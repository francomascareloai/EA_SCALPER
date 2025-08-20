//+------------------------------------------------------------------+
//|                                      AmazingEA.mq4 Version 1.1.7 |
//|                                                     FiFtHeLeMeNt |
//|                                             http://www.irxfx.com |
//|                                         fifthelement80@gmail.com |
//+------------------------------------------------------------------+
#property copyright "FiFtHeLeMeNt"
#property link      "http://www.irxfx.com"

extern int TP=20; // The Exact Amount Of the Pips u will get as the profit in your account
extern int NDay=0;  // News Day
extern int NHour=0; // News Hour
extern int NMin=0;  // News Minute
extern int CTCBN=0; // Numbers Candles to check Before News For determining High & Lows , when it is 1 it check 2 candles the current candle and the 1 last one
extern int SecBPO=300; // Seconds Before News Which EA Will Place Pending Orders
extern int SecBMO=0; // Seconds Before News Which EA Will Stop Modifying Orders
extern int STWAN=150; // Seconds To Wait After News to Delete Pending Orders
extern bool OCO=true; // One Cancel The Other , will cancel the other pending order if one of them is hit
extern int BEPips=0; // Pips In profit which EA will Move SL to BE+1 after that
extern int TrailingStop=0; // Trailing Stop
extern bool mm=true;
extern int RiskPercent=3;
extern double Lots=0.1;
extern string TradeLog = " MI_Log";

double h,l,ho,lo,hso,lso,htp,ltp,sp;
int Magic;
string filename;


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
    ObjectsDeleteAll();
    return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    Comment("");
    ObjectsDeleteAll();
//----
   return(0);
  }

double LotsOptimized()
  {
   double lot=Lots;
  //---- select lot size
   if (mm) lot=NormalizeDouble(MathFloor(AccountFreeMargin()*RiskPercent/100)/100,1);
   
  // lot at this point is number of standard lots
   return(lot);
  } 

  
int CheckOrdersCondition()
  {
    int result=0;
    for (int i=0;i<OrdersTotal();i++) {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if ((OrderType()==OP_BUY) && (OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic)) {
        result=result+1000; 
      }
      if ((OrderType()==OP_SELL) && (OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic)) {
        result=result+100; 
      }
      if ((OrderType()==OP_BUYSTOP) && (OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic)) {
        result=result+10;
      }
      if ((OrderType()==OP_SELLSTOP) && (OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic)) {
        result=result+1; 
      }

    }
    return(result); // 0 means we have no trades
  }
  
// OrdersCondition Result Pattern
//    1    1    1    1
//    b    s    bs   ss
//  
  
  
void OpenBuyStop()
 {
    int ticket,err,tries;
        tries = 0;
        if (!GlobalVariableCheck("InTrade")) {
          while (tries < 3)
            {
               GlobalVariableSet("InTrade", CurTime());  // set lock indicator
               ticket = OrderSend(Symbol(),OP_BUYSTOP,LotsOptimized(),ho,1,hso,htp,"EA Order",Magic,0,Red);
               Write("in function OpenBuyStop OrderSend Executed , ticket ="+ticket);
               GlobalVariableDel("InTrade");   // clear lock indicator
               if(ticket<=0) {
                  Write("Error Accured : "+ErrorDescription(GetLastError())+" BuyStop @ "+ho+" SL @ "+hso+" TP @"+htp);
                  tries++;
               } else tries = 3;
            }
        }
 }
  
void OpenSellStop()
 {
    int ticket,err,tries;
        tries = 0;
        if (!GlobalVariableCheck("InTrade")) {
          while (tries < 3)
            {
               GlobalVariableSet("InTrade", CurTime());  // set lock indicator
               ticket = OrderSend(Symbol(),OP_SELLSTOP,LotsOptimized(),lo,1,lso,ltp,"EA Order",Magic,0,Red);
               Write("in function OpenSellStop OrderSend Executed , ticket ="+ticket);
               GlobalVariableDel("InTrade");   // clear lock indicator
               if(ticket<=0) {
                  Write("Error Accured : "+ErrorDescription(GetLastError())+" BuyStop @ "+lo+" SL @ "+lso+" TP @"+ltp);
                  tries++;
               } else tries = 3;
            }
        }
 }
 
void DoBE(int byPips)
  {
    for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if ( OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic))  // only look if mygrid and symbol...
        {
            if (OrderType() == OP_BUY) if (Bid - OrderOpenPrice() > byPips * Point) if (OrderStopLoss() < OrderOpenPrice()) {
              Write("Movine StopLoss of Buy Order to BE+1");
              OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() +  Point, OrderTakeProfit(), Red);
            }
            if (OrderType() == OP_SELL) if (OrderOpenPrice() - Ask > byPips * Point) if (OrderStopLoss() > OrderOpenPrice()) { 
               Write("Movine StopLoss of Buy Order to BE+1");
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() -  Point, OrderTakeProfit(), Red);
            }
        }
    }
  }

void DoTrail()
  {
    for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if ( OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic))  // only look if mygrid and symbol...
        {
          
          if (OrderType() == OP_BUY) {
             if(Bid-OrderOpenPrice()>Point*TrailingStop)
             {
                if(OrderStopLoss()<Bid-Point*TrailingStop)
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                     return(0);
                  }
             }
          }

          if (OrderType() == OP_SELL) 
          {
             if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
             {
                if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                {
                   OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                   return(0);
                }
             }
          }
       }
    }
 }
 

void DeleteBuyStop()
{
   for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic) && (OrderType()==OP_BUYSTOP)) {
       OrderDelete(OrderTicket());
       Write("in function DeleteBuyStopOrderDelete Executed");
     }
       
   }
}
   
void DeleteSellStop()
{
   for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic) && (OrderType()==OP_SELLSTOP)) {
       OrderDelete(OrderTicket());
       Write("in function DeleteSellStopOrderDelete Executed");
     }
       
   }
}

void DoModify()
{
   for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic) && (OrderType()==OP_SELLSTOP)) {
       if ((OrderOpenPrice()>lo) || (OrderOpenPrice()<lo)) {
         Write("in function DoModify , SellStop OrderModify Executed, Sell Stop was @ "+DoubleToStr(OrderOpenPrice(),4)+" it changed to "+DoubleToStr(lo,4));
         OrderModify(OrderTicket(),lo,lso,ltp,0,Red);
       }
     }

     if (OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic) && (OrderType()==OP_BUYSTOP)) {
       if ((OrderOpenPrice()>ho) || (OrderOpenPrice()<ho)) {
         Write("in function DoModify , BuyStop OrderModify Executed, Buy Stop was @ "+DoubleToStr(OrderOpenPrice(),4)+" it changed to "+DoubleToStr(ho,4));
         OrderModify(OrderTicket(),ho,hso,htp,0,Red);
       }
     }
   }
}

int Write(string str)
{
   int handle;
  
   handle = FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV,"/t");
   FileSeek(handle, 0, SEEK_END);      
   FileWrite(handle,str + " Time " + TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS));
    FileClose(handle);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  
   Magic=NDay+NHour+NMin;
   
   int i;
   int OrdersCondition,secofday,secofnews;
      
   filename=Symbol() + TradeLog + "-" + Month() + "-" + Day() + ".txt";

   if (BEPips>0) DoBE(BEPips);
   
   if (TrailingStop>0) DoTrail();
   
   OrdersCondition=CheckOrdersCondition();
   
   secofday=Hour()*3600+Minute()*60+Seconds();
   secofnews=NHour*3600+NMin*60;
   
   h=iHigh(NULL,PERIOD_M1,0);
   l=iLow(NULL,PERIOD_M1,0);
   for (i=1;i<=CTCBN;i++) if (iHigh(NULL,PERIOD_M1,i)>h) h=iHigh(NULL,PERIOD_M1,i);
   for (i=1;i<=CTCBN;i++) if (iLow(NULL,PERIOD_M1,i)<l) l=iLow(NULL,PERIOD_M1,i);
   sp=Ask-Bid;
   ho=h+sp+(10)*Point;
   lo=l-(10)*Point;
   hso=h+sp;
   lso=l;
   htp=ho+TP*Point;
   ltp=lo-TP*Point;

   if (Day()!=NDay) {
   Comment("\nAmazing Forex System Expert Advisor v 1.1.7 By FiFtHeLeMeNt\n\nHigh @ ",h," Buy Order @ ",ho," Stoploss @ ",hso," TakeProfit @ ",htp,"\nLow @ ",l," Sell Order @ ",lo," StopLoss @ ",lso," TakeProfit @ ",ltp,"\n\nNews Day : ",NDay,"st"," News Time @ ",NHour,":",NMin," CTCBN : ",CTCBN," SecBPO : ",SecBPO," SecBMO : ",SecBMO," STWAN : ",STWAN," OCO : ",OCO," BEPips : ",BEPips," Money Management : ",mm," RiskPercent: ",RiskPercent," Lots : ",LotsOptimized(),"\n\nExpert is disabled because it is not day of expected news");
     return(0);
   } else Comment("\nAmazing Forex System Expert Advisor v 1.1.7 By FiFtHeLeMeNt\n\nHigh @ ",h," Buy Order @ ",ho," Stoploss @ ",hso," TakeProfit @ ",htp,"\nLow @ ",l," Sell Order @ ",lo," StopLoss @ ",lso," TakeProfit @ ",ltp,"\n\nNews Day : ",NDay,"st"," News Time @ ",NHour,":",NMin," CTCBN : ",CTCBN," SecBPO : ",SecBPO," SecBMO : ",SecBMO," STWAN : ",STWAN," OCO : ",OCO," BEPips : ",BEPips," Money Management : ",mm," RiskPercent: ",RiskPercent," Lots : ",LotsOptimized());
   
   if ((secofday<secofnews) && (secofday>(secofnews-SecBPO))) {
      
      if (OrdersCondition==0) {
         Write("Opening BuyStop & SellStop, OrdersCondition="+OrdersCondition+" SecOfDay="+secofday);
         OpenBuyStop();
         OpenSellStop();
      }

      if (OrdersCondition==10) {
         Write("Opening SellStop, OrdersCondition="+OrdersCondition+" SecOfDay="+secofday);
         OpenSellStop();
      }
      
      if (OrdersCondition==1) {
         Write("Opening BuyStop , OrdersCondition="+OrdersCondition+" SecOfDay="+secofday);
         OpenBuyStop();
      }
   }

   if ((secofday<secofnews) && (secofday>(secofnews-SecBPO)) && (secofday<(secofnews-SecBMO))) {
         Write("Modifying Orders, OrdersCondition="+OrdersCondition+" SecOfDay="+secofday);
         DoModify();
      }
      
   


   if ((secofday>secofnews) && (secofday<(secofnews+STWAN)) && OCO) {

      if (OrdersCondition==1001) {
         Write("Deleting SellStop Because of BuyStop Hit, OrdersCondition="+OrdersCondition+" SecOfDay="+secofday);
         DeleteSellStop();
      }
      
      if (OrdersCondition==110) {
        Write("Deleting BuyStop Because of SellStop Hit, OrdersCondition="+OrdersCondition+" SecOfDay="+secofday);
        DeleteBuyStop();
      }
   }
   
   if ((secofday>secofnews) && (secofday>(secofnews+STWAN))) {
      if (OrdersCondition==11) {
         Write("Deleting BuyStop and SellStop Because 4 min expired, OrdersCondition="+OrdersCondition+" SecOfDay="+secofday);
         DeleteBuyStop();
         DeleteSellStop();
      }
      
      if ((OrdersCondition==10) || (OrdersCondition==110)) {
        Write("Deleting BuyStop Because expired, OrdersCondition="+OrdersCondition+" SecOfDay="+secofday);
        DeleteBuyStop();
      }
      
      if ((OrdersCondition==1) || (OrdersCondition==1001)) {
        Write("Deleting SellStop Because expired, OrdersCondition="+OrdersCondition+" SecOfDay="+secofday);
        DeleteSellStop();
      }
   }
        
   
//----
   return(0);
  }
  
//+------------------------------------------------------------------+
//| return error description                                         |
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
      case 9:   error_string="malfunctional trade operation";                             break;
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
      case 137: error_string="broker is busy";                                            break;
      case 138: error_string="requote";                                                   break;
      case 139: error_string="order is locked";                                           break;
      case 140: error_string="long positions only allowed";                               break;
      case 141: error_string="too many requests";                                         break;
      case 145: error_string="modification denied because order too close to market";     break;
      case 146: error_string="trade context is busy";                                     break;
      //---- mql4 errors
      case 4000: error_string="no error";                                                 break;
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
      case 4109: error_string="trade is not allowed";                                     break;
      case 4110: error_string="longs are not allowed";                                    break;
      case 4111: error_string="shorts are not allowed";                                   break;
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