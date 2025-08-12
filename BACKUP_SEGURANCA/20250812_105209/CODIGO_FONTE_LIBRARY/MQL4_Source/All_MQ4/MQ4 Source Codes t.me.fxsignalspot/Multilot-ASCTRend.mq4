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

void GetSignal(int i)
{
 int Counter,i1,value10,value11; 
 double value1,x1,x2,value2,value3; 
 double TrueCount,Range,AvgRange,MRO1,MRO2; 
 double Table_value2[150];
 double RISK=3;
 
 SigUP=0; 
 SigDN=0; 
 value10=3+RISK*2; 
 x1=67+RISK; 
 x2=33-RISK; 
 value11=value10; 
 for (int n=99;n>=0;n--)
  { 
   Range=0.0; 
   AvgRange=0.0; 
   for(Counter=i+n; Counter<=i+n+9; Counter++) AvgRange=AvgRange+MathAbs(High[Counter]-Low[Counter]); 
   
   Range=AvgRange/10; 
   Counter=i+n; 
   TrueCount=0; 
   while (Counter<i+n+9 && TrueCount<1) 
    { 
     if (MathAbs(Open[Counter]-Close[Counter+1])>=Range*2.0) TrueCount=TrueCount+1; 
     Counter=Counter+1; 
    } 
   if (TrueCount>=1) {MRO1=Counter;} else {MRO1=-1;} 
   Counter=i+n; 
   TrueCount=0; 
   while (Counter<i+n+6 && TrueCount<1) 
    { 
     if (MathAbs(Close[Counter+3]-Close[Counter])>=Range*4.6) TrueCount=TrueCount+1; 
     Counter=Counter+1; 
    } 
   if (TrueCount>=1) {MRO2=Counter;} else {MRO2=-1;} 
   if (MRO1>-1) {value11=3;} else {value11=value10;} 
   if (MRO2>-1) {value11=4;} else {value11=value10;} 
   value2=100-MathAbs(iWPR(NULL,0,value11,i+n)); // PercentR(value11=9) 
   Table_value2[n+i]=value2;  
//   Print(n+i," ",Table_value2[n+i]);
  }
   if (value2<x2) 
    { 
     i1=1; 
     while (Table_value2[i+i1]>=x2 && Table_value2[i+i1]<=x1)
      {
//       Print("------------------ i+i1=",i+i1," ------Table_value2[i+i1]=",Table_value2[i+i1]);
       i1++;
      } 
     if (Table_value2[i+i1]>x1) {SigDN=1;}
    } 
   if (value2>x1) 
    { 
     i1=1; 
     while (Table_value2[i+i1]>=x2 && Table_value2[i+i1]<=x1){i1++;} 
     if (Table_value2[i+i1]<x2) {SigUP=1;} 
    } 
//   Print("SigUP=",SigUP," SigDN=",SigDN);   
 
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
 GetSignal(0);
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