//+------------------------------------------------------------------+
//| macd test mq4 version by jpygbp@yahoo.com
//+------------------------------------------------------------------+
/////////////////////////////////////////////////////////////////////////////////////////
extern double TakeProfit = 50;
extern double Lots = 1.0;
extern double TrailingStop = 30;
extern double MACDOpenLevel=3;
extern double MACDCloseLevel=2;
extern double MATrendPeriod=26;
extern double OpenTimeStart=1530;
extern double OpenTimeEnd=1730;
extern double CloseTime=2300;
extern int    mytime = -1;
/////////////////////////////////////////////////////////////////////////////////////////////
int init()
{
   mytime = Hour()*100+Seconds();
   PrintTime();
   #property show_inputs
   return(0);
}
/////////////////////////////////////////////////////////////////////////////////////////////
bool CheckMargin()
{
    if(AccountFreeMargin()<(1000*Lots))
   {
      Print("We have no money. Free Margin = ", AccountFreeMargin());
      return(0);  
   }
   else return(1);  
}
/////////////////////////////////////////////////////////////////////////////////////////////
bool CheckBars()
{
   if(Bars<100)
   {
      Print("bars less than 100");
      return(0);  
   }
   else return(1);
}
/////////////////////////////////////////////////////////////////////////////////////////////
bool CheckProfit()
{
   if(TakeProfit<10)
   {
      Print("TakeProfit less than 10");
      return(0);
   }
   else return(1);
}
/////////////////////////////////////////////////////////////////////////////////////////////
int PrintTime()
{
   Print("Time:",mytime);
}
/////////////////////////////////////////////////////////////////////////////////////////////
bool CheckTime()
{
   if(mytime < OpenTimeStart || mytime > OpenTimeEnd)
   {
      return(0);
   }
   else return(1);
}
/////////////////////////////////////////////////////////////////////////////////////////////
bool BuyConditionsMet()
{
   double MacdCurrent, MacdPrevious, SignalCurrent;
   double SignalPrevious, MaCurrent, MaPrevious;
   MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);
   if(
      MacdCurrent<0 && 
      MacdCurrent>SignalCurrent &&
      MacdPrevious<SignalPrevious &&
      MathAbs(MacdCurrent)>(MACDOpenLevel*Point) &&
      MaCurrent>MaPrevious //&&
      //MacdCurrent > MacdPrevious &&
      //mytime >= OpenTimeStart
      )
      {return (1);}
      else
      {return (0);}
}
/////////////////////////////////////////////////////////////////////////////////////////////
bool SellConditionsMet()
{
   double MacdCurrent, MacdPrevious, SignalCurrent;
   double SignalPrevious, MaCurrent, MaPrevious;
   MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);
   if(
      MacdCurrent>0 &&
      MacdCurrent<SignalCurrent &&
      MacdPrevious>SignalPrevious && 
      MacdCurrent>(MACDOpenLevel*Point) &&
      MaCurrent>MaPrevious //&&
      //MacdCurrent < MacdPrevious &&
      //mytime >= OpenTimeStart
      )
      {return(1);}
      else
      {return(0);}
}
/////////////////////////////////////////////////////////////////////////////////////////////
bool CheckOpenOrders()
{
   if (OrdersTotal()> 1)
   {
      return(0);
   }
   else return(1);
}
/////////////////////////////////////////////////////////////////////////////////////////////
int OpenBuyOrder()
{ 
   int ticket = 0;
   ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,Ask+TakeProfit*Point,"macd sample",16384,0,Green);
   Print("BuyTime: ",mytime);
   if(ticket>0)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
      { 
         Print("BUY order opened : ",OrderOpenPrice()," BuyTime: ",mytime );
         return(1);
      }
   }
   else 
   {
      Print("Error opening BUY order : ",GetLastError()); 
      return(0);
   } 
}
/////////////////////////////////////////////////////////////////////////////////////////////
int OpenSellOrder()
{
   int ticket = 0;
   ticket=OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,Bid-TakeProfit*Point,"macd sample",16384,0,Red);
   Print("SellTime:",mytime);
   if(ticket>0)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
      {
         Print("SELL order opened : ",OrderOpenPrice()," SellTime:",mytime);
         return(1);
      }
   }
   else
   {
      Print("Error opening SELL order : ",GetLastError()); 
      return(0);
   } 
}
/////////////////////////////////////////////////////////////////////////////////////////////
int CloseLongOrder()
{
   OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
   Print("LongCloseTime: ",mytime);
   return(1);
}
/////////////////////////////////////////////////////////////////////////////////////////////
int CloseShortOrder()
{
   OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
   Print("ShortCloseTime: ",mytime);
   return(1);
}
/////////////////////////////////////////////////////////////////////////////////////////////
int ModifyLongTrail()
{
   if(TrailingStop>0)  
   {                 
      if(Bid-OrderOpenPrice()>Point*TrailingStop)
      {
         if(OrderStopLoss()<Bid-Point*TrailingStop)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
            Print("LongModifyTime: ",mytime);
            return(1);
         }
         else return(0);
      }
      else return(0);
   }
   else return(0);
}
/////////////////////////////////////////////////////////////////////////////////////////////
int ModifyShortTrail()
{
   if(TrailingStop>0)  
   {                 
      if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
      {
         if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
            Print("ShortModifyTime: ",mytime);
            return(1);
         }
         else return(0);
      }
      else return(0);   
   }
   else return(0);
}
/////////////////////////////////////////////////////////////////////////////////////////////
int CheckForClose()
{
   int cnt, total, ticket;
   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
      {
         if(OrderType()==OP_BUY)   // long position is opened
         { 
            if(SellConditionsMet())
            {
               CloseLongOrder();
            }
            ModifyLongTrail();
         }
         else 
         {
            if(BuyConditionsMet())
            {
               CloseShortOrder();
            }
            ModifyShortTrail();   
         }
      }
   return(1);
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
int start()
{
   mytime = Hour()*100+Seconds();
     
   if (
   CheckBars()&&
   CheckProfit() &&
   CheckTime() &&
   CheckOpenOrders() &&
   CheckMargin()
   )
   {
      if (BuyConditionsMet())
      {
         OpenBuyOrder();
      }
      if (SellConditionsMet())
      {
         OpenSellOrder(); 
      }
   }
   else
   CheckForClose();   
} 