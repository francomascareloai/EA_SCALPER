//+------------------------------------------------------------------+
//|                                                  BB_Analyzer.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 15
#property indicator_chart_window

enum e_method{ SMA        =  1,
               EMA        =  2,
               Wilder     =  3,
               LWMA       =  4,
               SineWMA    =  5,
               TriMA      =  6,
               LSMA       =  7,
               SMMA       =  8,
               HMA        =  9,
               ZeroLagEMA = 10,
               ITrend     = 11,
               Median     = 12,
               GeoMean    = 13,
               REMA       = 14,
               ILRS       = 15,
               IE_2       = 16,
               TriMAgen   = 17
             };

extern int      Periods                 = 20;
extern double   Deviation               = 2.0;
input  e_method Method_to_Smooth        = EMA;
extern int      Periods_to_Smooth       = 3;
extern string   Comment0                = "- Slope: Minimum Slope to Confirm Bubble (pip/minute) -";
extern double   Slope                   = 0.18;
extern string   Comment1                = "- Percent: To Confirm end of sausage (%) -";
extern double   Percent                 = 25;
extern bool     Show_BB_Middle_Line     = true;
extern double   Slope_Detection         = 0.5;
extern int      Bars_to_Calculate_Slope = 1;

extern color    Color_Bands             = clrDarkGoldenrod;
extern color    Color_Middle            = clrWhite;
extern color    Color_Middle_Up         = clrLime;
extern color    Color_Middle_Dn         = clrRed;
extern color    Color_Bubble_Up         = clrDarkGreen;
extern color    Color_Bubble_Down       = clrRed;
extern color    Color_Sausage_Up        = clrTeal;
extern color    Color_Sausage_Down      = clrMaroon;
extern color    Color_Squeeze           = C'33,33,33';

double BB_Top[];
double BB_Middle[];
double BB_Bottom[];

double AVG_Top[];
double AVG_Middle[];
double AVG_Bottom[];

double Middle_Up[];
double Middle_Dn[];

double Bubble_Up_min[];  double Bubble_Up_max[];
double Bubble_Dn_min[];  double Bubble_Dn_max[];
double Sausage_Up_min[]; double Sausage_Up_max[];
double Sausage_Dn_min[]; double Sausage_Dn_max[];
double Squeeze_min[];    double Squeeze_max[];

double Signal_AVG_Top[];
double Signal_AVG_Bottom[];

bool StartBubbleUp  = false; 
bool StopBubbleUp   = false;
bool StartBubbleDn  = false;
bool StopBubbleDn   = false;
bool StartSausageUp = false;
bool StartSausageDn = false;

int init(){
   
   IndicatorShortName("BB Analyzer");
   
   IndicatorBuffers(20);
   
   if (Show_BB_Middle_Line) int Middle_Draw = DRAW_LINE; else Middle_Draw = DRAW_NONE;
   
   SetIndexStyle(0,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Sausage_Up);
   SetIndexBuffer(0,Sausage_Up_min);
   SetIndexLabel(0,"Sausage Up");
   
   SetIndexStyle(1,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Sausage_Up);
   SetIndexBuffer(1,Sausage_Up_max);
   SetIndexLabel(1,"Sausage Up");
   
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Sausage_Down);
   SetIndexBuffer(2,Sausage_Dn_min);
   SetIndexLabel(2,"Sausage Down");
   
   SetIndexStyle(3,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Sausage_Down);
   SetIndexBuffer(3,Sausage_Dn_max);
   SetIndexLabel(3,"Sausage Down");
   
   SetIndexStyle(4,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Bubble_Up);
   SetIndexBuffer(4,Bubble_Up_min);
   SetIndexLabel(4,"Bubble Up");
   
   SetIndexStyle(5,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Bubble_Up);
   SetIndexBuffer(5,Bubble_Up_max);
   SetIndexLabel(5,"Bubble Up");
   
   SetIndexStyle(6,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Bubble_Down);
   SetIndexBuffer(6,Bubble_Dn_min);
   SetIndexLabel(6,"Bubble Down");
   
   SetIndexStyle(7,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Bubble_Down);
   SetIndexBuffer(7,Bubble_Dn_max);
   SetIndexLabel(7,"Bubble Down");
   
   SetIndexStyle(8,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Squeeze);
   SetIndexBuffer(8,Squeeze_min);
   SetIndexLabel(8,"Squeeze");
   
   SetIndexStyle(9,DRAW_HISTOGRAM, STYLE_SOLID, 4, Color_Squeeze);
   SetIndexBuffer(9,Squeeze_max);
   SetIndexLabel(9,"Squeeze");
   
   SetIndexBuffer(10,AVG_Top);
   SetIndexStyle(10,DRAW_LINE,STYLE_SOLID,2,Color_Bands);
   SetIndexLabel(10,"BB Top");
   
   SetIndexBuffer(11,AVG_Bottom);
   SetIndexStyle(11,DRAW_LINE,STYLE_SOLID,2,Color_Bands);
   SetIndexLabel(11,"BB Bottom");
   
   SetIndexBuffer(12,AVG_Middle);
   SetIndexStyle(12,DRAW_LINE,STYLE_SOLID,2,Color_Middle);
   SetIndexLabel(12,"BB Middle");
   
   SetIndexBuffer(13,Middle_Up);
   SetIndexStyle(13,Middle_Draw,STYLE_SOLID,2,Color_Middle_Up);
   SetIndexLabel(13,"BB Middle Up");
   
   SetIndexBuffer(14,Middle_Dn);
   SetIndexStyle(14,Middle_Draw,STYLE_SOLID,2,Color_Middle_Dn);
   SetIndexLabel(14,"BB Middle Down");
   
   SetIndexBuffer(15,BB_Top);
   SetIndexBuffer(16,BB_Middle);
   SetIndexBuffer(17,BB_Bottom);
   
   SetIndexBuffer(18,Signal_AVG_Top);
   SetIndexBuffer(19,Signal_AVG_Bottom);
   
   return(0);
}

int start(){
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double EcartConfirmBubbleUp, EcartConfirmBubbleDn, EcartBubble;
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   for(i=limit; i>=0; i--){
      
      BB_Top[i]    = iBands(NULL,0,Periods,Deviation,0,PRICE_CLOSE,MODE_UPPER,i);
      BB_Middle[i] = iBands(NULL,0,Periods,Deviation,0,PRICE_CLOSE,MODE_MAIN,i);
      BB_Bottom[i] = iBands(NULL,0,Periods,Deviation,0,PRICE_CLOSE,MODE_LOWER,i);
      
      switch(Method_to_Smooth){
         case 1 :
            AVG_Top[i] = SMA(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = SMA(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = SMA(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 2 :
            AVG_Top[i] = EMA(BB_Top[i],AVG_Top[i+1],Periods_to_Smooth,i);
            AVG_Middle[i] = EMA(BB_Middle[i],AVG_Middle[i+1],Periods_to_Smooth,i);
            AVG_Bottom[i] = EMA(BB_Bottom[i],AVG_Bottom[i+1],Periods_to_Smooth,i);
            break;
         case 3 :
            AVG_Top[i] = Wilder(BB_Top[i],AVG_Top[i+1],Periods_to_Smooth,i);
            AVG_Middle[i] = Wilder(BB_Middle[i],AVG_Middle[i+1],Periods_to_Smooth,i);
            AVG_Bottom[i] = Wilder(BB_Bottom[i],AVG_Bottom[i+1],Periods_to_Smooth,i);
            break;  
         case 4 :
            AVG_Top[i] = LWMA(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = LWMA(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = LWMA(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 5 :
            AVG_Top[i] = SineWMA(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = SineWMA(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = SineWMA(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 6 :
            AVG_Top[i] = TriMA(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = TriMA(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = TriMA(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 7 :
            AVG_Top[i] = LSMA(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = LSMA(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = LSMA(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 8 :
            AVG_Top[i] = SMMA(BB_Top,AVG_Top[i+1],Periods_to_Smooth,i);
            AVG_Middle[i] = SMMA(BB_Middle,AVG_Middle[i+1],Periods_to_Smooth,i);
            AVG_Bottom[i] = SMMA(BB_Bottom,AVG_Bottom[i+1],Periods_to_Smooth,i);
            break;
         case 9 :
            AVG_Top[i] = HMA(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = HMA(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = HMA(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 10:
            AVG_Top[i] = ZeroLagEMA(BB_Top,AVG_Top[i+1],Periods_to_Smooth,i);
            AVG_Middle[i] = ZeroLagEMA(BB_Middle,AVG_Middle[i+1],Periods_to_Smooth,i);
            AVG_Bottom[i] = ZeroLagEMA(BB_Bottom,AVG_Bottom[i+1],Periods_to_Smooth,i);
            break;
         case 11:
            AVG_Top[i] = ITrend(BB_Top,AVG_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = ITrend(BB_Middle,AVG_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = ITrend(BB_Bottom,AVG_Bottom,Periods_to_Smooth,i);
            break;
         case 12:
            AVG_Top[i] = Median(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = Median(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = Median(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 13:
            AVG_Top[i] = GeoMean(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = GeoMean(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = GeoMean(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 14:
            AVG_Top[i] = REMA(BB_Top[i],AVG_Top,Periods_to_Smooth,0.5,i);
            AVG_Middle[i] = REMA(BB_Middle[i],AVG_Middle,Periods_to_Smooth,0.5,i);
            AVG_Bottom[i] = REMA(BB_Bottom[i],AVG_Bottom,Periods_to_Smooth,0.5,i);
            break;
         case 15:
            AVG_Top[i] = ILRS(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = ILRS(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = ILRS(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 16:
            AVG_Top[i] = IE2(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = IE2(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = IE2(BB_Bottom,Periods_to_Smooth,i);
            break;
         case 17:
            AVG_Top[i] = TriMA_gen(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = TriMA_gen(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = TriMA_gen(BB_Bottom,Periods_to_Smooth,i);
            break;
         default:
            AVG_Top[i] = SMA(BB_Top,Periods_to_Smooth,i);
            AVG_Middle[i] = SMA(BB_Middle,Periods_to_Smooth,i);
            AVG_Bottom[i] = SMA(BB_Bottom,Periods_to_Smooth,i);
            break;
      }
      
      if (AVG_Middle[i] > AVG_Middle[i+1]) Middle_Up[i] = AVG_Middle[i];
      if (AVG_Middle[i] < AVG_Middle[i+1]) Middle_Dn[i] = AVG_Middle[i];
      
      EcartConfirmBubbleUp = (AVG_Top[i]     - AVG_Top[i+1] ) / (pipSize*1440*((iTime(NULL,Period(),i)*1.0) - (iTime(NULL,Period(),i+1)*1.0))/(3600*24));
      EcartConfirmBubbleDn = (AVG_Bottom[i+1]- AVG_Bottom[i]) / (pipSize*1440*((iTime(NULL,Period(),i)*1.0) - (iTime(NULL,Period(),i+1)*1.0))/(3600*24));
   
      // Calculation of slope change of AVG Top
      Signal_AVG_Top[i] = Signal_AVG_Top[i+1];
      // Signal AVG Top Up
      if (AVG_Top[i+2] >= AVG_Top[i+1] && AVG_Top[i+1] < AVG_Top[i]){
         Signal_AVG_Top[i]=1.0;
      }
      // Signal AVG Top Dn
      else if (AVG_Top[i+2] <= AVG_Top[i+1] && AVG_Top[i+1] > AVG_Top[i]){
         Signal_AVG_Top[i]=-1.0;
      }

      // Calculation of slope change of AVG Bottom       
      Signal_AVG_Bottom[i] = Signal_AVG_Bottom[i+1];
      // Signal AVG Bottom Up
      if (AVG_Bottom[i+2] >= AVG_Bottom[i+1] && AVG_Bottom[i+1] < AVG_Bottom[i]){
         Signal_AVG_Bottom[i]=1.0;
      }
      // Signal AVG Bottom Dn
      else if (AVG_Bottom[i+2] <= AVG_Bottom[i+1] && AVG_Bottom[i+1] > AVG_Bottom[i]){
         Signal_AVG_Bottom[i]=-1.0;
      }
      
      // ConditionStartBubbleUp
      if (Signal_AVG_Top[i]==1.0 && Signal_AVG_Bottom[i]==-1.0 && StartBubbleUp == false  && Close[i] >= AVG_Top[i] && EcartConfirmBubbleUp >= Slope){
         if (StartSausageUp == false){ // new bubbleUp
            StartBubbleUp = true; 
            StopBubbleUp = false;
            StartBubbleDn = false;
            StopBubbleDn = false;
            StartSausageUp = false;
            StartSausageDn = false;
         }
         else{ // bubbleUp in sausageUp -> sausageUp
            StartBubbleUp = false; 
            StopBubbleUp = false;
            StartBubbleDn = false;
            StopBubbleDn = false;
            StartSausageUp = true;
            StartSausageDn = false;
         }
      }
      
      // ConditionStartBubbleDn
       if (Signal_AVG_Top[i]==1.0 && Signal_AVG_Bottom[i]==-1.0 && StartBubbleDn == false  && Close[i] <= AVG_Bottom[i] && EcartConfirmBubbleDn >= Slope){
         if (StartSausageDn == false){ // new bubbleDn
            StartBubbleUp = false; 
            StopBubbleUp = false;
            StartBubbleDn = true;
            StopBubbleDn = false;
            StartSausageUp = false;
            StartSausageDn = false;
         }
         else{ // bubbleDn in sausageDn -> sausageDn
            StartBubbleUp = false; 
            StopBubbleUp = false;
            StartBubbleDn = false;
            StopBubbleDn = false;
            StartSausageUp = false;
            StartSausageDn = true;
         }
      }
      
      // ConditionStopBubbleUp
       if (StartBubbleUp == true && Signal_AVG_Top[i]==1.0 && Signal_AVG_Bottom[i]==1.0){
         EcartBubble = AVG_Top[i]-AVG_Bottom[i];            
         StartBubbleUp = false; 
         StopBubbleUp = true;
         StartBubbleDn = false;
         StopBubbleDn = false;
         StartSausageUp = false;
         StartSausageDn = false;
      }
      
      // ConditionStopBubbleDn
       if (StartBubbleDn == true && Signal_AVG_Top[i]==-1.0 && Signal_AVG_Bottom[i]==-1.0){
         EcartBubble = AVG_Top[i]-AVG_Bottom[i];
         StartBubbleUp = false; 
         StopBubbleUp = false;
         StartBubbleDn = false;
         StopBubbleDn = true;   
         StartSausageUp = false;
         StartSausageDn = false;
      }
      
      // ConditionStartSausageUp
       if (StopBubbleUp == true && Signal_AVG_Top[i]==1.0 && Signal_AVG_Bottom[i]==1.0){
         StartBubbleUp = false; 
         StopBubbleUp = false;
         StartBubbleDn = false;
         StopBubbleDn = false;
         StartSausageUp = true;
         StartSausageDn = false;
      }
      
      // ConditionStartSausageDn
       if (StopBubbleDn == true && Signal_AVG_Top[i]==-1.0 && Signal_AVG_Bottom[i]==-1.0){
         StartBubbleUp = false; 
         StopBubbleUp = false;
         StartBubbleDn = false;
         StopBubbleDn = false;
         StartSausageUp = false;
         StartSausageDn = true;
      }
      
      // ConditionStopSausageUp
       if (StartSausageUp == true){
         // bottleneck, go to squeeze
         if (Signal_AVG_Top[i]==-1 && Signal_AVG_Bottom[i]==1.0 && (EcartBubble*Percent)/100 >= (AVG_Top[i]-AVG_Bottom[i])){
            StartBubbleUp = false; 
            StopBubbleUp = false;
            StartBubbleDn = false;
            StopBubbleDn = false;
            StartSausageUp = false;
            StartSausageDn = false;
         }
      }
      
      // ConditionStopSausageDn
       if (StartSausageDn == true){
         // bottleneck, go to squeeze
         if (Signal_AVG_Top[i]==-1 && Signal_AVG_Bottom[i]==1.0 && (EcartBubble*Percent)/100 >= (AVG_Top[i]-AVG_Bottom[i])){
         StartBubbleUp = false; 
         StopBubbleUp = false;
         StartBubbleDn = false;
         StopBubbleDn = false;
         StartSausageUp = false;
         StartSausageDn = false;
         }
      }
      
       if ((StartBubbleUp == true || StartSausageUp == true) && AVG_Middle[i+1] > AVG_Middle[i]){
         StartBubbleUp = false; 
         StopBubbleUp = false;
         StartBubbleDn = false;
         StopBubbleDn = false;
         StartSausageUp = false;
         StartSausageDn = false;
      }
      
       if ((StartBubbleDn == true || StartSausageDn == true) && AVG_Middle[i+1] < AVG_Middle[i]){
         StartBubbleUp = false; 
         StopBubbleUp = false;
         StartBubbleDn = false;
         StopBubbleDn = false;
         StartSausageUp = false;
         StartSausageDn = false;
      }
      
      if (StartBubbleUp){
         Bubble_Up_max[i] = AVG_Top[i];
         Bubble_Up_min[i] = AVG_Bottom[i];
      }
      
      else if (StartBubbleDn){
         Bubble_Dn_max[i] = AVG_Top[i];
         Bubble_Dn_min[i] = AVG_Bottom[i];
      }
      
      else if (StartSausageUp){
         Sausage_Up_max[i] = AVG_Top[i];
         Sausage_Up_min[i] = AVG_Bottom[i];
      }
      
      else if (StartSausageDn){
         Sausage_Dn_max[i] = AVG_Top[i];
         Sausage_Dn_min[i] = AVG_Bottom[i];
      }
      
      else{
         Squeeze_max[i] = AVG_Top[i];
         Squeeze_min[i] = AVG_Bottom[i];
      }
      
   }
   
   //double eup = (AVG_Top[9]     - AVG_Top[10] ) / (pipSize*1440*((iTime(NULL,Period(),9)*1.0) - (iTime(NULL,Period(),10)*1.0))/(3600*24));
   //double edn = (AVG_Bottom[10]- AVG_Bottom[9]) / (pipSize*1440*((iTime(NULL,Period(),9)*1.0) - (iTime(NULL,Period(),10)*1.0))/(3600*24));
   //Comment("High: "+High[9]+" eBubleUp: "+eup+" eBubleDn: "+edn+" SignalTop: "+Signal_AVG_Top[9]+" SignalBot: "+Signal_AVG_Bottom[9]);
   
//----
   return(0);
}

string TFToStr(int tf)   { 
  if (tf == 0)        tf = Period();
  if (tf >= 43200)    return("MN");
  if (tf >= 10080)    return("W1");
  if (tf >=  1440)    return("D1");
  if (tf >=   240)    return("H4");
  if (tf >=    60)    return("H1");
  if (tf >=    30)    return("M30");
  if (tf >=    15)    return("M15");
  if (tf >=     5)    return("M5");
  if (tf >=     1)    return("M1");
  return("");
}

double SMA(double &array[],int per,int bar){
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[bar+i];
   return(Sum/per);
}                

double EMA(double price,double prev,int per,int bar){
   if(bar >= Bars - 2)
      double ema = price;
   else 
      ema = prev + 2.0/(1+per)*(price - prev); 
   return(ema);
}

double Wilder(double price,double prev,int per,int bar){
   if(bar >= Bars - 2)
      double wilder = price;
   else 
      wilder = prev + (price - prev)/per; 
   return(wilder);
}

double LWMA(double &array[],int per,int bar){
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= (per - i);
      Sum += array[bar+i]*(per - i);
   }
   if(Weight>0)
      double lwma = Sum/Weight;
   else
      lwma = 0; 
   return(lwma);
} 

double SineWMA(double &array[],int per,int bar){
   double pi = 3.1415926535;
   double Sum = 0;
   double Weight = 0;
   for(int i = 0;i < per;i++){ 
      Weight+= MathSin(pi*(i+1)/(per+1));
      Sum += array[bar+i]*MathSin(pi*(i+1)/(per+1)); 
   }
   if(Weight>0)
      double swma = Sum/Weight;
   else
      swma = 0; 
   return(swma);
}

double TriMA(double &array[],int per,int bar){
   double sma;
   int len = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len;i++) {
      sma = SMA(array,len,bar+i);
      sum += sma;
   } 
   double trima = sum/len;
   return(trima);
}

double LSMA(double &array[],int per,int bar){   
   double Sum=0;
   for(int i=per; i>=1; i--) Sum += (i-(per+1)/3.0)*array[bar+per-i];
   double lsma = Sum*6/(per*(per+1));
   return(lsma);
}

double SMMA(double &array[],double prev,int per,int bar){
   if(bar == Bars - per)
      double smma = SMA(array,per,bar);
   else if(bar < Bars - per){
      double Sum = 0;
      for(int i = 0;i < per;i++) Sum += array[bar+i+1];
      smma = (Sum - prev + array[bar])/per;
   }
   return(smma);
}                

double HMA(double &array[],int per,int bar){
   double tmp1[];
   int len = MathSqrt(per);
   ArrayResize(tmp1,len);
   if(bar == Bars - per)
      double hma = array[bar]; 
   else if(bar < Bars - per){
      for(int i=0;i<len;i++) tmp1[i] = 2*LWMA(array,per/2,bar+i) - LWMA(array,per,bar+i);  
      hma = LWMA(tmp1,len,0); 
   }  
   return(hma);
}

double ZeroLagEMA(double &price[],double prev,int per,int bar){
   double alfa = 2.0/(1+per); 
   int lag = 0.5*(per - 1); 
   if(bar >= Bars - lag)
      double zema = price[bar];
   else 
      zema = alfa*(2*price[bar] - price[bar+lag]) + (1-alfa)*prev;
   return(zema);
}

double ITrend(double &price[],double &array[],int per,int bar){
   double alfa = 2.0/(per+1);
   if (bar < Bars - 7)
      double it = (alfa - 0.25*alfa*alfa)*price[bar] + 0.5*alfa*alfa*price[bar+1] - (alfa - 0.75*alfa*alfa)*price[bar+2] + 2*(1-alfa)*array[bar+1] - (1-alfa)*(1-alfa)*array[bar+2];
   else
      it = (price[bar] + 2*price[bar+1] + price[bar+2])/4;
   return(it);
}

double Median(double &price[],int per,int bar){
   double array[];
   ArrayResize(array,per);
   for(int i = 0; i < per;i++) array[i] = price[bar+i];
   ArraySort(array);
   int num = MathRound((per-1)/2); 
   if(MathMod(per,2) > 0) double median = array[num]; else median = 0.5*(array[num]+array[num+1]);
   return(median); 
}

double GeoMean(double &price[],int per,int bar){
   if(bar < Bars - per){ 
      double gmean = MathPow(price[bar],1.0/per); 
      for(int i = 1; i < per;i++) gmean *= MathPow(price[bar+i],1.0/per); 
   }   
   return(gmean);
}

double REMA(double price,double &array[],int per,double lambda,int bar){
   double alpha =  2.0/(per + 1);
   if(bar >= Bars - 3)
      double rema = price;
   else 
      rema = (array[bar+1]*(1+2*lambda) + alpha*(price - array[bar+1]) - lambda*array[bar+2])/(1+lambda);    
   return(rema);
}

double ILRS(double &price[],int per,int bar){
   double sum = per*(per-1)*0.5;
   double sum2 = (per-1)*per*(2*per-1)/6.0;
   double sum1 = 0;
   double sumy = 0;
   for(int i=0;i<per;i++){ 
      sum1 += i*price[bar+i];
      sumy += price[bar+i];
   }
   double num1 = per*sum1 - sum*sumy;
   double num2 = sum*sum - per*sum2;
   if(num2 != 0) double slope = num1/num2; else slope = 0; 
   double ilrs = slope + SMA(price,per,bar);
   return(ilrs);
}

double IE2(double &price[],int per,int bar){
   double ie = 0.5*(ILRS(price,per,bar) + LSMA(price,per,bar));
   return(ie); 
}
 

double TriMA_gen(double &array[],int per,int bar){
   int len1 = MathFloor((per+1)*0.5);
   int len2 = MathCeil((per+1)*0.5);
   double sum=0;
   for(int i = 0;i < len2;i++) sum += SMA(array,len1,bar+i);
   double trimagen = sum/len2;
   return(trimagen);
}