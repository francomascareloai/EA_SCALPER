
//+------------------------------------------------------------------+
//|                                 Copyright 2006, Taylor Stockwell |
//|                                               stockwet@yahoo.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2006, Taylor Stockwell"
#property link      "mailto:stockwet@yahoo.com"



extern int First_Target = 10;
extern int Target_Increment = 6;
extern double Close_Lots = 0.1;
extern int First_Stop = 10;
extern int Stop_Differential = 0;
extern bool Move_Stops = true;

// Global Variables
int ft;  //This variable will be incremented by the target increment after every successful take profit.
int fs; // This variable will change as the trade progresses if Move_Stops is true.
int curPipValue;  // Checks to see the difference between the open price and current price in pips.


void ManageTrade()
{

// Create another set of variables used in the code. 
// These variables provide an abbreviated way of calling variables.
// Mostly, they are more easily written in the code than using the user
// friendly external variables.

   int ti=Target_Increment; //This variable will not change.
   double cl=Close_Lots; // This variable will not change.
// Additional variables used in the code.
   int trange = 0; // Use a range versus a specific pip amount as prices may get jumped.
   int totalorders = OrdersTotal(); // Calls a function to get all the open orders.

// Starts initial "for" loop. This loop will go through all the open orders.
// If a target is reached, the script will close a portion of the trade and, possibly, move the stop loss.

  for(int j=0; j<totalorders;j++)
  {  
   
   OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
   if(ft == 0) ft = First_Target;
//  if(OrderType() == OP_SELL && OrderSymbol()==Symbol())
//         {             
   if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
      {
      // Get the current pip amount on a buy order.
      curPipValue = (Bid - OrderOpenPrice())/Point;     
      if(ft == 0) ft = First_Target;
      trange=ft+5;
      // Check if the current pip amount is within the appropriate range  
      if(curPipValue >= ft-1 && curPipValue <= trange)         
         {               
            // First, if target is reached, then take profit.  
            if(OrderClose(OrderTicket(), cl, Bid, 3, YellowGreen))
               {
                  // Increment First_Target
                  ft += ti;             
                  Comment(ft);
                  return(0);
               }
          }
      }
   else if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
      {
      // Get the current pip amount on a sell order.
      curPipValue = (OrderOpenPrice()-Ask)/Point;  
      if(ft == 0) ft = First_Target;
      trange=ft+5;
      // Check if the current pip amount is within the appropriate range  
      if(curPipValue >= ft-1 && curPipValue <= trange)
         {                     
            if(OrderClose(OrderTicket(), cl, Ask, 3, YellowGreen))
               {
                  // Increment First_Target
                  ft +=ti;                  
                  Comment(ft);
                  return(0);                  
               }
          }
      }
   }
}
         
   
void MoveStops()
{
// Starts initial "for" loop. This loop will go through all the open orders.
// If a target is reached, the script will move the stop loss.

  int sd=Stop_Differential; // This variable will not change.
// Additional variables used in the code.
   int trange = 0; // Use a range versus a specific pip amount as prices may get jumped.
   int totalorders2 = OrdersTotal(); // Calls a function to get all the open orders.
   

  for(int j=0; j<totalorders2;j++)
  {  
  
   OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
   if(fs == 0) fs = First_Stop;
   trange=First_Stop+5;
//  if(OrderType() == OP_SELL && OrderSymbol()==Symbol())
//         {             
   if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
      {
         // Get the current pip amount on a buy order.
         curPipValue = (Bid - OrderOpenPrice())/Point;     
         // Check if the current pip amount is within the appropriate range  
       if(Move_Stops)
         {
            if(curPipValue >= First_Stop && curPipValue <= trange)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+Stop_Differential*Point, OrderTakeProfit(),0,Plum);
            }
            return(0);
         }    
      }
   else if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
      {
         // Get the current pip amount on a buy order.
         curPipValue = (OrderOpenPrice()-Ask)/Point;      
         // Check if the current pip amount is within the appropriate range  
       if(Move_Stops)
         {
            if(curPipValue >= First_Stop && curPipValue <= trange)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-Stop_Differential*Point, OrderTakeProfit(),0,Plum);
            }
            return(0);
         }    
      }

   }
}

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
  MoveStops();
  ManageTrade();

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   ft=0;
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  MoveStops();  
  ManageTrade();

  }