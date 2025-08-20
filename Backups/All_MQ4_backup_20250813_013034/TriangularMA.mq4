//+------------------------------------------------------------------+
//|                                                          TMA.mq4 |
//|                                                     Matias Romeo |
//|                                    mailto:matias.romeo@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Matias Romeo"
#property link      "mailto:matias.romeo@gmail.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Green

//Input parameters
extern int       Periods=30;
extern int       ApplyTo=0;

//Apply To like "Applied price enumeration"
//0 Close price. 
//1 Open price. 
//2 High price. 
//3 Low price. 
//4 Median price, (high+low)/2. 
//5 Typical price, (high+low+close)/3. 
//6 Weighted close price, (high+low+close+close)/4

//Indicator buffers
double tma[];

//Global variables
int    weights[];
double divisor;

int init()
{
  SetIndexStyle(0,DRAW_LINE);
  SetIndexBuffer(0,tma);

  IndicatorShortName( "TMA(" + Periods + ")" );

  //Calculate weigths
  ArrayResize(weights,Periods);

  double dPeriods = Periods;
  int to=MathCeil(dPeriods/2.0);

  for(int i=0; i<to; i++)
  {
    weights[i]            = i+1;
    weights[Periods-1-i]  = i+1;
  }

  divisor = 0.0;
  for(int j=0; j<Periods; j++)
    divisor += weights[j];

  return(0);
}

int deinit()
{
  return(0);
}
int start()
{
  int    counted_bars = IndicatorCounted();
  if( counted_bars < 0 )
    return(-1);
  
  //Recalculate last bar
  if( counted_bars > 0 )
    counted_bars++;
  
  int limit = Bars - counted_bars;
  for(int i=limit-1; i>=0; i--)
  {
    double tma_val = 0.0;
    for(int j=0; j<Periods; j++)
    {
      double price = getPrice(ApplyTo, i+Periods-j);
      tma_val += price*weights[j];
    }

    tma[i] = tma_val/divisor;
  }
  
  return(0);
}

double getPrice(int priceType, int index)
{
  double price = 0.0;
  
  switch(priceType)
  {
    case PRICE_OPEN    : price = Open[index];
                         break;
  
    case PRICE_HIGH    : price = High[index];
                         break;
  
    case PRICE_LOW     : price = Low[index];
                         break;
  
    case PRICE_MEDIAN  : price = (High[index]+Low[index])/2.0;
                         break;
  
    case PRICE_TYPICAL : price = (High[index]+Low[index]+Close[index])/3.0;
                         break;

    case PRICE_WEIGHTED: price = (High[index]+Low[index]+2*Close[index])/4.0;
                         break;

    
    case PRICE_CLOSE   : 
    default            : price = Close[index];
                         break;

  }
  
  return(price);
}
//+------------------------------------------------------------------+