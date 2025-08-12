//+------------------------------------------------------------------+
//|                                           CLASS OOP MA+STOCH.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade/Trade.mqh>

bool isLastBuy = false, isLastSell = false;

class CLASS_MA_STOCH{ // BASE CLASS
   // MEMBER VARIABLES
   // PRIVATE MEMBER VARIABLES
   // private, protected, public
   private:
      CTrade obj_Trade;
      double maDATA[], stochDATA[];
      string symbol;
      ENUM_TIMEFRAMES period;
      double lotsize;
      string message;
      void print_msg(string msg);
      int stoch_upper_level;
      int stoch_lower_level;
      
   protected:
      int handleMA, handleSTOCH;
   
      int MA_Period;
      ENUM_MA_METHOD MA_Method;
      ENUM_MA_METHOD STOCH_Method;
      ENUM_STO_PRICE STOCH_App_Price;
      string getMessage(){return (message);}
      double Ask(){ return (SymbolInfoDouble(symbol,SYMBOL_ASK));}
      double Bid(){ return (SymbolInfoDouble(symbol,SYMBOL_BID));}
   
   public:
      void CLASS_MA_STOCH(); // constructor
      ~CLASS_MA_STOCH(){};// deconstructor
      double getHigh(int shift){ return (iHigh(symbol,period,shift));}
      double getLow(int shift){ return (iLow(symbol,period,shift));}
      datetime getTime(int shift){ return (iTime(symbol,period,shift));}
      
      int get_UP_L(){ return (stoch_upper_level);}
      int get_DN_L(){ return (stoch_lower_level);}
      
      void set_stoch_up (int up_level){stoch_upper_level = up_level;}
      void set_stoch_dn (int dn_level){stoch_lower_level = dn_level;}
      void set_ma_period (int ma_prd){MA_Period = ma_prd;}
      void set_ma_method (ENUM_MA_METHOD ma_mtd){MA_Method = ma_mtd;}
      void set_stoch_method (ENUM_MA_METHOD stoch_mtd){STOCH_Method = stoch_mtd;}
      void set_stoch_app_price (ENUM_STO_PRICE stoch_app){STOCH_App_Price = stoch_app;}

      int init (string symb,ENUM_TIMEFRAMES tf,double lot_size);
      virtual void getBuffers(int buf_no,int start_pos,int count);
      bool checkBuy();
      bool checkSell();
      virtual ulong OpenPosition(ENUM_POSITION_TYPE pos_type,double lots,
                                 int sl_pts,int tp_pts);
      //,,,,,,,,,,,,,,,,,,,//      
};
void CLASS_MA_STOCH::CLASS_MA_STOCH(void){ // :: scope operator
   // initialize all the necessary variables
   handleMA = INVALID_HANDLE;
   handleSTOCH = INVALID_HANDLE;
   ZeroMemory(maDATA);
   ZeroMemory(stochDATA);
   message = "";
}
void CLASS_MA_STOCH::print_msg(string msg){
   Print(msg);
}
int CLASS_MA_STOCH::init(string symb,ENUM_TIMEFRAMES tf,double lot_size){
   
   symbol = symb;
   period = tf;
   lotsize = lot_size;
   
   handleMA = iMA(symbol,period,MA_Period,0,MA_Method,PRICE_CLOSE);
   if (handleMA == INVALID_HANDLE){
      message = "ERROR: FAILED TO CREATE THE MA IND HANDLE. REVERTING";
      print_msg(getMessage());
      return (INIT_FAILED);
   }
   handleSTOCH = iStochastic(symbol,period,8,3,3,STOCH_Method,STOCH_App_Price);
   if (handleSTOCH == INVALID_HANDLE){
      message = "ERROR: FAILED TO CREATE THE STOCH IND HANDLE. REVERTING";
      print_msg(getMessage());
      return (INIT_FAILED);
   }
   
   ArraySetAsSeries(maDATA,true);
   ArraySetAsSeries(stochDATA,true);
   
   return (INIT_SUCCEEDED);
}
void CLASS_MA_STOCH::getBuffers(int buf_no,int start_pos,int count){
   if (CopyBuffer(handleMA,buf_no,start_pos,count,maDATA) < count){
      message = "ERROR: NOT ENOUGH DATA FROM MA IND FOR FURTHER ANALYSIS";
      print_msg(getMessage());
      return;
   }
   if (CopyBuffer(handleSTOCH,0,0,3,stochDATA) < 3){
      message = "ERROR: NOT ENOUGH DATA FROM STOCH IND FOR FURTHER ANALYSIS";
      print_msg(getMessage());
      return;
   }
}
bool CLASS_MA_STOCH::checkBuy(void){
   getBuffers(0,0,3);
   double low0 = getLow(0);
   double high0 = getHigh(0);
   datetime currBarTime0 = getTime(0);
   static datetime signalTime = currBarTime0;
   
   if (stochDATA[0] > get_DN_L() && stochDATA[1] < get_DN_L() && low0 < maDATA[0]
      && signalTime != currBarTime0){
      message = "BUY SIGNAL @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
      print_msg(getMessage());
      signalTime = currBarTime0;
      return (true);
   }
   else {return (false);}
}
bool CLASS_MA_STOCH::checkSell(void){
   getBuffers(0,0,3);
   double low0 = getLow(0);
   double high0 = getHigh(0);
   datetime currBarTime0 = getTime(0);
   static datetime signalTime = currBarTime0;
   
   if (stochDATA[0] < get_UP_L() && stochDATA[1] > get_UP_L() && high0 > maDATA[0]
      && signalTime != currBarTime0){
      message = "SELL SIGNAL @ "+TimeToString(TimeCurrent(),TIME_SECONDS);
      print_msg(getMessage());
      signalTime = currBarTime0;
      return (true);
   }
   else {return (false);}
}
ulong CLASS_MA_STOCH::OpenPosition(ENUM_POSITION_TYPE pos_type,double lots,
                      int sl_pts,int tp_pts){
   lots = lotsize;
   double price = NULL;
   ulong ticket = NULL;
   
   if (pos_type == POSITION_TYPE_BUY){
      price = Ask();
      double sl = price - sl_pts*_Point;
      double tp = price + tp_pts*_Point;
      if (obj_Trade.Buy(lots,symbol,price,sl,tp)){
         ticket = obj_Trade.ResultOrder();
      }
   }
   else if (pos_type == POSITION_TYPE_SELL){
      price = Bid();
      double sl = price + sl_pts*_Point;
      double tp = price - tp_pts*_Point;
      if (obj_Trade.Sell(lots,symbol,price,sl,tp)){
         ticket = obj_Trade.ResultOrder();
      }
   }
   else {ticket = -1;}
   
   string type = pos_type == POSITION_TYPE_BUY ? "BUY" : "SELL"; // TERNARY
   message = "OPENED "+type+" POSITION WITH TICKET # "+IntegerToString(ticket);
   print_msg(getMessage());
   
   return (ticket);
}







CLASS_MA_STOCH OBJECT_EA;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){

   OBJECT_EA.set_ma_method(MODE_SMA);
   OBJECT_EA.set_ma_period(100);
   OBJECT_EA.set_stoch_app_price(STO_LOWHIGH);
   OBJECT_EA.set_stoch_method(MODE_SMA);
   OBJECT_EA.set_stoch_dn(20);
   OBJECT_EA.set_stoch_up(80);
   
   OBJECT_EA.init(_Symbol,_Period,0.01);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   
   if (OBJECT_EA.checkBuy()){
      if (isLastBuy == false){
         OBJECT_EA.OpenPosition(POSITION_TYPE_BUY,0.01,300,300);
         isLastBuy = true; isLastSell = false;
      }
   }
   else if (OBJECT_EA.checkSell()){
      if (!isLastSell){
         OBJECT_EA.OpenPosition(POSITION_TYPE_SELL,0.01,300,300);
         isLastBuy = false; isLastSell = true;
      }
   }
}
//+------------------------------------------------------------------+

class NEW_CLASS_MA_STOCH : public CLASS_MA_STOCH{ //derived class
   public:
      void NEW_CLASS_MA_STOCH(){};
      ~NEW_CLASS_MA_STOCH(){};
      void deinit();
};
void NEW_CLASS_MA_STOCH::deinit(void){
   double high = OBJECT_DERIVED_EA.getHigh(0);
   Print(high);

   IndicatorRelease(handleMA);
   IndicatorRelease(handleSTOCH);
   //message = "INDICATOR HANDLES DEINITIALISED";
   //print_msg(getMessage());
   Print("INDICATOR HANDLES DEINITIALISED");
}

NEW_CLASS_MA_STOCH OBJECT_DERIVED_EA;

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   OBJECT_DERIVED_EA.deinit();
}
