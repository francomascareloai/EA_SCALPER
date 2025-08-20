//+------------------------------------------------------------------+
//|                                                       tiger.mq4  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, zeshan tayyab malick, June 21st 2014"
#property link      "zmalick@hotmail.com"
double price_ma_period_fast =21; //slow ma
double price_ma_period_slow =89; //fast ma 
double LotSize; //lotsize
double LotFactor = 2; //lotsize factor
double StopLoss=5000; //stop loss
double TakeProfit=70; //take profit
int MagicNumber=1234; //magic
double pips = 0.00001; //leave as default for 5 digit brokers
double adxthreshold = 27; //adx threshold - must be greater than this to trade
double adxperiod = 14; //adx period
double rsiperiod = 14; //rsi period
double rsiupper = 65; //rsi upper bound, wont buy above this value
double rsilower = 35; //rsi lower bound, wont sell below this value

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
//----
if(IsNewCandle())
{
trenddirection(); //find trend direction
logic(); //apply indicator logic
Lot_Volume(); //calc lotsize
buyorsell(); //trade - buy or sell


   return(0);
  }
  return(0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//insuring its a new candle function
//+------------------------------------------------------------------+
bool IsNewCandle()
{
   static int BarsOnChart=0;
	if (Bars == BarsOnChart)
	return (false);
	BarsOnChart = Bars;
	return(true);
}
//+------------------------------------------------------------------+
//identifies the direction of the current trend
//+------------------------------------------------------------------+
bool trenddirection()
{

//----
double pricefastmanow,priceslowmanow;
pricefastmanow = iMA(Symbol(),0,price_ma_period_fast,0,MODE_EMA,PRICE_CLOSE,0);
priceslowmanow = iMA(Symbol(),0,price_ma_period_slow,0,MODE_EMA,PRICE_CLOSE,0);

if (pricefastmanow > priceslowmanow)// bullish
{
return(true);
}

if (pricefastmanow < priceslowmanow)// bearish
{
return(false);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////

return(0);
}
//+------------------------------------------------------------------+
//applies logic from indicators ADX and RSI to determine if we can trade
//+------------------------------------------------------------------+
int logic()
{
double adx,rsi;

adx = iADX(Symbol(),0,adxperiod,PRICE_CLOSE,MODE_MAIN,0);
rsi = iRSI(Symbol(),0,rsiperiod,PRICE_CLOSE,0);

if(adx > adxthreshold)
{

if(rsi > rsilower && rsi < rsiupper)

{

return(1);

}

}

return(0);

}
//+------------------------------------------------------------------+
//opens trades
//+------------------------------------------------------------------+
int buyorsell()
{
bool trenddirectionx, logicx;
int TicketNumber;
trenddirectionx = trenddirection();
logicx = logic();


if(OrdersTotal() == 0)
{
if(trenddirectionx == true && logicx == 1 )

{

//buy

TicketNumber = OrderSend(Symbol(),OP_BUY,LotSize,Ask,3,Ask-(StopLoss*pips),Ask+(TakeProfit*pips),NULL,MagicNumber,0,Green);

if( TicketNumber > 0 )
   {
   Print("Order placed # ", TicketNumber);
   }
else
   {
   Print("Order Send failed, error # ", GetLastError() );
   }


}
}
if(OrdersTotal() == 0)
{
if(trenddirectionx == false && logicx == 1 )
//sell
{

TicketNumber = OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,Bid+(StopLoss*pips),Bid-(TakeProfit*pips),NULL,MagicNumber,0,Red);
if( TicketNumber > 0 )
   {
   Print("Order placed # ", TicketNumber);
   }
else
   {
   Print("Order Send failed, error # ", GetLastError() );
   }

}
}
return(0);

}

//+------------------------------------------------------------------+
//calculates lot size based on balance and factor
//+------------------------------------------------------------------+
double Lot_Volume()
{
double lot;

if (AccountBalance()>=50) lot=0.02;
if (AccountBalance()>=75) lot=0.03;
if (AccountBalance()>=100) lot=0.04;
if (AccountBalance()>=125) lot=0.05;
if (AccountBalance()>=150) lot=0.06;
if (AccountBalance()>=175) lot=0.07;
if (AccountBalance()>=200) lot=0.08;
if (AccountBalance()>=225) lot=0.09;
if (AccountBalance()>=250) lot=0.1;
if (AccountBalance()>=275) lot=0.11;
if (AccountBalance()>=300) lot=0.12;
if (AccountBalance()>=325) lot=0.13;
if (AccountBalance()>=350) lot=0.14;
if (AccountBalance()>=375) lot=0.15;
if (AccountBalance()>=400) lot=0.16;
if (AccountBalance()>=425) lot=0.17;
if (AccountBalance()>=450) lot=0.18;
if (AccountBalance()>=475) lot=0.19;
if (AccountBalance()>=500) lot=0.2;
if (AccountBalance()>=550) lot=0.24;
if (AccountBalance()>=600) lot=0.26;
if (AccountBalance()>=650) lot=0.28;
if (AccountBalance()>=700) lot=0.3;
if (AccountBalance()>=750) lot=0.32;
if (AccountBalance()>=800) lot=0.34;
if (AccountBalance()>=850) lot=0.36;
if (AccountBalance()>=900) lot=0.38;
if (AccountBalance()>=1000) lot=0.4;
if (AccountBalance()>=1500) lot=0.6;
if (AccountBalance()>=2000) lot=0.8;
if (AccountBalance()>=2500) lot=1.0;
if (AccountBalance()>=3000) lot=1.2;
if (AccountBalance()>=3500) lot=1.4;
if (AccountBalance()>=4000) lot=1.6;
if (AccountBalance()>=4500) lot=1.8;
if (AccountBalance()>=5000) lot=2.0;
if (AccountBalance()>=5500) lot=2.2;
if (AccountBalance()>=6000) lot=2.4;
if (AccountBalance()>=7000) lot=2.8;
if (AccountBalance()>=8000) lot=3.2;
if (AccountBalance()>=9000) lot=3.6;
if (AccountBalance()>=10000) lot=4.0;
if (AccountBalance()>=15000) lot=6.0;
if (AccountBalance()>=20000) lot=8.0;
if (AccountBalance()>=30000) lot=12;
if (AccountBalance()>=40000) lot=16;
if (AccountBalance()>=50000) lot=20;
if (AccountBalance()>=60000) lot=24;
if (AccountBalance()>=70000) lot=28;
if (AccountBalance()>=80000) lot=32;
if (AccountBalance()>=90000) lot=36;
if (AccountBalance()>=100000) lot=40;
if (AccountBalance()>=200000) lot=80;

LotSize=lot/LotFactor;
   return(LotSize);
}

