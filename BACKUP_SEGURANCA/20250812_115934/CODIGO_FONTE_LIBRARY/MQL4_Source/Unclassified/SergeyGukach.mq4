// Copyright by maloma //
//#include <b-Orders.mqh>

extern double Lots       = 0.1;
extern int    TP         = 60;
extern int    StartHour  = 14;
extern int    Filtr      = 9;
extern int    SL         = 23;
extern int    EndHour    = 21;
extern int    TStOp=15;
extern int    TStEp=1;
extern int    Bezubitok=10;
       int    magic      =923845;

       double HiPrice, LoPrice;
       int    CBars;
       int    SellDone=-1, BuyDone=-1;
/*
int deinit()
{
 //WriteOrdersInfo();
}
*/
void Tral()
{
 int i;
 for(i=OrdersTotal()-1;i>=0;i--)
    {
     OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
     if ((OrderSymbol()==Symbol()) && (OrderMagicNumber()==magic))
      {
       if (OrderType()==OP_BUY && Bid-OrderOpenPrice()>TStOp*Point)
        {
         if (Bid-OrderOpenPrice()>=Bezubitok*Point && OrderStopLoss()<OrderOpenPrice())
          {OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+1*Point,OrderTakeProfit(),0,CLR_NONE);}
         if (Bid-OrderStopLoss()>=(TStOp+TStEp)*Point)
          {OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TStOp*Point,OrderTakeProfit(),0,CLR_NONE);}
        }
       if (OrderType()==OP_SELL && OrderOpenPrice()-Ask>TStOp*Point)
        {
         if (OrderOpenPrice()-Ask>=Bezubitok*Point && OrderStopLoss()>OrderOpenPrice())
          {OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-1*Point,OrderTakeProfit(),0,CLR_NONE);}
         if (OrderStopLoss()-Ask>=(TStOp+TStEp)*Point)
          {OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TStOp*Point,OrderTakeProfit(),0,CLR_NONE);}
        }
      }
    }
 return(0);
}

void GetLevels()
{
 HiPrice=0;
 LoPrice=0;
 int i=0;
 while (HiPrice==0 || LoPrice==0)
  {
 //----Up and Down Fractals
//----5 bars Fractal
   if(High[i+3]>High[i+3+1] && High[i+3]>High[i+3+2] && High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]<Low[i+3+1] && Low[i+3]<Low[i+3+2] && Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Low[i+3];
      i++;
      continue;
     }
//----6 bars Fractal
   if(High[i+3]==High[i+3+1] && High[i+3]>High[i+3+2] && High[i+3]>High[i+3+3] && High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]==Low[i+3+1] && Low[i+3]<Low[i+3+2] && Low[i+3]<Low[i+3+3] && Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Low[i+3];
      i++;
      continue;
     }                      
//----7 bars Fractal
   if(High[i+3]>=High[i+3+1] && High[i+3]==High[i+3+2] && High[i+3]>High[i+3+3] && High[i+3]>High[i+3+4] && High[i+3]>High[i+3-1] && 
      High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]<=Low[i+3+1] && Low[i+3]==Low[i+3+2] && Low[i+3]<Low[i+3+3] && Low[i+3]<Low[i+3+4] && Low[i+3]<Low[i+3-1] && 
      Low[i+3]<Low[i+3-2] && LoPrice==0)
     { 
      LoPrice=Low[i+3];
      i++;
      continue;
     }                  
 //----8 bars Fractal                          
   if(High[i+3]>=High[i+3+1] && High[i+3]==High[i+3+2] && High[i+3]==High[i+3+3] && High[i+3]>High[i+3+4] && High[i+3]>High[i+3+5] && 
      High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]<=Low[i+3+1] && Low[i+3]==Low[i+3+2] && Low[i+3]==Low[i+3+3] && Low[i+3]<Low[i+3+4] && Low[i+3]<Low[i+3+5] && 
      Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Low[i+3];
      i++;
      continue;
     }                              
//----9 bars Fractal                                        
   if(High[i+3]>=High[i+3+1] && High[i+3]==High[i+3+2] && High[i+3]>=High[i+3+3] && High[i+3]==High[i+3+4] && High[i+3]>High[i+3+5] && 
      High[i+3]>High[i+3+6] && High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=High[i+3];
     }
   if(Low[i+3]<=Low[i+3+1] && Low[i+3]==Low[i+3+2] && Low[i+3]<=Low[i+3+3] && Low[i+3]==Low[i+3+4] && Low[i+3]<Low[i+3+5] && 
      Low[i+3]<Low[i+3+6] && Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Low[i+3];
      i++;
      continue;
     }                        
   i++;
  }
}

void ClosePosition()
{
 SellDone=-1;
 BuyDone=-1;
 int j=OrdersTotal()-1;
 for (int i=j;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
    {
     if (OrderType()>1) {OrderDelete(OrderTicket());}
     if (OrderType()==OP_BUY) {OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);}
     if (OrderType()==OP_SELL) {OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);}
    }
  }
}

void SetOrders()
{
 if (Ask<HiPrice+Filtr*Point || Bid>LoPrice-Filtr*Point)
   {
    BuyDone=OrderSend(Symbol(),OP_BUYSTOP,Lots,HiPrice+(MarketInfo(Symbol(),MODE_SPREAD)+Filtr)*Point,3,HiPrice-(SL-MarketInfo(Symbol(),MODE_SPREAD)-Filtr)*Point,HiPrice+(TP+MarketInfo(Symbol(),MODE_SPREAD)+Filtr)*Point,"AFB",magic,0,Teal);
    SellDone=OrderSend(Symbol(),OP_SELLSTOP,Lots,LoPrice-Filtr*Point,3,LoPrice-(Filtr-SL)*Point,LoPrice-(Filtr+TP)*Point,"AFB",magic,0,Magenta);
   }
}

void CorrectOrders()
{
 int i,j=OrdersTotal()-1;
 for (i=j;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if (Symbol()==OrderSymbol() && magic==OrderMagicNumber())
    {
     if (OrderType()==OP_BUYSTOP && OrderOpenPrice()-(MarketInfo(Symbol(),MODE_SPREAD)+Filtr)*Point!=HiPrice && Ask<HiPrice+Filtr*Point)
      {OrderModify(OrderTicket(),HiPrice+(MarketInfo(Symbol(),MODE_SPREAD)+Filtr)*Point,OrderStopLoss(),OrderTakeProfit(),0);}
     if (OrderType()==OP_SELLSTOP && OrderOpenPrice()+Filtr*Point!=LoPrice && Bid>LoPrice-Filtr*Point)
      {OrderModify(OrderTicket(),LoPrice-Filtr*Point,OrderStopLoss(),OrderTakeProfit(),0);}      
    }
  }
}

void Try()
{
// Print("HiPrice=",HiPrice, "  LoPrice=",LoPrice);
 if (BuyDone==-1) BuyDone=OrderSend(Symbol(),OP_BUYSTOP,Lots,HiPrice+(MarketInfo(Symbol(),MODE_SPREAD)+Filtr)*Point,3,HiPrice-(SL-MarketInfo(Symbol(),MODE_SPREAD)-Filtr)*Point,HiPrice+(TP+MarketInfo(Symbol(),MODE_SPREAD)+Filtr)*Point,"AFB",magic,0,Teal);
 if (SellDone==-1) SellDone=OrderSend(Symbol(),OP_SELLSTOP,Lots,LoPrice-Filtr*Point,3,LoPrice-(Filtr-SL)*Point,LoPrice-(Filtr+TP)*Point,"AFB",magic,0,Magenta);
}

void start()
{
 if (StartHour>=EndHour) {return(0);}
 Tral();
 if (Hour()==EndHour)
  {
   ClosePosition();
  }
 if (CBars==Bars) {return(0);} 
 if (Hour()==StartHour) 
  {
   GetLevels();
   SetOrders();
  }
 if (Hour()>StartHour && Hour()<EndHour)
  {
   GetLevels();
   //CorrectOrders();
   Try();
  }
 CBars=Bars;
}