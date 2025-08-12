//+------------------------------------------------------------------+
//|                                                Trend_Catcher.mq4 |
//|                                                 Dmitriy Epshteyn |
//|                                                  setkafx@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Dmitriy Epshteyn"
#property link      "setkafx@mail.ru"
#property version   "1.00"
#property strict

input ENUM_TIMEFRAMES Candle_TF=PERIOD_CURRENT;
// Candle, for a period which can be opened only one order, an example, if you select PERIOD_D1 - the advisor can open only one order at the current daily candle
extern int    PeriodMA_slow=200;
// The period of the slow MA
extern int    PeriodMA_fast=50;
// The period of the first fast MA
extern int    PeriodMA_fast2=25;
// The period of the second fast MA
extern double Step_Sar = 0.004;
extern double Max_Sar  = 0.2;
// Parabolic SAR indicator settings
extern bool   Auto_SL=true;
// enable automatic stop loss point on the indicator Parabolic SAR
extern bool   Auto_TP=true;
// enable automatic take profit, which is calculated from stop loss
extern int    minSL=10;
// if the current stop-loss less than minSL, no order is placed
extern int    maxSL=200;
// if the current stop-loss greater than maxSL, no order is placed
extern double SL_koef=1;
// factor, which is multiplied by the stop loss (if 1, the stop loss is at the point of Parabolic SAR)
extern double TP_koef=1;
// calculating the take profit from stop loss, for example: if TP_koef = 2, it means that the take profit is twice the stop loss
extern int    SL=20;
// Stop Loss in points, apply if Auto_SL = false
extern int    TP=200;
// take profit at the points is used, if Auto_TP = false
extern double Risk=2;
// the risk on which the lot of order is calculated, depends on the stop loss
extern bool   Martin=true;
// If true, martingale applies
extern double Koef=2;
// If the latest order is closed with a loss, the risk of the next order will be multiplied by Koef
extern int Profit_Level=500;
// if the position goes in the profit pips on Profit_Level
extern int SL_Plus=1;
// + SL_Plus pips exposes the breakeven to order
extern int Profit_Level2=500;
// if the position goes to profit on Profit_Level2 pips
extern int TrailingStop2=10;
// at a distance TrailingStop2 pips stop loss will drag the price
extern int    Slip=3;
// slippage
extern int    Magic=1;
// Magic number
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int b=0,s=0,n=0,total=OrdersTotal();
   double bez=NormalizeDouble(Profit_Level*Point,Digits);
   double sl_plus=NormalizeDouble(SL_Plus*Point,Digits);
   double bez2=NormalizeDouble(Profit_Level2*Point,Digits);
   double tr=NormalizeDouble(TrailingStop2*Point,Digits);
   for(int i1=total-1; i1>=0; i1--)
      if(OrderSelect(i1,SELECT_BY_POS))
         if(OrderSymbol()==Symbol())
            if(OrderMagicNumber()==Magic)
              {
               if(OrderType()==OP_BUY)
                 {
                  b++;n++;
                  if(Bid-OrderOpenPrice()>bez && OrderStopLoss()<NormalizeDouble(OrderOpenPrice()+sl_plus,Digits) && OrderStopLoss()!=NormalizeDouble(OrderOpenPrice()+sl_plus,Digits))
                    {bool mod=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+sl_plus,Digits),OrderTakeProfit(),0,0);Print("Безубыток Buy",NormalizeDouble(OrderOpenPrice()+sl_plus,Digits));}
                  if(Bid-OrderOpenPrice()>bez2 && Bid-OrderStopLoss()>tr && OrderStopLoss()!=NormalizeDouble(Bid-tr,Digits))
                    {bool mod=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-tr,Digits),OrderTakeProfit(),0,0);Print("Трейлинг Buy",NormalizeDouble(Bid-tr,Digits));}
                 }
               if(OrderType()==OP_SELL)
                 {
                  s++;n++;
                  if(OrderOpenPrice()-Ask>bez && OrderStopLoss()>NormalizeDouble(OrderOpenPrice()-sl_plus,Digits) && OrderStopLoss()!=NormalizeDouble(OrderOpenPrice()-sl_plus,Digits))
                    {bool mod=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-sl_plus,Digits),OrderTakeProfit(),0,0);Print("Безубыток Sell",NormalizeDouble(OrderOpenPrice()-sl_plus,Digits));}
                  if(OrderOpenPrice()-Ask>bez2)
                     if(OrderStopLoss()-Ask>tr || OrderStopLoss()==0)
                        if(OrderStopLoss()!=NormalizeDouble(Ask+tr,Digits))
                          {bool mod=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+tr,Digits),OrderTakeProfit(),0,0);Print("Трейлинг Sell",NormalizeDouble(Ask+tr,Digits));}
                 }
              }
//--- history of the last closed order
   int h=0,accTotal1=OrdersHistoryTotal();
   double h_Percent=0;
   double Lot_History=0;
   for(int h_1=0;h_1<accTotal1;h_1++)
      if(OrderSelect(h_1,SELECT_BY_POS,MODE_HISTORY)==true)
         if(OrderSymbol()==Symbol())
            if(OrderMagicNumber()==Magic)
              {
               h_Percent=OrderProfit()+OrderSwap()+OrderCommission(); Lot_History=OrderLots();
               if(OrderOpenTime()>=iTime(Symbol(),Candle_TF,0)) {h++;}
              }
//--- signal and  indicators
   double SAR0=iSAR(Symbol(),0,Step_Sar,Max_Sar,0);  // stop loss forward on it 
   double SAR1 = iSAR(Symbol(),0,Step_Sar,Max_Sar,1);
   double SAR2 = iSAR(Symbol(),0,Step_Sar,Max_Sar,2);
   double MA_slow = iMA(NULL,0,PeriodMA_slow,0,MODE_SMA,PRICE_CLOSE,0);
   double MA_fast = iMA(NULL,0,PeriodMA_fast,0,MODE_SMA,PRICE_CLOSE,0);
   double MA_fast2= iMA(NULL,0,PeriodMA_fast2,0,MODE_SMA,PRICE_CLOSE,0);
//---
   int sig=0;
   if(Close[0]>SAR0&&Close[1]<SAR1&&MA_fast>MA_slow&&Ask>MA_fast2) {sig=1;}
   if(Close[0]<SAR0&&Close[1]>SAR1&&MA_fast<MA_slow&&Bid<MA_fast2) {sig=2;}
//--- stop loss and take profit
   double sl=0;
   double tp=0;
   double min_sl = NormalizeDouble(minSL*Point,Digits);
   double max_sl = NormalizeDouble(maxSL*Point,Digits);
   if(Auto_SL==false) {sl=NormalizeDouble(SL*Point,Digits);}
   if(Auto_TP==false) {tp=NormalizeDouble(TP*Point,Digits);}
//---
   if(Auto_SL==true&&Ask<SAR0) {sl=NormalizeDouble((MathAbs(SAR0-Ask))*SL_koef,Digits);}
   if(Auto_SL==true&&Bid>SAR0) {sl=NormalizeDouble((MathAbs(Bid-SAR0))*SL_koef,Digits);}
   if(sl<min_sl) {sl=min_sl;}
   if(sl>max_sl) {sl=max_sl;}
//---
   if(Auto_TP==true) {tp=NormalizeDouble(sl*TP_koef,Digits);}
//---
//--- lot count by the percentage of the account balance and apply the Martingale according to the settings
   double Procent=AccountBalance()/100*Risk;
   if(h_Percent<0 && Martin==true) {Procent=NormalizeDouble(MathAbs(h_Percent)*Koef,Digits);}
//---
   double stops=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
   double One_Lot=MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   double Lot=0;
   if(sl>0&&AccountFreeMargin()>=One_Lot*Lot) {Lot=NormalizeDouble(Procent/sl*Point/MarketInfo(Symbol(),MODE_TICKVALUE),2);}
   if(sl>0&&AccountFreeMargin()<=One_Lot*Lot) {Lot=NormalizeDouble((AccountBalance()/100*Risk)/sl*Point/MarketInfo(Symbol(),MODE_TICKVALUE),2);}
//---
   if(Lot<MarketInfo(Symbol(),MODE_MINLOT)) {Lot=MarketInfo(Symbol(),MODE_MINLOT);}
//---
   if(AccountFreeMargin()<One_Lot*Lot) {Comment("Not enough money to open a lot=",DoubleToStr(Lot,2)); return;}
//--- open orders
   if(n==0&&sig==1&&h==0&&sl>min_sl) {int open = OrderSend(Symbol(),OP_BUY,Lot,Ask,Slip,Ask-sl,Ask+tp,NULL,Magic,0,0);Print("Цена buy=",Ask,", Стоп лосс=",Ask-sl,", Тейк профит=",Ask+tp);}
   if(n==0&&sig==2&&h==0&&sl>min_sl) {int open = OrderSend(Symbol(),OP_SELL,Lot,Bid,Slip,Bid+sl,Bid-tp,NULL,Magic,0,0);Print("Цена sell=",Bid,", Стоп лосс=",Bid+sl,", Тейк профит=",Bid-tp);}
//--- close order on reverse signal
   for(int i2=total-1; i2>=0; i2--)
      if(OrderSelect(i2,SELECT_BY_POS))
         if(OrderSymbol()==Symbol())
            if(OrderMagicNumber()==Magic)
              {
               if(OrderType()==OP_BUY)
                 {
                  if(sig==2) {int cl=OrderClose(OrderTicket(),OrderLots(),Bid,Slip,0);}
                 }
               if(OrderType()==OP_SELL)
                 {
                  if(sig==1) {int cl=OrderClose(OrderTicket(),OrderLots(),Ask,Slip,0);}
                 }
              }
  }
//+------------------------------------------------------------------+
