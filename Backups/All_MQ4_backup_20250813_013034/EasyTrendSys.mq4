//+------------------------------------------------------------------+
//|                                                 EasyTrendSys.mq4 |
//|                     Copyright © 2010, Gorbushin Grigory (Dzhini) |
//|                                              grin2000@rbcmail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Gorbushin Grigory (Dzhini)"
#property link      "grin2000@rbcmail.ru"

extern string S1="---------------- Magic Number";
extern int MAGICMA1=34268732;
extern int MAGICMA2=32685632;

extern string S2="---------------- Signals Settings";
extern int RISK=4;

extern string S3="---------------- Lot Settings";
extern double  Lot = 0.1; //---------------------lot size
extern bool RiskMM=false;  //---------------------risk management
extern double RiskPercent=1;  //------------------risk percentage

extern string S4="---------------- TP&SL&BE Settings";
extern double  TP = 100;  //----------------------takeprofit
extern double   SL = 50;  //---------------------stoploss
extern int BreakEven=60;//-----------------------break even

extern string S5="---------------- Trailing Settings";
extern int TrailingStop=60;//--------------------trailing stop
extern int TrailingStep=20;//--------------------trailing step

bool BuySignal=false, SellSignal=false;


//-------------------------------------------------------------------- Open orders checking (Func)
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && (OrderMagicNumber()==MAGICMA1 || OrderMagicNumber()==MAGICMA2))
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }

   if(buys>0) return(buys);
   else       return(-sells);
  }
  

//----------------------------------------------------------------- Signals indicator (Func) iCustom

double Signals(int TF, int mode, int shift)
{
return (iCustom(Symbol(), TF, "Signals", RISK, mode, shift));
}

//-------------------------------------------------------------------Check FirstSignal 60 min (Func)

int FirstSignal()
{

double SignalsBuy_1 = Signals(60,0,1);
double SignalsBuy_2 = Signals(60,0,2);
double SignalsSell_1 = Signals(60,1,1);
double SignalsSell_2 = Signals(60,1,2);

if (SignalsBuy_2==0 && SignalsBuy_1!=0) return(1);

if (SignalsSell_2==0 && SignalsSell_1!=0) return(-1);

}

//---------------------------------------------------------------------------------- Check SecondSignal 5 min (Func)

int SecondSignal()
{
double SignalsBuy5_1 = Signals(5,0,1);
double SignalsBuy5_2 = Signals(5,0,2);
double SignalsSell5_1 = Signals(5,1,1);
double SignalsSell5_2 = Signals(5,1,2);

if (SignalsBuy5_2==0 && SignalsBuy5_1!=0) return (1);

if (SignalsSell5_2==0 && SignalsSell5_1!=0) return (-1);

}

//----------------------------------------------------------------------------------- 
//----------------------------------------------------------------------------------- MAIN

void start()
 {
 
 int res1, res2;
 
//----------------------------------------------------------------------trailing stop

   if(TrailingStop>0)MoveTrailingStop();
   
//----------------------------------------------------------------------break even
   
   if(BreakEven>0)MoveBreakEven();   

//----------------------------------------------------------------------check trade situation

   if(Bars<100 && IsTradeAllowed()==false) return;
 
//---------------------------------------------------------------------risk management 

   if(RiskMM)CalculateMM();
   
//---------------------------------------------------------------------first signal

 if (FirstSignal()==1) {BuySignal=true; SellSignal=false;}
 if (FirstSignal()==-1) {BuySignal=false; SellSignal=true;}
 
//----------------------------------------------------------------------open orders

 if(CalculateCurrentOrders(Symbol())== 0 && SellSignal && SecondSignal()==-1)   
    {res1=OrderSend(Symbol(),OP_SELL,Lot ,Bid,2,Ask+SL*Point,Bid-TP*Point,"",MAGICMA1,0,Red);
     res2=OrderSend(Symbol(),OP_SELL,Lot ,Bid,2,Ask+SL*Point,Bid-TP*Point,"",MAGICMA2,0,Red);
     return;}
    
    
 if(CalculateCurrentOrders(Symbol())== 0 && BuySignal && SecondSignal()==1)
    {res1=OrderSend(Symbol(),OP_BUY ,Lot ,Ask,2,Bid-SL*Point,Ask+TP*Point,"",MAGICMA1,0,Blue);
     res2=OrderSend(Symbol(),OP_BUY ,Lot ,Ask,2,Bid-SL*Point,Ask+TP*Point,"",MAGICMA2,0,Blue);
     return;}
  
//----------------------------------------------------------------------close
   
   if(CalculateCurrentOrders(Symbol())!= 0 && FirstSignal()!= 0 && NumberOfBarOpenLastPos()!=0)
    {CheckForClose(); return;}
 
 }
 //---------------------------------------------------------------------------
 //--------------------------------------------------------------------------- Check conditions for close & Close (Func)
 
 void CheckForClose()
 {

   for( int i = 0; i < OrdersTotal(); i++ )
   {
      if( OrderSelect(i, SELECT_BY_POS) == -1 ) { continue; }
      if( OrderMagicNumber() != MAGICMA2 || OrderSymbol() != Symbol() ) { continue; }
      
      if( OrderType() == OP_BUY )
      {
         OrderClose(OrderTicket(), OrderLots(), Bid, 2, Blue);
      }
      else if( OrderType() == OP_SELL )
      {
         OrderClose(OrderTicket(), OrderLots(), Ask, 2, Red);
      }
   } 
} 
 
 //---------------------------------------------------------------------------- Trailing stop (Func)

void MoveTrailingStop()
{
   int cnt,total=OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL&&OrderSymbol()==Symbol()&&OrderMagicNumber()==MAGICMA1)
      {
         if(OrderType()==OP_BUY)
         {
            if(TrailingStop>0)  
            {                 
               if((NormalizeDouble(OrderStopLoss(),Digits)<NormalizeDouble(Bid-Point*(TrailingStop+TrailingStep),Digits))||(OrderStopLoss()==0))
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*TrailingStop,Digits),OrderTakeProfit(),0,Blue);
                  return(0);
               }
            }
         }
         else 
         {
            if(TrailingStop>0)  
            {                 
               if((NormalizeDouble(OrderStopLoss(),Digits)>(NormalizeDouble(Ask+Point*(TrailingStop+TrailingStep),Digits)))||(OrderStopLoss()==0))
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*TrailingStop,Digits),OrderTakeProfit(),0,Red);
                  return(0);
               }
            }
         }
      }
   }
}


//---------------------------------------------------- Break even (Func) ????? Check for condition:  if(OrderType()<=OP_SELL&&OrderSymbol()==Symbol()&&OrderMagicNumber()==MAGICMA1&&OrderMagicNumber()==MAGICMA2)

void MoveBreakEven()
{
   int cnt,total=OrdersTotal();
   for(cnt=0;cnt<total;cnt++)
   {
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()<=OP_SELL&&OrderSymbol()==Symbol()&&OrderMagicNumber()==MAGICMA1&&OrderMagicNumber()==MAGICMA2)
      {
         if(OrderType()==OP_BUY)
         {
            if(BreakEven>0)
            {
               if(NormalizeDouble((Bid-OrderOpenPrice()),Digits)>BreakEven*Point)
               {
                  if(NormalizeDouble((OrderStopLoss()-OrderOpenPrice()),Digits)<0)
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()+0*Point,Digits),OrderTakeProfit(),0,Blue);
                     return(0);
                  }
               }
            }
         }
         else
         {
            if(BreakEven>0)
            {
               if(NormalizeDouble((OrderOpenPrice()-Ask),Digits)>BreakEven*Point)
               {
                  if(NormalizeDouble((OrderOpenPrice()-OrderStopLoss()),Digits)<0)
                  {
                     OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice()-0*Point,Digits),OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
         }
      }
   }
}

//---------------------------------------------------- Check open orders on current candle (Func)

int NumberOfBarOpenLastPos(string sy="0", int tf=0, int op=-1, int mn=-1) 

{
  datetime t;
  int      i, k=OrdersTotal();

  if (sy=="" || sy=="0") sy=Symbol();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==sy) {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (op<0 || OrderType()==op) {
            if (mn<0 || OrderMagicNumber()==mn) {
              if (t<OrderOpenTime()) t=OrderOpenTime();
            }
          }
        }
      }
    }
  }
  return(iBarShift(sy, tf, t, True));
}

//--------------------------------------------- Calculate money management (Func)

void CalculateMM()
{
   double MinLots=MarketInfo(Symbol(),MODE_MINLOT);
   double MaxLots=MarketInfo(Symbol(),MODE_MAXLOT);
   Lot=AccountFreeMargin()/100000*RiskPercent;
   Lot=MathMin(MaxLots,MathMax(MinLots,Lot));
   if(MinLots<0.1)Lot=NormalizeDouble(Lot,2);
   else
   {
     if(MinLots<1)Lot=NormalizeDouble(Lot,1);
     else Lot=NormalizeDouble(Lot,0);
   }
   if(Lot<MinLots)Lot=MinLots;
   if(Lot>MaxLots)Lot=MaxLots;
   return(0);
}

