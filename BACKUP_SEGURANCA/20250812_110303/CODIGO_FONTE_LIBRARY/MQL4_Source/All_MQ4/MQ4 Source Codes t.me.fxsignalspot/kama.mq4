//+------------------------------------------------------------------+
//|                              Kaufman Adaptive Moving Average.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1 
#property indicator_color1 LightSeaGreen 
//---- input parameters 
extern int periodAMA=20; 
extern int PriceType=4;
extern int nfast=2; 
extern int nslow=30; 
extern double  PctFilter         = 0;  //Dynamic filter in decimal
//PRICE_CLOSE 0  
//PRICE_OPEN 1 
//PRICE_HIGH 2 
//PRICE_LOW 3 
//PRICE_MEDIAN 4  (high+low)/2 
//PRICE_TYPICAL 5 (high+low+close)/3 
//PRICE_WEIGHTED 6  (high+low+close+close)/4 

//---- buffers 
double kAMAbuffer[]; 
double     Del[];

double dSC,slowSC,fastSC; 
double noise,signal,ER; 
double ERSC,SSC,Price; 
bool fc;

//+------------------------------------------------------------------+ 
//| Custom indicator initialization function | 
//+------------------------------------------------------------------+ 
int init() { 
   //---- indicators 
   IndicatorBuffers(2);
   SetIndexBuffer(0,kAMAbuffer); 
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexLabel(0,"KAMA");
   SetIndexDrawBegin(0,periodAMA);
   SetIndexBuffer(1,Del);
   IndicatorDigits(6);
   
   slowSC=(2.0 /(nslow+1)); 
   fastSC=(2.0 /(nfast+1)); 
   dSC=(fastSC-slowSC); 
   fc=true;
   //---- 
   return(0); 
} 
//+------------------------------------------------------------------+ 
//| Custom indicator deinitialization function | 
//+------------------------------------------------------------------+ 
int deinit() { 
   return(0); 
} 
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function | 
//+------------------------------------------------------------------+ 
int start() { 
   int i, limit, pos=1, countedbars=IndicatorCounted();

   if (Bars<=periodAMA+2) return(0); 
   if(countedbars<0) return(-1);
   if (countedbars>0) countedbars--;
   if (fc==true) {
      limit=(Bars-periodAMA-countedbars);
      kAMAbuffer[limit+1]=(High[limit+1]+Low[limit+1])/2;
   }
   else limit=Bars-countedbars;
   
   for (pos=limit; pos>=0; pos--){ 
      signal=MathAbs(((High[pos]+Low[pos])/2)-((High[pos+periodAMA]+Low[pos+periodAMA])/2)); 
      noise=0; 
      for(i=0;i<periodAMA;i++) { 
         noise=noise+MathAbs(((High[pos+i]+Low[pos+i])/2)-((High[pos+i+1]+Low[pos+i+1])/2)); 
      } 
      if (noise!=0) ER =signal/noise; //Efficiency Ratio
      ERSC=ER*dSC; 
      SSC=ERSC+slowSC;
      SSC=MathPow(SSC,2); //Smoothing Factor
 //      Price=(High[pos]+Low[pos])/2; //Price Median
      kAMAbuffer[pos]=kAMAbuffer[pos+1]+SSC*(Price(pos)-kAMAbuffer[pos+1]);
       
      if(PctFilter>0){
         Del[pos] = MathAbs(kAMAbuffer[pos] - kAMAbuffer[pos+1]);

         double sumdel=0;
         for (int j=0; j<periodAMA; j++) sumdel += Del[pos+j];
         double AvgDel = sumdel/periodAMA;
   
         double sumpow = 0;
         for (j=0; j<periodAMA; j++) sumpow += MathPow(Del[j+pos]-AvgDel,2);
         double StdDev = MathSqrt(sumpow/periodAMA); 
     
         double Filter = PctFilter * StdDev;
         if( MathAbs(kAMAbuffer[pos]-kAMAbuffer[pos+1]) < Filter ) kAMAbuffer[pos]=kAMAbuffer[pos+1];
      }
      fc=false;
   } 
   return(0); 
} 
//+------------------------------------------------------------------+
//| Price Function                                                 |
//+------------------------------------------------------------------+
double Price(int shift){
   double res;
   switch (PriceType){
      case PRICE_OPEN: res=Open[shift]; break;
      case PRICE_HIGH: res=High[shift]; break;
      case PRICE_LOW: res=Low[shift]; break;
      case PRICE_MEDIAN: res=(High[shift]+Low[shift])/2.0; break;
      case PRICE_TYPICAL: res=(High[shift]+Low[shift]+Close[shift])/3.0; break;
      case PRICE_WEIGHTED: res=(High[shift]+Low[shift]+2*Close[shift])/4.0; break;
      default: res=Close[shift];break;
   }
   return(res);
}

