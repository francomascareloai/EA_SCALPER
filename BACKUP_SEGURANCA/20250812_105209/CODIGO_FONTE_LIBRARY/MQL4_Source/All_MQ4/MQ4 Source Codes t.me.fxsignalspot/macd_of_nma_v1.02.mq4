//+------------------------------------------------------------------+
//|                                             MACD of NMA v1.0.mq4 |
//|                                          by brax64 for forex-tsd |
//+------------------------------------------------------------------+

#property copyright "brax64"
#property link      "www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 C'40,40,40'
#property indicator_color2 Gainsboro
#property indicator_color3 C'35,95,235'
#property indicator_color4 C'200,0,0'
#property indicator_color5 DimGray
#property indicator_color6 DarkOrange

#property indicator_style1 2
#property indicator_width2 1
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 3
#property indicator_width6 1


extern ENUM_APPLIED_PRICE  MACD_price = PRICE_CLOSE;
extern int            NMA_Fast        = 12;
extern int            NMA_Fast_sample = 6;
extern ENUM_MA_METHOD NMA_Fast_Mode   = MODE_LWMA;
extern int            NMA_Slow        = 26;
extern int            NMA_Slow_sample = 13;
extern ENUM_MA_METHOD NMA_Slow_Mode   = MODE_LWMA;
extern int            SignalSMA       = 9;
extern double         Magnifier       = 1.5;
extern bool           ShowArrows       = false;
extern string         arrowsIdentifier = "MACD_NMA arrows";
extern color          arrowsUpColor    = DeepSkyBlue;
extern color          arrowsDnColor    = Red;

double MACDLineBuffer[];
double SignalLineBuffer[];
double HistogramBufferUP[];
double HistogramBufferDN[];
double MACDHistoBuffer[];
double HistogramBuffer[];

//double alpha   = 0;
//double alpha_1 = 0;

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+

int deinit()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);

   SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexBuffer(0, MACDHistoBuffer);
   SetIndexStyle(1,DRAW_LINE);      SetIndexBuffer(1, SignalLineBuffer);  SetIndexLabel(1,"Signal");
   SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexBuffer(2, HistogramBufferUP);
   SetIndexStyle(3,DRAW_HISTOGRAM); SetIndexBuffer(3, HistogramBufferDN);
   SetIndexStyle(4,DRAW_LINE);      SetIndexBuffer(4, MACDLineBuffer);    SetIndexLabel(4,"MACD");
   SetIndexStyle(5,DRAW_LINE);      SetIndexBuffer(5, HistogramBuffer);

   IndicatorShortName("MACD of NMA v1.0 ("+NMA_Fast+","+NMA_Slow+","+SignalSMA+")");   


   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
{
   int limit,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);

	double alpha = 2.0 / (SignalSMA + 1.0);
	double alpha_1 = 1.0 - alpha;
   for(int i=limit; i>=0; i--)
   {
      MACDLineBuffer[i]    = iNma(iMA(NULL,0,1,0,MODE_SMA,MACD_price,i),NMA_Fast,NMA_Fast_sample,NMA_Fast_Mode,i,0) - 
                             iNma(iMA(NULL,0,1,0,MODE_SMA,MACD_price,i),NMA_Slow,NMA_Slow_sample,NMA_Slow_Mode,i,1);
      SignalLineBuffer[i]  = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
      MACDHistoBuffer[i]   = MACDLineBuffer[i];      
      HistogramBuffer[i]   = (MACDLineBuffer[i] - SignalLineBuffer[i]) * Magnifier;
      HistogramBufferUP[i] = EMPTY_VALUE;
      HistogramBufferDN[i] = EMPTY_VALUE;
           
      if (HistogramBuffer[i] > 0)
      
            HistogramBufferUP[i] = HistogramBuffer[i];
      else  HistogramBufferDN[i] = HistogramBuffer[i];
     
      manageArrow(i);
   }
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------

double iNma(double price, double period, double samplePeriod, int mode, int i, int id=0)
{
   double Lambda = period / samplePeriod;
       if(Lambda < 2.0)
       {
          Lambda = 2.0;
          samplePeriod = period / 2.0;
       }
   double Alpha  = Lambda * (period - 1.0) / (period - Lambda);

   double sample = iCustomMa(price ,period      ,mode,i,id*2+0);
   double Gamma  = iCustomMa(sample,samplePeriod,mode,i,id*2+1);
      return((Alpha+1.0)*sample - Alpha*Gamma);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------

#define _maWorkBufferx1 4
#define _maWorkBufferx2 8
#define _maWorkBufferx3 12
double iCustomMa(double price, double length, int mode, int i, int id=0)
{
   int r = Bars-i-1;
   switch (mode)
   {
      case 0  : return(iSma(price,length,r,id));
      case 1  : return(iEma(price,length,r,id));
      case 2  : return(iSmma(price,length,r,id));
      case 3  : return(iLwma(price,length,r,id));
      default : return(0);
   }
}

//------------------------------------------------------------------

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int id=0)
{
   if (ArrayRange(workSma,0)!= Bars) ArrayResize(workSma,Bars); id *= 2;

   workSma[r][id] = price;
   if (r>=period)
          workSma[r][id+1] = workSma[r-1][id+1]+(workSma[r][id]-workSma[r-period][id])/period;
   else
   {
      workSma[r][id+1] = 0;
      for(int k=0; k<period && (r-k)>=0; k++) workSma[r][id+1] += workSma[r-k][id];  
      workSma[r][id+1] /= k;
   }
   return(workSma[r][id+1]);
}

//------------------------------------------------------------------

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int id=0)
{
   if (ArrayRange(workEma,0)!= Bars) ArrayResize(workEma,Bars);

   double alpha = 2.0 / (1.0+period);
          workEma[r][id] = workEma[r-1][id]+alpha*(price-workEma[r-1][id]);
   return(workEma[r][id]);
}

//------------------------------------------------------------------

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int id=0)
{
   if (ArrayRange(workSmma,0)!= Bars) ArrayResize(workSmma,Bars);

   if (r<period) workSmma[r][id] = price;
   else  workSmma[r][id] = workSmma[r-1][id]+(price-workSmma[r-1][id])/period;
   return(workSmma[r][id]);
}

//------------------------------------------------------------------

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int id=0)
{
   if (ArrayRange(workLwma,0)!= Bars) ArrayResize(workLwma,Bars);

   workLwma[r][id] = price;
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][id];  
      }             
      return(sum/sumw);
}

//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------

void manageArrow(int i)
{
   if (ShowArrows)
   {
      deleteArrow(Time[i]);
      {
         if (HistogramBuffer[i] > 0) drawArrow(i,arrowsUpColor,241);
         else                        drawArrow(i,arrowsDnColor,242);
      }
   }
}               

void drawArrow(int i,color theColor,int theCode)
{
   
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i); 
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
  
         if       (HistogramBuffer[i] > 0 && HistogramBuffer[i+1] < 0)
                             ObjectSet(name,OBJPROP_PRICE1,Low[i]-gap);
         else if (HistogramBuffer[i] < 0 && HistogramBuffer[i+1] > 0)
                             ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
}

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
} 