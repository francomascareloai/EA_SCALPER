
//+------------------------------------------------------------------+
//|                                                        11190.mq4 |
//|                                   Copyright © 2010 Jeremy Roseth |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#define DECIMAL_CONVERSION 10
#define COMMENT_DIGITS 2

// defines for evaluating entry conditions
#define INITIAL_CROSS_BAR 2
#define EVAL_BAR 1
#define THIS_BAR 0
#define NEGATIVE_VALUE -1

#define BULLISH      1
#define BEARISH      0

// defines for managing trade orders
#define RETRYCOUNT    10
#define RETRYDELAY    500

#define LONG          1
#define SHORT         -1
#define ALL           0

#define LONG_COMMENT "Long Order"
#define SHORT_COMMENT "Short Order"



#property copyright "Jeremy Roseth, Programmed by OneStepRemoved.com"
#property link      "www.onestepremoved.com"


extern         double      Lots                                  = 0.1;
extern         int              Stop                                 = 50;
extern         int              TakeProfit                        = 100;
extern   int   Lookback       =  20;
extern   int   firstMA        =  5;
extern   int   secondMA       =  12;
extern   int   thirdMA        =  18;
extern   int   fourthMA       =  28;
extern   int   rsiPeriod      =  21;
extern        int               MagicNumber                  = 11190;
extern         bool          WriteScreenshots            = true;

datetime lastTradeTime, lastTradeLevel2;
int Slippage = 2;
int handle;

double maxStop;

int tradeTicket;

string display = "";

string nameIndy = "Teodosi_4_movinq_averages_system";

int init()
  {
      int numDigits = Digits;
      
      if (numDigits == 3 || numDigits == 5)   {
         Stop        *=    DECIMAL_CONVERSION;
         TakeProfit  *=    DECIMAL_CONVERSION;
      }
      
      lastTradeTime = Time[1];
      Print("Broker: " + AccountCompany());
      
      maxStop        =     Stop * Point;

   return(0);
  }

int deinit()  {   return(0);  }

int start()
{

   display = "";
   double bullish, bearish, highestHigh, lowestLow;
   
   bullish = iCustom( Symbol(), Period(), nameIndy, firstMA, secondMA, thirdMA, fourthMA, rsiPeriod, false, -1, BULLISH, EVAL_BAR );
   bearish = iCustom( Symbol(), Period(), nameIndy, firstMA, secondMA, thirdMA, fourthMA, rsiPeriod, false, -1, BEARISH, EVAL_BAR );
   
   display = "Bullish: " + DoubleToStr( bullish, Digits ) + "\nBearish: " + DoubleToStr( bearish, Digits);
   
   int hh, ll;

   if( bullish != EMPTY_VALUE && lastTradeTime != Time[ THIS_BAR ] ) {
      
      ExitAll( SHORT );
      
      if( NoOpenPositionsExist( LONG_COMMENT ) ) {
         if( DoTrade( LONG, Lots, Stop, TakeProfit, LONG_COMMENT ) ) {
            lastTradeTime = Time[ THIS_BAR ];
         }
         
         ll = iLowest( Symbol(), Period(), MODE_LOW, Lookback , EVAL_BAR ); 
      
         OrderSelect( tradeTicket, SELECT_BY_TICKET, MODE_TRADES );
      
         if( Low[ ll ] > OrderStopLoss() ) { 
            OrderModify( OrderTicket(), OrderOpenPrice(), Low[ ll ], OrderTakeProfit(), 0, CLR_NONE ); 
            Print("Stop modified using lowest low");
         }         
      }      
   }
   
   if( bearish != EMPTY_VALUE && lastTradeTime != Time[ THIS_BAR ] ) {
      
      ExitAll( LONG );
      
      if( NoOpenPositionsExist( SHORT_COMMENT ) ) {
         if( DoTrade( SHORT, Lots, Stop, TakeProfit, SHORT_COMMENT ) ) {
            lastTradeTime = Time[ THIS_BAR ];
         } 
         
         hh = iHighest( Symbol(), Period(), MODE_HIGH, Lookback , EVAL_BAR );
      
         OrderSelect( tradeTicket, SELECT_BY_TICKET, MODE_TRADES );
      
         if( High[ hh ] < OrderStopLoss() ) {
            OrderModify( OrderTicket(), OrderOpenPrice(), High[ hh ], OrderTakeProfit(), 0, CLR_NONE ); 
            Print("Stop modified using highest high");
         }          
      }
   }
         
   Comment(display);

   return(0);
}

bool DoTrade(int dir, double volume, int stop, int take, string comment)  {

double sl, tp;

bool retVal = false;

   switch(dir)  {
      case LONG:
         if (stop != 0) { sl = Ask-(stop*Point); }
         else { sl = 0; }
         if (take != 0) { tp = Ask +(take*Point); }
         else { tp = 0; }

         retVal = OpenTrade(LONG, volume, sl, tp, comment);
         break;

      case SHORT:
         if (stop != 0) { sl = Bid+(stop*Point); }
         else { sl = 0; }
         if (take != 0) { tp = Bid-(take*Point); }
         else { tp = 0; }

         retVal = OpenTrade(SHORT, volume, sl, tp, comment);
         break;

   }

return(retVal);

}

bool OpenTrade(int dir, double volume, double stop, double take, string comment, int t = 0)  {
    int i, j, ticket, cmd;
    double prc, sl, tp, lots;
    string cmt;
    color theColor;

    Print("OpenTrade("+dir+","+DoubleToStr(volume,3)+","+DoubleToStr(stop,Digits)+","+DoubleToStr(take,Digits)+","+t+")");

    lots = CheckLots(volume);

    for (i=0; i<RETRYCOUNT; i++) {
        for (j=0; (j<50) && IsTradeContextBusy(); j++)
            Sleep(100);
        RefreshRates();

        if (dir == LONG) {
            cmd = OP_BUY;
            prc = Ask;
            sl = stop;
            tp = take;
            theColor = Blue;
        }
        if (dir == SHORT) {
            cmd = OP_SELL;
            prc = Bid;
            sl = stop;
            tp = take;
            theColor = Red;
        }
        Print("OpenTrade: prc="+DoubleToStr(prc,Digits)+" sl="+DoubleToStr(sl,Digits)+" tp="+DoubleToStr(tp,Digits));

        cmt = comment;
        if (t > 0)
            cmt = comment + "|" + t;

        ticket = OrderSend(Symbol(), cmd, lots, prc, Slippage, 0, 0, cmt, MagicNumber, 0, theColor);
        tradeTicket = ticket;
        
        if (ticket != -1 && ( sl > 0 || tp > 0) ) {
            Print("OpenTrade: opened ticket " + ticket);
            Screenshot("OpenTrade");

            for (i=0; i<RETRYCOUNT; i++) {
                for (j=0; (j<50) && IsTradeContextBusy(); j++)
                    Sleep(100);
                RefreshRates();

                if ( OrderModify(ticket, 0, sl, tp, 0) ) {
                    Print("OpenTrade: SL/TP are set");
                    Screenshot("OpenTrade_SLTP");
                    break;
                }

                Print("OpenTrade: error \'"+ErrorDescription(GetLastError())+"\' when setting SL/TP");
                Sleep(RETRYDELAY);
            }

            return (true);
        }

        if(ticket != -1 && sl == 0 && tp == 0 ) {
            Print("OpenTrade: opened ticket " + ticket);
            Screenshot("OpenTrade");
            return (true);        
        }

        Print("OpenTrade: error \'"+ErrorDescription(GetLastError())+"\' when entering with "+DoubleToStr(lots,3)+" @"+DoubleToStr(prc,Digits));
        Sleep(RETRYDELAY);
    }

    Print("OpenTrade: can\'t enter after "+RETRYCOUNT+" retries");
    return (false);
}

string ConvertBoolToStr(bool value)
{
   if (value) { return("True"); }
   else { return("False"); }
}  

double CheckLots(double lots)
{
    double lot, lotmin, lotmax, lotstep, margin;
    
    lotmin = MarketInfo(Symbol(), MODE_MINLOT);
    lotmax = MarketInfo(Symbol(), MODE_MAXLOT);
    lotstep = MarketInfo(Symbol(), MODE_LOTSTEP);
    margin = MarketInfo(Symbol(), MODE_MARGINREQUIRED);

    if (lots*margin > AccountFreeMargin())
        lots = AccountFreeMargin() / margin;

    lot = MathFloor(lots/lotstep + 0.5) * lotstep;

    if (lot < lotmin)
        lot = lotmin;
    if (lot > lotmax)
        lot = lotmax;

    return (lot);
}


void Screenshot(string moment_name)
{
    if ( WriteScreenshots )
        WindowScreenShot(WindowExpertName()+"_"+Symbol()+"_M"+Period()+"_"+
                         Year()+"-"+two_digits(Month())+"-"+two_digits(Day())+"_"+
                         two_digits(Hour())+"-"+two_digits(Minute())+"-"+two_digits(Seconds())+"_"+
                         moment_name+".gif", 1024, 768);
}

string two_digits(int i)
{
    if (i < 10)
        return ("0"+i);
    else
        return (""+i);
}

bool NoOpenPositionsExist(string theComment)
{
   int total = OrdersTotal();
  
   for(int i = 0; i < total; i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderComment() == theComment)
      { return (false); }
   }

return (true);
}

bool Exit(int ticket, int dir, double volume, color clr, int t = 0)  {
    int i, j, cmd;
    double prc, sl, tp, lots;
    string cmt;

    bool closed;

    Print("Exit("+dir+","+DoubleToStr(volume,3)+","+t+")");

    for (i=0; i<RETRYCOUNT; i++) {
        for (j=0; (j<50) && IsTradeContextBusy(); j++)
            Sleep(100);
        RefreshRates();

        if (dir == LONG) {
            prc = Bid;
        }
        if (dir == SHORT) {
            prc = Ask;
       }
        Print("Exit: prc="+DoubleToStr(prc,Digits));

        closed = OrderClose(ticket,volume,prc,Slippage,clr);
        if (closed) {
            Print("Trade closed");
            Screenshot("Exit");

            return (true);
        }

        Print("Exit: error \'"+ErrorDescription(GetLastError())+"\' when exiting with "+DoubleToStr(volume,3)+" @"+DoubleToStr(prc,Digits));
        Sleep(RETRYDELAY);
    }

    Print("Exit: can\'t enter after "+RETRYCOUNT+" retries");
    return (false);
}

string ConvertPeriod(int period) {
   string retVal;

   if(period == 0 ) { period = Period(); }

   switch(period) {
        case PERIOD_M1:
           retVal = "M1";
           break;
        case PERIOD_M5:
           retVal = "M5";
           break;
        case PERIOD_M15:
           retVal = "M15";
           break;
        case PERIOD_M30:
           retVal = "M30";
           break;
        case PERIOD_H1:
           retVal = "H1";
           break;
        case PERIOD_H4:
           retVal = "H4";
           break;
        case PERIOD_D1:
           retVal = "D1";
           break;
        case PERIOD_W1:
           retVal = "W1";
           break;
        case PERIOD_MN1:
           retVal = "MN1";
           break;        
   }

   return(retVal);
}

string ErrorDescription(int error_code)
{
    string error_string;

    switch( error_code ) {
        case 0:
        case 1:   error_string="no error";                                                  break;
        case 2:   error_string="common error";                                              break;
        case 3:   error_string="invalid trade parameters";                                  break;
        case 4:   error_string="trade server is busy";                                      break;
        case 5:   error_string="old version of the client terminal";                        break;
        case 6:   error_string="no connection with trade server";                           break;
        case 7:   error_string="not enough rights";                                         break;
        case 8:   error_string="too frequent requests";                                     break;
        case 9:   error_string="malfunctional trade operation (never returned error)";      break;
        case 64:  error_string="account disabled";                                          break;
        case 65:  error_string="invalid account";                                           break;
        case 128: error_string="trade timeout";                                             break;
        case 129: error_string="invalid price";                                             break;
        case 130: error_string="invalid stops";                                             break;
        case 131: error_string="invalid trade volume";                                      break;
        case 132: error_string="market is closed";                                          break;
        case 133: error_string="trade is disabled";                                         break;
        case 134: error_string="not enough money";                                          break;
        case 135: error_string="price changed";                                             break;
        case 136: error_string="off quotes";                                                break;
        case 137: error_string="broker is busy (never returned error)";                     break;
        case 138: error_string="requote";                                                   break;
        case 139: error_string="order is locked";                                           break;
        case 140: error_string="long positions only allowed";                               break;
        case 141: error_string="too many requests";                                         break;
        case 145: error_string="modification denied because order too close to market";     break;
        case 146: error_string="trade context is busy";                                     break;
        case 147: error_string="expirations are denied by broker";                          break;
        case 148: error_string="amount of open and pending orders has reached the limit";   break;
        case 149: error_string="hedging is prohibited";                                     break;
        case 150: error_string="prohibited by FIFO rules";                                  break;
        case 4000: error_string="no error (never generated code)";                          break;
        case 4001: error_string="wrong function pointer";                                   break;
        case 4002: error_string="array index is out of range";                              break;
        case 4003: error_string="no memory for function call stack";                        break;
        case 4004: error_string="recursive stack overflow";                                 break;
        case 4005: error_string="not enough stack for parameter";                           break;
        case 4006: error_string="no memory for parameter string";                           break;
        case 4007: error_string="no memory for temp string";                                break;
        case 4008: error_string="not initialized string";                                   break;
        case 4009: error_string="not initialized string in array";                          break;
        case 4010: error_string="no memory for array\' string";                             break;
        case 4011: error_string="too long string";                                          break;
        case 4012: error_string="remainder from zero divide";                               break;
        case 4013: error_string="zero divide";                                              break;
        case 4014: error_string="unknown command";                                          break;
        case 4015: error_string="wrong jump (never generated error)";                       break;
        case 4016: error_string="not initialized array";                                    break;
        case 4017: error_string="dll calls are not allowed";                                break;
        case 4018: error_string="cannot load library";                                      break;
        case 4019: error_string="cannot call function";                                     break;
        case 4020: error_string="expert function calls are not allowed";                    break;
        case 4021: error_string="not enough memory for temp string returned from function"; break;
        case 4022: error_string="system is busy (never generated error)";                   break;
        case 4050: error_string="invalid function parameters count";                        break;
        case 4051: error_string="invalid function parameter value";                         break;
        case 4052: error_string="string function internal error";                           break;
        case 4053: error_string="some array error";                                         break;
        case 4054: error_string="incorrect series array using";                             break;
        case 4055: error_string="custom indicator error";                                   break;
        case 4056: error_string="arrays are incompatible";                                  break;
        case 4057: error_string="global variables processing error";                        break;
        case 4058: error_string="global variable not found";                                break;
        case 4059: error_string="function is not allowed in testing mode";                  break;
        case 4060: error_string="function is not confirmed";                                break;
        case 4061: error_string="send mail error";                                          break;
        case 4062: error_string="string parameter expected";                                break;
        case 4063: error_string="integer parameter expected";                               break;
        case 4064: error_string="double parameter expected";                                break;
        case 4065: error_string="array as parameter expected";                              break;
        case 4066: error_string="requested history data in update state";                   break;
        case 4099: error_string="end of file";                                              break;
        case 4100: error_string="some file error";                                          break;
        case 4101: error_string="wrong file name";                                          break;
        case 4102: error_string="too many opened files";                                    break;
        case 4103: error_string="cannot open file";                                         break;
        case 4104: error_string="incompatible access to a file";                            break;
        case 4105: error_string="no order selected";                                        break;
        case 4106: error_string="unknown symbol";                                           break;
        case 4107: error_string="invalid price parameter for trade function";               break;
        case 4108: error_string="invalid ticket";                                           break;
        case 4109: error_string="trade is not allowed in the expert properties";            break;
        case 4110: error_string="longs are not allowed in the expert properties";           break;
        case 4111: error_string="shorts are not allowed in the expert properties";          break;
        case 4200: error_string="object is already exist";                                  break;
        case 4201: error_string="unknown object property";                                  break;
        case 4202: error_string="object is not exist";                                      break;
        case 4203: error_string="unknown object type";                                      break;
        case 4204: error_string="no object name";                                           break;
        case 4205: error_string="object coordinates error";                                 break;
        case 4206: error_string="no specified subwindow";                                   break;
        default:   error_string="unknown error";
    }

    return(error_string);
}

void ExitAll(int direction) {

   for (int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY && direction == LONG) { Exit(OrderTicket(), LONG, OrderLots(), Blue); }
         if (OrderType() == OP_SELL && direction == SHORT) { Exit( OrderTicket(), SHORT, OrderLots(), Red); }
      }
   }
}

bool CheckTime(string start, string end) {

   string today = TimeToStr( iTime(Symbol(),PERIOD_D1, 0 ), TIME_DATE ) + " ";
   
   datetime startTime = StrToTime( today + start);
   datetime endTime = StrToTime( today + end);
   
   Comment("start is " + today + start + "\end is " + today + end);
  
   if(startTime < endTime) {
      if(TimeCurrent() > startTime && TimeCurrent() < endTime) { return(true); }
   }
  
   if( startTime > endTime ) {
      if( TimeCurrent() > startTime ) { return(true); }
      if( TimeCurrent() < endTime ) { return(true); }
   }
  
   if( startTime == endTime) {
      Comment("***** The Start Time cannot equal the End Time ******* ");
   }
  
   return(false);
}

bool MoveStopToBreakeven(int BreakEven) {

   double breakeven = BreakEven * Point;
   bool retVal = false;

   // select the Order
   for(int i = 0; i < OrdersTotal(); i++) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      
      if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() && OrderStopLoss() != OrderOpenPrice() ) {
      
         if(OrderType() == OP_BUY) {
            if( Bid - OrderOpenPrice() >= breakeven ) {
              retVal = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue) ;
            }
         }
        
       if(OrderType() == OP_SELL) {
            if( OrderOpenPrice() - Ask >= breakeven ) {
               retVal = OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue) ;
            }
         }
      }
   }
  
   return(retVal);
}

bool DoPending(int dir, int pendingType, double entryPrice, double volume, int stop, int take, string comment)  {

   double sl, tp;

   int retVal = 0;

   double lots = CheckLots(volume);
   string info;
   
   for (int i=0; i<RETRYCOUNT; i++) {
     for (int j=0; (j<50) && IsTradeContextBusy(); j++)
         Sleep(100);
      RefreshRates();   

      switch(dir)  {
         case LONG:
           if (stop != 0) { sl = entryPrice-(stop*Point); }
                else { sl = 0; }
                if (take != 0) { tp = entryPrice +(take*Point); }
                else { tp = 0; }
                
                info = "Type: " + pendingType + ", \nentryPrice: " + DoubleToStr(entryPrice, Digits) + ", \nAsk " + DoubleToStr(Ask,Digits)
                   + ", \nLots " + DoubleToStr(lots, 2) + " , \nStop: " + DoubleToStr(sl, Digits)  
                   + ", \nTP: " + DoubleToStr(tp, Digits);
           Print(info);
           Comment(info);

                retVal = OrderSend(Symbol(), pendingType, lots, entryPrice, Slippage, sl, tp, comment, MagicNumber, 0, Blue);
                //retVal = OrderSend(Symbol(), pendingType, lots, 1.39, Slippage, 1.38, 1.40, "", 0, 0, Blue);
                break;

         case SHORT:
           if (stop != 0) { sl = entryPrice+(stop*Point); }
                else { sl = 0; }
                if (take != 0) { tp = entryPrice-(take*Point); }
                else { tp = 0; }
                
                info = "Type: " + pendingType + ", \nentryPrice: " + DoubleToStr(entryPrice, Digits) + ", \nBid " + DoubleToStr(Bid,Digits)
                   + ", \nLots " + DoubleToStr(lots, 2) + " , \nStop: " + DoubleToStr(sl, Digits)  
                   + ", \nTP: " + DoubleToStr(tp, Digits);
           Print(info);
           Comment(info);
          
                retVal = OrderSend(Symbol(), pendingType, lots, entryPrice, Slippage, sl, tp, comment, MagicNumber, 0, Red);
                break;
      }
           
      if( retVal > 0 ) { return( true ); }
      else {
         Print("DoPending: error \'"+ErrorDescription(GetLastError())+"\' when setting entry order");
         Sleep(RETRYDELAY);      
      }
      
   }
   
   
   return( false );

}

bool DeletePendings() {

   bool retVal;

   for(int i = 0; i < OrdersTotal(); i++ ) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      
      if( OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() ) { continue; }
      
      if( OrderType() != OP_BUY && OrderType() != OP_SELL ) {
         retVal = OrderDelete( OrderTicket() );
        
         if( retVal == false ) {
            Print(ErrorDescription( GetLastError() ) );
            return( retVal );
         }
      }
   }
  
   return(true);
}  

bool TrailStop(int magic, string theComment, double trailStart, double trailAmount) {

   double profitPips, increments, sl;

   for(int i = 0; i < OrdersTotal(); i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if (OrderMagicNumber() != magic && OrderSymbol() != Symbol() && OrderComment() != theComment)
      { continue; }
      
      if( OrderType() == OP_BUY ) {
         // move to break even
         if( Bid - OrderOpenPrice() >= trailStart && OrderStopLoss() < OrderOpenPrice() ) {
            Print("Moving stop to breakeven. Bid is " + DoubleToStr( Bid, Digits ));
            return( OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Blue) );
         }
         
         profitPips = Bid - ( trailStart + OrderOpenPrice() ) ;
         increments = MathFloor( profitPips / trailAmount );
         
         if ( increments >= 1 && Bid >= OrderStopLoss() + trailStart + ( increments * trailAmount ) ) {
            sl = OrderOpenPrice() + ( increments  * trailAmount );
            
            if( sl > OrderStopLoss() && OrderModify( OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), 0, Blue) ) {
               Print("Trailng stop updated. Total increments: " + DoubleToStr(increments, Digits) );
               return(true);
            }
         }
      }
      
      if( OrderType() == OP_SELL ) {
         // move to break even
         if( OrderOpenPrice() - Ask >= trailStart && OrderStopLoss() > OrderOpenPrice() ) {
            Print("Moving stop to breakeven. Ask is " + DoubleToStr( Ask, Digits ));
            return( OrderModify( OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Red) );
         }
         
         profitPips = ( OrderOpenPrice()- trailStart ) - Ask ;
         increments = MathFloor( profitPips / trailAmount );
         
         if ( increments >= 1 && Ask <= OrderStopLoss() - trailStart - ( increments * trailAmount ) ) {
            sl = OrderOpenPrice() - ( increments * trailAmount );
            
            if( sl < OrderStopLoss() && OrderModify( OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), 0, Red) ) {
               Print("Trailng stop updated. Total increments: " + DoubleToStr(increments, Digits) );
               return(true);
            }
         }
      }           
   }
   
   return( false );
}