//+------------------------------------------------------------------+
//|                                                  TTM scalper.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers  2
#property indicator_color1   Red
#property indicator_color2   Lime
#property indicator_width1   4
#property indicator_width2   4

//
//
//
//
//

double upBuffer[];
double dnBuffer[];
double trendBuffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(3);
   SetIndexBuffer(0,upBuffer); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,dnBuffer); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,trendBuffer);
   return(0);
}
int deinit() { return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define trendUp    1
#define trendDown -1

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         
            //
            //
            //
            //
            //
            
            for (k=3,i=limit;i<(Bars-1) && k>0;i++) if (dnBuffer[i]!=EMPTY_VALUE) k--;
                       limit = MathMax(limit,MathMin(Bars-1,i));
         
   //
   //
   //
   //
   //
            
   int swingBar;
   for(i=limit; i>=0; i--)
   {
      upBuffer[i] = EMPTY_VALUE;
      dnBuffer[i] = EMPTY_VALUE;
         if (i==Bars-1)
               trendBuffer[i] = 1;
         else  trendBuffer[i] = trendBuffer[i+1];
         
         //
         //
         //
         //
         //

         if (trendBuffer[i] == trendUp)
         {
            for (k=1; (i+k)<Bars; k++)
               if (upBuffer[i+k]!=EMPTY_VALUE && trendBuffer[i+k]==trendDown) break;
         
               //
               //
               //
               //
               //
            
               swingBar = swingHighBar(i,1,PRICE_HIGH,2,k);
               if (swingBar>-1)
               if (isLess(Close[i],Low[swingBar-1]) && isLess(High[iHighest(NULL,0,MODE_HIGH,swingBar-i,i)],High[swingBar]))
               { 
                  upBuffer[swingBar] = High[swingBar];
                  dnBuffer[swingBar] = Low[swingBar];
                  trendBuffer[i]     = trendDown;
                  continue;
               }
         }

      //
      //
      //
      //
      //
                  
         if (trendBuffer[i] == trendDown)
         {
            for (k=1;(i+k)<Bars;k++)
               if (dnBuffer[i+k]!=EMPTY_VALUE && trendBuffer[i+k]==trendUp) break;

               //
               //
               //
               //
               //
               
               swingBar = swingLowBar(i,1,PRICE_LOW,2,k);
               if (swingBar>-1)
               if (isGreater(Close[i],High[swingBar-1]) && isGreater(Low[iLowest(NULL,0,MODE_LOW,swingBar-i,i)],Low[swingBar]))
               {
                  dnBuffer[swingBar] = High[swingBar];
                  upBuffer[swingBar] = Low[swingBar];
                  trendBuffer[i]     = trendUp;
               }                  
         }               
   }
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

bool isLess(double first, double second)
{
   return(NormalizeDouble(first,Digits)<NormalizeDouble(second,Digits));
}
bool isGreater(double first, double second)
{
   return(NormalizeDouble(first,Digits)>NormalizeDouble(second,Digits));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int swingHighBar(int shift, int instance, int price, int strength, int length)
{
   double pivotPrice = 0; 
	int    pivotBar   = 0 ;

      pivot(shift, price, length, strength, strength, instance, 1, pivotPrice,  pivotBar);
      
   return(pivotBar);
}   
int swingLowBar(int shift, int instance, int price, int strength, int length)
{
   double pivotPrice = 0; 
	int    pivotBar   = 0 ;

      pivot(shift, price, length, strength, strength, instance, -1, pivotPrice,  pivotBar);
      
   return(pivotBar);
}   

//
//
//
//
//

int pivot(int shift, int price, int length, int leftStrength, int rightStrength, int instance, int hiLo, double& pivotPrice, int& pivotBar)
{
   double testPrice;
   double candidatePrice;
   bool   instanceTest = false;
   int    strengthCntr = 0;
   int    instanceCntr = 0;
   int    lengthCntr   = rightStrength;
   
   //
   //
   //
   //
   //
   
   while (lengthCntr<length && !instanceTest)
   {
      bool pivotTest = true;
      candidatePrice = iMA(NULL,0,1,0,MODE_SMA,price,shift+lengthCntr);
         
      //
      //
      //
      //
      //
            
      strengthCntr = 1;
      while (pivotTest && (strengthCntr <= leftStrength))
      {
         testPrice = iMA(NULL,0,1,0,MODE_SMA,price,shift+lengthCntr+strengthCntr);
         if ((hiLo== 1 && candidatePrice < testPrice) ||
             (hiLo==-1 && candidatePrice > testPrice))
               pivotTest    =  false;
         else  strengthCntr += 1;
      }
      strengthCntr = 1;
      while(pivotTest && (strengthCntr <= rightStrength))
      {
         testPrice = iMA(NULL,0,1,0,MODE_SMA,price,shift+lengthCntr-strengthCntr); 
         if ((hiLo== 1 && candidatePrice <= testPrice) ||
             (hiLo==-1 && candidatePrice >= testPrice))
               pivotTest    =  false;
         else  strengthCntr += 1;
      }
         
      //
      //
      //
      //
      //
         
      if (pivotTest) instanceCntr += 1;
      if (instanceCntr == instance)
            instanceTest = true;
      else  lengthCntr += 1;           
   }
   
   //
   //
   //
   //
   //
   
   if (instanceTest)
   {
      pivotPrice = candidatePrice;
      pivotBar   = shift+lengthCntr;
      return(1);
   }
   else
   {
      pivotPrice = -1;
      pivotBar   = -1;
      return(-1);
   }
}