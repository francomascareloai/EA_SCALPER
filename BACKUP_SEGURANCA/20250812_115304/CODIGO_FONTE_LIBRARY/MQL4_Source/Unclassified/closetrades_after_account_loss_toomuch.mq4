//+------------------------------------------------------------------+
//|                      CloseTrades_After_Account_Loss_TooMuch.mq4  |
//|                                     Copyright © 2007, Tradinator |
//|                                          tradinator.fx@gmail.com |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2007, Tradinator"
#property link      "tradinator.fx@gmail.com"
                                           
                                           
                                               //+---------------------------------------------------------------------+
extern double Open_Loss_To_CloseTrades=-1000;  //|The amount of money at which you want to take a loss & close ALL     |
                                               //|open trades. eg if the floating loss in your account reaches or goes |
                                               //|beyond -$1000 then ALL the open positions in your account will be    |
                                               //|closed.                                                              |      
                                               //+---------------------------------------------------------------------+
int Slippage=5;                                 
int i;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   
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
if (AccountProfit()<= Open_Loss_To_CloseTrades)
   {
    for(i=OrdersTotal()-1;i>=0;i--)
       {
       OrderSelect(i, SELECT_BY_POS);
       int type   = OrderType();
               
       bool result = false;
              
       switch(type)
          {
          //Close opened long positions
          case OP_BUY  : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),Slippage,Pink);
                         break;
               
          //Close opened short positions
          case OP_SELL : result = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),Slippage,Pink);
                          
          }
          
       if(result == false)
          {
            Sleep(3000);
          }  
       }
      Print ("Account Cutoff Limit Reached. All Open Trades Have Been Closed");
      return(0);
   }  
   
   Comment("Balance: ",AccountBalance(),", Account Equity: ",AccountEquity(),", Account Profit: ",AccountProfit(),
           "\nMy Account Cutoff Limit: ",Open_Loss_To_CloseTrades);
   
  return(0);
}