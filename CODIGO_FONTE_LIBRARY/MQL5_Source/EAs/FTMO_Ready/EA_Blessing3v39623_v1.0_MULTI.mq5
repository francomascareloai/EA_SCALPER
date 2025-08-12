//+---------------------------------------------------------------------+
//|                                                Blessing 3 v3.9.6.23 |
//|                                                   December 13, 2021 |
//|                                                                     |
//|     In no event will authors be liable for any damages whatsoever.  |
//|                         Use at your own risk.                       |
//|                                                                     |
//|  This EA is dedicated to Mike McKeough, a member of the Blessing    |
//|  Development Group, who passed away on Saturday, 31st July 2010.    |
//|  His contributions to the development of this EA have helped make   |
//|  it what it is today, and we will miss his enthusiasm, dedication   |
//|  and desire to make this the best EA possible.                      |
//|  Rest In Peace.                                                     |
//+---------------------------------------------------------------------+
// This work has been entered into the public domain by its authors ...
// Copyrights have been rescinded.

// *** IMPORTANT:
// ***
// *** 1) All code from here through to line 3574 is for MT4-MT5 cross-compiler compatibility - do not edit!!
// ***
// *** 2) Ensure that this file is saved with UTF-8 encoding (use "Save As" in MetaEditor to be certain)

//+-----------------------------------------------------------------------------
// Versions .10 thru .18 ...
//
// .10 Clean up for new versions of MT4 and potentially MT5,
//     passes #property strict added EnableOncePerBar to allow use of
//     Open Prices Only model of MT4 Strategy Tester to vastly speed up
//     optimization.  Filters out ticks!
//     Also a few bug fixes and cosmetic changes.
// .11 Repaired external parameters from .10 so they match the Blessing manual
// .12 Added UseMinMarginPercent control to keep margin from dropping too low.
// .13 Holiday bug fix.
// .14 Enhanced PortionPC behavior, settings over 100 force effective balance
//     to that amount.  Assuming real balance is greater.
// .15 Fixed divide by zero error
// .16 Fixed Draw Down display
// .17
// .18 Added MA_TF, to replace hardwired Current setting for more control
// .19 Skipped a-la-Windows 10
// .20 MT4/MT5 common source file - compiles for both platforms
// .21 Added Ichimoku Cloud from MT4 .16 version
//+-----------------------------------------------------------------------------

#property version   "396.23"
#property strict


// MQL4&5-code

// Parallel use of MT4 and MT5 order systems.
// https://www.mql5.com/ru/code/16006

// This mqh-file after the corresponding #include allows you to work with orders in MQL5 (MT5-Hedge) in the same way as in MQL4.
// i.e. The order language system (SNR) becomes identical to MQL4. At the same time, it is possible to use PARALLELLY
// MQL5-order system. In particular, the standard MQL5 library will continue to work fully.
// You do not need to choose between order systems. Use them in parallel!

// When translating MQL4 -> MQL5, you do not need to touch the order system.
// Just add one line at the beginning (if the source can compile into MT4 with #property strict):

// #include <MT4Orders.mqh> // if there is #include <Expert / Expert.mqh>, insert this line AFTER

// Similarly acting (adding one line) in their MQL5-codes, you can add MT4-SNF to MT5-SNF, or completely replace it.

// The author created such an opportunity for himself, so he intentionally did not pursue a similar idea of transition "one line"
// for timeseries, graphic objects, indicators, etc.

// This work affects ONLY the order system.

// The question of the possibility of creating such a complete library, when MQL4-code can work in MT5 WITHOUT CHANGES, was not solved.

// What is not implemented:
// CloseBy-moments - until there was not before. Perhaps in the future, when needed.
// Definition of TP and SL of closed positions - at the moment (build 1470) MQL5 does not know how to do this.
// Accounting for DEAL_ENTRY_INOUT and DEAL_ENTRY_OUT_BY transactions.

// Features:
// In MT4 OrderSelect in SELECT_BY_TICKET mode selects a ticket regardless of MODE_TRADES / MODE_HISTORY,
// since "Ticket number is a unique order ID".
// In MT5, the ticket number is NOT unique,
// so OrderSelect in SELECT_BY_TICKET mode has the following selection priorities for matching tickets:
// MODE_TRADES: existing position> existing order> transaction> canceled order
// MODE_HISTORY: transaction> canceled order> existing position> existing order
//
// Accordingly, OrderSelect in the mode of SELECT_BY_TICKET in MT5 in rare cases (in the tester) can choose not what was conceived in MT4.
//
// If you call OrdersTotal() with the input parameter, the return value will match the MT5 variant.

// List of changes:
// 08.03.2016:
// Release - was written and checked only on the offline tester.
// 29.09.2016:
//    Add: the opportunity to work on the stock exchange (SYMBOL_TRADE_EXECUTION_EXCHANGE). Note that the exchange is Netto (not Hedge) -mode.
//    Add: The requirement "if there is #include <Trade / Trade.mqh>, insert this line AFTER"
//         replaced with "if there is #include <Expert / Expert.mqh>, insert this line AFTER."
//    Fix: OrderSend market orders returns a ticket position, not a trade.
// 13.11.2016:
//    Add: Complete synchronization OrderSend, OrderModify, OrderClose, OrderDelete with the trading environment (real-time and history) - as in MT4.
//         The maximum synchronization time can be set via MT4ORDERS::OrderSend_MaxPause in µs. The average synchronization time in MT5 is ~ 1 ms.
//         By default, the maximum synchronization time is one second. MT4ORDERS::OrderSend_MaxPause = 0 - no synchronization.
//    Add: Since the parameter Slippage (OrderSend, OrderClose) affects the execution of market orders only in Instant-mode,
//         then through it now, if desired, you can specify the type of execution for the remainder - ENUM_ORDER_TYPE_FILLING:
//         ORDER_FILLING_FOK, ORDER_FILLING_IOC, or ORDER_FILLING_RETURN.
//         In case of an erroneous job or no symbol support of the specified type of execution, the operating mode will be automatically selected.
//       Examples:
//         OrderSend(Symb, Type, Lots, Price, ORDER_FILLING_FOK, SL, TP) - send the corresponding order with execution type ORDER_FILLING_FOK
//         OrderSend(Symb, Type, Lots, Price, ORDER_FILLING_IOC, SL, TP) - send the corresponding order with execution type ORDER_FILLING_IOC
//         OrderClose(Ticket, Lots, Price, ORDER_FILLING_RETURN) - send the corresponding market order with the type of execution ORDER_FILLING_RETURN
//    Add: OrdersHistoryTotal() and OrderSelect(Pos, SELECT_BY_POS, MODE_HISTORY) are cached - they work as fast as possible.
//         There are no slow implementations in the library.
// 08.02.2017:
//    Add: The variables MT4ORDERS::__LastTradeRequest and MT4ORDERS::__LastTradeResult contain the corresponding MT5-OrderSend data.
// 14.06.2017:
//    Add: Included initially is the implementation of the definition of SL / TP closed positions (closed through OrderClose).
//    Add: MagicNumber now has the type long - 8 bytes (used to be int - 4 bytes).
//    Add: If the color input parameter in OrderSend, OrderClose or OrderModify (the most recent one) is set to INT_MAX, then the
//         corresponding trade MT5-request (MT4ORDERS::__LastTradeRequest), will NOT be sent. Instead, it will carry out its MT5-check,
//         the result of which will be available in MT4ORDERS::__LastTradeRequest.
//         If the check is successful, OrderModify and OrderClose return true, otherwise false.
//         OrderSend will return 0 in case of success, otherwise -1.
//
//         If the corresponding color input parameter is set to INT_MIN, ONLY in the case of a successful MT5-check of the generated
//         trade request (as in the case with INT_MAX) will it be sent.
//    Add: Added asynchronous analogs to MQL4-trading functions: OrderSendAsync, OrderModifyAsync, OrderCloseAsync, OrderDeleteAsync.
//         Return the corresponding Result.request_id in case of success, otherwise - 0.
// 03.08.2017:
//    Add: Added OrderCloseBy.
//    Add: The OrderSelect is speeded up in MODE_TRADES mode. Now it is possible to receive the data of the selected order through
//         corresponding MT4-Order functions, even if MT5-position / order (not in history) is selected not via MT4Orders.
//         For example, via MT5-PositionSelect * -functions or MT5-OrderSelect.
//    Add: Added OrderOpenPriceRequest () and OrderClosePriceRequest () - return the price of the trade request when the position is opened / closed.
//         With the help of these functions it is possible to calculate the corresponding order slips.
// 26.08.2017:
//    Add: Added OrderOpenTimeMsc () and OrderCloseTimeMsc () - the corresponding time in milliseconds.
//    Fix: Previously, all trade tickets had the int type, as in MT4. Because of the occurrence of cases of exceeding the limits of the int-type in MT5,
//         the type of tickets is changed to long. Accordingly, OrderTicket and OrderSend return long values. The return mode of the same type as in
//         MT4 (int) is turned on via writing the next line before #include <MT4Orders.mqh>
//
//         #define MT4_TICKET_TYPE // We bind OrderSend and OrderTicket to return a value of the same type as in MT4 - int.
// 03.09.2017:
//    Add: Added by OrderTicketOpen()  - Ticket MT5-transaction opening position
//                  OrderOpenReason()  - the reason for the MT5 opening deal (reason for opening the position)
//                  OrderCloseReason() - the reason for the MT5 closing deal (reason for closing the position)
// 14.09.2017:
//    Fix: Now the library does not see the current MT5-orders, which do not have the status ORDER_STATE_PLACED.
//         In order for the library to see all open MT5-orders, you need to register a line to the library
//
//         #define MT4ORDERS_SELECTFILTER_OFF // We require MT4Orders.mqh to see all current MT5-orders
// 16.10.2017:
//    Fix: OrdersHistoryTotal() reacts to the change of the account number at runtime.
// 13.02.2018
//    Add: Added logging of erroneous execution of MT5-OrderSend.
//    Fix: Now only the closing MT5-orders (SL / TP / SO, partial / full close) are "invisible".
//    Fix: The mechanism for determining SL / TP closed positions after OrderClose is corrected - it works if StopLevel allows.
// 15.02.2018
//    Fix: The MT5-OrderSend synchronization check now takes into account possible features of the ECN / STP implementation.
// 06.03.2018
//    Add: Added TICKET_TYPE and MAGIC_TYPE so that you can write a single cross-platform code without compiler warnings (including strict-mode MQL4).
// 30.05.2018
//    Add: Accelerated work with the history of trade, selected the golden mean of the realizations between productivity and
//         Memory consumption is important for VPS. A standard Generic library is used.
//         If you do not want to use the Generic library, then the old history mode is available.
//         To do this, you need to register a line before the MT4Orders library
//
//         #define MT4ORDERS_FASTHISTORY_OFF // Turn off the fast implementation of the trade history - do not use Generic-library.
// 02.11.2018
//    Fix: The opening price of the MT4 position before it triggers can no longer be zero.
//    Fix: Rare features of execution of some trading servers are taken into account.
// 26.11.2018
//    Fix: Magic and comment of the closed MT4 position: the priority of the corresponding fields of opening deals is higher than that of the closing ones.
//    Fix: Takes a rare change in MT5-OrdersTotal and MT5-PositionsTotal during the calculation of MT4-OrdersTotal and MT4-OrderSelect.
//    Fix: Orders that opened a position, but did not manage to retire MT5, are no longer taken into account by the library.
// 17.01.2019
//    Fix: Fixed an annoying error when selecting pending orders.
// 08.02.2019
//    Add: Position comment is saved when partially closed via OrderClose.
//         If you want to change the comment of an open position at partial closing, you can set it in OrderClose.
// 20.02.2019
//    Fix: If there is no MT5 order from the existing MT5 transaction, the library will wait for the history to be synchronized. In case of failure will report this.
// 13.03.2019
//    Add: Added OrderTicketID () - PositionID of an MT5 transaction or MT5 position, a ticket of a pending MT4 order.
//    Add: SELECT_BY_TICKET applies to all MT5 tickets (and MT5-PositionID).
// 02.11.2019
//    Fix: Lot, commission and closing price for CloseBy positions have been adjusted.
// 12.01.2020
//    Fix: OrderTicketID() for book transactions now returns the correct value.
//    Fix: Adjusted SELECT_BY_TICKET selection by OrderTicketID() (MT5-PositionID).
//    Fix: Changed the name of the internal library method for greater compatibility with macros.
// 10.04.2020
//    Fix: A partially executed live pending order did not fall into OrdersTotal().
// 09.06.2020
//    Add: Better StopLoss / TakeProfit / ClosePriceRequest prices for closed positions are better defined.
// 10.06.2020
//    Add: Added milliseconds and removed rounding of prices, volumes in OrderPrint().
// 13.08.2020
//    Add: Added the ability to check the performance of library parts through the MT4ORDERS_BENCHMARK_MINTIME macro.
// 20.08.2020
//    Fix: Taking into account the revealed features of partial order execution.
// 29.08.2020
//    Fix: Working with the history of trades has been accelerated.
// 30.09.2020
//    Add: If you need to increase the priority of MT5 order selection over MT5 position when selecting a live MT4 order by SELECT_BY_TICKET
//         (the tickets are the same), then this can be done by changing the ticket sign to negative: OrderSelect (-Ticket, SELECT_BY_TICKET).
//    Add: If you need to select only MT5 order when modifying a live MT4 order (tickets are the same),
//         then this can be done by changing the ticket sign to negative: OrderModify (-Ticket, ...).
//    Add: OrderSelect (INT_MAX, SELECT_BY_POS) - switch to MT5 position without checking for existence and updating.
//         OrderSelect (INT_MIN, SELECT_BY_POS) - switch to a live MT5 order without checking for existence and updating.
//    Fix: Working with the history of trades has been accelerated.
// 09/30/2020
//    Fix: Working with the history of trades has been accelerated.

#ifdef __MQL5__

#define MT4_TICKET_TYPE

#ifndef __MT4ORDERS__

// #define MT4ORDERS_BENCHMARK_MINTIME 1000 // Minimum time for the performance alert

#ifdef MT4ORDERS_BENCHMARK_MINTIME
  #include <fxsaber\Benchmark.mqh> // https://c.mql5.com/3/332/Benchmark.mqh

  #define _B2(A) _B(A, MT4ORDERS_BENCHMARK_MINTIME)
  #define _B3(A) _B(A, 1)
  #define _BV2(A) _BV(A, MT4ORDERS_BENCHMARK_MINTIME)
#else // MT4ORDERS_BENCHMARK_MINTIME
  #define _B2(A) (A)
  #define _B3(A) (A)
  #define _BV2(A) { A; }
#endif // MT4ORDERS_BENCHMARK_MINTIME

#define __MT4ORDERS__ "2020.09.30"
#define MT4ORDERS_SLTP_OLD // Enabling the old mechanism for determining SL / TP closed positions via OrderClose

#ifdef MT4_TICKET_TYPE
  #define TICKET_TYPE int
  #define MAGIC_TYPE  int

  #undef MT4_TICKET_TYPE
#else // MT4_TICKET_TYPE
  #define TICKET_TYPE long // Negative values are also required for OrderSelectByTicket.
  #define MAGIC_TYPE  long
#endif // MT4_TICKET_TYPE

struct MT4_ORDER
{
  long Ticket;
  int Type;

  long TicketOpen;
  long TicketID;

  double Lots;

  string Symbol;
  string Comment;

  double OpenPriceRequest;
  double OpenPrice;

  long OpenTimeMsc;
  datetime OpenTime;

  ENUM_DEAL_REASON OpenReason;

  double StopLoss;
  double TakeProfit;

  double ClosePriceRequest;
  double ClosePrice;

  long CloseTimeMsc;
  datetime CloseTime;

  ENUM_DEAL_REASON CloseReason;

  ENUM_ORDER_STATE State;

  datetime Expiration;

  long MagicNumber;

  double Profit;

  double Commission;
  double Swap;

#define POSITION_SELECT (-1)
#define ORDER_SELECT (-2)

  static int GetDigits( double Price )
  {
    int Res = 0;

    while ((bool)(Price = ::NormalizeDouble(Price - (int)Price, 8)))
    {
      Price *= 10;

      Res++;
    }

    return(Res);
  }

  static string DoubleToString( const double Num, const int digits )
  {
    return(::DoubleToString(Num, ::MathMax(digits, MT4_ORDER::GetDigits(Num))));
  }

  static string TimeToString( const long time )
  {
    return((string)(datetime)(time / 1000) + "." + ::IntegerToString(time % 1000, 3, '0'));
  }

  static const MT4_ORDER GetPositionData( void )
  {
    MT4_ORDER Res = {0};

    Res.Ticket = ::PositionGetInteger(POSITION_TICKET);
    Res.Type = (int)::PositionGetInteger(POSITION_TYPE);

    Res.Lots = ::PositionGetDouble(POSITION_VOLUME);

    Res.Symbol = ::PositionGetString(POSITION_SYMBOL);

    Res.OpenPrice = ::PositionGetDouble(POSITION_PRICE_OPEN);
    Res.OpenTimeMsc = (datetime)::PositionGetInteger(POSITION_TIME_MSC);

    Res.StopLoss = ::PositionGetDouble(POSITION_SL);
    Res.TakeProfit = ::PositionGetDouble(POSITION_TP);

    Res.ClosePrice = ::PositionGetDouble(POSITION_PRICE_CURRENT);
    Res.CloseTimeMsc = 0;

    Res.Expiration = 0;

    Res.MagicNumber = ::PositionGetInteger(POSITION_MAGIC);

    Res.Profit = ::PositionGetDouble(POSITION_PROFIT);

    Res.Swap = ::PositionGetDouble(POSITION_SWAP);

    return(Res);
  }

  static const MT4_ORDER GetOrderData( void )
  {
    MT4_ORDER Res = {0};

    Res.Ticket = ::OrderGetInteger(ORDER_TICKET);
    Res.Type = (int)::OrderGetInteger(ORDER_TYPE);

    Res.Lots = ::OrderGetDouble(ORDER_VOLUME_CURRENT);

    Res.Symbol = ::OrderGetString(ORDER_SYMBOL);
    Res.Comment = ::OrderGetString(ORDER_COMMENT);

    Res.OpenPrice = ::OrderGetDouble(ORDER_PRICE_OPEN);
    Res.OpenTimeMsc = (datetime)::OrderGetInteger(ORDER_TIME_SETUP_MSC);

    Res.StopLoss = ::OrderGetDouble(ORDER_SL);
    Res.TakeProfit = ::OrderGetDouble(ORDER_TP);

    Res.ClosePrice = ::OrderGetDouble(ORDER_PRICE_CURRENT);
    Res.CloseTimeMsc = 0; // (datetime)::OrderGetInteger(ORDER_TIME_DONE)

    Res.Expiration = (datetime)::OrderGetInteger(ORDER_TIME_EXPIRATION);

    Res.MagicNumber = ::OrderGetInteger(ORDER_MAGIC);

    Res.Profit = 0;

    Res.Commission = 0;
    Res.Swap = 0;

    if (!Res.OpenPrice)
      Res.OpenPrice = Res.ClosePrice;

    return(Res);
  }

  string ToString( void ) const
  {
    static const string Types[] = {"buy", "sell", "buy limit", "sell limit", "buy stop", "sell stop", "balance"};
    const int digits = (int)::SymbolInfoInteger(this.Symbol, SYMBOL_DIGITS);

    MT4_ORDER TmpOrder = {0};

    if (this.Ticket == POSITION_SELECT)
    {
      TmpOrder = MT4_ORDER::GetPositionData();

      TmpOrder.Comment = this.Comment;
      TmpOrder.Commission = this.Commission;
    }
    else if (this.Ticket == ORDER_SELECT)
      TmpOrder = MT4_ORDER::GetOrderData();

    return(((this.Ticket == POSITION_SELECT) || (this.Ticket == ORDER_SELECT)) ? TmpOrder.ToString() :
           ("#" + (string)this.Ticket + " " +
            MT4_ORDER::TimeToString(this.OpenTimeMsc) + " " +
            ((this.Type < ::ArraySize(Types)) ? Types[this.Type] : "unknown") + " " +
            MT4_ORDER::DoubleToString(this.Lots, 2) + " " +
            (::StringLen(this.Symbol) ? this.Symbol + " " : NULL) +
            MT4_ORDER::DoubleToString(this.OpenPrice, digits) + " " +
            MT4_ORDER::DoubleToString(this.StopLoss, digits) + " " +
            MT4_ORDER::DoubleToString(this.TakeProfit, digits) + " " +
            ((this.CloseTimeMsc > 0) ? (MT4_ORDER::TimeToString(this.CloseTimeMsc) + " ") : "") +
            MT4_ORDER::DoubleToString(this.ClosePrice, digits) + " " +
            MT4_ORDER::DoubleToString(::NormalizeDouble(this.Commission, 3), 2) + " " + // Don't print more than three digits after the decimal point
            MT4_ORDER::DoubleToString(this.Swap, 2) + " " +
            MT4_ORDER::DoubleToString(this.Profit, 2) + " " +
            ((this.Comment == "") ? "" : (this.Comment + " ")) +
            (string)this.MagicNumber +
            (((this.Expiration > 0) ? (" expiration " + (string)this.Expiration): ""))));
  }
};

#define RESERVE_SIZE 1000
#define DAY (24 * 3600)
#define HISTORY_PAUSE (MT4HISTORY::IsTester ? 0 : 5)
#define END_TIME D'31.12.3000 23:59:59'
#define THOUSAND 1000
#define LASTTIME(A)                                          \
  if (Time##A >= LastTimeMsc)                                \
  {                                                          \
    const datetime TmpTime = (datetime)(Time##A / THOUSAND); \
                                                             \
    if (TmpTime > this.LastTime)                             \
    {                                                        \
      this.LastTotalOrders = 0;                              \
      this.LastTotalDeals = 0;                               \
                                                             \
      this.LastTime = TmpTime;                               \
      LastTimeMsc = this.LastTime * THOUSAND;                \
    }                                                        \
                                                             \
    this.LastTotal##A##s++;                                  \
  }

#ifndef MT4ORDERS_FASTHISTORY_OFF
  #include <Generic\HashMap.mqh>
#endif // MT4ORDERS_FASTHISTORY_OFF

class MT4HISTORY
{
private:
  static const bool MT4HISTORY::IsTester;
//  static long MT4HISTORY::AccountNumber;

#ifndef MT4ORDERS_FASTHISTORY_OFF
  CHashMap<ulong, ulong> DealsIn;  // By positionID returns DealIn
  CHashMap<ulong, ulong> DealsOut; // By positionID returns DealOut
#endif // MT4ORDERS_FASTHISTORY_OFF

  long Tickets[];
  uint Amount;

  int LastTotalDeals;
  int LastTotalOrders;

#ifdef MT4ORDERS_HISTORY_OLD

  datetime LastTime;
  datetime LastInitTime;

  int PrevDealsTotal;
  int PrevOrdersTotal;

  // https://www.mql5.com/ru/forum/93352/page50#comment_18040243
  bool IsChangeHistory( void )
  {
    bool Res = !_B2(::HistorySelect(0, INT_MAX));

    if (!Res)
    {
      const int iDealsTotal = ::HistoryDealsTotal();
      const int iOrdersTotal = ::HistoryOrdersTotal();

      if (Res = (iDealsTotal != this.PrevDealsTotal) || (iOrdersTotal != this.PrevOrdersTotal))
      {
        this.PrevDealsTotal = iDealsTotal;
        this.PrevOrdersTotal = iOrdersTotal;
      }
    }

    return(Res);
  }

  bool RefreshHistory( void )
  {
    bool Res = !MT4HISTORY::IsChangeHistory();

    if (!Res)
    {
      const datetime LastTimeCurrent = ::TimeCurrent();

      if (!MT4HISTORY::IsTester && ((LastTimeCurrent >= this.LastInitTime + DAY)))
      {
        this.LastTime = 0;

        this.LastTotalOrders = 0;
        this.LastTotalDeals = 0;

        this.Amount = 0;

        ::ArrayResize(this.Tickets, this.Amount, RESERVE_SIZE);

        this.LastInitTime = LastTimeCurrent;

      #ifndef MT4ORDERS_FASTHISTORY_OFF
        this.DealsIn.Clear();
        this.DealsOut.Clear();
      #endif // MT4ORDERS_FASTHISTORY_OFF
      }

      const datetime LastTimeCurrentLeft = LastTimeCurrent - HISTORY_PAUSE;

      // If LastTime is zero, then HistorySelect has already been made in MT4HISTORY :: IsChangeHistory ()
      if (!this.LastTime || _B2(::HistorySelect(this.LastTime, END_TIME))) // https://www.mql5.com/ru/forum/285631/page79#comment_9884935
      {
        const int TotalOrders = ::HistoryOrdersTotal();
        const int TotalDeals = ::HistoryDealsTotal();

        Res = ((TotalOrders > this.LastTotalOrders) || (TotalDeals > this.LastTotalDeals));

        if (Res)
        {
          int iOrder = this.LastTotalOrders;
          int iDeal = this.LastTotalDeals;

          ulong TicketOrder = 0;
          ulong TicketDeal = 0;

          long TimeOrder = (iOrder < TotalOrders) ? ::HistoryOrderGetInteger((TicketOrder = ::HistoryOrderGetTicket(iOrder)), ORDER_TIME_DONE_MSC) : LONG_MAX;
          long TimeDeal = (iDeal < TotalDeals) ? ::HistoryDealGetInteger((TicketDeal = ::HistoryDealGetTicket(iDeal)), DEAL_TIME_MSC) : LONG_MAX;

          if (this.LastTime < LastTimeCurrentLeft)
          {
            this.LastTotalOrders = 0;
            this.LastTotalDeals = 0;

            this.LastTime = LastTimeCurrentLeft;
          }

          long LastTimeMsc = this.LastTime * THOUSAND;

          while ((iDeal < TotalDeals) || (iOrder < TotalOrders))
            if (TimeOrder < TimeDeal)
            {
              LASTTIME(Order)

              if (MT4HISTORY::IsMT4Order(TicketOrder))
              {
                this.Amount = ::ArrayResize(this.Tickets, this.Amount + 1, RESERVE_SIZE);

                this.Tickets[this.Amount - 1] = -(long)TicketOrder;
              }

              iOrder++;

              TimeOrder = (iOrder < TotalOrders) ? ::HistoryOrderGetInteger((TicketOrder = ::HistoryOrderGetTicket(iOrder)), ORDER_TIME_DONE_MSC) : LONG_MAX;
            }
            else
            {
              LASTTIME(Deal)

              if (MT4HISTORY::IsMT4Deal(TicketDeal))
              {
                this.Amount = ::ArrayResize(this.Tickets, this.Amount + 1, RESERVE_SIZE);

                this.Tickets[this.Amount - 1] = (long)TicketDeal;

              #ifndef MT4ORDERS_FASTHISTORY_OFF
                _B2(this.DealsOut.Add(::HistoryDealGetInteger(TicketDeal, DEAL_POSITION_ID), TicketDeal));
              #endif // MT4ORDERS_FASTHISTORY_OFF
              }
            #ifndef MT4ORDERS_FASTHISTORY_OFF
              else if ((ENUM_DEAL_ENTRY)::HistoryDealGetInteger(TicketDeal, DEAL_ENTRY) == DEAL_ENTRY_IN)
                _B2(this.DealsIn.Add(::HistoryDealGetInteger(TicketDeal, DEAL_POSITION_ID), TicketDeal));
            #endif // MT4ORDERS_FASTHISTORY_OFF

              iDeal++;

              TimeDeal = (iDeal < TotalDeals) ? ::HistoryDealGetInteger((TicketDeal = ::HistoryDealGetTicket(iDeal)), DEAL_TIME_MSC) : LONG_MAX;
            }
        }
        else if (LastTimeCurrentLeft > this.LastTime)
        {
          this.LastTime = LastTimeCurrentLeft;

          this.LastTotalOrders = 0;
          this.LastTotalDeals = 0;
        }
      }
    }

    return(Res);
  }

#else // #ifdef MT4ORDERS_HISTORY_OLD
  bool RefreshHistory( void )
  {
    if (_B2(::HistorySelect(0, INT_MAX)))
    {
      const int TotalOrders = ::HistoryOrdersTotal();
      const int TotalDeals = ::HistoryDealsTotal();

      if ((TotalOrders > this.LastTotalOrders) || (TotalDeals > this.LastTotalDeals))
      {
        ulong TicketOrder = 0;
        ulong TicketDeal = 0;

        long TimeOrder = (this.LastTotalOrders < TotalOrders) ?
                           ::HistoryOrderGetInteger((TicketOrder = ::HistoryOrderGetTicket(this.LastTotalOrders)), ORDER_TIME_DONE_MSC) : LONG_MAX;
        long TimeDeal = (this.LastTotalDeals < TotalDeals) ?
                          ::HistoryDealGetInteger((TicketDeal = ::HistoryDealGetTicket(this.LastTotalDeals)), DEAL_TIME_MSC) : LONG_MAX;

        while ((this.LastTotalDeals < TotalDeals) || (this.LastTotalOrders < TotalOrders))
          if (TimeOrder < TimeDeal)
          {
            if (MT4HISTORY::IsMT4Order(TicketOrder))
            {
              this.Amount = ::ArrayResize(this.Tickets, this.Amount + 1, RESERVE_SIZE);

              this.Tickets[this.Amount - 1] = -(long)TicketOrder;
            }

            this.LastTotalOrders++;

            TimeOrder = (this.LastTotalOrders < TotalOrders) ?
                          ::HistoryOrderGetInteger((TicketOrder = ::HistoryOrderGetTicket(this.LastTotalOrders)), ORDER_TIME_DONE_MSC) : LONG_MAX;
          }
          else
          {
            if (MT4HISTORY::IsMT4Deal(TicketDeal))
            {
              this.Amount = ::ArrayResize(this.Tickets, this.Amount + 1, RESERVE_SIZE);

              this.Tickets[this.Amount - 1] = (long)TicketDeal;

              _B2(this.DealsOut.Add(::HistoryDealGetInteger(TicketDeal, DEAL_POSITION_ID), TicketDeal));
            }
            else if ((ENUM_DEAL_ENTRY)::HistoryDealGetInteger(TicketDeal, DEAL_ENTRY) == DEAL_ENTRY_IN)
              _B2(this.DealsIn.Add(::HistoryDealGetInteger(TicketDeal, DEAL_POSITION_ID), TicketDeal));

            this.LastTotalDeals++;

            TimeDeal = (this.LastTotalDeals < TotalDeals) ?
                         ::HistoryDealGetInteger((TicketDeal = ::HistoryDealGetTicket(this.LastTotalDeals)), DEAL_TIME_MSC) : LONG_MAX;
          }
      }
    }

    return(true);
  }
#endif // #ifdef MT4ORDERS_HISTORY_OLD #else
public:
  static bool IsMT4Deal( const ulong &Ticket )
  {
    const ENUM_DEAL_TYPE DealType = (ENUM_DEAL_TYPE)::HistoryDealGetInteger(Ticket, DEAL_TYPE);
    const ENUM_DEAL_ENTRY DealEntry = (ENUM_DEAL_ENTRY)::HistoryDealGetInteger(Ticket, DEAL_ENTRY);

    return(((DealType != DEAL_TYPE_BUY) && (DealType != DEAL_TYPE_SELL)) ||      // not a bargain
           ((DealEntry == DEAL_ENTRY_OUT) || (DealEntry == DEAL_ENTRY_OUT_BY))); // commercial
  }

  static bool IsMT4Order( const ulong &Ticket )
  {
    // If the pending order is executed, its ORDER_POSITION_ID is filled
    // https://www.mql5.com/ru/forum/170952/page70#comment_6543162
    // https://www.mql5.com/ru/forum/93352/page19#comment_6646726
    // Second condition: when the limit order was partially filled and then deleted
    return(!::HistoryOrderGetInteger(Ticket, ORDER_POSITION_ID) || (::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_CURRENT) &&
                                                                    ::HistoryOrderGetInteger(Ticket, ORDER_TYPE) > ORDER_TYPE_SELL));
  }

  MT4HISTORY( void ) : Amount(::ArrayResize(this.Tickets, 0, RESERVE_SIZE)),
                       LastTotalDeals(0), LastTotalOrders(0)
                     #ifdef MT4ORDERS_HISTORY_OLD
                       , LastTime(0), LastInitTime(0), PrevDealsTotal(0), PrevOrdersTotal(0)
                     #endif // #ifdef MT4ORDERS_HISTORY_OLD
  {
  }

  ulong GetPositionDealIn( const ulong PositionIdentifier = -1 ) // 0 - it is impossible, because the balance sheet of the tester has zero
  {
    ulong Ticket = 0;

    if (PositionIdentifier == -1)
    {
      const ulong MyPositionIdentifier = ::PositionGetInteger(POSITION_IDENTIFIER);

    #ifndef MT4ORDERS_FASTHISTORY_OFF
      if (!_B2(this.DealsIn.TryGetValue(MyPositionIdentifier, Ticket))
          #ifndef MT4ORDERS_HISTORY_OLD
          && !_B2(this.RefreshHistory() && this.DealsIn.TryGetValue(MyPositionIdentifier, Ticket))
          #endif // #ifndef MT4ORDERS_HISTORY_OLD
          )
    #endif // MT4ORDERS_FASTHISTORY_OFF
      {
        const datetime PosTime = (datetime)::PositionGetInteger(POSITION_TIME);

        if (_B3(::HistorySelect(PosTime, PosTime)))
        {
          const int Total = ::HistoryDealsTotal();

          for (int i = 0; i < Total; i++)
          {
            const ulong TicketDeal = ::HistoryDealGetTicket(i);

            if ((::HistoryDealGetInteger(TicketDeal, DEAL_POSITION_ID) == MyPositionIdentifier)) // The first mention and so will be DEAL_ENTRY_IN
            {
              Ticket = TicketDeal;

            #ifndef MT4ORDERS_FASTHISTORY_OFF
              _B2(this.DealsIn.Add(MyPositionIdentifier, Ticket));
            #endif // MT4ORDERS_FASTHISTORY_OFF

              break;
            }
          }
        }
      }
    }
    else if (PositionIdentifier && // PositionIdentifier of balance transactions is zero
           #ifndef MT4ORDERS_FASTHISTORY_OFF
             !_B2(this.DealsIn.TryGetValue(PositionIdentifier, Ticket)) &&
             #ifndef MT4ORDERS_HISTORY_OLD
               !_B2(this.RefreshHistory() && this.DealsIn.TryGetValue(PositionIdentifier, Ticket)) &&
             #endif // #ifndef MT4ORDERS_HISTORY_OLD
           #endif // MT4ORDERS_FASTHISTORY_OFF
             _B3(::HistorySelectByPosition(PositionIdentifier)) && (::HistoryDealsTotal() > 1)) // Почему > 1, а не > 0 ?!
    {
      Ticket = _B2(::HistoryDealGetTicket(0)); // The first mention and so will be DEAL_ENTRY_IN

    #ifndef MT4ORDERS_FASTHISTORY_OFF
      _B2(this.DealsIn.Add(PositionIdentifier, Ticket));
    #endif // MT4ORDERS_FASTHISTORY_OFF
    }

    return(Ticket);
  }

  ulong GetPositionDealOut( const ulong PositionIdentifier )
  {
    ulong Ticket = 0;

  #ifndef MT4ORDERS_FASTHISTORY_OFF
    if (!_B2(this.DealsOut.TryGetValue(PositionIdentifier, Ticket)) && _B2(this.RefreshHistory()))
      _B2(this.DealsOut.TryGetValue(PositionIdentifier, Ticket));
    #endif // MT4ORDERS_FASTHISTORY_OFF

    return(Ticket);
  }

  int GetAmount( void )
  {
    _B2(this.RefreshHistory());

    return((int)this.Amount);
  }

  long operator []( const uint &Pos )
  {
    long Res = 0;

    if ((Pos >= this.Amount))
    {
      _B2(this.RefreshHistory());

      if (Pos < this.Amount)
        Res = this.Tickets[Pos];
    }
    else
      Res = this.Tickets[Pos];

    return(Res);
  }
};

static const bool MT4HISTORY::IsTester = ::MQLInfoInteger(MQL_TESTER);

#undef LASTTIME
#undef THOUSAND
#undef END_TIME
#undef HISTORY_PAUSE
#undef DAY
#undef RESERVE_SIZE

#define OP_BUY ORDER_TYPE_BUY
#define OP_SELL ORDER_TYPE_SELL
#define OP_BUYLIMIT ORDER_TYPE_BUY_LIMIT
#define OP_SELLLIMIT ORDER_TYPE_SELL_LIMIT
#define OP_BUYSTOP ORDER_TYPE_BUY_STOP
#define OP_SELLSTOP ORDER_TYPE_SELL_STOP
#define OP_BALANCE 6

#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1

#define MODE_TRADES 0
#define MODE_HISTORY 1

class MT4ORDERS
{
private:
  static MT4_ORDER Order;
  static MT4HISTORY History;

  static const bool MT4ORDERS::IsTester;
  static const bool MT4ORDERS::IsHedging;

  static int OrderSendBug;

  static bool HistorySelectOrder( const ulong Ticket )
  {
    return(Ticket && ((::HistoryOrderGetInteger(Ticket, ORDER_TICKET) == Ticket) ||
                      (_B2(::HistorySelect(0, INT_MAX)) && (::HistoryOrderGetInteger(Ticket, ORDER_TICKET) == Ticket))));
  }

  static bool HistorySelectDeal( const ulong &Ticket )
  {
    return(Ticket && ((::HistoryDealGetInteger(Ticket, DEAL_TICKET) == Ticket) ||
                      (_B2(::HistorySelect(0, INT_MAX)) && (::HistoryDealGetInteger(Ticket, DEAL_TICKET) == Ticket))));
  }

#define UNKNOWN_COMMISSION DBL_MIN
#define UNKNOWN_REQUEST_PRICE DBL_MIN
#define UNKNOWN_TICKET 0

  static bool CheckNewTicket( void )
  {
    return(false); // This functionality is useless - there is INT_MIN / INT_MAX with SELECT_BY_POS + MODE_TRADES

    static long PrevPosTimeUpdate = 0;
    static long PrevPosTicket = 0;

    const long PosTimeUpdate = ::PositionGetInteger(POSITION_TIME_UPDATE_MSC);
    const long PosTicket = ::PositionGetInteger(POSITION_TICKET);

    // If the user did not select the item via MT4Orders then overload MQL5-PositionSelect * and MQL5-OrderSelect is unreasonable.
    // This check is enough, because several position + PositionSelect changes in one millisecond are possible only in the tester:
    const bool Res = ((PosTimeUpdate != PrevPosTimeUpdate) || (PosTicket != PrevPosTicket));

    if (Res)
    {
      MT4ORDERS::GetPositionData();

      PrevPosTimeUpdate = PosTimeUpdate;
      PrevPosTicket = PosTicket;
    }

    return(Res);
  }

  static bool CheckPositionTicketOpen( void )
  {
    if ((MT4ORDERS::Order.TicketOpen == UNKNOWN_TICKET) || MT4ORDERS::CheckNewTicket())
      MT4ORDERS::Order.TicketOpen = (long)_B2(MT4ORDERS::History.GetPositionDealIn()); // All because of this very expensive function

    return(true);
  }

  static bool CheckPositionCommissionComment( void )
  {
    if ((MT4ORDERS::Order.Commission == UNKNOWN_COMMISSION) || MT4ORDERS::CheckNewTicket())
    {
      MT4ORDERS::Order.Commission = 0; // Always zero
      MT4ORDERS::Order.Comment = ::PositionGetString(POSITION_COMMENT);

      if (!MT4ORDERS::Order.Commission || (MT4ORDERS::Order.Comment == ""))
      {
        MT4ORDERS::CheckPositionTicketOpen();

        const ulong Ticket = MT4ORDERS::Order.TicketOpen;

        if ((Ticket > 0) && _B2(MT4ORDERS::HistorySelectDeal(Ticket)))
        {
          if (!MT4ORDERS::Order.Commission)
          {
            const double LotsIn = ::HistoryDealGetDouble(Ticket, DEAL_VOLUME);

            if (LotsIn > 0)
              MT4ORDERS::Order.Commission = ::HistoryDealGetDouble(Ticket, DEAL_COMMISSION) * ::PositionGetDouble(POSITION_VOLUME) / LotsIn;
          }

          if (MT4ORDERS::Order.Comment == "")
            MT4ORDERS::Order.Comment = ::HistoryDealGetString(Ticket, DEAL_COMMENT);
        }
      }
    }

    return(true);
  }

  static bool CheckPositionOpenPriceRequest( void )
  {
    const long PosTicket = ::PositionGetInteger(POSITION_TICKET);

    if (((MT4ORDERS::Order.OpenPriceRequest == UNKNOWN_REQUEST_PRICE) || MT4ORDERS::CheckNewTicket()) &&
        !(MT4ORDERS::Order.OpenPriceRequest = (_B2(MT4ORDERS::HistorySelectOrder(PosTicket)) &&
                                              (MT4ORDERS::IsTester || (::PositionGetInteger(POSITION_TIME_MSC) ==
                                              ::HistoryOrderGetInteger(PosTicket, ORDER_TIME_DONE_MSC)))) // Is this check necessary?
                                            ? ::HistoryOrderGetDouble(PosTicket, ORDER_PRICE_OPEN)
                                            : ::PositionGetDouble(POSITION_PRICE_OPEN)))
      MT4ORDERS::Order.OpenPriceRequest = ::PositionGetDouble(POSITION_PRICE_OPEN); // In case the order price is zero

    return(true);
  }

  static void GetPositionData( void )
  {
    MT4ORDERS::Order.Ticket = POSITION_SELECT;

    MT4ORDERS::Order.Commission = UNKNOWN_COMMISSION;
    MT4ORDERS::Order.OpenPriceRequest = UNKNOWN_REQUEST_PRICE;
    MT4ORDERS::Order.TicketOpen = UNKNOWN_TICKET;

    return;
  }

// #undef UNKNOWN_REASON
#undef UNKNOWN_TICKET
#undef UNKNOWN_REQUEST_PRICE
#undef UNKNOWN_COMMISSION

  static void GetOrderData( void )
  {
    MT4ORDERS::Order.Ticket = ORDER_SELECT;

    return;
  }

  static void GetHistoryOrderData( const ulong Ticket )
  {
    MT4ORDERS::Order.Ticket = ::HistoryOrderGetInteger(Ticket, ORDER_TICKET);
    MT4ORDERS::Order.Type = (int)::HistoryOrderGetInteger(Ticket, ORDER_TYPE);

    MT4ORDERS::Order.TicketOpen = MT4ORDERS::Order.Ticket;
    MT4ORDERS::Order.TicketID = MT4ORDERS::Order.Ticket;

    MT4ORDERS::Order.Lots = ::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_CURRENT);

    if (!MT4ORDERS::Order.Lots)
      MT4ORDERS::Order.Lots = ::HistoryOrderGetDouble(Ticket, ORDER_VOLUME_INITIAL);

    MT4ORDERS::Order.Symbol = ::HistoryOrderGetString(Ticket, ORDER_SYMBOL);
    MT4ORDERS::Order.Comment = ::HistoryOrderGetString(Ticket, ORDER_COMMENT);

    MT4ORDERS::Order.OpenTimeMsc = ::HistoryOrderGetInteger(Ticket, ORDER_TIME_SETUP_MSC);
    MT4ORDERS::Order.OpenTime = (datetime)(MT4ORDERS::Order.OpenTimeMsc / 1000);

    MT4ORDERS::Order.OpenPrice = ::HistoryOrderGetDouble(Ticket, ORDER_PRICE_OPEN);
    MT4ORDERS::Order.OpenPriceRequest = MT4ORDERS::Order.OpenPrice;

    MT4ORDERS::Order.OpenReason = (ENUM_DEAL_REASON)::HistoryOrderGetInteger(Ticket, ORDER_REASON);

    MT4ORDERS::Order.StopLoss = ::HistoryOrderGetDouble(Ticket, ORDER_SL);
    MT4ORDERS::Order.TakeProfit = ::HistoryOrderGetDouble(Ticket, ORDER_TP);

    MT4ORDERS::Order.CloseTimeMsc = ::HistoryOrderGetInteger(Ticket, ORDER_TIME_DONE_MSC);
    MT4ORDERS::Order.CloseTime = (datetime)(MT4ORDERS::Order.CloseTimeMsc / 1000);

    MT4ORDERS::Order.ClosePrice = ::HistoryOrderGetDouble(Ticket, ORDER_PRICE_CURRENT);
    MT4ORDERS::Order.ClosePriceRequest = MT4ORDERS::Order.ClosePrice;

    MT4ORDERS::Order.CloseReason = MT4ORDERS::Order.OpenReason;

    MT4ORDERS::Order.State = (ENUM_ORDER_STATE)::HistoryOrderGetInteger(Ticket, ORDER_STATE);

    MT4ORDERS::Order.Expiration = (datetime)::HistoryOrderGetInteger(Ticket, ORDER_TIME_EXPIRATION);

    MT4ORDERS::Order.MagicNumber = ::HistoryOrderGetInteger(Ticket, ORDER_MAGIC);

    MT4ORDERS::Order.Profit = 0;

    MT4ORDERS::Order.Commission = 0;
    MT4ORDERS::Order.Swap = 0;

    return;
  }

  static string GetTickFlag( uint tickflag )
  {
    string flag = " " + (string)tickflag;

  #define TICKFLAG_MACRO(A) flag += ((bool)(tickflag & TICK_FLAG_##A)) ? " TICK_FLAG_" + #A : ""; \
                            tickflag -= tickflag & TICK_FLAG_##A;
    TICKFLAG_MACRO(BID)
    TICKFLAG_MACRO(ASK)
    TICKFLAG_MACRO(LAST)
    TICKFLAG_MACRO(VOLUME)
    TICKFLAG_MACRO(BUY)
    TICKFLAG_MACRO(SELL)
  #undef TICKFLAG_MACRO

    if (tickflag)
      flag += " FLAG_UNKNOWN (" + (string)tickflag + ")";

    return(flag);
  }

#define TOSTR(A) " " + #A + " = " + (string)Tick.A
#define TOSTR2(A) " " + #A + " = " + ::DoubleToString(Tick.A, digits)
#define TOSTR3(A) " " + #A + " = " + (string)(A)

  static string TickToString( const string &Symb, const MqlTick &Tick )
  {
    const int digits = (int)::SymbolInfoInteger(Symb, SYMBOL_DIGITS);

    return(TOSTR3(Symb) + TOSTR(time) + "." + ::IntegerToString(Tick.time_msc % 1000, 3, '0') +
           TOSTR2(bid) + TOSTR2(ask) + TOSTR2(last)+ TOSTR(volume) + MT4ORDERS::GetTickFlag(Tick.flags));
  }

  static string TickToString( const string &Symb )
  {
    MqlTick Tick = {0};

    return(TOSTR3(::SymbolInfoTick(Symb, Tick)) + MT4ORDERS::TickToString(Symb, Tick));
  }

#undef TOSTR3
#undef TOSTR2
#undef TOSTR

  static void AlertLog( void )
  {
    ::Alert("Please send the logs to the coauthor - https://www.mql5.com/en/users/fxsaber");

    string Str = ::TimeToString(::TimeLocal(), TIME_DATE);
    ::StringReplace(Str, ".", NULL);

    ::Alert(::TerminalInfoString(TERMINAL_PATH) + "\\MQL5\\Logs\\" + Str + ".log");

    return;
  }

  static long GetTimeCurrent( void )
  {
    long Res = 0;
    MqlTick Tick = {0};

    for (int i = ::SymbolsTotal(true) - 1; i >= 0; i--)
    {
      const string SymbName = ::SymbolName(i, true);

      if (!::SymbolInfoInteger(SymbName, SYMBOL_CUSTOM) && ::SymbolInfoTick(SymbName, Tick) && (Tick.time_msc > Res))
        Res = Tick.time_msc;
    }

    return(Res);
  }

  static string TimeToString( const long time )
  {
    return((string)(datetime)(time / 1000) + "." + ::IntegerToString(time % 1000, 3, '0'));
  }

#define WHILE(A) while ((!(Res = (A))) && MT4ORDERS::Waiting())

#define TOSTR(A)  #A + " = " + (string)(A) + "\n"
#define TOSTR2(A) #A + " = " + ::EnumToString(A) + " (" + (string)(A) + ")\n"

  static void GetHistoryPositionData( const ulong Ticket )
  {
    MT4ORDERS::Order.Ticket = (long)Ticket;
    MT4ORDERS::Order.TicketID = ::HistoryDealGetInteger(MT4ORDERS::Order.Ticket, DEAL_POSITION_ID);
    MT4ORDERS::Order.Type = (int)::HistoryDealGetInteger(Ticket, DEAL_TYPE);

    if ((MT4ORDERS::Order.Type > OP_SELL))
      MT4ORDERS::Order.Type += (OP_BALANCE - OP_SELL - 1);
    else
      MT4ORDERS::Order.Type = 1 - MT4ORDERS::Order.Type;

    MT4ORDERS::Order.Lots = ::HistoryDealGetDouble(Ticket, DEAL_VOLUME);

    MT4ORDERS::Order.Symbol = ::HistoryDealGetString(Ticket, DEAL_SYMBOL);
    MT4ORDERS::Order.Comment = ::HistoryDealGetString(Ticket, DEAL_COMMENT);

    MT4ORDERS::Order.CloseTimeMsc = ::HistoryDealGetInteger(Ticket, DEAL_TIME_MSC);
    MT4ORDERS::Order.CloseTime = (datetime)(MT4ORDERS::Order.CloseTimeMsc / 1000);

    MT4ORDERS::Order.ClosePrice = ::HistoryDealGetDouble(Ticket, DEAL_PRICE);

    MT4ORDERS::Order.CloseReason = (ENUM_DEAL_REASON)::HistoryDealGetInteger(Ticket, DEAL_REASON);;

    MT4ORDERS::Order.Expiration = 0;

    MT4ORDERS::Order.MagicNumber = ::HistoryDealGetInteger(Ticket, DEAL_MAGIC);

    MT4ORDERS::Order.Profit = ::HistoryDealGetDouble(Ticket, DEAL_PROFIT);

    MT4ORDERS::Order.Commission = ::HistoryDealGetDouble(Ticket, DEAL_COMMISSION);
    MT4ORDERS::Order.Swap = ::HistoryDealGetDouble(Ticket, DEAL_SWAP);

#ifndef MT4ORDERS_SLTP_OLD
    MT4ORDERS::Order.StopLoss = ::HistoryDealGetDouble(Ticket, DEAL_SL);
    MT4ORDERS::Order.TakeProfit = ::HistoryDealGetDouble(Ticket, DEAL_TP);
#else // MT4ORDERS_SLTP_OLD
    MT4ORDERS::Order.StopLoss = 0;
    MT4ORDERS::Order.TakeProfit = 0;
#endif // MT4ORDERS_SLTP_OLD

    const ulong OrderTicket = (MT4ORDERS::Order.Type < OP_BALANCE) ? ::HistoryDealGetInteger(Ticket, DEAL_ORDER) : 0;
    const ulong PosTicket = MT4ORDERS::Order.TicketID;
    const ulong OpenTicket = (OrderTicket > 0) ? _B2(MT4ORDERS::History.GetPositionDealIn(PosTicket)) : 0;

    if (OpenTicket > 0)
    {
      const ENUM_DEAL_REASON Reason = (ENUM_DEAL_REASON)HistoryDealGetInteger(Ticket, DEAL_REASON);
      const ENUM_DEAL_ENTRY DealEntry = (ENUM_DEAL_ENTRY)::HistoryDealGetInteger(Ticket, DEAL_ENTRY);

    // History (OpenTicket and OrderTicket) is loaded, thanks to GetPositionDealIn, - HistorySelectByPosition
    #ifdef MT4ORDERS_FASTHISTORY_OFF
      const bool Res = true;
    #else // MT4ORDERS_FASTHISTORY_OFF
      // Partial execution will generate the desired order - https://www.mql5.com/ru/forum/227423/page2#comment_6543129
      bool Res = MT4ORDERS::IsTester ? MT4ORDERS::HistorySelectOrder(OrderTicket) : MT4ORDERS::Waiting(true);

      // You can wait a long time in this situation: https://www.mql5.com/ru/forum/170952/page184#comment_17913645
      if (!Res)
        WHILE(_B2(MT4ORDERS::HistorySelectOrder(OrderTicket))) // https://www.mql5.com/ru/forum/304239#comment_10710403
          ;

      if (_B2(MT4ORDERS::HistorySelectDeal(OpenTicket))) // Sure to work, because OpenTicket guaranteed in history
    #endif // MT4ORDERS_FASTHISTORY_OFF
      {
        MT4ORDERS::Order.TicketOpen = (long)OpenTicket;

        MT4ORDERS::Order.OpenReason = Reason;

        MT4ORDERS::Order.OpenPrice = ::HistoryDealGetDouble(OpenTicket, DEAL_PRICE);

        MT4ORDERS::Order.OpenTimeMsc = ::HistoryDealGetInteger(OpenTicket, DEAL_TIME_MSC);
        MT4ORDERS::Order.OpenTime = (datetime)(MT4ORDERS::Order.OpenTimeMsc / 1000);

        const double OpenLots = ::HistoryDealGetDouble(OpenTicket, DEAL_VOLUME);

        if (OpenLots > 0)
          MT4ORDERS::Order.Commission += ::HistoryDealGetDouble(OpenTicket, DEAL_COMMISSION) * MT4ORDERS::Order.Lots / OpenLots;

          const long __Magic = ::HistoryDealGetInteger(OpenTicket, DEAL_MAGIC);

          if (__Magic)
            MT4ORDERS::Order.MagicNumber = __Magic;

          const string StrComment = ::HistoryDealGetString(OpenTicket, DEAL_COMMENT);

        if (Res) // OrderTicket may not be in history, but may be among the living. Perhaps it is reasonable to get the necessary info from there.
        {
          double OrderPriceOpen = ::HistoryOrderGetDouble(OrderTicket, ORDER_PRICE_OPEN);

      #ifdef MT4ORDERS_SLTP_OLD
          if (Reason == DEAL_REASON_SL)
          {
            if (!OrderPriceOpen)
              // https://www.mql5.com/ru/forum/1111/page2820#comment_17749873
              OrderPriceOpen = (double)::StringSubstr(MT4ORDERS::Order.Comment, MT4ORDERS::IsTester ? 3 : (::StringFind(MT4ORDERS::Order.Comment, "sl ") + 3));

            MT4ORDERS::Order.StopLoss = OrderPriceOpen;
            MT4ORDERS::Order.TakeProfit = ::HistoryOrderGetDouble(OrderTicket, ORDER_SL);
          }
          else if (Reason == DEAL_REASON_TP)
          {
            if (!OrderPriceOpen)
              // https://www.mql5.com/ru/forum/1111/page2820#comment_17749873
              OrderPriceOpen = (double)::StringSubstr(MT4ORDERS::Order.Comment, MT4ORDERS::IsTester ? 3 : (::StringFind(MT4ORDERS::Order.Comment, "tp ") + 3));

            MT4ORDERS::Order.TakeProfit = OrderPriceOpen;
            MT4ORDERS::Order.StopLoss = ::HistoryOrderGetDouble(OrderTicket, ORDER_TP);
          }
          else
          {
            // Inverted - not an error: see OrderClose.
            MT4ORDERS::Order.StopLoss = ::HistoryOrderGetDouble(OrderTicket, ORDER_TP);
            MT4ORDERS::Order.TakeProfit = ::HistoryOrderGetDouble(OrderTicket, ORDER_SL);
          }
      #endif // MT4ORDERS_SLTP_OLD

          MT4ORDERS::Order.State = (ENUM_ORDER_STATE)::HistoryOrderGetInteger(OrderTicket, ORDER_STATE);

          if (!(MT4ORDERS::Order.ClosePriceRequest = (DealEntry == DEAL_ENTRY_OUT_BY) ? MT4ORDERS::Order.ClosePrice : OrderPriceOpen))
            MT4ORDERS::Order.ClosePriceRequest = MT4ORDERS::Order.ClosePrice;

          if (!(MT4ORDERS::Order.OpenPriceRequest = _B2(MT4ORDERS::HistorySelectOrder(PosTicket) &&
                                                    // In case of partial execution, only the last deal of a fully executed order has this condition for taking the request price.
                                                    (MT4ORDERS::IsTester || (::HistoryDealGetInteger(OpenTicket, DEAL_TIME_MSC) == ::HistoryOrderGetInteger(PosTicket, ORDER_TIME_DONE_MSC)))) ?
                                                   ::HistoryOrderGetDouble(PosTicket, ORDER_PRICE_OPEN) : MT4ORDERS::Order.OpenPrice))
            MT4ORDERS::Order.OpenPriceRequest = MT4ORDERS::Order.OpenPrice;
        }
        else
        {
          MT4ORDERS::Order.State = ORDER_STATE_FILLED;

          MT4ORDERS::Order.ClosePriceRequest = MT4ORDERS::Order.ClosePrice;
          MT4ORDERS::Order.OpenPriceRequest = MT4ORDERS::Order.OpenPrice;
        }

        // The above comment is used to find SL / TP.
        if (StrComment != "")
          MT4ORDERS::Order.Comment = StrComment;
      }

      if (!Res)
      {
        ::Alert("HistoryOrderSelect(" + (string)OrderTicket + ") - BUG! MT4ORDERS - not Sync with History!");
        MT4ORDERS::AlertLog();

        ::Print(__FILE__ + "\nVersion = " + __MT4ORDERS__ + "\nCompiler = " + (string)__MQLBUILD__ + "\n" + TOSTR(__DATE__) +
                TOSTR(::AccountInfoString(ACCOUNT_SERVER)) + TOSTR2((ENUM_ACCOUNT_TRADE_MODE)::AccountInfoInteger(ACCOUNT_TRADE_MODE)) +
                TOSTR((bool)::TerminalInfoInteger(TERMINAL_CONNECTED)) +
                TOSTR(::TerminalInfoInteger(TERMINAL_PING_LAST)) + TOSTR(::TerminalInfoDouble(TERMINAL_RETRANSMISSION)) +
                TOSTR(::TerminalInfoInteger(TERMINAL_BUILD)) + TOSTR((bool)::TerminalInfoInteger(TERMINAL_X64)) +
                TOSTR((bool)::TerminalInfoInteger(TERMINAL_VPS)) + TOSTR2((ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)) +
                TOSTR(::TimeCurrent()) + TOSTR(::TimeTradeServer()) + TOSTR(MT4ORDERS::TimeToString(MT4ORDERS::GetTimeCurrent())) +
                TOSTR(::SymbolInfoString(MT4ORDERS::Order.Symbol, SYMBOL_PATH)) + TOSTR(::SymbolInfoString(MT4ORDERS::Order.Symbol, SYMBOL_DESCRIPTION)) +
                "CurrentTick =" + MT4ORDERS::TickToString(MT4ORDERS::Order.Symbol) + "\n" +
                TOSTR(::PositionsTotal()) + TOSTR(::OrdersTotal()) +
                TOSTR(::HistorySelect(0, INT_MAX)) + TOSTR(::HistoryDealsTotal()) + TOSTR(::HistoryOrdersTotal()) +
                TOSTR(::TerminalInfoInteger(TERMINAL_MEMORY_AVAILABLE)) + TOSTR(::TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL)) +
                TOSTR(::TerminalInfoInteger(TERMINAL_MEMORY_TOTAL)) + TOSTR(::TerminalInfoInteger(TERMINAL_MEMORY_USED)) +
                TOSTR(::MQLInfoInteger(MQL_MEMORY_LIMIT)) + TOSTR(::MQLInfoInteger(MQL_MEMORY_USED)) +
                TOSTR(Ticket) + TOSTR(OrderTicket) + TOSTR(OpenTicket) + TOSTR(PosTicket) +
                TOSTR(MT4ORDERS::TimeToString(MT4ORDERS::Order.CloseTimeMsc)) +
                TOSTR(MT4ORDERS::HistorySelectOrder(OrderTicket)) + TOSTR(::OrderSelect(OrderTicket)) +
                (::OrderSelect(OrderTicket) ? TOSTR2((ENUM_ORDER_STATE)::OrderGetInteger(ORDER_STATE)) : NULL) +
                (::HistoryDealsTotal() ? TOSTR(::HistoryDealGetTicket(::HistoryDealsTotal() - 1)) +
                   "DEAL_TIME_MSC = " + MT4ORDERS::TimeToString(::HistoryDealGetInteger(::HistoryDealGetTicket(::HistoryDealsTotal() - 1), DEAL_TIME_MSC)) + "\n"
                                       : NULL) +
                (::HistoryOrdersTotal() ? TOSTR(::HistoryOrderGetTicket(::HistoryOrdersTotal() - 1)) +
                   "ORDER_TIME_DONE_MSC = " + MT4ORDERS::TimeToString(::HistoryOrderGetInteger(::HistoryOrderGetTicket(::HistoryOrdersTotal() - 1), ORDER_TIME_DONE_MSC)) + "\n"
                                        : NULL));
      }
    }
    else
    {
      MT4ORDERS::Order.TicketOpen = MT4ORDERS::Order.Ticket;

      if (!MT4ORDERS::Order.TicketID && (MT4ORDERS::Order.Type <= OP_SELL)) // The balance sheet ID must remain zero
        MT4ORDERS::Order.TicketID = MT4ORDERS::Order.Ticket;

      MT4ORDERS::Order.OpenPrice = MT4ORDERS::Order.ClosePrice;

      MT4ORDERS::Order.OpenTimeMsc = MT4ORDERS::Order.CloseTimeMsc;
      MT4ORDERS::Order.OpenTime = MT4ORDERS::Order.CloseTime;

      MT4ORDERS::Order.OpenReason = MT4ORDERS::Order.CloseReason;

      MT4ORDERS::Order.State = ORDER_STATE_FILLED;

      MT4ORDERS::Order.ClosePriceRequest = MT4ORDERS::Order.ClosePrice;
      MT4ORDERS::Order.OpenPriceRequest = MT4ORDERS::Order.OpenPrice;
    }

    if (OrderTicket)
    {
      bool Res = MT4ORDERS::IsTester ? MT4ORDERS::HistorySelectOrder(OrderTicket) : MT4ORDERS::Waiting(true);

      if (!Res)
        WHILE(_B2(MT4ORDERS::HistorySelectOrder(OrderTicket))) // https://www.mql5.com/ru/forum/304239#comment_10710403
          ;

      if ((ENUM_ORDER_TYPE)::HistoryOrderGetInteger(OrderTicket, ORDER_TYPE) == ORDER_TYPE_CLOSE_BY)
      {
        const ulong PosTicketBy = ::HistoryOrderGetInteger(OrderTicket, ORDER_POSITION_BY_ID);

        if (PosTicketBy == PosTicket) // CloseBy-Slave should not affect trade.
        {
          MT4ORDERS::Order.Lots = 0;
          MT4ORDERS::Order.Commission = 0;

          MT4ORDERS::Order.ClosePrice = MT4ORDERS::Order.OpenPrice;
          MT4ORDERS::Order.ClosePriceRequest = MT4ORDERS::Order.ClosePrice;
        }
        else // CloseBy-Master must receive a commission from CloseBy-Slave
        {
          const ulong OpenTicketBy = (OrderTicket > 0) ? _B2(MT4ORDERS::History.GetPositionDealIn(PosTicketBy)) : 0;

          if ((OpenTicketBy > 0) && _B2(MT4ORDERS::HistorySelectDeal(OpenTicketBy)))
          {
            const double OpenLots = ::HistoryDealGetDouble(OpenTicketBy, DEAL_VOLUME);

            if (OpenLots > 0)
              MT4ORDERS::Order.Commission += ::HistoryDealGetDouble(OpenTicketBy, DEAL_COMMISSION) * MT4ORDERS::Order.Lots / OpenLots;
          }
        }
      }
    }

    return;
  }

  static bool Waiting( const bool FlagInit = false )
  {
    static ulong StartTime = 0;

    const bool Res = FlagInit ? false : (::GetMicrosecondCount() - StartTime < MT4ORDERS::OrderSend_MaxPause);

    if (FlagInit)
    {
      StartTime = ::GetMicrosecondCount();

      MT4ORDERS::OrderSendBug = 0;
    }
    else if (Res)
    {
      MT4ORDERS::OrderSendBug++;
    }

    return(Res);
  }

  static bool EqualPrices( const double Price1, const double &Price2, const int &digits)
  {
    return(!::NormalizeDouble(Price1 - Price2, digits));
  }

  static bool HistoryDealSelect2( MqlTradeResult &Result ) // At the end of the name is a number for greater compatibility with macros
  {
  #ifdef MT4ORDERS_HISTORY_OLD
    // Replace HistorySelectByPosition with HistorySelect (PosTime, PosTime)
    if (!Result.deal && Result.order && _B3(::HistorySelectByPosition(::HistoryOrderGetInteger(Result.order, ORDER_POSITION_ID))))
    {
  #else // #ifdef MT4ORDERS_HISTORY_OLD
    if (!Result.deal && Result.order && _B2(MT4ORDERS::HistorySelectOrder(Result.order)))
    {
      const long OrderTimeFill = ::HistoryOrderGetInteger(Result.order, ORDER_TIME_DONE_MSC);
  #endif // #ifdef MT4ORDERS_HISTORY_OLD #else
      for (int i = ::HistoryDealsTotal() - 1; i >= 0; i--)
      {
        const ulong DealTicket = ::HistoryDealGetTicket(i);

        if (Result.order == ::HistoryDealGetInteger(DealTicket, DEAL_ORDER))
        {
          Result.deal = DealTicket;
          Result.price = ::HistoryDealGetDouble(DealTicket, DEAL_PRICE);

          break;
        }
      #ifndef MT4ORDERS_HISTORY_OLD
        else if (::HistoryDealGetInteger(DealTicket, DEAL_TIME_MSC) < OrderTimeFill)
          break;
      #endif // #ifndef MT4ORDERS_HISTORY_OLD
      }
    }

    return(_B2(MT4ORDERS::HistorySelectDeal(Result.deal)));
  }

#define TMP_MT4ORDERS_BENCHMARK(A) \
  static ulong Max##A = 0;         \
                                   \
  if (Interval##A > Max##A)        \
  {                                \
    MT4ORDERS_BENCHMARK            \
                                   \
    Max##A = Interval##A;          \
  }

  static void OrderSend_Benchmark( const ulong &Interval1, const ulong &Interval2 )
  {
    #ifdef MT4ORDERS_BENCHMARK
      TMP_MT4ORDERS_BENCHMARK(1)
      TMP_MT4ORDERS_BENCHMARK(2)
    #endif // MT4ORDERS_BENCHMARK

    return;
  }

#undef TMP_MT4ORDERS_BENCHMARK

  static string ToString( const MqlTradeRequest &Request )
  {
    return(TOSTR2(Request.action) + TOSTR(Request.magic) + TOSTR(Request.order) +
           TOSTR(Request.symbol) + TOSTR(Request.volume) + TOSTR(Request.price) +
           TOSTR(Request.stoplimit) + TOSTR(Request.sl) +  TOSTR(Request.tp) +
           TOSTR(Request.deviation) + TOSTR2(Request.type) + TOSTR2(Request.type_filling) +
           TOSTR2(Request.type_time) + TOSTR(Request.expiration) + TOSTR(Request.comment) +
           TOSTR(Request.position) + TOSTR(Request.position_by));
  }

  static string ToString( const MqlTradeResult &Result )
  {
    return(TOSTR(Result.retcode) + TOSTR(Result.deal) + TOSTR(Result.order) +
           TOSTR(Result.volume) + TOSTR(Result.price) + TOSTR(Result.bid) +
           TOSTR(Result.ask) + TOSTR(Result.comment) + TOSTR(Result.request_id) +
           TOSTR(Result.retcode_external));
  }

  static bool OrderSend( const MqlTradeRequest &Request, MqlTradeResult &Result )
  {
    MqlTick PrevTick = {0};

    if (!MT4ORDERS::IsTester)
      ::SymbolInfoTick(Request.symbol, PrevTick); // Может тормозить.

    const long PrevTimeCurrent = MT4ORDERS::IsTester ? 0 : MT4ORDERS::GetTimeCurrent();
    const ulong StartTime1 = MT4ORDERS::IsTester ? 0 : ::GetMicrosecondCount();

    bool Res = ::OrderSend(Request, Result);

    const ulong Interval1 = MT4ORDERS::IsTester ? 0 : (::GetMicrosecondCount() - StartTime1);

    const ulong StartTime2 = MT4ORDERS::IsTester ? 0 : ::GetMicrosecondCount();

    if (!MT4ORDERS::IsTester && Res && (Result.retcode < TRADE_RETCODE_ERROR) && (MT4ORDERS::OrderSend_MaxPause > 0))
    {
      Res = (Result.retcode == TRADE_RETCODE_DONE);
      MT4ORDERS::Waiting(true);

      // TRADE_ACTION_CLOSE_BY is not on the checklist
      if (Request.action == TRADE_ACTION_DEAL)
      {
        if (!Result.deal)
        {
          WHILE(_B2(::OrderSelect(Result.order)) || _B2(MT4ORDERS::HistorySelectOrder(Result.order)))
            ;

          if (!Res)
            ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR(::OrderSelect(Result.order)) + TOSTR(MT4ORDERS::HistorySelectOrder(Result.order)));
          else if (::OrderSelect(Result.order) && !(Res = ((ENUM_ORDER_STATE)::OrderGetInteger(ORDER_STATE) == ORDER_STATE_PLACED) ||
                                                          ((ENUM_ORDER_STATE)::OrderGetInteger(ORDER_STATE) == ORDER_STATE_PARTIAL)))
            ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR(::OrderSelect(Result.order)) + TOSTR2((ENUM_ORDER_STATE)::OrderGetInteger(ORDER_STATE)));
        }

        // If after the partial execution the remaining part is left hanging - false
        if (Res)
        {
          const bool ResultDeal = (!Result.deal) && (!MT4ORDERS::OrderSendBug);

          if (MT4ORDERS::OrderSendBug && (!Result.deal))
            ::Print("Line = " + (string)__LINE__ + "\n" + "Before ::HistoryOrderSelect(Result.order):\n" + TOSTR(MT4ORDERS::OrderSendBug) + TOSTR(Result.deal));

          WHILE(_B2(MT4ORDERS::HistorySelectOrder(Result.order)))
            ;

          // If previously there was no OrderSend-bug and __result.deal == 0
          if (ResultDeal)
            MT4ORDERS::OrderSendBug = 0;

          if (!Res)
            ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR(MT4ORDERS::HistorySelectOrder(Result.order)) + TOSTR(MT4ORDERS::HistorySelectDeal(Result.deal)) + TOSTR(::OrderSelect(Result.order)));
          // If the historical order is not executed (rejected) - false
          else if (!(Res = ((ENUM_ORDER_STATE)::HistoryOrderGetInteger(Result.order, ORDER_STATE) == ORDER_STATE_FILLED) ||
                           ((ENUM_ORDER_STATE)::HistoryOrderGetInteger(Result.order, ORDER_STATE) == ORDER_STATE_PARTIAL)))
            ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR2((ENUM_ORDER_STATE)::HistoryOrderGetInteger(Result.order, ORDER_STATE)));
        }

        if (Res)
        {
          const bool ResultDeal = (!Result.deal) && (!MT4ORDERS::OrderSendBug);

          if (MT4ORDERS::OrderSendBug && (!Result.deal))
            ::Print("Line = " + (string)__LINE__ + "\n" + "Before MT4ORDERS::HistoryDealSelect(Result):\n" + TOSTR(MT4ORDERS::OrderSendBug) + TOSTR(Result.deal));

          WHILE(MT4ORDERS::HistoryDealSelect2(Result))
            ;

          // If previously there was no OrderSend-bug and __result.deal == 0
          if (ResultDeal)
            MT4ORDERS::OrderSendBug = 0;

          if (!Res)
            ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR(MT4ORDERS::HistoryDealSelect2(Result)));
        }
      }
      else if (Request.action == TRADE_ACTION_PENDING)
      {
        if (Res)
        {
          WHILE(_B2(::OrderSelect(Result.order)))
            ;

          if (!Res)
            ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR(::OrderSelect(Result.order)));
          else if (!(Res = ((ENUM_ORDER_STATE)::OrderGetInteger(ORDER_STATE) == ORDER_STATE_PLACED) ||
                           ((ENUM_ORDER_STATE)::OrderGetInteger(ORDER_STATE) == ORDER_STATE_PARTIAL)))
            ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR2((ENUM_ORDER_STATE)::OrderGetInteger(ORDER_STATE)));
        }
        else
        {
          WHILE(_B2(MT4ORDERS::HistorySelectOrder(Result.order)))
            ;

          ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR(MT4ORDERS::HistorySelectOrder(Result.order)));

          Res = false;
        }
      }
      else if (Request.action == TRADE_ACTION_SLTP)
      {
        if (Res)
        {
          const int digits = (int)::SymbolInfoInteger(Request.symbol, SYMBOL_DIGITS);

          bool EqualSL = false;
          bool EqualTP = false;

          do
            if (Request.position ? _B2(::PositionSelectByTicket(Request.position)) : _B2(::PositionSelect(Request.symbol)))
            {
              EqualSL = MT4ORDERS::EqualPrices(::PositionGetDouble(POSITION_SL), Request.sl, digits);
              EqualTP = MT4ORDERS::EqualPrices(::PositionGetDouble(POSITION_TP), Request.tp, digits);
            }
          WHILE(EqualSL && EqualTP);

          if (!Res)
            ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR(::PositionGetDouble(POSITION_SL)) + TOSTR(::PositionGetDouble(POSITION_TP)) +
                    TOSTR(EqualSL) + TOSTR(EqualTP) +
                    TOSTR(Request.position ? ::PositionSelectByTicket(Request.position) : ::PositionSelect(Request.symbol)));
        }
      }
      else if (Request.action == TRADE_ACTION_MODIFY)
      {
        if (Res)
        {
          const int digits = (int)::SymbolInfoInteger(Request.symbol, SYMBOL_DIGITS);

          bool EqualSL = false;
          bool EqualTP = false;
          bool EqualPrice = false;

          do
            // https://www.mql5.com/ru/forum/170952/page184#comment_17913645
            if (_B2(::OrderSelect(Result.order)) && ((ENUM_ORDER_STATE)::OrderGetInteger(ORDER_STATE) != ORDER_STATE_REQUEST_MODIFY))
            {
              EqualSL = MT4ORDERS::EqualPrices(::OrderGetDouble(ORDER_SL), Request.sl, digits);
              EqualTP = MT4ORDERS::EqualPrices(::OrderGetDouble(ORDER_TP), Request.tp, digits);
              EqualPrice = MT4ORDERS::EqualPrices(::OrderGetDouble(ORDER_PRICE_OPEN), Request.price, digits);
            }
          WHILE((EqualSL && EqualTP && EqualPrice));

          if (!Res)
            ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR(::OrderGetDouble(ORDER_SL)) + TOSTR(Request.sl)+
                    TOSTR(::OrderGetDouble(ORDER_TP)) + TOSTR(Request.tp) +
                    TOSTR(::OrderGetDouble(ORDER_PRICE_OPEN)) + TOSTR(Request.price) +
                    TOSTR(EqualSL) + TOSTR(EqualTP) + TOSTR(EqualPrice) +
                    TOSTR(::OrderSelect(Result.order)) +
                    TOSTR2((ENUM_ORDER_STATE)::OrderGetInteger(ORDER_STATE)));
        }
      }
      else if (Request.action == TRADE_ACTION_REMOVE)
      {
        if (Res)
          WHILE(_B2(MT4ORDERS::HistorySelectOrder(Result.order)))
            ;

        if (!Res)
          ::Print("Line = " + (string)__LINE__ + "\n" + TOSTR(MT4ORDERS::HistorySelectOrder(Result.order)));
      }

      const ulong Interval2 = ::GetMicrosecondCount() - StartTime2;

      Result.comment += " " + ::DoubleToString(Interval1 / 1000.0, 3) + " + " +
                              ::DoubleToString(Interval2 / 1000.0, 3) + " (" + (string)MT4ORDERS::OrderSendBug + ") ms.";

      if (!Res || MT4ORDERS::OrderSendBug)
      {
        ::Alert(Res ? "OrderSend(" + (string)Result.order + ") - BUG!" : "MT4ORDERS - not Sync with History!");
        MT4ORDERS::AlertLog();

        ::Print(__FILE__ + "\nVersion = " + __MT4ORDERS__ + "\nCompiler = " + (string)__MQLBUILD__ + "\n" + TOSTR(__DATE__) +
                TOSTR(::AccountInfoString(ACCOUNT_SERVER)) + TOSTR2((ENUM_ACCOUNT_TRADE_MODE)::AccountInfoInteger(ACCOUNT_TRADE_MODE)) +
                TOSTR((bool)::TerminalInfoInteger(TERMINAL_CONNECTED)) +
                TOSTR(::TerminalInfoInteger(TERMINAL_PING_LAST)) + TOSTR(::TerminalInfoDouble(TERMINAL_RETRANSMISSION)) +
                TOSTR(::TerminalInfoInteger(TERMINAL_BUILD)) + TOSTR((bool)::TerminalInfoInteger(TERMINAL_X64)) +
                TOSTR((bool)::TerminalInfoInteger(TERMINAL_VPS)) + TOSTR2((ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)) +
                TOSTR(::TimeCurrent()) + TOSTR(::TimeTradeServer()) +
                TOSTR(MT4ORDERS::TimeToString(MT4ORDERS::GetTimeCurrent())) + TOSTR(MT4ORDERS::TimeToString(PrevTimeCurrent)) +
                "PrevTick =" + MT4ORDERS::TickToString(Request.symbol, PrevTick) + "\n" +
                "CurrentTick =" + MT4ORDERS::TickToString(Request.symbol) + "\n" +
                TOSTR(::SymbolInfoString(Request.symbol, SYMBOL_PATH)) + TOSTR(::SymbolInfoString(Request.symbol, SYMBOL_DESCRIPTION)) +
                TOSTR(::PositionsTotal()) + TOSTR(::OrdersTotal()) +
                TOSTR(::HistorySelect(0, INT_MAX)) + TOSTR(::HistoryDealsTotal()) + TOSTR(::HistoryOrdersTotal()) +
                (::HistoryDealsTotal() ? TOSTR(::HistoryDealGetTicket(::HistoryDealsTotal() - 1)) +
                   "DEAL_TIME_MSC = " + MT4ORDERS::TimeToString(::HistoryDealGetInteger(::HistoryDealGetTicket(::HistoryDealsTotal() - 1), DEAL_TIME_MSC)) + "\n"
                                       : NULL) +
                (::HistoryOrdersTotal() ? TOSTR(::HistoryOrderGetTicket(::HistoryOrdersTotal() - 1)) +
                   "ORDER_TIME_DONE_MSC = " + MT4ORDERS::TimeToString(::HistoryOrderGetInteger(::HistoryOrderGetTicket(::HistoryOrdersTotal() - 1), ORDER_TIME_DONE_MSC)) + "\n"
                                        : NULL) +
                TOSTR(::TerminalInfoInteger(TERMINAL_MEMORY_AVAILABLE)) + TOSTR(::TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL)) +
                TOSTR(::TerminalInfoInteger(TERMINAL_MEMORY_TOTAL)) + TOSTR(::TerminalInfoInteger(TERMINAL_MEMORY_USED)) +
                TOSTR(::MQLInfoInteger(MQL_MEMORY_LIMIT)) + TOSTR(::MQLInfoInteger(MQL_MEMORY_USED)) +
                TOSTR(MT4ORDERS::IsHedging) + TOSTR(Res) + TOSTR(MT4ORDERS::OrderSendBug) +
                MT4ORDERS::ToString(Request) + MT4ORDERS::ToString(Result));
      }
      else
        MT4ORDERS::OrderSend_Benchmark(Interval1, Interval2);
    }
    else if (!MT4ORDERS::IsTester && MT4ORDERS::OrderSend_MaxPause)
    {
      Result.comment += " " + ::DoubleToString(Interval1 / 1000.0, 3) + " ms";

      ::Print(TOSTR(::TimeCurrent()) + TOSTR(::TimeTradeServer()) + TOSTR(MT4ORDERS::TimeToString(PrevTimeCurrent)) +
              MT4ORDERS::TickToString(Request.symbol, PrevTick) + "\n" + MT4ORDERS::TickToString(Request.symbol) + "\n" +
              MT4ORDERS::ToString(Request) + MT4ORDERS::ToString(Result));
    }

    return(Res);
  }

#undef TOSTR2
#undef TOSTR
#undef WHILE

  static ENUM_DAY_OF_WEEK GetDayOfWeek( const datetime &time )
  {
    MqlDateTime sTime = {0};

    ::TimeToStruct(time, sTime);

    return((ENUM_DAY_OF_WEEK)sTime.day_of_week);
  }

  static bool SessionTrade( const string &Symb )
  {
    datetime TimeNow = ::TimeCurrent();

    const ENUM_DAY_OF_WEEK DayOfWeek = MT4ORDERS::GetDayOfWeek(TimeNow);

    TimeNow %= 24 * 60 * 60;

    bool Res = false;
    datetime From, To;

    for (int i = 0; (!Res) && ::SymbolInfoSessionTrade(Symb, DayOfWeek, i, From, To); i++)
      Res = ((From <= TimeNow) && (TimeNow < To));

    return(Res);
  }

  static bool SymbolTrade( const string &Symb )
  {
    MqlTick Tick;

    return(::SymbolInfoTick(Symb, Tick) ? (Tick.bid && Tick.ask && MT4ORDERS::SessionTrade(Symb)) : false);
  }

  static bool CorrectResult( void )
  {
    ::ZeroMemory(MT4ORDERS::LastTradeResult);

    MT4ORDERS::LastTradeResult.retcode = MT4ORDERS::LastTradeCheckResult.retcode;
    MT4ORDERS::LastTradeResult.comment = MT4ORDERS::LastTradeCheckResult.comment;

    return(false);
  }

  static bool NewOrderCheck( void )
  {
    return((::OrderCheck(MT4ORDERS::LastTradeRequest, MT4ORDERS::LastTradeCheckResult) &&
           (MT4ORDERS::IsTester || MT4ORDERS::SymbolTrade(MT4ORDERS::LastTradeRequest.symbol))) ||
           (!MT4ORDERS::IsTester && MT4ORDERS::CorrectResult()));
  }

  static bool NewOrderSend( const int &Check )
  {
    return((Check == INT_MAX) ? MT4ORDERS::NewOrderCheck() :
           (((Check != INT_MIN) || MT4ORDERS::NewOrderCheck()) && MT4ORDERS::OrderSend(MT4ORDERS::LastTradeRequest, MT4ORDERS::LastTradeResult) ? MT4ORDERS::LastTradeResult.retcode < TRADE_RETCODE_ERROR : false));
  }

  static bool ModifyPosition( const long &Ticket, MqlTradeRequest &Request )
  {
    const bool Res = _B2(::PositionSelectByTicket(Ticket));

    if (Res)
    {
      Request.action = TRADE_ACTION_SLTP;

      Request.position = Ticket;
      Request.symbol = ::PositionGetString(POSITION_SYMBOL); // One ticket is not enough!
    }

    return(Res);
  }

  static ENUM_ORDER_TYPE_FILLING GetFilling( const string &Symb, const uint Type = ORDER_FILLING_FOK )
  {
    static ENUM_ORDER_TYPE_FILLING Res = ORDER_FILLING_FOK;
    static string LastSymb = NULL;
    static uint LastType = ORDER_FILLING_FOK;

    const bool SymbFlag = (LastSymb != Symb);

    if (SymbFlag || (LastType != Type)) // You can speed up a little by changing the order of checking the conditions
    {
      LastType = Type;

      if (SymbFlag)
        LastSymb = Symb;

      const ENUM_SYMBOL_TRADE_EXECUTION ExeMode = (ENUM_SYMBOL_TRADE_EXECUTION)::SymbolInfoInteger(Symb, SYMBOL_TRADE_EXEMODE);
      const int FillingMode = (int)::SymbolInfoInteger(Symb, SYMBOL_FILLING_MODE);

      Res = (!FillingMode || (Type >= ORDER_FILLING_RETURN) || ((FillingMode & (Type + 1)) != Type + 1)) ?
            (((ExeMode == SYMBOL_TRADE_EXECUTION_EXCHANGE) || (ExeMode == SYMBOL_TRADE_EXECUTION_INSTANT)) ?
             ORDER_FILLING_RETURN : ((FillingMode == SYMBOL_FILLING_IOC) ? ORDER_FILLING_IOC : ORDER_FILLING_FOK)) :
            (ENUM_ORDER_TYPE_FILLING)Type;
    }

    return(Res);
  }

  static ENUM_ORDER_TYPE_TIME GetExpirationType( const string &Symb, uint Expiration = ORDER_TIME_GTC )
  {
    static ENUM_ORDER_TYPE_TIME Res = ORDER_TIME_GTC;
    static string LastSymb = NULL;
    static uint LastExpiration = ORDER_TIME_GTC;

    const bool SymbFlag = (LastSymb != Symb);

    if ((LastExpiration != Expiration) || SymbFlag)
    {
      LastExpiration = Expiration;

      if (SymbFlag)
        LastSymb = Symb;

      const int ExpirationMode = (int)::SymbolInfoInteger(Symb, SYMBOL_EXPIRATION_MODE);

      if ((Expiration > ORDER_TIME_SPECIFIED_DAY) || (!((ExpirationMode >> Expiration) & 1)))
      {
        if ((Expiration < ORDER_TIME_SPECIFIED) || (ExpirationMode < SYMBOL_EXPIRATION_SPECIFIED))
          Expiration = ORDER_TIME_GTC;
        else if (Expiration > ORDER_TIME_DAY)
          Expiration = ORDER_TIME_SPECIFIED;

        uint i = 1 << Expiration;

        while ((Expiration <= ORDER_TIME_SPECIFIED_DAY) && ((ExpirationMode & i) != i))
        {
          i <<= 1;
          Expiration++;
        }
      }

      Res = (ENUM_ORDER_TYPE_TIME)Expiration;
    }

    return(Res);
  }

  static bool ModifyOrder( const long Ticket, const double &Price, const datetime &Expiration, MqlTradeRequest &Request )
  {
    const bool Res = _B2(::OrderSelect(Ticket));

    if (Res)
    {
      Request.action = TRADE_ACTION_MODIFY;
      Request.order = Ticket;

      Request.price = Price;

      Request.symbol = ::OrderGetString(ORDER_SYMBOL);

      // https://www.mql5.com/ru/forum/1111/page1817#comment_4087275
      Request.type_filling = _B2(MT4ORDERS::GetFilling(Request.symbol));
      Request.type_time = _B2(MT4ORDERS::GetExpirationType(Request.symbol, (uint)Expiration));

      if (Expiration > ORDER_TIME_DAY)
        Request.expiration = Expiration;
    }

    return(Res);
  }

  static bool SelectByPosHistory( const int Index )
  {
    const long Ticket = MT4ORDERS::History[Index];
    const bool Res = (Ticket > 0) ? _B2(MT4ORDERS::HistorySelectDeal(Ticket)) : ((Ticket < 0) && _B2(MT4ORDERS::HistorySelectOrder(-Ticket)));

    if (Res)
    {
      if (Ticket > 0)
        _BV2(MT4ORDERS::GetHistoryPositionData(Ticket))
      else
        _BV2(MT4ORDERS::GetHistoryOrderData(-Ticket))
    }

    return(Res);
  }

  // https://www.mql5.com/ru/forum/227960#comment_6603506
  static bool OrderVisible( void )
  {
    bool Market = false;
    bool Res = !(::OrderGetInteger(ORDER_POSITION_ID) &&
                 (Market = (::OrderGetInteger(ORDER_TYPE) <= ORDER_TYPE_SELL))); // Partial-delayer has non-zero PositionID

    // If a live Market Order was partially filled, then it will not be visible with this condition, although it should.
    // https://www.mql5.com/ru/forum/38456/page148#comment_17910929
    if (Res && Market)
    {
      const long Ticket = ::PositionGetInteger(POSITION_TICKET);

      if (_B2(::PositionSelectByTicket(::OrderGetInteger(ORDER_TICKET)))) // The order and its position can be simultaneous - this condition will help only on Hedge accounts
      {
        if (Ticket && (::PositionGetInteger(POSITION_TICKET) != Ticket))
          _B2(::PositionSelectByTicket(Ticket));

        Res = false;
      }
    }
    return(Res);
  }

  static ulong OrderGetTicket( const int Index )
  {
    ulong Res;
    int PrevTotal;
    const long PrevTicket = ::OrderGetInteger(ORDER_TICKET);

    do
    {
      Res = 0;
      PrevTotal = ::OrdersTotal();

      if ((Index >= 0) && (Index < PrevTotal))
      {
        int Count = 0;

        for (int i = 0; i < PrevTotal; i++)
        {
          const int Total = ::OrdersTotal();

          // The number of orders may change during the search
          if (Total != PrevTotal)
          {
            PrevTotal = Total;

            Count = 0;
            i = -1;
          }
          else
          {
            const ulong Ticket = ::OrderGetTicket(i);

            if (Ticket && MT4ORDERS::OrderVisible())
            {
              if (Count == Index)
              {
                Res = Ticket;

                break;
              }

              Count++;
            }
          }
        }

        // In case of failure, reselect the previously selected order
        if (!Res && PrevTicket && (::OrderGetInteger(ORDER_TICKET) != PrevTicket))
          const bool AntiWarning = _B2(::OrderSelect(PrevTicket));
      }
    } while (PrevTotal != ::OrdersTotal()); // The number of orders may change during the search

    return(Res);
  }

  // With the same ticket, the priority of position selection is higher than the order
  static bool SelectByPos( const int Index )
  {
    bool Flag = (Index == INT_MAX);
    bool Res = Flag || (Index == INT_MIN);

    if (!Res)
    {
      const int Total = ::PositionsTotal();

      Flag = (Index < Total);
      Res = (Flag) ? _B2(::PositionGetTicket(Index)) :
                                                     #ifdef MT4ORDERS_SELECTFILTER_OFF
                                                       ::OrderGetTicket(Index - Total);
                                                     #else // MT4ORDERS_SELECTFILTER_OFF
                                                       (MT4ORDERS::IsTester ? ::OrderGetTicket(Index - Total) : _B2(MT4ORDERS::OrderGetTicket(Index - Total)));
                                                     #endif //MT4ORDERS_SELECTFILTER_OFF
    }

    if (Res)
    {
      if (Flag)
        MT4ORDERS::GetPositionData(); // (Index == INT_MAX) - switch to MT5 position without checking for existence and updating
      else
        MT4ORDERS::GetOrderData();    // (Index == INT_MIN) - switch to a live MT5 order without checking for existence and updating
    }

    return(Res);
  }

  static bool SelectByHistoryTicket( const long &Ticket )
  {
    bool Res = false;

    if (!Ticket) // Selection by OrderTicketID (zero value - balance operations)
    {
      const ulong TicketDealOut = MT4ORDERS::History.GetPositionDealOut(Ticket);

      if (Res = _B2(MT4ORDERS::HistorySelectDeal(TicketDealOut)))
        _BV2(MT4ORDERS::GetHistoryPositionData(TicketDealOut));
    }
    else if (_B2(MT4ORDERS::HistorySelectDeal(Ticket)))
    {
      if (Res = MT4HISTORY::IsMT4Deal(Ticket))
        _BV2(MT4ORDERS::GetHistoryPositionData(Ticket))
      else
      {
        const ulong TicketDealOut = MT4ORDERS::History.GetPositionDealOut(HistoryDealGetInteger(Ticket, DEAL_POSITION_ID)); // DealIn selection

        if (Res = _B2(MT4ORDERS::HistorySelectDeal(TicketDealOut)))
          _BV2(MT4ORDERS::GetHistoryPositionData(TicketDealOut))
      }
    }
    else if (_B2(MT4ORDERS::HistorySelectOrder(Ticket)))
    {
      if (Res = MT4HISTORY::IsMT4Order(Ticket))
        _BV2(MT4ORDERS::GetHistoryOrderData(Ticket))
      else
      {
        // Selection by OrderTicketID or a ticket for a completed deposit - relevant for Netting
        const ulong TicketDealOut = MT4ORDERS::History.GetPositionDealOut(HistoryOrderGetInteger(Ticket, ORDER_POSITION_ID));

        if (Res = _B2(MT4ORDERS::HistorySelectDeal(TicketDealOut)))
          _BV2(MT4ORDERS::GetHistoryPositionData(TicketDealOut));
      }
    }
    else
    {
      // Selection by OrderTicketID or ticket of the executed pending order is relevant for Netting.
      const ulong TicketDealOut = MT4ORDERS::History.GetPositionDealOut(Ticket);

      if (Res = _B2(MT4ORDERS::HistorySelectDeal(TicketDealOut)))
        _BV2(MT4ORDERS::GetHistoryPositionData(TicketDealOut));
    }

    return(Res);
  }

  static bool SelectByExistingTicket( const long &Ticket )
  {
    bool Res = true;

    if (Ticket < 0)
    {
      if (_B2(::OrderSelect(-Ticket)))
        MT4ORDERS::GetOrderData();
      else if (_B2(::PositionSelectByTicket(-Ticket)))
        MT4ORDERS::GetPositionData();
      else
        Res = false;
    }
    else if (_B2(::PositionSelectByTicket(Ticket)))
      MT4ORDERS::GetPositionData();
    else if (_B2(::OrderSelect(Ticket)))
      MT4ORDERS::GetOrderData();
    else if (_B2(MT4ORDERS::HistorySelectDeal(Ticket)))
    {
      if (MT4HISTORY::IsMT4Deal(Ticket)) // If a choice is made by DealOut
        _BV2(MT4ORDERS::GetHistoryPositionData(Ticket))
      else if (_B2(::PositionSelectByTicket(::HistoryDealGetInteger(Ticket, DEAL_POSITION_ID)))) // DealIn selection
        MT4ORDERS::GetPositionData();
      else
        Res = false;
    }
    else if (_B2(MT4ORDERS::HistorySelectOrder(Ticket)) && _B2(::PositionSelectByTicket(::HistoryOrderGetInteger(Ticket, ORDER_POSITION_ID)))) // Выбор по тикету MT5-ордера
      MT4ORDERS::GetPositionData();
    else
      Res = false;

    return(Res);
  }

  // With the same ticket selection priorities:
  // MODE_TRADES: existing position > existing order > transaction > canceled order
  // MODE_HISTORY: transaction > canceled order > existing position > existing order
  static bool SelectByTicket( const long &Ticket, const int &Pool )
  {
    return((Pool == MODE_TRADES) || (Ticket < 0) ?
           (_B2(MT4ORDERS::SelectByExistingTicket(Ticket)) || ((Ticket > 0) && _B2(MT4ORDERS::SelectByHistoryTicket(Ticket)))) :
           (_B2(MT4ORDERS::SelectByHistoryTicket(Ticket)) || _B2(MT4ORDERS::SelectByExistingTicket(Ticket))));
  }

#ifdef MT4ORDERS_SLTP_OLD
  static void CheckPrices( double &MinPrice, double &MaxPrice, const double Min, const double Max )
  {
    if (MinPrice && (MinPrice >= Min))
      MinPrice = 0;

    if (MaxPrice && (MaxPrice <= Max))
      MaxPrice = 0;

    return;
  }
#endif // MT4ORDERS_SLTP_OLD

  static int OrdersTotal( void )
  {
    int Res = 0;
    const long PrevTicket = ::OrderGetInteger(ORDER_TICKET);
    int PrevTotal;

    do
    {
      PrevTotal = ::OrdersTotal();

      for (int i = PrevTotal - 1; i >= 0; i--)
      {
        const int Total = ::OrdersTotal();

        // The number of orders may change during the search
        if (Total != PrevTotal)
        {
          PrevTotal = Total;

          Res = 0;
          i = PrevTotal;
        }
        else if (::OrderGetTicket(i) && MT4ORDERS::OrderVisible())
          Res++;
      }
    } while (PrevTotal != ::OrdersTotal()); // The number of orders may change during the search

    if (PrevTicket && (::OrderGetInteger(ORDER_TICKET) != PrevTicket))
      const bool AntiWarning = _B2(::OrderSelect(PrevTicket));

    return(Res);
  }

public:
  static uint OrderSend_MaxPause; // Maximum time for synchronization in microseconds

  static MqlTradeResult LastTradeResult;
  static MqlTradeRequest LastTradeRequest;
  static MqlTradeCheckResult LastTradeCheckResult;

  static bool MT4OrderSelect( const long &Index, const int &Select, const int &Pool )
  {
    return((Select == SELECT_BY_POS) ?
           ((Pool == MODE_TRADES) ? _B2(MT4ORDERS::SelectByPos((int)Index)) : _B2(MT4ORDERS::SelectByPosHistory((int)Index))) :
           _B2(MT4ORDERS::SelectByTicket(Index, Pool)));
  }

  static int MT4OrdersTotal( void )
  {
  #ifdef MT4ORDERS_SELECTFILTER_OFF
    return(::OrdersTotal() + ::PositionsTotal());
  #else // MT4ORDERS_SELECTFILTER_OFF
    int Res;

    if (MT4ORDERS::IsTester)
      return(::OrdersTotal() + ::PositionsTotal());
    else
    {
      int PrevTotal;

      do
      {
        PrevTotal = ::PositionsTotal();

        Res = _B2(MT4ORDERS::OrdersTotal()) + PrevTotal;

      } while (PrevTotal != ::PositionsTotal()); // We only track changes in positions, because orders are tracked in MT4ORDERS :: OrdersTotal ()
    }

    return(Res); // https://www.mql5.com/ru/forum/290673#comment_9493241
  #endif //MT4ORDERS_SELECTFILTER_OFF
  }

  // This "overload" can be used together with the MT5 version of OrdersTotal
  static int MT4OrdersTotal( const bool )
  {
    return(::OrdersTotal());
  }

  static int MT4OrdersHistoryTotal( void )
  {
    return(MT4ORDERS::History.GetAmount());
  }

  static long MT4OrderSend( const string &Symb, const int &Type, const double &dVolume, const double &Price, const int &SlipPage, const double &SL, const double &TP,
                            const string &comment, const MAGIC_TYPE &magic, const datetime &dExpiration, const color &arrow_color )

  {
    ::ZeroMemory(MT4ORDERS::LastTradeRequest);

    MT4ORDERS::LastTradeRequest.action = (((Type == OP_BUY) || (Type == OP_SELL)) ? TRADE_ACTION_DEAL : TRADE_ACTION_PENDING);
    MT4ORDERS::LastTradeRequest.magic = magic;

    MT4ORDERS::LastTradeRequest.symbol = ((Symb == NULL) ? ::Symbol() : Symb);
    MT4ORDERS::LastTradeRequest.volume = dVolume;
    MT4ORDERS::LastTradeRequest.price = Price;

    MT4ORDERS::LastTradeRequest.tp = TP;
    MT4ORDERS::LastTradeRequest.sl = SL;
    MT4ORDERS::LastTradeRequest.deviation = SlipPage;
    MT4ORDERS::LastTradeRequest.type = (ENUM_ORDER_TYPE)Type;

    MT4ORDERS::LastTradeRequest.type_filling = _B2(MT4ORDERS::GetFilling(MT4ORDERS::LastTradeRequest.symbol, (uint)MT4ORDERS::LastTradeRequest.deviation));

    if (MT4ORDERS::LastTradeRequest.action == TRADE_ACTION_PENDING)
    {
      MT4ORDERS::LastTradeRequest.type_time = _B2(MT4ORDERS::GetExpirationType(MT4ORDERS::LastTradeRequest.symbol, (uint)dExpiration));

      if (dExpiration > ORDER_TIME_DAY)
        MT4ORDERS::LastTradeRequest.expiration = dExpiration;
    }

    if (comment != NULL)
      MT4ORDERS::LastTradeRequest.comment = comment;

    return((arrow_color == INT_MAX) ? (MT4ORDERS::NewOrderCheck() ? 0 : -1) :
           ((((int)arrow_color != INT_MIN) || MT4ORDERS::NewOrderCheck()) &&
            MT4ORDERS::OrderSend(MT4ORDERS::LastTradeRequest, MT4ORDERS::LastTradeResult) ?
            (MT4ORDERS::IsHedging ? (long)MT4ORDERS::LastTradeResult.order : // PositionID == Result.order - особенность MT5-Hedge
             ((MT4ORDERS::LastTradeRequest.action == TRADE_ACTION_DEAL) ?
              (MT4ORDERS::IsTester ? (_B2(::PositionSelect(MT4ORDERS::LastTradeRequest.symbol)) ? PositionGetInteger(POSITION_TICKET) : 0) :
                                      ::HistoryDealGetInteger(MT4ORDERS::LastTradeResult.deal, DEAL_POSITION_ID)) :
              (long)MT4ORDERS::LastTradeResult.order)) : -1));
  }

  static bool MT4OrderModify( const long &Ticket, const double &Price, const double &SL, const double &TP, const datetime &Expiration, const color &Arrow_Color )
  {
    ::ZeroMemory(MT4ORDERS::LastTradeRequest);

               // The case is taken into account when there is an order and a position with the same ticket
    bool Res = (Ticket < 0) ? MT4ORDERS::ModifyOrder(-Ticket, Price, Expiration, MT4ORDERS::LastTradeRequest) :
               ((MT4ORDERS::Order.Ticket != ORDER_SELECT) ?
                (MT4ORDERS::ModifyPosition(Ticket, MT4ORDERS::LastTradeRequest) || MT4ORDERS::ModifyOrder(Ticket, Price, Expiration, MT4ORDERS::LastTradeRequest)) :
                (MT4ORDERS::ModifyOrder(Ticket, Price, Expiration, MT4ORDERS::LastTradeRequest) || MT4ORDERS::ModifyPosition(Ticket, MT4ORDERS::LastTradeRequest)));

    {
      MT4ORDERS::LastTradeRequest.tp = TP;
      MT4ORDERS::LastTradeRequest.sl = SL;

      Res = MT4ORDERS::NewOrderSend(Arrow_Color);
    }

    return(Res);
  }

  static bool MT4OrderClose( const long &Ticket, const double &dLots, const double &Price, const int &SlipPage, const color &Arrow_Color, const string &comment )
  {
    // There is MT4ORDERS::__LastTradeRequest and MT4ORDERS::__LastTradeResult, so the result is not affected, but it is necessary for PositionGetString below
    _B2(::PositionSelectByTicket(Ticket));

    ::ZeroMemory(MT4ORDERS::LastTradeRequest);

    MT4ORDERS::LastTradeRequest.action = TRADE_ACTION_DEAL;
    MT4ORDERS::LastTradeRequest.position = Ticket;

    MT4ORDERS::LastTradeRequest.symbol = ::PositionGetString(POSITION_SYMBOL);

    // We keep a comment when a position is partially closed
    MT4ORDERS::LastTradeRequest.comment = (comment == NULL) ? ::PositionGetString(POSITION_COMMENT) : comment;

    // Is it correct not to set the magic when closing? -Right!
    MT4ORDERS::LastTradeRequest.volume = dLots;
    MT4ORDERS::LastTradeRequest.price = Price;

  #ifdef MT4ORDERS_SLTP_OLD
    // It is necessary to determine the SL / TP levels at the closed position.
    // SYMBOL_SESSION_PRICE_LIMIT_MIN and SYMBOL_SESSION_PRICE_LIMIT_MAX do not need to be checked; source SL / TP is already installed
    MT4ORDERS::LastTradeRequest.tp = ::PositionGetDouble(POSITION_SL);
    MT4ORDERS::LastTradeRequest.sl = ::PositionGetDouble(POSITION_TP);

    if (MT4ORDERS::LastTradeRequest.tp || MT4ORDERS::LastTradeRequest.sl)
    {
      const double __StopLevel = ::SymbolInfoInteger(MT4ORDERS::LastTradeRequest.symbol, SYMBOL_TRADE_STOPS_LEVEL) *
                                 ::SymbolInfoDouble(MT4ORDERS::LastTradeRequest.symbol, SYMBOL_POINT);

      const bool FlagBuy = (::PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      const double CurrentPrice = SymbolInfoDouble(MT4ORDERS::LastTradeRequest.symbol, FlagBuy ? SYMBOL_ASK : SYMBOL_BID);

      if (CurrentPrice)
      {
        if (FlagBuy)
          MT4ORDERS::CheckPrices(MT4ORDERS::LastTradeRequest.tp, MT4ORDERS::LastTradeRequest.sl, CurrentPrice - __StopLevel, CurrentPrice + __StopLevel);
        else
          MT4ORDERS::CheckPrices(MT4ORDERS::LastTradeRequest.sl, MT4ORDERS::LastTradeRequest.tp, CurrentPrice - __StopLevel, CurrentPrice + __StopLevel);
      }
      else
      {
        MT4ORDERS::LastTradeRequest.tp = 0;
        MT4ORDERS::LastTradeRequest.sl = 0;
      }
    }
  #endif // MT4ORDERS_SLTP_OLD

    MT4ORDERS::LastTradeRequest.deviation = SlipPage;

    MT4ORDERS::LastTradeRequest.type = (ENUM_ORDER_TYPE)(1 - ::PositionGetInteger(POSITION_TYPE));

    MT4ORDERS::LastTradeRequest.type_filling = _B2(MT4ORDERS::GetFilling(MT4ORDERS::LastTradeRequest.symbol, (uint)MT4ORDERS::LastTradeRequest.deviation));

    return(MT4ORDERS::NewOrderSend(Arrow_Color));
  }

  static bool MT4OrderCloseBy( const long &Ticket, const long &Opposite, const color &Arrow_Color )
  {
    ::ZeroMemory(MT4ORDERS::LastTradeRequest);

    MT4ORDERS::LastTradeRequest.action = TRADE_ACTION_CLOSE_BY;
    MT4ORDERS::LastTradeRequest.position = Ticket;
    MT4ORDERS::LastTradeRequest.position_by = Opposite;

    if ((!MT4ORDERS::IsTester) && _B2(::PositionSelectByTicket(Ticket))) // Need for MT4ORDERS::SymbolTrade ()
      MT4ORDERS::LastTradeRequest.symbol = ::PositionGetString(POSITION_SYMBOL);

    return(MT4ORDERS::NewOrderSend(Arrow_Color));
  }

  static bool MT4OrderDelete( const long &Ticket, const color &Arrow_Color )
  {
    ::ZeroMemory(MT4ORDERS::LastTradeRequest);

    MT4ORDERS::LastTradeRequest.action = TRADE_ACTION_REMOVE;
    MT4ORDERS::LastTradeRequest.order = Ticket;

    if ((!MT4ORDERS::IsTester) && _B2(::OrderSelect(Ticket))) // Need for MT4ORDERS::SymbolTrade ()
      MT4ORDERS::LastTradeRequest.symbol = ::OrderGetString(ORDER_SYMBOL);

    return(MT4ORDERS::NewOrderSend(Arrow_Color));
  }

#define MT4_ORDERFUNCTION(NAME,T,A,B,C)                               \
  static T MT4Order##NAME( void )                                     \
  {                                                                   \
    return(POSITION_ORDER((T)(A), (T)(B), MT4ORDERS::Order.NAME, C)); \
  }

#define POSITION_ORDER(A,B,C,D) (((MT4ORDERS::Order.Ticket == POSITION_SELECT) && (D)) ? (A) : ((MT4ORDERS::Order.Ticket == ORDER_SELECT) ? (B) : (C)))

  MT4_ORDERFUNCTION(Ticket, long, ::PositionGetInteger(POSITION_TICKET), ::OrderGetInteger(ORDER_TICKET), true)
  MT4_ORDERFUNCTION(Type, int, ::PositionGetInteger(POSITION_TYPE), ::OrderGetInteger(ORDER_TYPE), true)
  MT4_ORDERFUNCTION(Lots, double, ::PositionGetDouble(POSITION_VOLUME), ::OrderGetDouble(ORDER_VOLUME_CURRENT), true)
  MT4_ORDERFUNCTION(OpenPrice, double, ::PositionGetDouble(POSITION_PRICE_OPEN), (::OrderGetDouble(ORDER_PRICE_OPEN) ? ::OrderGetDouble(ORDER_PRICE_OPEN) : ::OrderGetDouble(ORDER_PRICE_CURRENT)), true)
  MT4_ORDERFUNCTION(OpenTimeMsc, long, ::PositionGetInteger(POSITION_TIME_MSC), ::OrderGetInteger(ORDER_TIME_SETUP_MSC), true)
  MT4_ORDERFUNCTION(OpenTime, datetime, ::PositionGetInteger(POSITION_TIME), ::OrderGetInteger(ORDER_TIME_SETUP), true)
  MT4_ORDERFUNCTION(StopLoss, double, ::PositionGetDouble(POSITION_SL), ::OrderGetDouble(ORDER_SL), true)
  MT4_ORDERFUNCTION(TakeProfit, double, ::PositionGetDouble(POSITION_TP), ::OrderGetDouble(ORDER_TP), true)
  MT4_ORDERFUNCTION(ClosePrice, double, ::PositionGetDouble(POSITION_PRICE_CURRENT), ::OrderGetDouble(ORDER_PRICE_CURRENT), true)
  MT4_ORDERFUNCTION(CloseTimeMsc, long, 0, 0, true)
  MT4_ORDERFUNCTION(CloseTime, datetime, 0, 0, true)
  MT4_ORDERFUNCTION(Expiration, datetime, 0, ::OrderGetInteger(ORDER_TIME_EXPIRATION), true)
  MT4_ORDERFUNCTION(MagicNumber, long, ::PositionGetInteger(POSITION_MAGIC), ::OrderGetInteger(ORDER_MAGIC), true)
  MT4_ORDERFUNCTION(Profit, double, ::PositionGetDouble(POSITION_PROFIT), 0, true)
  MT4_ORDERFUNCTION(Swap, double, ::PositionGetDouble(POSITION_SWAP), 0, true)
  MT4_ORDERFUNCTION(Symbol, string, ::PositionGetString(POSITION_SYMBOL), ::OrderGetString(ORDER_SYMBOL), true)
  MT4_ORDERFUNCTION(Comment, string, MT4ORDERS::Order.Comment, ::OrderGetString(ORDER_COMMENT), MT4ORDERS::CheckPositionCommissionComment())
  MT4_ORDERFUNCTION(Commission, double, MT4ORDERS::Order.Commission, 0, MT4ORDERS::CheckPositionCommissionComment())

  MT4_ORDERFUNCTION(OpenPriceRequest, double, MT4ORDERS::Order.OpenPriceRequest, ::OrderGetDouble(ORDER_PRICE_OPEN), MT4ORDERS::CheckPositionOpenPriceRequest())
  MT4_ORDERFUNCTION(ClosePriceRequest, double, ::PositionGetDouble(POSITION_PRICE_CURRENT), ::OrderGetDouble(ORDER_PRICE_CURRENT), true)

  MT4_ORDERFUNCTION(TicketOpen, long, MT4ORDERS::Order.TicketOpen, ::OrderGetInteger(ORDER_TICKET), MT4ORDERS::CheckPositionTicketOpen())
  MT4_ORDERFUNCTION(OpenReason, ENUM_DEAL_REASON, ::PositionGetInteger(POSITION_REASON), ::OrderGetInteger(ORDER_REASON), true)
  MT4_ORDERFUNCTION(CloseReason, ENUM_DEAL_REASON, 0, ::OrderGetInteger(ORDER_REASON), true)
  MT4_ORDERFUNCTION(TicketID, long, ::PositionGetInteger(POSITION_IDENTIFIER), ::OrderGetInteger(ORDER_TICKET), true)

#undef POSITION_ORDER
#undef MT4_ORDERFUNCTION

  static void MT4OrderPrint( void )
  {
    if (MT4ORDERS::Order.Ticket == POSITION_SELECT)
      MT4ORDERS::CheckPositionCommissionComment();

    ::Print(MT4ORDERS::Order.ToString());

    return;
  }

#undef ORDER_SELECT
#undef POSITION_SELECT
};

static MT4_ORDER MT4ORDERS::Order = {0};

static MT4HISTORY MT4ORDERS::History;

static const bool MT4ORDERS::IsTester = ::MQLInfoInteger(MQL_TESTER);

// If you switch the account, this value is still recalculated by the advisers.
// https://www.mql5.com/ru/forum/170952/page61#comment_6132824
static const bool MT4ORDERS::IsHedging = ((ENUM_ACCOUNT_MARGIN_MODE)::AccountInfoInteger(ACCOUNT_MARGIN_MODE) ==
                                          ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);

static int MT4ORDERS::OrderSendBug = 0;

static uint MT4ORDERS::OrderSend_MaxPause = 1000000; // Maximum time for synchronization in microseconds

static MqlTradeResult MT4ORDERS::LastTradeResult = {0};
static MqlTradeRequest MT4ORDERS::LastTradeRequest;// = {0};
static MqlTradeCheckResult MT4ORDERS::LastTradeCheckResult = {0};

bool OrderClose( const long Ticket, const double dLots, const double Price, const int SlipPage, const color Arrow_Color = clrNONE, const string comment = NULL )
{
  return(MT4ORDERS::MT4OrderClose(Ticket, dLots, Price, SlipPage, Arrow_Color, comment));
}

bool OrderModify( const long Ticket, const double Price, const double SL, const double TP, const datetime Expiration, const color Arrow_Color = clrNONE )
{
  return(MT4ORDERS::MT4OrderModify(Ticket, Price, SL, TP, Expiration, Arrow_Color));
}

bool OrderCloseBy( const long Ticket, const long Opposite, const color Arrow_Color = clrNONE )
{
  return(MT4ORDERS::MT4OrderCloseBy(Ticket, Opposite, Arrow_Color));
}

bool OrderDelete( const long Ticket, const color Arrow_Color = clrNONE )
{
  return(MT4ORDERS::MT4OrderDelete(Ticket, Arrow_Color));
}

void OrderPrint( void )
{
  MT4ORDERS::MT4OrderPrint();

  return;
}

#define MT4_ORDERGLOBALFUNCTION(NAME,T)     \
  T Order##NAME( void )                     \
  {                                         \
    return((T)MT4ORDERS::MT4Order##NAME()); \
  }

MT4_ORDERGLOBALFUNCTION(sHistoryTotal, int)
MT4_ORDERGLOBALFUNCTION(Ticket, TICKET_TYPE)
MT4_ORDERGLOBALFUNCTION(Type, int)
MT4_ORDERGLOBALFUNCTION(Lots, double)
MT4_ORDERGLOBALFUNCTION(OpenPrice, double)
MT4_ORDERGLOBALFUNCTION(OpenTimeMsc, long)
MT4_ORDERGLOBALFUNCTION(OpenTime, datetime)
MT4_ORDERGLOBALFUNCTION(StopLoss, double)
MT4_ORDERGLOBALFUNCTION(TakeProfit, double)
MT4_ORDERGLOBALFUNCTION(ClosePrice, double)
MT4_ORDERGLOBALFUNCTION(CloseTimeMsc, long)
MT4_ORDERGLOBALFUNCTION(CloseTime, datetime)
MT4_ORDERGLOBALFUNCTION(Expiration, datetime)
MT4_ORDERGLOBALFUNCTION(MagicNumber, MAGIC_TYPE)
MT4_ORDERGLOBALFUNCTION(Profit, double)
MT4_ORDERGLOBALFUNCTION(Commission, double)
MT4_ORDERGLOBALFUNCTION(Swap, double)
MT4_ORDERGLOBALFUNCTION(Symbol, string)
MT4_ORDERGLOBALFUNCTION(Comment, string)

MT4_ORDERGLOBALFUNCTION(OpenPriceRequest, double)
MT4_ORDERGLOBALFUNCTION(ClosePriceRequest, double)

MT4_ORDERGLOBALFUNCTION(TicketOpen, long)
MT4_ORDERGLOBALFUNCTION(OpenReason, ENUM_DEAL_REASON)
MT4_ORDERGLOBALFUNCTION(CloseReason, ENUM_DEAL_REASON)
MT4_ORDERGLOBALFUNCTION(TicketID, long)

#undef MT4_ORDERGLOBALFUNCTION

// Overloaded standard functions
#define OrdersTotal MT4ORDERS::MT4OrdersTotal // AFTER Expert / Expert.mqh - there is a call to MT5-OrdersTotal ()

bool OrderSelect( const long Index, const int Select, const int Pool = MODE_TRADES )
{
  return(_B2(MT4ORDERS::MT4OrderSelect(Index, Select, Pool)));
}

TICKET_TYPE OrderSend( const string Symb, const int Type, const double dVolume, const double Price, const int SlipPage, const double SL, const double TP,
                       const string comment = NULL, const MAGIC_TYPE magic = 0, const datetime dExpiration = 0, color arrow_color = clrNONE )
{
  return((TICKET_TYPE)MT4ORDERS::MT4OrderSend(Symb, Type, dVolume, Price, SlipPage, SL, TP, comment, magic, dExpiration, arrow_color));
}

#define RETURN_ASYNC(A) return((A) && ::OrderSendAsync(MT4ORDERS::LastTradeRequest, MT4ORDERS::LastTradeResult) &&                        \
                               (MT4ORDERS::LastTradeResult.retcode == TRADE_RETCODE_PLACED) ? MT4ORDERS::LastTradeResult.request_id : 0);

uint OrderCloseAsync( const long Ticket, const double dLots, const double Price, const int SlipPage, const color Arrow_Color = clrNONE )
{
  RETURN_ASYNC(OrderClose(Ticket, dLots, Price, SlipPage, INT_MAX))
}

uint OrderModifyAsync( const long Ticket, const double Price, const double SL, const double TP, const datetime Expiration, const color Arrow_Color = clrNONE )
{
  RETURN_ASYNC(OrderModify(Ticket, Price, SL, TP, Expiration, INT_MAX))
}

uint OrderDeleteAsync( const long Ticket, const color Arrow_Color = clrNONE )
{
  RETURN_ASYNC(OrderDelete(Ticket, INT_MAX))
}

uint OrderSendAsync( const string Symb, const int Type, const double dVolume, const double Price, const int SlipPage, const double SL, const double TP,
                    const string comment = NULL, const MAGIC_TYPE magic = 0, const datetime dExpiration = 0, color arrow_color = clrNONE )
{
  RETURN_ASYNC(!OrderSend(Symb, Type, dVolume, Price, SlipPage, SL, TP, comment, magic, dExpiration, INT_MAX))
}

#undef RETURN_ASYNC

#undef MT4ORDERS_SLTP_OLD

#undef _BV2
#undef _B3
#undef _B2

#ifdef MT4ORDERS_BENCHMARK_MINTIME
  #undef MT4ORDERS_BENCHMARK_MINTIME
#endif // MT4ORDERS_BENCHMARK_MINTIME

#endif // __MT4ORDERS__
#else  // __MQL5__
  #define TICKET_TYPE int
  #define MAGIC_TYPE  int
#endif // __MQL5__


#ifdef __MQL5__

#include <StdLibErr.mqh>

ENUM_TIMEFRAMES TFMigrate(int __timeframe)
{
   switch (__timeframe)
   {
      case 0:
         return (PERIOD_CURRENT);
      case 1:
         return (PERIOD_M1);
      case 5:
         return (PERIOD_M5);
      case 15:
         return (PERIOD_M15);
      case 30:
         return (PERIOD_M30);
      case 60:
         return (PERIOD_H1);
      case 240:
         return (PERIOD_H4);
      case 1440:
         return (PERIOD_D1);
      case 10080:
         return (PERIOD_W1);
      case 43200:
         return (PERIOD_MN1);

      case 2:
         return (PERIOD_M2);
      case 3:
         return (PERIOD_M3);
      case 4:
         return (PERIOD_M4);
      case 6:
         return (PERIOD_M6);
      case 10:
         return (PERIOD_M10);
      case 12:
         return (PERIOD_M12);
      case 16385:
         return (PERIOD_H1);
      case 16386:
         return (PERIOD_H2);
      case 16387:
         return (PERIOD_H3);
      case 16388:
         return (PERIOD_H4);
      case 16390:
         return (PERIOD_H6);
      case 16392:
         return (PERIOD_H8);
      case 16396:
         return (PERIOD_H12);
      case 16408:
         return (PERIOD_D1);
      case 32769:
         return (PERIOD_W1);
      case 49153:
         return (PERIOD_MN1);
      default:
         return (PERIOD_CURRENT);
   }
}

ENUM_APPLIED_PRICE PriceMigrate(int __price)
{
   switch (__price)
   {
      case 1:
         return (PRICE_CLOSE);
      case 2:
         return (PRICE_OPEN);
      case 3:
         return (PRICE_HIGH);
      case 4:
         return (PRICE_LOW);
      case 5:
         return (PRICE_MEDIAN);
      case 6:
         return (PRICE_TYPICAL);
      case 7:
         return (PRICE_WEIGHTED);
      default:
         return (PRICE_CLOSE);
   }
}

ENUM_MA_METHOD MethodMigrate(int __method)
{
   switch (__method)
   {
      case 0:
         return (MODE_SMA);
      case 1:
         return (MODE_EMA);
      case 2:
         return (MODE_SMMA);
      case 3:
         return (MODE_LWMA);
      default:
         return (MODE_SMA);
   }
}

ENUM_STO_PRICE StoFieldMigrate(int __field)
{
   switch (__field)
   {
      case 0:
         return (STO_LOWHIGH);
      case 1:
         return (STO_CLOSECLOSE);
      default:
         return (STO_LOWHIGH);
   }
}

#define Point                               _Point
#define Digits                              _Digits
#define Bid                                 (::SymbolInfoDouble(_Symbol, ::SYMBOL_BID))
#define Ask                                 (::SymbolInfoDouble(_Symbol, ::SYMBOL_ASK))

#define DoubleToStr                         DoubleToString
#define StringGetChar                       StringGetCharacter
#define StrToInteger                        (int)StringToInteger
#define StrToTime                           StringToTime
#define TimeToStr                           TimeToString

#define EMPTY                              -1

#define ERR_NO_ERROR                        0
#define ERR_NO_RESULT                       1
#define ERR_SERVER_BUSY                     4
#define ERR_NO_CONNECTION                   6
#define ERR_TRADE_TIMEOUT                 128
#define ERR_INVALID_PRICE                 129
#define ERR_NOT_ENOUGH_MONEY              134
#define ERR_PRICE_CHANGED                 135
#define ERR_OFF_QUOTES                    136
#define ERR_BROKER_BUSY                   137
#define ERR_REQUOTE                       138
#define ERR_TRADE_MODIFY_DENIED           145
#define ERR_TRADE_CONTEXT_BUSY            146

#define MODE_TIME                           5
#define MODE_BID                            9
#define MODE_ASK                           10
#define MODE_POINT                         11
#define MODE_DIGITS                        12
#define MODE_SPREAD                        13
#define MODE_STOPLEVEL                     14
#define MODE_LOTSIZE                       15
#define MODE_TICKVALUE                     16
#define MODE_TICKSIZE                      17
#define MODE_SWAPLONG                      18
#define MODE_SWAPSHORT                     19
#define MODE_STARTING                      20
#define MODE_EXPIRATION                    21
#define MODE_TRADEALLOWED                  22
#define MODE_MINLOT                        23
#define MODE_LOTSTEP                       24
#define MODE_MAXLOT                        25
#define MODE_SWAPTYPE                      26
#define MODE_PROFITCALCMODE                27
#define MODE_MARGINCALCMODE                28
#define MODE_MARGININIT                    29
#define MODE_MARGINMAINTENANCE             30
#define MODE_MARGINHEDGED                  31
#define MODE_MARGINREQUIRED                32
#define MODE_FREEZELEVEL                   33

#define LONG_VALUE                          INT_VALUE

#define OBJPROP_TIME1                       OBJPROP_TIME
#define OBJPROP_PRICE1                      OBJPROP_PRICE

#define MODE_ASCEND                         0
#define MODE_DESCEND                        1

#define MODE_TENKANSEN                      1
#define MODE_KIJUNSEN                       2
#define MODE_SENKOUSPANA                    3
#define MODE_SENKOUSPANB                    4 
#define MODE_CHIKOUSPAN                     5

void HideTestIndicators(bool __status = true)
{
   TesterHideIndicators(__status);
}

bool IsTradeContextBusy(void)
{
   return (false);
}

bool RefreshRates(void)
{
   return (true);
}

double AccountFreeMarginCheck(const string __symbol, const int __cmd, const double __volume)
{
   double __Margin = 0;

   return (::AccountInfoDouble(::ACCOUNT_MARGIN_FREE) -
           (::OrderCalcMargin((ENUM_ORDER_TYPE)__cmd, __symbol, __volume, ::SymbolInfoDouble(__symbol, (__cmd == ::ORDER_TYPE_BUY) ? ::SYMBOL_ASK : ::SYMBOL_BID), __Margin) ? __Margin : 0));
}

bool ObjectCreate(string __name, ENUM_OBJECT __type, int __window, datetime __time1, double __price1, datetime __time2 = 0, double __price2 = 0, datetime __time3 = 0, double __price3 = 0)
{
   return (ObjectCreate(0, __name, __type, __window, __time1, __price1, __time2, __price2, __time3, __price3));
}

bool ObjectDelete(string __name)
{
   return (ObjectDelete(0, __name));
}

int ObjectFind(string __name)
{
   return (ObjectFind(0, __name));
}

bool ObjectMove(string __name, int __point, datetime __time1, double __price1)
{
   return (ObjectMove(0, __name, __point, __time1, __price1));
}

string ObjectName(int __index)
{
   return (ObjectName(0, __index));
}

bool ObjectSet(string __name, ENUM_OBJECT_PROPERTY_INTEGER __index, long __value)
{
   return ((bool)ObjectSetInteger(0, __name, __index, __value));
}

bool ObjectSet(string __name, ENUM_OBJECT_PROPERTY_DOUBLE __index, double __value)
{
   return ((bool)ObjectSetDouble(0, __name, __index, __value));
}

bool ObjectSetText(string __name, string __text, int __font_size, string __font = "", color __text_color = CLR_NONE)
{
   int __ObjType = ObjectType(__name);

   if (__ObjType != OBJ_LABEL && __ObjType != OBJ_TEXT)
      return (false);

   if (StringLen(__text) > 0 && __font_size > 0)
   {
      if (ObjectSetString(0, __name, OBJPROP_TEXT, __text) == true && ObjectSetInteger(0, __name, OBJPROP_FONTSIZE, __font_size) == true)
      {
         if (StringLen(__font) > 0 && ObjectSetString(0, __name, OBJPROP_FONT, __font) == false)
            return (false);

         if (ObjectSetInteger(0, __name, OBJPROP_COLOR, __text_color) == false)
            return (false);

         return (true);
      }

      return (false);
   }

   return (false);
}

bool ObjectSetText(string __name, string __text)
{
   int __ObjType = ObjectType(__name);

   if (__ObjType != OBJ_LABEL && __ObjType != OBJ_TEXT)
      return (false);

   if (StringLen(__text) > 0)
   {
      if (ObjectSetString(0, __name, OBJPROP_TEXT, __text) == true)
         return (true);

      return (false);
   }

   return (false);
}

int ObjectType(string __name)
{
   return ((int)ObjectGetInteger(0, __name, OBJPROP_TYPE));
}

int ObjectsTotal(int __type = EMPTY, int __window = -1)
{
   return (ObjectsTotal(0, __window, __type));
}

void WindowRedraw()
{
   ChartRedraw(0);
}

int Year(void)
{
   MqlDateTime __Time;

   ::TimeToStruct(TimeCurrent(), __Time);

   return (__Time.year);
}

int DayOfWeek(void)
{
   MqlDateTime __Time;

   ::TimeToStruct(TimeCurrent(), __Time);

   return (__Time.day_of_week);
}

int TimeDayOfWeek(const datetime __date)
{
   MqlDateTime __Time;

   ::TimeToStruct(__date, __Time);

   return (__Time.day_of_week);
}

double GetMarginRequired(const string __symbol)
{
  MqlTick __Tick;
  double __MarginInit, __MarginMain;

  return (SymbolInfoTick(__symbol, __Tick) && SymbolInfoMarginRate(__symbol, ORDER_TYPE_BUY, __MarginInit, __MarginMain)
          ? __MarginInit * __Tick.ask * SymbolInfoDouble(__symbol, SYMBOL_TRADE_TICK_VALUE) / (SymbolInfoDouble(__symbol, SYMBOL_TRADE_TICK_SIZE) * AccountInfoInteger(ACCOUNT_LEVERAGE))
          : 0);
}

double MarketInfo(const string __symbol, const int __type)
{
   switch(__type)
   {
      case MODE_BID:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_BID));
      case MODE_ASK:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_ASK));
      case MODE_POINT:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_POINT));
      case MODE_DIGITS:
         return ((double)::SymbolInfoInteger(__symbol, ::SYMBOL_DIGITS));
      case MODE_SPREAD:
         return ((double)::SymbolInfoInteger(__symbol, ::SYMBOL_SPREAD));
      case MODE_LOW:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_LASTLOW));
      case MODE_HIGH:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_LASTHIGH));
      case MODE_TIME:
         return double(::SymbolInfoInteger(__symbol, ::SYMBOL_TIME));
      case MODE_STOPLEVEL:
         return ((double)::SymbolInfoInteger(__symbol, ::SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_TRADE_CONTRACT_SIZE));
      case MODE_MINLOT:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_VOLUME_MIN));
      case MODE_LOTSTEP:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_VOLUME_STEP));
      case MODE_MAXLOT:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_VOLUME_MAX));
      case MODE_TICKSIZE:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_TRADE_TICK_SIZE));
      case MODE_TICKVALUE:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_TRADE_TICK_VALUE));
      case MODE_SWAPTYPE:
         return double(::SymbolInfoInteger(__symbol, ::SYMBOL_SWAP_MODE));
      case MODE_SWAPLONG:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_SWAP_LONG));
      case MODE_SWAPSHORT:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_SWAP_SHORT));
      case MODE_STARTING:
         return ((double)::SymbolInfoInteger(__symbol, ::SYMBOL_START_TIME));
      case MODE_EXPIRATION:
         return ((double)::SymbolInfoInteger(__symbol, ::SYMBOL_EXPIRATION_TIME));
      case MODE_TRADEALLOWED:
         return ((double)::SymbolInfoInteger(__symbol, ::SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_DISABLED);
      case MODE_PROFITCALCMODE:
         return ((double)::SymbolInfoInteger(__symbol, ::SYMBOL_TRADE_CALC_MODE));
      case MODE_MARGINCALCMODE:
         return ((double)::SymbolInfoInteger(__symbol, ::SYMBOL_TRADE_CALC_MODE));
      case MODE_MARGININIT:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_MARGIN_INITIAL));
      case MODE_MARGINMAINTENANCE:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_MARGIN_MAINTENANCE));
      case MODE_MARGINHEDGED:
         return (::SymbolInfoDouble(__symbol, ::SYMBOL_MARGIN_HEDGED));
      case MODE_MARGINREQUIRED:
         return (GetMarginRequired(__symbol));
      case MODE_FREEZELEVEL:
         return ((double)::SymbolInfoInteger(__symbol, ::SYMBOL_TRADE_FREEZE_LEVEL));
   }

   return (-1);
}

string ErrorDescription(int __error)
{
   switch (__error)
   {
      case ERR_SUCCESS:
         return ("The operation completed successfully");
      case ERR_INTERNAL_ERROR:
         return ("Unexpected internal Error ");
      case ERR_WRONG_INTERNAL_PARAMETER:
         return ("Wrong parameter in the inner call of the client terminal function");
      case ERR_INVALID_PARAMETER:
         return ("Wrong parameter when calling the system function");
      case ERR_NOT_ENOUGH_MEMORY:
         return ("Not enough memory to perform the system function");
      case ERR_STRUCT_WITHOBJECTS_ORCLASS:
         return ("The structure contains objects of strings and/or dynamic arrays and/or structure of such objects and/or classes");
      case ERR_INVALID_ARRAY:
         return ("Array of a wrong type, wrong size, or a damaged object of a dynamic array");
      case ERR_ARRAY_RESIZE_ERROR:
         return ("Not enough memory for the relocation of an array, or an attempt to change the size of a static array");
      case ERR_STRING_RESIZE_ERROR:
         return ("Not enough memory for the relocation of string");
      case ERR_NOTINITIALIZED_STRING:
         return ("Not initialized string");
      case ERR_INVALID_DATETIME:
         return ("Invalid date and/or time");
      case ERR_ARRAY_BAD_SIZE:
         return ("Requested array size exceeds 2GB");
      case ERR_INVALID_POINTER:
         return ("Wrong pointer");
      case ERR_INVALID_POINTER_TYPE:
         return ("Wrong type of pointer");
      case ERR_FUNCTION_NOT_ALLOWED:
         return ("Function is not allowed for call");
      case ERR_RESOURCE_NAME_DUPLICATED:
         return ("The names of the dynamic and the static resource match");
      case ERR_RESOURCE_NOT_FOUND:
         return ("Resource with this name has not been found in EX5");
      case ERR_RESOURCE_UNSUPPOTED_TYPE:
         return ("Unsupported resource type or its size exceeds 16MB");
      case ERR_RESOURCE_NAME_IS_TOO_LONG:
         return ("The resource name exceeds 63 characters");
      case ERR_CHART_WRONG_ID:
         return ("Wrong chart ID");
      case ERR_CHART_NO_REPLY:
         return ("Chart does not respond");
      case ERR_CHART_NOT_FOUND:
         return ("Chart not found");
      case ERR_CHART_NO_EXPERT:
         return ("No Expert Advisor in the chart that could handle the event");
      case ERR_CHART_CANNOT_OPEN:
         return ("Chart opening Error ");
      case ERR_CHART_CANNOT_CHANGE:
         return ("Failed to change chart symbol and period");
      case ERR_CHART_WRONG_PARAMETER:
         return ("Error value of the parameter for the function of working with charts");
      case ERR_CHART_CANNOT_CREATE_TIMER:
         return ("Failed to create timer");
      case ERR_CHART_WRONG_PROPERTY:
         return ("Wrong chart property ID");
      case ERR_CHART_SCREENSHOT_FAILED:
         return ("Error creating screenshots");
      case ERR_CHART_NAVIGATE_FAILED:
         return ("Error navigating through chart");
      case ERR_CHART_TEMPLATE_FAILED:
         return ("Error applying template");
      case ERR_CHART_WINDOW_NOT_FOUND:
         return ("Subwindow containing the indicator was not found");
      case ERR_CHART_INDICATOR_CANNOT_ADD:
         return ("Error adding an indicator to chart");
      case ERR_CHART_INDICATOR_CANNOT_DEL:
         return ("Error deleting an indicator from the chart");
      case ERR_CHART_INDICATOR_NOT_FOUND:
         return ("Indicator not found on the specified chart");
      case ERR_OBJECT_ERROR:
         return ("Error working with a graphical object");
      case ERR_OBJECT_NOT_FOUND:
         return ("Graphical object was not found");
      case ERR_OBJECT_WRONG_PROPERTY:
         return ("Wrong ID of a graphical object property");
      case ERR_OBJECT_GETDATE_FAILED:
         return ("Unable to get date corresponding to the value");
      case ERR_OBJECT_GETVALUE_FAILED:
         return ("Unable to get value corresponding to the date");
      case ERR_MARKET_UNKNOWN_SYMBOL:
         return ("Unknown symbol");
      case ERR_MARKET_NOT_SELECTED:
         return ("Symbol is not selected in MarketWatch");
      case ERR_MARKET_WRONG_PROPERTY:
         return ("Wrong identifier of a symbol property");
      case ERR_MARKET_LASTTIME_UNKNOWN:
         return ("Time of the last tick is not known (no ticks)");
      case ERR_MARKET_SELECT_ERROR:
         return ("Error adding or deleting a symbol in MarketWatch");
      case ERR_HISTORY_NOT_FOUND:
         return ("Requested history not found");
      case ERR_HISTORY_WRONG_PROPERTY:
         return ("Wrong ID of the history property");
      case ERR_HISTORY_TIMEOUT:
         return ("Exceeded history request timeout");
      case ERR_HISTORY_BARS_LIMIT:
         return ("Number of requested bars limited by terminal settings");
      case ERR_HISTORY_LOAD_ERRORS:
         return ("Multiple errors when loading history");
      case ERR_HISTORY_SMALL_BUFFER:
         return ("Receiving array is too small to store all requested data");
      case ERR_GLOBALVARIABLE_NOT_FOUND:
         return ("Global variable of the client terminal is not found");
      case ERR_GLOBALVARIABLE_EXISTS:
         return ("Global variable of the client terminal with the same name already exists");
      case ERR_MAIL_SEND_FAILED:
         return ("Email sending failed");
      case ERR_PLAY_SOUND_FAILED:
         return ("Sound playing failed");
      case ERR_MQL5_WRONG_PROPERTY:
         return ("Wrong identifier of the program property");
      case ERR_TERMINAL_WRONG_PROPERTY:
         return ("Wrong identifier of the terminal property");
      case ERR_FTP_SEND_FAILED:
         return ("File sending via ftp failed");
      case ERR_NOTIFICATION_SEND_FAILED:
         return ("Failed to send a notification");
      case ERR_NOTIFICATION_WRONG_PARAMETER:
         return ("Invalid parameter for sending a notification – an empty string or NULL has been passed to the SendNotification() function");
      case ERR_NOTIFICATION_WRONG_SETTINGS:
         return ("Wrong settings of notifications in the terminal (ID is not specified or permission is not set)");
      case ERR_NOTIFICATION_TOO_FREQUENT:
         return ("Too frequent sending of notifications");
      case ERR_FTP_NOSERVER:
         return ("FTP server is not specified");
      case ERR_FTP_NOLOGIN:
         return ("FTP login is not specified");
      case ERR_FTP_FILE_ERROR:
         return ("File not found in the MQL5\\Files directory to send on FTP server");
      case ERR_FTP_CONNECT_FAILED:
         return ("FTP connection failed");
      case ERR_FTP_CHANGEDIR:
         return ("FTP path not found on server");
      case ERR_BUFFERS_NO_MEMORY:
         return ("Not enough memory for the distribution of indicator buffers");
      case ERR_BUFFERS_WRONG_INDEX:
         return ("Wrong indicator buffer index");
      case ERR_CUSTOM_WRONG_PROPERTY:
         return ("Wrong ID of the custom indicator property");
      case ERR_ACCOUNT_WRONG_PROPERTY:
         return ("Wrong account property ID");
      case ERR_TRADE_WRONG_PROPERTY:
         return ("Wrong trade property ID");
      case ERR_TRADE_DISABLED:
         return ("Trading by Expert Advisors prohibited");
      case ERR_TRADE_POSITION_NOT_FOUND:
         return ("Position not found");
      case ERR_TRADE_ORDER_NOT_FOUND:
         return ("Order not found");
      case ERR_TRADE_DEAL_NOT_FOUND:
         return ("Deal not found");
      case ERR_TRADE_SEND_FAILED:
         return ("Trade request sending failed");
      case ERR_INDICATOR_UNKNOWN_SYMBOL:
         return ("Unknown symbol");
      case ERR_INDICATOR_CANNOT_CREATE:
         return ("Indicator cannot be created");
      case ERR_INDICATOR_NO_MEMORY:
         return ("Not enough memory to add the indicator");
      case ERR_INDICATOR_CANNOT_APPLY:
         return ("The indicator cannot be applied to another indicator");
      case ERR_INDICATOR_CANNOT_ADD:
         return ("Error applying an indicator to chart");
      case ERR_INDICATOR_DATA_NOT_FOUND:
         return ("Requested data not found");
      case ERR_INDICATOR_WRONG_HANDLE:
         return ("Wrong indicator handle");
      case ERR_INDICATOR_WRONG_PARAMETERS:
         return ("Wrong number of parameters when creating an indicator");
      case ERR_INDICATOR_PARAMETERS_MISSING:
         return ("No parameters when creating an indicator");
      case ERR_INDICATOR_CUSTOM_NAME:
         return ("The first parameter in the array must be the name of the custom indicator");
      case ERR_INDICATOR_PARAMETER_TYPE:
         return ("Invalid parameter type in the array when creating an indicator");
      case ERR_INDICATOR_WRONG_INDEX:
         return ("Wrong index of the requested indicator buffer");
      case ERR_BOOKS_CANNOT_ADD:
         return ("Depth Of Market can not be added");
      case ERR_BOOKS_CANNOT_DELETE:
         return ("Depth Of Market can not be removed");
      case ERR_BOOKS_CANNOT_GET:
         return ("The data from Depth Of Market can not be obtained");
      case ERR_BOOKS_CANNOT_SUBSCRIBE:
         return ("Error in subscribing to receive new data from Depth Of Market");
      case ERR_TOO_MANY_FILES:
         return ("More than 64 files cannot be opened at the same time");
      case ERR_WRONG_FILENAME:
         return ("Invalid file name");
      case ERR_TOO_LONG_FILENAME:
         return ("Too long file name");
      case ERR_CANNOT_OPEN_FILE:
         return ("File opening Error ");
      case ERR_FILE_CACHEBUFFER_ERROR:
         return ("Not enough memory for cache to read");
      case ERR_CANNOT_DELETE_FILE:
         return ("File deleting Error ");
      case ERR_INVALID_FILEHANDLE:
         return ("A file with this handle was closed, or was not opening at all");
      case ERR_WRONG_FILEHANDLE:
         return ("Wrong file handle");
      case ERR_FILE_NOTTOWRITE:
         return ("The file must be opened for writing");
      case ERR_FILE_NOTTOREAD:
         return ("The file must be opened for reading");
      case ERR_FILE_NOTBIN:
         return ("The file must be opened as a binary one");
      case ERR_FILE_NOTTXT:
         return ("The file must be opened as a text");
      case ERR_FILE_NOTTXTORCSV:
         return ("The file must be opened as a text or CSV");
      case ERR_FILE_NOTCSV:
         return ("The file must be opened as CSV");
      case ERR_FILE_READERROR:
         return ("File reading Error ");
      case ERR_FILE_BINSTRINGSIZE:
         return ("String size must be specified, because the file is opened as binary");
      case ERR_INCOMPATIBLE_FILE:
         return ("A text file must be for string arrays, for other arrays - binary");
      case ERR_FILE_IS_DIRECTORY:
         return ("This is not a file, this is a directory");
      case ERR_FILE_NOT_EXIST:
         return ("File does not exist");
      case ERR_FILE_CANNOT_REWRITE:
         return ("File can not be rewritten");
   // case ERR_WRONG_DIRECTORYNAME:
   //    return ("Wrong directory name");
      case ERR_DIRECTORY_NOT_EXIST:
         return ("Directory does not exist");
      case ERR_FILE_ISNOT_DIRECTORY:
         return ("This is a file, not a directory");
      case ERR_CANNOT_DELETE_DIRECTORY:
         return ("The directory cannot be removed");
      case ERR_CANNOT_CLEAN_DIRECTORY:
         return ("Failed to clear the directory (probably one or more files are blocked and removal operation failed)");
      case ERR_FILE_WRITEERROR:
         return ("Failed to write a resource to a file");
      case ERR_FILE_ENDOFFILE:
         return ("Unable to read the next piece of data from a CSV file (FileReadString, FileReadNumber, FileReadDatetime, FileReadBool), since the end of file is reached");
      case ERR_NO_STRING_DATE:
         return ("No date in the string");
      case ERR_WRONG_STRING_DATE:
         return ("Wrong date in the string");
      case ERR_WRONG_STRING_TIME:
         return ("Wrong time in the string");
      case ERR_STRING_TIME_ERROR:
         return ("Error converting string to date");
      case ERR_STRING_OUT_OF_MEMORY:
         return ("Not enough memory for the string");
      case ERR_STRING_SMALL_LEN:
         return ("The string length is less than expected");
      case ERR_STRING_TOO_BIGNUMBER:
         return ("Too large number, more than ULONG_MAX");
      case ERR_WRONG_FORMATSTRING:
         return ("Invalid format string");
      case ERR_TOO_MANY_FORMATTERS:
         return ("Amount of format specifiers more than the parameters");
      case ERR_TOO_MANY_PARAMETERS:
         return ("Amount of parameters more than the format specifiers");
      case ERR_WRONG_STRING_PARAMETER:
         return ("Damaged parameter of string type");
      case ERR_STRINGPOS_OUTOFRANGE:
         return ("Position outside the string");
      case ERR_STRING_ZEROADDED:
         return ("0 added to the string end, a useless operation");
      case ERR_STRING_UNKNOWNTYPE:
         return ("Unknown data type when converting to a string");
      case ERR_WRONG_STRING_OBJECT:
         return ("Damaged string object");
      case ERR_INCOMPATIBLE_ARRAYS:
         return ("Copying incompatible arrays. String array can be copied only to a string array, and a numeric array - in numeric array only");
      case ERR_SMALL_ASSERIES_ARRAY:
         return ("The receiving array is declared as AS_SERIES, and it is of insufficient size");
      case ERR_SMALL_ARRAY:
         return ("Too small array, the starting position is outside the array");
      case ERR_ZEROSIZE_ARRAY:
         return ("An array of zero length");
      case ERR_NUMBER_ARRAYS_ONLY:
         return ("Must be a numeric array");
      case ERR_ONEDIM_ARRAYS_ONLY:
         return ("Must be a one-dimensional array");
      case ERR_SERIES_ARRAY:
         return ("Timeseries cannot be used");
      case ERR_DOUBLE_ARRAY_ONLY:
         return ("Must be an array of type double");
      case ERR_FLOAT_ARRAY_ONLY:
         return ("Must be an array of type float");
      case ERR_LONG_ARRAY_ONLY:
         return ("Must be an array of type long");
      case ERR_INT_ARRAY_ONLY:
         return ("Must be an array of type int");
      case ERR_SHORT_ARRAY_ONLY:
         return ("Must be an array of type short");
      case ERR_CHAR_ARRAY_ONLY:
         return ("Must be an array of type char");
      case ERR_OPENCL_NOT_SUPPORTED:
         return ("OpenCL functions are not supported on this computer");
      case ERR_OPENCL_INTERNAL:
         return ("Internal error occurred when running OpenCL");
      case ERR_OPENCL_INVALID_HANDLE:
         return ("Invalid OpenCL handle");
      case ERR_OPENCL_CONTEXT_CREATE:
         return ("Error creating the OpenCL context");
      case ERR_OPENCL_QUEUE_CREATE:
         return ("Failed to create a run queue in OpenCL");
      case ERR_OPENCL_PROGRAM_CREATE:
         return ("Error occurred when compiling an OpenCL program");
      case ERR_OPENCL_TOO_LONG_KERNEL_NAME:
         return ("Too long kernel name (OpenCL kernel)");
      case ERR_OPENCL_KERNEL_CREATE:
         return ("Error creating an OpenCL kernel");
      case ERR_OPENCL_SET_KERNEL_PARAMETER:
         return ("Error occurred when setting parameters for the OpenCL kernel");
      case ERR_OPENCL_EXECUTE:
         return ("OpenCL program runtime Error ");
      case ERR_OPENCL_WRONG_BUFFER_SIZE:
         return ("Invalid size of the OpenCL buffer");
      case ERR_OPENCL_WRONG_BUFFER_OFFSET:
         return ("Invalid offset in the OpenCL buffer");
      case ERR_OPENCL_BUFFER_CREATE:
         return ("Failed to create an OpenCL buffer");
      case ERR_WEBREQUEST_INVALID_ADDRESS:
         return ("Invalid URL");
      case ERR_WEBREQUEST_CONNECT_FAILED:
         return ("Failed to connect to specified URL");
      case ERR_WEBREQUEST_TIMEOUT:
         return ("Timeout exceeded");
      case ERR_WEBREQUEST_REQUEST_FAILED:
         return ("HTTP request failed");
      case ERR_USER_ERROR_FIRST:
         return ("User defined errors start with this code");
      default:
         return ("");
   }
}

double CopyBufferMQL4(int __handle, int __index, int __shift)
{
   double __Buffer[];

   switch (__index)
   {
      case 0:
         if (CopyBuffer(__handle, 0, __shift, 1, __Buffer) > 0)
            return (__Buffer[0]);

         break;
      case 1:
         if (CopyBuffer(__handle, 1, __shift, 1, __Buffer) > 0)
            return (__Buffer[0]);

         break;
      case 2:
         if (CopyBuffer(__handle, 2, __shift, 1, __Buffer) > 0)
            return (__Buffer[0]);

         break;
      case 3:
         if (CopyBuffer(__handle, 3, __shift, 1, __Buffer) > 0)
            return (__Buffer[0]);

         break;
      case 4:
         if (CopyBuffer(__handle, 4, __shift, 1, __Buffer) > 0)
            return (__Buffer[0]);

         break;
      default:
         break;
   }

   return (EMPTY_VALUE);
}

double iATRMQL4(string __symbol, int __timeframe, int __period, int __shift)
{
   ENUM_TIMEFRAMES __TimeFrame = TFMigrate(__timeframe);

   int __Handle = iATR(__symbol, __TimeFrame, __period);

   if (__Handle < 0)
   {
      Print("The iATR object was not created: Error ", GetLastError());

      return (-1);
   }
   else
      return (CopyBufferMQL4(__Handle, 0, __shift));
}

#define iATR iATRMQL4

double iCloseMQL4(string __symbol, int __tf, int __index)
{
   if (__index < 0)
      return (-1);

   double __Array[];
   ENUM_TIMEFRAMES __Timeframe = TFMigrate(__tf);

   if (CopyClose(__symbol, __Timeframe, __index, 1, __Array) > 0)
      return (__Array[0]);

   return (-1);
}

#define iClose iCloseMQL4

double iCCIMQL4(string __symbol, int __timeframe, int __period, int __price, int __shift)
{
   ENUM_TIMEFRAMES __TimeFrame = TFMigrate(__timeframe);
   ENUM_APPLIED_PRICE __AppliedPrice = PriceMigrate(__price);

   int __Handle = iCCI(__symbol, __TimeFrame, __period, __AppliedPrice);

   if (__Handle < 0)
   {
      Print("The iCCI object was not created: Error ", GetLastError());

      return (-1);
   }
   else
      return (CopyBufferMQL4(__Handle, 0, __shift));
}

#define iCCI iCCIMQL4

double iIchimokuMQL4(string __symbol, int __timeframe, int __tenkan_sen, int __kijun_sen, int __senkou_span_b, int __mode, int __shift)
{
   ENUM_TIMEFRAMES __TimeFrame = TFMigrate(__timeframe);

   int __Handle = iIchimoku(__symbol, __TimeFrame, __tenkan_sen, __kijun_sen, __senkou_span_b);

   if (__Handle < 0)
   {
      Print("The iIchimoku object was not created: Error ", GetLastError());

      return (-1);
   }
   else
      return (CopyBufferMQL4(__Handle, __mode - 1, __shift));
}

#define iIchimoku iIchimokuMQL4

double iMAMQL4(string __symbol, int __timeframe, int __period, int __ma_shift, int __method, int __price, int __shift)
{
   ENUM_TIMEFRAMES __TimeFrame = TFMigrate(__timeframe);
   ENUM_MA_METHOD __Method = MethodMigrate(__method);
   ENUM_APPLIED_PRICE __AppliedPrice = PriceMigrate(__price);

   int __Handle = iMA(__symbol, __TimeFrame, __period, __ma_shift, __Method, __AppliedPrice);

   if (__Handle < 0)
   {
      Print("The iMA object was not created: Error ", GetLastError());

      return (-1);
   }
   else
      return (CopyBufferMQL4(__Handle, 0, __shift));
}

#define iMA iMAMQL4

double iMAOnArrayMQL4(double &__array[], int __total, int __period, int __ma_shift, int __ma_method, int __shift)
{
   double __Buffer[], __Array[];

   if (__total == 0)
      __total = ArraySize(__Array);

   if (__total > 0 && __total <= __period)
      return (0);

   if (__shift > __total - __period - __ma_shift)
      return (0);

   switch (__ma_method)
   {
      case MODE_SMA :
      {
         __total = ArrayCopy(__Array, __array, 0, __shift + __ma_shift, __period);

         if (ArrayResize(__Buffer, __total) < 0)
            return (0);

         double __Sum = 0;
         int __Position = __total - 1;

         for (int __Index = 1; __Index < __period; __Index++, __Position--)
            __Sum += __Array[__Position];

         while (__Position >= 0)
         {
            __Sum += __Array[__Position];
            __Buffer[__Position] = __Sum / __period;
            __Sum -= __Array[__Position + __period - 1];
            __Position--;
         }

         return (__Buffer[0]);
      }
      case MODE_EMA :
      {
         if (ArrayResize(__Buffer, __total) < 0)
            return (0);

         double __pr = 2.0 / (__period + 1);
         int __Position = __total - 2;

         while (__Position >= 0)
         {
            if (__Position == __total - 2)
               __Buffer[__Position + 1] = __array[__Position + 1];

            __Buffer[__Position] = __array[__Position] * __pr + __Buffer[__Position + 1] * (1 - __pr);
            __Position--;
         }

         return (__Buffer[__shift + __ma_shift]);
      }
      case MODE_SMMA :
      {
         if (ArrayResize(__Buffer, __total) < 0)
            return (0);

         double __Sum = 0;
         int __Position = __total - __period;

         while (__Position >= 0)
         {
            if (__Position == __total - __period)
            {
               for (int __Index = 0, __Element = __Position; __Index < __period; __Index++, __Element++)
               {
                  __Sum += __array[__Element];
                  __Buffer[__Element] = 0;
               }
            }
            else
               __Sum = __Buffer[__Position + 1] * (__period - 1) + __array[__Position];

            __Buffer[__Position] = __Sum / __period;
            __Position--;
         }

         return (__Buffer[__shift + __ma_shift]);
      }
      case MODE_LWMA :
      {
         if (ArrayResize(__Buffer, __total) < 0)
            return (0);

         double __Sum = 0.0, __LinearSum = 0.0;
         double __Price;

         int __Index, __Weight = 0, __Position = __total - 1;

         for(__Index = 1; __Index <= __period; __Index++, __Position--)
         {
            __Price = __array[__Position];
            __Sum += __Price * __Index;
            __LinearSum += __Price;
            __Weight += __Index;
         }

         __Position++;
         __Index = __Position + __period;

         while (__Position >= 0)
         {
            __Buffer[__Position] = __Sum / __Weight;

            if (__Position == 0)
               break;

            __Position--;
            __Index--;
            __Price = __array[__Position];
            __Sum = __Sum - __LinearSum + __Price * __period;
            __LinearSum -= __array[__Index];
            __LinearSum += __Price;
         }

         return (__Buffer[__shift + __ma_shift]);
      }

      default:
         return (0);
   }

   return (0);
}

#define iMAOnArray iMAOnArrayMQL4

double iMACDMQL4(string __symbol, int __timeframe, int __fast_ema_period, int __slow_ema_period, int __signal_period, int __price, int __mode, int __shift)
{
   ENUM_TIMEFRAMES __TimeFrame = TFMigrate(__timeframe);
   ENUM_APPLIED_PRICE __AppliedPrice = PriceMigrate(__price);

   int __Handle = iMACD(__symbol, __TimeFrame, __fast_ema_period, __slow_ema_period, __signal_period, __AppliedPrice);

   if (__Handle < 0)
   {
      Print("The iMACD object was not created: Error ", GetLastError());

      return (-1);
   }
   else
      return (CopyBufferMQL4(__Handle, __mode, __shift));
}

#define iMACD iMACDMQL4

double iRSIMQL4(string __symbol, int __timeframe, int __period, int __price, int __shift)
{
   ENUM_TIMEFRAMES __TimeFrame = TFMigrate(__timeframe);
   ENUM_APPLIED_PRICE __AppliedPrice = PriceMigrate(__price);

   int __Handle = iRSI(__symbol, __TimeFrame, __period, __AppliedPrice);

   if (__Handle < 0)
   {
      Print("The iRSI object was not created: Error ", GetLastError());

      return (-1);
   }
   else
      return (CopyBufferMQL4(__Handle, 0, __shift));
}

#define iRSI iRSIMQL4

double iStdDevMQL4(string __symbol, int __timeframe, int __ma_period, int __ma_shift, int __method, int __price, int __shift)
{
   ENUM_TIMEFRAMES __TimeFrame = TFMigrate(__timeframe);
   ENUM_MA_METHOD __Method = MethodMigrate(__method);
   ENUM_APPLIED_PRICE __AppliedPrice = PriceMigrate(__price);

   int __Handle = iStdDev(__symbol, __TimeFrame, __ma_period, __ma_shift, __Method, __AppliedPrice);

   if (__Handle < 0)
   {
      Print("The iStdDev object was not created: Error ", GetLastError());

      return (-1);
   }
   else
      return (CopyBufferMQL4(__Handle, 0, __shift));
}

#define iStdDev iStdDevMQL4

double iStochasticMQL4(string __symbol, int __timeframe, int __Kperiod, int __Dperiod, int __slowing, int __method, int __price, int __mode, int __shift)
{
   ENUM_TIMEFRAMES __TimeFrame = TFMigrate(__timeframe);
   ENUM_MA_METHOD __Method = MethodMigrate(__method);
   ENUM_STO_PRICE __Price = StoFieldMigrate(__price);

   int __Handle = iStochastic(__symbol, __TimeFrame, __Kperiod, __Dperiod, __slowing, __Method, __Price);

   if (__Handle < 0)
   {
      Print("The iStochastic object was not created: Error ", GetLastError());

      return (-1);
   }
   else
      return (CopyBufferMQL4(__Handle, __mode, __shift));
}

#define iStochastic iStochasticMQL4

template <typename T>

void SwitchRow(T &__array[], const int __upper, const int __lower)
{
   const T __Saved = __array[__upper];

   __array[__upper] = __array[__lower];
   __array[__lower] = __Saved;
}

template <typename T>

bool ArraySortMQL4(T &__array[], int __count = WHOLE_ARRAY, int __start = 0, int __sort_dir = MODE_DESCEND)
{
   const bool __Result = ArraySort(__array);

   if (__Result && (__sort_dir == MODE_DESCEND))
   {
      const int __Size = ArraySize(__array);

      for (int __Index = (__Size >> 1) - 1; __Index >= 0; __Index--)
         SwitchRow(__array, __Index, __Size - 1 - __Index);
   }

   return (__Result);
}

template <typename T>

void SwitchRow(T &__array[][2], const int __upper, const int __lower)
{
   T __Saved[99];
   const int __Cells = ArrayRange(__array, 1);

   for (int __Cell = 0; __Cell < __Cells; __Cell++)
   {
      __Saved[__Cell] = __array[__upper][__Cell];
      __array[__upper][__Cell] = __array[__lower][__Cell];
      __array[__lower][__Cell] = __Saved[__Cell];
   }
}

template <typename T>

bool ArraySortMQL4(T &__array[][2], int __count = WHOLE_ARRAY, int __start = 0, int __sort_dir = MODE_DESCEND)
{
   const bool __Result = ArraySort(__array);

   if (__Result && (__sort_dir == MODE_DESCEND))
   {
      const int __Size = ArrayRange(__array, 0);

      for (int __Index = (__Size >> 1) - 1; __Index >= 0; __Index--)
         SwitchRow(__array, __Index, __Size - 1 - __Index);
   }

   return (__Result);
}

#define ArraySort ArraySortMQL4
#endif // __MQL5__

#ifndef __MQL5__
#include <StdLib.mqh>
#include <StdError.mqh>
#include <WinUser32.mqh>
#endif // __MQL5__



// ***
// *** Code from this point down is the actual Blessing strategy
// *** Use *ONLY* MQL4 coding style / commands
// ***

#define A    1                  //All (Basket + Hedge)
#define B    2                  //Basket
#define H    3                  //Hedge
#define T    4                  //Ticket
#define P    5                  //Pending

enum portChgs
{
   no_change = 0,              // No changes
   increase  = 1,              // Increase only
   any       = -1              // Increase / decrease
};

enum mktCond
{
   uptrend   = 0,              // Long only
   downtrend = 1,              // Short only
   range     = 2,              // Long & short
   automatic = 3               // Automatic
};

enum entType
{
   disable = 0,                // Disabled
   enable  = 1,                // Enabled
   reverse = 2                 // Reverse
};

enum crossType
{
   ic_disable = 0,             // Disabled
   ic_enabled = 1,             // Cross
   ic_cloud   = 2              // Cross Cloud Direction 
};

enum tFrame
{
   current = 0,                // Current
   m1      = 1,                // M1
   m5      = 2,                // M5
   m15     = 3,                // M15
   m30     = 4,                // M30
   h1      = 5,                // H1
   h4      = 6,                // H4
   d1      = 7,                // Daily
   w1      = 8,                // Weekly
   mn1     = 9                 // Monthly
};


//+-----------------------------------------------------------------+
//| External Parameters Set                                         |
//+-----------------------------------------------------------------+

input string             Version_3_9_6_23      = "EA Settings:";
input string             TradeComment          = "b3_v396.23";
input string             Notes                 = "";
input int                EANumber              = 1;                                                                         // EA Magic Number
input bool               EmergencyCloseAll     = false;                                                                     // *** CLOSE ALL NOW ***

input string             s1                    = "";                                                                        //.
input bool               ShutDown              = false;                                                                     // *** NO NEW TRADES ***
input string             s2                    = "";                                                                        //.

input string             LabelAcc              = "";                                                                        // ==   ACCOUNT SETTINGS   ==
input double             StopTradePercent      = 10;;                                                                       // Percentage of balance lost before trading stops

input bool               NanoAccount           = false;;                                                                    // Small Lot Account (0.01)
input string             s3                    = "... PortionPC > 100 forces effective balance to that amount (e.g. 1000)"; //.
input double             PortionPC             = 100;;                                                                      // Percentage of account you want to trade on this pair
input portChgs           PortionChange         = increase;;                                                                 // Permitted Portion change with open basket
// If basket open: 0=no Portion change;1=allow portion to increase; -1=allow increase and decrease
input double             MaxDDPercent          = 50;;                                                                       // Percent of portion for max drawdown level.
input double             MaxSpread             = 5;;                                                                        // Maximum allowed spread while placing trades
input bool               UseHolidayShutdown    = true;;                                                                     // Enable holiday shut-downs
input string             Holidays              = "18/12-01/01";;                                                            // Comma-separated holiday list (format: [day]/[mth]-[day]/[mth])
input bool               PlaySounds            = false;;                                                                    // Audible alerts
input string             AlertSound            = "Alert.wav";;                                                              // Alert sound

input string             eopb                  = "";                                                                        // -- Opt. with 'Open prices only' --
//put string             eopb0                   = "Filters out ticks";                                                     //. 
input bool               EnableOncePerBar      = true;
input bool               UseMinMarginPercent   = false;
input double             MinMarginPercent      = 1500;
input string             eopb1                 = "";                                                                        //. 

// ***********************************************************
input string			LabelTST				= "";                                                                        // ------   CUSTOM TESTER SETTINGS   ------
input double			TesterMinMarginPercent = 500;;
input int				TesterSelection = 1;;   // 1: Balance   2: (Balance^2 * min Drawdown * Trades)
input string			LabelTST2;				// .
// ***********************************************************
input bool               B3Traditional         = true;;                                                                     // Stop/Limits for entry if true, Buys/Sells if false
input mktCond            ForceMarketCond       = 3;;                                                                        // Market condition
// 0=uptrend 1=downtrend 2=range 3=automatic
input bool               UseAnyEntry           = false;;                                                                    // true = ANY entry can be used to open orders, false = ALL entries used to open orders

input string             LabelLS               = "";                                                                        // -----------   LOT SIZE   -----------
input bool               UseMM                 = true;;                                                                     // UseMM   (Money Management)
input double             LAF                   = 0.5;;                                                                      // Adjusts MM base lot for large accounts
input double             Lot                   = 0.01;;                                                                     // Starting lots if Money Management is off
input double             Multiplier            = 1.4;;                                                                      // Multiplier on each level

input string             LabelGS               = "";                                                                        // ------     GRID SETTINGS    ------
input bool               AutoCal               = false;;                                                                    // Auto calculation of TakeProfit and Grid size;
input tFrame             ATRTF                 = 0;;                                                                        // TimeFrame for ATR calculation
input int                ATRPeriods            = 21;;                                                                       // Number of periods for the ATR calculation
input double             GAF                   = 1.0;;                                                                      // Widens/Squishes Grid in increments/decrements of .1
input int                EntryDelay            = 2400;;                                                                     // Time Grid in seconds, avoid opening lots of levels in fast market
input double             EntryOffset           = 5;;                                                                        // In pips, used in conjunction with logic to offset first trade entry
input bool               UseSmartGrid          = true;;                                                                     // True = use RSI/MA calculation for next grid order

input string             LabelTS               = "";                                                                        // =====    TRADING    =====
input int                MaxTrades             = 15;;                                                                       // Maximum number of trades to place (stops placing orders when reaches MaxTrades)
input int                BreakEvenTrade        = 12;;                                                                       // Close All level, when reaches this level, doesn't wait for TP to be hit
input double             BEPlusPips            = 2;;                                                                        // Pips added to Break Even Point before BE closure
input bool               UseCloseOldest        = false;;                                                                    // True = will close the oldest open trade after CloseTradesLevel is reached
input int                CloseTradesLevel      = 5;;                                                                        // will start closing oldest open trade at this level
input bool               ForceCloseOldest      = true;;                                                                     // Will close the oldest trade whether it has potential profit or not
input int                MaxCloseTrades        = 4;;                                                                        // Maximum number of oldest trades to close
input double             CloseTPPips           = 10;;                                                                       // After Oldest Trades have closed, Forces Take Profit to BE +/- xx Pips
input double             ForceTPPips           = 0;;                                                                        // Force Take Profit to BE +/- xx Pips
input double             MinTPPips             = 0;;                                                                        // Ensure Take Profit is at least BE +/- xx Pips

input string             LabelES               = "";                                                                        // -----------     EXITS    -----------
input bool               MaximizeProfit        = false;;                                                                    // Turns on TP move and Profit Trailing Stop Feature
input double             ProfitSet             = 70;;                                                                       // Profit trailing stop: Lock in profit at set percent of Total Profit Potential
input double             MoveTP                = 30;;                                                                       // Moves TP this amount in pips
input int                TotalMoves            = 2;;                                                                        // Number of times you want TP to move before stopping movement
input bool               UseStopLoss           = false;;                                                                    // Use Stop Loss and/or Trailing Stop Loss
input double             SLPips                = 30;;                                                                       // Pips for fixed StopLoss from BE, 0=off
input double             TSLPips               = 10;;                                                                       // Pips for trailing stop loss from BE + TSLPips: +ve = fixed trail; -ve = reducing trail; 0=off
input double             TSLPipsMin            = 3;;                                                                        // Minimum trailing stop pips if using reducing TS
input bool               UsePowerOutSL         = false;;                                                                    // Transmits a SL in case of internet loss
input double             POSLPips              = 600;;                                                                      // Power Out Stop Loss in pips
input bool               UseFIFO               = false;;                                                                    // Close trades in FIFO order

input string             LabelEE               = "";                                                                        // ---------   EARLY EXITS   ---------
input bool               UseEarlyExit          = false;;                                                                    // Reduces ProfitTarget by a percentage over time and number of levels open
input double             EEStartHours          = 3;;                                                                        // Number of Hours to wait before EE over time starts
input bool               EEFirstTrade          = true;;                                                                     // true = StartHours from FIRST trade: false = StartHours from LAST trade
input double             EEHoursPC             = 0.5;;                                                                      // Percentage reduction per hour (0 = OFF)
input int                EEStartLevel          = 5;;                                                                        // Number of Open Trades before EE over levels starts
input double             EELevelPC             = 10;;                                                                       // Percentage reduction at each level (0 = OFF)
input bool               EEAllowLoss           = false;;                                                                    // true = Will allow the basket to close at a loss : false = Minimum profit is Break Even

input string             LabelAdv              = "";                                                                        //.
input string             LabelGrid             = "";                                                                        // ---------    GRID SIZE   ---------
input string             SetCountArray         = "4,4";;                                                                    // Specifies number of open trades in each block (separated by a comma)
input string             GridSetArray          = "25,50,100";;                                                              // Specifies number of pips away to issue limit order (separated by a comma)
input string             TP_SetArray           = "50,100,200";;                                                             // Take profit for each block (separated by a comma)

input string             LabelEST0             = "";                                                                        // .
input string             LabelEST              = "";                                                                        // ==  ENTRY PARAMETERS  ==
input string             LabelMA               = "";                                                                        // -------------     MA     -------------
input entType            MAEntry               = 1;;                                                                        // MA Entry
input tFrame             MA_TF                 = 0;;                                                                        // Time frame for MA calculation, r.f. ********
input int                MAPeriod              = 100;;                                                                      // Period of MA (H4 = 100, H1 = 400)
input double             MADistance            = 10;;                                                                       // Distance from MA to be treated as Ranging Market

input string             LabelCCI              = "";                                                                        // -------------     CCI     -------------
input entType            CCIEntry              = 0;;                                                                        // CCI Entry
input int                CCIPeriod             = 14;;                                                                       // Period for CCI calculation

input string             LabelBBS              = "";                                                                        // -----   BOLLINGER BANDS   -----
input entType            BollingerEntry        = 0;;                                                                        // Bollinger Entry
input int                BollPeriod            = 10;;                                                                       // Period for Bollinger
input double             BollDistance          = 10;;                                                                       // Up/Down spread
input double             BollDeviation         = 2.0;;                                                                      // Standard deviation multiplier for channel

input string             LabelIchi             = "";                                                                        // -----   ICHIMOKU CLOUD  -----
input entType            IchimokuEntry         = 0;                                                                         // Ichimoku Entry    
input tFrame             ICHI_TF               = 0;                                                                         // TF setting, but only current will work
input int                Tenkan_Sen            = 9;                                                                         // Tenkan
input int                Kijun_Sen             = 26;                                                                        // Kijun
input int                Senkou_Span           = 52;                                                                        // Senkou
input bool               useCloudBreakOut      = true;                                                                      // Trade if price breaks cloud / Kumo
input crossType          useTenken_Kijun_cross = 2;                                                                         // Trade if Tenken crosses Kijun
input bool               usePriceCrossTenken   = false;                                                                     // Trade if Price crosses Tenken
input bool               usePriceCrossKijun    = false;                                                                     // Trade if price crosses Kijun
input bool               useChikuspan          = false;                                                                     // Trade if chiku crosses Price
//put bool               useDistanceFromCloud  = false;
//put double             distanceFromCloud     = 0.0044;
input bool               useCloudSL            = false;                                                                     // Close all orders if price dives into the cloud/kumo

input string             LabelSto              = "";                                                                        // ---------   STOCHASTIC   --------
input entType            StochEntry            = 0;;                                                                        // Stochastic Entry
input int                BuySellStochZone      = 20;;                                                                       // Determines Overbought and Oversold Zones
input int                KPeriod               = 10;;                                                                       // Stochastic KPeriod
input int                DPeriod               = 2;;                                                                        // Stochastic DPeriod
input int                Slowing               = 2;;                                                                        // Stochastic Slowing

input string             LabelMACD             = "";                                                                        //  ------------    MACD    ------------
input entType            MACDEntry             = 0;;                                                                        // MACD Entry
input tFrame             MACD_TF               = 0;;                                                                        // Time frame for MACD calculation
// 0:Chart, 1:M1, 2:M5, 3:M15, 4:M30, 5:H1, 6:H4, 7:D1, 8:W1, 9:MN1
input int                FastPeriod            = 12;;                                                                       // MACD EMA Fast Period
input int                SlowPeriod            = 26;;                                                                       // MACD EMA Slow Period
input int                SignalPeriod          = 9;;                                                                        // MACD EMA Signal Period

#ifdef __MQL5__
input ENUM_APPLIED_PRICE MACDPrice             = PRICE_CLOSE;;                                                              // MACD Applied Price
#else
input ENUM_APPLIED_PRICE MACDPrice             = 0;;                                                                        // MACD Applied Price
#endif // __MQL5__
// 0=close, 1=open, 2=high, 3=low, 4=HL/2, 5=HLC/3 6=HLCC/4

input string             LabelSG               = "";                                                                        // ---------   SMART GRID   ---------
input tFrame             RSI_TF                = 3;;                                                                        // Timeframe for RSI calculation (should be lower than chart TF)
input int                RSI_Period            = 14;;                                                                       // Period for RSI calculation
#ifdef __MQL5__
input ENUM_APPLIED_PRICE RSI_Price             = PRICE_CLOSE;;                                                              // RSI Applied Price
#else
input ENUM_APPLIED_PRICE RSI_Price             = 0;;                                                                        // RSI Applied Price
#endif // __MQL5__
input int                RSI_MA_Period         = 10;;                                                                       // Period for MA of RSI calculation
input ENUM_MA_METHOD     RSI_MA_Method         = 0;;                                                                        // RSI MA Method


// ***********************************************************
input string             LabelHS0              = "";                                                                        //.
input string             LabelHS               = "";                                                                        // ------   HEDGE SETTINGS   -----
input string             HedgeSymbol           = "";;                                                                       // Enter the Symbol of the same/correlated pair EXACTLY as used by your broker.
input int                CorrPeriod            = 30;;                                                                       // Number of days for checking Hedge Correlation
input bool               UseHedge              = false;;                                                                    // Turns DD hedge on/off
input string             DDorLevel             = "DD";;                                                                     // DD = start hedge at set DD;Level = Start at set level
input double             HedgeStart            = 20;;                                                                       // DD Percent or Level at which Hedge starts
input double             hLotMult              = 0.8;;                                                                      // Hedge Lots = Open Lots * hLotMult
input double             hMaxLossPips          = 30;;                                                                       // DD Hedge maximum pip loss - also hedge trailing stop
input bool               hFixedSL              = false;;                                                                    // true = fixed SL at hMaxLossPips
input double             hTakeProfit           = 30;;                                                                       // Hedge Take Profit
input double             hReEntryPC            = 5;;                                                                        // Increase to HedgeStart to stop early re-entry of the hedge
input bool               StopTrailAtBE         = true;;                                                                     // True = Trailing Stop will stop at BE;False = Hedge will continue into profit
input bool               ReduceTrailStop       = true;;                                                                     // False = Trailing Stop is Fixed;True = Trailing Stop will reduce after BE is reached
// ***********************************************************

input string             LabelOS0              = "";                                                                        //.
input string             LabelOS               = "";                                                                        // ------------   OTHER   -----------
input bool               RecoupClosedLoss      = true;;                                                                     // true = Recoup any Hedge/CloseOldest losses: false = Use original profit target.
input int                Level                 = 7;;                                                                        // Largest Assumed Basket size.  Lower number = higher start lots
int                      slip                  = 99;
input bool               SaveStats             = false;;                                                                    // true = will save equity statistics
input int                StatsPeriod           = 3600;;                                                                     // seconds between stats entries - off by default
input bool               StatsInitialise       = true;;                                                                     // true for backtest - false for forward/live to ACCUMULATE equity traces

input string             LabelUE               = "";                                                                        // ------------   EMAIL   ------------
input bool               UseEmail              = false;
input string             LabelEDD              = "At what DD% would you like Email warnings (Max: 49, Disable: 0)?";        //.
input double             EmailDD1              = 20;
input double             EmailDD2              = 30;
input double             EmailDD3              = 40;

input string             LabelEH               = "Hours before DD timer resets";                                            //.
input double             EmailHours            = 24;                                                                        // Minimum number of hours between emails

input string             LabelDisplay          = "";                                                                        // ------------   DISPLAY   -----------
input bool               displayOverlay        = true;;                                                                     // Enable display
input bool               displayLogo           = true;;                                                                     // Display copyright and icon
input bool               displayCCI            = true;;                                                                     // Enable CCI display
input bool               displayLines          = true;;                                                                     // Show BE, TP and TS lines
input int                displayXcord          = 100;;                                                                      // Left / right offset
input int                displayYcord          = 30;;                                                                       // Up / down offset
input int                displayCCIxCord       = 10;;                                                                       // Moves CCI display left and right
input string             displayFont           = "Arial Bold";;                                                             // Display font
input int                displayFontSize       = 9;;                                                                        // Changes size of display characters
input int                displaySpacing        = 14;;                                                                       // Changes space between lines
input double             displayRatio          = 1.3;;                                                                      // Ratio to increase label width spacing
input color              displayColor          = DeepSkyBlue;;                                                              // default color of display characters
input color              displayColorProfit    = Green;;                                                                    // default color of profit display characters
input color              displayColorLoss      = Red;;                                                                      // default color of loss display characters
input color              displayColorFGnd      = Black;;                                                                    // default color of ForeGround Text display characters
input bool               HideIndicators        = true;;                                                                     // Hide test indicators
input bool               Debug                 = false;

input string             LabelGridOpt          = "";                                                                        // ----   GRID OPTIMIZATION   ----
input string             LabelOpt              = "These values can only be used while optimizing";                          //.
input bool               UseGridOpt            = false;;                                                                    // Set True in order to optimize the grid settings.
// These values will replace the normal SetCountArray,
// GridSetArray and TP_SetArray during optimization.
// The default values are the same as the normal array defaults
// REMEMBER:
// There must be one more value for GridArray and TPArray
// than there is for SetArray
input int                SetArray1             = 4;
input int                SetArray2             = 4;
input int                SetArray3             = 0;
input int                SetArray4             = 0;
input int                GridArray1            = 25;
input int                GridArray2            = 50;
input int                GridArray3            = 100;
input int                GridArray4            = 0;
input int                GridArray5            = 0;
input int                TPArray1              = 50;
input int                TPArray2              = 100;
input int                TPArray3              = 200;
input int                TPArray4              = 0;
input int                TPArray5              = 0;

//+-----------------------------------------------------------------+
//| Internal Parameters Set                                         |
//+-----------------------------------------------------------------+
int      ca;
int      Magic, hMagic;
int      CbT, CpT, ChT;   // Count basket Total,Count pending Total,Count hedge Total
double   Pip, hPip;
int      POSLCount;
double   SLbL;            // Stop Loss basket Last
int      Moves;
double   MaxDD;
double   SLb;             // Stop Loss
int      AccountType;
double   StopTradeBalance;
double   InitialAB;       // Initial Account Balance
bool     Testing, Visual;
bool     AllowTrading;
bool     EmergencyWarning;
double   MaxDDPer;
int      Error;
int      Set1Level, Set2Level, Set3Level, Set4Level;
int      EmailCount;
string   sTF;
datetime EmailSent;
int      GridArray[, 2];
double   Lots[], MinLotSize, LotStep;
int      LotDecimal, LotMult, MinMult;
bool     PendLot;
string   CS, UAE;
int      HolShutDown;
int      HolArray[, 4];
datetime HolFirst, HolLast, NextStats, OTbF;
double   RSI[];
int      Digit[6, 2], TF[10] = { 0, 1, 5, 15, 30, 60, 240, 1440, 10080, 43200 };

double   Email[3];
double   PbC, PhC, hDDStart, PbMax, PbMin, PhMax, PhMin, LastClosedPL, ClosedPips, SLh, hLvlStart, StatLowEquity, StatHighEquity;
datetime EETime;
int      hActive, EECount, TbF, CbC, CaL, FileHandle;
bool     TradesOpen, FileClosed, HedgeTypeDD, hThisChart, hPosCorr, dLabels, FirstRun;
string   FileName, ID, StatFile;
double   TPb, StopLevel, TargetPips, LbF, bTS, PortionBalance;
bool     checkResult;


//+-----------------------------------------------------------------+
//| Input Parameters Requiring Modifications To Entered Values      |
//+-----------------------------------------------------------------+
int     EANumber_;
double  EntryOffset_;
double  MoveTP_;
double  MADistance_;
double  BollDistance_;
double  POSLPips_;
double  hMaxLossPips_;
double  hTakeProfit_;
double  CloseTPPips_;
double  ForceTPPips_;
double  MinTPPips_;
double  BEPlusPips_;
double  SLPips_;
double  TSLPips_;
double  TSLPipsMin_;
string  HedgeSymbol_;
bool    UseHedge_;
double  HedgeStart_;
double  StopTradePercent_;
double  ProfitSet_;
double  EEHoursPC_;
double  EELevelPC_;
double  hReEntryPC_;
double  PortionPC_;
double  Lot_;
bool    Debug_;
mktCond ForceMarketCond_;
entType MAEntry_;
entType CCIEntry_;
entType BollingerEntry_;
entType IchimokuEntry_;
entType StochEntry_;
entType MACDEntry_;
int     MaxCloseTrades_;
double  Multiplier_;
string  SetCountArray_;
string  GridSetArray_;
string  TP_SetArray_;
bool    EmergencyCloseAll_;
bool    ShutDown_;


//+-----------------------------------------------------------------+
//| expert initialization function                                  |
//+-----------------------------------------------------------------+
int OnInit()
{
   HideTestIndicators(HideIndicators);

   EANumber_          = EANumber;
   EntryOffset_       = EntryOffset;
   MoveTP_            = MoveTP;
   MADistance_        = MADistance;
   BollDistance_      = BollDistance;
   POSLPips_          = POSLPips;
   hMaxLossPips_      = hMaxLossPips;
   hTakeProfit_       = hTakeProfit;
   CloseTPPips_       = CloseTPPips;
   ForceTPPips_       = ForceTPPips;
   MinTPPips_         = MinTPPips;
   BEPlusPips_        = BEPlusPips;
   SLPips_            = SLPips;
   TSLPips_           = TSLPips;
   TSLPipsMin_        = TSLPipsMin;
   HedgeSymbol_       = HedgeSymbol;
   UseHedge_          = UseHedge;
   HedgeStart_        = HedgeStart;
   StopTradePercent_  = StopTradePercent;
   ProfitSet_         = ProfitSet;
   EEHoursPC_         = EEHoursPC;
   EELevelPC_         = EELevelPC;
   hReEntryPC_        = hReEntryPC;
   PortionPC_         = PortionPC;

   if (PortionPC > 100)
      PortionPC_ = 100;                      // r.f.

   Lot_               = Lot;
   Debug_             = Debug;
   ForceMarketCond_   = ForceMarketCond;
   MAEntry_           = MAEntry;
   CCIEntry_          = CCIEntry;
   BollingerEntry_    = BollingerEntry;
   IchimokuEntry_     = IchimokuEntry;
   StochEntry_        = StochEntry;
   MACDEntry_         = MACDEntry;
   MaxCloseTrades_    = MaxCloseTrades;
   Multiplier_        = Multiplier;
   SetCountArray_     = SetCountArray;
   GridSetArray_      = GridSetArray;
   TP_SetArray_       = TP_SetArray;
   EmergencyCloseAll_ = EmergencyCloseAll;
   ShutDown_          = ShutDown;

   ChartSetInteger(0, CHART_SHOW_GRID, false);
   CS = "Waiting for next tick ."; // To display comments while testing, simply use CS = .... and
   Comment(CS);                    // it will be displayed by the line at the end of the start() block.
   CS           = "";
   Testing      = MQLInfoInteger(MQL_TESTER);
   Visual       = MQLInfoInteger(::MQL_VISUAL_MODE);
   FirstRun     = true;
   AllowTrading = true;

   if (EANumber_ < 1)
      EANumber_ = 1;

   if (Testing)
      EANumber_ = 0;

   Magic    = GenerateMagicNumber();
   hMagic   = JenkinsHash((string) Magic);
   FileName = "B3_" + (string) Magic + ".dat";

   if (Debug_)
   {
      Print("Magic Number: ", DTS(Magic, 0));
      Print("Hedge Number: ", DTS(hMagic, 0));
      Print("FileName: ", FileName);
   }

   Pip = Point;

   if (Digits % 2 == 1)
      Pip *= 10;

   if (NanoAccount)
      AccountType = 10;
   else
      AccountType = 1;

   MoveTP_       = ND(MoveTP_ * Pip, Digits);
   EntryOffset_  = ND(EntryOffset_ * Pip, Digits);
   MADistance_   = ND(MADistance_ * Pip, Digits);
   BollDistance_ = ND(BollDistance_ * Pip, Digits);
   POSLPips_     = ND(POSLPips_ * Pip, Digits);
   hMaxLossPips_ = ND(hMaxLossPips_ * Pip, Digits);
   hTakeProfit_  = ND(hTakeProfit_ * Pip, Digits);
   CloseTPPips_  = ND(CloseTPPips_ * Pip, Digits);
   ForceTPPips_  = ND(ForceTPPips_ * Pip, Digits);
   MinTPPips_    = ND(MinTPPips_ * Pip, Digits);
   BEPlusPips_   = ND(BEPlusPips_ * Pip, Digits);
   SLPips_       = ND(SLPips_ * Pip, Digits);
   TSLPips_      = ND(TSLPips * Pip, Digits);
   TSLPipsMin_   = ND(TSLPipsMin_ * Pip, Digits);

   if (UseHedge_)
   {
      if (HedgeSymbol_ == "")
         HedgeSymbol_ = Symbol();

      if (HedgeSymbol_ == Symbol())
         hThisChart = true;
      else
         hThisChart = false;

      hPip = MarketInfo(HedgeSymbol_, MODE_POINT);
      int hDigits = (int) MarketInfo(HedgeSymbol_, MODE_DIGITS);

      if (hDigits % 2 == 1)
         hPip *= 10;

      if (CheckCorr() > 0.9 || hThisChart)
         hPosCorr = true;
      else if (CheckCorr() < -0.9)
         hPosCorr = false;
      else
      {
         AllowTrading = false;
         UseHedge_    = false;
         Print("The specified Hedge symbol (", HedgeSymbol_, ") is not closely correlated with ", Symbol());
      }

      if (StringSubstr(DDorLevel, 0, 1) == "D" || StringSubstr(DDorLevel, 0, 1) == "d")
         HedgeTypeDD = true;
      else if (StringSubstr(DDorLevel, 0, 1) == "L" || StringSubstr(DDorLevel, 0, 1) == "l")
         HedgeTypeDD = false;
      else
         UseHedge_ = false;

      if (HedgeTypeDD)
      {
         HedgeStart_ /= 100;
         hDDStart     = HedgeStart_;
      }
   }

   StopTradePercent_ /= 100;
   ProfitSet_        /= 100;
   EEHoursPC_        /= 100;
   EELevelPC_        /= 100;
   hReEntryPC_       /= 100;
   PortionPC_        /= 100;

   InitialAB = AccountInfoDouble(ACCOUNT_BALANCE);
   // PortionPC now does double duty.  If > 100 serves as forced balance
   //  assuming the real balance is greater than PortionPC
   if (PortionPC > 100 && InitialAB > PortionPC)
   {
      InitialAB = PortionPC;
   }
   Print("*** Account balance: " + DTS(InitialAB, 0));
   StopTradeBalance = InitialAB * (1 - StopTradePercent_);

   if (Testing)
      ID = "B3Test.";
   else
      ID = DTS(Magic, 0) + ".";

   HideTestIndicators(true);

   MinLotSize = MarketInfo(Symbol(), MODE_MINLOT);

   if (MinLotSize > Lot_)
   {
      Print("Lot is less than minimum lot size permitted for this account");
      AllowTrading = false;
   }

   LotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double MinLot = MathMin(MinLotSize, LotStep);
   LotMult = (int) ND(MathMax(Lot_, MinLotSize) / MinLot, 0);
   MinMult = LotMult;
   Lot_    = MinLot;

   if (MinLot < 0.01)
      LotDecimal = 3;
   else if (MinLot < 0.1)
      LotDecimal = 2;
   else if (MinLot < 1)
      LotDecimal = 1;
   else
      LotDecimal = 0;

   FileHandle = FileOpen(FileName, FILE_BIN | FILE_READ);

   if (FileHandle != -1)
   {
      TbF = FileReadInteger(FileHandle, LONG_VALUE);
      FileClose(FileHandle);
      Error = GetLastError();

      if (OrderSelect(TbF, SELECT_BY_TICKET))
      {
         OTbF       = OrderOpenTime();
         LbF        = OrderLots();
         LotMult    = (int) MathMax(1, LbF / MinLot);
         PbC        = FindClosedPL(B);
         PhC        = FindClosedPL(H);
         TradesOpen = true;

         if (Debug_)
            Print(FileName, " File Read: ", TbF, " Lots: ", DTS(LbF, LotDecimal));
      }
      else
      {
         FileDelete(FileName);
         TbF   = 0;
         OTbF  = 0;
         LbF   = 0;
         Error = GetLastError();

         if (Error == ERR_NO_ERROR)
         {
            if (Debug_)
               Print(FileName, " File Deleted");
         }
         else
            Print("Error ", Error, " (", ErrorDescription(Error), ") deleting file ", FileName);
      }
   }

   GlobalVariableSet(ID + "LotMult", LotMult);

   if (Debug_)
      Print("MinLotSize: ", DTS(MinLotSize, 2), " LotStep: ", DTS(LotStep, 2), " MinLot: ", DTS(MinLot, 2), " StartLot: ", DTS(Lot_, 2), " LotMult: ", DTS(LotMult, 0), " Lot Decimal: ", DTS(LotDecimal, 0));

   EmergencyWarning = EmergencyCloseAll_;

   if (MQLInfoInteger(::MQL_OPTIMIZATION))
      Debug_ = false;

   if (UseAnyEntry)
      UAE = "||";
   else
      UAE = "&&";

   if (ForceMarketCond_ < 0 || ForceMarketCond_ > 3)
      ForceMarketCond_ = 3;

   if (MAEntry_ < 0 || MAEntry_ > 2)
      MAEntry_ = 0;

   if (CCIEntry_ < 0 || CCIEntry_ > 2)
      CCIEntry_ = 0;

   if (BollingerEntry_ < 0 || BollingerEntry_ > 2)
      BollingerEntry_ = 0;

   if (IchimokuEntry_ < 0 || IchimokuEntry_ > 2)
      IchimokuEntry_ = 0;

   if (StochEntry_ < 0 || StochEntry_ > 2)
      StochEntry_ = 0;

   if (MACDEntry_ < 0 || MACDEntry_ > 2)
      MACDEntry_ = 0;

   if (MaxCloseTrades_ == 0)
      MaxCloseTrades_ = MaxTrades;

   ArrayInitialize(Digit, 0);

   for (int Index = 0; Index < ArrayRange(Digit, 0); Index++)
   {
      if (Index > 0)
         Digit[Index, 0] = (int) MathPow(10, Index);

      Digit[Index, 1] = Index;

      if (Debug_)
         Print("Digit: ", Index, " [", Digit[Index, 0], ", ", Digit[Index, 1], "]");
   }

   LabelCreate();
   dLabels = false;

   //+-----------------------------------------------------------------+
   //| Set Lot Array                                                   |
   //+-----------------------------------------------------------------+
   ArrayResize(Lots, MaxTrades);

   for (int Index = 0; Index < MaxTrades; Index++)
   {
      if (Index == 0 || Multiplier_ < 1)
         Lots[Index] = Lot_;
      else
         Lots[Index] = ND(MathMax(Lots[Index - 1] * Multiplier_, Lots[Index - 1] + LotStep), LotDecimal);

      if (Debug_)
         Print("Lot Size for level ", DTS(Index + 1, 0), " : ", DTS(Lots[Index] * MathMax(LotMult, 1), LotDecimal));
   }

   if (Multiplier_ < 1)
      Multiplier_ = 1;

   //+-----------------------------------------------------------------+
   //| Set Grid and TP array                                           |
   //+-----------------------------------------------------------------+
   int GridSet = 0, GridTemp, GridTP, GridIndex = 0, GridLevel = 0, GridError = 0;

   if (!AutoCal)
   {
      ArrayResize(GridArray, MaxTrades);

      if (MQLInfoInteger(::MQL_OPTIMIZATION) && UseGridOpt)
      {
         if (SetArray1 > 0)
         {
            SetCountArray_ = DTS(SetArray1, 0);
            GridSetArray_  = DTS(GridArray1, 0);
            TP_SetArray_   = DTS(TPArray1, 0);
         }

         if (SetArray2 > 0 || (SetArray1 > 0 && GridArray2 > 0))
         {
            if (SetArray2 > 0)
               SetCountArray_ = SetCountArray_ + "," + DTS(SetArray2, 0);

            GridSetArray_ = GridSetArray_ + "," + DTS(GridArray2, 0);
            TP_SetArray_  = TP_SetArray_ + "," + DTS(TPArray2, 0);
         }

         if (SetArray3 > 0 || (SetArray2 > 0 && GridArray3 > 0))
         {
            if (SetArray3 > 0)
               SetCountArray_ = SetCountArray_ + "," + DTS(SetArray3, 0);

            GridSetArray_ = GridSetArray_ + "," + DTS(GridArray3, 0);
            TP_SetArray_  = TP_SetArray_ + "," + DTS(TPArray3, 0);
         }

         if (SetArray4 > 0 || (SetArray3 > 0 && GridArray4 > 0))
         {
            if (SetArray4 > 0)
               SetCountArray_ = SetCountArray_ + "," + DTS(SetArray4, 0);

            GridSetArray_ = GridSetArray_ + "," + DTS(GridArray4, 0);
            TP_SetArray_  = TP_SetArray_ + "," + DTS(TPArray4, 0);
         }

         if (SetArray4 > 0 && GridArray5 > 0)
         {
            GridSetArray_ = GridSetArray_ + "," + DTS(GridArray5, 0);
            TP_SetArray_  = TP_SetArray_ + "," + DTS(TPArray5, 0);
         }
      }

      while (GridIndex < MaxTrades)
      {
         if (StringFind(SetCountArray_, ",") == -1 && GridIndex == 0)
         {
            GridError = 1;
            break;
         }
         else
            GridSet = StrToInteger(StringSubstr(SetCountArray_, 0, StringFind(SetCountArray_, ",")));

         if (GridSet > 0)
         {
            SetCountArray_ = StringSubstr(SetCountArray_, StringFind(SetCountArray_, ",") + 1);
            GridTemp       = StrToInteger(StringSubstr(GridSetArray_, 0, StringFind(GridSetArray_, ",")));
            GridSetArray_  = StringSubstr(GridSetArray_, StringFind(GridSetArray_, ",") + 1);
            GridTP         = StrToInteger(StringSubstr(TP_SetArray_, 0, StringFind(TP_SetArray_, ",")));
            TP_SetArray_   = StringSubstr(TP_SetArray_, StringFind(TP_SetArray_, ",") + 1);
         }
         else
            GridSet = MaxTrades;

         if (GridTemp == 0 || GridTP == 0)
         {
            GridError = 2;
            break;
         }

         for (GridLevel = GridIndex; GridLevel <= MathMin(GridIndex + GridSet - 1, MaxTrades - 1); GridLevel++)
         {
            GridArray[GridLevel, 0] = GridTemp;
            GridArray[GridLevel, 1] = GridTP;

            if (Debug_)
               Print("GridArray ", (GridLevel + 1), ": [", GridArray[GridLevel, 0], ", ", GridArray[GridLevel, 1], "]");
         }

         GridIndex = GridLevel;
      }

      if (GridError > 0 || GridArray[0, 0] == 0 || GridArray[0, 1] == 0)
      {
         if (GridError == 1)
            Print("Grid Array Error. Each value should be separated by a comma.");
         else
            Print("Grid Array Error. Check that there is one more 'Grid' and 'TP' entry than there are 'Set' numbers - separated by commas.");

         AllowTrading = false;
      }
   }
   else
   {
      while (GridIndex < 4)
      {
         GridSet        = StrToInteger(StringSubstr(SetCountArray_, 0, StringFind(SetCountArray_, ",")));
         SetCountArray_ = StringSubstr(SetCountArray_, StringFind(SetCountArray_, DTS(GridSet, 0)) + 2);

         if (GridIndex == 0 && GridSet < 1)
         {
            GridError = 1;
            break;
         }

         if (GridSet > 0)
            GridLevel += GridSet;
         else if (GridLevel < MaxTrades)
            GridLevel = MaxTrades;
         else
            GridLevel = MaxTrades + 1;

         if (GridIndex == 0)
            Set1Level = GridLevel;
         else if (GridIndex == 1 && GridLevel <= MaxTrades)
            Set2Level = GridLevel;
         else if (GridIndex == 2 && GridLevel <= MaxTrades)
            Set3Level = GridLevel;
         else if (GridIndex == 3 && GridLevel <= MaxTrades)
            Set4Level = GridLevel;

         GridIndex++;
      }

      if (GridError == 1 || Set1Level == 0)
      {
         Print("Error setting up Grid Levels. Check that the SetCountArray contains valid numbers separated by commas.");
         AllowTrading = false;
      }
   }

   //+-----------------------------------------------------------------+
   //| Set holidays array                                              |
   //+-----------------------------------------------------------------+
   if (UseHolidayShutdown)
   {
      int    HolTemp = 0, NumHols, NumBS = 0, HolCounter = 0;
      string HolTempStr;

      // holidays are separated by commas
      // 18/12-01/01
      if (StringFind(Holidays, ",", 0) == -1)   // no comma if just one holiday
      {
         NumHols = 1;
      }
      else
      {
         NumHols = 1;
         while (HolTemp != -1)
         {
            HolTemp = StringFind(Holidays, ",", HolTemp + 1);
            if (HolTemp != -1)
               NumHols++;
         }
      }
      HolTemp = 0;
      while (HolTemp != -1)
      {
         HolTemp = StringFind(Holidays, "/", HolTemp + 1);
         if (HolTemp != -1)
            NumBS++;
      }

      if (NumBS != NumHols * 2)
      {
         Print("Holidays Error, number of back-slashes (", NumBS, ") should be equal to 2* number of Holidays (",
              NumHols, ", and separators should be commas.");
         AllowTrading = false;
      }
      else
      {
         HolTemp = 0;
         string hol = Holidays;
         ArrayResize(HolArray, NumHols);

         while (HolTemp != -1)
         {
            string a = StringSubstr(hol, 0, StringFind(hol, ",", HolTemp));
            StringTrimRight(a);

            if (HolTemp == 0)
            {
               StringTrimLeft(a);
               HolTempStr = a;
            }
            else
            {
               string b = StringSubstr(hol, HolTemp + 1, StringFind(hol, ",", HolTemp + 1) - StringFind(hol, ",", HolTemp) - 1);
               StringTrimRight(b);
               StringTrimLeft(b);
               HolTempStr = b;
            }

            HolTemp = StringFind(hol, ",", HolTemp + 1);
            HolArray[HolCounter, 0] = (int)(StringSubstr(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), StringFind(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), "/") + 1));
            HolArray[HolCounter, 1] = (int)(StringSubstr(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), 0, StringFind(StringSubstr(HolTempStr, 0, StringFind(HolTempStr, "-", 0)), "/")));
            HolArray[HolCounter, 2] = (int)(StringSubstr(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), StringFind(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), "/") + 1));
            HolArray[HolCounter, 3] = (int)(StringSubstr(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), 0, StringFind(StringSubstr(HolTempStr, StringFind(HolTempStr, "-", 0) + 1), "/")));
            HolCounter++;
         }
      }

      for (HolTemp = 0; HolTemp < HolCounter; HolTemp++)
      {
         datetime Start1, Start2;
         int      Temp0, Temp1, Temp2, Temp3;
         for (int Item1 = HolTemp + 1; Item1 < HolCounter; Item1++)
         {
            Start1 = (datetime) HolArray[HolTemp, 0] * 100 + HolArray[HolTemp, 1];
            Start2 = (datetime) HolArray[Item1, 0] * 100 + HolArray[Item1, 1];
            if (Start1 > Start2)
            {
               Temp0                = HolArray[Item1, 0];
               Temp1                = HolArray[Item1, 1];
               Temp2                = HolArray[Item1, 2];
               Temp3                = HolArray[Item1, 3];
               HolArray[Item1, 0]   = HolArray[HolTemp, 0];
               HolArray[Item1, 1]   = HolArray[HolTemp, 1];
               HolArray[Item1, 2]   = HolArray[HolTemp, 2];
               HolArray[Item1, 3]   = HolArray[HolTemp, 3];
               HolArray[HolTemp, 0] = Temp0;
               HolArray[HolTemp, 1] = Temp1;
               HolArray[HolTemp, 2] = Temp2;
               HolArray[HolTemp, 3] = Temp3;
            }
         }
      }

      if (Debug_)
      {
         for (HolTemp = 0; HolTemp < HolCounter; HolTemp++)
            Print("Holidays - From: ", HolArray[HolTemp, 1], "/", HolArray[HolTemp, 0], " - ",
                 HolArray[HolTemp, 3], "/", HolArray[HolTemp, 2]);
      }
   }
   //+-----------------------------------------------------------------+
   //| Set email parameters                                            |
   //+-----------------------------------------------------------------+
   if (UseEmail)
   {
      if (Period() == 43200)
         sTF = "MN1";
      else if (Period() == 10800)
         sTF = "W1";
      else if (Period() == 1440)
         sTF = "D1";
      else if (Period() == 240)
         sTF = "H4";
      else if (Period() == 60)
         sTF = "H1";
      else if (Period() == 30)
         sTF = "M30";
      else if (Period() == 15)
         sTF = "M15";
      else if (Period() == 5)
         sTF = "M5";
      else if (Period() == 1)
         sTF = "M1";

      Email[0] = MathMax(MathMin(EmailDD1, MaxDDPercent - 1), 0) / 100;
      Email[1] = MathMax(MathMin(EmailDD2, MaxDDPercent - 1), 0) / 100;
      Email[2] = MathMax(MathMin(EmailDD3, MaxDDPercent - 1), 0) / 100;
      ArraySort(Email, WHOLE_ARRAY, 0, MODE_ASCEND);

      for (int z = 0; z <= 2; z++)
      {
         for (int Index = 0; Index <= 2; Index++)
         {
            if (Email[Index] == 0)
            {
               Email[Index]     = Email[Index + 1];
               Email[Index + 1] = 0;
            }
         }

         if (Debug_)
            Print("Email [", (z + 1), "] : ", Email[z]);
      }
   }
   //+-----------------------------------------------------------------+
   //| Set SmartGrid parameters                                        |
   //+-----------------------------------------------------------------+
   if (UseSmartGrid)
   {
      ArrayResize(RSI, RSI_Period + RSI_MA_Period);
      ArraySetAsSeries(RSI, true);
   }
   //+---------------------------------------------------------------+
   //| Initialize Statistics                                         |
   //+---------------------------------------------------------------+
   if (SaveStats)
   {
      StatFile  = "B3" + Symbol() + "_" + (string) Period() + "_" + (string) EANumber_ + ".csv";
      NextStats = TimeCurrent();
      // new PortionPC behavior ... r.f.
      double temp_account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
      if (PortionPC > 100 && temp_account_balance > PortionPC)
      {
         Stats(StatsInitialise, false, PortionPC, 0);
      }
      else
      {
         Stats(StatsInitialise, false, temp_account_balance * PortionPC_, 0);
      }
   }

   return(0);
}

//+-----------------------------------------------------------------+
//| expert deinitialization function                                |
//+-----------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (!Testing)
   {
      for (int i = ObjectsTotal(ChartID()); i >= 0; i--)
      {
         if (StringFind(ObjectName(ChartID(), i), "B3") != -1)
            ObjectDelete(ChartID(), ObjectName(ChartID(), i));
      }
   }

   switch (UninitializeReason())
   {
   case REASON_REMOVE:
   case REASON_CHARTCLOSE:
   case REASON_CHARTCHANGE:
      if (CpT > 0)
      {
         while (CpT > 0)
            CpT -= ExitTrades(P, displayColorLoss, "Blessing Removed");
      }

      GlobalVariablesDeleteAll(ID);
   case REASON_RECOMPILE:
   case REASON_PARAMETERS:
   case REASON_ACCOUNT:
      if (!Testing)
         LabelDelete();

      Comment("");
   }
}


datetime OncePerBarTime = 0;

//+-----------------------------------------------------------------+
//| Once Per Bar function    returns true once per bar              |
//+-----------------------------------------------------------------+
bool OncePerBar()
{
   if (!EnableOncePerBar || FirstRun)
      return(true);           // always return true if disabled

   if (OncePerBarTime != iTime(_Symbol, Period(), 0))
   {
      OncePerBarTime = iTime(_Symbol, Period(), 0);
      return(true);           // true, our first time this bar
   }

   return(false);
}

double LbT = 0;                 // total lots out

double previous_stop_trade_amount;
double stop_trade_amount;


//+-----------------------------------------------------------------+
//| expert start function                                           |
//+-----------------------------------------------------------------+
void OnTick()
{
   int      CbB  = 0;                    // Count buy
   int      CbS  = 0;                    // Count sell
   int      CpBL = 0;                    // Count buy limit
   int      CpSL = 0;                    // Count sell limit
   int      CpBS = 0;                    // Count buy stop
   int      CpSS = 0;                    // Count sell stop
   double   LbB  = 0;                    // Count buy lots
   double   LbS  = 0;                    // Count sell lots
// double   LbT          =0;     // total lots out
   double   OPpBL     = 0;               // Buy limit open price
   double   OPpSL     = 0;               // Sell limit open price
   double   SLbB      = 0;               // stop losses are set to zero if POSL off
   double   SLbS      = 0;               // stop losses are set to zero if POSL off
   double   BCb       = 0, BCh = 0, BCa; // Broker costs (swap + commission)
   double   ProfitPot = 0;               // The Potential Profit of a basket of Trades
   double   PipValue, PipVal2, ASK, BID;
   double   OrderLot;
   double   OPbL = 0, OPhO = 0; // last open price
   datetime OTbL = 0;           // last open time
   datetime OTbO = 0, OThO = 0;
   double   g2, tp2, Entry_, RSI_MA = 0, LhB = 0, LhS = 0, LhT, OPbO = 0;
   int      Ticket = 0, ChB = 0, ChS = 0, IndEntry = 0, TbO = 0, ThO = 0;
   double   Pb     = 0, Ph = 0, PaC = 0, PbPips = 0, PbTarget = 0, DrawDownPC = 0, BEb = 0, BEh = 0, BEa = 0;
   bool     BuyMe  = false, SellMe = false, Success, SetPOSL;
   string   IndicatorUsed;
   double   EEpc  = 0, OPbN = 0, nLots = 0;
   double   bSL   = 0, TPa = 0, TPbMP = 0;
   int      Trend = 0;
   string   ATrend;
   double   cci_01 = 0, cci_02 = 0, cci_03 = 0, cci_04 = 0;
   double   cci_11 = 0, cci_12 = 0, cci_13 = 0, cci_14 = 0;


   //+-----------------------------------------------------------------+
   //| Count Open Orders, Lots and Totals                              |
   //+-----------------------------------------------------------------+
   PipVal2   = MarketInfo(Symbol(), MODE_TICKVALUE) / MarketInfo(Symbol(), MODE_TICKSIZE);
   PipValue  = PipVal2 * Pip;
   StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   ASK       = ND(MarketInfo(Symbol(), MODE_ASK), (int) MarketInfo(Symbol(), MODE_DIGITS));
   BID       = ND(MarketInfo(Symbol(), MODE_BID), (int) MarketInfo(Symbol(), MODE_DIGITS));

   if (ASK == 0 || BID == 0)
      return;

   for (int Order = 0; Order < OrdersTotal(); Order++)
   {
      if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
         continue;

      int Type = OrderType();

      if (OrderMagicNumber() == hMagic)
      {
         Ph  += OrderProfit();
         BCh += OrderSwap() + OrderCommission();
         BEh += OrderLots() * OrderOpenPrice();

         if (OrderOpenTime() < OThO || OThO == 0)
         {
            OThO = OrderOpenTime();
            ThO  = OrderTicket();
            OPhO = OrderOpenPrice();
         }

         if (Type == OP_BUY)
         {
            ChB++;
            LhB += OrderLots();
         }
         else if (Type == OP_SELL)
         {
            ChS++;
            LhS += OrderLots();
         }

         continue;
      }

      if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol())
         continue;

      if (OrderTakeProfit() > 0)
         ModifyOrder(OrderOpenPrice(), OrderStopLoss());

      if (Type <= OP_SELL)
      {
         Pb  += OrderProfit();
         BCb += OrderSwap() + OrderCommission();
         BEb += OrderLots() * OrderOpenPrice();

         if (OrderOpenTime() >= OTbL)
         {
            OTbL = OrderOpenTime();
            OPbL = OrderOpenPrice();
         }

         if (OrderOpenTime() < OTbF || TbF == 0)
         {
            OTbF = OrderOpenTime();
            TbF  = OrderTicket();
            LbF  = OrderLots();
         }

         if (OrderOpenTime() < OTbO || OTbO == 0)
         {
            OTbO = OrderOpenTime();
            TbO  = OrderTicket();
            OPbO = OrderOpenPrice();
         }

         if (UsePowerOutSL && ((POSLPips_ > 0 && OrderStopLoss() == 0) || (POSLPips_ == 0 && OrderStopLoss() > 0)))
            SetPOSL = true;

         if (Type == OP_BUY)
         {
            CbB++;
            LbB += OrderLots();
            continue;
         }
         else
         {
            CbS++;
            LbS += OrderLots();
            continue;
         }
      }
      else
      {
         if (Type == OP_BUYLIMIT)
         {
            CpBL++;
            OPpBL = OrderOpenPrice();
            continue;
         }
         else if (Type == OP_SELLLIMIT)
         {
            CpSL++;
            OPpSL = OrderOpenPrice();
            continue;
         }
         else if (Type == OP_BUYSTOP)
            CpBS++;
         else
            CpSS++;
      }
   }

   CbT = CbB + CbS;
   LbT = LbB + LbS;
   Pb  = ND(Pb + BCb, 2);
   ChT = ChB + ChS;
   LhT = LhB + LhS;
   Ph  = ND(Ph + BCh, 2);
   CpT = CpBL + CpSL + CpBS + CpSS;
   BCa = BCb + BCh;

   //+-----------------------------------------------------------------+
   //| Calculate Min/Max Profit and Break Even Points                  |
   //+-----------------------------------------------------------------+
   if (LbT > 0)
   {
      BEb = ND(BEb / LbT, Digits);

      if (BCa < 0)            // broker costs
      {
         if (LbB - LbS != 0) // r.f., fix divide by zero on following line
            BEb -= ND(BCa / PipVal2 / (LbB - LbS), Digits);
      }

      if (Pb > PbMax || PbMax == 0)
         PbMax = Pb;

      if (Pb < PbMin || PbMin == 0)
         PbMin = Pb;

      if (!TradesOpen)
      {
         FileHandle = FileOpen(FileName, FILE_BIN | FILE_WRITE);

         if (FileHandle > -1)
         {
            FileWriteInteger(FileHandle, TbF);
            FileClose(FileHandle);
            TradesOpen = true;

            if (Debug_)
               Print(FileName, " File Written: ", TbF);
         }
      }
   }
   else if (TradesOpen)
   {
      TPb        = 0;
      PbMax      = 0;
      PbMin      = 0;
      OTbF       = 0;
      TbF        = 0;
      LbF        = 0;
      PbC        = 0;
      PhC        = 0;
      PaC        = 0;
      ClosedPips = 0;
      CbC        = 0;
      CaL        = 0;
      bTS        = 0;

      if (HedgeTypeDD)
         hDDStart = HedgeStart_;
      else
         hLvlStart = HedgeStart_;

      EmailCount = 0;
      EmailSent  = 0;
      FileHandle = FileOpen(FileName, FILE_BIN | FILE_READ);

      if (FileHandle > -1)
      {
         FileClose(FileHandle);
         Error = GetLastError();
         FileDelete(FileName);
         Error = GetLastError();

         if (Error == ERR_NO_ERROR)
         {
            if (Debug_)
               Print(FileName + " File Deleted");

            TradesOpen = false;
         }
         else
            Print("Error ", Error, " {", ErrorDescription(Error), ") deleting file ", FileName);
      }
      else
         TradesOpen = false;
   }

   if (LhT > 0)
   {
      BEh = ND(BEh / LhT, Digits);

      if (Ph > PhMax || PhMax == 0)
         PhMax = Ph;

      if (Ph < PhMin || PhMin == 0)
         PhMin = Ph;
   }
   else
   {
      PhMax = 0;
      PhMin = 0;
      SLh   = 0;
   }

   //+-----------------------------------------------------------------+
   //| Check if trading is allowed                                     |
   //+-----------------------------------------------------------------+
   if (CbT == 0 && ChT == 0 && ShutDown_)
   {
      if (CpT > 0)
      {
         ExitTrades(P, displayColorLoss, "Blessing is shutting down");

         return;
      }

      if (AllowTrading)
      {
         Print("Blessing has shut down. Set ShutDown = 'false' to resume trading");

         if (PlaySounds)
            PlaySound(AlertSound);

         AllowTrading = false;
      }

      if (UseEmail && EmailCount < 4 && !Testing)
      {
         SendMail("Blessing EA", "Blessing has shut down on " + Symbol() + " " + sTF + ". To resume trading, change ShutDown to false.");
         Error = GetLastError();

         if (Error > 0)
            Print("Error ", Error, " (", ErrorDescription(Error), ") sending email");
         else
            EmailCount = 4;
      }
   }

   static bool LDelete;

   if (!AllowTrading)
   {
      if (!LDelete)
      {
         LDelete = true;
         LabelDelete();

         if (ObjectFind("B3LStop") == -1)
         {
            CreateLabel("B3LStop", "Trading has stopped on this pair.", 10, CORNER_LEFT_UPPER, 0, 3, displayColorLoss);
            CreateLabel("B3LLogo", "I", 27, CORNER_RIGHT_LOWER, 10, 10, Red, "Wingdings");   // I = open hand (stop)
         }

         string Tab = "Tester Journal";

         if (!Testing)
            Tab = "Terminal Experts";

         if (ObjectFind("B3LExpt") == -1)
            CreateLabel("B3LExpt", "Check the " + Tab + " tab for the reason.", 10, CORNER_LEFT_UPPER, 0, 6, displayColorLoss);

         if (ObjectFind("B3LResm") == -1)
            CreateLabel("B3LResm", "Reset Blessing to resume trading.", 10, CORNER_LEFT_UPPER, 0, 9, displayColorLoss);
      }

      return;
   }
   else
   {
      LDelete = false;
      ObjDel("B3LStop");
      ObjDel("B3LExpt");
      ObjDel("B3LResm");
   }

   //+-----------------------------------------------------------------+
   //| Calculate Drawdown and Equity Protection                        |
   //+-----------------------------------------------------------------+
   double temp_account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double NewPortionBalance;
   if (PortionPC > 100 && temp_account_balance > PortionPC)
   {
      NewPortionBalance = ND(PortionPC, 2);
   }
   else
   {
      NewPortionBalance = ND(temp_account_balance * PortionPC_, 2);
   }

   if (CbT == 0 || PortionChange < 0 || (PortionChange > 0 && NewPortionBalance > PortionBalance))
      PortionBalance = NewPortionBalance;

   if (Pb + Ph < 0)                               // *******************************
      DrawDownPC = -(Pb + Ph) / PortionBalance;  // opb
   if (!FirstRun && DrawDownPC >= MaxDDPercent / 100)
   {
      ExitTrades(A, displayColorLoss, "Equity StopLoss Reached");

      if (PlaySounds)
         PlaySound(AlertSound);

      return;
   }                                   // ***********************************
   if (-(Pb + Ph) > MaxDD)
      MaxDD = -(Pb + Ph);

   MaxDDPer = MathMax(MaxDDPer, DrawDownPC * 100);
   // ***********************************************************
   // ***********************************************************

   if (SaveStats)
      Stats(false, TimeCurrent() < NextStats, PortionBalance, Pb + Ph);

   //+-----------------------------------------------------------------+
   //| Calculate  Stop Trade Percent                                   |
   //+-----------------------------------------------------------------+
   double StepAB = InitialAB * (1 + StopTradePercent_);
   double StepSTB;
   double temp_ab = AccountInfoDouble(ACCOUNT_BALANCE);
   if (PortionPC > 100 && temp_ab > PortionPC)
   {
      StepSTB = PortionPC * (1 - StopTradePercent_);
   }
   else
   {
      StepSTB = temp_ab * (1 - StopTradePercent_);
   }
   double NextISTB = StepAB * (1 - StopTradePercent_);

   if (StepSTB > NextISTB)
   {
      InitialAB        = StepAB;
      StopTradeBalance = StepSTB;
   }
   // Stop Trade Amount:
   double InitialAccountMultiPortion = StopTradeBalance * PortionPC_;
   stop_trade_amount = InitialAccountMultiPortion;

   if (PortionBalance < InitialAccountMultiPortion)
   {
      if (CbT == 0)
      {
         AllowTrading = false;

         if (PlaySounds)
            PlaySound(AlertSound);

         Print("Portion Balance dropped below stop-trading percentage");
         MessageBox("Reset required - account balance dropped below stop-trading percentage on " + DTS((int)::AccountInfoInteger(::ACCOUNT_LOGIN), 0) + " " + Symbol() + " " + (string) Period(), "Blessing 3: Warning", 48);

         return;
      }
      else if (!ShutDown_ && !RecoupClosedLoss)
      {
         ShutDown_ = true;

         if (PlaySounds)
            PlaySound(AlertSound);

         Print("Portion Balance dropped below stop-trading percentage");

         return;
      }
   }

   // **********************************************************************
   // **********************************************************************

   //+-----------------------------------------------------------------+
   //| Calculation of Trend Direction                                  |
   //+-----------------------------------------------------------------+
   double ima_0 = iMA(Symbol(), MA_TF, MAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);

   if (ForceMarketCond_ == 3)
   {
      if (BID > ima_0 + MADistance_)
         Trend = 0;
      else if (ASK < ima_0 - MADistance_)
         Trend = 1;
      else
         Trend = 2;
   }
   else
   {
      Trend = ForceMarketCond_;

      if (Trend != 0 && BID > ima_0 + MADistance_)
         ATrend = "U";

      if (Trend != 1 && ASK < ima_0 - MADistance_)
         ATrend = "D";

      if (Trend != 2 && (BID < ima_0 + MADistance_ && ASK > ima_0 - MADistance_))
         ATrend = "R";
   }

   if (OncePerBar())   // **************************************************

   {   //+-----------------------------------------------------------------+
      //| Hedge/Basket/ClosedTrades Profit Management                     |
      //+-----------------------------------------------------------------+
      double Pa = Pb;
      PaC = PbC + PhC;

      if (hActive == 1 && ChT == 0)
      {
         PhC     = FindClosedPL(H);
         hActive = 0;

         return;
      }
      else if (hActive == 0 && ChT > 0)
         hActive = 1;

      if (LbT > 0)
      {
         if (PbC > 0 || (PbC < 0 && RecoupClosedLoss))
         {
            Pa  += PbC;
            BEb -= ND(PbC / PipVal2 / (LbB - LbS), Digits);
         }

         if (PhC > 0 || (PhC < 0 && RecoupClosedLoss))
         {
            Pa  += PhC;
            BEb -= ND(PhC / PipVal2 / (LbB - LbS), Digits);
         }

         if (Ph > 0 || (Ph < 0 && RecoupClosedLoss))
            Pa += Ph;
      }
      //+-----------------------------------------------------------------+
      //| Close oldest open trade after CloseTradesLevel reached          |
      //+-----------------------------------------------------------------+
      if (UseCloseOldest && CbT >= CloseTradesLevel && CbC < MaxCloseTrades_)
      {
         if (!FirstRun && TPb > 0 && (ForceCloseOldest || (CbB > 0 && OPbO > TPb) || (CbS > 0 && OPbO < TPb)))
         {
            int Index = ExitTrades(T, DarkViolet, "Close Oldest Trade", TbO);

            if (Index == 1)
            {
               if (OrderSelect(TbO, SELECT_BY_TICKET))     // yoh check return
               {
                  PbC += OrderProfit() + OrderSwap() + OrderCommission();
                  ca   = 0;
                  CbC++;
               }
               else
                  Print("OrderSelect error ", GetLastError());    // yoh

               return;
            }
         }
      }
      //+-----------------------------------------------------------------+
      //| ATR for Auto Grid Calculation and Grid Set Block                |
      //+-----------------------------------------------------------------+
      double GridTP;

      if (AutoCal)
      {
         double GridATR = iATR(NULL, TF[ATRTF], ATRPeriods, 0) / Pip;

         if ((CbT + CbC > Set4Level) && Set4Level > 0)
         {
            g2  = GridATR * 12;     //GS*2*2*2*1.5
            tp2 = GridATR * 18;     //GS*2*2*2*1.5*1.5
         }
         else if ((CbT + CbC > Set3Level) && Set3Level > 0)
         {
            g2  = GridATR * 8;      //GS*2*2*2
            tp2 = GridATR * 12;     //GS*2*2*2*1.5
         }
         else if ((CbT + CbC > Set2Level) && Set2Level > 0)
         {
            g2  = GridATR * 4;      //GS*2*2
            tp2 = GridATR * 8;      //GS*2*2*2
         }
         else if ((CbT + CbC > Set1Level) && Set1Level > 0)
         {
            g2  = GridATR * 2;      //GS*2
            tp2 = GridATR * 4;      //GS*2*2
         }
         else
         {
            g2  = GridATR;
            tp2 = GridATR * 2;
         }

         GridTP = GridATR * 2;
      }
      else
      {
         int Index = (int) MathMax(MathMin(CbT + CbC, MaxTrades) - 1, 0);
         g2     = GridArray[Index, 0];
         tp2    = GridArray[Index, 1];
         GridTP = GridArray[0, 1];
      }

      g2     = ND(MathMax(g2 * GAF * Pip, Pip), Digits);
      tp2    = ND(tp2 * GAF * Pip, Digits);
      GridTP = ND(GridTP * GAF * Pip, Digits);

      //+-----------------------------------------------------------------+
      //| Money Management and Lot size coding                            |
      //+-----------------------------------------------------------------+
      if (UseMM)
      {
         if (CbT > 0)        // Count basket Total
         {
            if (GlobalVariableCheck(ID + "LotMult"))
               LotMult = (int) GlobalVariableGet(ID + "LotMult");

            if (LbF != LotSize(Lots[0] * LotMult))
            {
               LotMult = (int) (LbF / Lots[0]);
               GlobalVariableSet(ID + "LotMult", LotMult);
               Print("LotMult reset to " + DTS(LotMult, 0));
            }
         }
         else if (CbT == 0)
         {
            double Contracts, Factor, Lotsize;
            Contracts = PortionBalance / 10000;     // MarketInfo(Symbol(), MODE_LOTSIZE); ??

            if (Multiplier_ <= 1)
               Factor = Level;
            else
               Factor = (MathPow(Multiplier_, Level) - Multiplier_) / (Multiplier_ - 1);

            Lotsize = LAF * AccountType * Contracts / (1 + Factor);
            LotMult = (int) MathMax(MathFloor(Lotsize / Lot_), MinMult);
            GlobalVariableSet(ID + "LotMult", LotMult);
         }
      }
      else if (CbT == 0)
         LotMult = MinMult;

      //+-----------------------------------------------------------------+
      //| Calculate Take Profit                                           |
      //+-----------------------------------------------------------------+
      static double BCaL, BEbL;
      nLots = LbB - LbS;

      if (CbT > 0 && (TPb == 0 || CbT + ChT != CaL || BEbL != BEb || BCa != BCaL || FirstRun))
      {
         string sCalcTP = "Set New TP:  BE: " + DTS(BEb, Digits);
         double NewTP   = 0, BasePips;
         CaL  = CbT + ChT;
         BCaL = BCa;
         BEbL = BEb;
         if (nLots == 0)
         {
            nLots = 1;
         }                   // divide by zero error fix ... r.f.
         BasePips = ND(Lot_ * LotMult * GridTP * (CbT + CbC) / nLots, Digits);

         if (CbB > 0)
         {
            if (ForceTPPips_ > 0)
            {
               NewTP   = BEb + ForceTPPips_;
               sCalcTP = sCalcTP + " +Force TP (" + DTS(ForceTPPips_, Digits) + ") ";
            }
            else if (CbC > 0 && CloseTPPips_ > 0)
            {
               NewTP   = BEb + CloseTPPips_;
               sCalcTP = sCalcTP + " +Close TP (" + DTS(CloseTPPips_, Digits) + ") ";
            }
            else if (BEb + BasePips > OPbL + tp2)
            {
               NewTP   = BEb + BasePips;
               sCalcTP = sCalcTP + " +Base TP: (" + DTS(BasePips, Digits) + ") ";
            }
            else
            {
               NewTP   = OPbL + tp2;
               sCalcTP = sCalcTP + " +Grid TP: (" + DTS(tp2, Digits) + ") ";
            }

            if (MinTPPips_ > 0)
            {
               NewTP   = MathMax(NewTP, BEb + MinTPPips_);
               sCalcTP = sCalcTP + " >Minimum TP: ";
            }

            NewTP += MoveTP_ * Moves;

            if (BreakEvenTrade > 0 && CbT + CbC >= BreakEvenTrade)
            {
               NewTP   = BEb + BEPlusPips_;
               sCalcTP = sCalcTP + " >BreakEven: (" + DTS(BEPlusPips_, Digits) + ") ";
            }

            sCalcTP = (sCalcTP + "Buy: TakeProfit: ");
         }
         else if (CbS > 0)
         {
            if (ForceTPPips_ > 0)
            {
               NewTP   = BEb - ForceTPPips_;
               sCalcTP = sCalcTP + " -Force TP (" + DTS(ForceTPPips_, Digits) + ") ";
            }
            else if (CbC > 0 && CloseTPPips_ > 0)
            {
               NewTP   = BEb - CloseTPPips_;
               sCalcTP = sCalcTP + " -Close TP (" + DTS(CloseTPPips_, Digits) + ") ";
            }
            else if (BEb + BasePips < OPbL - tp2)
            {
               NewTP   = BEb + BasePips;
               sCalcTP = sCalcTP + " -Base TP: (" + DTS(BasePips, Digits) + ") ";
            }
            else
            {
               NewTP   = OPbL - tp2;
               sCalcTP = sCalcTP + " -Grid TP: (" + DTS(tp2, Digits) + ") ";
            }

            if (MinTPPips_ > 0)
            {
               NewTP   = MathMin(NewTP, BEb - MinTPPips_);
               sCalcTP = sCalcTP + " >Minimum TP: ";
            }

            NewTP -= MoveTP_ * Moves;

            if (BreakEvenTrade > 0 && CbT + CbC >= BreakEvenTrade)
            {
               NewTP   = BEb - BEPlusPips_;
               sCalcTP = sCalcTP + " >BreakEven: (" + DTS(BEPlusPips_, Digits) + ") ";
            }

            sCalcTP = (sCalcTP + "Sell: TakeProfit: ");
         }

         if (TPb != NewTP)
         {
            TPb = NewTP;

            if (nLots > 0)
               TargetPips = ND(TPb - BEb, Digits);
            else
               TargetPips = ND(BEb - TPb, Digits);

            Print(sCalcTP + DTS(NewTP, Digits));

            return;
         }
      }

      PbTarget  = TargetPips / Pip;
      ProfitPot = ND(TargetPips * PipVal2 * MathAbs(nLots), 2);

      if (CbB > 0)
         PbPips = ND((BID - BEb) / Pip, 1);

      if (CbS > 0)
         PbPips = ND((BEb - ASK) / Pip, 1);

      //+-----------------------------------------------------------------+
      //| Adjust BEb/TakeProfit if Hedge is active                        |
      //+-----------------------------------------------------------------+
      double hAsk    = MarketInfo(HedgeSymbol_, MODE_ASK);
      double hBid    = MarketInfo(HedgeSymbol_, MODE_BID);
      double hSpread = hAsk - hBid;

      if (hThisChart)
         nLots += LhB - LhS;

      double PhPips;

      if (hActive == 1)
      {
         if (nLots == 0)
         {
            BEa = 0;
            TPa = 0;
         }
         else if (hThisChart)
         {
            if (nLots > 0)
            {
               if (CbB > 0)
                  BEa = ND((BEb * LbT - (BEh - hSpread) * LhT) / (LbT - LhT), Digits);
               else
                  BEa = ND(((BEb - (ASK - BID)) * LbT - BEh * LhT) / (LbT - LhT), Digits);

               TPa = ND(BEa + TargetPips, Digits);
            }
            else
            {
               if (CbS > 0)
                  BEa = ND((BEb * LbT - (BEh + hSpread) * LhT) / (LbT - LhT), Digits);
               else
                  BEa = ND(((BEb + ASK - BID) * LbT - BEh * LhT) / (LbT - LhT), Digits);

               TPa = ND(BEa - TargetPips, Digits);
            }
         }

         if (ChB > 0)
            PhPips = ND((hBid - BEh) / hPip, 1);

         if (ChS > 0)
            PhPips = ND((BEh - hAsk) / hPip, 1);
      }
      else
      {
         BEa = BEb;
         TPa = TPb;
      }

      //+-----------------------------------------------------------------+
      //| Calculate Early Exit Percentage                                 |
      //+-----------------------------------------------------------------+
      double EEStartTime = 0, TPaF;

      if (UseEarlyExit && CbT > 0)
      {
         datetime EEopt;

         if (EEFirstTrade)
            EEopt = OTbF;
         else
            EEopt = OTbL;

         if (DayOfWeek() < TimeDayOfWeek(EEopt))
            EEStartTime = 2 * 24 * 3600;

         EEStartTime += EEopt + EEStartHours * 3600;

         if (EEHoursPC_ > 0 && TimeCurrent() >= EEStartTime)
            EEpc = EEHoursPC_ * (TimeCurrent() - EEStartTime) / 3600;

         if (EELevelPC_ > 0 && (CbT + CbC) >= EEStartLevel)
            EEpc += EELevelPC_ * (CbT + CbC - EEStartLevel + 1);

         EEpc = 1 - EEpc;

         if (!EEAllowLoss && EEpc < 0)
            EEpc = 0;

         PbTarget *= EEpc;
         TPaF      = ND((TPa - BEa) * EEpc + BEa, Digits);

         if (displayOverlay && displayLines && (hActive != 1 || (hActive == 1 && hThisChart)) && (!Testing || (Testing && Visual)) &&
            EEpc < 1 && (CbT + CbC + ChT > EECount || EETime != iTime(_Symbol, Period(), 0)) && ((EEHoursPC_ > 0 && EEopt + EEStartHours * 3600 < iTime(_Symbol, Period(), 0)) || (EELevelPC_ > 0 && CbT + CbC >= EEStartLevel)))
         {
            EETime  = iTime(_Symbol, Period(), 0);
            EECount = CbT + CbC + ChT;

            if (ObjectFind("B3LEELn") < 0)
            {
               ObjectCreate("B3LEELn", OBJ_TREND, 0, 0, 0);
               ObjectSet("B3LEELn", OBJPROP_COLOR, Yellow);
               ObjectSet("B3LEELn", OBJPROP_WIDTH, 1);
               ObjectSet("B3LEELn", OBJPROP_STYLE, 0);
               ObjectSet("B3LEELn", OBJPROP_RAY, false);
               ObjectSet("B3LEELn", OBJPROP_BACK, false);
            }

            if (EEHoursPC_ > 0)
               ObjectMove("B3LEELn", 0, (datetime) (MathFloor(EEopt / 3600 + EEStartHours) * 3600), TPa);
            else
               ObjectMove("B3LEELn", 0, (datetime) (MathFloor(EEopt / 3600) * 3600), TPaF);

            ObjectMove("B3LEELn", 1, iTime(_Symbol, Period(), 1), TPaF);

            if (ObjectFind("B3VEELn") < 0)
            {
               ObjectCreate("B3VEELn", OBJ_TEXT, 0, 0, 0);
               ObjectSet("B3VEELn", OBJPROP_COLOR, Yellow);
               ObjectSet("B3VEELn", OBJPROP_WIDTH, 1);
               ObjectSet("B3VEELn", OBJPROP_STYLE, 0);
               ObjectSet("B3VEELn", OBJPROP_BACK, false);
            }

            ObjSetTxt("B3VEELn", "              " + DTS(TPaF, Digits), -1, Yellow);
            ObjectSet("B3VEELn", OBJPROP_PRICE1, TPaF + 2 * Pip);
            ObjectSet("B3VEELn", OBJPROP_TIME1, iTime(_Symbol, Period(), 1));
         }
         else if ((!displayLines || EEpc == 1 || (!EEAllowLoss && EEpc == 0) || (EEHoursPC_ > 0 && EEopt + EEStartHours * 3600 >= iTime(_Symbol, Period(), 0))))
         {
            ObjDel("B3LEELn");
            ObjDel("B3VEELn");
         }
      }
      else
      {
         TPaF    = TPa;
         EETime  = 0;
         EECount = 0;
         ObjDel("B3LEELn");
         ObjDel("B3VEELn");
      }

      //+-----------------------------------------------------------------+
      //| Maximize Profit with Moving TP and setting Trailing Profit Stop |
      //+-----------------------------------------------------------------+
      if (MaximizeProfit)
      {
         if (CbT == 0)
         {
            SLbL  = 0;
            Moves = 0;
            SLb   = 0;
         }

         if (!FirstRun && CbT > 0)
         {
            if (Pb + Ph < 0 && SLb > 0)
               SLb = 0;

            if (SLb > 0 && ((nLots > 0 && BID < SLb) || (nLots < 0 && ASK > SLb)))
            {
               ExitTrades(A, displayColorProfit, "Profit Trailing Stop Reached (" + DTS(ProfitSet_ * 100, 2) + "%)");

               return;
            }

            if (PbTarget > 0)
            {
               TPbMP = ND(BEa + (TPa - BEa) * ProfitSet_, Digits);

               if ((nLots > 0 && BID > TPbMP) || (nLots < 0 && ASK < TPbMP))
                  SLb = TPbMP;
            }

            if (SLb > 0 && SLb != SLbL && MoveTP_ > 0 && TotalMoves > Moves)
            {
               TPb = 0;
               Moves++;

               if (Debug_)
                  Print("MoveTP");

               SLbL = SLb;

               if (PlaySounds)
                  PlaySound(AlertSound);

               return;
            }
         }
      }

      if (!FirstRun && TPaF > 0)
      {
         if ((nLots > 0 && BID >= TPaF) || (nLots < 0 && ASK <= TPaF))
         {
            ExitTrades(A, displayColorProfit, "Profit Target Reached @ " + DTS(TPaF, Digits));

            return;
         }
      }

      if (!FirstRun && useCloudSL && IchimokuEntry_ != 0)
      {
         double senkou_a = iIchimoku(_Symbol, ICHI_TF, Tenkan_Sen, Kijun_Sen, Senkou_Span, MODE_SENKOUSPANA, 0);
         double senkou_b = iIchimoku(_Symbol, ICHI_TF, Tenkan_Sen, Kijun_Sen, Senkou_Span, MODE_SENKOUSPANB, 0);

         if (nLots > 0 && (BID < senkou_a || BID < senkou_b))
         {
            ExitTrades(A, displayColorProfit, "Ichi Stop Loss Reached");
                    
            return;
         }

         if (nLots < 0 && (ASK > senkou_a || ASK > senkou_b))
         {
            ExitTrades(A, displayColorProfit, "Ichi Stop Loss Reached");
                    
            return;
         }
      }

      if (!FirstRun && UseStopLoss)
      {
         if (SLPips_ > 0)
         {
            if (nLots > 0)
            {
               bSL = BEa - SLPips_;

               if (BID <= bSL)
               {
                  ExitTrades(A, displayColorProfit, "Stop Loss Reached");

                  return;
               }
            }
            else if (nLots < 0)
            {
               bSL = BEa + SLPips_;

               if (ASK >= bSL)
               {
                  ExitTrades(A, displayColorProfit, "Stop Loss Reached");

                  return;
               }
            }
         }

         if (TSLPips_ != 0)
         {
            if (nLots > 0)
            {
               if (TSLPips_ > 0 && BID > BEa + TSLPips_)
                  bTS = MathMax(bTS, BID - TSLPips_);

               if (TSLPips_ < 0 && BID > BEa - TSLPips_)
                  bTS = MathMax(bTS, BID - MathMax(TSLPipsMin_, -TSLPips_ * (1 - (BID - BEa + TSLPips_) / (-TSLPips_ * 2))));

               if (bTS > 0 && BID <= bTS)
               {
                  ExitTrades(A, displayColorProfit, "Trailing Stop Reached");

                  return;
               }
            }
            else if (nLots < 0)
            {
               if (TSLPips_ > 0 && ASK < BEa - TSLPips_)
               {
                  if (bTS > 0)
                     bTS = MathMin(bTS, ASK + TSLPips_);
                  else
                     bTS = ASK + TSLPips_;
               }

               if (TSLPips_ < 0 && ASK < BEa + TSLPips_)
                  bTS = MathMin(bTS, ASK + MathMax(TSLPipsMin_, -TSLPips_ * (1 - (BEa - ASK + TSLPips_) / (-TSLPips_ * 2))));

               if (bTS > 0 && ASK >= bTS)
               {
                  ExitTrades(A, displayColorProfit, "Trailing Stop Reached");

                  return;
               }
            }
         }
      }
      //+-----------------------------------------------------------------+
      //| Check for and Delete hanging pending orders                     |
      //+-----------------------------------------------------------------+
      if (CbT == 0 && !PendLot)
      {
         PendLot = true;

         for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
         {
            if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
               continue;

            if (OrderMagicNumber() != Magic || OrderType() <= OP_SELL)
               continue;

            if (ND(OrderLots(), LotDecimal) > ND(Lots[0] * LotMult, LotDecimal))
            {
               PendLot = false;

               while (IsTradeContextBusy())
                  Sleep(100);

               if (IsStopped())
                  return;

               Success = OrderDelete(OrderTicket());

               if (Success)
               {
                  PendLot = true;

                  if (Debug_)
                     Print("Delete pending > Lot");
               }
            }
         }

         return;
      }
      else if ((CbT > 0 || (CbT == 0 && CpT > 0 && !B3Traditional)) && PendLot)
      {
         PendLot = false;

         for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
         {
            if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
               continue;

            if (OrderMagicNumber() != Magic || OrderType() <= OP_SELL)
               continue;

            if (ND(OrderLots(), LotDecimal) == ND(Lots[0] * LotMult, LotDecimal))
            {
               PendLot = true;

               while (IsTradeContextBusy())
                  Sleep(100);

               if (IsStopped())
                  return;

               Success = OrderDelete(OrderTicket());

               if (Success)
               {
                  PendLot = false;

                  if (Debug_)
                     Print("Delete pending = Lot");
               }
            }
         }

         return;
      }
      //+-----------------------------------------------------------------+
      //| Check ca, Breakeven Trades and Emergency Close All              |
      //+-----------------------------------------------------------------+
      switch (ca)
      {
      case B:
         if (CbT == 0 && CpT == 0)
            ca = 0;

         break;
      case H:
         if (ChT == 0)
            ca = 0;

         break;
      case A:
         if (CbT == 0 && CpT == 0 && ChT == 0)
            ca = 0;

         break;
      case P:
         if (CpT == 0)
            ca = 0;

         break;
      case T:
         break;
      default:
         break;
      }

      if (ca > 0)
      {
         ExitTrades(ca, displayColorLoss, "Close All (" + DTS(ca, 0) + ")");

         return;
      }
      else if (CbT == 0 && ChT > 0)
      {
         ExitTrades(H, displayColorLoss, "Basket Closed");

         return;
      }
      else if (EmergencyCloseAll_)
      {
         ExitTrades(A, displayColorLoss, "Emergency Close-All-Trades");
         EmergencyCloseAll_ = false;

         return;
      }
      //+-----------------------------------------------------------------+
      //| Check Holiday Shutdown                                          |
      //+-----------------------------------------------------------------+
      if (UseHolidayShutdown)
      {
         if (HolShutDown > 0 && TimeCurrent() >= HolLast && HolLast > 0)
         {
            Print("Trading has resumed after the ", TimeToStr(HolFirst, TIME_DATE), " - ", TimeToStr(HolLast, TIME_DATE), " holidays.");
            HolShutDown = 0;
            LabelDelete();
            LabelCreate();

            if (PlaySounds)
               PlaySound(AlertSound);
         }

         if (HolShutDown == 3)
         {
            if (ObjectFind("B3LStop") == -1)
               CreateLabel("B3LStop", "Trading has been paused on this pair for the holidays.", 10, CORNER_LEFT_UPPER, 0, 3, displayColorLoss);

            if (ObjectFind("B3LResm") == -1)
               CreateLabel("B3LResm", "Trading will resume trading after " + TimeToStr(HolLast, TIME_DATE) + ".", 10, CORNER_LEFT_UPPER, 0, 9, displayColorLoss);

            return;
         }
         else if ((HolShutDown == 0 && TimeCurrent() >= HolLast) || HolFirst == 0)
         {
            for (int Index = 0; Index < ArraySize(HolArray); Index++)
            {
               // HolFirst = StrToTime((string) Year() + "." + (string) HolArray[Index, 0] + "." + (string) HolArray[Index, 1]);
               string tts = (string) Year() + "." + (string) HolArray[Index, 0] + "." + (string) HolArray[Index, 1];
               Print("tts: " + tts + "  *******************************************************");
               HolFirst = StrToTime(tts);

               HolLast = StrToTime((string) Year() + "." + (string) HolArray[Index, 2] + "." + (string) HolArray[Index, 3] + " 23:59:59");

               if (TimeCurrent() < HolFirst)
               {
                  if (HolFirst > HolLast)
                     HolLast = StrToTime(DTS(Year() + 1, 0) + "." + (string) HolArray[Index, 2] + "." + (string) HolArray[Index, 3] + " 23:59:59");

                  break;
               }

               if (TimeCurrent() < HolLast)
               {
                  if (HolFirst > HolLast)
                     HolFirst = StrToTime(DTS(Year() - 1, 0) + "." + (string) HolArray[Index, 0] + "." + (string) HolArray[Index, 1]);

                  break;
               }

               if (TimeCurrent() > HolFirst && HolFirst > HolLast)
               {
                  HolLast = StrToTime(DTS(Year() + 1, 0) + "." + (string) HolArray[Index, 2] + "." + (string) HolArray[Index, 3] + " 23:59:59");

                  if (TimeCurrent() < HolLast)
                     break;
               }
            }

            if (TimeCurrent() >= HolFirst && TimeCurrent() <= HolLast)
            {
               // Comment(""); // xxx
               HolShutDown = 1;
            }
         }
         else if (HolShutDown == 0 && TimeCurrent() >= HolFirst && TimeCurrent() < HolLast)
            HolShutDown = 1;

         if (HolShutDown == 1 && CbT == 0)
         {
            Print("Trading has been paused for holidays (", TimeToStr(HolFirst, TIME_DATE), " - ", TimeToStr(HolLast, TIME_DATE), ")");

            if (CpT > 0)
            {
               int Index = ExitTrades(P, displayColorLoss, "Holiday Shutdown");

               if (Index == CpT)
                  ca = 0;
            }

            HolShutDown = 2;
            ObjDel("B3LClos");
         }
         else if (HolShutDown == 1)
         {
            if (ObjectFind("B3LClos") == -1)
               CreateLabel("B3LClos", "", 5, CORNER_LEFT_UPPER, 0, 23, displayColorLoss);

            ObjSetTxt("B3LClos", "Trading will pause for holidays when this basket closes", 5);
         }

         if (HolShutDown == 2)
         {
            LabelDelete();

            if (PlaySounds)
               PlaySound(AlertSound);

            HolShutDown = 3;
         }

         if (HolShutDown == 3)
         {
            if (ObjectFind("B3LStop") == -1)
               CreateLabel("B3LStop", "Trading has been paused on this pair due to holidays.", 10, CORNER_LEFT_UPPER, 0, 3, displayColorLoss);

            if (ObjectFind("B3LResm") == -1)
               CreateLabel("B3LResm", "Trading will resume after " + TimeToStr(HolLast, TIME_DATE) + ".", 10, CORNER_LEFT_UPPER, 0, 9, displayColorLoss);

            // Comment(""); // xxx

            return;
         }
      }
      //+-----------------------------------------------------------------+
      //| Power Out Stop Loss Protection                                  |
      //+-----------------------------------------------------------------+
      if (SetPOSL)
      {
         if (UsePowerOutSL && POSLPips_ > 0)
         {
            double POSL = MathMin(PortionBalance * (MaxDDPercent + 1) / 100 / PipVal2 / LbT, POSLPips_);
            SLbB = ND(BEb - POSL, Digits);
            SLbS = ND(BEb + POSL, Digits);
         }
         else
         {
            SLbB = 0;
            SLbS = 0;
         }

         for (int Order = 0; Order < OrdersTotal(); Order++)
         {
            if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
               continue;

            if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol() || OrderType() > OP_SELL)
               continue;

            if (OrderType() == OP_BUY && OrderStopLoss() != SLbB)
            {
               Success = ModifyOrder(OrderOpenPrice(), SLbB, Purple);

               if (Debug_ && Success)
                  Print("Order ", OrderTicket(), ": Sync POSL Buy");
            }
            else if (OrderType() == OP_SELL && OrderStopLoss() != SLbS)
            {
               Success = ModifyOrder(OrderOpenPrice(), SLbS, Purple);

               if (Debug_ && Success)
                  Print("Order ", OrderTicket(), ": Sync POSL Sell");
            }
         }
      }
      //+-----------------------------------------------------------------+  << This must be the first Entry check.
      //| Moving Average Indicator for Order Entry                        |  << Add your own Indicator Entry checks
      //+-----------------------------------------------------------------+  << after the Moving Average Entry.
      if (MAEntry_ > 0 && CbT == 0 && CpT < 2)
      {
         if (BID > ima_0 + MADistance_ && (!B3Traditional || (B3Traditional && Trend != 2)))
         {
            if (MAEntry_ == 1)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
            else if (MAEntry_ == 2)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
         }
         else if (ASK < ima_0 - MADistance_ && (!B3Traditional || (B3Traditional && Trend != 2)))
         {
            if (MAEntry_ == 1)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
            else if (MAEntry_ == 2)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
         }
         else if (B3Traditional && Trend == 2)
         {
            if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
               BuyMe = true;

            if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
               SellMe = true;
         }
         else
         {
            BuyMe  = false;
            SellMe = false;
         }

         if (IndEntry > 0)
            IndicatorUsed = IndicatorUsed + UAE;

         IndEntry++;
         IndicatorUsed = IndicatorUsed + " MA ";
      }
      //+----------------------------------------------------------------+
      //| CCI of 5M, 15M, 30M, 1H for Market Condition and Order Entry      |
      //+----------------------------------------------------------------+
      if (CCIEntry_ > 0)
      {
         cci_01 = iCCI(Symbol(), PERIOD_M5, CCIPeriod, PRICE_CLOSE, 0);
         cci_02 = iCCI(Symbol(), PERIOD_M15, CCIPeriod, PRICE_CLOSE, 0);
         cci_03 = iCCI(Symbol(), PERIOD_M30, CCIPeriod, PRICE_CLOSE, 0);
         cci_04 = iCCI(Symbol(), PERIOD_H1, CCIPeriod, PRICE_CLOSE, 0);
         cci_11 = iCCI(Symbol(), PERIOD_M5, CCIPeriod, PRICE_CLOSE, 1);
         cci_12 = iCCI(Symbol(), PERIOD_M15, CCIPeriod, PRICE_CLOSE, 1);
         cci_13 = iCCI(Symbol(), PERIOD_M30, CCIPeriod, PRICE_CLOSE, 1);
         cci_14 = iCCI(Symbol(), PERIOD_H1, CCIPeriod, PRICE_CLOSE, 1);
      }

      if (CCIEntry_ > 0 && CbT == 0 && CpT < 2)
      {
         if (cci_11 > 0 && cci_12 > 0 && cci_13 > 0 && cci_14 > 0 && cci_01 > 0 && cci_02 > 0 && cci_03 > 0 && cci_04 > 0)
         {
            if (ForceMarketCond_ == 3)
               Trend = 0;

            if (CCIEntry_ == 1)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
            else if (CCIEntry_ == 2)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
         }
         else if (cci_11 < 0 && cci_12 < 0 && cci_13 < 0 && cci_14 < 0 && cci_01 < 0 && cci_02 < 0 && cci_03 < 0 && cci_04 < 0)
         {
            if (ForceMarketCond_ == 3)
               Trend = 1;

            if (CCIEntry_ == 1)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
            else if (CCIEntry_ == 2)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
         }
         else if (!UseAnyEntry && IndEntry > 0)
         {
            BuyMe  = false;
            SellMe = false;
         }

         if (IndEntry > 0)
            IndicatorUsed = IndicatorUsed + UAE;

         IndEntry++;
         IndicatorUsed = IndicatorUsed + " CCI ";
      }
      //+----------------------------------------------------------------+
      //| Bollinger Band Indicator for Order Entry                       |
      //+----------------------------------------------------------------+
      if (BollingerEntry_ > 0 && CbT == 0 && CpT < 2)
      {
         double ma     = iMA(Symbol(), 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
         double stddev = iStdDev(Symbol(), 0, BollPeriod, 0, MODE_SMA, PRICE_OPEN, 0);
         double bup    = ma + (BollDeviation * stddev);
         double bdn    = ma - (BollDeviation * stddev);
         double bux    = bup + BollDistance_;
         double bdx    = bdn - BollDistance_;

         if (ASK < bdx)
         {
            if (BollingerEntry_ == 1)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
            else if (BollingerEntry_ == 2)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
         }
         else if (BID > bux)
         {
            if (BollingerEntry_ == 1)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
            else if (BollingerEntry_ == 2)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
         }
         else if (!UseAnyEntry && IndEntry > 0)
         {
            BuyMe  = false;
            SellMe = false;
         }

         if (IndEntry > 0)
            IndicatorUsed = IndicatorUsed + UAE;

         IndEntry++;
         IndicatorUsed = IndicatorUsed + " BBands ";
      }
      //+----------------------------------------------------------------+
      //| Ichimokou Indicator for Order Entry                            |
      //+----------------------------------------------------------------+
      if (IchimokuEntry_ > 0 && CbT == 0 && CpT < 2)
      {
         double senkou_a = iIchimoku(_Symbol, ICHI_TF, Tenkan_Sen, Kijun_Sen, Senkou_Span, MODE_SENKOUSPANA, 0);
         double senkou_b = iIchimoku(_Symbol, ICHI_TF, Tenkan_Sen, Kijun_Sen, Senkou_Span, MODE_SENKOUSPANB, 0);
         double tenkan = iIchimoku(_Symbol, ICHI_TF, Tenkan_Sen, Kijun_Sen, Senkou_Span, MODE_TENKANSEN, 0);
         double kijun = iIchimoku(_Symbol, ICHI_TF, Tenkan_Sen, Kijun_Sen, Senkou_Span, MODE_KIJUNSEN, 0);
           
         bool denyBuy = false;
         bool denySell = false;
           
      // if ((senkou_a > senkou_b && BID - senkou_a > distanceFromCloud) || (senkou_a < senkou_b && BID - senkou_b > distanceFromCloud))
      //    bgotdistanceFromCloud = true;
      // if (useChikuspan && chikou > senkou_a)
      //    bgotChikouSpan = true;
              
         if ((useCloudBreakOut && !(BID > senkou_a && BID > senkou_b)) ||
             (useTenken_Kijun_cross == 1 && !(tenkan > kijun)) ||
             (useTenken_Kijun_cross == 2 && !(tenkan > kijun && tenkan > senkou_a && tenkan > senkou_b && kijun > senkou_a && kijun > senkou_b)) ||
             (usePriceCrossTenken && !(BID > tenkan)) ||
             (usePriceCrossKijun && !(BID > kijun)) ||
             (useChikuspan && !(iClose(_Symbol, ICHI_TF, Kijun_Sen) < BID)) ||
             (!useCloudBreakOut && !usePriceCrossKijun && !usePriceCrossTenken && !useTenken_Kijun_cross && !useChikuspan))
            denyBuy = true; 
         
         if ((useCloudBreakOut && !(ASK < senkou_a && ASK < senkou_b)) ||
             (useTenken_Kijun_cross == 1 && !(tenkan < kijun)) ||
             (useTenken_Kijun_cross == 2 && !(tenkan < kijun && tenkan < senkou_a && tenkan < senkou_b && kijun < senkou_a && kijun < senkou_b)) ||
             (usePriceCrossTenken && !(ASK < tenkan)) ||
             (usePriceCrossKijun && !(ASK < kijun)) ||
             (useChikuspan && !(iClose(_Symbol, ICHI_TF, Kijun_Sen) > ASK)) ||
             (!useCloudBreakOut && !usePriceCrossKijun && !usePriceCrossTenken && !useTenken_Kijun_cross && !useChikuspan))
            denySell = true; 
        
         if (!denyBuy)
         {
            if (IchimokuEntry_ == 1)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
            else if (IchimokuEntry_ == 2)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
         }
         else if (!denySell)
         {
            if (IchimokuEntry_ == 1)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
            else if (IchimokuEntry_ == 2)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
         }
         else if (!UseAnyEntry && IndEntry > 0)
         {
            BuyMe = false;
            SellMe = false;
         }

         if (IndEntry > 0)
            IndicatorUsed = IndicatorUsed + UAE;

         IndEntry++;
         IndicatorUsed = IndicatorUsed + " Ichimoku ";
      }
      //+----------------------------------------------------------------+
      //| Stochastic Indicator for Order Entry                           |
      //+----------------------------------------------------------------+
      if (StochEntry_ > 0 && CbT == 0 && CpT < 2)
      {
         int    zoneBUY  = BuySellStochZone;
         int    zoneSELL = 100 - BuySellStochZone;
         double stoc_0   = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 1, 0, 1);
         double stoc_1   = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_LWMA, 1, 1, 1);

         if (stoc_0 < zoneBUY && stoc_1 < zoneBUY)
         {
            if (StochEntry_ == 1)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
            else if (StochEntry_ == 2)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
         }
         else if (stoc_0 > zoneSELL && stoc_1 > zoneSELL)
         {
            if (StochEntry_ == 1)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
            else if (StochEntry_ == 2)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
         }
         else if (!UseAnyEntry && IndEntry > 0)
         {
            BuyMe  = false;
            SellMe = false;
         }

         if (IndEntry > 0)
            IndicatorUsed = IndicatorUsed + UAE;

         IndEntry++;
         IndicatorUsed = IndicatorUsed + " Stoch ";
      }
      //+----------------------------------------------------------------+
      //| MACD Indicator for Order Entry                                 |
      //+----------------------------------------------------------------+
      if (MACDEntry_ > 0 && CbT == 0 && CpT < 2)
      {
         double MACDm = iMACD(NULL, TF[MACD_TF], FastPeriod, SlowPeriod, SignalPeriod, MACDPrice, 0, 0);
         double MACDs = iMACD(NULL, TF[MACD_TF], FastPeriod, SlowPeriod, SignalPeriod, MACDPrice, 1, 0);

         if (MACDm > MACDs)
         {
            if (MACDEntry_ == 1)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
            else if (MACDEntry_ == 2)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
         }
         else if (MACDm < MACDs)
         {
            if (MACDEntry_ == 1)
            {
               if (ForceMarketCond_ != 0 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && SellMe)))
                  SellMe = true;
               else
                  SellMe = false;

               if (!UseAnyEntry && IndEntry > 0 && BuyMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  BuyMe = false;
            }
            else if (MACDEntry_ == 2)
            {
               if (ForceMarketCond_ != 1 && (UseAnyEntry || IndEntry == 0 || (!UseAnyEntry && IndEntry > 0 && BuyMe)))
                  BuyMe = true;
               else
                  BuyMe = false;

               if (!UseAnyEntry && IndEntry > 0 && SellMe && (!B3Traditional || (B3Traditional && Trend != 2)))
                  SellMe = false;
            }
         }
         else if (!UseAnyEntry && IndEntry > 0)
         {
            BuyMe  = false;
            SellMe = false;
         }

         if (IndEntry > 0)
            IndicatorUsed = IndicatorUsed + UAE;

         IndEntry++;
         IndicatorUsed = IndicatorUsed + " MACD ";
      }
      //+-----------------------------------------------------------------+  << This must be the last Entry check before
      //| UseAnyEntry Check && Force Market Condition Buy/Sell Entry      |  << the Trade Selection Logic. Add checks for
      //+-----------------------------------------------------------------+  << additional indicators before this block.
      if ((!UseAnyEntry && IndEntry > 1 && BuyMe && SellMe) || FirstRun)
      {
         BuyMe  = false;
         SellMe = false;
      }

      if (ForceMarketCond_ < 2 && IndEntry == 0 && CbT == 0 && !FirstRun)
      {
         if (ForceMarketCond_ == 0)
            BuyMe = true;
         else if (ForceMarketCond_ == 1)
            SellMe = true;

         IndicatorUsed = " FMC ";
      }
      //+-----------------------------------------------------------------+
      //| Trade Selection Logic                                           |
      //+-----------------------------------------------------------------+
      OrderLot = LotSize(Lots[StrToInteger(DTS(MathMin(CbT + CbC, MaxTrades - 1), 0))] * LotMult);

      if (CbT == 0 && CpT < 2 && !FirstRun)
      {
         if (B3Traditional)
         {
            if (BuyMe)
            {
               if (CpBS == 0 && CpSL == 0 && ((Trend != 2 || MAEntry_ == 0) || (Trend == 2 && MAEntry_ == 1)))
               {
                  Entry_ = g2 - MathMod(ASK, g2) + EntryOffset_;

                  if (Entry_ > StopLevel)
                  {
                     Ticket = SendOrder(Symbol(), OP_BUYSTOP, OrderLot, Entry_, 0, Magic, CLR_NONE);

                     if (Ticket > 0)
                     {
                        if (Debug_)
                           Print("Indicator Entry - (", IndicatorUsed, ") BuyStop MC = ", Trend);

                        CpBS++;
                     }
                  }
               }

               if (CpBL == 0 && CpSS == 0 && ((Trend != 2 || MAEntry_ == 0) || (Trend == 2 && MAEntry_ == 2)))
               {
                  Entry_ = MathMod(ASK, g2) + EntryOffset_;

                  if (Entry_ > StopLevel)
                  {
                     Ticket = SendOrder(Symbol(), OP_BUYLIMIT, OrderLot, -Entry_, 0, Magic, CLR_NONE);

                     if (Ticket > 0)
                     {
                        if (Debug_)
                           Print("Indicator Entry - (", IndicatorUsed, ") BuyLimit MC = ", Trend);

                        CpBL++;
                     }
                  }
               }
            }

            if (SellMe)
            {
               if (CpSL == 0 && CpBS == 0 && ((Trend != 2 || MAEntry_ == 0) || (Trend == 2 && MAEntry_ == 2)))
               {
                  Entry_ = g2 - MathMod(BID, g2) + EntryOffset_;

                  if (Entry_ > StopLevel)
                  {
                     Ticket = SendOrder(Symbol(), OP_SELLLIMIT, OrderLot, Entry_, 0, Magic, CLR_NONE);

                     if (Ticket > 0 && Debug_)
                        Print("Indicator Entry - (", IndicatorUsed, ") SellLimit MC = ", Trend);
                  }
               }

               if (CpSS == 0 && CpBL == 0 && ((Trend != 2 || MAEntry_ == 0) || (Trend == 2 && MAEntry_ == 1)))
               {
                  Entry_ = MathMod(BID, g2) + EntryOffset_;

                  if (Entry_ > StopLevel)
                  {
                     Ticket = SendOrder(Symbol(), OP_SELLSTOP, OrderLot, -Entry_, 0, Magic, CLR_NONE);

                     if (Ticket > 0 && Debug_)
                        Print("Indicator Entry - (", IndicatorUsed, ") SellStop MC = ", Trend);
                  }
               }
            }
         }
         else
         {
            if (BuyMe)
            {
               Ticket = SendOrder(Symbol(), OP_BUY, OrderLot, 0, slip, Magic, Blue);

               if (Ticket > 0 && Debug_)
                  Print("Indicator Entry - (", IndicatorUsed, ") Buy");
            }
            else if (SellMe)
            {
               Ticket = SendOrder(Symbol(), OP_SELL, OrderLot, 0, slip, Magic, displayColorLoss);

               if (Ticket > 0 && Debug_)
                  Print("Indicator Entry - (", IndicatorUsed, ") Sell");
            }
         }

         if (Ticket > 0)
            return;
      }
      else if (TimeCurrent() - EntryDelay > OTbL && CbT + CbC < MaxTrades && !FirstRun)
      {
         if (UseSmartGrid)
         {
            if (RSI[1] != iRSI(NULL, TF[RSI_TF], RSI_Period, RSI_Price, 1))
            {
               for (int Index = 0; Index < RSI_Period + RSI_MA_Period; Index++)
                  RSI[Index] = iRSI(NULL, TF[RSI_TF], RSI_Period, RSI_Price, Index);
            }
            else
               RSI[0] = iRSI(NULL, TF[RSI_TF], RSI_Period, RSI_Price, 0);

            RSI_MA = iMAOnArray(RSI, 0, RSI_MA_Period, 0, RSI_MA_Method, 0);
         }

         if (CbB > 0)
         {
            if (OPbL > ASK)
               Entry_ = OPbL - (MathRound((OPbL - ASK) / g2) + 1) * g2;
            else
               Entry_ = OPbL - g2;

            if (UseSmartGrid)
            {
               if (ASK < OPbL - g2)
               {
                  if (RSI[0] > RSI_MA)
                  {
                     Ticket = SendOrder(Symbol(), OP_BUY, OrderLot, 0, slip, Magic, Blue);

                     if (Ticket > 0 && Debug_)
                        Print("SmartGrid Buy RSI: ", RSI[0], " > MA: ", RSI_MA);
                  }

                  OPbN = 0;
               }
               else
                  OPbN = OPbL - g2;
            }
            else if (CpBL == 0)
            {
               if (ASK - Entry_ <= StopLevel)
                  Entry_ = OPbL - (MathFloor((OPbL - ASK + StopLevel) / g2) + 1) * g2;

               Ticket = SendOrder(Symbol(), OP_BUYLIMIT, OrderLot, Entry_ - ASK, 0, Magic, SkyBlue);

               if (Ticket > 0 && Debug_)
                  Print("BuyLimit grid");
            }
            else if (CpBL == 1 && Entry_ - OPpBL > g2 / 2 && ASK - Entry_ > StopLevel)
            {
               for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
               {
                  if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                     continue;

                  if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol() || OrderType() != OP_BUYLIMIT)
                     continue;

                  Success = ModifyOrder(Entry_, 0, SkyBlue);

                  if (Success && Debug_)
                     Print("Mod BuyLimit Entry");
               }
            }
         }
         else if (CbS > 0)
         {
            if (BID > OPbL)
               Entry_ = OPbL + (MathRound((-OPbL + BID) / g2) + 1) * g2;
            else
               Entry_ = OPbL + g2;

            if (UseSmartGrid)
            {
               if (BID > OPbL + g2)
               {
                  if (RSI[0] < RSI_MA)
                  {
                     Ticket = SendOrder(Symbol(), OP_SELL, OrderLot, 0, slip, Magic, displayColorLoss);

                     if (Ticket > 0 && Debug_)
                        Print("SmartGrid Sell RSI: ", RSI[0], " < MA: ", RSI_MA);
                  }

                  OPbN = 0;
               }
               else
                  OPbN = OPbL + g2;
            }
            else if (CpSL == 0)
            {
               if (Entry_ - BID <= StopLevel)
                  Entry_ = OPbL + (MathFloor((-OPbL + BID + StopLevel) / g2) + 1) * g2;

               Ticket = SendOrder(Symbol(), OP_SELLLIMIT, OrderLot, Entry_ - BID, 0, Magic, Coral);

               if (Ticket > 0 && Debug_)
                  Print("SellLimit grid");
            }
            else if (CpSL == 1 && OPpSL - Entry_ > g2 / 2 && Entry_ - BID > StopLevel)
            {
               for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
               {
                  if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
                     continue;

                  if (OrderMagicNumber() != Magic || OrderSymbol() != Symbol() || OrderType() != OP_SELLLIMIT)
                     continue;

                  Success = ModifyOrder(Entry_, 0, Coral);

                  if (Success && Debug_)
                     Print("Mod SellLimit Entry");
               }
            }
         }

         if (Ticket > 0)
            return;
      }
      //+-----------------------------------------------------------------+
      //| Hedge Trades Set-Up and Monitoring                              |
      //+-----------------------------------------------------------------+
      if ((UseHedge_ && CbT > 0) || ChT > 0)
      {
         int hLevel = CbT + CbC;

         if (HedgeTypeDD)
         {
            if (hDDStart == 0 && ChT > 0)
               hDDStart = MathMax(HedgeStart_, DrawDownPC + hReEntryPC_);

            if (hDDStart > HedgeStart_ && hDDStart > DrawDownPC + hReEntryPC_)
               hDDStart = DrawDownPC + hReEntryPC_;

            if (hActive == 2)
            {
               hActive  = 0;
               hDDStart = MathMax(HedgeStart_, DrawDownPC + hReEntryPC_);
            }
         }

         if (hActive == 0)
         {
            if (!hThisChart && ((hPosCorr && CheckCorr() < 0.9) || (!hPosCorr && CheckCorr() > -0.9)))
            {
               if (ObjectFind("B3LhCor") == -1)
                  CreateLabel("B3LhCor", "Correlation with the hedge pair has dropped below 90%.", 0, CORNER_LEFT_UPPER, 190, 10, displayColorLoss);
            }
            else
               ObjDel("B3LhCor");

            if (hLvlStart > hLevel + 1 || (!HedgeTypeDD && hLvlStart == 0))
               hLvlStart = MathMax(HedgeStart_, hLevel + 1);

            if ((HedgeTypeDD && DrawDownPC > hDDStart) || (!HedgeTypeDD && hLevel >= hLvlStart))
            {
               OrderLot = LotSize(LbT * hLotMult);

               if ((CbB > 0 && !hPosCorr) || (CbS > 0 && hPosCorr))
               {
                  Ticket = SendOrder(HedgeSymbol_, OP_BUY, OrderLot, 0, slip, hMagic, MidnightBlue);

                  if (Ticket > 0)
                  {
                     if (hMaxLossPips_ > 0)
                        SLh = hAsk - hMaxLossPips_;

                     if (Debug_)
                        Print("Hedge Buy: Stoploss @ ", DTS(SLh, Digits));
                  }
               }

               if ((CbB > 0 && hPosCorr) || (CbS > 0 && !hPosCorr))
               {
                  Ticket = SendOrder(HedgeSymbol_, OP_SELL, OrderLot, 0, slip, hMagic, Maroon);

                  if (Ticket > 0)
                  {
                     if (hMaxLossPips_ > 0)
                        SLh = hBid + hMaxLossPips_;

                     if (Debug_)
                        Print("Hedge Sell: Stoploss @ ", DTS(SLh, Digits));
                  }
               }

               if (Ticket > 0)
               {
                  hActive = 1;

                  if (HedgeTypeDD)
                     hDDStart += hReEntryPC_;

                  hLvlStart = hLevel + 1;

                  return;
               }
            }
         }
         else if (hActive == 1)
         {
            if (HedgeTypeDD && hDDStart > HedgeStart_ && hDDStart < DrawDownPC + hReEntryPC_)
               hDDStart = DrawDownPC + hReEntryPC_;

            if (hLvlStart == 0)
            {
               if (HedgeTypeDD)
                  hLvlStart = hLevel + 1;
               else
                  hLvlStart = MathMax(HedgeStart_, hLevel + 1);
            }

            if (hLevel >= hLvlStart)
            {
               OrderLot = LotSize(Lots[CbT + CbC - 1] * LotMult * hLotMult);

               if (OrderLot > 0 && ((CbB > 0 && !hPosCorr) || (CbS > 0 && hPosCorr)))
               {
                  Ticket = SendOrder(HedgeSymbol_, OP_BUY, OrderLot, 0, slip, hMagic, MidnightBlue);

                  if (Ticket > 0 && Debug_)
                     Print("Hedge Buy");
               }

               if (OrderLot > 0 && ((CbB > 0 && hPosCorr) || (CbS > 0 && !hPosCorr)))
               {
                  Ticket = SendOrder(HedgeSymbol_, OP_SELL, OrderLot, 0, slip, hMagic, Maroon);

                  if (Ticket > 0 && Debug_)
                     Print("Hedge Sell");
               }

               if (Ticket > 0)
               {
                  hLvlStart = hLevel + 1;

                  return;
               }
            }

            int Index = 0;

            if (!FirstRun && hMaxLossPips_ > 0)
            {
               if (ChB > 0)
               {
                  if (hFixedSL)
                  {
                     if (SLh == 0)
                        SLh = hBid - hMaxLossPips_;
                  }
                  else
                  {
                     if (SLh == 0 || (SLh < BEh && SLh < hBid - hMaxLossPips_))
                        SLh = hBid - hMaxLossPips_;
                     else if (StopTrailAtBE && hBid - hMaxLossPips_ >= BEh)
                        SLh = BEh;
                     else if (SLh >= BEh && !StopTrailAtBE)
                     {
                        if (!ReduceTrailStop)
                           SLh = MathMax(SLh, hBid - hMaxLossPips_);
                        else
                           SLh = MathMax(SLh, hBid - MathMax(StopLevel, hMaxLossPips_ * (1 - (hBid - hMaxLossPips_ - BEh) / (hMaxLossPips_ * 2))));
                     }
                  }

                  if (hBid <= SLh)
                     Index = ExitTrades(H, DarkViolet, "Hedge StopLoss");
               }
               else if (ChS > 0)
               {
                  if (hFixedSL)
                  {
                     if (SLh == 0)
                        SLh = hAsk + hMaxLossPips_;
                  }
                  else
                  {
                     if (SLh == 0 || (SLh > BEh && SLh > hAsk + hMaxLossPips_))
                        SLh = hAsk + hMaxLossPips_;
                     else if (StopTrailAtBE && hAsk + hMaxLossPips_ <= BEh)
                        SLh = BEh;
                     else if (SLh <= BEh && !StopTrailAtBE)
                     {
                        if (!ReduceTrailStop)
                           SLh = MathMin(SLh, hAsk + hMaxLossPips_);
                        else
                           SLh = MathMin(SLh, hAsk + MathMax(StopLevel, hMaxLossPips_ * (1 - (BEh - hAsk - hMaxLossPips_) / (hMaxLossPips_ * 2))));
                     }
                  }

                  if (hAsk >= SLh)
                     Index = ExitTrades(H, DarkViolet, "Hedge StopLoss");
               }
            }

            if (Index == 0 && hTakeProfit_ > 0)
            {
               if (ChB > 0 && hBid > OPhO + hTakeProfit_)
                  Index = ExitTrades(T, DarkViolet, "Hedge TakeProfit reached", ThO);

               if (ChS > 0 && hAsk < OPhO - hTakeProfit_)
                  Index = ExitTrades(T, DarkViolet, "Hedge TakeProfit reached", ThO);
            }

            if (Index > 0)
            {
               PhC = FindClosedPL(H);

               if (Index == ChT)
               {
                  if (HedgeTypeDD)
                     hActive = 2;
                  else
                     hActive = 0;
               }
               return;
            }
         }
      }
      //+-----------------------------------------------------------------+
      //| Check DD% and send Email                                        |
      //+-----------------------------------------------------------------+
      if ((UseEmail || PlaySounds) && !Testing)
      {
         if (EmailCount < 2 && Email[EmailCount] > 0 && DrawDownPC > Email[EmailCount])
         {
            GetLastError();

            if (UseEmail)
            {
               SendMail("Drawdown warning", "Drawdown has exceeded " + DTS(Email[EmailCount] * 100, 2) + "% on " + Symbol() + " " + sTF);
               Error = GetLastError();

               if (Error > 0)
                  Print("Email DD: ", DTS(DrawDownPC * 100, 2), " Error: ", Error, " (", ErrorDescription(Error), ")");
               else if (Debug_)
                  Print("DrawDown Email sent for ", Symbol(), " ", sTF, "  DD: ", DTS(DrawDownPC * 100, 2));
               EmailSent = TimeCurrent();
               EmailCount++;
            }

            if (PlaySounds)
               PlaySound(AlertSound);
         }
         else if (EmailCount > 0 && EmailCount < 3 && DrawDownPC < Email[EmailCount] &&
                TimeCurrent() > EmailSent + EmailHours * 3600)
            EmailCount--;
      }
   }   // opb *********************
   //+-----------------------------------------------------------------+
   //| Display Overlay Code                                            |
   //+-----------------------------------------------------------------+
   string dMess = "";

   if ((Testing && Visual) || !Testing)
   {
      if (displayOverlay)
      {
         color Colour;
         int   dDigits;

         ObjSetTxt("B3VTime", TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS));
         // This fixes a problem with OncePerBar & display of Stop Trade Amount always
         // showing zero, but is a hack ... Blessing needs to be re-engineered.
         // display of Stop Trade Amount:
         // double stop_trade_amount = -(Pb + Ph) / PortionBalance;   // opb
         // DrawLabel("B3VSTAm", InitialAccountMultiPortion, 175, 2, displayColorLoss);
         // static double previous_stop_trade_amount;

         if (stop_trade_amount != 0)
         {
            previous_stop_trade_amount = stop_trade_amount;
            DrawLabel("B3VSTAm", stop_trade_amount, 175, 2, displayColorLoss);
         }
         else
            DrawLabel("B3VSTAm", previous_stop_trade_amount, 167, 2, displayColorLoss);
         // DrawLabel("B3VSTAm", stop_trade_amount, 167, 2, displayColorLoss);
         // End of fix

         if (UseHolidayShutdown)
         {
            ObjSetTxt("B3VHolF", TimeToStr(HolFirst, TIME_DATE));
            ObjSetTxt("B3VHolT", TimeToStr(HolLast, TIME_DATE));
         }

         DrawLabel("B3VPBal", PortionBalance, 167);

         if (DrawDownPC > 0.4)
            Colour = displayColorLoss;
         else if (DrawDownPC > 0.3)
            Colour = Orange;
         else if (DrawDownPC > 0.2)
            Colour = Yellow;
         else if (DrawDownPC > 0.1)
            Colour = displayColorProfit;
         else
            Colour = displayColor;

         DrawLabel("B3VDrDn", DrawDownPC * 100, 315, 2, Colour);

         if (UseHedge_ && HedgeTypeDD)
            ObjSetTxt("B3VhDDm", DTS(hDDStart * 100, 2));
         else if (UseHedge_ && !HedgeTypeDD)
         {
            DrawLabel("B3VhLvl", CbT + CbC, 318, 0);
            ObjSetTxt("B3VhLvT", DTS(hLvlStart, 0));
         }

         ObjSetTxt("B3VSLot", DTS(Lot_ * LotMult, 2));

         if (ProfitPot >= 0)
            DrawLabel("B3VPPot", ProfitPot, 190);
         else
         {
            ObjSetTxt("B3VPPot", DTS(ProfitPot, 2), 0, displayColorLoss);
            dDigits = Digit[ArrayBsearch(Digit, (int) -ProfitPot), 1];
            ObjSet("B3VPPot", 186 - dDigits * 7);
         }

         if (UseEarlyExit && EEpc < 1)
         {
            if (ObjectFind("B3SEEPr") == -1)
               CreateLabel("B3SEEPr", "/", 0, CORNER_LEFT_UPPER, 220, 12);

            if (ObjectFind("B3VEEPr") == -1)
               CreateLabel("B3VEEPr", "", 0, CORNER_LEFT_UPPER, 229, 12);

            ObjSetTxt("B3VEEPr", DTS(PbTarget * PipValue * MathAbs(LbB - LbS), 2));
         }
         else
         {
            ObjDel("B3SEEPr");
            ObjDel("B3VEEPr");
         }

         if (SLb > 0)
            DrawLabel("B3VPrSL", SLb, 190, Digits);
         else if (bSL > 0)
            DrawLabel("B3VPrSL", bSL, 190, Digits);
         else if (bTS > 0)
            DrawLabel("B3VPrSL", bTS, 190, Digits);
         else
            DrawLabel("B3VPrSL", 0, 190, 2);

         if (Pb >= 0)
         {
            DrawLabel("B3VPnPL", Pb, 190, 2, displayColorProfit);
            ObjSetTxt("B3VPPip", DTS(PbPips, 1), 0, displayColorProfit);
            ObjSet("B3VPPip", 229);
         }
         else
         {
            ObjSetTxt("B3VPnPL", DTS(Pb, 2), 0, displayColorLoss);
            dDigits = Digit[ArrayBsearch(Digit, (int) -Pb), 1];
            ObjSet("B3VPnPL", 186 - dDigits * 7);
            ObjSetTxt("B3VPPip", DTS(PbPips, 1), 0, displayColorLoss);
            ObjSet("B3VPPip", 229);
         }

         if (PbMax >= 0)
            DrawLabel("B3VPLMx", PbMax, 190, 2, displayColorProfit);
         else
         {
            ObjSetTxt("B3VPLMx", DTS(PbMax, 2), 0, displayColorLoss);
            dDigits = Digit[ArrayBsearch(Digit, (int) -PbMax), 1];
            ObjSet("B3VPLMx", 186 - dDigits * 7);
         }

         if (PbMin < 0)
            ObjSet("B3VPLMn", 225);
         else
            ObjSet("B3VPLMn", 229);

         ObjSetTxt("B3VPLMn", DTS(PbMin, 2), 0, displayColorLoss);

         if (CbT + CbC < BreakEvenTrade && CbT + CbC < MaxTrades)
            Colour = displayColor;
         else if (CbT + CbC < MaxTrades)
            Colour = Orange;
         else
            Colour = displayColorLoss;

         if (CbB > 0)
         {
            ObjSetTxt("B3LType", "Buy:");
            DrawLabel("B3VOpen", CbB, 207, 0, Colour);
         }
         else if (CbS > 0)
         {
            ObjSetTxt("B3LType", "Sell:");
            DrawLabel("B3VOpen", CbS, 207, 0, Colour);
         }
         else
         {
            ObjSetTxt("B3LType", "");
            ObjSetTxt("B3VOpen", DTS(0, 0), 0, Colour);
            ObjSet("B3VOpen", 207);
         }

         ObjSetTxt("B3VLots", DTS(LbT, 2));
         ObjSetTxt("B3VMove", DTS(Moves, 0));
         DrawLabel("B3VMxDD", MaxDD, 107);
         DrawLabel("B3VDDPC", MaxDDPer, 229);

         if (Trend == 0)
         {
            ObjSetTxt("B3LTrnd", "Trend is UP", 10, displayColorProfit);

            if (ObjectFind("B3ATrnd") == -1)
               CreateLabel("B3ATrnd", "", 0, CORNER_LEFT_UPPER, 160, 20, displayColorProfit, "Wingdings");

            ObjectSetText("B3ATrnd", "é", displayFontSize + 9, "Wingdings", displayColorProfit);
            ObjSet("B3ATrnd", 160);
            ObjectSet("B3ATrnd", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);

            if (StringLen(ATrend) > 0)
            {
               if (ObjectFind("B3AATrn") == -1)
                  CreateLabel("B3AATrn", "", 0, CORNER_LEFT_UPPER, 200, 20, displayColorProfit, "Wingdings");

               if (ATrend == "D")
               {
                  ObjectSetText("B3AATrn", "ê", displayFontSize + 9, "Wingdings", displayColorLoss);
                  ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20 + 5);
               }
               else if (ATrend == "R")
               {
                  ObjSetTxt("B3AATrn", "R", 10, Orange);
                  ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);
               }
            }
            else
               ObjDel("B3AATrn");
         }
         else if (Trend == 1)
         {
            ObjSetTxt("B3LTrnd", "Trend is DOWN", 10, displayColorLoss);

            if (ObjectFind("B3ATrnd") == -1)
               CreateLabel("B3ATrnd", "", 0, CORNER_LEFT_UPPER, 210, 20, displayColorLoss, "WingDings");

            ObjectSetText("B3ATrnd", "ê", displayFontSize + 9, "Wingdings", displayColorLoss);
            ObjSet("B3ATrnd", 210);
            ObjectSet("B3ATrnd", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20 + 5);

            if (StringLen(ATrend) > 0)
            {
               if (ObjectFind("B3AATrn") == -1)
                  CreateLabel("B3AATrn", "", 0, CORNER_LEFT_UPPER, 250, 20, displayColorProfit, "Wingdings");

               if (ATrend == "U")
               {
                  ObjectSetText("B3AATrn", "é", displayFontSize + 9, "Wingdings", displayColorProfit);
                  ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);
               }
               else if (ATrend == "R")
               {
                  ObjSetTxt("B3AATrn", "R", 10, Orange);
                  ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);
               }
            }
            else
               ObjDel("B3AATrn");
         }
         else if (Trend == 2)
         {
            ObjSetTxt("B3LTrnd", "Trend is Ranging", 10, Orange);
            ObjDel("B3ATrnd");

            if (StringLen(ATrend) > 0)
            {
               if (ObjectFind("B3AATrn") == -1)
                  CreateLabel("B3AATrn", "", 0, CORNER_LEFT_UPPER, 220, 20, displayColorProfit, "Wingdings");

               if (ATrend == "U")
               {
                  ObjectSetText("B3AATrn", "é", displayFontSize + 9, "Wingdings", displayColorProfit);
                  ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20);
               }
               else if (ATrend == "D")
               {
                  ObjectSetText("B3AATrn", "ê", displayFontSize + 8, "Wingdings", displayColorLoss);
                  ObjectSet("B3AATrn", OBJPROP_YDISTANCE, displayYcord + displaySpacing * 20 + 5);
               }
            }
            else
               ObjDel("B3AATrn");
         }

         if (PaC != 0)
         {
            if (ObjectFind("B3LClPL") == -1)
               CreateLabel("B3LClPL", "Closed P/L", 0, CORNER_LEFT_UPPER, 312, 11);

            if (ObjectFind("B3VClPL") == -1)
               CreateLabel("B3VClPL", "", 0, CORNER_LEFT_UPPER, 327, 12);

            if (PaC >= 0)
               DrawLabel("B3VClPL", PaC, 327, 2, displayColorProfit);
            else
            {
               ObjSetTxt("B3VClPL", DTS(PaC, 2), 0, displayColorLoss);
               dDigits = Digit[ArrayBsearch(Digit, (int) -PaC), 1];
               ObjSet("B3VClPL", 323 - dDigits * 7);
            }
         }
         else
         {
            ObjDel("B3LClPL");
            ObjDel("B3VClPL");
         }

         if (hActive == 1)
         {
            if (ObjectFind("B3LHdge") == -1)
               CreateLabel("B3LHdge", "Hedge", 0, CORNER_LEFT_UPPER, 323, 13);

            if (ObjectFind("B3VhPro") == -1)
               CreateLabel("B3VhPro", "", 0, CORNER_LEFT_UPPER, 312, 14);

            if (Ph >= 0)
               DrawLabel("B3VhPro", Ph, 312, 2, displayColorProfit);
            else
            {
               ObjSetTxt("B3VhPro", DTS(Ph, 2), 0, displayColorLoss);
               dDigits = Digit[ArrayBsearch(Digit, (int) -Ph), 1];
               ObjSet("B3VhPro", 308 - dDigits * 7);
            }

            if (ObjectFind("B3VhPMx") == -1)
               CreateLabel("B3VhPMx", "", 0, CORNER_LEFT_UPPER, 312, 15);

            if (PhMax >= 0)
               DrawLabel("B3VhPMx", PhMax, 312, 2, displayColorProfit);
            else
            {
               ObjSetTxt("B3VhPMx", DTS(PhMax, 2), 0, displayColorLoss);
               dDigits = Digit[ArrayBsearch(Digit, (int) -PhMax), 1];
               ObjSet("B3VhPMx", 308 - dDigits * 7);
            }

            if (ObjectFind("B3ShPro") == -1)
               CreateLabel("B3ShPro", "/", 0, CORNER_LEFT_UPPER, 342, 15);

            if (ObjectFind("B3VhPMn") == -1)
               CreateLabel("B3VhPMn", "", 0, CORNER_LEFT_UPPER, 351, 15, displayColorLoss);

            if (PhMin < 0)
               ObjSet("B3VhPMn", 347);
            else
               ObjSet("B3VhPMn", 351);

            ObjSetTxt("B3VhPMn", DTS(PhMin, 2), 0, displayColorLoss);

            if (ObjectFind("B3LhTyp") == -1)
               CreateLabel("B3LhTyp", "", 0, CORNER_LEFT_UPPER, 292, 16);

            if (ObjectFind("B3VhOpn") == -1)
               CreateLabel("B3VhOpn", "", 0, CORNER_LEFT_UPPER, 329, 16);

            if (ChB > 0)
            {
               ObjSetTxt("B3LhTyp", "Buy:");
               DrawLabel("B3VhOpn", ChB, 329, 0);
            }
            else if (ChS > 0)
            {
               ObjSetTxt("B3LhTyp", "Sell:");
               DrawLabel("B3VhOpn", ChS, 329, 0);
            }
            else
            {
               ObjSetTxt("B3LhTyp", "");
               ObjSetTxt("B3VhOpn", DTS(0, 0));
               ObjSet("B3VhOpn", 329);
            }

            if (ObjectFind("B3ShOpn") == -1)
               CreateLabel("B3ShOpn", "/", 0, CORNER_LEFT_UPPER, 342, 16);

            if (ObjectFind("B3VhLot") == -1)
               CreateLabel("B3VhLot", "", 0, CORNER_LEFT_UPPER, 351, 16);

            ObjSetTxt("B3VhLot", DTS(LhT, 2));
         }
         else
         {
            ObjDel("B3LHdge");
            ObjDel("B3VhPro");
            ObjDel("B3VhPMx");
            ObjDel("B3ShPro");
            ObjDel("B3VhPMn");
            ObjDel("B3LhTyp");
            ObjDel("B3VhOpn");
            ObjDel("B3ShOpn");
            ObjDel("B3VhLot");
         }
      }

      if (displayLines)
      {
         if (BEb > 0)
         {
            if (ObjectFind("B3LBELn") == -1)
               CreateLine("B3LBELn", DodgerBlue, 1, 0);

            ObjectMove("B3LBELn", 0, iTime(_Symbol, Period(), 1), BEb);
         }
         else
            ObjDel("B3LBELn");

         if (TPa > 0)
         {
            if (ObjectFind("B3LTPLn") == -1)
               CreateLine("B3LTPLn", Gold, 1, 0);

            ObjectMove("B3LTPLn", 0, iTime(_Symbol, Period(), 1), TPa);
         }
         else if (TPb > 0 && nLots != 0)
         {
            if (ObjectFind("B3LTPLn") == -1)
               CreateLine("B3LTPLn", Gold, 1, 0);

            ObjectMove("B3LTPLn", 0, iTime(_Symbol, Period(), 1), TPb);
         }
         else
            ObjDel("B3LTPLn");

         if (OPbN > 0)
         {
            if (ObjectFind("B3LOPLn") == -1)
               CreateLine("B3LOPLn", Red, 1, 4);

            ObjectMove("B3LOPLn", 0, iTime(_Symbol, Period(), 1), OPbN);
         }
         else
            ObjDel("B3LOPLn");

         if (bSL > 0)
         {
            if (ObjectFind("B3LSLbT") == -1)
               CreateLine("B3LSLbT", Red, 1, 3);

            ObjectMove("B3LSLbT", 0, iTime(_Symbol, Period(), 1), bSL);
         }
         else
            ObjDel("B3LSLbT");

         if (bTS > 0)
         {
            if (ObjectFind("B3LTSbT") == -1)
               CreateLine("B3LTSbT", Gold, 1, 3);

            ObjectMove("B3LTSbT", 0, iTime(_Symbol, Period(), 1), bTS);
         }
         else
            ObjDel("B3LTSbT");

         if (hActive == 1 && BEa > 0)
         {
            if (ObjectFind("B3LNBEL") == -1)
               CreateLine("B3LNBEL", Crimson, 1, 0);

            ObjectMove("B3LNBEL", 0, iTime(_Symbol, Period(), 1), BEa);
         }
         else
            ObjDel("B3LNBEL");

         if (TPbMP > 0)
         {
            if (ObjectFind("B3LMPLn") == -1)
               CreateLine("B3LMPLn", Gold, 1, 4);

            ObjectMove("B3LMPLn", 0, iTime(_Symbol, Period(), 1), TPbMP);
         }
         else
            ObjDel("B3LMPLn");

         if (SLb > 0)
         {
            if (ObjectFind("B3LTSLn") == -1)
               CreateLine("B3LTSLn", Gold, 1, 2);

            ObjectMove("B3LTSLn", 0, iTime(_Symbol, Period(), 1), SLb);
         }
         else
            ObjDel("B3LTSLn");

         if (hThisChart && BEh > 0)
         {
            if (ObjectFind("B3LhBEL") == -1)
               CreateLine("B3LhBEL", SlateBlue, 1, 0);

            ObjectMove("B3LhBEL", 0, iTime(_Symbol, Period(), 1), BEh);
         }
         else
            ObjDel("B3LhBEL");

         if (hThisChart && SLh > 0)
         {
            if (ObjectFind("B3LhSLL") == -1)
               CreateLine("B3LhSLL", SlateBlue, 1, 3);

            ObjectMove("B3LhSLL", 0, iTime(_Symbol, Period(), 1), SLh);
         }
         else
            ObjDel("B3LhSLL");
      }
      else
      {
         ObjDel("B3LBELn");
         ObjDel("B3LTPLn");
         ObjDel("B3LOPLn");
         ObjDel("B3LSLbT");
         ObjDel("B3LTSbT");
         ObjDel("B3LNBEL");
         ObjDel("B3LMPLn");
         ObjDel("B3LTSLn");
         ObjDel("B3LhBEL");
         ObjDel("B3LhSLL");
      }

      if (CCIEntry_ && displayCCI)
      {
         if (cci_01 > 0 && cci_11 > 0)
            ObjectSetText("B3VCm05", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
         else if (cci_01 < 0 && cci_11 < 0)
            ObjectSetText("B3VCm05", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
         else
            ObjectSetText("B3VCm05", "Ø", displayFontSize + 6, "Wingdings", Orange);

         if (cci_02 > 0 && cci_12 > 0)
            ObjectSetText("B3VCm15", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
         else if (cci_02 < 0 && cci_12 < 0)
            ObjectSetText("B3VCm15", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
         else
            ObjectSetText("B3VCm15", "Ø", displayFontSize + 6, "Wingdings", Orange);

         if (cci_03 > 0 && cci_13 > 0)
            ObjectSetText("B3VCm30", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
         else if (cci_03 < 0 && cci_13 < 0)
            ObjectSetText("B3VCm30", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
         else
            ObjectSetText("B3VCm30", "Ø", displayFontSize + 6, "Wingdings", Orange);

         if (cci_04 > 0 && cci_14 > 0)
            ObjectSetText("B3VCm60", "Ù", displayFontSize + 6, "Wingdings", displayColorProfit);
         else if (cci_04 < 0 && cci_14 < 0)
            ObjectSetText("B3VCm60", "Ú", displayFontSize + 6, "Wingdings", displayColorLoss);
         else
            ObjectSetText("B3VCm60", "Ø", displayFontSize + 6, "Wingdings", Orange);
      }

      if (Debug_)
      {
         string dSpace;

         for (int Index = 0; Index <= 190; Index++)
            dSpace = dSpace + " ";

         dMess = "\n\n" + dSpace + "Ticket   Magic     Type Lots OpenPrice  Costs  Profit  Potential";

         for (int Order = 0; Order < OrdersTotal(); Order++)
         {
            if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
               continue;

            if (OrderMagicNumber() != Magic && OrderMagicNumber() != hMagic)
               continue;

            dMess = (dMess + "\n" + dSpace + " " + (string) OrderTicket() + "  " + DTS(OrderMagicNumber(), 0) + "   " + (string) OrderType());
            dMess = (dMess + "   " + DTS(OrderLots(), LotDecimal) + "  " + DTS(OrderOpenPrice(), Digits));
            dMess = (dMess + "     " + DTS(OrderSwap() + OrderCommission(), 2));
            dMess = (dMess + "    " + DTS(OrderProfit() + OrderSwap() + OrderCommission(), 2));

            if (OrderMagicNumber() != Magic)
               continue;
            else if (OrderType() == OP_BUY)
               dMess = (dMess + "      " + DTS(OrderLots() * (TPb - OrderOpenPrice()) * PipVal2 + OrderSwap() + OrderCommission(), 2));
            else if (OrderType() == OP_SELL)
               dMess = (dMess + "      " + DTS(OrderLots() * (OrderOpenPrice() - TPb) * PipVal2 + OrderSwap() + OrderCommission(), 2));
         }

         if (!dLabels)
         {
            dLabels = true;
            CreateLabel("B3LPipV", "Pip Value", 0, CORNER_LEFT_LOWER, 0, 0);
            CreateLabel("B3VPipV", "", 0, CORNER_LEFT_LOWER, 100, 0);
            CreateLabel("B3LDigi", "Digits Value", 0, CORNER_LEFT_LOWER, 0, 1);
            CreateLabel("B3VDigi", "", 0, CORNER_LEFT_LOWER, 100, 1);
            ObjSetTxt("B3VDigi", DTS(Digits, 0));
            CreateLabel("B3LPoin", "Point Value", 0, CORNER_LEFT_LOWER, 0, 2);
            CreateLabel("B3VPoin", "", 0, CORNER_LEFT_LOWER, 100, 2);
            ObjSetTxt("B3VPoin", DTS(Point, Digits));
            CreateLabel("B3LSprd", "Spread Value", 0, CORNER_LEFT_LOWER, 0, 3);
            CreateLabel("B3VSprd", "", 0, CORNER_LEFT_LOWER, 100, 3);
            CreateLabel("B3LBid", "Bid Value", 0, CORNER_LEFT_LOWER, 0, 4);
            CreateLabel("B3VBid", "", 0, CORNER_LEFT_LOWER, 100, 4);
            CreateLabel("B3LAsk", "Ask Value", 0, CORNER_LEFT_LOWER, 0, 5);
            CreateLabel("B3VAsk", "", 0, CORNER_LEFT_LOWER, 100, 5);
            CreateLabel("B3LLotP", "Lot Step", 0, CORNER_LEFT_LOWER, 200, 0);
            CreateLabel("B3VLotP", "", 0, CORNER_LEFT_LOWER, 300, 0);
            ObjSetTxt("B3VLotP", DTS(MarketInfo(Symbol(), MODE_LOTSTEP), LotDecimal));
            CreateLabel("B3LLotX", "Lot Max", 0, CORNER_LEFT_LOWER, 200, 1);
            CreateLabel("B3VLotX", "", 0, CORNER_LEFT_LOWER, 300, 1);
            ObjSetTxt("B3VLotX", DTS(MarketInfo(Symbol(), MODE_MAXLOT), 0));
            CreateLabel("B3LLotN", "Lot Min", 0, CORNER_LEFT_LOWER, 200, 2);
            CreateLabel("B3VLotN", "", 0, CORNER_LEFT_LOWER, 300, 2);
            ObjSetTxt("B3VLotN", DTS(MarketInfo(Symbol(), MODE_MINLOT), LotDecimal));
            CreateLabel("B3LLotD", "Lot Decimal", 0, CORNER_LEFT_LOWER, 200, 3);
            CreateLabel("B3VLotD", "", 0, CORNER_LEFT_LOWER, 300, 3);
            ObjSetTxt("B3VLotD", DTS(LotDecimal, 0));
            CreateLabel("B3LAccT", "Account Type", 0, CORNER_LEFT_LOWER, 200, 4);
            CreateLabel("B3VAccT", "", 0, CORNER_LEFT_LOWER, 300, 4);
            ObjSetTxt("B3VAccT", DTS(AccountType, 0));
            CreateLabel("B3LPnts", "Pip", 0, CORNER_LEFT_LOWER, 200, 5);
            CreateLabel("B3VPnts", "", 0, CORNER_LEFT_LOWER, 300, 5);
            ObjSetTxt("B3VPnts", DTS(Pip, Digits));
            CreateLabel("B3LTicV", "Tick Value", 0, CORNER_LEFT_LOWER, 400, 0);
            CreateLabel("B3VTicV", "", 0, CORNER_LEFT_LOWER, 500, 0);
            CreateLabel("B3LTicS", "Tick Size", 0, CORNER_LEFT_LOWER, 400, 1);
            CreateLabel("B3VTicS", "", 0, CORNER_LEFT_LOWER, 500, 1);
            ObjSetTxt("B3VTicS", DTS(MarketInfo(Symbol(), MODE_TICKSIZE), Digits));
            CreateLabel("B3LLev", "Leverage", 0, CORNER_LEFT_LOWER, 400, 2);
            CreateLabel("B3VLev", "", 0, CORNER_LEFT_LOWER, 500, 2);
            ObjSetTxt("B3VLev", DTS(AccountInfoInteger(ACCOUNT_LEVERAGE), 0) + ":1");
            CreateLabel("B3LSGTF", "SmartGrid", 0, CORNER_LEFT_LOWER, 400, 3);

            if (UseSmartGrid)
               CreateLabel("B3VSGTF", "True", 0, CORNER_LEFT_LOWER, 500, 3);
            else
               CreateLabel("B3VSGTF", "False", 0, CORNER_LEFT_LOWER, 500, 3);

            CreateLabel("B3LCOTF", "Close Oldest", 0, CORNER_LEFT_LOWER, 400, 4);

            if (UseCloseOldest)
               CreateLabel("B3VCOTF", "True", 0, CORNER_LEFT_LOWER, 500, 4);
            else
               CreateLabel("B3VCOTF", "False", 0, CORNER_LEFT_LOWER, 500, 4);

            CreateLabel("B3LUHTF", "Hedge", 0, CORNER_LEFT_LOWER, 400, 5);

            if (UseHedge_ && HedgeTypeDD)
               CreateLabel("B3VUHTF", "DrawDown", 0, CORNER_LEFT_LOWER, 500, 5);
            else if (UseHedge_ && !HedgeTypeDD)
               CreateLabel("B3VUHTF", "Level", 0, CORNER_LEFT_LOWER, 500, 5);
            else
               CreateLabel("B3VUHTF", "False", 0, CORNER_LEFT_LOWER, 500, 5);
         }

         ObjSetTxt("B3VPipV", DTS(PipValue, 2));
         ObjSetTxt("B3VSprd", DTS(ASK - BID, Digits));
         ObjSetTxt("B3VBid", DTS(BID, Digits));
         ObjSetTxt("B3VAsk", DTS(ASK, Digits));
         ObjSetTxt("B3VTicV", DTS(MarketInfo(Symbol(), MODE_TICKVALUE), Digits));
      }

      if (EmergencyWarning)
      {
         if (ObjectFind("B3LClos") == -1)
            CreateLabel("B3LClos", "", 5, CORNER_LEFT_UPPER, 0, 23, displayColorLoss);

         ObjSetTxt("B3LClos", "WARNING: EmergencyCloseAll is TRUE", 5, displayColorLoss);
      }
      else if (ShutDown_)
      {
         if (ObjectFind("B3LClos") == -1)
            CreateLabel("B3LClos", "", 5, CORNER_LEFT_UPPER, 0, 23, displayColorLoss);

         ObjSetTxt("B3LClos", "Trading will stop when this basket closes.", 5, displayColorLoss);
      }
      else if (HolShutDown != 1)
         ObjDel("B3LClos");
   }

   WindowRedraw();
   FirstRun = false;
   Comment(CS, dMess);
}


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
}


//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
{
   // Balance max + min Drawdown + Trades Number:
   double Balance = TesterStatistics(STAT_PROFIT);
   double MinDD = TesterStatistics(STAT_BALANCE_DD);

	// Test minimum margin first //
	if (TesterStatistics(STAT_MIN_MARGINLEVEL) < TesterMinMarginPercent) {
		return 0;
	}
	if (TesterSelection == 2) {
	   if (MinDD > 0.0)
		  MinDD = 1.0 / MinDD;

	   double Trades = TesterStatistics(STAT_TRADES);

	   return (MathRound(Balance * Balance * Trades * MinDD));
	}
	// return (Balance);
	return (TesterStatistics(STAT_PROFIT));
}


//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
}


//+-----------------------------------------------------------------+
//| Check Lot Size Function                                         |
//+-----------------------------------------------------------------+
double LotSize(double NewLot)
{
   NewLot = ND(NewLot, LotDecimal);
   NewLot = MathMin(NewLot, MarketInfo(Symbol(), MODE_MAXLOT));
   NewLot = MathMax(NewLot, MinLotSize);

   return(NewLot);
}


double margin_maxlots()
{
   return(AccountInfoDouble(ACCOUNT_MARGIN_FREE) / MarketInfo(Symbol(), MODE_MARGINREQUIRED));
}


double portion_maxlots()
{
   return(PortionBalance / MarketInfo(Symbol(), MODE_MARGINREQUIRED));
}


//+-----------------------------------------------------------------+
//| Open Order Function                                             |
//+-----------------------------------------------------------------+
int SendOrder(string OSymbol, int OCmd, double OLot, double OPrice, int OSlip, int OMagic, color OColor = CLR_NONE)
{
   if (FirstRun)
      return(-1);

   int    Ticket = 0;
   int    Tries  = 0;
   int    OType  = (int) MathMod(OCmd, 2);
   double OrderPrice;

   // check margin against MinMarginPercent
   if (UseMinMarginPercent && AccountInfoDouble(ACCOUNT_MARGIN) > 0)
   {
      // double ml = ND(AccountInfoDouble(ACCOUNT_EQUITY) / AccountInfoDouble(ACCOUNT_MARGIN) * 100, 2);
      double ml = ND(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2);
      Print("Account Margin Level: " + DTS(ml, 2));
      if (ml < MinMarginPercent)
      {
         Print("Margin percent " + (string) ml + "% too low to open new trade");
         return -1;
      }
   }

   // Sanity check lots vs. portion and margin ... r.f.
   if (OLot > (portion_maxlots() - LbT))       // Request lots vs Portion - Current lots out
   {
      Print("Insufficient Portion free ", OSymbol, "  Type: ", OType, " Lots: ", DTS(OLot, 2),
           "  Free margin: ", DTS(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2), "  Margin Maxlots: ", DTS(margin_maxlots(), 2), "  Portion Maxlots: ", DTS(portion_maxlots(), 2), "  Current Lots: ", DTS(LbT, 2));
      return(-1);

      // OLot = portion_maxlots() - LbT - MinLotSize;
      // Print("Reducing order to: ", DTS(OLot, 2));
   }

   if (AccountFreeMarginCheck(OSymbol, OType, OLot) <= 0 || GetLastError() == ERR_NOT_ENOUGH_MONEY)
   {
      Print("Not enough margin ", OSymbol, "  Type: ", OType, " Lots: ", DTS(OLot, 2),
           "  Free margin: ", DTS(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2), "  Margin Maxlots: ", DTS(margin_maxlots(), 2), "  Portion Maxlots: ", DTS(portion_maxlots(), 2), "  Current Lots: ", DTS(LbT, 2));

      return(-1);
   }

   if (MaxSpread > 0 && MarketInfo(OSymbol, MODE_SPREAD) * Point / Pip > MaxSpread)
      return(-1);

   while (Tries < 5)
   {
      Tries++;

      while (IsTradeContextBusy())
         Sleep(100);

      if (IsStopped())
         return(-1);
      else if (OType == 0)
         OrderPrice = ND(MarketInfo(OSymbol, MODE_ASK) + OPrice, (int) MarketInfo(OSymbol, MODE_DIGITS));
      else
         OrderPrice = ND(MarketInfo(OSymbol, MODE_BID) + OPrice, (int) MarketInfo(OSymbol, MODE_DIGITS));

      Ticket = OrderSend(OSymbol, OCmd, OLot, OrderPrice, OSlip, 0, 0, TradeComment, OMagic, 0, OColor);

      if (Ticket < 0)
      {
         Error = GetLastError();

         if (Error != 0)
            Print("Error ", Error, "(", ErrorDescription(Error), ") opening order - ",
                 "  Symbol: ", OSymbol, "  TradeOP: ", OCmd, "  OType: ", OType,
                 "  Ask: ", DTS(MarketInfo(OSymbol, MODE_ASK), Digits),
                 "  Bid: ", DTS(MarketInfo(OSymbol, MODE_BID), Digits), "  OPrice: ", DTS(OPrice, Digits), "  Price: ", DTS(OrderPrice, Digits), "  Lots: ", DTS(OLot, 2));

         switch (Error)
         {
         case ERR_TRADE_DISABLED:
            AllowTrading = false;
            Print("Broker has disallowed EAs on this account");
            Tries = 5;
            break;
         case ERR_OFF_QUOTES:
         case ERR_INVALID_PRICE:
            Sleep(5000);
         case ERR_PRICE_CHANGED:
         case ERR_REQUOTE:
            RefreshRates();
         case ERR_SERVER_BUSY:
         case ERR_NO_CONNECTION:
         case ERR_BROKER_BUSY:
         case ERR_TRADE_CONTEXT_BUSY:
            Tries++;
            break;
         case 149:          //ERR_TRADE_HEDGE_PROHIBITED:
            if (Debug_)
               Print("Hedge trades are not supported on this pair");

            UseHedge_ = false;
            Tries     = 5;
            break;
         default:
            Tries = 5;
         }
      }
      else
      {
         if (PlaySounds)
            PlaySound(AlertSound);

         break;
      }
   }

   return(Ticket);
}


//+-----------------------------------------------------------------+
//| Modify Order Function                                           |
//+-----------------------------------------------------------------+
bool ModifyOrder(double OrderOP, double OrderSL, color Color = CLR_NONE)
{
   bool Success = false;
   int  Tries   = 0;

   while (Tries < 5 && !Success)
   {
      Tries++;

      while (IsTradeContextBusy())
         Sleep(100);

      if (IsStopped())
         return(false);      //(-1)

      Success = OrderModify(OrderTicket(), OrderOP, OrderSL, 0, 0, Color);

      if (!Success)
      {
         Error = GetLastError();

         if (Error > 1)
         {
            Print("Error ", Error, " (", ErrorDescription(Error), ") modifying order ", OrderTicket(), "  Ask: ", Ask,
                 "  Bid: ", Bid, "  OrderPrice: ", OrderOP, "  StopLevel: ", StopLevel, "  SL: ", OrderSL, "  OSL: ", OrderStopLoss());

            switch (Error)
            {
            case ERR_TRADE_MODIFY_DENIED:
               Sleep(10000);
            case ERR_OFF_QUOTES:
            case ERR_INVALID_PRICE:
               Sleep(5000);
            case ERR_PRICE_CHANGED:
            case ERR_REQUOTE:
               RefreshRates();
            case ERR_SERVER_BUSY:
            case ERR_NO_CONNECTION:
            case ERR_BROKER_BUSY:
            case ERR_TRADE_CONTEXT_BUSY:
            case ERR_TRADE_TIMEOUT:
               Tries++;
               break;
            default:
               Tries = 5;
               break;
            }
         }
         else
            Success = true;
      }
      else
         break;
   }

   return(Success);
}


//+-------------------------------------------------------------------------+
//| Exit Trade Function - Type: All Basket Hedge Ticket Pending             |
//+-------------------------------------------------------------------------+
int ExitTrades(int Type, color Color, string Reason, int OTicket = 0)
{
   static int OTicketNo;
   bool       Success;
   int        Tries = 0, Closed = 0, CloseCount = 0;
   int        CloseTrades[, 2];
   double     OPrice;
   string     s;
   ca = Type;

   if (Type == T)
   {
      if (OTicket == 0)
         OTicket = OTicketNo;
      else
         OTicketNo = OTicket;
   }

   for (int Order = OrdersTotal() - 1; Order >= 0; Order--)
   {
      if (!OrderSelect(Order, SELECT_BY_POS, MODE_TRADES))
         continue;

      if (Type == B && OrderMagicNumber() != Magic)
         continue;
      else if (Type == H && OrderMagicNumber() != hMagic)
         continue;
      else if (Type == A && OrderMagicNumber() != Magic && OrderMagicNumber() != hMagic)
         continue;
      else if (Type == T && OrderTicket() != OTicket)
         continue;
      else if (Type == P && (OrderMagicNumber() != Magic || OrderType() <= OP_SELL))
         continue;

      ArrayResize(CloseTrades, CloseCount + 1);
      CloseTrades[CloseCount, 0] = (int) OrderOpenTime();
      CloseTrades[CloseCount, 1] = OrderTicket();
      CloseCount++;
   }

   if (CloseCount > 0)
   {
      if (!UseFIFO)
         ArraySort(CloseTrades, WHOLE_ARRAY, 0, MODE_DESCEND);
      else if (CloseCount != ArraySort(CloseTrades))
         Print("Error sorting CloseTrades Array");

      for (int Order = 0; Order < CloseCount; Order++)
      {
         if (!OrderSelect(CloseTrades[Order, 1], SELECT_BY_TICKET))
            continue;

         while (IsTradeContextBusy())
            Sleep(100);

         if (IsStopped())
            return(-1);
         else if (OrderType() > OP_SELL)
            Success = OrderDelete(OrderTicket(), Color);
         else
         {
            if (OrderType() == OP_BUY)
               OPrice = ND(MarketInfo(OrderSymbol(), MODE_BID), (int) MarketInfo(OrderSymbol(), MODE_DIGITS));
            else
               OPrice = ND(MarketInfo(OrderSymbol(), MODE_ASK), (int) MarketInfo(OrderSymbol(), MODE_DIGITS));

            Success = OrderClose(OrderTicket(), OrderLots(), OPrice, slip, Color);
         }

         if (Success)
            Closed++;
         else
         {
            Error = GetLastError();
            Print("Error ", Error, " (", ErrorDescription(Error), ") closing order ", OrderTicket());

            switch (Error)
            {
            case ERR_NO_ERROR:
            case ERR_NO_RESULT:
               Success = true;
               break;
            case ERR_OFF_QUOTES:
            case ERR_INVALID_PRICE:
               Sleep(5000);
            case ERR_PRICE_CHANGED:
            case ERR_REQUOTE:
               RefreshRates();
            case ERR_SERVER_BUSY:
            case ERR_NO_CONNECTION:
            case ERR_BROKER_BUSY:
            case ERR_TRADE_CONTEXT_BUSY:
               Print("Attempt ", (Tries + 1), " of 5: Order ", OrderTicket(), " failed to close. Error:", ErrorDescription(Error));
               Tries++;
               break;
            case ERR_TRADE_TIMEOUT:
            default:
               Print("Attempt ", (Tries + 1), " of 5: Order ", OrderTicket(), " failed to close. Fatal Error:", ErrorDescription(Error));
               Tries = 5;
               ca    = 0;
               break;
            }
         }
      }

      if (Closed == CloseCount || Closed == 0)
         ca = 0;
   }
   else
      ca = 0;

   if (Closed > 0)
   {
      if (Closed != 1)
         s = "s";

      Print("Closed ", Closed, " position", s, " because ", Reason);

      if (PlaySounds)
         PlaySound(AlertSound);
   }

   return(Closed);
}


//+-----------------------------------------------------------------+
//| Find Hedge Profit                                               |
//+-----------------------------------------------------------------+
double FindClosedPL(int Type)
{
   double ClosedProfit = 0;

   if (Type == B && UseCloseOldest)
      CbC = 0;

   if (OTbF > 0)
   {
      for (int Order = OrdersHistoryTotal() - 1; Order >= 0; Order--)
      {
         if (!OrderSelect(Order, SELECT_BY_POS, MODE_HISTORY))
            continue;

         if (OrderOpenTime() < OTbF)
            continue;

         if (Type == B && OrderMagicNumber() == Magic && OrderType() <= OP_SELL)
         {
            ClosedProfit += OrderProfit() + OrderSwap() + OrderCommission();

            if (UseCloseOldest)
               CbC++;
         }

         if (Type == H && OrderMagicNumber() == hMagic)
            ClosedProfit += OrderProfit() + OrderSwap() + OrderCommission();
      }
   }

   return(ClosedProfit);
}


//+-----------------------------------------------------------------+
//| Check Correlation                                               |
//+-----------------------------------------------------------------+
double CheckCorr()
{
   double BaseDiff, HedgeDiff, BasePow = 0, HedgePow = 0, Mult = 0;

   for (int Index = CorrPeriod - 1; Index >= 0; Index--)
   {
      BaseDiff  = iClose(Symbol(), PERIOD_D1, Index) - iMA(Symbol(), PERIOD_D1, CorrPeriod, 0, MODE_SMA, PRICE_CLOSE, Index);
      HedgeDiff = iClose(HedgeSymbol_, PERIOD_D1, Index) - iMA(HedgeSymbol_, PERIOD_D1, CorrPeriod, 0, MODE_SMA, PRICE_CLOSE, Index);
      Mult     += BaseDiff * HedgeDiff;
      BasePow  += MathPow(BaseDiff, 2);
      HedgePow += MathPow(HedgeDiff, 2);
   }

   if (BasePow * HedgePow > 0)
      return(Mult / MathSqrt(BasePow * HedgePow));

   return(0);
}


//+------------------------------------------------------------------+
//|  Save Equity / Balance Statistics                                |
//+------------------------------------------------------------------+
void Stats(bool NewFile, bool IsTick, double Balance, double DrawDown)
{
   double   Equity  = Balance + DrawDown;
   datetime TimeNow = TimeCurrent();

   if (IsTick)
   {
      if (Equity < StatLowEquity)
         StatLowEquity = Equity;

      if (Equity > StatHighEquity)
         StatHighEquity = Equity;
   }
   else
   {
      while (TimeNow >= NextStats)
         NextStats += StatsPeriod;

      int StatHandle;

      if (NewFile)
      {
         StatHandle = FileOpen(StatFile, FILE_WRITE | FILE_CSV, ',');
         Print("Stats " + StatFile + " " + (string) StatHandle);
         FileWrite(StatHandle, "Date", "Time", "Balance", "Equity Low", "Equity High", TradeComment);
      }
      else
      {
         StatHandle = FileOpen(StatFile, FILE_READ | FILE_WRITE | FILE_CSV, ',');
         FileSeek(StatHandle, 0, SEEK_END);
      }

      if (StatLowEquity == 0)
      {
         StatLowEquity  = Equity;
         StatHighEquity = Equity;
      }

      FileWrite(StatHandle, TimeToStr(TimeNow, TIME_DATE), TimeToStr(TimeNow, TIME_SECONDS), DTS(Balance, 0), DTS(StatLowEquity, 0), DTS(StatHighEquity, 0));
      FileClose(StatHandle);

      StatLowEquity  = Equity;
      StatHighEquity = Equity;
   }
}


//+-----------------------------------------------------------------+
//| Magic Number Generator                                          |
//+-----------------------------------------------------------------+
int GenerateMagicNumber()
{
   if (EANumber_ > 99)
      return(EANumber_);

   return(JenkinsHash((string) EANumber_ + "_" + Symbol() + "__" + (string) Period()));
}


int JenkinsHash(string Input)
{
   int MagicNo = 0;

   for (int Index = 0; Index < StringLen(Input); Index++)
   {
      MagicNo += StringGetChar(Input, Index);
      MagicNo += (MagicNo << 10);
      MagicNo ^= (MagicNo >> 6);
   }

   MagicNo += (MagicNo << 3);
   MagicNo ^= (MagicNo >> 11);
   MagicNo += (MagicNo << 15);

   return(MathAbs(MagicNo));
}


//+-----------------------------------------------------------------+
//| Normalize Double                                                |
//+-----------------------------------------------------------------+
double ND(double Value, int Precision)
{
   return(NormalizeDouble(Value, Precision));
}


//+-----------------------------------------------------------------+
//| Double To String                                                |
//+-----------------------------------------------------------------+
string DTS(double Value, int Precision)
{
   return(DoubleToStr(Value, Precision));
}


//+-----------------------------------------------------------------+
//| Integer To String                                                |
//+-----------------------------------------------------------------+
string ITS(int Value)
{
   return(IntegerToString(Value));
}


//+-----------------------------------------------------------------+
//| Create Label Function (OBJ_LABEL ONLY)                          |
//+-----------------------------------------------------------------+
void CreateLabel(string Name, string Text, int FontSize, int Corner, int XOffset, double YLine, color Colour = CLR_NONE, string Font = "")
{
   double XDistance = 0, YDistance = 0;
   int Anchor = ANCHOR_LEFT;

   if (Corner == CORNER_RIGHT_LOWER)
      Anchor = ANCHOR_RIGHT_LOWER;
   else if (Corner == CORNER_RIGHT_UPPER)
      Anchor = ANCHOR_RIGHT_UPPER;

   if (Font == "")
      Font = displayFont;

   FontSize += displayFontSize;
   YDistance = displayYcord + displaySpacing * YLine;

//MT4:  0  1
//      2  3
//MT5:  0  3
//      1  2

   if (Corner == CORNER_LEFT_UPPER)
      XDistance = displayXcord + (XOffset * displayFontSize * displayRatio / 9);
   else if (Corner == CORNER_RIGHT_UPPER)
      XDistance = displayCCIxCord + XOffset * displayRatio;
   else if (Corner == CORNER_LEFT_LOWER)
      XDistance = displayXcord + (XOffset * displayFontSize * displayRatio / 9);
   else if (Corner == CORNER_RIGHT_LOWER)
   {
      XDistance = (XOffset * displayFontSize * displayRatio / 9);
      YDistance = YLine;
   }
   else if (Corner == 5)
   {
      XDistance = XOffset * displayRatio;
      YDistance = 14 * YLine;
      Corner    = CORNER_RIGHT_UPPER;
   }

   if (Colour == CLR_NONE)
      Colour = displayColor;

   ObjectCreate(ChartID(), Name, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(Name, Text, FontSize, Font, Colour);
   ObjectSetInteger(ChartID(), Name, OBJPROP_CORNER, Corner);
   ObjectSetInteger(ChartID(), Name, OBJPROP_XDISTANCE, (int)XDistance);
   ObjectSetInteger(ChartID(), Name, OBJPROP_YDISTANCE, (int)YDistance);
   ObjectSetInteger(ChartID(), Name, OBJPROP_ANCHOR, Anchor);
   ObjectSetInteger(ChartID(), Name, OBJPROP_BACK, false);
   ObjectSetInteger(ChartID(), Name, OBJPROP_ZORDER, 1);
}


//+-----------------------------------------------------------------+
//| Create Line Function (OBJ_HLINE ONLY)                           |
//+-----------------------------------------------------------------+
void CreateLine(string Name, color Colour, int Width, int Style)
{
   ObjectCreate(Name, OBJ_HLINE, 0, 0, 0);
   ObjectSet(Name, OBJPROP_COLOR, Colour);
   ObjectSet(Name, OBJPROP_WIDTH, Width);
   ObjectSet(Name, OBJPROP_STYLE, Style);
}


//+------------------------------------------------------------------+
//| Draw Label Function (OBJ_LABEL ONLY)                             |
//+------------------------------------------------------------------+
void DrawLabel(string Name, double Value, int XOffset, int Decimal = 2, color Colour = CLR_NONE)
{
   int dDigits = Digit[ArrayBsearch(Digit, (int) Value), 1];
   ObjectSet(Name, OBJPROP_XDISTANCE, displayXcord + (int)((XOffset - 7 * dDigits) * displayFontSize * displayRatio / 9));
   ObjSetTxt(Name, DTS(Value, Decimal), 0, Colour);
}


//+-----------------------------------------------------------------+
//| Object Set Function                                             |
//+-----------------------------------------------------------------+
void ObjSet(string Name, int XCoord)
{
   ObjectSet(Name, OBJPROP_XDISTANCE, displayXcord + (int)(XCoord * displayFontSize * displayRatio / 9));
}


//+-----------------------------------------------------------------+
//| Object Set Text Function                                        |
//+-----------------------------------------------------------------+
void ObjSetTxt(string Name, string Text, int FontSize = 0, color Colour = CLR_NONE, string Font = "")
{
   FontSize += displayFontSize;

   if (Font == "")
      Font = displayFont;

   if (Colour == CLR_NONE)
      Colour = displayColor;

   ObjectSetText(Name, Text, FontSize, Font, Colour);
}


//+------------------------------------------------------------------+
//| Delete Overlay Label Function                                    |
//+------------------------------------------------------------------+
void LabelDelete()
{
   for (int Object = ObjectsTotal(); Object >= 0; Object--)
   {
      if (StringSubstr(ObjectName(Object), 0, 2) == "B3")
         ObjectDelete(ObjectName(Object));
   }
}


//+------------------------------------------------------------------+
//| Delete Object Function                                           |
//+------------------------------------------------------------------+
void ObjDel(string Name)
{
   if (ObjectFind(Name) != -1)
      ObjectDelete(Name);
}


//+-----------------------------------------------------------------+
//| Create Object List Function                                     |
//+-----------------------------------------------------------------+
void LabelCreate()
{
   if (displayOverlay && ((Testing && Visual) || !Testing))
   {
      int    dDigits;
      string ObjText;
      color  ObjClr;

      // CreateLabel("B3LMNum", "Magic: ", 8 - displayFontSize, 5, 59, 1, displayColorFGnd, "Tahoma");
      CreateLabel("B3VMNum", DTS(Magic, 0), 8 - displayFontSize, 5, 5, 1, displayColorFGnd, "Tahoma");
      // CreateLabel("B3LComm", "Trade Comment: " + TradeComment, 8 - displayFontSize, 5, 5, 1.8, displayColorFGnd, "Tahoma");
      CreateLabel("B3LComm", TradeComment, 8 - displayFontSize, 5, 5, 1.8, displayColorFGnd, "Tahoma");

      if (displayLogo)
      {
         // changed from red airplane to green thumbs up, signify all is good
         // CreateLabel("B3LLogo", "Q", 27, CORNER_RIGHT_LOWER, 10, 10, Crimson, "Wingdings");      // Airplane
         // CreateLabel("B3LLogo", "F", 27, CORNER_RIGHT_LOWER, 10, 10, Green, "Wingdings");    // F = right pointing finger
         CreateLabel("B3LLogo", "C", 27, CORNER_RIGHT_LOWER, 10, 10, Green, "Wingdings");     // C = thumbs up
         CreateLabel("B3LCopy", "This software is free and public domain", 10 - displayFontSize, CORNER_RIGHT_LOWER, 5, 3, Silver, "Arial");
      }

      CreateLabel("B3LTime", "Server:", 0, CORNER_LEFT_UPPER, 0, 0);
      CreateLabel("B3VTime", "", 0, CORNER_LEFT_UPPER, 60, 0);
      CreateLabel("B3Line1", "=========================", 0, CORNER_LEFT_UPPER, 0, 1);
      CreateLabel("B3LEPPC", "Equity Protection % Set:", 0, CORNER_LEFT_UPPER, 0, 2);
      dDigits = Digit[ArrayBsearch(Digit, (int)MaxDDPercent), 1];
      CreateLabel("B3VEPPC", DTS(MaxDDPercent, 2), 0, CORNER_LEFT_UPPER, 167 - 7 * dDigits, 2);
      CreateLabel("B3PEPPC", "%", 0, CORNER_LEFT_UPPER, 193, 2);
      CreateLabel("B3LSTPC", "Stop Trade % Set:", 0, CORNER_LEFT_UPPER, 0, 3);
      dDigits = Digit[ArrayBsearch(Digit, (int) (StopTradePercent_ * 100)), 1];
      CreateLabel("B3VSTPC", DTS(StopTradePercent_ * 100, 2), 0, CORNER_LEFT_UPPER, 167 - 7 * dDigits, 3);
      CreateLabel("B3PSTPC", "%", 0, CORNER_LEFT_UPPER, 193, 3);
      CreateLabel("B3LSTAm", "Stop Trade Amount:", 0, CORNER_LEFT_UPPER, 0, 4);
      CreateLabel("B3VSTAm", "", 0, CORNER_LEFT_UPPER, 175, 4, displayColorLoss);
      CreateLabel("B3LAPPC", "Account Portion:", 0, CORNER_LEFT_UPPER, 0, 5);
      if (PortionPC > 100)            // r.f.
      {
         dDigits = Digit[ArrayBsearch(Digit, (int) (PortionPC)), 1];
         CreateLabel("B3VAPPC", DTS(PortionPC, 2), 0, CORNER_LEFT_UPPER, 167 - 7 * dDigits, 5);
         CreateLabel("B3PAPPC", " ", 0, CORNER_LEFT_UPPER, 193, 5);
      }
      else
      {
         dDigits = Digit[ArrayBsearch(Digit, (int) (PortionPC_ * 100)), 1];
         CreateLabel("B3VAPPC", DTS(PortionPC_ * 100, 2), 0, CORNER_LEFT_UPPER, 167 - 7 * dDigits, 5);
         CreateLabel("B3PAPPC", "%", 0, CORNER_LEFT_UPPER, 193, 5);
      }
      CreateLabel("B3LPBal", "Portion Balance:", 0, CORNER_LEFT_UPPER, 0, 6);
      CreateLabel("B3VPBal", "", 0, CORNER_LEFT_UPPER, 167, 6);
      if (PortionPC > 100)            // r.f.
      {
         CreateLabel("B3LAPCR", "Portion Risk:", 0, CORNER_LEFT_UPPER, 228, 6);
      }
      else
      {
         CreateLabel("B3LAPCR", "Account Risk:", 0, CORNER_LEFT_UPPER, 228, 6);
      }
      CreateLabel("B3VAPCR", DTS(MaxDDPercent * PortionPC_, 2), 0, CORNER_LEFT_UPPER, 310, 6);
      CreateLabel("B3PAPCR", "%", 0, CORNER_LEFT_UPPER, 340, 6);

      if (UseMM)
      {
         ObjText = "Money Management is ON";
         ObjClr  = displayColorProfit;
      }
      else
      {
         ObjText = "Money Management is OFF";
         ObjClr  = displayColorLoss;
      }

      CreateLabel("B3LMMOO", ObjText, 0, CORNER_LEFT_UPPER, 0, 7, ObjClr);

      if (UsePowerOutSL)
      {
         ObjText = "Power-Off StopLoss is ON";
         ObjClr  = displayColorProfit;
      }
      else
      {
         ObjText = "Power-Off StopLoss is OFF";
         ObjClr  = displayColorLoss;
      }

      CreateLabel("B3LPOSL", ObjText, 0, CORNER_LEFT_UPPER, 0, 8, ObjClr);
      CreateLabel("B3LDrDn", "Draw Down %:", 0, CORNER_LEFT_UPPER, 228, 8);
      CreateLabel("B3VDrDn", "", 0, CORNER_LEFT_UPPER, 315, 8);

      if (UseHedge_)
      {
         if (HedgeTypeDD)
         {
            CreateLabel("B3LhDDn", "Hedge", 0, CORNER_LEFT_UPPER, 190, 8);
            CreateLabel("B3ShDDn", "/", 0, CORNER_LEFT_UPPER, 342, 8);
            CreateLabel("B3VhDDm", "", 0, CORNER_LEFT_UPPER, 347, 8);
         }
         else
         {
            CreateLabel("B3LhLvl", "Hedge Level:", 0, CORNER_LEFT_UPPER, 228, 9);
            CreateLabel("B3VhLvl", "", 0, CORNER_LEFT_UPPER, 318, 9);
            CreateLabel("B3ShLvl", "/", 0, CORNER_LEFT_UPPER, 328, 9);
            CreateLabel("B3VhLvT", "", 0, CORNER_LEFT_UPPER, 333, 9);
         }
      }

      CreateLabel("B3Line2", "======================", 0, CORNER_LEFT_UPPER, 0, 9);
      CreateLabel("B3LSLot", "Starting Lot Size:", 0, CORNER_LEFT_UPPER, 0, 10);
      CreateLabel("B3VSLot", "", 0, CORNER_LEFT_UPPER, 130, 10);

      if (MaximizeProfit)
      {
         ObjText = "Profit Maximizer is ON";
         ObjClr  = displayColorProfit;
      }
      else
      {
         ObjText = "Profit Maximizer is OFF";
         ObjClr  = displayColorLoss;
      }

      CreateLabel("B3LPrMx", ObjText, 0, CORNER_LEFT_UPPER, 0, 11, ObjClr);
      CreateLabel("B3LBask", "Basket", 0, CORNER_LEFT_UPPER, 200, 11);
      CreateLabel("B3LPPot", "Profit Potential:", 0, CORNER_LEFT_UPPER, 30, 12);
      CreateLabel("B3VPPot", "", 0, CORNER_LEFT_UPPER, 190, 12);
      CreateLabel("B3LPrSL", "Profit Trailing Stop:", 0, CORNER_LEFT_UPPER, 30, 13);
      CreateLabel("B3VPrSL", "", 0, CORNER_LEFT_UPPER, 190, 13);
      CreateLabel("B3LPnPL", "Portion P/L / Pips:", 0, CORNER_LEFT_UPPER, 30, 14);
      CreateLabel("B3VPnPL", "", 0, CORNER_LEFT_UPPER, 190, 14);
      CreateLabel("B3SPnPL", "/", 0, CORNER_LEFT_UPPER, 220, 14);
      CreateLabel("B3VPPip", "", 0, CORNER_LEFT_UPPER, 229, 14);
      CreateLabel("B3LPLMM", "Profit/Loss Max/Min:", 0, CORNER_LEFT_UPPER, 30, 15);
      CreateLabel("B3VPLMx", "", 0, CORNER_LEFT_UPPER, 190, 15);
      CreateLabel("B3SPLMM", "/", 0, CORNER_LEFT_UPPER, 220, 15);
      CreateLabel("B3VPLMn", "", 0, CORNER_LEFT_UPPER, 225, 15);
      CreateLabel("B3LOpen", "Open Trades / Lots:", 0, CORNER_LEFT_UPPER, 30, 16);
      CreateLabel("B3LType", "", 0, CORNER_LEFT_UPPER, 170, 16);
      CreateLabel("B3VOpen", "", 0, CORNER_LEFT_UPPER, 207, 16);
      CreateLabel("B3SOpen", "/", 0, CORNER_LEFT_UPPER, 220, 16);
      CreateLabel("B3VLots", "", 0, CORNER_LEFT_UPPER, 229, 16);
      CreateLabel("B3LMvTP", "Move TP by:", 0, CORNER_LEFT_UPPER, 0, 17);
      CreateLabel("B3VMvTP", DTS(MoveTP_ / Pip, 0), 0, CORNER_LEFT_UPPER, 100, 17);
      CreateLabel("B3LMves", "# Moves:", 0, CORNER_LEFT_UPPER, 150, 17);
      CreateLabel("B3VMove", "", 0, CORNER_LEFT_UPPER, 229, 17);
      CreateLabel("B3SMves", "/", 0, CORNER_LEFT_UPPER, 242, 17);
      CreateLabel("B3VMves", DTS(TotalMoves, 0), 0, CORNER_LEFT_UPPER, 249, 17);
      CreateLabel("B3LMxDD", "Max DD:", 0, CORNER_LEFT_UPPER, 0, 18);
      CreateLabel("B3VMxDD", "", 0, CORNER_LEFT_UPPER, 107, 18);
      CreateLabel("B3LDDPC", "Max DD %:", 0, CORNER_LEFT_UPPER, 150, 18);
      CreateLabel("B3VDDPC", "", 0, CORNER_LEFT_UPPER, 229, 18);
      CreateLabel("B3PDDPC", "%", 0, CORNER_LEFT_UPPER, 257, 18);

      if (ForceMarketCond_ < 3)
         CreateLabel("B3LFMCn", "Market trend is forced", 0, CORNER_LEFT_UPPER, 0, 19);

      CreateLabel("B3LTrnd", "", 0, CORNER_LEFT_UPPER, 0, 20);

      if (CCIEntry_ > 0 && displayCCI)
      {
         CreateLabel("B3LCCIi", "CCI", 2, CORNER_RIGHT_UPPER, 12, 1);
         CreateLabel("B3LCm05", "m5", 2, CORNER_RIGHT_UPPER, 25, 2.2);
         CreateLabel("B3VCm05", "Ø", 6, CORNER_RIGHT_UPPER, 0, 2, Orange, "Wingdings");
         CreateLabel("B3LCm15", "m15", 2, CORNER_RIGHT_UPPER, 25, 3.4);
         CreateLabel("B3VCm15", "Ø", 6, CORNER_RIGHT_UPPER, 0, 3.2, Orange, "Wingdings");
         CreateLabel("B3LCm30", "m30", 2, CORNER_RIGHT_UPPER, 25, 4.6);
         CreateLabel("B3VCm30", "Ø", 6, CORNER_RIGHT_UPPER, 0, 4.4, Orange, "Wingdings");
         CreateLabel("B3LCm60", "h1", 2, CORNER_RIGHT_UPPER, 25, 5.8);
         CreateLabel("B3VCm60", "Ø", 6, CORNER_RIGHT_UPPER, 0, 5.6, Orange, "Wingdings");
      }

      if (UseHolidayShutdown)
      {
         CreateLabel("B3LHols", "Next Holiday Period", 0, CORNER_LEFT_UPPER, 240, 2);
         CreateLabel("B3LHolD", "From: (yyyy.mm.dd) To:", 0, CORNER_LEFT_UPPER, 232, 3);
         CreateLabel("B3VHolF", "", 0, CORNER_LEFT_UPPER, 232, 4);
         CreateLabel("B3VHolT", "", 0, CORNER_LEFT_UPPER, 300, 4);
      }
   }
}
