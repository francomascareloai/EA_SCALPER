//+------------------------------------------------------------------+
//|                                                        Pedro.mq4 |
/*
	                              Name := Venezuelan Investment Group
	                                      Author := Pedro Echenagucia
	                             Link   := http://www.veninvgroup.com/
	                                                      Lots := 1.00
	                                                   Stop Loss := 30
	                                                 Take Profit := 50
	                                                Trailing Stop := 0
*/
//+------------------------------------------------------------------+
#property copyright "Pedro Echenagucia"
#property link      "http://www.veninvgroup.com"
#define ID 98698

extern double Lots=1;
extern int StopLoss=30,TakeProfit=50;
extern int GAP=5,MaxTrades=10,ReEntryGAP=1,tStop=10,tPips=0,StartHour=1,EndHour=23;
extern bool MM=1;
extern int MaxLots=50,StartYear=2006;
double Entry=0,ReEntry=0;
int Dir=0;
int i=0;
double nLots=0;
int nTrades=0;


int start(){
//if( Year()<StartYear )return(0);

if (Hour()<StartHour) {
	Entry=0;
//	ReEntry=0;
	return(0);
}

if( Hour()>EndHour) {
	Entry=0;
//	ReEntry=0;
	return(0);
}
if( nTrades()< MaxTrades){
   Trade();
   Comment("Trade");
}
}



void Trade(){

if (MM) {
	nLots = MathFloor(AccountEquity()/20000);
	if (nLots < 1)nLots=1;
	if (nLots > MaxLots )nLots=MaxLots;
} else {
	nLots=Lots;
}

if ( Entry>0){
	if( Ask>=Entry+GAP*Point){
			OrderSend(Symbol(),OP_SELL,nLots,Bid,1,Bid+StopLoss*Point,Bid-TakeProfit*Point,"PedroMod",ID,0,Red);
		ReEntry=Ask;
		Print("ReEntry ",ReEntry, " Time ",TimeToStr(CurTime(),TIME_DATE|TIME_MINUTES));
		Entry=0;
		Dir=2;
		return;
	}
	
	if( Ask<=Entry-GAP*Point){	
	OrderSend(Symbol(),OP_BUY,nLots,Ask,1,Ask-StopLoss*Point,Ask+TakeProfit*Point,"PedroMod",ID,0,Blue);
		ReEntry=Ask;		
		Print("ReEntry ",ReEntry, " Time ",TimeToStr(CurTime(),TIME_DATE|TIME_MINUTES));
		Entry=0;
		Dir=1;
		return;
	}
} else {
	if( nTrades()==0 ){
		Entry=Ask;
		Print("Entry ",Entry, " Time ",TimeToStr(CurTime(),TIME_DATE|TIME_MINUTES));
		ReEntry=0;
	}
}

if (ReEntry>0){
	if(Dir==1){
		if( Ask<=ReEntry+ReEntryGAP*Point ){
			OrderSend(Symbol(),OP_BUY,nLots,Ask,1,Ask-StopLoss*Point,Ask+TakeProfit*Point,"PedroMod",ID,0,Blue);
			if( nTrades+1<MaxTrades)ReEntry=Ask; else ReEntry=0;
			Print("ReEntry ",ReEntry, " Time ",TimeToStr(CurTime(),TIME_DATE|TIME_MINUTES));
			return;
		}
	}
	
	if( Dir==2 ){
		if( Ask>=ReEntry-ReEntryGAP*Point){	
			OrderSend(Symbol(),OP_SELL,nLots,Bid,1,Bid+StopLoss*Point,Bid-TakeProfit*Point,"PedroMod",ID,0,Red);
			if( nTrades+1<MaxTrades )ReEntry=Ask; else ReEntry=0;
			Print("ReEntry ",ReEntry, " Time ",TimeToStr(CurTime(),TIME_DATE|TIME_MINUTES));
			return;
		}
	}
}
}

int nTrades(){
int g;
   for(int f=0;f<OrdersTotal();f++){
      if(OrderSelect(f,SELECT_BY_POS)){
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==ID){
            g++;
         }
      }
   }
   return(g);
}
/*
if( TrailingStop >0) {
   for(i=0;i<OrdersTotal(); i++){
	   if(OrderSelect(i,SELECT_BY_POS)){
         if (OrderSymbol()==Symbol()) {
			   switch (OrderType()) {
				case OP_BUY:				
					If OrderValue(i,VAL_STOPLOSS)<Ask-TrailingStop*Point Then 
						ModifyOrder(OrderValue(i,VAL_TICKET),OrderValue(i,VAL_OPENPRICE),ask-TrailingStop*Point, OrderValue(i,VAL_TAKEPROFIT), Blue);
				case OP_SELL:
					If OrderValue(i,VAL_STOPLOSS)>bid+TrailingStop*Point Then 
						ModifyOrder(OrderValue(i,VAL_TICKET),OrderValue(i,VAL_OPENPRICE),bid+TrailingStop*Point, OrderValue(i,VAL_TAKEPROFIT), Blue);
			};

		}
	}
}

If tStop Then {
	For i=1 to TotalTrades {
		If OrderValue(1,VAL_SYMBOL)==Symbol Then {
			Switch OrderValue(i,VAL_TYPE) {
				Case OP_BUY:				
					If OrderValue(i,VAL_STOPLOSS)<OrderValue(i,VAL_OPENPRICE) And ask>=OrderValue(i,VAL_OPENPRICE)+tStop*Point Then 
						ModifyOrder(OrderValue(i,VAL_TICKET),OrderValue(i,VAL_OPENPRICE),OrderValue(i,VAL_OPENPRICE)+tPips*Point, OrderValue(i,VAL_TAKEPROFIT), Blue);
				Case OP_SELL:
					If OrderValue(i,VAL_STOPLOSS)>OrderValue(i,VAL_OPENPRICE) And bid<=OrderValue(i,VAL_OPENPRICE)-tStop*Point Then 
						ModifyOrder(OrderValue(i,VAL_TICKET),OrderValue(i,VAL_OPENPRICE),OrderValue(i,VAL_OPENPRICE)-tPips*Point, OrderValue(i,VAL_TAKEPROFIT), Red);					
			};

		}
	}
}
*/


