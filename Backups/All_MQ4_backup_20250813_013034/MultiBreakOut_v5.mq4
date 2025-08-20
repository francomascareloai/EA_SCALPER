// MultiBreakout_v5
// Programmed by Don_Forex and modified by kmrunner
// System based on Hans123 breakout

#property copyright "Provided by SBFX forum members"
#property link      "http://www.strategybuilderfx.com"

#include <stdlib.mqh>
#include <WinUser32.mqh>

#define        NewLine            "\n"
#define        SkipLine           "\n\n"
#define        Tab                "    "

extern double  LotSize                 = 3;
extern int     BrokerOffsetToGMT       = 0;
extern int     NumberOfOrdersPerSide   = 1; // NumberOfOrdersPerSide X TakeProfitIncrement = Highest TakeProfit Level
extern int     TakeProfitIncrement     = 30;
extern bool    EnterNOW                = false;
extern bool    Trade1                  = true;
extern int     Time1Hour               = 6;
extern int     Time1Minutes            = 30;
extern bool    Trade2                  = true;
extern int     Time2Hour               = 9;
extern int     Time2Minutes            = 15;
extern bool    Trade3                  = true;
extern int     Time3Hour               = 12;
extern int     Time3Minutes            = 30;
extern bool    Trade4                  = true;
extern int     Time4Hour               = 23;
extern int     Time4Minutes            = 46;
extern int     ExitMinute              = 55;
extern int     StopLoss                = 20;
extern int     PipsForEntry            = 8;
extern int     BreakEven               = 10;
extern bool    MovingStopLoss          = true;
extern int     PipsToStartMSL          = 25;
extern int     BarsForRange            = 2;

//+------------------------------------------------------------------+
//|  START                                                           |
//+------------------------------------------------------------------+
  
   int start() {
   int ticket;
   if(Bars<100) {
      Print("bars less than 100");
      return(0);
   }
   
   double   TradeTime1 = (Time1Hour*3600)+(Time1Minutes*60);
   double   TradeTime2 = (Time2Hour*3600)+(Time2Minutes*60);
   double   TradeTime3 = (Time3Hour*3600)+(Time3Minutes*60);
   double   TradeTime4 = (Time4Hour*3600)+(Time4Minutes*60);
   double   TradeTime  = OrderOpenTime();
   double   PFE = PipsForEntry;
   double   CurrentTime=(TimeHour(CurTime())*3600+TimeMinute(CurTime())*60-(BrokerOffsetToGMT*3600));
      
   int      total=OrdersTotal();
   double   Spread=Ask-Bid;
   double   hprice=High[Highest(NULL,0,MODE_HIGH,BarsForRange,0)]+Point*PFE+Spread;
   double   lprice=Low[Lowest(NULL,0,MODE_LOW,BarsForRange,0)]-Point*PFE;
   int      TPI=TakeProfitIncrement;
   int      i,j,k;
   int      Volume0 = Volume[0];
   int      Volume1 = Volume[1];
   int      Volume2 = Volume[2];
   int      Volume3 = Volume[3];
   int      Volume4 = Volume[4];
   bool     need_long  = true;
   bool     need_short = true;
                 
// First update existing orders

   if  ((CurrentTime==(TradeTime1-300)&& Trade1)
     || (CurrentTime==(TradeTime2-300)&& Trade2)
     || (CurrentTime==(TradeTime3-300)&& Trade3)
     || (CurrentTime==(TradeTime4-300)&& Trade4)) {
      for(i = OrdersTotal(); i > 0; i--) {
         OrderSelect(i, SELECT_BY_POS);
         if(OrderSymbol()==Symbol()) {
         
         bool result = false;
         
            if(OrderType()==OP_BUYSTOP())  result = OrderDelete( OrderTicket() );
            if(OrderType()==OP_SELLSTOP()) result = OrderDelete( OrderTicket() );
            }
    
           // if(result == false) {
           //    Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
           //    Sleep(3000);
           // }  
         }//End for loop
      }//End Closing All Open and Pending Orders
     
// MODIFY existing orders

 else { 
    for(total = OrdersTotal(); total > 0; total--) {
       OrderSelect(total, SELECT_BY_POS, MODE_TRADES);
        if(OrderSymbol()==Symbol()) {
 
 int  shift=iBarShift(NULL,0,OrderOpenTime(), true);  //to get the number of bars back to the Open Bar               
 
           if(OrderType()==OP_BUY) {
           
                if(High[Highest(NULL,0,MODE_HIGH,shift,0)]<OrderOpenPrice()+Point*BreakEven){
          OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-Point*StopLoss,OrderTakeProfit(),0,White);
                  }
                if(High[Highest(NULL,0,MODE_HIGH,shift,0)]>=OrderOpenPrice()+Point*BreakEven && High[Highest(NULL,0,MODE_HIGH,shift,0)]<OrderOpenPrice()+Point*PipsToStartMSL){
          OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,White); 
                  }
                if(High[Highest(NULL,0,MODE_HIGH,shift,0)]>=OrderOpenPrice()+Point*PipsToStartMSL && Low[1]>Low[2] && Low[1]>OrderOpenPrice()) 
          OrderModify(OrderTicket(),OrderOpenPrice(),Low[1],OrderTakeProfit(),0,White);
             }//End if(OrderType 
           
                                
          if(OrderType()==OP_SELL) {
          
                if(Low[Lowest(NULL,0,MODE_HIGH,shift,0)]>OrderOpenPrice()-Point*BreakEven){
          OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+Point*StopLoss,OrderTakeProfit(),0,White);
                  }
                if(Low[Lowest(NULL,0,MODE_HIGH,shift,0)]<=OrderOpenPrice()-Point*BreakEven && Low[Lowest(NULL,0,MODE_HIGH,shift,0)]>OrderOpenPrice()-Point*PipsToStartMSL){
          OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,White); 
                  }
                if(Low[Lowest(NULL,0,MODE_HIGH,shift,0)]<=OrderOpenPrice()+Point*PipsToStartMSL && High[1]<High[2] && High[1]<OrderOpenPrice()) 
          OrderModify(OrderTicket(),OrderOpenPrice(),High[1],OrderTakeProfit(),0,White);
             }//End if(OrderType
              
            if(OrderType()==OP_BUYSTOP)  need_long = false;
            if(OrderType()==OP_SELLSTOP) need_short = false;
           }//End OrderSymbol()==Symbol()
          }//End for loop
         }//End else
      
       if(AccountFreeMargin()<(1000*LotSize)) {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);
      }
       
 // SEND Orders 
   
       if((CurrentTime==CurrentTime && CurrentTime<=TradeTime+300 && EnterNOW)
       || (CurrentTime>=TradeTime1 && CurrentTime<=TradeTime1+300 && Trade1) 
       || (CurrentTime>=TradeTime2 && CurrentTime<=TradeTime2+300 && Trade2) 
       || (CurrentTime>=TradeTime3 && CurrentTime<=TradeTime3+300 && Trade3)
       || (CurrentTime>=TradeTime4 && CurrentTime<=TradeTime4+300 && Trade4)) {
          
          if(need_long) {
            for(i=NumberOfOrdersPerSide; i>0; i--) {
               int hticket=OrderSend(Symbol(),OP_BUYSTOP,LotSize,hprice,6,hprice-Point*StopLoss,hprice+((TPI*i)*Point),"MultiBreakOut_v5",255+i,0,Green);
            }
            if(hticket<(i+1)) {
               int herror=GetLastError();
               Print("Error = ",ErrorDescription(herror));
            }
         }//End need_long
         
          if(need_short) {
            for(j=NumberOfOrdersPerSide;j>0; j--) {
               int lticket=OrderSend(Symbol(),OP_SELLSTOP,LotSize,lprice,6,lprice+Point*StopLoss,lprice-((TPI*j)*Point),"MultiBreakOut_v5",355+j,0,Red);
            }
            if(lticket<(j+1)) {
               int lerror=GetLastError();
               Print("Error = ",ErrorDescription(lerror));
           }//end for
         }//End need_short
      }//End Entry
         
      
 // INFORMATIONAL COMMENTS
 
      Comment("Current Time is  ",TimeHour(CurTime())-BrokerOffsetToGMT,":",TimeMinute(CurTime()),".",TimeSeconds(CurTime()),
      NewLine + "Curent Volume is      ",
      Tab + Volume0,
      NewLine + "Volume -1 is   ",
      Tab + Volume1,
      NewLine + "Volume -2 is   ",
      Tab + Volume2,
      NewLine + "Volume -3 is   ",
      Tab + Volume3,
      NewLine + "Volume -4 is   ",
      Tab + Volume4,
      NewLine + "Shift is   ",
      Tab + shift);   
 }//End Start
Sleep(10000);

