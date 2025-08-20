//+------------------------------------------------------------------+
//|                         Close Orders by Symbol and Set Price.mq4 |
//|                                Copyright © 2009, Dennis Hamilton |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Dennis Hamilton"
#property link      "ramble_32@yahoo.com"

extern double AUDUSD,EURJPY,EURUSD,GBPJPY,GBPUSD,USDJPY,USDCHF,USDCAD;

double Price[8],Order_Profit[50];
string Symbols[8];

//+------------------------------------------------------------------+
int start()
  {
//---- Set Up Symbol Array
   Price[0]=AUDUSD; Symbols[0]="AUDUSD"; Price[1]=EURJPY; Symbols[1]="EURJPY";
   Price[2]=EURUSD; Symbols[2]="EURUSD"; Price[3]=GBPJPY; Symbols[3]="GBPJPY";
   Price[4]=GBPUSD; Symbols[4]="GBPUSD"; Price[5]=USDJPY; Symbols[5]="USDJPY";
   Price[6]=USDCHF; Symbols[6]="USDCHF"; Price[7]=USDCAD; Symbols[7]="USDCAD";
//---- Close Selected Symbols / Pairs
   for(int i=0; i<=7; i++)
     {
      if(Price[i]>0)
        {
         int total=OrdersTotal(); Order_Profit[i]=0;
         for(int ii=total-1; ii>=0; ii--)
           {
            if(OrderSelect(ii,SELECT_BY_POS,MODE_TRADES)==true)
              {
               if(OrderSymbol()==Symbols[i]&&Price[i]>0)
                 {
                  if(OrderType()==OP_BUY||OrderType()==OP_SELL)
                    {
                     Order_Profit[i]+=OrderProfit();
                    }
                 }
              }
           }
         int total2=OrdersTotal();
         for(int iii=total2-1; iii>=0; iii--)
           {
            if(OrderSelect(iii,SELECT_BY_POS,MODE_TRADES)==true)
              {
               if(OrderSymbol()==Symbols[i]&&Order_Profit[i]>=Price[i])
                 {
                  if(OrderType()==OP_BUY||OrderType()==OP_SELL)
                    {
                     OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,Red);
                    }
                  if(OrderType()==OP_BUYSTOP) OrderDelete(OrderTicket());
                    {
                   if(OrderType()==OP_SELLSTOP) OrderDelete(OrderTicket());                
                     {  
                    if(OrderType()==OP_BUYLIMIT) OrderDelete(OrderTicket());
                      {
                     if(OrderType()==OP_SELLLIMIT) OrderDelete(OrderTicket());
                    }
                  }   
                }
              }
            }     
          }
        }
      }
              
                   
//----
   return(0);
  }
//+------------------------------------------------------------------+