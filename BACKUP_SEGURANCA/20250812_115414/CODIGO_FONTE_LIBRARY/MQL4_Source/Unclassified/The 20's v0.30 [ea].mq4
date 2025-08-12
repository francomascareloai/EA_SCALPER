//+------------------------------------------------------------------+
//|                                                   The 20's v0.30 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"

#include <stdlib.mqh>                  // Include this file in case of needing to retrieve error descriptions
 
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// This EA has 2 main parts.
// Variation=0
// If previous bar opens in the lower 20% of its range and closes in the upper 20% of its range then sell on previous high+10pips.
// If previous bar opens in the upper 20% of its range and closes in the lower 20% of its range then buy on previous low-10pips.
// 
// Variation=1
// The previous bar is an inside bar that has a smaller range than the 3 bars before it.
// If todays bar opens in the lower 20% of yesterdays range then buy.
// If todays bar opens in the upper 20% of yesterdays range then sell.
//
//01010100 01110010 01100001 01100100 01100101 01110010 01010011 01100101 01110110 01100101 01101110 

#define Magic_Num  1002                // ID for The20s Strategy
#define Buy 1
#define Sell 0

extern int Variation=0;

extern int Stoploss=50;
extern int TrailingStop=5;
extern int LockProfit=30;
extern int TakeProfit=100;
extern int LockOutLossValue=10;

extern bool LockInProfit=False;
extern bool LockOutLoss=False;
extern bool LotOptimized=False;
extern bool OverwriteLog=False;

extern int Slippage=3;
extern double Lots=0.1;
extern double MaximumRisk=0.02;
extern double DecreaseFactor=3;

bool LockInProfitFlag;
bool LockOutLossFlag;
int LastTrade=-1, FileHandle;

int init()
{
   if(OverwriteLog==True)
      FileHandle = FileOpen("20sExpert.txt",FILE_WRITE);
   else
      FileHandle = FileOpen("20sExpert.txt",FILE_READ|FILE_WRITE);
   FileSeek(FileHandle,0,SEEK_END);
   if(FileHandle<1)
   {
      Print("File 20sExpert.txt error: ", GetLastError());
      return(-1);
   }

   return(0);
}

int deinit()                           
{                                      
   FileClose(FileHandle);
   return(0);
}

int start()
{
int h = TimeHour(CurTime());
int m = TimeMinute(CurTime());



   int BuyPositions,SellPositions;
   double LastBarsRange,Top20,Bottom20;

   if(IsTradeAllowed()==False)
   {
      Print("Error 1: Expert Advisor not allowed to trade");
      return(-1);
   }

   if(LockProfit<=LockOutLossValue && LockInProfit==True && LockOutLoss==True)
   {      
      Print("LockProfit must be greater than LockOutLossValue");
      return(-1);
   }
   
   if(DetermineOpenPositions(BuyPositions, SellPositions)>1)
      Print("Warning: Multiple trades open simultaneously [",BuyPositions+SellPositions,"]");

   if(BuyPositions+SellPositions==1)
      CheckForClose(BuyPositions,SellPositions);
   
   if(BuyPositions+SellPositions==0)
   {
      LastBarsRange=(High[1]-Low[1]);
      Top20=High[1]-(LastBarsRange*0.20);
      Bottom20=Low[1]+(LastBarsRange*0.20);

      if(Variation==0 && h==0 && m==0)
      {
         if(Open[1]>=Top20 && Close[1]<=Bottom20 && Low[0]<=Low[1]+10*Point)
            OpenOrder(Buy);
         else if(Open[1]<=Bottom20 && Close[1]>=Top20 && High[0]>=High[1]+10*Point)
            OpenOrder(Sell);
      }
      else if(Variation==1 && h==0 && m==0)
      { 
         if((High[4]-Low[4])>LastBarsRange && (High[3]-Low[3])>LastBarsRange && (High[2]-Low[2])>LastBarsRange && High[2]>High[1] && Low[2]<Low[1])
         {
            if(Open[0]<=Bottom20)
               OpenOrder(Buy);  
            if(Open[0]>=Top20)
               OpenOrder(Sell);
         }
      }
   }
}

int OpenOrder(bool OpenType)
{
   if(OpenType==Buy && LastTrade!=DayOfYear())
   {
      if(OrderSend(Symbol(),OP_BUY,LotOptimized(),Ask,Slippage,Ask-Stoploss*Point,Ask+TakeProfit*Point,"The 20's Strategy",Magic_Num,0,Blue) == -1)
      {
         Print("OP_BUY, Err = (", GetLastError(),") ",ErrorDescription(GetLastError()));
         return(-1);
      }
      else
      {
         FileWrite(FileHandle,"Buy @ "+TimeToStr(CurTime(),TIME_DATE|TIME_MINUTES)+": "+Symbol()+" Vol: "+LotOptimized()+" Balance: "+AccountBalance());
         LastTrade=DayOfYear();
         LockOutLossFlag=False;
         LockInProfitFlag=False;
      }
   }
   else if(OpenType==Sell && LastTrade!=DayOfYear())
   {
      if(OrderSend(Symbol(),OP_SELL,LotOptimized(),Bid,Slippage,Bid+Stoploss*Point,Bid-TakeProfit*Point,"The 20's Strategy",Magic_Num,0,Red) == -1)
      {
         Print("OP_SELL, Err = (", GetLastError(),") ",ErrorDescription(GetLastError()));
         return(-1);
      }
      else
      {         
         FileWrite(FileHandle,"Sell @ "+TimeToStr(CurTime(),TIME_DATE|TIME_MINUTES)+": "+Symbol()+" Vol: "+LotOptimized()+" Balance: "+AccountBalance());
         LastTrade=DayOfYear();
         LockOutLossFlag=False;
         LockInProfitFlag=False;
      }
   }
   return(0);
}


int DetermineOpenPositions(int& BuyPositions, int& SellPositions)
{
   int i;

   for(i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==False) 
         break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Num)
      {
         if(OrderType()==OP_BUY)
            BuyPositions++;
         if(OrderType()==OP_SELL)
            SellPositions++;
      }
   }
   if(BuyPositions+SellPositions==0)
   {      
      LockInProfitFlag=False;
      LockOutLossFlag=False;
   }
   return(BuyPositions+SellPositions);
}

int CheckForClose(int& BuyPositions, int& SellPositions)
{
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;
      if(OrderMagicNumber()!=Magic_Num || OrderSymbol()!=Symbol()) 
         continue;

      if(OrderType()==OP_BUY)
      {
         if(LockOutLossFlag==False && LockOutLoss==True)
         {
            if(Bid-OrderOpenPrice()>=LockOutLossValue*Point && OrderStopLoss()<OrderOpenPrice())
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Black);            
               LockOutLossFlag=True;
            }
         }
         
         if(LockInProfitFlag==False && LockInProfit==True)
         {
            if(Bid-OrderOpenPrice()>=LockProfit*Point)
               LockInProfitFlag=True;
         }
         
         if((Bid-OrderOpenPrice()>TrailingStop*Point && (LockInProfit==True && LockInProfitFlag==True)) || (Bid-OrderOpenPrice()>TrailingStop*Point && LockInProfit==False))
         {
            if(OrderStopLoss()<Bid-Point*TrailingStop)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStop*Point,OrderTakeProfit(),0,Black);
               return(0);
            }
         }
      }
      else if(OrderType()==OP_SELL)
      {
         if(LockOutLossFlag==False && LockOutLoss==True)
         {
            if(OrderOpenPrice()-Ask>=LockOutLossValue*Point && OrderStopLoss()>OrderOpenPrice())
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Black);            
               LockOutLossFlag=True;
            }
         }

         if(LockInProfitFlag==False && LockInProfit==True)
         {
            if(OrderOpenPrice()-Ask>=LockProfit*Point)
               LockInProfitFlag=True;
         }

         if((OrderOpenPrice()-Ask>TrailingStop*Point && (LockInProfit==True && LockInProfitFlag==True)) || (OrderOpenPrice()-Ask>TrailingStop*Point && LockInProfit==False))
         {
            if(OrderStopLoss()>Ask+TrailingStop*Point || OrderStopLoss()==0)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStop*Point,OrderTakeProfit(),0,Black);
               return(0);
            }         
         }
      }
   }
   return(0);
}

double LotOptimized()
{
   double lot=Lots;
   int    orders=HistoryTotal();     // history orders total
   int    losses=0;                  // number of losses orders without a break

   if(LotOptimized==True)
   {
      lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);

      if(DecreaseFactor>0)
      {
         for(int i=orders-1;i>=0;i--)
         {
            if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) 
            {
               Print("Error in history!");
               break;
            }
            if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL)
               continue;
         
            if(OrderProfit()>0)
               break;
            if(OrderProfit()<0)
               losses++;
         }
      }
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);

      if(lot<0.1)
         lot=0.1;
      return(lot);
   }
   else
      return(Lots);
 
 int h = TimeHour(CurTime());
int m = TimeMinute(CurTime()); 
Comment(h,":",m);    
  if(h==23 && m>=55)
   {
   OrderSelect(0, SELECT_BY_POS);
   if(OrderType()==OP_BUY)
     {
     OrderClose(OrderTicket(),1,Bid,1000*Point);
     }   
     
   if(OrderType()==OP_SELL)
     {
     OrderClose(OrderTicket(),1,Ask,1000*Point);     
     }
   }     
      
      
}


