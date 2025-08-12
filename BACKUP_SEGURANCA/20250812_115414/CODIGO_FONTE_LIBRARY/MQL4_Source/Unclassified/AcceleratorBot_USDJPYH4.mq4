//+------------------------------------------------------------------+
//|                                                                  |
//|                                                  Sébastien       |
//|                                              vsebastien3@aol.com |
//+------------------------------------------------------------------+
#property copyright "Sébastien V"
#property link      "vsebastien3@aol.com"
#property version   "1.00"
#property strict

 int RiskBoost=3;
 int magicalNumber = 24542789;
extern int StopL = 750;          //StopLoss(in pips)
extern int TakeProfit = 9999;   //TakeProfit
 int slippage = 3;
extern double Lots = 0.01;       // Lot size
extern int Trailing =0;          //Trailing stop (in pips)
extern double percent = 0.02;    //percent riked by trade
extern bool AutoLots=True;
 int depotinit=500;
 bool saving=false;
 int MovingPeriod = 200;
extern int x1=0;
extern int x2=150;
extern int x3=500;
extern int ADXP=14;
extern int ADXS=20;
int filtre=5;
int ticket = 0;
double iDoji=8.5; 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int start()
  {
  
  
  double ADX=iADX(Symbol(),0,ADXP,PRICE_HIGH,MODE_MAIN,0); 
   double STOCHM_1 = iStochastic(Symbol(),0,8,3,3,MODE_SMMA,0, MODE_MAIN, 1);
  double STOCHS_1 = iStochastic(Symbol(),0,8,3,3,MODE_SMMA,0, MODE_SIGNAL, 1);
  
        double MA =iMA(Symbol(),0,MovingPeriod,0,MODE_EMA,PRICE_CLOSE,0); 
  AutoLot();
  
  double close=Close[1];
  if((IsEveningStar()==0) && (IsDojiCandle()==0) && (IsBearishEngulfing()==0))
  {
  
  filtre=1;
  
  }
  if((IsMorningStar()==0) && (IsDojiCandle()==0) && (IsBullishEngulfing()==0))
  {
  filtre=0;
  }
 


  
   if(ADX>ADXS && isPositionOpen()==False && Close[1]<Open[1] && Algo()>0 && filtre==1  )
  {
 OpenBuy();
  }
  
  if(ADX>ADXS && isPositionOpen()==False && Close[1]>Open[1] && Algo()<0 && filtre==0 )
  {
  OpenSell();
  }
  
  if(ADX<ADXS && isPositionOpen()==False && Close[1]<Open[1] && STOCHM_1 > STOCHS_1 && filtre==1)
  {
  OpenBuy();
  }
  
  if(ADX<ADXS && isPositionOpen()==False && Close[1]>Open[1] && STOCHM_1 < STOCHS_1 && filtre==0)
  {
  OpenSell();
  }
  
  if((ADX>ADXS && Algo()<0)  )
  {
  CloseBuy();
   
  }
  
  if((ADX>ADXS && Algo()>0))
  
  {
  CloseSell();
  
  }
  
  if((ADX<ADXS && STOCHM_1 < STOCHS_1))
  {
  CloseBuy();
   
  }
  
  if((ADX<ADXS && STOCHM_1 > STOCHS_1))
  {
  CloseSell();
  
  }
  
  Trail();
  return(0); 
  
  }
  
//+------------------------------------------------------------------+

void CloseSell()
  {
   int  total=OrdersTotal();
   for(int y=OrdersTotal()-1; y>=0; y--)
     {
      if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==magicalNumber)
           {
            ticket=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,Black);
           }
     }
     
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseBuy()
  {
   int  total=OrdersTotal();
   for(int y=OrdersTotal()-1; y>=0; y--)
     {
      if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==magicalNumber)
           {
            ticket=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,Black);
           }
     }
     
  }
  
 //*************************************************************************** 
  
  void OpenBuy()
  {
  
    double EMA_D5_1 = iMA(Symbol(),PERIOD_D1,5,0,MODE_EMA,PRICE_CLOSE,1);
   double EMA_D5_0 = iMA(Symbol(),PERIOD_D1,5,0,MODE_EMA,PRICE_CLOSE,0);
   double EMA_D20_0 = iMA(Symbol(),PERIOD_D1,20,0,MODE_EMA,PRICE_CLOSE,0);
   double EMA_D130_0 = iMA(Symbol(),PERIOD_MN1,6,0,MODE_EMA,PRICE_CLOSE,0);
    double  BuyLots=Lots;
     double SellLots=Lots;
    

  if ((EMA_D5_0 > EMA_D20_0) && (EMA_D5_0 > EMA_D5_1) && (EMA_D20_0 > EMA_D130_0))
    {
     BuyLots=Lots;
     SellLots=Lots;
    }

    if ((EMA_D5_0 < EMA_D20_0) && (EMA_D5_0 < EMA_D5_1) && (EMA_D20_0 < EMA_D130_0))
    {
     BuyLots=Lots;
     SellLots=Lots;
    }
 
 
   ticket=OrderSend(Symbol(),OP_BUY,BuyLots,Ask,slippage,Ask-StopL*Point,Ask+TakeProfit*Point,"BUY",magicalNumber,0,Green);   
           if (ticket>=0)
           {  
           
               if(OrderSelect(ticket,SELECT_BY_TICKET))
               {
              bool res=OrderModify(OrderTicket(),OrderOpenPrice(),Ask-StopL*Point,Ask+TakeProfit*Point,0,Blue);  
                          if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            else
               Print("Order modified successfully.");              
               }
           
           
           }
           
   }
   
  //*******************************************************************************
  
  void OpenSell()
  
  
  {
    double EMA_D5_1 = iMA(Symbol(),PERIOD_D1,5,0,MODE_EMA,PRICE_CLOSE,1);
   double EMA_D5_0 = iMA(Symbol(),PERIOD_D1,5,0,MODE_EMA,PRICE_CLOSE,0);
   double EMA_D20_0 = iMA(Symbol(),PERIOD_D1,20,0,MODE_EMA,PRICE_CLOSE,0);
   double EMA_D130_0 = iMA(Symbol(),PERIOD_MN1,6,0,MODE_EMA,PRICE_CLOSE,0);
  
  double  BuyLots=Lots;
     double SellLots=Lots;
    

  if ((EMA_D5_0 > EMA_D20_0) && (EMA_D5_0 > EMA_D5_1) && (EMA_D20_0 > EMA_D130_0))
    {
     BuyLots=Lots;
     SellLots=Lots;
    }

    if ((EMA_D5_0 < EMA_D20_0) && (EMA_D5_0 < EMA_D5_1) && (EMA_D20_0 < EMA_D130_0))
    {
     BuyLots=Lots;
     SellLots=Lots;
    }
 
  double ATR=iATR(NULL,0,20,0);
  
 ticket = OrderSend(Symbol(),OP_SELL,SellLots,Bid,slippage,Bid+StopL*Point,Bid-TakeProfit*Point,"SELL",magicalNumber,0,Green);
           if (ticket>=0)
           {  
           
               if(OrderSelect(ticket,SELECT_BY_TICKET))
               {
               bool res =OrderModify(OrderTicket(),OrderOpenPrice(),Bid+StopL*Point,Bid-TakeProfit*Point,0,Blue);   
                           if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            else
               Print("Order modified successfully.");             
               }
           
           
           }
           
           }
           
//**************************************************************

int Trail()

{

  
for(int cnt=0;cnt<OrdersTotal();cnt++)
     {
      bool ch = OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
                  if(!ch)
               Print("Error in OrderSelect. Error code=",GetLastError());
            else
               Print("Order selected successfully.");
      if( OrderSymbol()==Symbol() && OrderMagicNumber()==magicalNumber)
        
        {
         if(OrderType()==OP_BUY)
           {

            if(Trailing>0)
              {
               if(Bid-OrderOpenPrice()>Point*Trailing)
                 {
                  if(OrderStopLoss()<Bid-Point*Trailing)
                    {
                     bool res =OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*Trailing,OrderTakeProfit(),0,Green); return(0);
                                 if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            else
               Print("Order modified successfully.");
                    }
                 }
              }
           }
         if(OrderType()==OP_SELL)
           {
            if(Trailing>0)
              {
               if((OrderOpenPrice()-Ask)>(Point*Trailing))
                 {
                  if((OrderStopLoss()>(Ask+Point*Trailing)) || (OrderStopLoss()==0))
                    {
                     bool res = OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*Trailing,OrderTakeProfit(),0,Red); return(0);
                                 if(!res)
               Print("Error in OrderModify. Error code=",GetLastError());
            else
               Print("Order modified successfully.");
                    }
                 }
              }
           }
         }
       }


  return(0);
}
//--------------------------------------------------------------

void AutoLot()
{
   if(AutoLots == True)
   {
   double tickvalue = MarketInfo(Symbol(),MODE_TICKVALUE);
   
   Lots=MathRound(((AccountBalance()*percent*tickvalue)/StopL)*100)/100;
      if(Lots<0.01)
      {Lots=0.01;}
       if((AccountBalance()>=1.5*depotinit || AccountBalance()<=0.6*depotinit) && saving==true)
   {
   Lots=0.01;
   }
   //double tickvalue = MarketInfo(Symbol(),MODE_TICKVALUE*10);

   }
   
}

////////////////////////////////////////////////////////////////////////////

bool isPositionOpen()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==magicalNumber && OrderSymbol()==Symbol())
        {
         return true;
        }
     }
   return false;
   
   }

///////////////////////////

double Algo()
  {
   double a1 = iAC(Symbol(),PERIOD_W1 , 0);
   double a2 = iAC(Symbol(),PERIOD_D1 , 0);
   double a3 = iAC(Symbol(), PERIOD_H4, 0);
   
   
   return(x1 * a1 + x2 * a2 + x3 * a3);
  }
  
  //////////////////////////////////////////////////
  
  int IsMorningStar()
{int retval=0;

if(
    (Body(3) > Body(2)) &&  // Star body smaller than the previous one
    
    (Body(1) > Body(2)) && // Body of star smaller than bodies of first and last candles
    
    (Close[3] < Open[3]) && // First is a down candle
    
    (Close[1] > Open[1]) && // Third is an up candle
    
    (Close[1] > (BodyLo(3) + Body(3)*0.5)) // The third candle closes above the midpoint of the first candle
    
  )
  retval=1;

return (retval);

}

int IsEveningStar()
{int retval=0;

if(
    (Body(3) > Body(2)) &&  // Star body smaller than the previous one
    
    (Body(1) > Body(2)) && // Body of star smaller than bodies of first and last candles
    
    (Close[3] > Open[3]) && // First is an up candle
    
    (Close[1] < Open[1]) && // Third is a down candle
    
    (Close[1] < (BodyHi(3) - Body(3)*0.5)) // The third candle closes below the midpoint of the first candle
    
  )
  retval=1;

return (retval);

}

int IsBullishEngulfing()
{int retval=0;

if(

    (Close[2] < Open[2]) && // First is a down candle
    
    (Close[1] > Open[1]) && // Second is an up candle
    
    (Body(2) < Body(1)) // First engulfed by second

  )
  retval=1;

return (retval);

}

int IsBearishEngulfing()
{int retval=0;

if(

    (Close[2] > Open[2]) && // First is an up candle
    
    (Close[1] < Open[1]) && // Second is a down candle
    
    (Body(2) < Body(1)) // First engulfed by second

  )
  retval=1;

return (retval);

}

int IsDojiCandle()
{int retval=0;

if(
   (Body(1) < ((High[1] - Low[1])/iDoji))
  )
  retval=1;

return (retval);

}


double Body (int iCandle)
{ double CandleOpen, CandleClose;

CandleOpen=Open[iCandle];
CandleClose=Close[iCandle];

return (MathMax(CandleOpen, CandleClose)-(MathMin(CandleOpen, CandleClose)));
}


double BodyLo (int iCandle)
{
return (MathMin(Open[iCandle], Close[iCandle]));
}


double BodyHi (int iCandle)
{
return (MathMax(Open[iCandle], Close[iCandle]));
}

