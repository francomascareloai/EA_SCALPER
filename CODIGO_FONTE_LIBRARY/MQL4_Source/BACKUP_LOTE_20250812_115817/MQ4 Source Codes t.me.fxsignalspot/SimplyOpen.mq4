// Copyright by maloma //
//#include <b-Orders.mqh>

extern double Lots       = 0.1;
extern int    SL         = 31;
       int    magic      =89756432;

       double HiPrice, LoPrice;
       int    CBars;
       int    SellDone=-1, BuyDone=-1;
/*
int deinit()
{
 WriteOrdersInfo();
}
*/
void GetLevels()
{
 HiPrice=0;
 LoPrice=0;
 int i=0;
 //----Up and Down Fractals
//----5 bars Fractal
   if(High[i+3]>High[i+3+1] && High[i+3]>High[i+3+2] && High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=Open[i];
     }
   if(Low[i+3]<Low[i+3+1] && Low[i+3]<Low[i+3+2] && Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Open[i];
     }
//----6 bars Fractal
   if(High[i+3]==High[i+3+1] && High[i+3]>High[i+3+2] && High[i+3]>High[i+3+3] && High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=Open[i];
     }
   if(Low[i+3]==Low[i+3+1] && Low[i+3]<Low[i+3+2] && Low[i+3]<Low[i+3+3] && Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Open[i];
     }                      
//----7 bars Fractal
   if(High[i+3]>=High[i+3+1] && High[i+3]==High[i+3+2] && High[i+3]>High[i+3+3] && High[i+3]>High[i+3+4] && High[i+3]>High[i+3-1] && 
      High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=Open[i];
     }
   if(Low[i+3]<=Low[i+3+1] && Low[i+3]==Low[i+3+2] && Low[i+3]<Low[i+3+3] && Low[i+3]<Low[i+3+4] && Low[i+3]<Low[i+3-1] && 
      Low[i+3]<Low[i+3-2] && LoPrice==0)
     { 
      LoPrice=Open[i];
     }                  
 //----8 bars Fractal                          
   if(High[i+3]>=High[i+3+1] && High[i+3]==High[i+3+2] && High[i+3]==High[i+3+3] && High[i+3]>High[i+3+4] && High[i+3]>High[i+3+5] && 
      High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=Open[i];
     }
   if(Low[i+3]<=Low[i+3+1] && Low[i+3]==Low[i+3+2] && Low[i+3]==Low[i+3+3] && Low[i+3]<Low[i+3+4] && Low[i+3]<Low[i+3+5] && 
      Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Open[i];
     }                              
//----9 bars Fractal                                        
   if(High[i+3]>=High[i+3+1] && High[i+3]==High[i+3+2] && High[i+3]>=High[i+3+3] && High[i+3]==High[i+3+4] && High[i+3]>High[i+3+5] && 
      High[i+3]>High[i+3+6] && High[i+3]>High[i+3-1] && High[i+3]>High[i+3-2] && HiPrice==0)
     {
      HiPrice=Open[i];
     }
   if(Low[i+3]<=Low[i+3+1] && Low[i+3]==Low[i+3+2] && Low[i+3]<=Low[i+3+3] && Low[i+3]==Low[i+3+4] && Low[i+3]<Low[i+3+5] && 
      Low[i+3]<Low[i+3+6] && Low[i+3]<Low[i+3-1] && Low[i+3]<Low[i+3-2] && LoPrice==0)
     {
      LoPrice=Open[i];
     }                        
}

void Check4Close()
{
 int j=OrdersTotal()-1;
 for(int i=j;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if (Symbol()==OrderSymbol() && magic==OrderMagicNumber())
    {
     if (OrderType()==OP_BUY) {double CP=Bid;} else
     if (OrderType()==OP_SELL) {CP=Ask;}
     if (CurTime()-OrderOpenTime()-1>=Period()*60)
       {
        Print("CurTime=",CurTime()," OrdOpT=",OrderOpenTime()," Period=",Period()*60," CurTime()-OrderOpenTime()-1=",CurTime()-OrderOpenTime()-1);
        OrderClose(OrderTicket(),OrderLots(),CP,3);
       }
    }
  }
}

void SetOrders()
{
 if (LoPrice>0)
   {
    OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0,"SO",magic,0,Magenta);
   }
  if (HiPrice>0)
   {
    OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0,"SO",magic,0,Teal);
   }
}

void start()
{
 Check4Close();
 if (CBars==Bars) {return(0);} 
 GetLevels();
 SetOrders();
 CBars=Bars;
}