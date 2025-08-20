//+------------------------------------------------------------------+
//|                   Firebird v0.51 - MA envelope exhaustion system |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"
//----------------------- USER INPUT
extern double MA_length = 10;	 
extern double slip = 0;
extern double Lots = 1;
extern double TakeProfit = 30;
extern double Stoploss = 2000;
//extern double TrailingStop = 5;
extern double PipStep = 30;
//----------------------- MAIN PROGRAM LOOP
double PriceTargetOld=9999999;
int start()
{
double PriceTarget;
double AveragePrice;
int OpeningDay;
double Tester;
double Stopper=0;
 

   int cnt=0, total;
   total=OrdersTotal();
   if(total==0) OpeningDay=DayOfYear();
   OrderSelect(total-1, SELECT_BY_POS);
   double LastPrice=OrderOpenPrice();
      
   OrderSelect(total, SELECT_BY_POS, MODE_TRADES); 
   //if(OrderSymbol()==Symbol())
   //{
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_HIGH,1)*1.02)<Bid && (Bid>=(LastPrice+(PipStep*Point))||total==0)) // Go SHORT -> Only sell if >= 30 pips above previous position entry	
 	     {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),0,0,Red);
     }   
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*0.98)>Ask && (Ask<=(LastPrice-(PipStep*Point))||total==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 
        {
      OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),0,0,Blue);
     }     
//----------------------- CALCULATE AVERAGE OPENING PRICE
   total=OrdersTotal();
   AveragePrice=0;  

 if(total>0)
   {
   for(cnt=0;cnt<total;cnt++)
      {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      AveragePrice=AveragePrice+OrderOpenPrice();
      }
   AveragePrice=AveragePrice/total;
   Tester=TakeProfit;
   }
//----------------------- RECALCULATE STOPLOSS & PROFIT TARGET BASED ON AVERAGE OPENING PRICE
  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
  //if(OrderType()<=OP_SELL && OrderSymbol()==Symbol())  
  //  {
    if(OrderType()==OP_BUY)// && OrderSymbol()==Symbol()) // Calculate profit/stop target for long 
      {
      PriceTarget=AveragePrice-(TakeProfit*Point);
      Stopper=AveragePrice+(Stoploss*Point); 
      }
    if(OrderType()==OP_SELL)// && OrderSymbol()==Symbol()) // Calculate profit/stop target for short
      {
      PriceTarget=AveragePrice+(TakeProfit*Point);
      Stopper=AveragePrice-(Stoploss*Point); 
      }
  //  }
//----------------------- IF NEEDED CHANGE ALL OPEN ORDERS TO THE NEWLY CALCULATED PROFIT TARGET    
if(PriceTargetOld!=PriceTarget)// check if average has really changed
  { 
    total=OrdersTotal();  
    for(cnt=0;cnt<total;cnt++)
       {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);            
       OrderModify(OrderTicket(),0,Stopper,PriceTarget,0,Yellow);// set all positions to averaged levels
       } 
  }
      PriceTargetOld=PriceTarget; 
int ctm;
OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
double price0=OrderOpenPrice();
OrderSelect(1, SELECT_BY_POS, MODE_TRADES);
double price1=OrderOpenPrice(); 
      OrderSelect(0, SELECT_BY_POS, MODE_TRADES);

Comment("Debugging use only. Target0: ", price0,"   Target1: ",price1,"   TotalPos:  ",total," Average: ",AveragePrice," PipStep: ",PipStep*Point," PriceTarget: ",PriceTarget);



}
//----------------------- TO DO LIST
// 1st days profit target is the 30 pip line *not* 30 pips below average as usually. -----> Day()
// Trailing stop -> trailing or S/R or pivot target
// Realistic stop loss
// Avoid overly big positions
// EUR/USD  30 pips / use same value as pipstep
// GBP/CHF  50 pips / use same value as pipstep 
// USD/CAD  35 pips / use same value as pipstep 

//----------------------- OBSERVATIONS
// GBPUSD not suited for this system due to not reversing exhaustions. Maybe use other types of MA
// EURGBP often sharp reversals-> good for trailing stops?
// EURJPY deep pockets needed.