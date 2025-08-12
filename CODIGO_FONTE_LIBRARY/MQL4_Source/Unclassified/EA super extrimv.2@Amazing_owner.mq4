//+------------------------------------------------------------------+
//|                                              EA Super Extrim.mq4 |
//|                                                 Bambang Hariyono |
//|                                    http://www.bahary84@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Super Extrim"
#property link      "http://www.bahary84@yahoo.com"

extern double TakeProfit         = 25;
extern double Lots               = 0.01;
extern double InitialStop        = 300;
extern double TrailingStop       = 200;
extern int    MaxTrades          = 10;
extern double Multiplier         = 1.2;
extern int    Pips               = 7;
extern int    OrderstoProtect    = 6;
extern bool   Money_management   = false;
extern int    AccountType        = 2;        //0: Standard account(NorthFinance,MiG,Alpari) 1: Normal account(FXLQ,FXDD) 2:InterbankFX's NANO Account
extern double risk               = 0.5;
extern bool   ReverseSignal      = false;
extern bool UseTimeFilter=false;
extern int StopTrade = 18;
extern int StartTrade = 19;

extern int ExtDepth=100; 
extern int ExtDeviation=75; 
extern int ExtBackstep=15;  
int Urgency=2;
  
datetime TimeStamp=0;
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
double PipValue=0;
string text="", text2="",text3="",text4="";

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

   double MinLots = NormalizeDouble((MarketInfo(Symbol(), MODE_MINLOT)),2);
   double MaxLots = NormalizeDouble((MarketInfo(Symbol(), MODE_MAXLOT)),2);
   double LotSizeValue = NormalizeDouble((MarketInfo(Symbol(), MODE_LOTSIZE)),0);
   double PipValue=MarketInfo(Symbol(),16);

   if(Money_management)
   {
      switch(AccountType)
      {
         case 0: lotsi=NormalizeDouble(MathCeil((risk*AccountEquity())/10000)/10,1); break;
         case 1: lotsi=NormalizeDouble((risk*AccountEquity())/100000,2); break;
         case 2: lotsi=NormalizeDouble((risk*AccountEquity())/1000,2); break;
         default: lotsi=NormalizeDouble(MathCeil((risk*AccountEquity())/10000)/10,1); break;
      }
   }
   else
   {
      lotsi=Lots;
   }
   
   if(lotsi<MinLots){lotsi=MinLots;}
   if(lotsi>MaxLots){lotsi=MaxLots;}
   
   OpenOrders=0;
   for(cnt=0;cnt<OrdersTotal();cnt++)   
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol()==Symbol())
	  {				
	  	  OpenOrders++;
	  }
   }     
   if (PreviousOpenOrders>OpenOrders) 
   {	  
	  for(cnt=OrdersTotal();cnt>=0;cnt--)
	  {
	     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  	  mode=OrderType();
		  if (OrderSymbol()==Symbol()) 
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
		 if (OrderSymbol()==Symbol()) 
		 {
			LastPrice=OrderOpenPrice();
			if (mode==OP_BUY) { myOrderType=1; }
			if (mode==OP_SELL) { myOrderType=2;	}
		 }
	  }
   }

   if (OpenOrders<1) 
   {
     if (UseTimeFilter)
     {//check trading time
        if (Hour()>StopTrade && Hour()<StartTrade) 
        {Comment(" Medeni Brow...!");
        return(0);}//End of trading time check
     }

	     myOrderType=ZIGZAG();


     	  if (ReverseSignal)
	     {
	  	     if (myOrderType==1) { myOrderType=2; }
		    else { if (myOrderType==2) { myOrderType=1; } }
	     }
   }

   // if we have opened positions we take care of them
   for(cnt=OrdersTotal();cnt>=0;cnt--)
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
	  if (OrderSymbol() == Symbol()) 
	  {	
	  	  if (OrderType()==OP_SELL) 
	  	  {			
	  	  	  if (TrailingStop>0) 
			  {
				  if (OrderOpenPrice()-Ask>=(TrailingStop*Point+Pips*Point))  
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
			   if (Bid-OrderOpenPrice()>=(TrailingStop*Point+Pips*Point))  
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
	  if (OrderSymbol()==Symbol()) 
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
   if (OpenOrders>=OrderstoProtect)
   {	    
	     //Print(Symbol,":",Profit);
	     if ((Profit>=(AccountBalance()*(risk/100) && Money_management)) || (Profit>=(lotsi*(LotSizeValue/100)) && !Money_management))
	     {
	        OrderClose(LastTicket,LastLots,LastClosePrice,slippage,Yellow);		 
	        ContinueOpening=False;
	        return(0);
	     }
   }

      if (!IsTesting()) 
      {
	     if (myOrderType==3) { text="Membidik Sasaran"; }
	     else { text="                         "; }
	     Comment(
	     "\n Trading Extrim");
      }

      if (myOrderType==2 && ContinueOpening) 
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
				     else { mylotsi=NormalizeDouble(mylotsi*Multiplier,2); }
			      }
		    } else { mylotsi=lotsi; }
		    if (mylotsi>10) { mylotsi=10; }
		    OrderSend(Symbol(),OP_SELL,mylotsi,SellPrice,slippage,sl,tp,"OP Sell masuk kandang",0,Red);		    		    
		    return(0);
	     }
      }
      
      if (myOrderType==1 && ContinueOpening) 
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
				  else { mylotsi=NormalizeDouble(mylotsi*Multiplier,2); }
			   }
		    } else { mylotsi=lotsi; }
		    if (mylotsi>5) { mylotsi=5; }
		    OrderSend(Symbol(),OP_BUY,mylotsi,BuyPrice,slippage,sl,tp,"OP Buy masuk kandang",0,Blue);		    
		    return(0);
	     }
      }   

//----
   return(0);
  }
//+------------------------------------------------------------------+

int ZIGZAG()
{
   myOrderType=3;
   int i, candle;
   double ZigZag;
   int CurrentCondition;
   
   
    
   while(candle<100)
     {
      ZigZag=iCustom(NULL,0,"ZigZag",   ExtDepth,ExtDeviation,ExtBackstep,   0,candle);
      if(ZigZag!=0) break;
      candle++;
     }
   if(candle>99) return(0);
   if(ZigZag==High[candle])
      myOrderType=2;
   else if(ZigZag==Low[candle])
      myOrderType=1;
      
      
/*
   double MACDMainCurr=iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_SMA,PRICE_CLOSE,MODE_MAIN,Shift);
   double MACDSigCurr=iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_SMA,PRICE_CLOSE,MODE_SIGNAL,Shift);
   double MACDMainPre=iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_SMA,PRICE_CLOSE,MODE_MAIN,Shift+1);
   double MACDSigPre=iMACD(NULL,0,Fast_EMA,Slow_EMA,Signal_SMA,PRICE_CLOSE,MODE_SIGNAL,Shift+1);

   double SellRange=TradingRange*Point;
   double BuyRange=(TradingRange-(TradingRange*2))*Point;

   if(MACDMainCurr>MACDSigCurr && MACDMainPre<MACDSigPre && MACDSigPre<BuyRange && MACDMainCurr<0 && TimeStamp!=iTime(NULL,0,0)) {myOrderType=2; TimeStamp=iTime(NULL,0,0);}
   if(MACDMainCurr<MACDSigCurr && MACDMainPre>MACDSigPre && MACDSigPre>SellRange && MACDMainCurr>0 && TimeStamp!=iTime(NULL,0,0)) {myOrderType=1; TimeStamp=iTime(NULL,0,0);}
   
   text3=DoubleToStr(SellRange,Digits);
   text4=DoubleToStr(BuyRange,Digits);
*/
if(candle<=Urgency){return(myOrderType);}
else
return(0);
}