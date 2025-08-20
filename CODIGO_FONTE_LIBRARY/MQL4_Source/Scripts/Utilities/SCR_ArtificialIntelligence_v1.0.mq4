//+------------------------------------------------------------------+
//|                                       ArtificialIntelligence.mq4 |
//|                               Copyright © 2006, Yury V. Reshetov |
//|                                         http://reshetov.xnet.uz/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Yury V. Reshetov ICQ:282715499  http://reshetov.xnet.uz/"
#property link      "http://reshetov.xnet.uz/"
//---- input parameters
extern int    x1 = 135;
extern int    x2 = 127;
extern int    x3 = 16;
extern int    x4 = 93;
// StopLoss level
extern double sl = 85;
extern double lots = 1;
extern int MagicNumber = 888;
static int prevtime = 0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   if(Time[0] == prevtime) 
       return(0);
   prevtime = Time[0];
   int spread = 3;
//----
   if(IsTradeAllowed()) 
     {
       RefreshRates();
       spread = MarketInfo(Symbol(), MODE_SPREAD);
     } 
   else 
     {
       prevtime = Time[1];
       return(0);
     }
   int ticket = -1;
// check for opened position
   int total = OrdersTotal();   
//----
   for(int i = 0; i < total; i++) 
     {
       OrderSelect(i, SELECT_BY_POS, MODE_TRADES); 
       // check for symbol & magic number
       if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
         {
           int prevticket = OrderTicket();
           // long position is opened
           if(OrderType() == OP_BUY) 
             {
               // check profit 
               if(Bid > (OrderStopLoss() + (sl * 2  + spread) * Point)) 
                 {               
                   if(perceptron() < 0) 
                     { // reverse
                       ticket = OrderSend(Symbol(), OP_SELL, lots * 2, Bid, 3, 
                                          Ask + sl * Point, 0, "AI", MagicNumber, 0, Red); 
                       Sleep(30000);
                       //----
                       if(ticket < 0) 
                           prevtime = Time[1];
                       else 
                           OrderCloseBy(ticket, prevticket, Blue);   
                     } 
                   else 
                     { // trailing stop
                       if(!OrderModify(OrderTicket(), OrderOpenPrice(), Bid - sl * Point, 
                          0, 0, Blue)) 
                         {
                           Sleep(30000);
                           prevtime = Time[1];
                         }
                     }
                 }  
               // short position is opened
             } 
           else 
             {
               // check profit 
               if(Ask < (OrderStopLoss() - (sl * 2 + spread) * Point)) 
                 {
                   if(perceptron() > 0) 
                     { // reverse
                       ticket = OrderSend(Symbol(), OP_BUY, lots * 2, Ask, 3, 
                                          Bid - sl * Point, 0, "AI", MagicNumber, 0, Blue); 
                       Sleep(30000);
                       //----
                       if(ticket < 0) 
                           prevtime = Time[1];
                       else 
                           OrderCloseBy(ticket, prevticket, Blue);   
                     } 
                   else 
                     { // trailing stop
                       if(!OrderModify(OrderTicket(), OrderOpenPrice(), Ask + sl * Point, 
                          0, 0, Blue)) 
                         {
                           Sleep(30000);
                           prevtime = Time[1];
                         }
                     }
                 }  
             }
           // exit
           return(0);
         }
     }
// check for long or short position possibility
   if(perceptron() > 0) 
     { //long
       ticket = OrderSend(Symbol(), OP_BUY, lots, Ask, 3, Bid - sl * Point, 0, "AI", 
                          MagicNumber, 0, Blue); 
       //----
       if(ticket < 0) 
         {
           Sleep(30000);
           prevtime = Time[1];
         }
     } 
   else 
     { // short
       ticket = OrderSend(Symbol(), OP_SELL, lots, Bid, 3, Ask + sl * Point, 0, "AI", 
                          MagicNumber, 0, Red); 
       if(ticket < 0) 
         {
           Sleep(30000);
           prevtime = Time[1];
         }
     }
//--- exit
   return(0);
  }
//+------------------------------------------------------------------+
//| The PERCEPTRON - a perceiving and recognizing function           |
//+------------------------------------------------------------------+
double perceptron() 
  {
   double w1 = x1 - 100;
   double w2 = x2 - 100;
   double w3 = x3 - 100;
   double w4 = x4 - 100;
   double a1 = iAC(Symbol(), 0, 0);
   double a2 = iAC(Symbol(), 0, 7);
   double a3 = iAC(Symbol(), 0, 14);
   double a4 = iAC(Symbol(), 0, 21);
   return(w1 * a1 + w2 * a2 + w3 * a3 + w4 * a4);
  }
//+------------------------------------------------------------------+


