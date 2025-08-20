//+------------------------------------------------------------------+
//|                                                        TmaX2.mq4 |
//|                                           Copyright 2019, Pacois |
//|                                        https://forex-station.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Pacois"
#property link      "https://forex-station.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers    2
#property indicator_color1     clrAqua
#property indicator_width1 2
#property indicator_color2     clrMagenta   // Gold
#property indicator_width2 2

  
extern int    HalfLength       = 9;//3 default
extern int    Per       = 1;
extern ENUM_MA_METHOD        MODE          =MODE_SMA;
extern ENUM_APPLIED_PRICE    Price            = PRICE_MEDIAN;


extern bool   Interpolate     = true;

extern int    LineSize1       = 4 ;
extern ENUM_LINE_STYLE   LineStyle1      = 0 ;


extern int    CountBars       = 500 ;



string IndicatorFileName;
bool   calculating;
bool   gettingBars;
int    timeFrame;

int gi_PipsDecimal;
string       shortName_CCI2   = "TMA" ;

double buffer1[];
double buffer2[];

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(6);
   HalfLength=MathMax(HalfLength,1);
   
   SetIndexStyle (0, DRAW_LINE );  //, LineStyle1, LineSize1
   SetIndexBuffer(0, buffer1);
   SetIndexStyle (1, DRAW_LINE);
   SetIndexBuffer(1, buffer2);
 

      IndicatorFileName = WindowExpertName();
      
     IndicatorShortName("AATTMM"); 
   //IndicatorShortName(timeFrameToString(timeFrame)+" TMA bands )"+HalfLength+")");
  
//=================================================      
   
   return(0);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int deinit() 
    { 
       return(0);
    }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
   int i,j,k,limit;
   
     SetIndexDrawBegin(0,Bars-CountBars);
     SetIndexDrawBegin(1,Bars-CountBars);
   
     
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-1,Bars-counted_bars+HalfLength);
       //     if (returnBars)  { buffer1[0] = limit+1; return(0); }
       
//============================================================================================
 
   {
     { for (i=limit; i>=0; i--)
      {
         double sum  = (HalfLength+1)*iMA(NULL,0,Per,0,MODE,Price,i);
         double sumw = (HalfLength+1);
                
         for(j=1, k=HalfLength; j<=HalfLength; j++, k--)
         {
            sum  += k*iMA(NULL,0,Per,0,MODE,Price,i+j);
            sumw += k;

            if (j<=i)
            {
               sum  += k*iMA(NULL,0,Per,0,MODE,Price,i-j);
               sumw += k;
            }          
        } 
              buffer1[i] = sum/sumw;
              
  }  } 

//==================================================================================================================       
 { for (i=limit; i>=0; i--)
   {   buffer2[i] = EMPTY_VALUE;
      
      if   ( buffer1[i + 1] < buffer1[i] )  {buffer2[i + 1] = buffer2[i + 1];
                                                 buffer2[i] = buffer2[i];
                                            }
     else 
          {  if  (buffer1[i + 1] > buffer1[i])
                 {   if (buffer2[i + 1] == EMPTY_VALUE) buffer2[i + 1] = buffer1[i + 1];
                                                         buffer2[i] = buffer1[i];
   }      }      }   
  
  }
  }
//=========================================================================================== 
  
   return(0);
}

//=============================================================================================

