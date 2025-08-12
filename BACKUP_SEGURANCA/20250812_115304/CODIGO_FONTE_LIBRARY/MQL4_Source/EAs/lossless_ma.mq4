//+------------------------------------------------------------------+
//|                                                      Lossless MA |
//|                                Copyright 2015, Vladimir V. Tkach |
//+------------------------------------------------------------------+
#property version "1.0"
#property copyright "Copyright © 2015, Vladimir V. Tkach"
#property description "EA trades two MA crossing."
#property description "Noloss function with maximum deals limitation."
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum yes_no
  {
   yes=0,   //yes
   no=1,    //no 
  };

extern int
   slip=50,             //Slippage (in pips)
   fast_MA=10,          //Fast ÃA
   slow_MA=30,          //Slow Ã¿
   MovingShift=6,       //MA Shift
   max_deals=5,         //Maximum deals
   magic=1133;          //Magic number  

extern yes_no losses=1; //Close losses

extern double
   Lot=0.01;            //Lot size

int
   order_type=-1,
   ticket=-1;

double
   ma1,
   ma2;
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   ma1=iMA(NULL,0,fast_MA,MovingShift,MODE_SMA,PRICE_CLOSE,1);
   ma2=iMA(NULL,0,slow_MA,MovingShift,MODE_SMA,PRICE_CLOSE,1);

   if(ticket!=-1) CheckForCloseMA();

   if(CountDeals()==0) CheckForOpen();
   else
     {
      if(CountDeals()<max_deals && EnumToString(losses)=="no") CheckForOpen();
     }
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
//sell conditions
   if(ma1<ma2 && order_type!=OP_SELL)
     {
      ticket=OrderSend(Symbol(),OP_SELL,Lot,Bid,slip,0,0,"",magic,0,Red);
      if(ticket==-1) return;

      if(!OrderSelect(ticket,SELECT_BY_TICKET)) {Print("Error during selection."); return;}
      else order_type=OrderType();

      return;
     }
//buy conditions
   if(ma1>ma2 && order_type!=OP_BUY)
     {
      ticket=OrderSend(Symbol(),OP_BUY,Lot,Ask,slip,0,0,"",magic,0,Blue);
      if(ticket==-1) return;

      if(!OrderSelect(ticket,SELECT_BY_TICKET)) {Print("Error during selection."); return;}
      else order_type=OrderType();

      return;
     }
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForCloseMA()
  {
   if(OrderSelect(ticket,SELECT_BY_TICKET)==false) return;
   if(OrderMagicNumber()!=magic || OrderSymbol()!=Symbol()) return;

   if(OrderType()==OP_BUY)
     {
      if(ma1<ma2)
        {
         if(EnumToString(losses)=="yes")
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Bid,slip,White)) Print("Error during order close.");
           }
         else
           {
            if(OrderProfit()>0)
              {
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,slip,White)) Print("Error during order close.");
              }
            else
              {
               if(!OrderModify(ticket,OrderOpenPrice(),0,OrderOpenPrice()+MarketInfo(Symbol(),MODE_SPREAD)*Point,0)) Print("Error during order modify.");
              }
           }
         ticket=-1;
        }
     }

   if(OrderType()==OP_SELL)
     {
      if(ma1>ma2)
        {
         if(EnumToString(losses)=="yes")
           {
            if(!OrderClose(OrderTicket(),OrderLots(),Ask,slip,White)) Print("Error during order close.");
           }
         else
           {
            if(OrderProfit()>0)
              {
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,slip,White)) Print("Error during order close.");
              }
            else
              {
               if(!OrderModify(ticket,OrderOpenPrice(),0,OrderOpenPrice()-MarketInfo(Symbol(),MODE_SPREAD)*Point,0)) Print("Error during order modify.");
              }
           }
         ticket=-1;
        }
     }
  }
//+------------------------------------------------------------------+
//| Count the deals                                                  |
//+------------------------------------------------------------------+
int CountDeals()
  {
   int h=0;

   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
      if(OrderMagicNumber()==magic || OrderSymbol()==Symbol()) h++;
     }
   if(h==0) ticket=-1;
   return(h);
  }
//+------------------------------------------------------------------+
