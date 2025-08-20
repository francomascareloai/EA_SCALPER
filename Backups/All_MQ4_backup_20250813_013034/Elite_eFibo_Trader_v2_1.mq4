//+------------------------------------------------------------------+
//|                                                eFibo EA v2.1.mq4 |
//|                             Copyright © 2007, Elite E Services   |
//|                                         www.eliteeservices.net   |
//|    Programmed by:  Mikhail Veneracion   mikhail.eforex@yahoo.com |
//| Forum: www.eesfx.com  Google Group: www.forexcoding.com          |
//|For MQL Programming, EA purchase and lease, and managed accounts  |
//|Contact Elite E Services www.startelite.com                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Elite E Services "
#property link      "info@eliteeservices.net"

// 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377
extern int 
         MagicNumber       = 100,
         Slippage          = 4;

extern bool
         Open_Buy          = false,
         Open_Sell         = true,
         TradeAgainAfterProfit = true;
extern int
         LevelDistance     = 20,
         StopLoss          = 10;
extern double
         MoneyTakeProfit   = 2000;
extern double
         Lots_Level_1        = 1,
         Lots_Level_2        = 1,
         Lots_Level_3        = 2,
         Lots_Level_4        = 3,
         Lots_Level_5        = 5,
         Lots_Level_6        = 8,
         Lots_Level_7        = 13,
         Lots_Level_8        = 21,
         Lots_Level_9        = 34,
         Lots_Level_10       = 55,
         Lots_Level_11       = 89,
         Lots_Level_12       = 144,
         Lots_Level_13       = 233,
         Lots_Level_14       = 377;

bool Trade=True;
datetime FirstTime;                            
double BestBuySL, BestSellSL;
int ticket1,ticket2,ticket3,ticket4,ticket5,ticket6,ticket7,ticket8,ticket9,ticket10,ticket11,ticket12,ticket13,ticket14;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   FirstTime = 0;

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
      if(TradeAgainAfterProfit)Trade=true;
         ticket1 = 0;
         ticket2 = 0;
         ticket3 = 0;
         ticket4 = 0;
         ticket5 = 0;
         ticket6 = 0;
         ticket7 = 0;
         ticket8 = 0;
         ticket9 = 0;
         ticket10 = 0;
         ticket11 = 0;
         ticket12 = 0;
         ticket13 = 0;
         ticket14 = 0;
      
      if((subTotalTrade()<1)&&(Trade))
      {
         //OPEN BUY
         if(Open_Buy&&!Open_Sell)
         {
            double OP = Ask;
            if(ticket1==0)ticket1 = subOpenOrder(OP_BUY, Lots_Level_1, StopLoss, 0,MagicNumber);
            if(ticket1>0&&ticket2==0)ticket2 = subOpenPendingOrder(OP_BUYSTOP, OP+(LevelDistance*Point),Lots_Level_2 ,0,StopLoss,MagicNumber);
            if(ticket2>0&&ticket3==0)ticket3 =subOpenPendingOrder(OP_BUYSTOP, OP+(2*LevelDistance*Point),Lots_Level_3 ,0,StopLoss,MagicNumber);
            if(ticket3>0&&ticket4==0)ticket4 =subOpenPendingOrder(OP_BUYSTOP, OP+(3*LevelDistance*Point),Lots_Level_4 ,0,StopLoss,MagicNumber);
            if(ticket4>0&&ticket5==0)ticket5 =subOpenPendingOrder(OP_BUYSTOP, OP+(4*LevelDistance*Point),Lots_Level_5 ,0,StopLoss,MagicNumber);
            if(ticket5>0&&ticket6==0)ticket6 =subOpenPendingOrder(OP_BUYSTOP, OP+(5*LevelDistance*Point),Lots_Level_6 ,0,StopLoss,MagicNumber);
            if(ticket6>0&&ticket7==0)ticket7 =subOpenPendingOrder(OP_BUYSTOP, OP+(6*LevelDistance*Point),Lots_Level_7 ,0,StopLoss,MagicNumber);
            if(ticket7>0&&ticket8==0)ticket8 =subOpenPendingOrder(OP_BUYSTOP, OP+(7*LevelDistance*Point),Lots_Level_8 ,0,StopLoss,MagicNumber);
            if(ticket8>0&&ticket9==0)ticket9 =subOpenPendingOrder(OP_BUYSTOP, OP+(8*LevelDistance*Point),Lots_Level_9 ,0,StopLoss,MagicNumber);
            if(ticket9>0&&ticket10==0)ticket10 =subOpenPendingOrder(OP_BUYSTOP, OP+(9*LevelDistance*Point),Lots_Level_10 ,0,StopLoss,MagicNumber);
            if(ticket10>0&&ticket11==0)ticket11 =subOpenPendingOrder(OP_BUYSTOP, OP+(10*LevelDistance*Point),Lots_Level_11 ,0,StopLoss,MagicNumber);
            if(ticket11>0&&ticket12==0)ticket12 =subOpenPendingOrder(OP_BUYSTOP, OP+(11*LevelDistance*Point),Lots_Level_12 ,0,StopLoss,MagicNumber);
            if(ticket12>0&&ticket13==0)ticket13 =subOpenPendingOrder(OP_BUYSTOP, OP+(12*LevelDistance*Point),Lots_Level_13 ,0,StopLoss,MagicNumber);
            if(ticket13>0&&ticket14==0)ticket14 =subOpenPendingOrder(OP_BUYSTOP, OP+(13*LevelDistance*Point),Lots_Level_14 ,0,StopLoss,MagicNumber);
            
            if(ticket14>0)
            {
               FirstTime = iTime(Symbol(),0,0);
               return(0);
            }   
         }
              
         if(Open_Sell&&!Open_Buy)
         {
            OP = Bid;
            if(ticket1==0)ticket1 = subOpenOrder(OP_SELL, Lots_Level_1, StopLoss, 0,MagicNumber);
            if(ticket1>0&&ticket2==0)ticket2 = subOpenPendingOrder(OP_SELLSTOP, OP-(LevelDistance*Point),Lots_Level_2 ,0,StopLoss,MagicNumber);
            if(ticket2>0&&ticket3==0)ticket3 = subOpenPendingOrder(OP_SELLSTOP, OP-(2*LevelDistance*Point),Lots_Level_3 ,0,StopLoss,MagicNumber);
            if(ticket3>0&&ticket4==0)ticket4 = subOpenPendingOrder(OP_SELLSTOP, OP-(3*LevelDistance*Point),Lots_Level_4 ,0,StopLoss,MagicNumber);
            if(ticket4>0&&ticket5==0)ticket5 = subOpenPendingOrder(OP_SELLSTOP, OP-(4*LevelDistance*Point),Lots_Level_5 ,0,StopLoss,MagicNumber);
            if(ticket5>0&&ticket6==0)ticket6 = subOpenPendingOrder(OP_SELLSTOP, OP-(5*LevelDistance*Point),Lots_Level_6 ,0,StopLoss,MagicNumber);
            if(ticket6>0&&ticket7==0)ticket7 = subOpenPendingOrder(OP_SELLSTOP, OP-(6*LevelDistance*Point),Lots_Level_7 ,0,StopLoss,MagicNumber);
            if(ticket7>0&&ticket8==0)ticket8 = subOpenPendingOrder(OP_SELLSTOP, OP-(7*LevelDistance*Point),Lots_Level_8 ,0,StopLoss,MagicNumber);
            if(ticket8>0&&ticket9==0)ticket9 = subOpenPendingOrder(OP_SELLSTOP, OP-(8*LevelDistance*Point),Lots_Level_9 ,0,StopLoss,MagicNumber);
            if(ticket9>0&&ticket10==0)ticket10 = subOpenPendingOrder(OP_SELLSTOP, OP-(9*LevelDistance*Point),Lots_Level_10 ,0,StopLoss,MagicNumber);
            if(ticket10>0&&ticket11==0)ticket11 = subOpenPendingOrder(OP_SELLSTOP, OP-(10*LevelDistance*Point),Lots_Level_11 ,0,StopLoss,MagicNumber);
            if(ticket11>0&&ticket12==0)ticket12 = subOpenPendingOrder(OP_SELLSTOP, OP-(11*LevelDistance*Point),Lots_Level_12 ,0,StopLoss,MagicNumber);
            if(ticket12>0&&ticket13==0)ticket13 = subOpenPendingOrder(OP_SELLSTOP, OP-(12*LevelDistance*Point),Lots_Level_13 ,0,StopLoss,MagicNumber);
            if(ticket13>0&&ticket14==0)ticket14 = subOpenPendingOrder(OP_SELLSTOP, OP-(13*LevelDistance*Point),Lots_Level_14 ,0,StopLoss,MagicNumber);
            
            if(ticket14>0)
            {
               FirstTime = iTime(Symbol(),0,0);
               return(0);
            }
         }  
         FirstTime = iTime(Symbol(),0,0);
      }   
      FirstTime = iTime(Symbol(),0,0);
      
      //---TAKE PROFIT
      if(subTotalProfit()>=MoneyTakeProfit)
      {
         Print("Money Take Profit Reached");
         if(!TradeAgainAfterProfit)Trade=false;
         subCloseOrder();
         subCloseAllOrder();
         subCloseAllOrder();
         subCloseAllPending();
         subCloseAllPending();
      }
      //---ModifySL
      if(subTotalOpen()>0)
      {
          
          BestSellSL = subBestSellSL();
          BestBuySL = subBestBuySL();
          Print("BestBuySL:"+BestBuySL+"|BestSellSL:"+BestSellSL);
          int total = OrdersTotal();
          for(int cnt=0;cnt<total;cnt++)
          {
             OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

             if(OrderType()<=OP_SELL &&
                OrderSymbol()==Symbol() &&
                OrderMagicNumber()==MagicNumber)
             {
                subTrailingStop(OrderType());
             }
          }
      } 
      //---DELETE ALL PENDING ORDERS   
      if(subTotalOpen()<1)
      {
         subCloseAllPending();
         subCloseAllPending();
         subCloseAllPending();
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+
void subCloseAllPending()
{
   int
         NumberOfTries=10,
         cnt, 
         total       = 0,
         ticket      = 0,
         err         = 0,
         c           = 0;

   total = OrdersTotal();
   for(cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol() == Symbol() &&
         OrderMagicNumber()==MagicNumber)
      {
         switch(OrderType())
         {               
            case OP_BUYLIMIT :
            case OP_BUYSTOP  :
            case OP_SELLLIMIT:
            case OP_SELLSTOP :
               OrderDelete(OrderTicket());
         }
      }
   }      
}
int subTotalTrade()
{
   int
      cnt, 
      total = 0;

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol()&&
        (OrderMagicNumber()==MagicNumber)) total++;
   }
   return(total);
}
int subTotalOpen()
{
   int
      cnt, 
      total = 0;

   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL&&OrderSymbol()==Symbol()&&
        (OrderMagicNumber()==MagicNumber)) total++;
   }
   return(total);
}
double subTotalProfit()
{
   int
      cnt, 
      total = 0;
   double Profit = 0;
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL&&OrderSymbol()==Symbol()&&
        (OrderMagicNumber()==MagicNumber))Profit = Profit +OrderProfit();
   }
   return(Profit);
}

int subOpenPendingOrder(int type, double OpenPrice,double Lots ,double takeprofit,double stoploss,int MagicNumber)
{
   string TicketComment = "Andrew EA";
   int
         ticket      = 0,
         err         = 0,
         c           = 0;
         
    double         
         aStopLoss   = 0,
         aTakeProfit = 0,
         aOpenPrice  = 0,
         bStopLoss   = 0,
        // OpenPrice  = 0,
         bTakeProfit = 0;
         
   if(takeprofit!=0)
   {
      aTakeProfit = NormalizeDouble(OpenPrice+takeprofit*Point,Digits);
      bTakeProfit = NormalizeDouble(OpenPrice-takeprofit*Point,Digits);
   }
   if(stoploss!=0)
   {
      aStopLoss   = NormalizeDouble(OpenPrice-stoploss*Point,Digits);
      bStopLoss   = NormalizeDouble(OpenPrice+stoploss*Point,Digits);
   }

   if(type==OP_BUYSTOP)
   {
      for(c=0;c<10;c++)
      {
         ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,OpenPrice,6,aStopLoss,aTakeProfit,TicketComment,MagicNumber,0,Green);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }
   if(type==OP_SELLSTOP)
   {   
      for(c=0;c<10;c++)
      {
         ticket=OrderSend(Symbol(),OP_SELLSTOP,Lots,OpenPrice,6,bStopLoss,bTakeProfit,TicketComment,MagicNumber,0,Red);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }
   if(type==OP_BUYLIMIT)
   {
      for(c=0;c<10;c++)
      {
         ticket=OrderSend(Symbol(),OP_BUYLIMIT,Lots,OpenPrice,6,aStopLoss,aTakeProfit,TicketComment,MagicNumber,0,Green);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }
   if(type==OP_SELLLIMIT)
   {   
      for(c=0;c<10;c++)
      {
         ticket=OrderSend(Symbol(),OP_SELLLIMIT,Lots,OpenPrice,6,bStopLoss,bTakeProfit,TicketComment,MagicNumber,0,Red);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }  
   return(ticket);  
}
//+------------------------------------------------------------------+
int subOpenOrder(int type, double Lotz, int stoploss, int takeprofit,int MagicNumber)
{
   int NumberOfTries = 10;
   string TicketComment = "Hedge EA";
   int
         ticket      = 0,
         err         = 0,
         c           = 0;
         
   double         
         aStopLoss   = 0,
         aTakeProfit = 0,
         bStopLoss   = 0,
         bTakeProfit = 0;

   if(stoploss!=0)
   {
      aStopLoss   = NormalizeDouble(Ask-stoploss*Point,4);
      bStopLoss   = NormalizeDouble(Bid+stoploss*Point,4);
   }
   
   if(takeprofit!=0)
   {
      aTakeProfit = NormalizeDouble(Ask+takeprofit*Point,4);
      bTakeProfit = NormalizeDouble(Bid-takeprofit*Point,4);
   }
   
   if(type==OP_BUY)
   {
      for(c=0;c<NumberOfTries;c++)
      {
         ticket=OrderSend(Symbol(),OP_BUY,Lotz,Ask,Slippage,aStopLoss,aTakeProfit,TicketComment,MagicNumber,0,Green);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }
   if(type==OP_SELL)
   {   
      for(c=0;c<NumberOfTries;c++)
      {
         ticket=OrderSend(Symbol(),OP_SELL,Lotz,Bid,Slippage,bStopLoss,bTakeProfit,TicketComment,MagicNumber,0,Red);
         err=GetLastError();
         if(err==0)
         { 
            if(ticket>0) break;
         }
         else
         {
            if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
            {
               Sleep(5000);
               continue;
            }
            else //normal error
            {
               if(ticket>0) break;
            }  
         }
      }   
   }  
   return(ticket);
}
double subBestBuySL()
{
   int
      cnt, 
      total = 0;
   double SL = 0;
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_BUY&&OrderSymbol()==Symbol()&&
        (OrderMagicNumber()==MagicNumber))
        {
           if(OrderStopLoss()>SL)
           {
               SL = OrderStopLoss();
           }
        }
   }
   return(SL);
}
double subBestSellSL()
{
   int
      cnt, 
      total = 0;
   double SL = 10000000;
   for(cnt=0;cnt<OrdersTotal();cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL&&OrderSymbol()==Symbol()&&
        (OrderMagicNumber()==MagicNumber))
        {   
           if(OrderStopLoss()<SL)
           {
               SL = OrderStopLoss();
           }
        }   
   }
   return(SL);
}
void subTrailingStop(int Type)
{
   if(Type==OP_BUY)   // buy position is opened   
   {
//----------------------- AFTER PROFIT TRAILING STOP      
        
            if(OrderStopLoss()<BestBuySL)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),subBestBuySL(),OrderTakeProfit(),0,Green);
               return(0);
            }
          
   }         
   if(Type==OP_SELL)   // sell position is opened   
   {
//----------------------- AFTER PROFIT TRAILING STOP      
     
            if(OrderStopLoss()>BestSellSL)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),subBestSellSL(),OrderTakeProfit(),0,Red);
               return(0);
            }
            
           
           
        
   }
}
void subCloseAllOrder()
{
   int
         NumberOfTries=10,
         cnt, 
         total       = 0,
         ticket      = 0,
         err         = 0,
         c           = 0;

   total = OrdersTotal();
   for(cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol() == Symbol() &&
         (OrderMagicNumber()==MagicNumber))
      {
         switch(OrderType())
         {
            case OP_BUY      :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_SELL     :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_BUYLIMIT :
            case OP_BUYSTOP  :
            case OP_SELLLIMIT:
            case OP_SELLSTOP :
               OrderDelete(OrderTicket());
         }
      }
   }      
}
void subCloseOrder()
{
   int
         NumberOfTries=10,
         cnt, 
         total       = 0,
         ticket      = 0,
         err         = 0,
         c           = 0;

   total = OrdersTotal();
   for(cnt=total-1;cnt>=0;cnt--)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

      if(OrderSymbol() == Symbol() &&
         (OrderMagicNumber()==MagicNumber))
      {
         switch(OrderType())
         {
            case OP_BUY      :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
            case OP_SELL     :
               for(c=0;c<NumberOfTries;c++)
               {
                  ticket=OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet);
                  err=GetLastError();
                  if(err==0)
                  { 
                     if(ticket>0) break;
                  }
                  else
                  {
                     if(err==0 || err==4 || err==136 || err==137 || err==138 || err==146) //Busy errors
                     {
                        Sleep(5000);
                        continue;
                     }
                     else //normal error
                     {
                        if(ticket>0) break;
                     }  
                  }
               }   
               break;
               
         }
      }
   }      
}