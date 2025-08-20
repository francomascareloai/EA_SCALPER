// Id: 17798
//+------------------------------------------------------------------+
//|                                        MA_Cross_with_Exit_EA.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "This EA triggers a Buy or Sell Order after two moving averages cross each other.\n"
#property description "- MA1 crossing above the MA2 triggers a Buy Order"
#property description "- MA1 crossing below the MA2 triggers a Sell Order\n"
#property description "It will Exit a trade:\n"
#property description "- If the MA1 crosses either the MA2 or MA3"
#property description "- Or after hitting Take Profit or Stop Loss\n"

enum e_cycles{  Min_1=1, Min_5=2, Min_15=3, Min_30=4, Min_60=5, Min_240=6, Daily=7, Weekly=8, Monthly=9 };
enum order_type{ Both=1, Only_Buy=2, Only_Sell=3 };
enum e_risk { Automatic=1, Manual=2 };

enum e_method{ SMA        =  1,
               EMA        =  2,
               Wilder     =  3,
               LWMA       =  4,
               SineWMA    =  5,
               TriMA      =  6,
               LSMA       =  7,
               SMMA       =  8,
               HMA        =  9,
               ZeroLagEMA = 10,
               ITrend     = 11,
               Median     = 12,
               GeoMean    = 13,
               REMA       = 14,
               ILRS       = 15,
               IE_2       = 16,
               TriMAgen   = 17
             };

enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern string     Comment1                      = "- Strategy Parameters -";
extern bool       EA_Activated                  = true;
input  e_cycles   TimeFrame                     = Min_60;
input  order_type Order_Type                    = Both;
extern int        Maximum_Trades_Open           = 3;
extern int        Wait_Mins_For_Next_Trade      = 30;
extern int        MA1_Period                    = 5;
extern e_method   MA1_Method                    = SMA;
extern e_price    MA1_Price_Type                = CLOSE;
extern int        MA2_Period                    = 30;
extern e_method   MA2_Method                    = SMA;
extern e_price    MA2_Price_type                = CLOSE;
extern int        MA3_Period                    = 10;
extern e_method   MA3_Method                    = SMA;
extern e_price    MA3_Price_type                = CLOSE;
extern double     Max_Pips_Away_From_Cross      = 10;
extern string     Comment2                      = "- Order magic number. May be used as user defined identifier -";
extern int        Magic_N                       = 123456;
extern string     Comment3                      = "- AutoLots True will calculate Lots automatically -";
input  e_risk     Risk_Management               = Automatic;
extern string     Comment4                      = "- Automatic Risk, For ex: 2.5 means 2.5% -";
extern double     Auto_Risk_Percent             = 2;
extern double     Auto_Max_Risk_in_Total_Orders = 7;
extern string     Comment5                      = "- Manual Number of Lots (if not Automatic Risk) -";
extern double     Manual_Lots                   = 0.3;
extern double     Manual_Maximum_Lots           = 3.0;
extern string     Comment6                      = "- Maximum price slippage for buy or sell orders -";
extern double     Slippage                      = 3;
extern string     Comment7                      = "- Stop loss in Pips -";
extern double     StopLoss                      = 10;
extern string     Comment8                      = "- Take profit in Pips -";
extern double     TakeProfit                    = 20;
extern string     Comment9                      = "- Trailing Stop in Pips -";
extern double     TrailingStop                  = 20;
extern double     TrailingStep                  = 5;
extern string     Comment10                     = "- Should the EA use alerts -";
extern bool       Sound_Alert                   = true;
extern bool       Email_Alert                   = false;
extern string     Comment11                     = "- Optional EA actions -";
extern bool       EASounds                      = true;
extern bool       Show_Profit_Comments          = true;

double Emergency_SL = 2000;

string EA_Name = "Moving Average Cross with Exit EA";
string CommentOrder = EA_Name+" Order";

double Lots;

int Open_Long, Open_Short, Close_Long, Close_Short;
double Side, Open_Level, TP_Level, SL_Level, TSL_Level = 0;
double Profit;
string Calculation_Comments, Orders_Comments, Profit_Comments;
datetime LastClose, LastOpen;

// Ongoing Risk
double Equity_Risked=0;
double Order_SL;
double Orders_Lots;

int init(){
   
       double temp = iCustom(NULL, 0, "Two_MA_Cross_Indicator", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Two_MA_Cross_Indicator' indicator");
       return INIT_FAILED;
   }
   // Trader sets Levels in pips but broker could work for ex. with 5 digits for EURUSD instead of 4
   if(Digits == 3 || Digits == 5) {
      Slippage     *= 10;
      StopLoss     *= 10;
      TakeProfit   *= 10;
      TrailingStop *= 10;
      TrailingStep *= 10;
   }
   return(0);
}

int start(){

   int i;
   int total = OrdersTotal();
   string Order_Label;
   
   Side = -1;
   Open_Level = 0;
   Orders_Comments = "";
   Profit_Comments = "";
   
      // Reset Levels
   TP_Level   = 0;
   SL_Level   = 0;
   TSL_Level  = 0;
   
   // Reset P/L
   Profit = 0;
   
   // Trades History
   for(i=0; i < OrdersHistoryTotal(); i++){
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)){
         Profit_Comments+="Ticket: "+OrderTicket()+" P/L: "+OrderProfit()+ "\n";
         Profit+=OrderProfit();
         if (OrderCloseTime()    > LastClose
         &&  OrderMagicNumber()  == Magic_N
         &&  OrderSymbol()       == Symbol()
         &&  OrderType()         <= OP_SELL){
            LastClose    = OrderCloseTime();
         }
      }
   }
   
   Equity_Risked = 0;
   Orders_Lots   = 0;
   
   // Ongoing Trades
   for(i=0; i<total; i++) {
      
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
   
         if (   (Magic_N==0 || OrderMagicNumber () == Magic_N)
             && (OrderType()==OP_SELL || OrderType()==OP_BUY)
             && OrderSymbol()==Symbol()
             ){
            Side    = OrderType();
            if (Side==OP_BUY)  Order_Label = "Buy Order";
            if (Side==OP_SELL) Order_Label = "Sell Order";
            Open_Level = OrderOpenPrice();
            Set_Levels();
            // SL is still in the negative side, so the equity is handling risk
            if ((Side==OP_BUY && Open_Level > OrderStopLoss()) || (Side==OP_SELL && OrderStopLoss() > Open_Level)){
               if (Side==OP_BUY) Order_SL = Open_Level-OrderStopLoss(); else Order_SL = OrderStopLoss() - Open_Level;
               Equity_Risked+= (((Order_SL/Point) * OrderLots())/AccountInfoDouble(ACCOUNT_EQUITY))*100;
               Orders_Lots+=OrderLots();
            }else{
               Equity_Risked+= 0;
               Orders_Lots+=0;
            }
            Orders_Comments+=Order_Label+" #"+OrderTicket()+" @ "+Open_Level+" TP: "+TP_Level+" SL: "+SL_Level+" Lots: "+OrderLots()+"\n";
            
         }
   
      }
   
   }
   
   if(Risk_Management==1){
      LotSize(); // if Auto=true, risk is calculated here
   }else{
      Lots = Manual_Lots;
   }
   
   Orders_Comments+="=======================\n";
   // Automatic Risk (Lots)
   if (Risk_Management==1){
      if (Auto_Max_Risk_in_Total_Orders-Equity_Risked > Auto_Risk_Percent)
         string Still_Available_Risk = DoubleToStr(Auto_Max_Risk_in_Total_Orders-Equity_Risked,2)+"% still available";
      else 
         Still_Available_Risk = "No Available Risk for other trade";
      Orders_Comments+="Equity Risked: "+DoubleToStr(Equity_Risked,2)+"% ("+Still_Available_Risk+")\n";
   // Manual Risk
   }else{
      if (Manual_Maximum_Lots-Orders_Lots > Manual_Lots)
         Still_Available_Risk = DoubleToStr(Manual_Maximum_Lots-Orders_Lots,2)+" Lots still available";
      else 
         Still_Available_Risk = "No Available Lots for other trade";
      Orders_Comments+="Lots in Risk: "+DoubleToStr(Orders_Lots,2)+" ("+Still_Available_Risk+")\n";
   }
     
   // Reset Orders
   Open_Long   = 0;
   Open_Short  = 0;
   Close_Long  = 0;
   Close_Short = 0;
   
   EA_Calculations(); // The heart of this strategy
   
   // Opening Positions
   
   if(Open_Long == 1 && total < Maximum_Trades_Open && (Order_Type == 1 || Order_Type == 2) && TimeCurrent() > LastClose+(Wait_Mins_For_Next_Trade*60)){
      OpenPos(OP_BUY);
   }
   
   if(Open_Short == 1 && total < Maximum_Trades_Open && (Order_Type == 1 || Order_Type == 3) && TimeCurrent() > LastClose+(Wait_Mins_For_Next_Trade*60)){
      OpenPos(OP_SELL);
   }
   
   // Closing Open Buy and Sell positions by Exit Rules (not SL or TP):
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
   Open_Long = 0;
   Open_Short = 0;
   Close_Long = 0;
   Close_Short = 0;
   
   int period     = Get_TimeFrame(TimeFrame);
   int multiplier = Get_TimeFrame(TimeFrame, true)/Period();
   int limit      = MA2_Period*multiplier*2;
   
   int iMA1_Method = -1;
   int iMA2_Method = -1;
   int iMA3_Method = -1;
   
   double MA1_0, MA2_0, MA3_0, MA1_1, MA2_1, MA3_1;
      
   if (MA1_Method==1) iMA1_Method = ENUM_MA_METHOD(0);
   if (MA1_Method==2) iMA1_Method = ENUM_MA_METHOD(1);
   if (MA1_Method==8) iMA1_Method = ENUM_MA_METHOD(2);
   if (MA1_Method==4) iMA1_Method = ENUM_MA_METHOD(3);
   if (MA2_Method==1) iMA2_Method = ENUM_MA_METHOD(0);
   if (MA2_Method==2) iMA2_Method = ENUM_MA_METHOD(1);
   if (MA2_Method==8) iMA2_Method = ENUM_MA_METHOD(2);
   if (MA2_Method==4) iMA2_Method = ENUM_MA_METHOD(3);
   if (MA3_Method==1) iMA3_Method = ENUM_MA_METHOD(0);
   if (MA3_Method==2) iMA3_Method = ENUM_MA_METHOD(1);
   if (MA3_Method==8) iMA3_Method = ENUM_MA_METHOD(2);
   if (MA3_Method==4) iMA3_Method = ENUM_MA_METHOD(3);
   
   if (iMA1_Method != -1){
   
      MA1_0 = iMA(NULL,period,MA1_Period,0,iMA1_Method,ENUM_APPLIED_PRICE(MA1_Price_Type),0);
      MA1_1 = iMA(NULL,period,MA1_Period,0,iMA1_Method,ENUM_APPLIED_PRICE(MA1_Price_Type),1);
   
   }else{
   
      MA1_0 = iCustom(NULL,period,"Two_MA_Cross_Indicator",MA1_Period,MA1_Method,MA1_Price_Type,MA2_Period,MA2_Method,MA2_Price_type,0,0);
      MA1_1 = iCustom(NULL,period,"Two_MA_Cross_Indicator",MA1_Period,MA1_Method,MA1_Price_Type,MA2_Period,MA2_Method,MA2_Price_type,0,1);
   
   }
   
   if (iMA2_Method != -1){
   
      MA2_0 = iMA(NULL,period,MA2_Period,0,iMA2_Method,ENUM_APPLIED_PRICE(MA2_Price_type),0);
      MA2_1 = iMA(NULL,period,MA2_Period,0,iMA2_Method,ENUM_APPLIED_PRICE(MA2_Price_type),1);
   
   }else{
   
      MA2_0 = iCustom(NULL,period,"Two_MA_Cross_Indicator",MA1_Period,MA1_Method,MA1_Price_Type,MA2_Period,MA2_Method,MA2_Price_type,1,0);
      MA2_1 = iCustom(NULL,period,"Two_MA_Cross_Indicator",MA1_Period,MA1_Method,MA1_Price_Type,MA2_Period,MA2_Method,MA2_Price_type,1,1);
   
   }
   
   if (iMA3_Method != -1){
   
      MA3_0 = iMA(NULL,period,MA3_Period,0,iMA3_Method,ENUM_APPLIED_PRICE(MA3_Price_type),0);
      MA3_1 = iMA(NULL,period,MA3_Period,0,iMA3_Method,ENUM_APPLIED_PRICE(MA3_Price_type),1);
   
   }else{
   
      MA3_0 = iCustom(NULL,period,"Two_MA_Cross_Indicator",MA1_Period,MA1_Method,MA1_Price_Type,MA3_Period,MA3_Method,MA3_Price_type,1,0);
      MA3_1 = iCustom(NULL,period,"Two_MA_Cross_Indicator",MA1_Period,MA1_Method,MA1_Price_Type,MA3_Period,MA3_Method,MA3_Price_type,1,1);
   
   }
   
   double PP=MarketInfo(OrderSymbol(), MODE_POINT);
   double Distance = MathAbs(MA2_0 - Close[0]);
   
   if (  (Risk_Management==1 && Auto_Max_Risk_in_Total_Orders-Equity_Risked > Auto_Risk_Percent)
      || (Risk_Management==2 && Manual_Maximum_Lots-Orders_Lots > Manual_Lots)
      )
      bool Risk_Allowed = true;
   else
      Risk_Allowed = false;
   
   if (Digits==3||Digits==5) Max_Pips_Away_From_Cross*=10;
   
   // Open Buy
   if (EA_Activated && Risk_Allowed && MA1_0 > MA2_0 && MA1_1 < MA2_1 && Distance <= Max_Pips_Away_From_Cross*PP && TimeCurrent() > (LastOpen+(Wait_Mins_For_Next_Trade*60))){
      Open_Long = 1;
      LastOpen = TimeCurrent();
   }
   
   // Open Sell
   if (EA_Activated && Risk_Allowed && MA1_0 < MA2_0 && MA1_1 > MA2_1 && Distance <= Max_Pips_Away_From_Cross*PP && TimeCurrent() > (LastOpen+(Wait_Mins_For_Next_Trade*60))){
      Open_Short = 1;
      LastOpen = TimeCurrent();
   }
   
   // Close Buy
   if (EA_Activated && ((MA1_0 < MA2_0 && MA1_1 > MA2_1)||(MA1_0 < MA3_0 && MA1_1 > MA3_1))){
      Close_Long = 1;
   }
   
   // Close Sell
   if (EA_Activated && ((MA1_0 > MA2_0 && MA1_1 < MA2_1)||(MA1_0 > MA3_0 && MA1_1 < MA3_1))){
      Close_Short = 1;
   }
   
   if (MA1_0 > MA2_0) string next_trade = "SELL"; else next_trade = "BUY";
   Calculation_Comments = "MA1: "+DoubleToStr(MA1_0,4)+" | MA2: "+DoubleToStr(MA2_0,4)+" | MA3: "+DoubleToStr(MA3_0,4)+"\n";
   Calculation_Comments = "Max Pips: "+(Max_Pips_Away_From_Cross*PP)+" | Distance: "+(Distance)+"\n";
   Calculation_Comments+= "Waiting for MA cross to "+next_trade;
   
}

// Determining the TP, SL and TSL Levels
void Set_Levels(){
   
   double PP=MarketInfo(OrderSymbol(), MODE_POINT);
   double BID=MarketInfo(OrderSymbol(), MODE_BID);
   double ASK=MarketInfo(OrderSymbol(), MODE_ASK);
   double TP = PP*TakeProfit;
   double SL = PP*StopLoss;
   double BUY_TSL  = BID - (TrailingStop*PP);
   double SELL_TSL = ASK + (TrailingStop*PP);
   
   if(Side == -1) return;
   
   if (StopLoss==0) StopLoss = Emergency_SL;
   
   if(TakeProfit > 0){
      
      if(Side == OP_BUY  ) TP_Level = Open_Level + TP;
      if(Side == OP_SELL ) TP_Level = Open_Level - TP;
   
   }

   if(StopLoss > 0){
      
      if(Side == OP_BUY  ) SL_Level = Open_Level - SL;
      if(Side == OP_SELL ) SL_Level = Open_Level + SL;
   
   }
   
   bool Order_Modified = false;
   if ((OrderTakeProfit()==0 && TakeProfit > 0) || (OrderStopLoss()==0 && StopLoss > 0)){
      if (OrderModify(OrderTicket(),0,SL_Level,TP_Level,0,clrBlue)){ Order_Modified = true; }
   }
   
   if(TrailingStop){
      
      if(Side == OP_BUY){
         if ((BID-OrderOpenPrice())>TrailingStop*PP){
            if (OrderStopLoss()<BID-(TrailingStop+TrailingStep-1)*PP && BID-TrailingStop*PP>SL_Level) {
               if (OrderModify(OrderTicket(),OrderOpenPrice(),BID-TrailingStop*PP,OrderTakeProfit(),0,clrMagenta)){ Order_Modified = true; }
            }
         }
      }
      
      if(Side == OP_SELL){
         if (OrderOpenPrice()-ASK>TrailingStop*PP) {
            if (OrderStopLoss()>ASK+(TrailingStop+TrailingStep-1)*PP && ASK+TrailingStop*PP<SL_Level) {
               if (OrderModify(OrderTicket(),OrderOpenPrice(),ASK+TrailingStop*PP,OrderTakeProfit(),0,clrMagenta)){ Order_Modified = true; }
            }
         }
      }
   
   }
   
   return;
}

//+------------------------------------------------------------------+
//| // Automatic Lot Size
//+------------------------------------------------------------------+
double LotSize() {

    double minlot    = MarketInfo(Symbol(), MODE_MINLOT);
    double maxlot    = MarketInfo(Symbol(), MODE_MAXLOT);
    double tickVal   = MarketInfo(Symbol(), MODE_TICKVALUE);

    double Equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double _Risk = Auto_Risk_Percent / 100;
    double Risk_per_Trade   = Equity * _Risk;
    double Pips_Risked = StopLoss  * tickVal;

    if(Risk_per_Trade > 0 && Pips_Risked > 0 && (Risk_per_Trade / Pips_Risked) > 0) {
        double lots = (Risk_per_Trade / Pips_Risked);
        if(lots < minlot) {
            lots = minlot;
        } else if(lots > maxlot) {
            lots = maxlot;
        }
        Lots = lots;
    }
    return(0);
}

// Notes given by the Expert
void EA_Notes(){
   
   if (Digits==3||Digits==5){
      double sl = StopLoss/10;
      double tp = TakeProfit/10;
      double tsl = TrailingStop/10;
   }
   else{
      sl = StopLoss/10;
      tp = TakeProfit/10;
      tsl = TrailingStop/10;
   }
   string Currency = AccountCurrency();
   
   string Note = EA_Name+"\n";
   Note = Note + "Account Equity: "+AccountInfoDouble(ACCOUNT_EQUITY)+" "+Currency+"\n";
   Note = Note + "Risk per SL Pip: "+DoubleToStr(((AccountInfoDouble(ACCOUNT_EQUITY)*(Auto_Risk_Percent/100))/sl),2)+" "+Currency+"\n";
   Note = Note + "Total Risk per Trade: "+DoubleToStr((AccountInfoDouble(ACCOUNT_EQUITY)*(Auto_Risk_Percent/100)),2)+" "+Currency+"\n";
   Note = Note + "Lots: " + DoubleToStr(Lots,2);
   if(Risk_Management==1) Note = Note + " (Automatic "+Auto_Risk_Percent+"%)"; else Note = Note + " (Set Manually)";
   Note = Note + "\n";
   Note = Note + "SL:" + DoubleToStr(sl,0) + " pips | "; 
   Note = Note + "TP:" + DoubleToStr(tp,0) + " pips | ";
   Note = Note + "TSL:" + DoubleToStr(tsl,0) + " pips\n";   
   Note = Note + "=======================\n";  
   if (Show_Profit_Comments){
      Note = Note + "Trades Results:\n";
      Note = Note + Profit_Comments;
   }
   Note = Note + "-----------------------\nTotal Profit: " + DoubleToStr(Profit,2) + "\n";
   Note = Note + "=======================\n"; 
   Note = Note + Calculation_Comments+"\n";
   Note = Note + "=======================\n"; 
   Note = Note + Orders_Comments;

   Comment(Note);
}

//+------------------------------------------------------------------+
// Opening positions
//+------------------------------------------------------------------+
int OpenPos(int direction){
   
   int    attempts = 0;
   int    order = 0;
   double price;
   string string_direction = "";
   
   for(attempts=0;attempts<3;attempts++){
      
      if (IsTradeContextBusy()){
         Sleep(1000);
      
      }else{
         
         RefreshRates();         

         if(direction == OP_BUY){
            price = Ask;
            string_direction = "Long";
         }else{
            price = Bid;
            string_direction = "Short";
         }        
         
         if(EASounds) PlaySound("alert.wav");

         order = OrderSend(Symbol(),direction,Lots,price,Slippage,0,0,CommentOrder,Magic_N,0,Red);
         
         if(order<=0) {
            
            Print("Error Occured : "+Errors(GetLastError()));
         
         }else{
            
            attempts = 3;
            Print("Order opened : "+Symbol()+" Price @ "+price+" SL @ "+StopLoss+" TP @"+TakeProfit+" order ="+order);
            Side = direction;
            Open_Level = OrderOpenPrice();
            TP_Level = 0;
            SL_Level = 0;
            TSL_Level = 0;
            Notifications("Open "+string_direction,price,StopLoss,TakeProfit,order);
            return(order);
         
         }
      }
   }
   return(-1);
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
 
   Alerta = Alerta + ": "+ _type +" @ "+DoubleToStr(_price,Digits)+"; P/L: "+DoubleToStr(Profit,2)+" SL: "+DoubleToStr(_sl,Digits)+"; TP: "+DoubleToStr(_tp,Digits)+" at "+CurDate+" Order:"+DoubleToStr(_order,0)+"."; 
   
   Alerta_Subject = EA_Name+" - "+Symbol() + " (" + TFToStr(Get_TimeFrame(TimeFrame)) +") Alert";
   Alerta_Body    = Symbol() + " (" + TFToStr(Get_TimeFrame(TimeFrame)) +") - "+Alerta;
      
   if (Sound_Alert) Alert(Alerta_Body);
   if (Email_Alert) SendMail(Alerta_Subject, Alerta_Body);

   return;
}

int Get_TimeFrame(int BTF, bool mins = false){
   int Periodo, Minutes;
   if (BTF==1){ Periodo = PERIOD_M1;  Minutes = 1;     }
   if (BTF==2){ Periodo = PERIOD_M5;  Minutes = 5;     }
   if (BTF==3){ Periodo = PERIOD_M15; Minutes = 15;    }
   if (BTF==4){ Periodo = PERIOD_M30; Minutes = 30;    }
   if (BTF==5){ Periodo = PERIOD_H1;  Minutes = 60;    }
   if (BTF==6){ Periodo = PERIOD_H4;  Minutes = 240;   }
   if (BTF==7){ Periodo = PERIOD_D1;  Minutes = 1440;  }
   if (BTF==8){ Periodo = PERIOD_W1;  Minutes = 10080; }
   if (BTF==9){ Periodo = PERIOD_MN1; Minutes = 43200; }
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

// ---------------------------------------------------- //
// ---------------- Moving Averages ------------------- //
// ---------------------------------------------------- //
double SMA(double &array[],int per,int bar, int mult=1){
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+(i*mult)];
   return(Sum/per);
}                

double EMA(double price,double prev,int per,int bar){
   if(bar >= Bars - 2)
      double ema = price;
   else 
      ema = prev + 2.0/(1+per)*(price - prev); 
   return(ema);
}

double Wilder(double price,double prev,int per,int bar){
   if(bar >= Bars - 2)
      double wilder = price;
   else 
      wilder = prev + (price - prev)/per; 
   return(wilder);
}

double LWMA(double &array[],int per,int bar, int mult=1){
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= (per - i);
      Sum += array[bar+(i*mult)]*(per - i);
   }
   if(Weight>0)
      double lwma = Sum/Weight;
   else
      lwma = 0; 
   return(lwma);
} 

double SineWMA(double &array[],int per,int bar, int mult=1){
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar+(i*mult)]*MathSin(pi*(i+1)/(per+1)); 
   }
   if(Weight>0)
      double swma = Sum/Weight;
   else
      swma = 0; 
   return(swma);
}

double TriMA(double &array[],int per,int bar, int mult=1){
   double sma;
   int len = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len;i++) {
      sma = SMA(array,len,bar+(i*mult),mult);
      sum += sma;
   } 
   double trima = sum/len;
   return(trima);
}

double LSMA(double &array[],int per,int bar, int mult=1){   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar+((per-i)*mult)];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}

double SMMA(double &array[],double prev,int per,int bar, int mult=1){
   if(bar == Bars - per)
      double smma = SMA(array,per,bar, mult);
   else if(bar < Bars - per){
      double Sum = 0;
      for(int i = 0;i < per;i++) Sum += array[bar+((i+1)*mult)];
      smma = (Sum - prev + array[bar])/per;
   }
   return(smma);
}                

double HMA(double &array[],int per,int bar, int mult=1){
   double tmp1[];
   int len = MathSqrt(per);
   ArrayResize(tmp1,len);
   if(bar == Bars - per)
      double hma = array[bar]; 
   else if(bar < Bars - per){
      for(int i=0;i<len;i++) tmp1[i] = 2*LWMA(array,per/2,bar+(i*mult),mult) - LWMA(array,per,bar+(i*mult),mult);  
      hma = LWMA(tmp1,len,0); 
   }  
   return(hma);
}

double ZeroLagEMA(double &price[],double prev,int per,int bar, int mult=1){
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   if(bar >= Bars - lag)
      double zema = price[bar];
   else 
      zema = alfa*(2*price[bar] - price[bar+(lag*mult)]) + (1-alfa)*prev;
   return(zema);
}

double ITrend(double &price[],double &array[],int per,int bar, int mult=1){
   double alfa = 2.0/(per+1);
   if (bar < Bars - 7)
      double it = (alfa - 0.25*alfa*alfa)*price[bar] + 0.5*alfa*alfa*price[bar+(1*mult)] - (alfa - 0.75*alfa*alfa)*price[bar+(2*mult)] + 2*(1-alfa)*array[bar+(1*mult)] - (1-alfa)*(1-alfa)*array[bar+(2*mult)];
   else
      it = (price[bar] + 2*price[bar+(1*mult)] + price[bar+(2*mult)])/4;
   return(it);
}

double Median(double &price[],int per,int bar, int mult=1){
   double array[];
   ArrayResize(array,per);
   for(int i = 0; i < per;i++) array[i] = price[bar+(i*mult)];
   ArraySort(array);
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
   return(median); 
}

double GeoMean(double &price[],int per,int bar, int mult=1){
   if(bar < Bars - per){ 
      double gmean = MathPow(price[bar],1.0/per); 
      for(int i = 1; i < per;i++) gmean *= MathPow(price[bar+(i*mult)],1.0/per); 
   }   
   return(gmean);
}

double REMA(double price,double &array[],int per,double lambda,int bar, int mult=1){
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3)
      double rema = price;
   else 
      rema = (array[bar+(1*mult)]*(1+2*lambda) + alpha*(price - array[bar+(1*mult)]) - lambda*array[bar+(2*mult)])/(1+lambda);    
   return(rema);
}

double ILRS(double &price[],int per,int bar, int mult=1){
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
   double sum1 = 0;
   double sumy = 0;
   for(int i=0;i<per;i++){ 
      sum1 += i*price[bar+(i*mult)];
      sumy += price[bar+(i*mult)];
   }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   if(num2 != 0) double slope = num1/num2; else slope = 0; 
   double ilrs = slope + SMA(price,per,bar,mult);
   return(ilrs);
}

double IE2(double &price[],int per,int bar, int mult=1){
   double ie = 0.5*(ILRS(price,per,bar,mult) + LSMA(price,per,bar,mult));
   return(ie); 
}
 

double TriMA_gen(double &array[],int per,int bar, int mult=1){
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMA(array,len1,bar+(i*mult),mult);
   double trimagen = sum/len2;
   return(trimagen);
}