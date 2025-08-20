/*
Newz Traderz Mt4 vo1
Conversion only Dr. Gaines

Use on M1
Testing and demo only DO NOT USE WITH REAL MONEY.
USE AT YOUR OWN RISK !!!!!
*/
#property copyright " Jesse Breaker"
#property link      ""
#include <stdlib.mqh>

//-------------------------------------------------
//   Common External variables                                        
//-------------------------------------------------
extern double Lots = 0.01;
extern double StopLoss = 100.00;
extern double TakeProfit = 50.00;
extern double TrailingStop = 13.00;

//+------------------------------------------------------------------+
//| External variables                                               |
//+------------------------------------------------------------------+
extern double StartHour = 15;
extern double StartMinute = 27;
extern double vSL = 10;
extern double vTP = 20;
extern double EntryAmount = 10;
extern double OrderKillInSeconds = 300;

//+------------------------------------------------------------------+
//| Special Convertion Functions                                     |
//+------------------------------------------------------------------+

int LastTradeTime;

bool MOrderDelete( int ticket )
{
  LastTradeTime = CurTime();
  return ( OrderDelete( ticket ) );
}

int MOrderSend( string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment="", int magic=0, datetime expiration=0, color arrow_color=CLR_NONE)
{
  LastTradeTime = CurTime();
  price = MathRound(price*10000)/10000;
  stoploss = MathRound(stoploss*10000)/10000;
  takeprofit = MathRound(takeprofit*10000)/10000;
  return ( OrderSend( symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color ) );
}

int OrderValueTicket(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderTicket());
}

int OrderValueType(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderType());
}

string OrderValueSymbol(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderSymbol());
}

datetime OrderValueOpenTime(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderOpenTime());
}

//+------------------------------------------------------------------+
//| End                                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+

int init()
{
   return(0);
}
int start()
{
//+------------------------------------------------------------------+
//| Local variables                                                  |
//+------------------------------------------------------------------+
double vEntry = 0;
double SL = 0;
double TP = 0;
double x = 600;
double OrderedEntered = 0;
int cnt = 0;
double counter = 0;
double vLots = 0;
double risk = 0;
int cnt2 = 0;



//-------------------------------------------------------
//        Defines
//-------------------------------------------------------

//-------------------------------------------------------
//       Check time
//-------------------------------------------------------
if( Period() != 1 ) 
{  Comment("MUST BE RUN ON Minute CHART!");
   return(0);
}   


//Wait 11 seconds before runnning script again.
if( CurTime() - LastTradeTime < 14 ) return(0);


//-------------------------------------------------------
//       Calculate Open Orders
//-------------------------------------------------------
Comment("Day Of Week : ",DayOfWeek()," Hour : ",Hour()," Minute : ",Minute(), " Seconds : ",Seconds(),
		"'#10'","Waiting for ",StartHour," Start Hour ",StartMinute, " Start Minute");

      

//  order has turned into a valid buy or sell, so we delete the other stop order that was not triggered

    if( OrderedEntered == 2 && OrdersTotal() == 2 ) 
     {

        if( OrderValueType(1) == OP_BUY || OrderValueType(1) == OP_SELL ) 
            {
              MOrderDelete(OrderValueTicket(2));
              return(0);
            } 
        
        if( OrderValueType(2) == OP_BUY || OrderValueType(2) == OP_SELL ) 
            {
              MOrderDelete(OrderValueTicket(1));
              return(0);
            }    
      } 
      
//---------------------------------------------------------------
//        Lot Calculation
//---------------------------------------------------------------
vLots = Lots;

//---------------------------------------------------------------
//        Entry
//---------------------------------------------------------------
	
if( OrdersTotal() == 0 ) // we do the buys first
{ 

	if( (Hour() == StartHour && (Minute() == StartMinute || Minute() == StartMinute+1 || Minute() == StartMinute+2) && OrderedEntered == 0) )  
	{
		//vSL=0;vTP=0;//X=300;
		OrderedEntered=1;	
      	vEntry=High[1]+(EntryAmount*Point);
      	SL=vEntry-(vSL*Point);
      	if( vTP != 0 ) TP=vEntry+(vTP*Point);
      	MOrderSend(Symbol(),OP_BUYSTOP,vLots,vEntry,5,SL,TP,"",16384,0,Blue);

		return(0);
    }
}

// Now onto the Sells

if( OrdersTotal() == 1 ) // 
{ 
	if( (Hour() == StartHour && (Minute() == StartMinute || Minute() == StartMinute+1 || Minute() == StartMinute+2) && OrderedEntered == 1) ) 
	{
		OrderedEntered=2;
		//vSL=0;vTP=0;

      	vEntry=Low[1]-(EntryAmount*Point);
      	SL=vEntry+(vSL*Point);
      	if( vTP != 0 ) TP=vEntry-(vTP*Point);
    	MOrderSend(Symbol(),OP_SELLSTOP,vLots,vEntry,5,SL,TP,"",16384,0,Red);
		return(0);
    }
 



}


//If CurTime - LastTradeTime < X Then Exit;


// ====================================================================================================
//        EOD Close
//=====================================================================================================

for(cnt=1;cnt<=OrdersTotal();cnt++)
{
 if( OrderValueType(cnt) != OP_SELL && OrderValueType(cnt) != OP_BUY ) 
    {
      // check how long it exists in the trading terminal.  Time is counted in seconds.
        // 10 minutes = 600 seconds, 30 minutes = 1800, 1 hour = 3600, 1 day = 86400
        if( (CurTime() - OrderValueOpenTime(cnt)) > OrderKillInSeconds ) 
       {
          MOrderDelete(OrderValueTicket(cnt));
          return(0);
       }
    }
}



for(cnt=1;cnt<=OrdersTotal();cnt++) {
  if( OrderValueSymbol(cnt) == Symbol() ) 
   { 

// remove 'dud' orders

	//If OrderedEntered=2 then //AND (Hour = EndHour And Minute >= EndMinute) then
//     {
		//X=15;
    	OrderedEntered=-1;
        if( OrderValueType(cnt) == OP_BUY ) 
            {
              cnt2=0;
              for(cnt2=1;cnt2<=OrdersTotal();cnt2++) {
                if( OrderValueType(cnt2) == OP_SELLSTOP) 
 				   {	               
                	 MOrderDelete(OrderValueTicket(cnt2));
                     return(0);
                   }
              }
              
            } 
        
        if( OrderValueType(cnt) == OP_SELL ) 
            {
              cnt2=0;
              for(cnt2=1;cnt2<=OrdersTotal();cnt2++) {
                if( OrderValueType(cnt2) == OP_BUYSTOP) 
 				   {	               
                	 MOrderDelete(OrderValueTicket(cnt2));
                     return(0);
                   }
              }
              
            } 
        
            
 //     };    
      
  }
}  return(0);
}