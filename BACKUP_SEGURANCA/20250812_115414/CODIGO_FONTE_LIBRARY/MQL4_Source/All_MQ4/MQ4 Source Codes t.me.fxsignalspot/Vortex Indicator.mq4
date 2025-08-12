//+------------------------------------------------------------------+
//|                                            Vortex Indicator.mq4  |
//|                      Copyright © 2014, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

//---- Input parameters
extern int VI_Length=28;

//---- Buffers
double PlusVI[];        //VI+ : + Vortex Indicator buffer
double MinusVI[];       //VI- : - Vortex Indicator buffer
double PlusVM[];        //VM+ : + Vortex Movement buffer
double MinusVM[];       //VM- : - Vorext Movement buffer
double SumPlusVM[];     //Sum of VI_Length PlusVM values
double SumMinusVM[];    //Sum of VI_Length MinusVM values
double SumTR[];         //True Range buffer
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//----
    IndicatorBuffers(7);
    IndicatorDigits(Digits);
//---- Set visible buffer properties    
    SetIndexBuffer(0,PlusVI);
    SetIndexBuffer(1,MinusVI);
    SetIndexStyle(0,DRAW_LINE);    
    SetIndexStyle(1,DRAW_LINE);
    SetIndexLabel(0,"PlusVI(" + VI_Length + ")");
    SetIndexLabel(1,"MinusVI(" + VI_Length + ")");
    SetIndexDrawBegin(0,VI_Length);
    SetIndexDrawBegin(1,VI_Length);
//---- Set indices of caching buffers
    SetIndexBuffer(2,PlusVM);
    SetIndexBuffer(3,MinusVM);
    SetIndexBuffer(4,SumPlusVM);
    SetIndexBuffer(5,SumMinusVM);
    SetIndexBuffer(6,SumTR);
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----
   
//----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
    int Limit;
    int CountedBars = IndicatorCounted();
//---- Check for possible errors
    if(CountedBars < 0) return(-1);
//---- Last counted bar will be recounted
    if(CountedBars > 0) CountedBars--;
    Limit = Bars - CountedBars;
//---- Clear caching buffers
    for(int i = 0; i < Limit; i++)
    {
      SumPlusVM[i] = 0;
      SumMinusVM[i] = 0;
      SumTR[i]= 0;  
    }
//---- Store the values of PlusVM and MinusVM
    for(i = 0; i < Limit; i++)
    {
        //PlusVM = |Today's High - Yesterday's Low|
        PlusVM[i] = MathAbs(High[i] - Low[i + 1]);
        //MinusVM = |Today's Low - Yesterday's High|
        MinusVM[i] = MathAbs(Low[i] - High[i +1]);  
    }
//---- Sum VI_Length values of PlusVM, MinusVM and the True Range
    for(i = 0; i < Limit; i++)
    {
        for(int j = 0; j <= VI_Length - 1; j++)
        {
           SumPlusVM[i] += PlusVM[i + j];
           SumMinusVM[i] += MinusVM[i + j];
           SumTR[i] += iATR(NULL,0,1,i + j); //Sum VI_Length values of the True Range by using a 1-period ATR
        }
    }
//---- Draw the indicator
    for(i = 0; i < Limit; i++)
    {
        PlusVI[i] = SumPlusVM[i] / SumTR[i];
        MinusVI[i] = SumMinusVM[i] / SumTR[i];
    }
//----
    return(0);
}
//+------------------------------------------------------------------+