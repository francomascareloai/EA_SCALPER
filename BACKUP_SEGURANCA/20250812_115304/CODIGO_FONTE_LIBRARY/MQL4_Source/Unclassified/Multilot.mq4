#property  copyright "Copyright © 2006, Maloma."
#property  link "maloma@datasvit.net"

extern double РазмерЛотаБезРеинвестирования = 0.1;
extern int    Взять = 10;

int    magic=9356735;
int    i,tc = 0;
int    cnt;
double M;
double SigUP=0, SigDN=0;
double Summ=0;
int CBars=0;

//+------------------------------------------------------------------+

void GetFractalSignal()
{
  
 if(High[3]>High[4] && High[3]>High[5] && High[3]>High[2] && High[3]>High[1])
  {SigUP=1;}
 else
  {SigUP=0;}
 
 if(Low[3]<Low[4] && Low[3]<Low[5] && Low[3]<Low[2] && Low[3]<Low[1])
  {SigDN=1;}
 else
  {SigDN=0;}
 
 return(0);
}


int start()
{
 RefreshRates();

 Summ=0;
 int j=OrdersTotal()-1;
 for (cnt = j; cnt >= 0; cnt--)
  {
   RefreshRates();
   OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
   if ((OrderMagicNumber() == magic) && (OrderSymbol() == Symbol()))
   Summ=OrderProfit()+OrderSwap()+Summ;
  }

 for (cnt = j; cnt >= 0; cnt--)
  {
   OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
   if ((OrderMagicNumber() == magic) && (OrderSymbol() == Symbol()))
    {
     RefreshRates();
     if (OrderType() == OP_BUY && Summ>=Взять)  
      {
       i = OrderClose(OrderTicket(),OrderLots(),Bid,100,Red);
      }
     if (OrderType() == OP_SELL && Summ>=Взять)
      {
       i = OrderClose(OrderTicket(),OrderLots(),Ask,100,Blue);
       
      }
    }
  }
 
 if (CBars==Bars) return(-1);
 GetFractalSignal();
 RefreshRates();
 if (SigDN==1)   
  {
   PlaySound("expert.wav");
//   i = OrderSend(Symbol(),OP_BUY,РазмерЛотаБезРеинвестирования,Ask,3,0,0,"Multilot",magic,0,Blue);
   i = OrderSend(Symbol(),OP_BUYSTOP,РазмерЛотаБезРеинвестирования,High[3]+(Ask-Bid+2*Point) ,3,0,0,"Multilot",magic,0,Blue);
   Comment(GetLastError());
  }
 if (SigUP==1) 
  {
   PlaySound("expert.wav");
//   i = OrderSend(Symbol(),OP_SELL,РазмерЛотаБезРеинвестирования,Bid,3,0,0,"Multilot",magic,0,Red);
   i = OrderSend(Symbol(),OP_SELLSTOP,РазмерЛотаБезРеинвестирования,Low[3],3,0,0,"Multilot",magic,0,Red);
   Comment(GetLastError());
  }
 CBars=Bars;

return(0);
}