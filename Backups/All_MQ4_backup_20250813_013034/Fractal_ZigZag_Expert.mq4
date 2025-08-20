//+------------------------------------------------------------------+
//|                                        Fractal ZigZag Expert.mq4 |
//|                                                        ikovrigin |
//|    This expert was made from a fractal zig zag indicator created |
//| by ikorigin  expert, made by bobammax, use at your own risk, will| 
//| work better on higher time frames,1 hour seems to be the best but|
//| it is your money.I'm not a programmer.                           |
//|                                                   bobammax       |
//+------------------------------------------------------------------+
#property copyright "ikovrigin, bobammax"
#property link      ""

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green
//---- input parameters
extern int Level = 2;
extern double TakeProfit = 25; 
extern double Lots = 1;
extern double TrailingStop = 10;
extern double InitialStop = 20;
extern int slip = 0;  //exits only
extern double lp = 300;
extern double sp = 30;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_SECTION);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexBuffer(1, ExtMapBuffer2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   int PU, PD, Trend = 2;
   PU = 0;
   PD = 0;
   double FU,FD,F;
   FU=0;
   FD=0;
   int shift = Bars-Level;
   int n;
//----
   if(shift > Level) 
       shift = shift - Level - 1;
//----
   if(counted_bars == 0)
   while(shift > Level - 1)
     {
       ExtMapBuffer1[shift] = 0;
       F = Low[shift];
       //----
       for(n = 1; n <= Level; n++)
         {
           if(Low[shift+n] < Low[shift] || Low[shift-n] < Low[shift]) 
               F = 0;
         }
       if(F > 0)
         {
           if(FD != 0)
               switch(Trend)
                 {
                   case 1: if(F < FD) 
                             {
                               ExtMapBuffer1[PU] = FU;
                               Trend = 2;
                             }
                           break;
                   case 2: if(F > FD) 
                             {
                               ExtMapBuffer1[PD] = FD;
                               Trend = 1;
                               if(PU >= PD)
                                 {
                                   FU = 0;
                                   PU = 0;
                                 }
                             }
                           break;
                 }
           FD = F;
           PD = shift;
           ExtMapBuffer2[PD] = FD;
         }    
       F = High[shift];
       for(n = 1; n <= Level; n++)
         {
           if(High[shift+n] > High[shift] || High[shift-n] > High[shift]) 
               F = 0;    
         }
       if(F > 0)
         {
           if(FU != 0) 
               switch(Trend)
                 {
                   case 1: if(F < FU)
                             {
                               ExtMapBuffer1[PU] = FU;
                               Trend = 2;
                               if(PD >= PU)
                                 {
                                   FD = 0;
                                   PD = 0;
                                 }
                             }
                           break;
                   case 2: if(F > FU)
                             {
                               ExtMapBuffer1[PD] = FD;
                               Trend = 1;
                             }
                           break;
                 }
           FU = F;
           PU = shift;
           ExtMapBuffer2[PU] = FU;
         }
	      shift--;
     }
   if(Trend == 1)
       ExtMapBuffer1[PU] = FU; 
   else 
       ExtMapBuffer1[PD] = FD;
// order section
   int OrderForThisSymbol = 0;
   for(int x = 0; x < OrdersTotal(); x++)
     {
       OrderSelect(x, SELECT_BY_POS, MODE_TRADES);
       if(OrderSymbol() == Symbol()) 
           OrderForThisSymbol++;
     }//end for
   if(Trend == 2 && OrderForThisSymbol == 0)
     {
       //Alert("Buy order triggered for "+Symbol()+" on the "+Period()+" minute chart.");
       int BuyOrderTicket = OrderSend(Symbol(), OP_BUY, Lots, Ask, slip, 
                                      Ask - (InitialStop*Point), Ask + (TakeProfit*Point), 
                                      "Buy Order placed at " + CurTime(), 0, 0, Green);
     }
   if(Trend == 1 && OrderForThisSymbol == 0)
     {
       //Alert("Sell order triggered for "+Symbol()+" on the "+Period()+" minute chart.");
       int SellOrderTicket = OrderSend(Symbol(), OP_SELL, Lots, Bid, slip,
                                       Bid + (InitialStop*Point), Bid - (TakeProfit*Point),
                                       "Sell Order placed at " + CurTime(), 0, 0, Red);
     }
// ---------------- TRAILING STOP
   if(TrailingStop > 0)
     { 
       OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
       if((OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) && (OrderSymbol() == Symbol()))
         {
           if(TrailingStop > 0) 
             {                
               if(Bid - OrderOpenPrice() > Point*TrailingStop)
                 {
                   if(OrderStopLoss() < Bid - Point*TrailingStop)
                     {
                       OrderModify(OrderTicket(), OrderOpenPrice(), Bid - Point*TrailingStop, 
                                   OrderTakeProfit(), 0, Aqua);
                       return(0);
                     }
                 }
             }
         }
       if((OrderType() == OP_SELL || OrderType() == OP_SELLSTOP) && (OrderSymbol()==Symbol()))
         {
           if(TrailingStop > 0)  
             {                
               if((OrderOpenPrice() - Ask) > (Point*TrailingStop))
                 {
                   if(OrderStopLoss() == 0.0 || OrderStopLoss()>(Ask+Point*TrailingStop))
                     {
                       OrderModify(OrderTicket(), OrderOpenPrice(), Ask + Point*TrailingStop, 
                                   OrderTakeProfit(), 0, Aqua);
                       return(0);
                     }
                 }
             }
         }
     }   
   return(0);
  } 
//+------------------------------------------------------------------+