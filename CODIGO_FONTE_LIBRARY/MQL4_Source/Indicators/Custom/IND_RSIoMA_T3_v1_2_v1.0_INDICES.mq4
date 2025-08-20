//+------------------------------------------------------------------+
//|                                                    RSIoMA_T3.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description " E-Mail:40468962@qq.com "
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow   //RSI

#property indicator_level1 70
#property indicator_level2 30


#property indicator_level3  50


//----

extern int  RSI_Period=10;
extern int  MA_Period=10;
extern int smooth=10; 
extern int T3_Period = 5;
extern double T3_Curvature = 0.618; //0.618

double RSI[];
double MA_Array[];
double t3Array[];


double ExtBuffer1[];
double ExtBuffer2[];
double ExtBuffer3[];
double ExtBuffer4[];
double ExtBuffer5[];
double ExtBuffer6[];
double StepBuffer[];


double e1,e2,e3,e4,e5,e6;
double c1,c2,c3,c4;
double n,w1,w2,b2,b3;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators setting
   IndicatorBuffers(10); 

   SetIndexStyle(0,DRAW_LINE);  
   SetIndexBuffer(0,StepBuffer);  

   SetIndexStyle(1,DRAW_LINE);  
   SetIndexBuffer(1,ExtBuffer5);   
   SetIndexLabel(1,"RSIoMA_T3");   

   SetIndexStyle(2,DRAW_LINE); //RSI   
   SetIndexBuffer(2,t3Array);
      
   SetIndexStyle(3,DRAW_LINE);  
   SetIndexBuffer(3,ExtBuffer2);   
   
   SetIndexStyle(4,DRAW_LINE);  
   SetIndexBuffer(4,ExtBuffer3); 
   
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,1); //EMA10
   SetIndexBuffer(5,MA_Array);
     
   SetIndexStyle(6,DRAW_NONE); //RSI
   SetIndexBuffer(6,RSI);   
    
   SetIndexStyle(7,DRAW_LINE);  
   SetIndexBuffer(7,ExtBuffer4);
   
   SetIndexStyle(8,DRAW_LINE);  
   SetIndexBuffer(8,ExtBuffer1);  
   
   SetIndexBuffer(9,ExtBuffer6); 
                 
//----
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   //IndicatorShortName("RSIoMA_T3");
   IndicatorShortName("RSIoMA_T3_v1.2  ("+IntegerToString(RSI_Period)+",  "+IntegerToString(MA_Period)+",  "+IntegerToString(smooth)+",  "+IntegerToString(T3_Period)+",  "+T3_Curvature+")");

 
//-------------  
e1=0; e2=0; e3=0; e4=0; e5=0; e6=0;
c1=0; c2=0; c3=0; c4=0;
n=0;
w1=0; w2=0;
b2=0; b3=0;

b2=T3_Curvature*T3_Curvature;
b3=b2*T3_Curvature;
c1=-b3;
c2=(3*(b2+b3));
c3=-3*(2*b2+T3_Curvature+b3);
c4=(1+3*T3_Curvature+b3+3*b2);
n=T3_Period;

if (n<1) n=1;
n = 1 + 0.5*(n-1);
w1 = 2 / (n + 1);
w2 = 1 - w1;   
   
//------- 
  
   return(0);
  }
//-------------  
int deinit() 
{

   ObjectDelete("a label");  
   return (0);
}  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
  int TextSize=20;
  color TextColor1=Yellow;
  
  
   if(ObjectFind("a label") != 0)
   {
      ObjectCreate("a label", OBJ_LABEL, 0,0,0);
      ObjectSetText("a label","Yexf_RSIoMA_T3_indicator " , TextSize, "Arial", TextColor1);
      ObjectSet("a label", OBJPROP_XDISTANCE,380);
     ObjectSet("a label", OBJPROP_YDISTANCE,0);
   } 
  
  
   int i;
   double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
   int counted_bars=IndicatorCounted();    
   if(counted_bars<0) return(-1); 
   if(counted_bars>0) counted_bars-- ;  
   
     
   int limit=MathMin(Bars-counted_bars+7,Bars-1);
   
   
   
   //+------------------------------------------------------------------+
   //| RSI                                                              |
   //+------------------------------------------------------------------+
     for(i=limit; i>=0; i--)
     {
       int y = iBarShift(NULL,0,Time[i]);
      RSI[i]= iRSI(NULL,0,RSI_Period,6,y);
     }
   //+------------------------------------------------------------------+
   //| EMA 10 & 30                                                      |
   //+------------------------------------------------------------------+
     for(i=limit; i>=0; i--)
     {
       y = iBarShift(NULL,0,Time[i]);
      //MA_Array[i]=iMAOnArray(RSI,Bars,MA_Period,0,2,i);   
      MA_Array[i]=iMAOnArray(RSI,0,MA_Period,0,2,i);      
     }
     
    for(i=Bars-1; i>=0; i--)
    {
      
      e1 = w1*MA_Array[i] + w2*e1;
      e2 = w1*e1 + w2*e2;
      e3 = w1*e2 + w2*e3;
      e4 = w1*e3 + w2*e4;
      e5 = w1*e4 + w2*e5;
      e6 = w1*e5 + w2*e6;

      t3Array[i]=c1*e6 + c2*e5 + c3*e4 + c4*e3;      
    }     
//------------------------    
   for(i=limit; i>=0; i--)
   {
      double sum  = 0;
      double sumw = 0;

      //for(int k=1; k<smooth && (i+k)<Bars; k++)
      for(int k=1; k<smooth && (i+k)<Bars-1; k++)
      {
         double weight = smooth-k;
                sumw  += weight; 
                sum   += weight*t3Array[i+k];
      }             
      if (sumw!=0)
            ExtBuffer1[i] = sum/sumw;
      else  ExtBuffer1[i] = 0;
   }    
//---------
   for(i=0; i<=limit; i++)
   {
     double sum2  = 0;
     double sumw2 = 0;

      for(k=0; k<smooth && (i-k)>=0; k++)
      {
         weight = smooth-k;
                sumw2  += weight;
                sum2   += weight*ExtBuffer1[i-k];
                
      }             
      if (sumw2 !=0)
            ExtBuffer2[i] = sum2/sumw2 ;
      else  ExtBuffer2[i] = 0;
   } 
//------------
   for(i=0; i<=limit; i++)
   {
     double sum3  = 0;
     double sumw3 = 0;

      for(k=0; k<smooth && (i-k)>=0; k++)
      {
         weight = smooth-k;
                sumw3  += weight;
                sum3   += weight*ExtBuffer2[i-k];
      }             
      if (sumw3 !=0)
            ExtBuffer3[i] = sum3/sumw3 ;
      else  ExtBuffer3[i] = 0;
   } 
//-----------
   for(i=0; i<=limit; i++)
   {
     double sum4  = 0;
     double sumw4 = 0;

      for(k=0; k<smooth && (i-k)>=0; k++)
      {
         weight = smooth-k;
                sumw4  += weight;
                sum4   += weight*ExtBuffer3[i-k];
      }             
      if (sumw4 !=0)
            ExtBuffer4[i] = sum4/sumw4 ;
      else  ExtBuffer4[i] = 0;
   } 
//--------------------
   for(i=0; i<=limit; i++)
   {
     double sum5  = 0;
     double sumw5 = 0;

      for(k=0; k<smooth && (i-k)>=0; k++)
      {
         weight = smooth-k;
                sumw5  += weight;
                sum5   += weight*ExtBuffer4[i-k];
      }             
      if (sumw5 !=0)
            ExtBuffer5[i] = sum5/sumw5 ;
      else  ExtBuffer5[i] = 0;
   } 
//-----------------
   for(i=0; i<=limit; i++)
   {
     double sum6  = 0;
     double sumw6 = 0;

      for(k=0; k<smooth && (i-k)>=0; k++)
      {
         weight = smooth-k;
                sumw6  += weight;
                sum6   += weight*ExtBuffer5[i-k];
      }             
      if (sumw6 !=0)
            ExtBuffer6[i] = sum6/sumw6 ;
      else  ExtBuffer6[i] = 0;
   } 

//-----------------
   for(i=limit; i>=0; i--)
   {
     
     StepBuffer[i] = ExtBuffer6[i+1];
    
   }

//-----------------
   WindowRedraw();
   RefreshRates();

   return(0);
  }
//+------------------------------------------------------------------+