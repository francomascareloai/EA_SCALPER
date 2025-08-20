//+------------------------------------------------------------------+
//|                                                                  |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Tundra Laboratory"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 LightCoral
#property indicator_width1 3
#property indicator_width2 3

#property strict

//---- input parameters
extern int     TimeFrame         =     0;    //TimeFrame in min
extern int     Price             =     0;    //Applied Price(0...6)
extern int     NumberLines       =     3;    //Number Lines 
extern int     HiLoMode          =     0;    //High/Low Mode:0-off,1-on
extern double  MinHeight         =     0;    //Min Height in pips
extern int     PreSmooth         =     1;    //Period of Pre-smoothing 
extern int     Pole              =     1;    //Pole:1-EMA(1 pole),2-DEMA(2 poles),3-TEMA(3 poles),4-QEMA(4 poles)...
extern int     Order             =     1;    //Smoothing Order(min. 1)
extern double  WeightFactor      =     2;    //Weight Factor(ex.Wilder=1,EMA=2)   
extern double  DampingFactor     =     1;    //Damping Factor
 

//---- indicator buffers
double UpBuffer[];
double DnBuffer[];
double tlbtrend[];

int    Num,  trend[2], upcount[2], dncount[2];
double mprice[2], hiprice[2], loprice[2], upband[2], loband[2], minprice[][2], maxprice[][2],_point; 
 
double uniema_tmp[][2];
int    uniema_size;
datetime uniema_prevtime[], prevtime;
string IndicatorName, TF;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if(TimeFrame <= Period()) TimeFrame = Period();
   TF = tf(TimeFrame);
   if(TF  == "N/A") TimeFrame = Period();
   
   IndicatorDigits(Digits);
//---- indicator line
   IndicatorBuffers(3);
   SetIndexBuffer(0,UpBuffer); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,DnBuffer); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,tlbtrend);
      
//---- 
   IndicatorName = WindowExpertName();  
   string short_name = IndicatorName + "["+TF+"]("+(string)Price+","+(string)NumberLines+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"UniLineBreak Close");
   SetIndexLabel(1,"UniLineBreak Open" );
//----
   int begin = MathMax(2,PreSmooth); 
   SetIndexDrawBegin(0,begin);
   SetIndexDrawBegin(1,begin);
   
//----
   Num = MathMax(NumberLines,1);
   
   ArrayResize(minprice,Num);
   ArrayResize(maxprice,Num);
   
   uniema_size = Pole*Order;   
   ArrayResize(uniema_tmp,3*uniema_size);
   ArrayResize(uniema_prevtime,3);
   
   _point   = Point*MathPow(10,Digits%2);
      
   return(0);
}

//+------------------------------------------------------------------+
//| UniLineBreak_v2 600+                                             |
//+------------------------------------------------------------------+
int start()
{
   int shift,limit = 0, counted_bars = IndicatorCounted();
      
   if(counted_bars > 0) limit = Bars - counted_bars - 1;
   if(counted_bars < 0) return(0);
  	if(counted_bars < 1)
   { 
   limit = Bars - 1;   
      for(int i=0;i<Bars-1;i++)
      { 
      UpBuffer[i] = EMPTY_VALUE;
      DnBuffer[i] = EMPTY_VALUE;
      }
   }   
	
   if(TimeFrame != Period())
	{
   limit = MathMax(limit,TimeFrame/Period());   
      
      for(shift=0;shift<limit;shift++) 
      {	
      int y = iBarShift(NULL,TimeFrame,Time[shift]);
      
      UpBuffer[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,Price,NumberLines,HiLoMode,MinHeight,PreSmooth,Pole,Order,WeightFactor,DampingFactor,0,y);
      DnBuffer[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,Price,NumberLines,HiLoMode,MinHeight,PreSmooth,Pole,Order,WeightFactor,DampingFactor,1,y);
      }  
	return(0);
	}
	else
   {
      for(shift=limit;shift>=0;shift--) 
      {  	
      double upBand = EMPTY_VALUE;
      double loBand = EMPTY_VALUE; 
      
      tlbtrend[shift] = nLineBreak(upBand,loBand,Price,Num,HiLoMode,MinHeight,PreSmooth,Pole,Order,WeightFactor,DampingFactor,shift);        
   
      UpBuffer[shift] = upBand;
      DnBuffer[shift] = loBand;
      }      
   }

   return(0);	
}

int nLineBreak(double& uptrend,double& dntrend,int p,int number,int hilo,double minh,int presm,int pole,int order,double wf,double df,int bar)
{      
   int i;
   
   if(prevtime != Time[bar])
   {
   mprice[1]  = mprice[0];   
   upcount[1] = upcount[0];
   dncount[1] = dncount[0];
   upband[1]  = upband[0];
   loband[1]  = loband[0]; 
   trend[1]   = trend[0]; 
   for(i=number-1;i>=0;i--) {maxprice[i][1] = maxprice[i][0]; minprice[i][1] = minprice[i][0];}    
   prevtime   = Time[bar]; 
   }
   
   mprice[0]  = NormalizeDouble(UniXMA(0,iMA(NULL,0,1,0,0,p,bar),presm,pole,order,wf,df,bar),Digits);  
   
   if(hilo == 0)
   {   
   hiprice[0] = mprice[0];
   loprice[0] = mprice[0];
   }
   else
   {
   hiprice[0] = NormalizeDouble(UniXMA(1,High[bar],presm,pole,order,wf,df,bar),Digits); 
   loprice[0] = NormalizeDouble(UniXMA(2,Low[bar] ,presm,pole,order,wf,df,bar),Digits); 
   }
         
      if(bar == Bars - (2 + presm)) 
      {
         if(mprice[0] >= mprice[1])
         {
	      trend[0]   = 1;
	      upcount[0] = 0;
         maxprice[0][0] = hiprice[0];
		   if(hilo == 0) minprice[0][0] = mprice[1]; else minprice[0][0] = loprice[0];
		   }
      	
      	if(mprice[0] < mprice[1])
         {	        
         trend[0]   =-1;
         dncount[0] = 0;
		   minprice[0][0] = loprice[0];
		   if(hilo == 0) maxprice[0][0] = mprice[1]; else maxprice[0][0] = hiprice[0];
		   }

      for(i=number-1;i>0;i--) {maxprice[i][0] = maxprice[i-1][0]; minprice[i][0] = minprice[i-1][0];} 
      
      upband[0] = maxprice[0][0];
      loband[0] = minprice[0][0];
      }
      else
      if(bar < Bars - (2 + presm))
      {
      trend[0]   = trend[1]; 
      upband[0]  = upband[1];
      loband[0]  = loband[1]; 
      upcount[0] = upcount[1];
      dncount[0] = dncount[1]; 
      for(i=number-1;i>=0;i--) {maxprice[i][0] = maxprice[i][1]; minprice[i][0] = minprice[i][1];} 
       
      if(hiprice[0] > upband[0] + minh*_point && mprice[0] > mprice[1] && trend[1] < 0) {trend[0] = 1; upcount[0] = 0;}	
	   if(loprice[0] < loband[0] - minh*_point && mprice[0] < mprice[1] && trend[1] > 0) {trend[0] =-1; dncount[0] = 0;}		

         if(trend[0] > 0)
         { 
            if(hiprice[0] - maxprice[0][0] > minh*_point)
            { 
		      for(i=number-1;i>0;i--) maxprice[i][0] = maxprice[i-1][0];  
		      maxprice[0][0] = hiprice[0]; 
		      
		      for(i=number-1;i>0;i--) minprice[i][0] = minprice[i-1][0];
		      minprice[0][0] = maxprice[1][0];
	         if(trend[1] > 0) upcount[0] = upcount[0] + 1;
		      }
	  
            if(trend[1] < 0) loband[0] = maxprice[1][0]; 
            else
            { 
               if(upcount[0] <= number-1) loband[0] = loband[1];
               else
               if(upcount[0] > number-1) loband[0] = minprice[number-1][0];          
            }   
         
         upband[0] = maxprice[0][0];
         uptrend   = maxprice[0][0];
         dntrend   = minprice[0][0];
         }		
         
         if(trend[0] < 0) 
         { 
            if(minprice[0][0] - loprice[0] > minh*_point )
            { 
		      for(i=number-1;i>0;i--) minprice[i][0] = minprice[i-1][0];
		      minprice[0][0] = loprice[0];  
		      
		      for(i=number-1;i>0;i--) maxprice[i][0] = maxprice[i-1][0]; 
		      maxprice[0][0] = minprice[1][0];
		      if(trend[1] < 0) dncount[0]  = dncount[0] + 1;
		      }	

            if(trend[1] > 0) upband[0] = minprice[1][0];
	         else
	         {
               if(dncount[0] <= Num-1) upband[0] = upband[1];
               else
               if(dncount[0] > number-1) upband[0] = maxprice[number-1][0];          
            }
         
         loband[0] = minprice[0][0];
         uptrend   = minprice[0][0];
         dntrend   = maxprice[0][0];
         }
      }   			
       
   return(trend[0]);
}



//-----
double UniXMA(int index,double price,int len,int mode,int order,double wf,double df,int bar)
{
   int k, j, m = index*uniema_size; 
   double alpha = (wf*order)/(len + wf*order-1); 
         
   if(uniema_prevtime[index] != Time[bar])
   {
   for(k=0;k<order;k++) 
      for(j=0;j<mode;j++) uniema_tmp[m+mode*k+j][1] = uniema_tmp[m+mode*k+j][0];
   
   uniema_prevtime[index] = Time[bar];
   }
   
   if(bar >= Bars-2) 
   {
   for(k=0;k<order;k++) 
      for(j=0;j<mode;j++) uniema_tmp[m+mode*k+j][0] = price; 
   }
   else  
   {
      for(k=0;k<order;k++)
      {
         for(j=0;j<mode;j++)
         {   
         uniema_tmp[m+mode*k+j][0] = (1 - alpha) * uniema_tmp[m+mode*k+j][1] + alpha * price; 
         if(j > 0) price = price + df * (uniema_tmp[m+mode*k][0] - uniema_tmp[m+mode*k+j][0]);
         else price = uniema_tmp[m+mode*k+j][0];
         }
      }   
   }
    
   return(price); 
}

string tf(int timeframe)
{
   switch(timeframe)
   {
   case PERIOD_M1:   return("M1");
   case PERIOD_M5:   return("M5");
   case PERIOD_M15:  return("M15");
   case PERIOD_M30:  return("M30");
   case PERIOD_H1:   return("H1");
   case PERIOD_H4:   return("H4");
   case PERIOD_D1:   return("D1");
   case PERIOD_W1:   return("W1");
   case PERIOD_MN1:  return("MN1");
   default:          return("N/A");
   }
} 