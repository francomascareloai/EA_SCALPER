//+-----------------------------------------------------------------------+
//| Goblin.mq4 Rel.1                                                 |
//| Original 10Point 3.mq4 Copyright © 2005, Alejandro Galindo            |
//| http://elCactus.com                                                   |
//|                                                                       |
//| Modified ver. of 10points 3_dynamic_stop to provide multiple options  |
//| for better trend detection using customized Jurik based indicators.   |
//|                                                                       |
//| bluto @ www.forex-tsd.com; 11/22/2006                                 |
//+-----------------------------------------------------------------------+

#property copyright "Copyright © 2005, Alejandro Galindo"
#property link      "http://elCactus.com"

extern double    TakeProfit = 40;           // Profit Goal for the latest order opened
extern double    Lots = 0.1;                // First order will be for this lot size
extern double    InitialStop = 0;           // StopLoss
extern double    TrailingStop = 20;         // Pips to trail the StopLoss

extern int       MaxTrades=10;              // Maximum number of orders to open
extern int       Pips=15;                   // Distance in Pips from one order to another
extern int       SecureProfit=10;           // If profit made is bigger than SecureProfit we close the orders
extern int       AccountProtection=1;       // If one the account protection will be enabled, 0 is disabled
extern int       OrderstoProtect=3;         // This number subtracted from MaxTrades is the number of open orders to enable the account protection.
                                            // Example: (MaxTrades=10) minus (OrderstoProtect=3)=7 orders need to be open before account protection is enabled.
extern int       ReverseCondition=0;        // If one the decision to go long/short will be reversed
extern int       StartYear=2005;            // Year to start (only for backtest)
extern int       StartMonth=1;              // Month to start (only for backtest)
extern int       EndYear=2050;              // Year to stop trading (backtest and live)
extern int       EndMonth=12;               // Month to stop trading (backtest and live)
// extern int    EndHour=22;                // Not used for now
// extern int    EndMinute=30;              // Not used for now
extern int       mm=0;                      // if 1, the lots size will increase based on account size
extern int       risk=12;                   // risk to calculate the lots size (only if mm is enabled)
extern int       AccountisNormal=0;         // Zero if account is not mini/micro                            
extern int       Magic = 123987;            // Magic number for the orders placed
                                
int  OpenOrders=0, cnt=0;
int  slippage=5;
double sl=0, tp=0;
double BuyPrice=0, SellPrice=0;
double lotsi=0, mylotsi=0;
int mode=0, myOrderType=0;
bool ContinueOpening=True;
double LastPrice=0;
int  PreviousOpenOrders=0;
double Profit=0;
int LastTicket=0, LastType=0;
double LastClosePrice=0, LastLots=0;
double Pivot=0;
double PipValue=0;
string text="", text2="";
double DnTrendVal=0,UpTrendVal=0,TrendVal=0;
string TrendTxt="analyzing...";
int RSX_Period=17;
int trendtype=0;



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
   if (AccountisNormal==1)
   {
	  if (mm!=0) { lotsi=MathCeil(AccountBalance()*risk/10000); }
		else { lotsi=Lots; }
   } else {  // then is mini
    if (mm!=0) { lotsi=MathCeil(AccountBalance()*risk/10000)/10; }
		else { lotsi=Lots; }
   }

   if (lotsi>100){ lotsi=100; }
   
   OpenOrders=0;
   for(cnt=0;cnt<OrdersTotal();cnt++)   
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic)
	  {				
	  	  OpenOrders++;
	  }
   }     
   
   if (OpenOrders<1) 
   {
	  if (TimeYear(CurTime())<StartYear) { return(0);  }
	  if (TimeMonth(CurTime())<StartMonth) { return(0); }
	  if (TimeYear(CurTime())>EndYear) { return(0); }
	  if (TimeMonth(CurTime())>EndMonth ) { return(0); }
   }
   
   
   double PipValue = MarketInfo(Symbol(),MODE_TICKVALUE);
   if (PipValue==0) { PipValue=5; }
   
   if (PreviousOpenOrders>OpenOrders) 
   {	  
	  for(cnt=OrdersTotal();cnt>=0;cnt--)
	  {
	     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  	  mode=OrderType();
		  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
		  {
			if (mode==OP_BUY) { OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Blue); }
			if (mode==OP_SELL) { OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Red); }
			return(0);
		 }
	  }
   }

   PreviousOpenOrders=OpenOrders;
   if (OpenOrders>=MaxTrades) 
   {
	  ContinueOpening=False;
   } else {
	  ContinueOpening=True;
   }

   if (LastPrice==0) 
   {
	  for(cnt=0;cnt<OrdersTotal();cnt++)
	  {	
	    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
		 mode=OrderType();	
		 if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
		 {
			LastPrice=OrderOpenPrice();
			if (mode==OP_BUY) { myOrderType=2; }
			if (mode==OP_SELL) { myOrderType=1;	}
		 }
	  }
   }

   if (OpenOrders<1) 
   {
     myOrderType=OpenOrdersBasedOnTrendRSX();
 	  if (ReverseCondition==1)
	  {
	  	  if (myOrderType==1) { myOrderType=2; }
		  else { if (myOrderType==2) { myOrderType=1; } }
	  }
   }
   
   
   Check_Trend();

   // if we have opened positions we take care of them
   for(cnt=OrdersTotal();cnt>=0;cnt--)
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) 
	  {	
	  	  if (OrderType()==OP_SELL) 
	  	  {			
	  	  	  if (TrailingStop>0) 
			  {
				  if (OrderOpenPrice()-Ask>=(TrailingStop+Pips)*Point) 
				  {						
					 if (OrderStopLoss()>(Ask+Point*TrailingStop))
					 {			
					    OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderClosePrice()-TakeProfit*Point-TrailingStop*Point,800,Purple);
	  					 return(0);	  					
	  				 }
	  			  }
			  }
	  	  }
   
	  	  if (OrderType()==OP_BUY)
	  	  {
	  		 if (TrailingStop>0) 
	  		 {
			   if (Bid-OrderOpenPrice()>=(TrailingStop+Pips)*Point) 
				{
					if (OrderStopLoss()<(Bid-Point*TrailingStop)) 
					{					   
					   OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderClosePrice()+TakeProfit*Point+TrailingStop*Point,800,Yellow);
                  return(0);
					}
  				}
			 }
	  	  }
   	}
   }
   
   Profit=0;
   LastTicket=0;
   LastType=0;
	LastClosePrice=0;
	LastLots=0;	
	for(cnt=0;cnt<OrdersTotal();cnt++)
	{
	  OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol()==Symbol() && OrderMagicNumber() == Magic) 
	  {			
	  	   LastTicket=OrderTicket();
			if (OrderType()==OP_BUY) { LastType=OP_BUY; }
			if (OrderType()==OP_SELL) { LastType=OP_SELL; }
			LastClosePrice=OrderClosePrice();
			LastLots=OrderLots();
			if (LastType==OP_BUY) 
			{
				//Profit=Profit+(Ord(cnt,VAL_CLOSEPRICE)-Ord(cnt,VAL_OPENPRICE))*PipValue*Ord(cnt,VAL_LOTS);				
				if (OrderClosePrice()<OrderOpenPrice()) 
					{ Profit=Profit-(OrderOpenPrice()-OrderClosePrice())*OrderLots()/Point; }
				if (OrderClosePrice()>OrderOpenPrice()) 
					{ Profit=Profit+(OrderClosePrice()-OrderOpenPrice())*OrderLots()/Point; }
			}
			if (LastType==OP_SELL) 
			{
				//Profit=Profit+(Ord(cnt,VAL_OPENPRICE)-Ord(cnt,VAL_CLOSEPRICE))*PipValue*Ord(cnt,VAL_LOTS);
				if (OrderClosePrice()>OrderOpenPrice()) 
					{ Profit=Profit-(OrderClosePrice()-OrderOpenPrice())*OrderLots()/Point; }
				if (OrderClosePrice()<OrderOpenPrice()) 
					{ Profit=Profit+(OrderOpenPrice()-OrderClosePrice())*OrderLots()/Point; }
			}
			//Print(Symbol,":",Profit,",",LastLots);
	  }
   }
	
	Profit=Profit*PipValue;
	text2="Profit: $"+DoubleToStr(Profit,2)+" +/-";
   if (OpenOrders>=(MaxTrades-OrderstoProtect) && AccountProtection==1) 
   {	    
	     //Print(Symbol,":",Profit);
	     if (Profit>=SecureProfit) 
	     {
	        OrderClose(LastTicket,LastLots,LastClosePrice,slippage,Yellow);		 
	        ContinueOpening=False;
	        return(0);
	     }
   }

      if (!IsTesting()) 
      {
	     if (myOrderType==3) { text="No conditions to open trades"; }
	     else { text="                         "; }
	     Comment("LastPrice=",LastPrice," Previous open orders=",PreviousOpenOrders,"   H4 Trend Dir: ",TrendTxt," == ",TrendVal,"\nContinue opening=",ContinueOpening," OrderType=",myOrderType,"\n",text2,"\nLots=",lotsi,"\n",text);
      }

      if (myOrderType==1 && ContinueOpening) 
      {	
	     if ((Bid-LastPrice)>=Pips*Point || OpenOrders<1) 
	     {		
		    SellPrice=Bid;				
		    LastPrice=0;
		    if (TakeProfit==0) { tp=0; }
		    else { tp=SellPrice-TakeProfit*Point; }	
		    if (InitialStop==0) { sl=0; }
		    else { sl=NormalizeDouble(SellPrice+InitialStop*Point + (MaxTrades-OpenOrders)*Pips*Point, Digits);  }
		    if (OpenOrders!=0) 
		    {
			      mylotsi=lotsi;			
			      for(cnt=1;cnt<=OpenOrders;cnt++)
			      {
				     if (MaxTrades>12) { mylotsi=NormalizeDouble(mylotsi*1.5,2); }
				     else { mylotsi=NormalizeDouble(mylotsi*2,2); }
			      }
		    } else { mylotsi=lotsi; }
		    if (mylotsi>100) { mylotsi=100; }
		    OrderSend(Symbol(),OP_SELL,mylotsi,SellPrice,slippage,sl,tp,"RF1",Magic,0,Red);		    		    
		    return(0);
	     }
      }
      
      if (myOrderType==2 && ContinueOpening) 
      {
	     if ((LastPrice-Ask)>=Pips*Point || OpenOrders<1) 
	     {		
		    BuyPrice=Ask;
		    LastPrice=0;
		    if (TakeProfit==0) { tp=0; }
		    else { tp=BuyPrice+TakeProfit*Point; }	
		    if (InitialStop==0)  { sl=0; }
		    else { sl=NormalizeDouble(BuyPrice-InitialStop*Point - (MaxTrades-OpenOrders)*Pips*Point, Digits); }
		    if (OpenOrders!=0) {
			   mylotsi=lotsi;			
			   for(cnt=1;cnt<=OpenOrders;cnt++)
			   {
				  if (MaxTrades>12) { mylotsi=NormalizeDouble(mylotsi*1.5,2); }
				  else { mylotsi=NormalizeDouble(mylotsi*2,2); }
			   }
		    } else { mylotsi=lotsi; }
		    if (mylotsi>100) { mylotsi=100; }
		    OrderSend(Symbol(),OP_BUY,mylotsi,BuyPrice,slippage,sl,tp,"RF1",Magic,0,Blue);		    
		    return(0);
	     }
      }   

   return(0);
  }
  
//+---------------------------------------- End of mainline order processing logic  ---------------------------------+


int OpenOrdersBasedOnTrendRSX()
{
      int myOrderType=3;
   
      Check_Trend();
         
      double rsxcurr = iCustom(Symbol(),Period(),"Turbo_JRSX",RSX_Period,0,0);
      double rsxprev = iCustom(Symbol(),Period(),"Turbo_JRSX",RSX_Period,0,1);
      if ((rsxcurr > rsxprev) && (trendtype == 2 || trendtype == 3)) { myOrderType = 2; }
      if ((rsxcurr < rsxprev) && (trendtype == 2 || trendtype == 1)) { myOrderType = 1; }
      return(myOrderType);
     
}

void Check_Trend()
{
  UpTrendVal = iCustom(Symbol(), PERIOD_H4, "Turbo_JVEL",7,-100,0,0);
  DnTrendVal = iCustom(Symbol(), PERIOD_H4, "Turbo_JVEL",7,-100,1,0);
  TrendVal = (UpTrendVal + DnTrendVal);
  Comment("LastPrice=",LastPrice," Previous open orders=",PreviousOpenOrders,"   H4 Trend Dir: ",TrendTxt," == ",TrendVal,"\nContinue opening=",ContinueOpening," OrderType=",myOrderType,"\n",text2,"\nLots=",lotsi,"\n",text);
  if(TrendVal <= -0.1)
      {
       trendtype = 1;
       TrendTxt = "Strong Downtrend";
      } 
  if(TrendVal > -0.1 && TrendVal < 0)
      {
       trendtype = 2;
       TrendTxt = "Weak Downtrend/Ranging";
      }
  if(TrendVal > 0 && TrendVal < 0.1)
      {
       trendtype = 2;
       TrendTxt = "Weak Uptrend/Ranging";
      } 
  if(TrendVal >= 0.1)
      {
       trendtype = 3;
       TrendTxt = "Strong Uptrend";  
      }
  return(0);
}