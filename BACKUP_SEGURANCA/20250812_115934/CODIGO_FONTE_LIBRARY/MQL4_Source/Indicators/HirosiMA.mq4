#property link      "@TUNDRA LABORATORY@"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 SteelBlue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

extern int Length=14;
extern int Method=0;     // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
                      
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
                         
extern int Mode=1;       // Type of normalization
                         // 0 - Normalization
                         // 1 - Period Normalization
                         // 2 - Period Anchored
                         // 3 - Period Anchored with Normalization

double MA[], IMA[];
double St_IMA[];

int init()
{
 IndicatorShortName("MA");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MA);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,IMA);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,St_IMA);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-Length;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);
  pos--;
 } 
 
 double Min1, Max1, Min2, Max2;
 int i;
 pos=limit;
 while(pos>=0)
 {
  if (Mode==0)
  {
   if (pos==0)
   {
    Min1=MA[ArrayMinimum(MA, Bars-Length, 0)];
    Max1=MA[ArrayMaximum(MA, Bars-Length, 0)];
    for (i=limit;i>=0;i--)
    {
     IMA[i]=Max1+Min1-MA[i];
    }
   }
  }
  else
  {
   if (Mode==1)
   {
    Min1=MA[ArrayMinimum(MA, Length, pos)];
    Max1=MA[ArrayMaximum(MA, Length, pos)];
    for (i=Length-1;i>=0;i--)
    {
     IMA[pos+i]=Max1+Min1-MA[pos+i];
    }
   }
   else
   {
    if (Mode==2)
    {
     IMA[pos]=2*MA[pos+Length]-MA[pos];
    }
    else
    {
     St_IMA[pos]=2*MA[pos+Length]-MA[pos];
     Min1=MA[ArrayMinimum(MA, Length, pos)];
     Max1=MA[ArrayMaximum(MA, Length, pos)];
     Min2=St_IMA[ArrayMinimum(St_IMA, Length, pos)];
     Max2=St_IMA[ArrayMaximum(St_IMA, Length, pos)];
//     Print(Min1, " ", Max1, " ", Min2, " ", Max2);
     for (i=Length-1;i>=0;i--)
     {
      IMA[pos+i]=Min1+(Max1-Min1)*(St_IMA[pos+i]-Min2)/(Max2-Min2);
     }
    }
   }
  }
  pos--;
 }
   
 return(0);
}

