//+------------------------------------------------------------------+
//|                                                 TradeChannel.mq4 |
//|                                  Copyright ฉ 2005, George-on-Don |
//|                                       http://www.forex.aaanet.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright ฉ 2005, George-on-Don"
#property link      "http://www.forex.aaanet.ru"

#include <stdlib.mqh>
#include <stderror.mqh>

#define MAGICMA  20050610

extern double    Lots=0.1; // Lot size
extern bool      SndMl=true; // Flag to send e-mail message  
extern bool      isFloatLots = true; // flag to calculate size lot
extern double    DcF = 3;// factor to optimisation
extern double    MaxR = 0.02; // max risk
extern int       pATR=4; // periods ภาะ
extern int       rChannel = 20; // periods channel
extern double    Trailing = 30; // value tralings

//--------- global variables
   double Atr;
   double Resist;
   double ResistPrev;
   double Support;
   double SupportPrev;
   double Pivot;
//------------------   

int CalculateCurrentOrders(string symbol)
  {
   int buys=0;
   int sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) 
         break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  
            buys++;
         if(OrderType()==OP_SELL) 
           sells++;
        }
     }
//---- return orders volume
      if(buys>0) 
         return(buys);
      else
        return(-sells);
  }

//+------------------------------------------------------------------+
//| calculate value trade lots                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   if (isFloatLots == true) // if isFloatLots true then optimise value lots else value lots = const
    {  
 	int    orders=HistoryTotal();     // history orders total
	int    losses=0;                  // number of losses orders without a break
	//---- select lot size
	   lot=NormalizeDouble(AccountFreeMargin()*MaxR/1000.0,1);
	//---- calcuulate number of losses orders without a break
	   if(DcF>0)
     	{
      	for(int i=orders-1;i>=0;i--)
        		{
	         	if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
	         	{ 
	         	Print("Error on History!"); 
	         	break;
	         	 }
         		if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) 
         		continue;
         	//----
	         	if(OrderProfit()>0) break;
         		if(OrderProfit()<0) losses++;
        		}
      	if(losses>1) lot=NormalizeDouble(lot-lot*losses/DcF,1);
     	}
   }
//---- return lot size
   if(lot<0.1) lot=0.1;
   return(lot);
}
// calculate channel periods 
void defPcChannel() 
{
     Resist=High[Highest(NULL,0,MODE_HIGH,rChannel,1)]; // up channel   
     ResistPrev=High[Highest(NULL,0,MODE_HIGH,rChannel,2)];   
     Support=Low[Lowest(NULL,0,MODE_LOW,rChannel,1)];
     SupportPrev=Low[Lowest(NULL,0,MODE_LOW,rChannel,2)];
     Pivot = (Resist+Support+Close[1])/3;
}
// is open trade BUY?
bool isOpenBuy()
{
       
     defPcChannel() ;     
   
     if ( High[1] >= Resist && Resist == ResistPrev) 
        return (true); 
      
     if ( Close [1] < Resist && Resist == ResistPrev && Close [1] > Pivot) 
       return(true); 

      return(false);

}
// is open trade SELL?
bool isOpenSell()
{
      defPcChannel();
 
      if (Low[1] <= Support && Support==SupportPrev ) 
         return (true);

      if (Close [1] > Support && Support==SupportPrev && Close [1] < Pivot ) 
         return (true);

      return (false);
}
// is open trade on?
void CheckForOpen()
{
  
   int    res;
   string sHeaderLetter;
   string sBodyLetter;
//---- is First value bar?
   if(Volume[0]>1) 
   return;
//---- 
   Atr = iATR(NULL,0,pATR,1);
 //---- is Sell?
    
     if (isOpenBuy() == True)
      {    
      res=OrderSend(Symbol(),OP_SELL, LotsOptimized(),Bid,3, Resist+Atr,0,"",MAGICMA,0,Red);
       if (SndMl == True && res != -1) 
         {
         sHeaderLetter = "Operation SELL by " + Symbol()+"";
         sBodyLetter = "Order Sell by "+ Symbol() + " at " + DoubleToStr(Bid,4)+ ", and set stop/loss at " + DoubleToStr(Resist+Atr,4)+"";
         sndMessage(sHeaderLetter, sBodyLetter);
         }
       
      return;
     }
//---- is Buy?
       
           
      if (isOpenSell() == true)
      {
         res=OrderSend(Symbol(),OP_BUY, LotsOptimized() ,Ask,3,Support-Atr,0,"order",MAGICMA,0,Blue);
         if ( SndMl == True && res != -1)
            { 
            sHeaderLetter = "Operation BUY at " + Symbol()+"";
            sBodyLetter = "Order Buy at "+ Symbol() + " for " + DoubleToStr(Ask,4)+ ", and set stop/loss at " + DoubleToStr(Support-Atr,4)+"";
            sndMessage(sHeaderLetter, sBodyLetter);
            }
      return;
      }
    return;    
}  

// is close trade?
bool isCloseSell()
{
   defPcChannel();
   if (Low[1] <= Support && Support==SupportPrev ) 
        return (true);
   return (false);
}

bool isCloseBuy()
{
   defPcChannel();
   
     if ( High[1] >= Resist && Resist == ResistPrev) 
        return (true); 
      
     
   
   return (false);
}

void CheckForClose()
{
   string sHeaderLetter;
   string sBodyLetter;
   bool CloseOrd;
   //---- 
   if(Volume[0]>1) return;
//----  
   
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol())
        continue;
      
      //----  
      if(OrderType()==OP_BUY)
        {
         if (isCloseBuy() == true )        
         {
          CloseOrd=OrderClose(OrderTicket(),OrderLots(),Bid,3,Lime);
            if ( SndMl == True && CloseOrd == True)
            {
            sHeaderLetter = "Operation CLOSE BUY at" + Symbol()+"";
            sBodyLetter = "Close order Buy at "+ Symbol() + " for " + DoubleToStr(Bid,4)+ ", and finish this Trade";
            sndMessage(sHeaderLetter, sBodyLetter);
            }
         break;
         }                                            
         else 
         {
         // is traling stop? 
         if(Trailing>0)  
            {                 
            if(Bid-OrderOpenPrice()>Point*Trailing)
               {
               if(OrderStopLoss()<Bid-Point*Trailing)
                  {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*Trailing,OrderTakeProfit(),0,Green);
                  return ;
                  }
                }
            }
         
         }
        
        }
        
      if(OrderType()==OP_SELL)
        {
           
         if (isCloseSell() == true)       
         {
           CloseOrd=OrderClose(OrderTicket(),OrderLots(),Ask,3,Lime);
            if ( SndMl == True && CloseOrd == True) 
            {
            sHeaderLetter = "Operation CLOSE SELL at" + Symbol()+"";
            sBodyLetter = "Close order Sell at "+ Symbol() + " for " + DoubleToStr(Ask,4)+ ", and finish this Trade";
            sndMessage(sHeaderLetter, sBodyLetter);
            }
         break;
         }
         else 
         {
         // is trailing stop,?
         if(Trailing>0)  
            {                 
            if((OrderOpenPrice()-Ask)>(Point*Trailing))
               {
               if((OrderStopLoss()>(Ask+Point*Trailing)) || (OrderStopLoss()==0))
                  {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*Trailing,OrderTakeProfit(),0,Red);
                  return;
                  }
               }
             }


         }
        }
     }
//----
}  
//--------------------------------------------------------------------
// fumction send e-mail message then open trade 
//--------------------------------------------------------------------
void sndMessage(string HeaderLetter, string BodyLetter)
{
   int RetVal;
      SendMail( HeaderLetter, BodyLetter );
      RetVal = GetLastError();
      if (RetVal!= ERR_NO_MQLERROR) 
      Print ("Error, message not send: ", ErrorDescription(RetVal));
      return;      
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  
//---- 
   if(Bars<25 || IsTradeAllowed()==false) 
   return (0);
   if (AccountFreeMargin()<(100*Point*Lots))
     {
     Print("Stop!Our account not enable for trade.Free margin is  = ", AccountFreeMargin());
     return(0);  
     }

//---- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
//-
//----
   return(0);
  }
//+------------------------------------------------------------------+