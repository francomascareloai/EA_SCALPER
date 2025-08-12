//+------------------------------------------------------------------+
//|                                      AmazingEA.mq4 Version 1.0.5 |
//|                                                     FiFtHeLeMeNt |
//|                                             http://www.irxfx.com |
//|                                         fifthelement80@gmail.com |
//+------------------------------------------------------------------+
#property copyright "FiFtHeLeMeNt"
#property link      "http://www.irxfx.com"

extern int TP=25;
extern int NHour=0;
extern int NMin=0;
extern int BEPips=11;
extern int TrailingStop=0;
extern double Lots=0.2;
extern string TradeLog = " MI_Log";

double h,l,ho,lo,hso,lso,htp,ltp,sp;
int Magic=2210;
string filename;


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
  
int CheckOrdersCondition()
  {
    int result=0;
    for (int i=0;i<OrdersTotal();i++) {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if ((OrderType()==OP_BUY) && (OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic)) {
        result=result+1000; 
      }
      if ((OrderType()==OP_SELL) && (OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic)) {
        result=result+100; 
      }
      if ((OrderType()==OP_BUYSTOP) && (OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic)) {
        result=result+10;
      }
      if ((OrderType()==OP_SELLSTOP) && (OrderSymbol() == Symbol()) && (OrderMagicNumber() == Magic)) {
        result=result+1; 
      }

    }
    return(result); // 0 means we have no trades
  }
  
// OrdersCondition Result Pattern
//    1    1    1    1
//    b    s    bs   ss
//  
  
  
void OpenBuyStop()
 {
    int ticket,err,tries;
        tries = 0;
        if (!GlobalVariableCheck("InTrade")) {
          while (tries < 3)
            {
               GlobalVariableSet("InTrade", CurTime());  // set lock indicator
               ticket = OrderSend(Symbol(),OP_BUYSTOP,Lots,ho,1,hso,htp,"EA Order",Magic,0,Red);
               Write("in function OpenBuyStop OrderSend Executed , ticket ="+ticket);
               GlobalVariableDel("InTrade");   // clear lock indicator
               if(ticket<=0) {
                  tries++;
               } else tries = 3;
            }
        }
 }
  
void OpenSellStop()
 {
    int ticket,err,tries;
        tries = 0;
        if (!GlobalVariableCheck("InTrade")) {
          while (tries < 3)
            {
               GlobalVariableSet("InTrade", CurTime());  // set lock indicator
               ticket = OrderSend(Symbol(),OP_SELLSTOP,Lots,lo,1,lso,ltp,"EA Order",Magic,0,Red);
               Write("in function OpenSellStop OrderSend Executed , ticket ="+ticket);
               GlobalVariableDel("InTrade");   // clear lock indicator
               if(ticket<=0) {
                  tries++;
               } else tries = 3;
            }
        }
 }
 
void DoBE(int byPips)
  {
    for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if ( OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic))  // only look if mygrid and symbol...
        {
            if (OrderType() == OP_BUY) if (Bid - OrderOpenPrice() > byPips * Point) if (OrderStopLoss() < OrderOpenPrice()) {
              Write("Movine StopLoss of Buy Order to BE+1");
              OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() +  Point, OrderTakeProfit(), Red);
            }
            if (OrderType() == OP_SELL) if (OrderOpenPrice() - Ask > byPips * Point) if (OrderStopLoss() > OrderOpenPrice()) { 
               Write("Movine StopLoss of Buy Order to BE+1");
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() -  Point, OrderTakeProfit(), Red);
            }
        }
    }
  }

void DoTrail()
  {
    for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if ( OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic))  // only look if mygrid and symbol...
        {
          
          if (OrderType() == OP_BUY) {
             if(Bid-OrderOpenPrice()>Point*TrailingStop)
             {
                if(OrderStopLoss()<Bid-Point*TrailingStop)
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
                     return(0);
                  }
             }
          }

          if (OrderType() == OP_SELL) 
          {
             if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
             {
                if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
                {
                   OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                   return(0);
                }
             }
          }
       }
    }
 }
 

void DeleteBuyStop()
{
   for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic) && (OrderType()==OP_BUYSTOP)) {
       OrderDelete(OrderTicket());
       Write("in function DeleteBuyStopOrderDelete Executed");
     }
       
   }
}
   
void DeleteSellStop()
{
   for (int i = 0; i < OrdersTotal(); i++) {
     OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
     if (OrderSymbol()==Symbol() && (OrderMagicNumber() == Magic) && (OrderType()==OP_SELLSTOP)) {
       OrderDelete(OrderTicket());
       Write("in function DeleteSellStopOrderDelete Executed");
     }
       
   }
}

int Write(string str)
{
   int handle;
  
   handle = FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV,"/t");
   FileSeek(handle, 0, SEEK_END);      
   FileWrite(handle,str + " Time " + TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS));
    FileClose(handle);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   
   Comment("Amazing EA Version 1.0.5 By FiFtHeLeMeNt");
   int i;
   int OrdersCondition,minofday,minofnews;
   
   filename=Symbol() + TradeLog + "-" + Month() + "-" + Day() + ".txt";

   if (BEPips>0) DoBE(BEPips);
   
   if (TrailingStop>0) DoTrail();
   
   OrdersCondition=CheckOrdersCondition();
   
   minofday=Hour()*60+Minute();
   minofnews=NHour*60+NMin;
   
   if ((minofday==minofnews-2) || (minofday==minofnews-1)) {
      h=iHigh(NULL,PERIOD_M1,0);
      l=iLow(NULL,PERIOD_M1,0);
      for (i=1;i<=3;i++) if (iHigh(NULL,PERIOD_M1,i)>h) h=iHigh(NULL,PERIOD_M1,i);
      for (i=1;i<=3;i++) if (iLow(NULL,PERIOD_M1,i)<l) l=iLow(NULL,PERIOD_M1,i);
      sp=Ask-Bid;
      ho=h+sp+(10)*Point;
      lo=l-(10)*Point;
      hso=h+sp;
      lso=l;
      htp=ho+TP*Point-sp;
      ltp=lo-TP*Point+sp;
      if (OrdersCondition==0) {
         Write("Opening BuyStop & SellStop, OrdersCondition="+OrdersCondition+" MinOfDay="+minofday);
         OpenBuyStop();
         OpenSellStop();
      }

      if (OrdersCondition==10) {
         Write("Opening SellStop, OrdersCondition="+OrdersCondition+" MinOfDay="+minofday);
         OpenSellStop();
      }
      
      if (OrdersCondition==1) {
         Write("Opening BuyStop , OrdersCondition="+OrdersCondition+" MinOfDay="+minofday);
         OpenBuyStop();
      }
   }

   if ((minofday>=minofnews) && (minofday<=minofnews+4)) {

      if (OrdersCondition==1001) {
         Write("Deleting SellStop Because of BuyStop Hit, OrdersCondition="+OrdersCondition+" MinOfDay="+minofday);
         DeleteSellStop();
      }
      
      if (OrdersCondition==110) {
        Write("Deleting BuyStop Because of SellStop Hit, OrdersCondition="+OrdersCondition+" MinOfDay="+minofday);
        DeleteBuyStop();
      }
   }
   
   if (minofday>=minofnews+5) {
      if (OrdersCondition==11) {
         Write("Deleting BuyStop and SellStop Because 5 min expired, OrdersCondition="+OrdersCondition+" MinOfDay="+minofday);
         DeleteBuyStop();
         DeleteSellStop();
      }
      
      if ((OrdersCondition==10) || (OrdersCondition==110)) {
        Write("Deleting BuyStop Because 5 min expired, OrdersCondition="+OrdersCondition+" MinOfDay="+minofday);
        DeleteBuyStop();
      }
      
      if ((OrdersCondition==1) || (OrdersCondition==1001)) {
        Write("Deleting SellStop Because 5 min expired, OrdersCondition="+OrdersCondition+" MinOfDay="+minofday);
        DeleteSellStop();
      }
   }
        
   
//----
   return(0);
  }
//+------------------------------------------------------------------+