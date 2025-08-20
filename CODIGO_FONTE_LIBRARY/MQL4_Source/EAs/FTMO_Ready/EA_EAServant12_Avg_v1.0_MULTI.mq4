
#property copyright "Dwi Malistyo ea@dwim.web.id"
#property link      "http://ea.dwim.web.id"

extern int    TakeProfit = 4;
extern int    StopLoss = 10;
extern int    LockProfit = 100;
extern bool   Averaging = true;
extern double Lot_Multiplier = 1.0;
extern double Range = 4;
extern int    Level = 100;
extern bool   Modify_TPSL = false;  //Bila false maka TP_Money_Percents juga tidak berfungsi
extern double TP_Money_Percents  = 0.40;
string gsa_88[4];
int ticket=0; 
int a=0;

int init() {
   if (StopLoss < MarketInfo(Symbol(), MODE_STOPLEVEL)) StopLoss = MarketInfo(Symbol(), MODE_STOPLEVEL);
   return (0);
}

int deinit() {
   ObjectDelete("ObjLabel1");
   ObjectDelete("ObjLabel2");
   ObjectDelete("ObjLabel3");
   ObjectDelete("ObjLabel4");
   return (0);
}

int start() {
   double l_irsi_0 = iRSI(NULL, PERIOD_D1, 14, PRICE_CLOSE, 0);
   int l_pos_8 = 0;
   gsa_88[0] = "Dwi Malistyo - ea@dwim.web.id";
   gsa_88[1] = "http://ea.dwim.web.id";
   gsa_88[2] = "";
   gsa_88[4] = "";   
   gsa_88[3] = "";
   if (l_irsi_0 < 45.0) gsa_88[2] = "Daily Trend : Downtrend";
   else {
      if (l_irsi_0 > 55.0) gsa_88[4] = "Daily Trend : Uptrend";
      else gsa_88[2] = "Daily Trend : Sideways";
   }
   ObjectCreate("ObjLabel1", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel1", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel1", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel1", OBJPROP_YDISTANCE, 15);
   ObjectSetText("ObjLabel1", gsa_88[0], 7, "Arial", SteelBlue);
   ObjectCreate("ObjLabel2", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel2", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel2", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel2", OBJPROP_YDISTANCE, 25);
   ObjectSetText("ObjLabel2", gsa_88[1], 7, "Arial", SteelBlue);
   ObjectCreate("ObjLabel3", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel3", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel3", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel3", OBJPROP_YDISTANCE, 35);
   ObjectSetText("ObjLabel3", gsa_88[2], 7, "Arial", Red);
   ObjectSetText("ObjLabel3", gsa_88[4], 7, "Arial", Lime);   
   ObjectCreate("ObjLabel4", OBJ_LABEL, 0, 0, 0);
   ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
   ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
   ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
   ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
   if (Digits == 4) {
      for (l_pos_8 = 0; l_pos_8 < OrdersTotal(); l_pos_8++) {
         OrderSelect(l_pos_8, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) {
               if (OrderStopLoss() == 0.0 && OrderTakeProfit() == 0.0) {
                  if (OrderModify(OrderTicket(), OrderOpenPrice(), Bid - StopLoss * Point, Ask + TakeProfit * Point, 0) == TRUE) gsa_88[3] = "Put SL and TP at trade BUY no: #" + OrderTicket();
                  else gsa_88[3] = "ERROR -- Put SL and TP at trade BUY no: #" + OrderTicket();
                  ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                  ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                  ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                  ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
               } else {
                  if (Bid - OrderOpenPrice() > LockProfit * Point) {
                     if (OrderStopLoss() <= OrderOpenPrice()) {
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 1.0 * Point, OrderTakeProfit(), 0) == TRUE) gsa_88[3] = "Modify SL at trade BUY no: #" + OrderTicket();
                        else gsa_88[3] = "ERROR -- Modifying SL at trade BUY no: #" + OrderTicket();
                        ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                        ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                        ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                        ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                     } else {
                        if (Bid - OrderStopLoss() > LockProfit * Point) OrderModify(OrderTicket(), OrderOpenPrice(), Bid - LockProfit * Point, OrderTakeProfit(), 0);
                        gsa_88[3] = "Trailing SL trade no: #" + OrderTicket();
                        ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                        ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                        ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                        ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                     }
                  }
               }
            } else {
               if (OrderType() == OP_SELL) {
                  if (OrderStopLoss() == 0.0 && OrderTakeProfit() == 0.0) {
                     if (OrderModify(OrderTicket(), OrderOpenPrice(), Ask + StopLoss * Point, Bid - TakeProfit * Point, 0) == TRUE) gsa_88[3] = "Put SL and TP at trade SELL no: #" + OrderTicket();
                     else gsa_88[3] = "ERROR -- Put SL and TP at trade SELL no: #" + OrderTicket();
                     ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                     ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                     ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                     ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                  } else {
                     if (OrderOpenPrice() - Ask > LockProfit * Point) {
                        if (OrderStopLoss() >= OrderOpenPrice()) {
                           if (OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 1.0 * Point, OrderTakeProfit(), 0) == TRUE) gsa_88[3] = "Modify SL at trade SELL no: #" + OrderTicket();
                           else gsa_88[3] = "ERROR -- Modifying SL at trade SELL no: #" + OrderTicket();
                           ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                           ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                           ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                           ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                        } else {
                           if (OrderStopLoss() - Ask > LockProfit * Point) OrderModify(OrderTicket(), OrderOpenPrice(), Ask + LockProfit * Point, OrderTakeProfit(), 0);
                           gsa_88[3] = "Trailing SL at trade no: #" + OrderTicket();
                           ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                           ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                           ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                           ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                        }
                     }
                  }
               }
            }
         }
      }
   } else {
      if (Digits == 2 || Digits == 3 || Digits == 5) {
         for (l_pos_8 = 0; l_pos_8 < OrdersTotal(); l_pos_8++) {
            OrderSelect(l_pos_8, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol()) {
               if (OrderType() == OP_BUY) {
                  if (OrderStopLoss() == 0.0 && OrderTakeProfit() == 0.0) {
                     if (OrderModify(OrderTicket(), OrderOpenPrice(), Bid - 10.0 * (StopLoss * Point), Ask + 10.0 * (TakeProfit * Point), 0) == TRUE) gsa_88[3] = "Put SL and TP at trade BUY no: #" + OrderTicket();
                     else gsa_88[3] = "ERROR -- Put SL and TP at trade BUY no: #" + OrderTicket();
                     ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                     ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                     ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                     ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                  } else {
                     if (Bid - OrderOpenPrice() > 10.0 * (LockProfit * Point)) {
                        if (OrderStopLoss() <= OrderOpenPrice()) {
                           if (OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 10.0 * (1.0 * Point), OrderTakeProfit(), 0) == TRUE) gsa_88[3] = "Modify SL at trade BUY no: #" + OrderTicket();
                           else gsa_88[3] = "ERROR -- Modifying SL at trade BUY no: #" + OrderTicket();
                           ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                           ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                           ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                           ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                        } else {
                           if (Bid - OrderStopLoss() > 10.0 * (LockProfit * Point)) OrderModify(OrderTicket(), OrderOpenPrice(), Bid - 10.0 * (LockProfit * Point), OrderTakeProfit(), 0);
                           gsa_88[3] = "Trailing SL trade no: #" + OrderTicket();
                           ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                           ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                           ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                           ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                        }
                     }
                  }
               } else {
                  if (OrderStopLoss() == 0.0 && OrderTakeProfit() == 0.0) {
                     if (OrderModify(OrderTicket(), OrderOpenPrice(), Ask + 10.0 * (StopLoss * Point), Bid - 10.0 * (TakeProfit * Point), 0) == TRUE) gsa_88[3] = "Put SL and TP at trade SELL no: #" + OrderTicket();
                     else gsa_88[3] = "ERROR -- Put SL and TP at trade SELL no: #" + OrderTicket();
                     ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                     ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                     ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                     ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                  } else {
                     if (OrderOpenPrice() - Ask > 10.0 * (LockProfit * Point)) {
                        if (OrderStopLoss() >= OrderOpenPrice()) {
                           if (OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 10.0 * (1.0 * Point), OrderTakeProfit(), 0) == TRUE) gsa_88[3] = "Modify SL at trade SELL no: #" + OrderTicket();
                           else gsa_88[3] = "ERROR -- Modifying SL at trade SELL no: #" + OrderTicket();
                           ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                           ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                           ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                           ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                        } else {
                           if (OrderStopLoss() - Ask > 10.0 * (LockProfit * Point)) OrderModify(OrderTicket(), OrderOpenPrice(), Ask + 10.0 * (LockProfit * Point), OrderTakeProfit(), 0);
                           gsa_88[3] = "Trailing SL at trade no: #" + OrderTicket();
                           ObjectSet("ObjLabel4", OBJPROP_CORNER, 1);
                           ObjectSet("ObjLabel4", OBJPROP_XDISTANCE, 10);
                           ObjectSet("ObjLabel4", OBJPROP_YDISTANCE, 45);
                           ObjectSetText("ObjLabel4", gsa_88[3], 7, "Arial", Yellow);
                        }
                     }
                  }
               }
            }
         }
      }
   }

    if(total()>0 && total()<Level)
   {
     int type; double op, lastlot; 
     for(int i=0; i<OrdersTotal(); i++)
     {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()!=Symbol()) continue;
         type=OrderType();
         op=OrderOpenPrice();
         lastlot=OrderLots();
     }
     if(type==0 && Ask<=op-Range*Point) 
     {
        if(TakeProfit > 0 || StopLoss > 0)
        {
           if(Averaging) ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot*Lot_Multiplier,2),Ask,3,Ask-StopLoss*Point,Ask+TakeProfit*Point,"",0,0,Blue);
        }
        else
        {
           if(Averaging) ticket=OrderSend(Symbol(),0,NormalizeDouble(lastlot*Lot_Multiplier,2),Ask,3,0,0,"",0,0,Blue);
        }
     }
     if(type==1 && Bid>=op+Range*Point) 
     {
        if(TakeProfit > 0 || StopLoss > 0)
        {
           if(Averaging) ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot*Lot_Multiplier,2),Bid,3,Bid+StopLoss*Point,Bid-TakeProfit*Point,"",0,0,Red);
        }
        else
        {
           if(Averaging) ticket=OrderSend(Symbol(),1,NormalizeDouble(lastlot*Lot_Multiplier,2),Bid,3,0,0,"",0,0,Red);
        }
     }
   }
   if(Modify_TPSL==true && TakeProfit > 0 || StopLoss > 0 && total()>1)
   {
     double s_l, t_p;
     for(i=0; i<OrdersTotal(); i++)
     {
         OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if(OrderSymbol()!=Symbol() || OrderType()>1) continue;
         type=OrderType();
         s_l=OrderStopLoss();
         t_p=OrderTakeProfit();
     }
     for(i=OrdersTotal()-1; i>=0; i--)
     {
       OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
       if(OrderSymbol()!=Symbol() || OrderType()>1) continue;
       if(OrderType()==type)
       {
          if(OrderStopLoss()!=s_l || OrderTakeProfit()!=t_p)
          {
             OrderModify(OrderTicket(),OrderOpenPrice(),s_l,t_p,0,CLR_NONE);
          }
       }
     }
   }
   double profit=0;
   double TP_in_Money =  AccountBalance() * TP_Money_Percents / 100.0;   
   for(i=0; i<OrdersTotal(); i++)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol() || OrderType()>1) continue;
      profit+=OrderProfit();
   }
   if(Modify_TPSL==true && profit>=TP_in_Money || a>0) 
   {
      closeall();
      closeall();
      closeall();
      a++;
      if(total()==0) a=0;
   }  
   
   return (0);
}
//+------------------------------------------------------------------+
int total()
{
  int total=0;
  for(int i=0; i<OrdersTotal(); i++)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol()) continue;
      total++;
  }
  return(total);
}
//+------------------------------------------------------------------+
void closeall()
{
  for(int i=OrdersTotal()-1; i>=0; i--)
  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol()) continue;
      if(OrderType()>1) OrderDelete(OrderTicket());
      else
      {
        if(OrderType()==0) OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);
        else               OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
      }
  }
}