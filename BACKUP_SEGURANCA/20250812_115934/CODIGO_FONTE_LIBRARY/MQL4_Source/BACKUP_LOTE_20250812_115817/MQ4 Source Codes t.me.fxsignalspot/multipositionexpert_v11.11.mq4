//+------------------------------------------------------------------+
//|                                     MultiPositionExpert_v1.1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"


#include <stdlib.mqh>

//---- input parameters
extern string     ExpertName = "MultiPositionExpert_v1";

extern string     Data = " Input Data ";
extern bool       StopManageAcc    =   false; // Stop of Manage Account switch(Close All Trades)
extern int        Magic            =       0; // Magic Number ( 0 - for All positions)
extern bool       UsePips          =    true;    
extern double     ProfitTarget     =     100; // Profit target in pips or USD       	
extern double     MaxLoss          =     100; // Maximum total loss in pips or USD     

int totalPips=0;
double  totalProfits=0;
bool CloseSignal=false;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   //CloseSignal=false;
//----
   return(0);
  }

// ---- Scan Open Trades
int ScanOpenTrades()
{   
   int total = OrdersTotal();
   int numords = 0;
    
   for(int cnt=0; cnt<=total-1; cnt++) 
   {        
   OrderSelect(cnt, SELECT_BY_POS);            
      if(OrderType()<=OP_SELL)
      {
      if(Magic > 0) if(OrderMagicNumber() == Magic) numords++;
      if(Magic == 0) numords++;
      }
   }   
   return(numords);
}

// Closing of Open Orders      
void OpenOrdClose()
{
    int total=OrdersTotal();
    for (int cnt=0;cnt<total;cnt++)
    { 
    OrderSelect(cnt, SELECT_BY_POS);   
    int mode=OrderType();
    bool res = false; 
    bool condition = false;
    if ( Magic>0 && OrderMagicNumber()==Magic ) condition = true;
    else if ( Magic==0 ) condition = true;
      if (condition && ( mode==OP_BUY || mode==OP_SELL ))
      { 
// - BUY Orders         
         if(mode==OP_BUY)
         {  
         res = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,Yellow);
               
            if( !res )
            {
            Print(" BUY: OrderClose failed with error #",GetLastError());
            Print(" Ticket=",OrderTicket());
            Sleep(3000);
            }
         break;
         }
         else     
// - SELL Orders          
         if( mode == OP_SELL)
         {
         res = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,White);
                 
            if( !res )
            {
            Print(" SELL: OrderClose failed with error #",GetLastError());
            Print(" Ticket=",OrderTicket());
            Sleep(3000);
            }
         break;    
         }  
      }                  
   }
}

void TotalProfit()
{
   int total=OrdersTotal();
   totalPips = 0;
   totalProfits = 0;
   for (int cnt=0;cnt<total;cnt++)
   { 
   OrderSelect(cnt, SELECT_BY_POS);   
   int mode=OrderType();
   bool condition = false;
   if ( Magic>0 && OrderMagicNumber()==Magic ) condition = true;
   else if ( Magic==0 ) condition = true;   
      if (condition)
      {      
         switch (mode)
         {
         case OP_BUY:
            totalPips += MathRound((MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT));
            //totalPips += MathRound((Bid-OrderOpenPrice())/Point);
            totalProfits += OrderProfit();
            break;
            
         case OP_SELL:
            totalPips += MathRound((OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK))/MarketInfo(OrderSymbol(),MODE_POINT));
            //totalPips += MathRound((OrderOpenPrice()-Ask)/Point);
            totalProfits += OrderProfit();
            break;
         }
      }            
	}
}

void ChartComment()
{
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";

   sComment = sp;
   sComment = sComment + "Open Positions=" + ScanOpenTrades() + NL;
   sComment = sComment + "Current Profit(pips)= " + totalPips + NL;
   sComment = sComment + "Current Profit(USD) = " + DoubleToStr(totalProfits,2) + NL; 
   sComment = sComment + sp;
  
   Comment(sComment);
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
   if(ScanOpenTrades()==0) CloseSignal=false;
   
   TotalProfit();
   ChartComment();
    
   if (!StopManageAcc)
   {
      if(ScanOpenTrades() > 0 && !CloseSignal && (ProfitTarget>0 || MaxLoss>0))
      {
         if(UsePips)
         {
         if(totalPips>=ProfitTarget || totalPips <= -MaxLoss) CloseSignal=true;    
         //Print("pips: totalPips =",totalPips," signal=",CloseSignal); 
         }
         else
         {
         if(totalProfits>=ProfitTarget || totalProfits <= -MaxLoss) CloseSignal=true;
         //Print("usd: tatalprofit=",totalProfits," signal=",CloseSignal);
         }        
      }   
   }
   else 
   { if (ScanOpenTrades() > 0) CloseSignal=true;}    
   
   //Print("Signal=",CloseSignal);
   if( CloseSignal ) OpenOrdClose();
          
 return(0);
}//int start
//+------------------------------------------------------------------+





