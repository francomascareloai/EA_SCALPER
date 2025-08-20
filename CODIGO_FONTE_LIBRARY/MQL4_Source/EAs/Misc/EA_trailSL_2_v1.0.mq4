#property copyright "Bugscoder Studio"
#property link      "https://www.bugscoder.com/"
#property version   "1.00"
#property strict

input bool ENABLE_BE = true;
input int BE_STEP = 20;
input int BE_POINT = 10;
input bool ENABLE_TRAILSL = true;
input bool TRAIL_AFTER_BE = true;
input int TRAIL_START = 40;
input int TRAIL_STEP = 10;
input int TRAIL_POINT = 10;

double SL = 200;

int OnInit() {

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {

}

bool firstLoad = false;
void OnTick() {
   if (firstLoad == false) {
      //int ticket = OrderSend(NULL, OP_BUY, 0.01, Ask, 0, price_calc(Ask, -SL), 0);
      // int ticket = OrderSend(NULL, OP_SELL, 0.01, Bid, 0, price_calc(Bid, SL), 0);
      // if (ticket > 0) { firstLoad = true; }
      // return;
   }
   
   be();
   trailSL();
}

void be() {
   if (ENABLE_BE == false) { return; }
   
   for(int x=OrdersTotal(); x>=0; x--) {
      if (OrderSelect(x, SELECT_BY_POS) == false) { continue; }
      if (OrderSymbol() != Symbol()) { continue; }
      //if (OrderMagicNumber() != MAGIC_NUMBER) { continue; }
      if (OrderType() != OP_BUY && OrderType() != OP_SELL) { continue; }
      if (OrderProfit() < 0) { continue; }
      if (OrderType() == OP_BUY  && OrderStopLoss() > OrderOpenPrice()) { continue; }
      if (OrderType() == OP_SELL && OrderStopLoss() < OrderOpenPrice()) { continue; }
      
      if (MathAbs(price_diff(OrderOpenPrice(), (OrderType() == OP_BUY ? Bid : Ask))) < BE_STEP) { continue; }
      
      double newSL = BE_POINT > 0 ? price_calc(OrderOpenPrice(), BE_POINT*(OrderType() == OP_BUY ? 1 : -1)) : 0;
      
      bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0);
      if (ret == true) {
         double _close = OrderType() == OP_BUY ? Bid : Ask;
         Print(__FUNCTION__, " [ok @ ", DoubleToString(_close, Digits), " newSL: ", DoubleToString(newSL, Digits), "]");
      } else {
         Print(__FUNCTION__, " [error ", GetLastError(), "]");
      }
   }
}

void trailSL() {
   if (ENABLE_TRAILSL == false) { return; }
   
   for(int x=OrdersTotal(); x>=0; x--) {
      if (OrderSelect(x, SELECT_BY_POS) == false) { continue; }
      if (OrderSymbol() != Symbol()) { continue; }
      //if (OrderMagicNumber() != MAGIC_NUMBER) { continue; }
      if (OrderType() != OP_BUY && OrderType() != OP_SELL) { continue; }
      if (OrderProfit() < 0) { continue; }
      
      double _close = OrderType() == OP_BUY ? Bid : Ask;
      bool _trailAfterBE = TRAIL_AFTER_BE == true && ENABLE_BE == true ? true : false;
      if (_trailAfterBE == true) {
         if (OrderType() == OP_BUY  && OrderStopLoss() < OrderOpenPrice()) { continue; }
         if (OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice()) { continue; }
      }
      
      if (_trailAfterBE == false && MathAbs(price_diff(OrderOpenPrice(), _close)) < TRAIL_START) { continue; }
      
      double oldSL = SL > 0 ? price_calc(OrderOpenPrice(), SL*(OrderType() == OP_BUY ? -1 : 1)) : 0;
      double _startPrice = price_calc(OrderOpenPrice(), (TRAIL_START-TRAIL_STEP)*(OrderType() == OP_BUY ? 1 : -1));
      if (_trailAfterBE == true) {
         oldSL = BE_POINT > 0 ? price_calc(OrderOpenPrice(), BE_POINT*(OrderType() == OP_BUY ? 1 : -1)) : 0;
         _startPrice = price_calc(oldSL, (TRAIL_START-TRAIL_STEP)*(OrderType() == OP_BUY ? 1 : -1));
         if (MathAbs(price_diff(oldSL, _close)) < TRAIL_START) { continue; }
      }
      if (oldSL == 0) { continue; }
      
      int stepOpenPrice = (int) MathFloor(MathAbs(price_diff(_startPrice, _close))/TRAIL_STEP);
      int stepSL        = (int) MathFloor(MathAbs(price_diff(oldSL, OrderStopLoss()))/TRAIL_POINT);
      
      if (stepOpenPrice <= stepSL) { continue; }
      
      double newSL = price_calc(oldSL, TRAIL_POINT*(stepOpenPrice*(OrderType() == OP_BUY ? 1 : -1)));
      int STOP_LEVEL = (int) SymbolInfoInteger(NULL, SYMBOL_TRADE_STOPS_LEVEL);
      if (OrderType() == OP_BUY  && price_diff(Bid, newSL) <= STOP_LEVEL) { continue; }
      if (OrderType() == OP_SELL && price_diff(newSL, Ask) <= STOP_LEVEL) { continue; }
      if (OrderType() == OP_BUY  && newSL <= OrderStopLoss()) { continue; }
      if (OrderType() == OP_SELL && newSL >= OrderStopLoss()) { continue; }
      if (OrderType() == OP_BUY  && newSL >= Bid) { continue; }
      if (OrderType() == OP_SELL && newSL <= Ask) { continue; }
      
      bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0);
      if (ret == true) {
         Print(__FUNCTION__, " [ok] Step: ", stepOpenPrice, " @ ", DoubleToString(_close, Digits), " NewSL: ", DoubleToString(newSL, Digits));
      }
      else {
         Print(__FUNCTION__, " [ko]");
      }
   }
}

int price_diff(double price1, double price2, string _symbol = NULL) {
   if (_symbol == NULL) { _symbol = Symbol(); }
   double _point = SymbolInfoDouble(_symbol, SYMBOL_POINT);
   
   double p = NormalizeDouble((price1-price2)/_point, 0);
   string s = DoubleToString(p, 0);
   int diff = (int) StringToInteger(s);
   
   return diff;
}

double price_calc(double price, double pt, string _symbol = NULL) {
   if (_symbol == NULL) { _symbol = Symbol(); }
   double _point = SymbolInfoDouble(_symbol, SYMBOL_POINT);
   int    _digit = (int) SymbolInfoInteger(_symbol, SYMBOL_DIGITS);
   
   return NormalizeDouble(price+(pt*_point), _digit);
}