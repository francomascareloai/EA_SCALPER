//+------------------------------------------------------------------+
//|                                               TrendMeLeaveMe.mq4 |
//|                              Copyright © 2006, Eng. Waddah Attar |
//|                                          waddahattar@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007,Eng Waddah Attar"
#property link      "waddahattar@hotmail.com"
//----
extern string BuyStop_Trend_Info = "_______________________";
extern string BuyStop_TrendName = "buystop";
extern int    BuyStop_TakeProfit = 50;
extern int    BuyStop_StopLoss = 30;
extern double BuyStop_Lot = 0.1;
extern int    BuyStop_StepUpper = 10;
extern int    BuyStop_StepLower = 50;
extern string SellStop_Trend_Info = "_______________________";
extern string SellStop_TrendName = "sellstop";
extern int    SellStop_TakeProfit = 50;
extern int    SellStop_StopLoss = 30;
extern double SellStop_Lot = 0.1;
extern int    SellStop_StepUpper = 50;
extern int    SellStop_StepLower = 10;
//------
int MagicBuyStop = 1101;
int MagicSellStop = 1102;
int glbOrderType;
int glbOrderTicket;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Comment("TrendMeLeaveMe by Waddah Attar");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double vH, vL, vM, sl, tp;
   if(ObjectFind(BuyStop_TrendName) == 0)
     {
       SetObject("High" + BuyStop_TrendName,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE1) + BuyStop_StepUpper*Point,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE2) + BuyStop_StepUpper*Point,
                 ObjectGet(BuyStop_TrendName, OBJPROP_COLOR));
       SetObject("Low" + BuyStop_TrendName,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE1) - BuyStop_StepLower*Point,
                 ObjectGet(BuyStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(BuyStop_TrendName, OBJPROP_PRICE2) - BuyStop_StepLower*Point,
                 ObjectGet(BuyStop_TrendName, OBJPROP_COLOR));
       vH = NormalizeDouble(ObjectGetValueByShift("High"+BuyStop_TrendName,0),Digits);
       vM = NormalizeDouble(ObjectGetValueByShift(BuyStop_TrendName,0),Digits);
       vL = NormalizeDouble(ObjectGetValueByShift("Low"+BuyStop_TrendName,0),Digits);
       sl = vH - BuyStop_StopLoss*Point;
       tp = vH + BuyStop_TakeProfit*Point;
       if(Ask <= vM && Ask >= vL && OrderFind(MagicBuyStop) == false)
           if(OrderSend(Symbol(), OP_BUYSTOP, BuyStop_Lot, vH, 3, sl, tp,
              "", MagicBuyStop, 0, Green) < 0)
               Print("Err (", GetLastError(), ") Open BuyStop Price= ", vH, " SL= ", 
                     sl," TP= ", tp);
       if(Ask <= vM && Ask >= vL && OrderFind(MagicBuyStop) == true && 
          glbOrderType == OP_BUYSTOP)
         {
           OrderSelect(glbOrderTicket, SELECT_BY_TICKET, MODE_TRADES);
           if(vH != OrderOpenPrice())
               if(OrderModify(glbOrderTicket, vH, sl, tp, 0, Green) == false)
                   Print("Err (", GetLastError(), ") Modify BuyStop Price= ", vH, 
                         " SL= ", sl, " TP= ", tp);
         }
     }
   if(ObjectFind(SellStop_TrendName) == 0)
     {
       SetObject("High" + SellStop_TrendName,
                 ObjectGet(SellStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE1) + SellStop_StepUpper*Point,
                 ObjectGet(SellStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE2) + SellStop_StepUpper*Point,
                 ObjectGet(SellStop_TrendName, OBJPROP_COLOR));
       SetObject("Low" + SellStop_TrendName, ObjectGet(SellStop_TrendName, OBJPROP_TIME1),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE1) - SellStop_StepLower*Point,
                 ObjectGet(SellStop_TrendName, OBJPROP_TIME2),
                 ObjectGet(SellStop_TrendName, OBJPROP_PRICE2) - SellStop_StepLower*Point,
                 ObjectGet(SellStop_TrendName, OBJPROP_COLOR));
       vH = NormalizeDouble(ObjectGetValueByShift("High" + SellStop_TrendName, 0), Digits);
       vM = NormalizeDouble(ObjectGetValueByShift(SellStop_TrendName, 0), Digits);
       vL = NormalizeDouble(ObjectGetValueByShift("Low" +SellStop_TrendName, 0), Digits);
       sl = vL + SellStop_StopLoss*Point;
       tp = vL - SellStop_TakeProfit*Point;
       if(Bid >= vM && Bid <= vH && OrderFind(MagicSellStop) == false)
           if(OrderSend(Symbol(), OP_SELLSTOP, SellStop_Lot, vL, 3, sl, tp, "", 
              MagicSellStop, 0, Red) < 0)
               Print("Err (", GetLastError(), ") Open SellStop Price= ", vL, " SL= ", sl, 
                     " TP= ", tp);
       if(Bid >= vM && Bid <= vH && OrderFind(MagicSellStop) == true && 
          glbOrderType == OP_SELLSTOP)
         {
           OrderSelect(glbOrderTicket, SELECT_BY_TICKET, MODE_TRADES);
           if(vL != OrderOpenPrice())
               if(OrderModify(glbOrderTicket, vL, sl, tp, 0, Red) == false)
                   Print("Err (", GetLastError(), ") Modify Sell Price= ", vL, " SL= ", sl, 
                         " TP= ", tp);
         }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderFind(int Magic)
  {
   glbOrderType = -1;
   glbOrderTicket = -1;
   int total = OrdersTotal();
   bool res = false;
   for(int cnt = 0 ; cnt < total ; cnt++)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderMagicNumber() == Magic && OrderSymbol() == Symbol())
         {
           glbOrderType = OrderType();
           glbOrderTicket = OrderTicket();
           res = true;
         }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetObject(string name,datetime T1,double P1,datetime T2,double P2,color clr)
  {
   if(ObjectFind(name) == -1)
     {
       ObjectCreate(name, OBJ_TREND, 0, T1, P1, T2, P2);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
     }
   else
     {
       ObjectSet(name, OBJPROP_TIME1, T1);
       ObjectSet(name, OBJPROP_PRICE1, P1);
       ObjectSet(name, OBJPROP_TIME2, T2);
       ObjectSet(name, OBJPROP_PRICE2, P2);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
     } 
  }
//+------------------------------------------------------------------+

