//+------------------------------------------------------------------+
//|                                Bollinger_Bands_Exit_Strategy.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property description "This Expert Advisors will Close:\n\n"
#property description "- Long Trades at the Top Bollinger Band\n"
#property description "- Short Trades at the Bottom Bollinger Band"
#property description "\n\nThat had been placed manually at the choosen Pair/TimeFrame"

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

extern string   Comment1     = "- Strategy Parameters -";
extern bool     EA_Activated = true;
input  e_cycles TimeFrame    = Min_60;
extern int      BB_Periods   = 20;
extern double   BB_Deviation = 2.0;
extern string   Comment2     = "- Maximum price slippage for buy or sell orders -";
extern int      Slippage     = 3;
extern string   Comment3     = "- Order comment text. Last part of the comment may be changed by server -";
extern string   CommentOrder = "Expert Advisor Order";
extern string   Comment4    = "- Should the EA use alerts -";
extern bool     Sound_Alert  = true;
extern bool     Email_Alert  = false;
extern string   Comment5    = "- Should the EA orders produce sound -";
extern bool     EASounds     = true;

int Magic_N = 0;

string EA_Name = "Bollinger Bands Exit Strategy";

int Close_Long, Close_Short;
int Side, Open_Level = 0;

double Profit;

int init(){
   
   int i;
   
   Side = -1;
   Open_Level = 0;
   
   for(i=0; i<OrdersTotal(); i++) {
      
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
   
         if (   (Magic_N==0 || OrderMagicNumber () == Magic_N)
             && (OrderType()==OP_SELL || OrderType()==OP_BUY)
             && OrderSymbol()==Symbol()
             ){
            Side    = OrderType();
            Open_Level = OrderOpenPrice();
            return(0);
         }
         
      }
   
   }
     
   // Reset Orders
   Close_Long  = 0;
   Close_Short = 0;
   
   // Reset P/L
   Profit = 0;
   
   return(0);
}

int start(){
      
   EA_Calculations(); // The heart of this strategy
      
   if(Close_Long == 1){
      ClosePos(OP_BUY);
   }
   
   if(Close_Short == 1){
      ClosePos(OP_SELL);
   }
         
   EA_Notes(); // Error Messages
   
   return(0);

}

//+------------------------------------------------------------------+

// EA Buy and Sell calculations
void EA_Calculations(){
   
   // Initially all possibilities set to 0
   // If any condition applies to any of them change to 1
   Close_Long = 0;
   Close_Short = 0;   
   
   int period = Get_TimeFrame(TimeFrame);
   
   if (Close[0] > iBands(NULL,period,BB_Periods,BB_Deviation,0,PRICE_CLOSE,MODE_UPPER,0) && EA_Activated) Close_Long = 1;
   if (Close[0] < iBands(NULL,period,BB_Periods,BB_Deviation,0,PRICE_CLOSE,MODE_LOWER,0) && EA_Activated) Close_Short = 1;
   
}

// Notes given by the Expert
void EA_Notes(){
   
   string Note = EA_Name+"\n";
   Note = Note + "Profit: " + DoubleToStr(Profit,2) + "\n";

   Comment(Note);
}

//+------------------------------------------------------------------+
// Closing positions                                                 |
//+------------------------------------------------------------------+
int ClosePos(int direction){
   
   int    i        = 0;
   int    attempts = 0;
   int    order   = 0;
   double price;
   string string_direction = "";

   for(i=0; i<OrdersTotal(); i++) {
      
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
 
         if (OrderType()==direction && OrderSymbol()==Symbol() && ((OrderMagicNumber () == Magic_N) || Magic_N==0)) {
            
            for(attempts=0;attempts<3;attempts++){
               
               if (IsTradeContextBusy()){
                  
                  Sleep(1000);
               
               }else{
                  
                  RefreshRates();
   
                  if(direction == OP_BUY){
                     price = Bid;
                     string_direction = "Long";
                  }else{
                     price = Ask;
                     string_direction = "Short";
                  }
               
                  if(EASounds) PlaySound("alert.wav");
                    
                  order = OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(price,Digits),Slippage,Red);
    
                  if(order==0){
                     Print("Error Occured : "+Errors(GetLastError()));
                  } 
                  else{
                     attempts = 3;
                     Print("Order closed : "+Symbol()+" Close @ "+price+" order ="+OrderTicket());
                     Profit = Profit + OrderProfit();
                     Side = -1;
                     Open_Level = 0;
                     Notifications("Close "+string_direction,price,0,0,OrderTicket());
                     return(order);
                  }
               }
            }
         }
      }
   }
   return(order);
}

//+------------------------------------------------------------------+
//| return error description                                         |
//+------------------------------------------------------------------+
string Errors(int error_code){
   
   string desc_error;
   
   switch(error_code){

      case 0:
      case 1:   desc_error="no error";                                                  break;
      case 2:   desc_error="common error";                                              break;
      case 3:   desc_error="invalid trade parameters";                                  break;
      case 4:   desc_error="trade server is busy";                                      break;
      case 5:   desc_error="old version of the client terminal";                        break;
      case 6:   desc_error="no connection with trade server";                           break;
      case 7:   desc_error="not enough rights";                                         break;
      case 8:   desc_error="too frequent requests";                                     break;
      case 9:   desc_error="malfunctional trade operation";                             break;
      case 64:  desc_error="account disabled";                                          break;
      case 65:  desc_error="invalid account";                                           break;
      case 128: desc_error="trade timeout";                                             break;
      case 129: desc_error="invalid price";                                             break;
      case 130: desc_error="invalid stops";                                             break;
      case 131: desc_error="invalid trade volume";                                      break;
      case 132: desc_error="market is closed";                                          break;
      case 133: desc_error="trade is disabled";                                         break;
      case 134: desc_error="not enough money";                                          break;
      case 135: desc_error="price changed";                                             break;
      case 136: desc_error="off quotes";                                                break;
      case 137: desc_error="broker is busy";                                            break;
      case 138: desc_error="requote";                                                   break;
      case 139: desc_error="order is locked";                                           break;
      case 140: desc_error="long positions only allowed";                               break;
      case 141: desc_error="too many requests";                                         break;
      case 145: desc_error="modification denied because order too close to market";     break;
      case 146: desc_error="trade context is busy";                                     break;
      // -----------------------------------------------------------------------------------///
      case 4000: desc_error="no error";                                                 break;
      case 4001: desc_error="wrong function pointer";                                   break;
      case 4002: desc_error="array index is out of range";                              break;
      case 4003: desc_error="no memory for function call stack";                        break;
      case 4004: desc_error="recursive stack overflow";                                 break;
      case 4005: desc_error="not enough stack for parameter";                           break;
      case 4006: desc_error="no memory for parameter string";                           break;
      case 4007: desc_error="no memory for temp string";                                break;
      case 4008: desc_error="not initialized string";                                   break;
      case 4009: desc_error="not initialized string in array";                          break;
      case 4010: desc_error="no memory for array\' string";                             break;
      case 4011: desc_error="too long string";                                          break;
      case 4012: desc_error="remainder from zero divide";                               break;
      case 4013: desc_error="zero divide";                                              break;
      case 4014: desc_error="unknown command";                                          break;
      case 4015: desc_error="wrong jump (never generated error)";                       break;
      case 4016: desc_error="not initialized array";                                    break;
      case 4017: desc_error="dll calls are not allowed";                                break;
      case 4018: desc_error="cannot load library";                                      break;
      case 4019: desc_error="cannot call function";                                     break;
      case 4020: desc_error="expert function calls are not allowed";                    break;
      case 4021: desc_error="not enough memory for temp string returned from function"; break;
      case 4022: desc_error="system is busy (never generated error)";                   break;
      case 4050: desc_error="invalid function parameters count";                        break;
      case 4051: desc_error="invalid function parameter value";                         break;
      case 4052: desc_error="string function internal error";                           break;
      case 4053: desc_error="some array error";                                         break;
      case 4054: desc_error="incorrect series array using";                             break;
      case 4055: desc_error="custom indicator error";                                   break;
      case 4056: desc_error="arrays are incompatible";                                  break;
      case 4057: desc_error="global variables processing error";                        break;
      case 4058: desc_error="global variable not found";                                break;
      case 4059: desc_error="function is not allowed in testing mode";                  break;
      case 4060: desc_error="function is not confirmed";                                break;
      case 4061: desc_error="send mail error";                                          break;
      case 4062: desc_error="string parameter expected";                                break;
      case 4063: desc_error="integer parameter expected";                               break;
      case 4064: desc_error="double parameter expected";                                break;
      case 4065: desc_error="array as parameter expected";                              break;
      case 4066: desc_error="requested history data in update state";                   break;
      case 4099: desc_error="end of file";                                              break;
      case 4100: desc_error="some file error";                                          break;
      case 4101: desc_error="wrong file name";                                          break;
      case 4102: desc_error="too many opened files";                                    break;
      case 4103: desc_error="cannot open file";                                         break;
      case 4104: desc_error="incompatible access to a file";                            break;
      case 4105: desc_error="no order selected";                                        break;
      case 4106: desc_error="unknown symbol";                                           break;
      case 4107: desc_error="invalid price parameter for trade function";               break;
      case 4108: desc_error="invalid ticket";                                           break;
      case 4109: desc_error="trade is not allowed";                                     break;
      case 4110: desc_error="longs are not allowed";                                    break;
      case 4111: desc_error="shorts are not allowed";                                   break;
      case 4200: desc_error="object is already exist";                                  break;
      case 4201: desc_error="unknown object property";                                  break;
      case 4202: desc_error="object is not exist";                                      break;
      case 4203: desc_error="unknown object type";                                      break;
      case 4204: desc_error="no object name";                                           break;
      case 4205: desc_error="object coordinates error";                                 break;
      case 4206: desc_error="no specified subwindow";                                   break;
      default:   desc_error="unknown error";
   }

   return(desc_error);
   
}  

//+------------------------------------------------------------------+
// Notifications (Sound & Email)                                                      |
//+------------------------------------------------------------------+
void Notifications(string _type, double _price, double _sl, double _tp, int _order) {
   
   string Alerta         = EA_Name;
   string Alerta_Subject = "";
   string Alerta_Body    = "";
   string CurDate        = TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);
 
   Alerta = Alerta + ": "+ _type +" @ "+DoubleToStr(_price,Digits)+"; P/L: "+DoubleToStr(Profit,2)+" at "+CurDate+" Order:"+DoubleToStr(_order,0)+"."; 
   
   Alerta_Subject = EA_Name+" - "+Symbol() + " (" + TFToStr(Get_TimeFrame(TimeFrame)) +") Alert";
   Alerta_Body    = Symbol() + " (" + TFToStr(Get_TimeFrame(TimeFrame)) +") - "+Alerta;
      
   if (Sound_Alert) Alert(Alerta_Body);
   if (Email_Alert) SendMail(Alerta_Subject, Alerta_Body);

   return;
}

int Get_TimeFrame(int BTF, bool mins = false){
   int Periodo, Minutes;
   if (BTF==1){ Periodo = PERIOD_M5;  Minutes = 5;     }
   if (BTF==2){ Periodo = PERIOD_M15; Minutes = 15;    }
   if (BTF==3){ Periodo = PERIOD_M30; Minutes = 30;    }
   if (BTF==4){ Periodo = PERIOD_H1;  Minutes = 60;    }
   if (BTF==5){ Periodo = PERIOD_H4;  Minutes = 240;   }
   if (BTF==6){ Periodo = PERIOD_D1;  Minutes = 1440;  }
   if (BTF==7){ Periodo = PERIOD_W1;  Minutes = 10080; }
   if (BTF==8){ Periodo = PERIOD_MN1; Minutes = 43200; }
   if (mins) return(Minutes); else return(Periodo);
}

string TFToStr(int tf){
  if (tf == 0)        tf = Period();
  if (tf >= 43200)    return("MN");
  if (tf >= 10080)    return("W1");
  if (tf >=  1440)    return("D1");
  if (tf >=   240)    return("H4");
  if (tf >=    60)    return("H1");
  if (tf >=    30)    return("M30");
  if (tf >=    15)    return("M15");
  if (tf >=     5)    return("M5");
  if (tf >=     1)    return("M1");
  return("");
}