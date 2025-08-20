//+------------------------------------------------------------------+
//|                   Firebird v0.55 - MA envelope exhaustion system |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"
//----------------------- USER INPUT
extern int MA_length = 10;
extern int TradeOnFriday =1; // >0 trades on friday
extern int MAtype=0;//0=close, 1=HL		 
extern int slip = 100;//exits only
extern int Lots = 1;
extern int TakeProfit = 30;
extern int Stoploss = 200;// total loss on all open positions in pips
//extern double TrailingStop = 5;
extern int PipStep = 30;
double Stopper=0;
double KeepStopLoss=0;
double KeepAverage;
double dummy;
double spread=0;
int OrderWatcher=0;
//----------------------- MAIN PROGRAM LOOP
int start()
{
double PriceTarget;
double AveragePrice;
int OpeningDay;
//double Tester;
 
int Direction=0;//1=long, 11=avoid long, 2=short, 22=avoid short
 
if (Day()!=5 || TradeOnFriday >0)
{
   int cnt=0, total;
   total=OrdersTotal();
   if(total==0) OpeningDay=DayOfYear();
   OrderSelect(total-1, SELECT_BY_POS);
   double LastPrice=OrderOpenPrice();
      
   OrderSelect(total, SELECT_BY_POS, MODE_TRADES); 
   
   
//----------------------- ENTER POSITION BASED ON OPEN
OrderWatcher=0;
if(MAtype==0)
{
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*1.02)<Bid && Direction!=22 && (Bid>=(LastPrice+(PipStep*Point))||total==0)) // Go SHORT -> Only sell if >= 30 pips above previous position entry	
 	  {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),0,0,Red);
      OrderWatcher=1;
      Direction=2;
     }   
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*0.98)>Ask && Direction!=11 && (Ask<=(LastPrice-(PipStep*Point))||total==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 
     {
      OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),0,0,Blue);
      OrderWatcher=1;
      Direction=1;
     } 
}     
  
//----------------------- ENTER POSITION BASED ON HIGH/LOW
if(MAtype==1)
{
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_HIGH,0)*1.02)<Bid && Direction!=22 && (Bid>=(LastPrice+(PipStep*Point))||total==0)) // Go SHORT -> Only sell if >= 30 pips above previous position entry	
 	     {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),0,0,Red);
      OrderWatcher=1;
      Direction=2;
     }   
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_LOW,0)*0.98)>Ask && Direction!=11 && (Ask<=(LastPrice-(PipStep*Point))||total==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 
        {
      OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),0,0,Blue);
      OrderWatcher=1;
      Direction=1;
     } 
}                   
//----------------------- CALCULATE AVERAGE OPENING PRICE
 
   total=OrdersTotal();
   AveragePrice=0;  

 if(total>1 && OrderWatcher==1)
   {
   for(cnt=0;cnt<total;cnt++)
      {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      AveragePrice=AveragePrice+OrderOpenPrice();
      }
   AveragePrice=AveragePrice/total;
   }
//----------------------- RECALCULATE STOPLOSS & PROFIT TARGET BASED ON AVERAGE OPENING PRICE
OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
        
    if(OrderType()==OP_BUY  && OrderWatcher==1 && total>1)// && OrderSymbol()==Symbol()) // Calculate profit/stop target for long 
      {
      PriceTarget=AveragePrice+(TakeProfit*Point);
      Stopper=AveragePrice-(((Stoploss*Point)/OrdersTotal())); 
      }
    if(OrderType()==OP_SELL && OrderWatcher==1 && total>1)// && OrderSymbol()==Symbol()) // Calculate profit/stop target for short
      {
      PriceTarget=AveragePrice-(TakeProfit*Point);
      Stopper=AveragePrice+(((Stoploss*Point)/OrdersTotal())); 
      }
//----------------------- IF NEEDED CHANGE ALL OPEN ORDERS TO THE NEWLY CALCULATED PROFIT TARGET    
if(OrderWatcher==1 && OrdersTotal()>1)// check if average has really changed
  { 
    total=OrdersTotal();  
    for(cnt=0;cnt<total;cnt++)
       {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);            
       OrderModify(OrderTicket(),0,Stopper,PriceTarget,0,Yellow);// set all positions to averaged levels
       } 
  }

//----------------------- KEEP TRACK OF STOPLOSS TO AVOID RUNAWAY MARKETS
// Sometimes the market keeps trending so strongly the system never reaches it's target.
// This means huge drawdown. After stopping out it falls in the same trap over and over.
// The code below avoids this by only accepting a signal in teh opposite direction after a SL was hit.
// After that all signals are taken again. Luckily this seems to happen rarely. 
if (OrdersTotal()>0)
   {
   OrderSelect(0, SELECT_BY_POS, MODE_TRADES); 
   KeepStopLoss=OrderStopLoss();
   KeepAverage=AveragePrice;
   if(OrderType()==OP_BUY) 
     Direction=1;//long
     else Direction=2;//short
   }

if(KeepStopLoss!=0)
  {
  spread=MathAbs(KeepAverage-KeepStopLoss)/2;
  dummy=(Bid+Ask)/2;
  if (KeepStopLoss<(dummy+spread) && KeepStopLoss>(dummy-spread))
     {
     // a stoploss was hit
     if(Direction==1) Direction=11;// no more longs
     if(Direction==2) Direction=22;// no more shorts
     }
  KeepStopLoss=0;
  }
      
}
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