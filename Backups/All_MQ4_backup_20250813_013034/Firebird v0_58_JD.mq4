//+-----------------------------------------------------------------------------+
//|                              Firebird v0.58 - MA envelope exhaustion system |
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
extern double Percent = 0.2;
extern int TradeOnFriday =1; // >0 trades on friday
extern int MAtype=0;//0=close, 1=HL		 
extern int slip = 100;//exits only
extern int Lots = 1;
extern int TakeProfit = 30;
extern int Stoploss = 200;// total loss on all open positions in pips
//extern double TrailingStop = 5;
extern int PipStep = 30;//if position goes this amount of pips against you add another.
extern double IncreasementType =0;//0=just add every PipStep,  >0 =OrdersToal()^x *Pipstep
extern int SymbolFloatingPoints =4;//4 for most Symbols, 2 for JPY, check in MarketWatchWindow

double KeepStopLoss=0;
double KeepAverage;
double dummy;
double spread=0;
double CurrentPipStep;
int OrderWatcher=0,flag=0,OpenTime=0;
int cnt=0, total,OpenTradesOnSymbol=0;
double LastPrice;
datetime orderclosetime;
int TheHistoryTotal;
int Direction=0;//1=long, 11=avoid long, 2=short, 22=avoid short
double StopperBuy=0,StopperSell=0;
   double PriceTargetBuy=0,PriceTargetSell=0;
   double AveragePriceBuy=0,AveragePriceSell=0;
//----------------------- MAIN PROGRAM LOOP
int start()
{
   if(Symbol()=="USDJPY" || Symbol()=="EURJPY" || Symbol()=="GBPJPY") SymbolFloatingPoints=2;
   
   
   
   total=OrdersTotal();
   OpenTradesOnSymbol=0;
   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderType()==OP_SELL || OrderType()==OP_BUY &&
          OrderSymbol()==Symbol() ) OpenTradesOnSymbol++;    
     }
   
   
   
Comment("LastPrice = ",LastPrice,"\n",
        "AveragePriceBuy = ",AveragePriceBuy,"\n",
        "AveragePriceSell = ",AveragePriceSell,"\n",
        "TradesOnsSymbol = ",OpenTradesOnSymbol,"\n", 
        "PriceTargetBuy = ",PriceTargetBuy,"\n", 
        "PriceTargetSell = ",PriceTargetSell,"\n", 
        "StopperBuy = ",StopperBuy,"\n", 
        "StopperSell = ",StopperSell,"\n", 
        "LastClosedOrder = ",TimeToStr(orderclosetime,TIME_DATE|TIME_SECONDS) ,"\n",
        "Flag = ",flag,"\n",
        "CurrentPipStep = ",CurrentPipStep); 

//----------------------- CALCULATE THE NEW PIPSTEP

CurrentPipStep=PipStep;
if(IncreasementType>0)
  {
  CurrentPipStep=MathPow(OrdersTotal(),IncreasementType)*PipStep;
  } 

//----------------------- 

     
    
/////////////////////////////////////////////////////////////////////////////////////////
// BACKTESTER FIX:  DO NOT PLACE AN ORDER IF WE JUST CLOSED
// AN ORDER WITHIN Period() MINUTES AGO
/////////////////////////////////////////////////////////////////////////////////////////

TheHistoryTotal=HistoryTotal();

for(int cnt2=TheHistoryTotal-1;cnt2>TheHistoryTotal-10;cnt2--) {
  OrderSelect(cnt2,SELECT_BY_POS,MODE_HISTORY);
    
    if ( (OrderSymbol()==Symbol()) ) {
       orderclosetime=OrderCloseTime();
       if(CurTime()-orderclosetime<Period()*60*2)  // At least 2 periods away!
       flag=1;   // Throw a flag
       else
       flag=0;
       break;
       }
} 


   
              
    


/////////////////////////////////////////////////////////////////////////////////////////
if(flag==0 && CurTime()-OpenTime>120) {   
   
//----------------------- ENTER POSITION BASED ON OPEN
if(MAtype==0)
   {
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*(1+Percent/100))<Bid && Direction!=22 && (Bid>=(LastPrice+(CurrentPipStep*Point))||OpenTradesOnSymbol==0)) // Go SHORT -> Only sell if >= 30 pips above previous position entry	
 	  {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),"1",0,0,Red);
      LastPrice=Bid;
      flag=1;
      OpenTime=CurTime();
      Direction=2;
      return;
     }   
   
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*(1-Percent/100))>Ask && Direction!=11 && (Ask<=(LastPrice-(CurrentPipStep*Point))||OpenTradesOnSymbol==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 

//   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*(1-Percent/100))>Ask &&                  (Ask<=(LastPrice-(       PipStep*Point))||total==0))     
          
     {
      OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),"2",0,0,Blue);
      LastPrice=Ask;
      flag=1;
      OpenTime=CurTime();
      Direction=1;
      return;
     } 
}     
  
//----------------------- ENTER POSITION BASED ON HIGH/LOW
if(MAtype==1)
   {
   if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_HIGH,0)*(1+Percent/100))<Bid && Direction!=22 && (Bid>=(LastPrice+(CurrentPipStep*Point))||OpenTradesOnSymbol==0)) // Go SHORT -> Only sell if >= 30 pips above previous position entry	
 	     {
      OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,Bid+(Stoploss*Point),Bid-(TakeProfit*Point),"3",0,0,Red);
      LastPrice=Bid;
      flag=1;
      OpenTime=CurTime();
      Direction=2;
      return;
     }
        
  if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_LOW,0)*(1-Percent/100))>Ask && Direction!=11 && (Ask<=(LastPrice-(CurrentPipStep*Point))||OpenTradesOnSymbol==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 
//  if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_LOW,0)*(1-Percent/100))>Ask && (Ask<=(LastPrice-(PipStep*Point))||total==0)) // Go LONG -> Only buy if >= 30 pips below previous position entry	 


        {

      OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Ask-(Stoploss*Point),Ask+(TakeProfit*Point),"4",0,0,Blue);
      LastPrice=Ask;
      flag=1;
      OpenTime=CurTime();
      Direction=1;
      return;
     } 
} 

} // end of flag test ]]*/                 
//----------------------- CALCULATE AVERAGE OPENING PRICE
if(OpenTradesOnSymbol>0 )
   {
   
   AveragePriceBuy=0;
   AveragePriceSell=0;
   total=OrdersTotal();
   for(int cnt3=0;cnt3<total;cnt3++)
      {
      OrderSelect(cnt3, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()==OP_BUY  && OrderSymbol()==Symbol())  // check for symbol
        {
        AveragePriceBuy=AveragePriceBuy+OrderOpenPrice();
        }
      if(OrderType()==OP_SELL  && OrderSymbol()==Symbol())  // check for symbol
        {
        AveragePriceSell=AveragePriceSell+OrderOpenPrice();
        }
      }
   AveragePriceBuy=NormalizeDouble(AveragePriceBuy/OpenTradesOnSymbol,SymbolFloatingPoints);
   AveragePriceSell=NormalizeDouble(AveragePriceSell/OpenTradesOnSymbol,SymbolFloatingPoints);
   }

//----------------------- RECALCULATE STOPLOSS & PROFIT TARGET BASED ON AVERAGE OPENING PRICE AND Modify Orders
if(OpenTradesOnSymbol>1 )
   {
   StopperBuy=0;
   StopperSell=0;
   PriceTargetBuy=0;
   PriceTargetSell=0;
   PriceTargetBuy=AveragePriceBuy+(TakeProfit*Point);
      StopperBuy=AveragePriceBuy-NormalizeDouble(((Stoploss*Point)/OpenTradesOnSymbol),SymbolFloatingPoints);
    PriceTargetSell=AveragePriceSell-(TakeProfit*Point);
      StopperSell=AveragePriceSell+NormalizeDouble(((Stoploss*Point)/OpenTradesOnSymbol),SymbolFloatingPoints);   
for(int cnt4=0;cnt4<total;cnt4++)
   {  
    OrderSelect(cnt4, SELECT_BY_POS, MODE_TRADES);
       
    if(OrderType()==OP_BUY  && OpenTradesOnSymbol>1 && OrderSymbol()==Symbol()) // Calculate profit/stop target for long 
      {
      
      if(OrderStopLoss() != StopperBuy || OrderTakeProfit( )!= PriceTargetBuy){
      OrderModify(OrderTicket(),0,StopperBuy,PriceTargetBuy,0,Yellow);
       }
      }
    if(OrderType()==OP_SELL && OpenTradesOnSymbol>1 && OrderSymbol()==Symbol()) // Calculate profit/stop target for short
      {
      
      if(OrderStopLoss() != StopperSell || OrderTakeProfit( ) != PriceTargetSell){
      OrderModify(OrderTicket(),0,StopperSell,PriceTargetSell,0,Yellow);
      }
      }
    }
  }

/*[[
//----------------------- KEEP TRACK OF STOPLOSS TO AVOID RUNAWAY MARKETS
// Sometimes the market keeps trending so strongly the system never reaches it's target.
// This means huge drawdown. After stopping out it falls in the same trap over and over.
// The code below avoids this by only accepting a signal in teh opposite direction after a SL was hit.
// After that all signals are taken again. Luckily this seems to happen rarely. 
   if (OpenTradesOnSymbol!=0)
      
     
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
  }]]*/
      

return;
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