
#property copyright ""
#property link      ""

extern int jarak_op_pip = 20;
extern double tp_dollar = 1.0;
extern double multiplier = 2.0;
extern int level = 7;
extern int slip_page = 5;
extern bool use_tp_sl = FALSE;
extern int tp = 30;
extern int sl = 50;
extern int magic = 191;
double Gd_128;
int G_ticket_136;
int Gi_140;
int G_count_144;
bool Gi_148 = FALSE;
double G_minlot_156;

int init() {
   if (Digits == 3 || Digits == 5) Gd_128 = 10.0 * Point;
   else Gd_128 = Point;
   G_minlot_156 = MarketInfo(Symbol(), MODE_MINLOT);
   if (G_minlot_156 == 0.01) Gi_140 = 2;
   if (G_minlot_156 == 0.1) Gi_140 = 1;
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int cmd_12;
   double order_open_price_16;
   double order_lots_24;
   int cmd_32;
   double order_open_price_36;
   double order_lots_44;
   double Ld_52;
   double Ld_60;
   double Ld_68;
   double Ld_0 = 0;
   for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
      Ld_0 += OrderProfit();
   }
   if (Ld_0 >= tp_dollar || G_count_144 > 0 || Gi_148) {
      f0_2();
      f0_2();
      f0_2();
      G_count_144++;
      Gi_148 = TRUE;
      if (f0_3() == 0) G_count_144 = 0;
   }
   for (pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         cmd_12 = OrderType();
         order_open_price_16 = OrderOpenPrice();
         order_lots_24 = OrderLots();
         if (f0_3() == 0) G_count_144 = 0;
      }
   }
   if (f0_3() == 0) Gi_148 = FALSE;
   if (IsTesting() && f0_3() == 0 && f0_1() == 0 && Hour() == 0) G_ticket_136 = OrderSend(Symbol(), OP_BUY, 0.01, Ask, slip_page, 0, 0, "", 0, 0, Blue);
   for (int pos_76 = 0; pos_76 < OrdersTotal(); pos_76++) {
      OrderSelect(pos_76, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         cmd_32 = OrderType();
         order_open_price_36 = OrderOpenPrice();
         order_lots_44 = OrderLots();
         if (OrderType() == OP_BUY) {
            Ld_52 += OrderLots();
            if (use_tp_sl && (OrderStopLoss() == 0.0 || OrderTakeProfit() == 0.0)) OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - sl * Gd_128, OrderOpenPrice() + tp * Gd_128, 0, CLR_NONE);
         }
         if (OrderType() == OP_SELL) {
            Ld_60 += OrderLots();
            if (use_tp_sl && (OrderStopLoss() == 0.0 || OrderTakeProfit() == 0.0)) OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + sl * Gd_128, OrderOpenPrice() - tp * Gd_128, 0, CLR_NONE);
         }
      }
   }
   if (f0_3() == 0 && f0_1() > 0) f0_0();
   if (f0_3() > 0 && f0_3() < level && (!Gi_148) && f0_1() == 0) {
      if (cmd_32 == OP_BUY) {
         Ld_68 = Ld_52 * multiplier - Ld_60;
         if (use_tp_sl) {
            G_ticket_136 = OrderSend(Symbol(), OP_SELLSTOP, NormalizeDouble(Ld_68, Gi_140), order_open_price_36 - jarak_op_pip * Gd_128, slip_page, order_open_price_36 - jarak_op_pip * Gd_128 +
               sl * Gd_128, order_open_price_36 - jarak_op_pip * Gd_128 - tp * Gd_128, "", magic, 0, Red);
         } else G_ticket_136 = OrderSend(Symbol(), OP_SELLSTOP, NormalizeDouble(Ld_68, Gi_140), order_open_price_36 - jarak_op_pip * Gd_128, slip_page, 0, 0, "", magic, 0, Red);
      }
      if (cmd_32 == OP_SELL) {
         Ld_68 = Ld_60 * multiplier - Ld_52;
         if (use_tp_sl) {
            G_ticket_136 = OrderSend(Symbol(), OP_BUYSTOP, NormalizeDouble(Ld_68, Gi_140), order_open_price_36 + jarak_op_pip * Gd_128, slip_page, order_open_price_36 + jarak_op_pip * Gd_128 - sl * Gd_128,
               order_open_price_36 + jarak_op_pip * Gd_128 + tp * Gd_128, "", magic, 0, Blue);
         } else G_ticket_136 = OrderSend(Symbol(), OP_BUYSTOP, NormalizeDouble(Ld_68, Gi_140), order_open_price_36 + jarak_op_pip * Gd_128, slip_page, 0, 0, "", magic, 0, Blue);
      }
   }
   return (0);
}


int f0_3() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol())
         if (OrderType() < OP_BUYLIMIT) count_0++;
   }
   return (count_0);
}

void f0_2() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderType() < OP_BUYLIMIT) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_page, CLR_NONE);
            else OrderClose(OrderTicket(), OrderLots(), Ask, slip_page, CLR_NONE);
         }
         OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol())
            if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
      }
   }
}


void f0_0() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol())
            if (OrderType() > OP_SELL) OrderDelete(OrderTicket());
      }
   }
}

int f0_1() {
   int count_0 = 0;
   for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      if (OrderType() > OP_SELL) count_0++;
   }
   return (count_0);
}
