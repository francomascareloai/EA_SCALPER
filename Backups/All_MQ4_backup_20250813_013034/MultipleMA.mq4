//+------------------------------------------------------------------+
//|                                                   MultipleMA.mq4 |
//|                          Copyright © 2006, Robert Hill aka MrPip |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, Robert Hill aka MrPip"

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 3
#property  indicator_color1  Red
#property  indicator_color2  Yellow
#property  indicator_color3  Green
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2
//---- indicator parameters

extern int FirstMA_Period=5;
extern int FirstMA_Mode = 1;   //0=sma, 1=ema, 2=smma, 3=lwma , 4=LSMA
extern int FirstMA_AppliedPrice = 0; // 0=close, 1=open, 2=high, 3=low, 4=median((h+l/2)), 5=typical((h+l+c)/3), 6=weighted((h+l+c+c)/4)
extern int SecondMA_Period=13;
extern int SecondMA_Mode = 1; //0=sma, 1=ema, 2=smma, 3=lwma
extern int ThirdMA_Period=62;
extern int ThirdMA_Mode = 1; //0=sma, 1=ema, 2=smma, 3=lwma
//---- indicator buffers
double MA1[];
double MA2[];
double MA3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexDrawBegin(0,ThirdMA_Period);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,MA1) &&
      !SetIndexBuffer(1,MA2) &&
      !SetIndexBuffer(2,MA3))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MultipleMA("+FirstMA_Period+","+SecondMA_Period+","+ThirdMA_Period+")");
//---- initialization done
   return(0);
  }

//+------------------------------------------------------------------------+
//| LSMA - Least Squares Moving Average function calculation               |
//| LSMA_In_Color Indicator plots the end of the linear regression line    |
//| Modified to use any timeframe                                          |
//+------------------------------------------------------------------------+

double LSMA(int Rperiod,int prMode, int TimeFrame, int mshift)
{
   int i;
   double sum, price;
   int length;
   double lengthvar;
   double tmp;
   double wt;

   length = Rperiod;
 
   sum = 0;
   for(i = length; i >= 1  ; i--)
   {
     lengthvar = length + 1;
     lengthvar /= 3;
     tmp = 0;
     switch (prMode)
     {
     case 0: price = iClose(NULL,TimeFrame,length-i+mshift);break;
     case 1: price = iOpen(NULL,TimeFrame,length-i+mshift);break;
     case 2: price = iHigh(NULL,TimeFrame,length-i+mshift);break;
     case 3: price = iLow(NULL,TimeFrame,length-i+mshift);break;
     case 4: price = (iHigh(NULL,TimeFrame,length-i+mshift) + iLow(NULL,TimeFrame,length-i+mshift))/2;break;
     case 5: price = (iHigh(NULL,TimeFrame,length-i+mshift) + iLow(NULL,TimeFrame,length-i+mshift) + iClose(NULL,TimeFrame,length-i+mshift))/3;break;
     case 6: price = (iHigh(NULL,TimeFrame,length-i+mshift) + iLow(NULL,TimeFrame,length-i+mshift) + iClose(NULL,TimeFrame,length-i+mshift) + iClose(NULL,TimeFrame,length-i+mshift))/4;break;
     }
     tmp = ( i - lengthvar)*price;
     sum+=tmp;
    }
    wt = sum*6/(length*(length+1));
    
    return(wt);
}

//+------------------------------------------------------------------+
//| CheckValidUserInputs                                             |
//| Check if User Inputs are valid for ranges allowed                |
//| return true if invalid input, false otherwise                    |
//| Also display an alert for invalid input                          |
//+------------------------------------------------------------------+
bool CheckValidUserInputs()
{
   if (CheckMAMethod(FirstMA_Mode, 0, 4))
   {
     Alert("FirstMA_Mode requires a value from 0 to 4."," You entered ",FirstMA_Mode);
     return(true);
   }
   if (CheckMAMethod(SecondMA_Mode, 0, 3))
   {
     Alert("SecondMA_Mode requires a value from 0 to 3."," You entered ",SecondMA_Mode);
     return(true);
   }
   if (CheckMAMethod(ThirdMA_Mode, 0, 3))
   {
     Alert("ThirdMA_Mode requires a value from 0 to 3."," You entered ",ThirdMA_Mode);
     return(true);
   }   
}

//+------------------------------------------------+
//| Check for valid Moving Average methods         |
//|  0=sma, 1=ema, 2=smma, 3=lwma , 4=lsma         |
//|  return true if invalid, false if OK           |
//+------------------------------------------------+
bool CheckMAMethod(int method, int low_val, int high_val)
{
   if (method < low_val) return (true);
   if (method > high_val) return (true);
   return(false);
}

//+------------------------------------------------------------------+
//| Multiple Moving Averages                                         |
//+------------------------------------------------------------------+
int start()
  {
   int i,limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
   if (CheckValidUserInputs()) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=limit; i>=0; i--)
   if (FirstMA_Mode == 4)
   {
     MA1[i] = LSMA(FirstMA_Period,FirstMA_AppliedPrice,0,i);
   }
   else
   {
      MA1[i]=iMA(NULL,0,FirstMA_Period,0,FirstMA_Mode,FirstMA_AppliedPrice,i);
   }
   for(i=limit; i>=0; i--)
      MA2[i] = iMAOnArray(MA1,Bars,SecondMA_Period,0,SecondMA_Mode,i);
   for(i=limit; i>=0; i--)
      MA3[i] = iMAOnArray(MA2,Bars,ThirdMA_Period,0,ThirdMA_Mode,i);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

