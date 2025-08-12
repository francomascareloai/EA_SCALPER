//+------------------------------------------------------------------+
//|                                         FractalsMD_v3.2 600+.mq4 |
//|                        Copyright © 2006-16, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006-16, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 clrSteelBlue
#property indicator_color2 clrOrangeRed
#property indicator_color3 clrRoyalBlue
#property indicator_color4 clrTomato
#property indicator_color5 clrCornflowerBlue
#property indicator_color6 clrLightSalmon
#property indicator_color7 clrPowderBlue
#property indicator_color8 clrOrange

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 0
#property indicator_width4 0
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 3
#property indicator_width8 3


enum ENUM_PRICE
{
   close,               // Close
   open,                // Open
   high,                // High
   low,                 // Low
   median,              // Median
   typical,             // Typical
   weightedClose,       // Weighted Close
   haClose,             // Heiken Ashi Close
   haOpen,              // Heiken Ashi Open
   haHigh,              // Heiken Ashi High   
   haLow,               // Heiken Ashi Low
   haMedian,            // Heiken Ashi Median
   haTypical,           // Heiken Ashi Typical
   haWeighted           // Heiken Ashi Weighted Close   
};

//---- input parameters
input ENUM_PRICE  UpBandPrice    =     2;    // Upper Band Price
input ENUM_PRICE  LoBandPrice    =     3;    // Lower Band Price 
input int         Dimension      =     1;    // Fractal Dimension (max. 4)
input int         FractalSize    =     1;    // Fractal Size in bars (ex. 1-3 bars,2-5 bars,3-7 bars)

//---- buffers
double upFractal1[];
double loFractal1[];
double upFractal2[];
double loFractal2[];
double upFractal3[];
double loFractal3[];
double upFractal4[];
double loFractal4[];

double   hiArray[],loArray[];
datetime hiTime[], loTime[];			
      
int      Length;
string   IndicatorName, short_name;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(Digits);
//---- 
   IndicatorBuffers(2*Dimension);
   SetIndexBuffer(0,upFractal1); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,159);
   SetIndexBuffer(1,loFractal1); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,159);
   SetIndexBuffer(2,upFractal2); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,162);
   SetIndexBuffer(3,loFractal2); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,162);
   SetIndexBuffer(4,upFractal3); SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,162);
   SetIndexBuffer(5,loFractal3); SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,162);
   SetIndexBuffer(6,upFractal4); SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,162);
   SetIndexBuffer(7,loFractal4); SetIndexStyle(7,DRAW_ARROW); SetIndexArrow(7,162);
   
//---- 
   IndicatorName = WindowExpertName();
   short_name    = IndicatorName + "(" + UpBandPrice + "," + LoBandPrice+"," + Dimension + "," + FractalSize + ")";
   IndicatorShortName(short_name);
      for(int i=0;i<Dimension;i++)
      {
      SetIndexLabel(2*i    ,"Upper " + (i + 1) + "D Fractal");
      SetIndexLabel(2*i + 1,"Lower " + (i + 1) + "D Fractal");
      }
//----

   Length = 2*FractalSize + 1; 
   ArrayResize(hiArray,Length);
   ArrayResize(loArray,Length);
   ArrayResize(hiTime ,Length);
   ArrayResize(loTime ,Length);
   
   
   return(0);
}
//+------------------------------------------------------------------+
//| FractalsMD_v3.2 600+                                             |
//+------------------------------------------------------------------+
int start()
{
   int      i, shift, limit, counted_bars = IndicatorCounted();
   datetime uptime, dntime;			
   
   if(counted_bars > 0) limit = Bars - counted_bars - 1;
   if(counted_bars < 0) return(0);
   if(counted_bars < 1)
   {
   limit = Bars - Length; 
      for(i=Bars - 1;i>=0;i--)	
      {
      upFractal1[i] = EMPTY_VALUE;
      loFractal1[i] = EMPTY_VALUE;
      upFractal2[i] = EMPTY_VALUE;
      loFractal2[i] = EMPTY_VALUE;
      upFractal3[i] = EMPTY_VALUE;
      loFractal3[i] = EMPTY_VALUE;
      upFractal4[i] = EMPTY_VALUE;
      loFractal4[i] = EMPTY_VALUE;
      }
   }
      
   
   
//--- 1st Dimension   
   for(shift=limit;shift>=0;shift--) 
   {	
      for(int j=0;j<Length;j++)
	   { 
         if(UpBandPrice <= 6) hiArray[j] = iMA(NULL,0,1,0,0,(int)UpBandPrice,shift+j);   
         else
         if(UpBandPrice > 6 && UpBandPrice <= 13) hiArray[j] = HeikenAshi(0,UpBandPrice-7,shift+j);
      
         if(LoBandPrice <= 6) loArray[j] = iMA(NULL,0,1,0,0,(int)LoBandPrice,shift+j);   
         else
         if(LoBandPrice > 6 && LoBandPrice <= 13) loArray[j] = HeikenAshi(1,LoBandPrice-7,shift+j);     
	   
	   hiTime[j] = Time[shift+j];
	   loTime[j] = Time[shift+j];
	   }
	 
	
	double f1 = Fractals(0,hiArray,hiTime,FractalSize,0,uptime);
	double f2 = Fractals(1,loArray,loTime,FractalSize,0,dntime);
	
	if(f1 > 0) upFractal1[shift+FractalSize] = f1; else upFractal1[shift+FractalSize] = EMPTY_VALUE;
	if(f2 > 0) loFractal1[shift+FractalSize] = f2; else loFractal1[shift+FractalSize] = EMPTY_VALUE; 
   }
   
//--- 2nd Dimension   
   if(Dimension > 1) 
   {
   for(shift=limit;shift>=0;shift--) MD_Fractals(0,upFractal1,loFractal1,FractalSize,shift,upFractal2,loFractal2);
   }
//--- 3rd Dimension   
   if(Dimension > 2) 
   {
   for(shift=limit;shift>=0;shift--) MD_Fractals(1,upFractal2,loFractal2,FractalSize,shift,upFractal3,loFractal3);
   }
//--- 4th Dimension   
   if(Dimension > 3) 
   {
   for(shift=limit;shift>=0;shift--) MD_Fractals(2,upFractal3,loFractal3,FractalSize,shift,upFractal4,loFractal4);
   }   

   return(0);
}




//-----
int prevupbar[3], prevdnbar[3]; 
datetime curruptime[3], currdntime[3], firstdntime[3], firstuptime[3];

//+------------------------------------------------------------------+
void MD_Fractals(int index,double& up[],double& dn[],int size,int bar,double& upf[],double& dnf[])
{
datetime uptime, lotime;
double   f1, f2;

//---Upper   
   ArrayInitialize(hiArray,0);
   
   int k = 0;
   int j = 0;

      while(k < Length)
	   { 
      if(bar + j >= Bars - 1) break;
         
         if(NormalizeDouble(up[bar+j],Digits) > 0 && up[bar+j]!= EMPTY_VALUE) 
         {
         hiArray[k] = up[bar+j]; 
         hiTime[k]  = Time[bar+j]; 
         k++;
         } 
      j++;
      }
     
   f1 = Fractals(0,hiArray,hiTime,size,0,uptime);
      
   if(f1 > 0)
   {
   prevupbar[index]      = iBarShift(Symbol(),0,uptime);   
   upf[prevupbar[index]] = f1;
   
      if(bar == 0 && hiTime[Length-1-size] >= firstuptime[index]) 
      {
      firstuptime[index] = hiTime[Length-1-size];
      curruptime[index]  = Time[bar];
      }
   }   
   else 
   {  
   if(bar == 0 && hiTime[Length-1-size] < firstuptime[index] && Time[bar] == curruptime[index] && prevupbar[index] > 0) upf[prevupbar[index]] = EMPTY_VALUE;
   }
     
//--- Lower
   ArrayInitialize(loArray,0);

   k = 0;
   j = 0;
		while(k < Length)
	   { 
      if(bar + j >= Bars - 1) break;
         
         if(dn[bar+j] > 0 && dn[bar+j]!= EMPTY_VALUE) 
         {
         loArray[k] = dn[bar+j]; 
         loTime[k]  = Time[bar+j]; 
         k++;
         } 
      j++;
      }	
   
   f2 = Fractals(1,loArray,loTime,size,0,lotime);
		
   if(f2 > 0)
   {
   prevdnbar[index]      = iBarShift(Symbol(),0,lotime);
   dnf[prevdnbar[index]] = f2;
      
      if(bar == 0 && loTime[Length-1-size] >= firstdntime[index]) 
      {
      firstdntime[index] = loTime[Length-1-size];
      currdntime[index]  = Time[bar];
      }
   }
   else
   { 
   if(bar == 0 && loTime[Length-1-size] < firstdntime[index] && Time[bar] == currdntime[index] && prevdnbar[index] > 0) dnf[prevdnbar[index]] = EMPTY_VALUE;
   }   
}


//-----
double Fractals(int type,double& price[],datetime& time[],int size,double height,datetime& ftime)
{
   int len  = 2*MathMax(1,size) + 1;
   int imax = 0, imin = 0;
   double max = 0, min = 100000000;
       
   for(int i=0;i<len;i++)
   { 
      if(type == 0 && price[i] > max ) {max = price[i]; imax = i;}  
      if(type == 1 && price[i] < min ) {min = price[i]; imin = i;}  
   }
   
   if(imax == size && max - price[0] > height && max - price[len-1] > height) {ftime = time[imax]; return(max);} 
   if(imin == size && price[0] - min > height && price[len-1] - min > height) {ftime = time[imin]; return(min);}
   
   return(0);  
}

// HeikenAshi Price
double   haClose[2][2], haOpen[2][2], haHigh[2][2], haLow[2][2];
datetime prevhatime[2];

double HeikenAshi(int index,int price,int bar)
{ 
   if(prevhatime[index] != Time[bar])
   {
   haClose[index][1] = haClose[index][0];
   haOpen [index][1] = haOpen [index][0];
   haHigh [index][1] = haHigh [index][0];
   haLow  [index][1] = haLow  [index][0];
   prevhatime[index] = Time[bar];
   }
   
   if(bar == Bars - 1) 
   {
   haClose[index][0] = Close[bar];
   haOpen [index][0] = Open [bar];
   haHigh [index][0] = High [bar];
   haLow  [index][0] = Low  [bar];
   }
   else
   {
   haClose[index][0] = (Open[bar] + High[bar] + Low[bar] + Close[bar])/4;
   haOpen [index][0] = (haOpen[index][1] + haClose[index][1])/2;
   haHigh [index][0] = MathMax(High[bar],MathMax(haOpen[index][0],haClose[index][0]));
   haLow  [index][0] = MathMin(Low [bar],MathMin(haOpen[index][0],haClose[index][0]));
   }
   
   switch(price)
   {
   case  0: return(haClose[index][0]); break;
   case  1: return(haOpen [index][0]); break;
   case  2: return(haHigh [index][0]); break;
   case  3: return(haLow  [index][0]); break;
   case  4: return((haHigh[index][0] + haLow[index][0])/2); break;
   case  5: return((haHigh[index][0] + haLow[index][0] +   haClose[index][0])/3); break;
   case  6: return((haHigh[index][0] + haLow[index][0] + 2*haClose[index][0])/4); break;
   default: return(haClose[index][0]); break;
   }
}   
   
   
   
   
   
   
   













