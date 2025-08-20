//+------------------------------------------------------------------+
//|                                                  CloseAtTime.mq4 |
//|                               Copyright 2015, AlgoFXSolution.com |
//|                                    http://www.algofxsolution.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, AlgoFXSolution.com"
#property link      "http://www.algofxsolution.com"
#property strict
//+------------------------------------------------------------------+
//| Parameters                                                       |
//+------------------------------------------------------------------+
extern string __s7="-----  Close Settings  -----------------------";
extern bool bAllClose = false; //Close All
extern bool bSymClose = false; //Close by Symbol
extern bool bMNClose = false; //Close by Magic Number
extern bool bTNClose = false; //Close by Ticket Number
extern bool PO = false; //Close Pending Orders
extern bool MO = false; //Close Market Orders
extern string TimeToClose="YYYY.MM.DD HH:MI"; //Local time to close

extern string __s3="-----  Close Parameters  ---------------------";
extern string SymClose=""; //Symbol to close
extern int MNClose = 0; //Magic Number to close
extern int TNClose = 0; //Ticket Number to close
//+------------------------------------------------------------------+
//| Functions                                                        |
//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(TimeLocal()>=StrToTime(TimeToClose))
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS)==true && bAllClose==true) {CloseProcess();}
         if(OrderSelect(i,SELECT_BY_POS)==true && OrderSymbol()==SymClose && bSymClose==true) {CloseProcess();}
         if(OrderSelect(i,SELECT_BY_POS)==true && OrderMagicNumber()==MNClose && bMNClose==true) {CloseProcess();}
         if(OrderSelect(i,SELECT_BY_POS)==true && OrderTicket()==TNClose && bTNClose==true) {CloseProcess();}
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Close process                                                    |
//+------------------------------------------------------------------+
void CloseProcess()
  {
   int error;
   int MaxSlippage=3;
   double AskOrBid;

   string DigitsS=StringConcatenate(MarketInfo(StringConcatenate(OrderSymbol()),MODE_DIGITS));
   int vDigits=StrToInteger(DigitsS);

   RefreshRates();
   if(OrderType()==OP_BUY) { AskOrBid=NormalizeDouble(MarketInfo(StringConcatenate(OrderSymbol()),MODE_BID),vDigits); } else { AskOrBid=NormalizeDouble(MarketInfo(StringConcatenate(OrderSymbol()),MODE_ASK),vDigits); }

//---Pending orders

   if(PO==true)
     {
      if(OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLSTOP || OrderType()==OP_SELLLIMIT)
        {
         if(!OrderDelete(OrderTicket()))
           {
            error=GetLastError();
            Print("Error deleting order for ticket:"+StringConcatenate(OrderTicket())+" Error: "+StringConcatenate(error)+" : "+ErrorDescription(error));
           }
        }
     }

//---Positions in market

   if(MO==true)
     {
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
        {
         if(OrderClose(OrderTicket(),OrderLots(),AskOrBid,MaxSlippage)==false)
           {
            error=GetLastError();
            Print("Error closing order for ticket:"+StringConcatenate(OrderTicket())+" Error: "+StringConcatenate(error)+" : "+ErrorDescription(error));
            Sleep(1000);

            RefreshRates();
            if(OrderType()==OP_BUY) { AskOrBid=NormalizeDouble(MarketInfo(StringConcatenate(OrderSymbol()),MODE_BID),vDigits); } else { AskOrBid=NormalizeDouble(MarketInfo(StringConcatenate(OrderSymbol()),MODE_ASK),vDigits); }

            //Retries 2//
            if(OrderClose(OrderTicket(),OrderLots(),AskOrBid,MaxSlippage)==false)
              {
               error=GetLastError();
               Print("Error closing order for ticket:"+StringConcatenate(OrderTicket())+" Error: "+StringConcatenate(error)+" : "+ErrorDescription(error));
               Sleep(1000);

               RefreshRates();
               if(OrderType()==OP_BUY) { AskOrBid=NormalizeDouble(MarketInfo(StringConcatenate(OrderSymbol()),MODE_BID),vDigits); } else { AskOrBid=NormalizeDouble(MarketInfo(StringConcatenate(OrderSymbol()),MODE_ASK),vDigits); }

               //Retries 3//
               if(OrderClose(OrderTicket(),OrderLots(),AskOrBid,MaxSlippage)==false)
                 {
                  error=GetLastError();
                  Print("Error closing order for ticket:"+StringConcatenate(OrderTicket())+" Error: "+StringConcatenate(error)+" : "+ErrorDescription(error));
                 }
              }
           }
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Error description                                                |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string;
//----
   switch(error_code)
     {
      //---- codes returned from trade server
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
      //---- mql4 errors
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
//----
   return(error_string);
  }
//+------------------------------------------------------------------+
