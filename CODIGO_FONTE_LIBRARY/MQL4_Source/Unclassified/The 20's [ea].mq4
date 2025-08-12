//+------------------------------------------------------------------------------+
//|                            ------------                       The 20's v0.20 |
//+------------------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"
 
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



//----------------------- USER INPUT
extern int TakeProfit=10;
extern int TrailingStop=20;//starts after TakeProfit is reached, 0=off
extern int Variation=1;	 

//----------------------- MAIN PROGRAM LOOP
double YesterdaysRange;
double Top20;
double Bottom20;
int Lots=1;
int slip=0;
double Stoploss=200;
double OrderDay=99;
int start()

{
// ---------------- START OF DAY???
 int h = TimeHour(CurTime());
 int m = TimeMinute(CurTime());
 int s = TimeSeconds(CurTime());

 
if(h==0 && m==0 && OrdersTotal()==0)
  {

YesterdaysRange=(High[1]-Low[1]);
Top20=High[1]-(YesterdaysRange*0.20);
Bottom20=Low[1]+(YesterdaysRange*0.20);

if(Variation==0)//original system
  {
  if(Open[1]>=Top20 && Close[1]<=Bottom20 && Ask<(Low[1]-0.010) && Day()!=OrderDay)
    { 
    OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Low[1]-(10*Point),Ask+(2*TakeProfit*Point),0,0,Blue);
    OrderDay=Day();
    }
  
  if(Close[1]>Top20 && Open[1]<Bottom20 && Bid>(High[1]+0.010) && Day()!=OrderDay)
    { 
    OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,High[1]+(10*Point),Bid-(2*TakeProfit*Point),0,0,Red);
    OrderDay=Day();
    }  
  }
   
 if(Variation==1)//with narrow range and inside bar
   { 
   if((High[4]-Low[4])>YesterdaysRange && (High[3]-Low[3])>YesterdaysRange && (High[2]-Low[2])>YesterdaysRange && High[1]<High[2] && Low[1]>Low[2])
     {
     if(Open[0]<=Bottom20 && Day()!=OrderDay)
       { 
       OrderSend(Symbol(),OP_BUY,Lots,Ask,slip,Low[1]-(100*Point),Ask+(2*TakeProfit*Point),0,0,Blue);
       OrderDay=Day();
       }
  
     if(Open[0]>=Top20 && Day()!=OrderDay)
       { 
       OrderSend(Symbol(),OP_SELL,Lots,Bid,slip,High[1]+(100*Point),Bid-(2*TakeProfit*Point),0,0,Red);
       OrderDay=Day();
       } 
     
     }
   }
   
}   


if((Bid-OrderOpenPrice()>=TakeProfit*Point && OrderType()==OP_BUY) || (OrderOpenPrice()-Ask>=TakeProfit*Point && OrderType()==OP_BUY))
{


// ---------------- TRAILING STOP
if(TrailingStop>0)
{ 
     OrderSelect(0, SELECT_BY_POS, MODE_TRADES);
     if((OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) && 
(OrderSymbol()==Symbol()))
         {
            if(TrailingStop>0) 
              {                
               if(Bid-OrderOpenPrice()>Point*TrailingStop)
                 {
                  if(OrderStopLoss()<Bid-Point*TrailingStop)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid- 
Point*TrailingStop,OrderTakeProfit(),0,Aqua);
                     return(0);
                    }
                 }
              }
          }
     if((OrderType() == OP_SELL || OrderType() == OP_SELLSTOP) && 
(OrderSymbol()==Symbol()))
         {
            if(TrailingStop>0)  
              {                
               if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
                 {
                  if(OrderStopLoss()==0.0 || 
                     OrderStopLoss()>(Ask+Point*TrailingStop))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice
(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Aqua);
                     return(0);
                    }
                 }
              }
          }
}   
} 
 
// ---------------- END OF DAY???
h = TimeHour(CurTime());
m = TimeMinute(CurTime());
s = TimeSeconds(CurTime());

 
 Comment(h,":",m,":",s);
 
 if(h==23 && m==59 && s>0 && OrdersTotal()>0)
   {
   OrderDay=9999;
   OrderSelect(0, SELECT_BY_POS);
   if(OrderType()==OP_BUY)
     {
     OrderClose(OrderTicket(),1,Bid,10*Point);
     }   
     
   if(OrderType()==OP_SELL)
     {
     OrderClose(OrderTicket(),1,Ask,10*Point);     
     }
   }



 if(h==23 && m==59 && s>0 && OrdersTotal()>0)
   {
   OrderDay=9999;
   OrderSelect(0, SELECT_BY_POS);
   if(OrderType()==OP_BUY)
     {
     OrderClose(OrderTicket(),1,Bid,10*Point);
     }   
     
   if(OrderType()==OP_SELL)
     {
     OrderClose(OrderTicket(),1,Ask,10*Point);     
     }
   }

}

