//+-----------------------------------------------------------------------------+
//|                              Firebird v0.60 - MA envelope exhaustion system |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"
 
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// Firebird calculates a 10 day SMA and then shifts it up and down 2% to for a channel.
// For the calculation of this SMA either close (more trades) or H+L (safer trades) is used.
// When the price breaks a band a postion in the opposite of the current trend is taken.
// If the position goes against us we simply open an extra position to average.
// 50% of the trades last a day. 45% 2-6 days 5% longer or just fail.
//
//01010100 01110010 01100001 01100100 01100101 01110010 01010011 01100101 01110110 01100101 01101110 
//----------------------- USER INPUT
extern int MA_length = 10;
extern double Percent = 0.3;
extern int TradeOnFriday =1; // >0 trades on friday
extern int MAtype=1;//0=close, 1=HL		 
extern int slip = 100;//exits only
extern double Lots = 0.1;
extern int TakeProfit = 30;
extern int Stoploss = 200;// total loss on all open positions in pips
//extern double TrailingStop = 5;
extern int PipStep = 30;//if position goes this amount of pips against you add another.
extern double IncreasementType =0;//0=just add every PipStep,  >0 =OrdersToal()^x *Pipstep
double Stopper=0;
double KeepStopLoss=0;
double KeepAverage;
double dummy;
double spread=0;
double CurrentPipStep;
int OrderWatcher=0;
//----------------------- MAIN PROGRAM LOOP
int start()
{
double PriceTarget;
double AveragePrice;
int OpeningDay;

//----------------------- CALCULATE THE NEW PIPSTEP
CurrentPipStep=PipStep;
if(IncreasementType>0)
  {
  //CurrentPipStep=MathSqrt(OrdersTotal())*PipStep;
  CurrentPipStep=MathPow(OrdersTotal(),IncreasementType)*PipStep;
  } 

//----------------------- 
int Direction=0;//1=long, 11=avoid long, 2=short, 22=avoid short
 
if (Day()!=5 || TradeOnFriday >0)
{
   int cnt=0, total,OpenTradesOnSymbol=0;
   total=OrdersTotal();
   for (cnt=total;cnt>0;cnt--)
      {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol())  // check for symbol
        {
        double LastPrice=OrderOpenPrice();
        break;
        }
      }
    for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderType()==OP_SELL || OrderType()==OP_BUY &&
          OrderSymbol()==Symbol() ) OpenTradesOnSymbol++;    
     }
      
      
  // OrderSelect(total, SELECT_BY_POS, MODE_TRADES); 

/////////////////////////////////////////////////////////////////////////////////////////
// BACKTESTER FIX:  DO NOT PLACE AN ORDER IF WE JUST CLOSED
// AN ORDER WITHIN Period() MINUTES AGO
/////////////////////////////////////////////////////////////////////////////////////////
double MagicNumber=0;
datetime orderclosetime;
string rightnow;
int rightnow2;
int TheHistoryTotal=HistoryTotal();
int difference;
int flag=0;
for(cnt=0;cnt<TheHistoryTotal;cnt++) {
    if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY)==true)
    {
        if ( (OrderSymbol()==Symbol()) && (OrderMagicNumber()==MagicNumber) ) {
            orderclosetime=OrderCloseTime();
            rightnow=Year()+"-"+Month()+"-"+Day()+" "+Hour()+":"+Minute()+":"+Seconds();
            rightnow2=StrToTime(rightnow);
            difference=rightnow2-orderclosetime;
            if(Period()*60*2>difference) { // At least 2 periods away!
                flag=1;   // Throw a flag
                break;
            }
        }
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
if(flag!=1) {   
   
//----------------------- ENTER POSITION BASED ON OPEN
OrderWatcher=0;
if(MAtype==0)
{
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*(1+Percent/100))<Bid && Direction!=22 && (Bid>=(LastPrice+(CurrentPipStep*Point))||OpenTradesOnSymbol==0)) // Go SHORT -> Only sell if >= 30 pips above previous position entry	
 	  {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),0,0,Red);
      OrderWatcher=1;
      Direction=2;
     }   
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*(1-Percent/100))>Ask && Direction!=11 && (Ask<=(LastPrice-(CurrentPipStep*Point))||OpenTradesOnSymbol==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 

//   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*(1-Percent/100))>Ask &&                  (Ask<=(LastPrice-(       PipStep*Point))||total==0))     
     
     
     {
      OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),0,0,Blue);
      OrderWatcher=1;
      Direction=1;
     } 
}     
  
//----------------------- ENTER POSITION BASED ON HIGH/LOW
if(MAtype==1)
{
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_HIGH,0)*(1+Percent/100))<Bid && Direction!=22 && (Bid>=(LastPrice+(CurrentPipStep*Point))||OpenTradesOnSymbol==0)) // Go SHORT -> Only sell if >= 30 pips above previous position entry	
 	     {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),0,0,Red);
      OrderWatcher=1;
      Direction=2;
     }   
  if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_LOW,0)*(1-Percent/100))>Ask && Direction!=11 && (Ask<=(LastPrice-(CurrentPipStep*Point))||OpenTradesOnSymbol==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 
//  if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_LOW,0)*(1-Percent/100))>Ask && (Ask<=(LastPrice-(PipStep*Point))||total==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 


        {


      OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),0,0,Blue);
      OrderWatcher=1;
      Direction=1;
     } 
} 

} // end of flag test ]]*/                 
//----------------------- CALCULATE AVERAGE OPENING PRICE

 total=OrdersTotal();
 AveragePrice=0;  

 if(OpenTradesOnSymbol>1 && OrderWatcher==1)
   {
   for(cnt=0;cnt<total;cnt++)
      {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()==Symbol())  // check for symbol
        {
        AveragePrice=AveragePrice+OrderOpenPrice();
        }
      }
   AveragePrice=AveragePrice/OpenTradesOnSymbol;
   }

//----------------------- RECALCULATE STOPLOSS & PROFIT TARGET BASED ON AVERAGE OPENING PRICE
total=OrdersTotal();
for(cnt=0;cnt<total;cnt++)
   {  
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       
    if(OrderType()==OP_BUY  && OrderWatcher==1 && OpenTradesOnSymbol>1 && OrderSymbol()==Symbol()) // Calculate profit/stop target for long 
      {
      PriceTarget=AveragePrice+(TakeProfit*Point);
      Stopper=AveragePrice-(((Stoploss*Point)/OpenTradesOnSymbol));
      break; 
      }
    if(OrderType()==OP_SELL && OrderWatcher==1 && OpenTradesOnSymbol>1 && OrderSymbol()==Symbol()) // Calculate profit/stop target for short
      {
      PriceTarget=AveragePrice-(TakeProfit*Point);
      Stopper=AveragePrice+(((Stoploss*Point)/OpenTradesOnSymbol)); 
      break;
      }
    }
//----------------------- IF NEEDED CHANGE ALL OPEN ORDERS TO THE NEWLY CALCULATED PROFIT TARGET    
if(OrderWatcher==1 && OpenTradesOnSymbol>1)// check if average has really changed
  { 
    total=OrdersTotal();  
    for(cnt=0;cnt<total;cnt++)
       {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderSymbol()==Symbol())  // check for symbol
         {
         OrderModify(OrderTicket(),0,Stopper,PriceTarget,0,Yellow);// set all positions to averaged levels
         } 
       }
  }

//----------------------- KEEP TRACK OF STOPLOSS TO AVOID RUNAWAY MARKETS
// Sometimes the market keeps trending so strongly the system never reaches it's target.
// This means huge drawdown. After stopping out it falls in the same trap over and over.
// The code below avoids this by only accepting a signal in teh opposite direction after a SL was hit.
// After that all signals are taken again. Luckily this seems to happen rarely. 
if (OpenTradesOnSymbol>0)
   {
   total=OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
     {  
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); 
     KeepStopLoss=OrderStopLoss();
     KeepAverage=AveragePrice;
     if(OrderType()==OP_BUY) 
       Direction=1;//long
       else Direction=2;//short
       break;
      }
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
// EUR/USD  30 pips / use same value as CurrentPipStep
// GBP/CHF  50 pips / use same value as CurrentPipStep 
// USD/CAD  35 pips / use same value as CurrentPipStep 

//----------------------- OBSERVATIONS
// GBPUSD not suited for this system due to not reversing exhaustions. Maybe use other types of MA
// EURGBP often sharp reversals-> good for trailing stops?
// EURJPY deep pockets needed.