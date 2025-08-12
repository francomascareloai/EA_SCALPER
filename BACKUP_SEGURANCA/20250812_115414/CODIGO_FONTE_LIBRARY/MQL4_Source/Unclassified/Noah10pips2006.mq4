//+------------------------------------------------------------------+
//|                                               noah10pips2006.mq4 |
//|                Copyright © 2005, Nick Bilak, beluck[AT]gmail.com |
//|                                    http://metatrader.50webs.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Nick Bilak"
#property link       "http://metatrader.50webs.com/"
#include <stdlib.mqh>

extern int    MAGICNUM=1;
extern double Lots = 0.1;
extern int StopLoss = 55;
extern int TakeProfit = 100;
extern int TrailingStop = 0;
extern int slippage = 3;

extern double MaximumRisk = 7.0;
extern double MaxLot = 100.0;
extern double MinLot = 1.0;
extern bool FixedLot = true;

extern int TimeZoneOfData=0; // NY 7,15;
extern int StartHour=2; // 9:00 PM EST
extern int StartMinute=0;
extern int EndHour=23;
extern int EndMinute=0;
extern int FridayEndHour=21;
extern int SecureProfit=10;
extern int TrailSecureProfit=16; 
extern int TradeFriday=1; // 0- dont open trades on friday, 1- Trade on friday
extern int DontReverse=1;
extern int StartYear=2005;
extern int StartMonth=6;
extern int TradesSet=2;
extern int TypeSet=0; // 0 = NONE, 1 = SELL, 2 = BUY
extern int ReverseSet=0;  // 0=False, 1=True


int Today, RefDate, LastBarOfDay, FirstBarOfDay, Loop;
double pre_lo, pre_hi, myC, myO, lotsi;
int Cnt;
int OpenTrades, FilledOrders;
double BuyPrice, SellPrice;
int TimetoOpen, TimetoClose, tmp, i;
int Trades=2; string Type="NONE"; bool Reverse=False;
int mode,tr;
int myEndHour, myFridayEndHour, myStartHour;
bool FirstTime=True;
double range;
double hi_pass;
double lo_pass;
double MP;
double er_hi;
double er_lo;
double erange,erange2;
double r3;
double diffs,diffb;
int res; bool bres;

int start() {

   if (TimeYear(Time[0])<StartYear) return;

   lotsi=LotsRisk(StopLoss);

   if (FirstTime) {
	   if (TradesSet!=2 || TypeSet!=0 || ReverseSet!=0)  {
		   Trades  = TradesSet;
		   if (TypeSet == 0) Type = "NONE";
		   if (TypeSet == 1) Type = "SELL";
		   if (TypeSet == 2) Type = "BUY";
		   if (ReverseSet ==0) Reverse = False;
		   if (ReverseSet ==1) Reverse = True;
	   }
	   FirstTime=False;
   }

   Today=MathFloor(CurTime()/86400)*86400;
   Cnt=1;
   if (Today!=RefDate) {
	   RefDate=Today;
		   while ( Cnt<(Bars-1) && (Time[Cnt]-TimeZoneOfData*3600>=RefDate) ) {
			   Cnt++;
		   }
		   LastBarOfDay=Cnt;
		   if (DayOfWeek()==1) RefDate=Today-86400*3;
		   else RefDate=Today-86400;
		   while ( Cnt<(Bars-1) && (Time[Cnt]-TimeZoneOfData*3600>=RefDate) ) {
			   Cnt++;
		   }
	   FirstBarOfDay=Cnt-1;
   }

   pre_hi=High[Highest(NULL,0,MODE_HIGH,FirstBarOfDay-LastBarOfDay+1,LastBarOfDay)];
   pre_lo=Low[Lowest(NULL,0,MODE_LOW,FirstBarOfDay-LastBarOfDay+1,LastBarOfDay)];
   myC=Close[LastBarOfDay];

   //pre_hi=High[lookback];
   //pre_lo=Low[lookback];

   // *** calculate all the 10pip numbers ***
   hi_pass = pre_hi + 0.002 ;
   lo_pass = pre_lo - 0.002 ;
   MP = (((pre_hi - pre_lo) / 2.0) + pre_lo);
   MP = NormalizeDouble(MP,Digits);
   hi_pass = NormalizeDouble(hi_pass,Digits);
   lo_pass = NormalizeDouble(lo_pass,Digits);
   
   erange = (pre_hi - pre_lo);
   //erange2= (pre_hi - pre_lo)*10000;

   // *** which entry range amount to use? ***
   // *** less than 160 range ***
   if (erange <= 0.016) 
     r3 = 0.004; 
   else
     r3 = erange * 0.25;

   // *** set entry range ***
   er_hi = (pre_hi - r3);
   er_lo = (pre_lo + r3);
   erange2= (er_hi - er_lo)*10000.0;
   // *** print the numbers on the chart for reference ***
   //Comment("BUY @ ", er_hi,"\nSELL @ ", er_lo);

   // *** draw the lines on the chart ***

   // *** special case for ER if range < 80 ***
   // *** Prints an advisory message on the screen ***


   if (erange <= 0.008) {
	     ObjectDelete("LT80_txt");
	     ObjectCreate("LT80_txt",OBJ_TEXT,0,Time[35],MP);
	     ObjectSetText("LT80_txt","RANGE<80 ",10,"Arial",White);
        //SetObjectText("LT80_txt","RANGE<80 ","Arial",10,Black);
        //MoveObject("LT80_txt",OBJ_TEXT,time[35],mp,time[35],mp,Black);
   }

   // *** Draw lines ***
   ObjectDelete("MP");
   ObjectCreate("MP", OBJ_HLINE,0,Time[25],MP);
   ObjectSetText("MP","MP Range ",8,"Arial",White);
   ObjectSet("MP",OBJPROP_COLOR,Blue);
   ObjectSet("MP",OBJPROP_STYLE,STYLE_DOT);
   //MoveObject("MP",OBJ_HLINE,time[25],mp,Time[25],mp,Blue,1,STYLE_DOT);
   //SetObjectText("MP_txt","MP Range ","Arial",8,Black);
   //MoveObject("MP_txt",OBJ_TEXT,time[25],mp,time[25],mp,Black);

   ObjectDelete("ER_Hi");
   ObjectCreate("ER_Hi", OBJ_HLINE,0,Time[25],er_hi);
   ObjectSetText("ER_Hi","Below Here BUYZONE ->MP ",8,"Arial",White);
   ObjectSet("ER_Hi",OBJPROP_COLOR,Green);
   ObjectSet("ER_Hi",OBJPROP_STYLE,STYLE_DASH);
   //MoveObject("ER_Hi",OBJ_HLINE,time[25],er_hi,Time[25],er_hi,Green,1,STYLE_DASH);
   //SetObjectText("ER_Hi_txt","Below Here BUYZONE ->MP ","Arial",8,Black);
   //MoveObject("ER_Hi_txt",OBJ_TEXT,time[25],er_hi,time[25],er_hi,Black);

   ObjectDelete("ER_Lo");
   ObjectCreate("ER_Lo", OBJ_HLINE,0,Time[25],er_lo);
   ObjectSetText("ER_Lo","Above Here SELLZONE ->MP ",8,"Arial",White);
   ObjectSet("ER_Lo",OBJPROP_COLOR,Red);
   ObjectSet("ER_Lo",OBJPROP_STYLE,STYLE_DASH);
   //MoveObject("ER_Lo",OBJ_HLINE,time[25],er_lo,Time[25],er_lo,red,1,STYLE_DASH);
   //SetObjectText("ER_Lo_txt","Above Here SELLZONE ->MP ","Arial",8,Black);
   //MoveObject("ER_Lo_txt",OBJ_TEXT,time[25],er_lo,time[25],er_lo,Black);

   ObjectDelete("Hi_Pass");
   ObjectCreate("Hi_Pass", OBJ_HLINE,0,Time[25],hi_pass);
   ObjectSetText("Hi_Pass","HiPASS ",8,"Arial",White);
   ObjectSet("Hi_Pass",OBJPROP_COLOR,Green);
   ObjectSet("Hi_Pass",OBJPROP_STYLE,STYLE_DOT);
   //MoveObject("Hi_Pass",OBJ_HLINE,time[25],hi_pass,time[25],hi_pass,Green,1,STYLE_DOT);
   //SetObjectText("Hi_Pass_txt","HiPASS ","Arial",8,Black);
   //MoveObject("Hi_Pass_txt",OBJ_TEXT,time[25],hi_Pass,time[25],hi_pass,Black);

   ObjectDelete("Lo_Pass");
   ObjectCreate("Lo_Pass", OBJ_HLINE,0,Time[25],lo_pass);
   ObjectSetText("Lo_Pass","LoPASS ",8,"Arial",White);
   ObjectSet("Lo_Pass",OBJPROP_COLOR,Red);
   ObjectSet("Lo_Pass",OBJPROP_STYLE,STYLE_DOT);
   //MoveObject("Lo_Pass",OBJ_HLINE,time[25],lo_pass,Time[25],lo_pass,red,1,STYLE_DOT);
   //SetObjectText("Lo_Pass_txt","LoPASS ","Arial",8,Black);
   //MoveObject("Lo_Pass_txt",OBJ_TEXT,time[25],lo_pass,time[25],lo_pass,Black);

   ObjectDelete("Pre_Hi");
   ObjectCreate("Pre_Hi", OBJ_HLINE,0,Time[25],pre_hi);
   ObjectSetText("Pre_Hi","PreHI ",8,"Arial",White);
   ObjectSet("Pre_Hi",OBJPROP_COLOR,Blue);
   ObjectSet("Pre_Hi",OBJPROP_STYLE,STYLE_DASH);
   //MoveObject("Pre_Hi",OBJ_HLINE,time[25],pre_hi,Time[25],pre_hi,Blue,1,STYLE_DASH);
   //SetObjectText("Pre_Hi_txt","PreHI ","Arial",8,Black);
   //MoveObject("Pre_Hi_txt",OBJ_TEXT,time[25],pre_hi,time[25],pre_hi,Black);

   ObjectDelete("Pre_Lo");
   ObjectCreate("Pre_Lo", OBJ_HLINE,0,Time[25],pre_lo);
   ObjectSetText("Pre_Lo","PreLO ",8,"Arial",White);
   ObjectSet("Pre_Lo",OBJPROP_COLOR,Blue);
   ObjectSet("Pre_Lo",OBJPROP_STYLE,STYLE_DASH);
   //MoveObject("Pre_Lo",OBJ_HLINE,time[25],pre_lo,Time[25],pre_lo,Blue,1,STYLE_DASH);	
   //SetObjectText("Pre_Lo_txt","PreLO ","Arial",8,Black);
   //MoveObject("Pre_Lo_txt",OBJ_TEXT,time[25],pre_lo,time[25],pre_lo,Black);


   if ( (Ask > MP) && (Ask < er_hi) ) { 
      Comment("Entry Price In BUYZONE");
   } else {
      if ( (Bid < MP) && (Bid > er_lo) ) {
         Comment("Entry Price In SELLZONE");
      }
   }

   OpenTrades=0;
   for (Cnt=0; Cnt<OrdersTotal(); Cnt++) {
      if (!OrderSelect(Cnt,SELECT_BY_POS,MODE_TRADES)) continue;
	   if ( OrderSymbol()==Symbol() ) {
		   OpenTrades++;
		   if (OrderType()==OP_SELL || OrderType()==OP_BUY)
			   FilledOrders++;
	   }
   }

   // We calculate the endHour based on the TimeZoneofData value
   Cnt=0;
   i=TimeZoneOfData;
   while (Cnt<=EndHour) {
	   if (i>23) i=0;	
	   myEndHour=i;
	   i++;
	   Cnt++;
   }

   // Friday end of day offset
   //cnt=0;
   //i=TimeZoneofData;
   //While (cnt<=FridayEndHour)
   //{
   //	if (i>23) then i=0;	
   //	myFridayEndHour=i;
   //	i++;
   //	cnt++;
   //};
   myFridayEndHour=FridayEndHour;

   if ( (Hour()==myEndHour && Minute()>=EndMinute) || (DayOfWeek()==6 && Hour()==myFridayEndHour && Minute()>=EndMinute) ) {
	   //cnt=0;While cnt<=10000 { cnt++; };
      for (Cnt=OrdersTotal()-1; Cnt>=0; Cnt--) {
         if (!OrderSelect(Cnt,SELECT_BY_POS,MODE_TRADES)) continue;
	      if ( OrderSymbol()==Symbol() ) {
		      mode = OrderType();
			   Trades=2;
			   Type="NONE";
			   Reverse=False;
            tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
 			   if (mode == OP_BUYSTOP)  bres=OrderDelete(OrderTicket());
 		      if (mode == OP_SELLSTOP)  bres=OrderDelete(OrderTicket());
 			   if (mode == OP_BUYLIMIT)  bres=OrderDelete(OrderTicket());
 		      if (mode == OP_SELLLIMIT)  bres=OrderDelete(OrderTicket());
 			   if (mode == OP_BUY)  bres=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Blue); //CloseOrder(ord(cnt,VAL_TICKET),ord(cnt,VAL_LOTS),bid,Slippage,Blue);
 			   if (mode == OP_SELL) bres=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Blue); //CloseOrder(ord(cnt,VAL_TICKET),ord(cnt,VAL_LOTS),ask,Slippage,red);
   		   if (!bres) Print("Error closing or deleting order : ",ErrorDescription(GetLastError())); 
		   }
	   }
   }


   // We get the StartHour offset
   Cnt=0;
   i=TimeZoneOfData;
   while (Cnt<=StartHour) {
	   if (i>23) i=0;	
	   myStartHour=i;
	   i++;
	   Cnt++;
   }

   if (TradeFriday ==1 || DayOfWeek()!=5) {
      if (Hour()==myStartHour && Minute()>=StartMinute) {
	     if (OpenTrades<1 && erange2 > 40) {
	       if ( (Close[1] > MP) && (Close[1] < hi_pass) ) {
		       Trades=1;
		       Type="NONE";
		       Reverse=True;		
             tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
             res=OrderSend(Symbol(),OP_SELLSTOP,lotsi,MP,slippage,MP+StopLoss*Point,MP-TakeProfit*Point,"N10",MAGICNUM,0,Red);
		       if (res<=0) Print("Error opening order : ",ErrorDescription(GetLastError())); 
		       //SetOrder(OP_SELLSTOP,Lotsi,MP,Slippage,MP+StopLoss*Point,MP-TakeProfit*Point,RED);		
             //return;
	       }		
		
	       if ( (Close[1] > lo_pass) && (Close[1] < MP) ) {	
		       Trades=1;
		       Type="NONE";
		       Reverse=True;
             tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
             res=OrderSend(Symbol(),OP_BUYSTOP,lotsi,MP,slippage,MP-StopLoss*Point,MP+TakeProfit*Point,"N10",MAGICNUM,0,Blue);
		       if (res<=0) Print("Error opening order : ",ErrorDescription(GetLastError())); 
		       //SetOrder(OP_BUYSTOP,Lotsi,MP,Slippage,MP-StopLoss*Point,MP+TakeProfit*Point,BLUE);				
             //return;
	       }
	       return;
	     }
      }
   }



   // if we only have one Stop order we place the another one to always have ready both sides
   if (OpenTrades==1 && Trades>=1) {
      for (Cnt=OrdersTotal()-1; Cnt>=0; Cnt--) {
         if (!OrderSelect(Cnt,SELECT_BY_POS,MODE_TRADES)) continue;
	      if ( OrderSymbol()==Symbol() ) {
			   if (OrderType()==OP_SELLSTOP) {
			      if ( (Close[1] > MP) && (Close[1] < hi_pass) ) {
				      Trades=1;
				      Type="NONE";
				      Reverse=True;
                  tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
                  res=OrderSend(Symbol(),OP_BUYSTOP,lotsi,hi_pass,slippage,hi_pass-StopLoss*Point,hi_pass+TakeProfit*Point,"N10",MAGICNUM,0,Blue);
		            if (res<=0) Print("Error opening order : ",ErrorDescription(GetLastError())); 
    			      //SetOrder(OP_BUYSTOP,Lotsi,HI_PASS,Slippage,HI_PASS-StopLoss*Point,HI_PASS+TakeProfit*Point,blue);
        		      return;
	    	      }
	    	   }
			   if (OrderType()==OP_BUYSTOP) {
    		      if ( (Close[1] > lo_pass) && (Close[1] < MP) ) {
    			      Trades=1;
	    		      Type="NONE";
	    		      Reverse=True;
                  tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
                  res=OrderSend(Symbol(),OP_SELLSTOP,lotsi,lo_pass,slippage,lo_pass+StopLoss*Point,lo_pass-TakeProfit*Point,"N10",MAGICNUM,0,Red);
		            if (res<=0) Print("Error opening order : ",ErrorDescription(GetLastError())); 
				      //SetOrder(OP_SELLSTOP,Lotsi,LO_PASS,Slippage,LO_PASS+StopLoss*Point,LO_PASS-TakeProfit*Point,Red); 		
        		      return;
    		      }
    		   }
    	   }
	   }
   }

   if (DontReverse==1) Reverse=False;

   // if one order was closed we reverse (only once in a day)
   if ( OpenTrades<1 && Trades==1 && Reverse ) {
	   if (Type=="BUY") {
		   Trades=0;
		   Type="NONE";
		   Reverse=False;
         tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
         res=OrderSend(Symbol(),OP_BUY,lotsi,Ask,slippage,Ask-StopLoss*Point,Ask+TakeProfit*Point,"N10",MAGICNUM,0,Blue);
         if (res<=0) Print("Error opening order : ",ErrorDescription(GetLastError())); 
		   return;
		   //SetOrder(OP_BUY,Lotsi,Ask,Slippage,Ask-StopLoss*Point,Ask+TakeProfit*Point,Blue); 			
	   }
	
	   if (Type=="SELL") {
		   Trades=0;
		   Type="NONE";
		   Reverse=False;		
         tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
         res=OrderSend(Symbol(),OP_SELL,lotsi,Bid,slippage,Bid+StopLoss*Point,Bid-TakeProfit*Point,"N10",MAGICNUM,0,Red);
         if (res<=0) Print("Error opening order : ",ErrorDescription(GetLastError())); 
		   return;
		   //SetOrder(OP_SELL,Lotsi,Bid,Slippage,Bid+StopLoss*Point,Bid-TakeProfit*Point,Red);
	   }
   }
   // if we have opened positions we take care of them
   for (Cnt=OrdersTotal()-1; Cnt>=0; Cnt--) {
      if (!OrderSelect(Cnt,SELECT_BY_POS,MODE_TRADES)) continue;
      if ( OrderSymbol()==Symbol() ) {
		   if (OrderType() == OP_BUY) {
            for (i=OrdersTotal()-1; i>=0; i--) {
               if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
               if ( OrderSymbol()==Symbol() ) {
					   if (OrderType()==OP_SELLSTOP || OrderType()==OP_BUYSTOP) {
						   Trades=1;
						   Type="SELL";
						   Reverse=True;
                     tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
						   bres=OrderDelete(OrderTicket());
		               if (!bres) Print("Error deleting order : ",ErrorDescription(GetLastError())); 
						   //return;
					   }
				   }
			   }

            if (!OrderSelect(Cnt,SELECT_BY_POS,MODE_TRADES)) continue;
			   //We secure	SecureProfit (10) pips after TrailSecureProfit (16) pips
			   if ( OrderStopLoss()<=OrderOpenPrice()+SecureProfit*Point
			         && Bid-OrderOpenPrice()>=TrailSecureProfit*Point ) {
               tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+SecureProfit*Point,0,0,DeepSkyBlue);
				   //ModifyOrder(Ord(cnt,VAL_TICKET),Ord(cnt,VAL_OPENPRICE),((Ord(cnt,VAL_OPENPRICE))+SecureProfit*Point),0,DeepSkyBlue);
				   Trades=0;
				   Type="NONE";
				   Reverse=False;
				   tmp=OrderOpenPrice()+SecureProfit*Point;
				   Print("BUY Stoploss trailed to Openprice+SecureProfit=",tmp);
				   //Exit;
			   }
			   // Trailing stop after profit secured
			   if (TrailingStop>0) {
				   if ( OrderStopLoss()>=OrderOpenPrice()+SecureProfit*Point && OrderStopLoss()<Bid-TrailingStop*Point ) {
                  tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
                  OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*Point,0,0,Yellow);
					   //ModifyOrder(OrderValue(cnt,VAL_TICKET),OrderValue(cnt,VAL_OPENPRICE),Bid-Point*(SecureProfit+TrailingStop),0,Yellow);
					   Trades=0;
					   Type="NONE";
					   Reverse=False;
					   //Exit;
				   }
			   }		
		   }
		
		   if (OrderType() == OP_SELL) {
            for (i=OrdersTotal()-1; i>=0; i--) {
               if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
               if ( OrderSymbol()==Symbol() ) {
					   if (OrderType()==OP_SELLSTOP || OrderType()==OP_BUYSTOP) {
						   Trades=1;
						   Type="BUY";
						   Reverse=True;
                     tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
						   bres=OrderDelete(OrderTicket());
		               if (!bres) Print("Error deleting order : ",ErrorDescription(GetLastError())); 
						   return;
					   }
				   }
			   }
            if (!OrderSelect(Cnt,SELECT_BY_POS,MODE_TRADES)) continue;
	
			   //We secure	SecureProfit (10) pips after TrailSecureProfit (16) pips
			   if ( OrderStopLoss()>=OrderOpenPrice()-SecureProfit*Point
			         && OrderOpenPrice()-Ask>=TrailSecureProfit*Point ) {
               tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-SecureProfit*Point,0,0,DeepSkyBlue);
				   //ModifyOrder(Ord(cnt,VAL_TICKET),Ord(cnt,VAL_OPENPRICE),((Ord(cnt,VAL_OPENPRICE))-SecureProfit*Point),0,DeepSkyBlue);
				   Trades=0;
				   Type="NONE";
				   Reverse=False;
				   tmp=OrderOpenPrice()-SecureProfit*Point;
				   Print("SELL Stoploss trailed to Openprice-SecureProfit=",tmp);
				   //Exit;
			   }

			   if (TrailingStop>0) {
				   if ( OrderStopLoss()<=OrderOpenPrice()-SecureProfit*Point && OrderStopLoss()>Ask+TrailingStop*Point ) {
                  tr=0; while (tr<5 && !IsTradeAllowed()) { tr++; Sleep(5000); }
                  OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop*Point,0,0,Purple);
					   //ModifyOrder(OrderValue(cnt,VAL_TICKET),OrderValue(cnt,VAL_OPENPRICE),Ask+Point*(TrailingStop+SecureProfit),0,Purple);
					   Trades=0;
					   Type="NONE";
					   Reverse=False;
					   //Exit;
				   }
			   }
		   }
	   }
   }
   //Alert(StrToTime("2005.11.30"));
   return;
}

double LotsRisk(int StopLoss)  { 
   double lot=Lots;
//---- select lot size
   if (!FixedLot)
      lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk*0.001/StopLoss,1);
   else
      lot=Lots;
//---- return lot size
   if(lot<MinLot) lot=MinLot;
   if(lot>MaxLot) lot=MaxLot;
   return(lot);
}


