//+------------------------------------------------------------------+
//|                                                 Jim Sloman's ndx |
//|                                                      ocn ndx.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    5
#property indicator_color1     LimeGreen
#property indicator_color2     Maroon
#property indicator_color3     Red
#property indicator_color4     DarkGreen
#property indicator_color5     DarkSlateGray   
#property indicator_width1     3
#property indicator_width2     3
#property indicator_width3     3
#property indicator_width4     3
#property indicator_width5     3
#property indicator_levelcolor DimGray


//
//
//
//
//

extern string TimeFrame    = "Current time frame";
extern int    NDX_Period   = 40;
extern int    NDX_Price    = PRICE_CLOSE;
extern double SmoothLength = 10;
extern double SmoothPhase  = 0;
extern bool   SmoothDouble = false;
extern bool   Interpolate  = true;
extern bool   HistoOnSlope = true;

extern int    levelOb      = 50;
extern int    levelOs      = -50; 

//
//
//
//
//

double ndx[];
double ndxhuu[];
double ndxhud[];
double ndxhdd[];
double ndxhdu[];
double trend[];
double slope[];
double tBuffer[][4];


//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int init()
{
    IndicatorBuffers(7);
    SetIndexBuffer(0,ndxhuu); SetIndexStyle(0,DRAW_HISTOGRAM);
    SetIndexBuffer(1,ndxhud); SetIndexStyle(1,DRAW_HISTOGRAM);
    SetIndexBuffer(2,ndxhdd); SetIndexStyle(2,DRAW_HISTOGRAM);
    SetIndexBuffer(3,ndxhdu); SetIndexStyle(3,DRAW_HISTOGRAM);
    SetIndexBuffer(4,ndx);
    SetIndexBuffer(5,trend);
    SetIndexBuffer(6,slope);
    SetLevelValue(0,0);
    SetLevelValue(1,levelOb);
    SetLevelValue(2,levelOs);
      
   //
   //
   //
   //
   //
      
      NDX_Period        = MathMax(NDX_Period ,1);
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
      
   //
   //
   //
   //
   //
   
   IndicatorShortName(timeFrameToString(timeFrame)+"   ocn ndx jurik ("+NDX_Period+","+DoubleToStr(SmoothLength,2)+")");
   SetIndexLabel(0,"");
   SetIndexLabel(1,"");
   SetIndexLabel(2,"");
   SetIndexLabel(3,"");
   SetIndexLabel(4,"");
   SetIndexLabel(5,"");
   SetIndexLabel(6,"");
 return(0);
}

//
//
//
//
//

int deinit() { return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define iPrc 3

int start()
{
   int    counted_bars=IndicatorCounted();
   int    i,r,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-NDX_Period-1);
         if (returnBars) { ndxhuu[0] = limit+1; return(0); }
         
   //
   //
   //
   //
   //
   
   if (calculateValue || timeFrame==Period())
   {
     if (ArrayRange(tBuffer,0) != Bars) ArrayResize(tBuffer,Bars);
     for(i=limit, r=Bars-i-1; i >= 0; i--,r++)
     {
        double currPrice = iMA(NULL,0,1,0,MODE_SMA,NDX_Price,i);
           if (currPrice > 0)
                 tBuffer[r][iPrc] = MathLog(currPrice);
           else  tBuffer[r][iPrc] = 0.00;
      
           //
           //
           //
           //
           //

           double sumMom = 0;
           double sumDen = 0;
           double sumDif = 0;
           for (int k=1; k < NDX_Period; k++)
           {
              sumDif += MathAbs(tBuffer[r-k+1][iPrc]-tBuffer[r-k][iPrc]);
              if (sumDif !=0)
                    double stoch = (tBuffer[r][iPrc]-tBuffer[r-k][iPrc])/sumDif;
              else         stoch = 0;
              double coeff = 1.0/MathSqrt(k);
          
              sumMom += coeff*stoch;
              sumDen += coeff;
           }
         
           //
           //
           //
           //
           //
           
           ndx[i] = iDSmooth(100.0*(sumMom/sumDen),SmoothLength,SmoothPhase,SmoothDouble,i);
           if (ndx[i] > 90) ndx[i] =  90+( ndx[i]-90)/2.0;
           if (ndx[i] <-90) ndx[i] = -90-(-ndx[i]-90)/2.0;
           
           ndxhuu[i] = EMPTY_VALUE;
           ndxhud[i] = EMPTY_VALUE;
           ndxhdd[i] = EMPTY_VALUE;
           ndxhdu[i] = EMPTY_VALUE;
           trend[i]  = trend[i+1]; 
           slope[i]  = slope[i+1];
                if (ndx[i] > 0)        trend[i] =  1;
                if (ndx[i] < 0)        trend[i] = -1;
                if (ndx[i] > ndx[i+1]) slope[i] =  1;
                if (ndx[i] < ndx[i+1]) slope[i] = -1;
            
                if (HistoOnSlope)
                {
                  if (trend[i] ==  1 && slope[i] ==  1) ndxhuu[i] = ndx[i];
                  if (trend[i] ==  1 && slope[i] == -1) ndxhud[i] = ndx[i];
                  if (trend[i] == -1 && slope[i] == -1) ndxhdd[i] = ndx[i];
                  if (trend[i] == -1 && slope[i] ==  1) ndxhdu[i] = ndx[i];
                }
                else
                {                  
                  if (trend[i] ==  1) ndxhuu[i] = ndx[i];
                  if (trend[i] == -1) ndxhdd[i] = ndx[i];
                }
	    
          }  
     return(0);
     }

    //
    //
    //
    //
    //
    
    limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
    for (i=limit;i>=0; i--)
    {
       int y = iBarShift(NULL,timeFrame,Time[i]);
          ndx[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",NDX_Period,NDX_Price,SmoothLength,SmoothPhase,SmoothDouble,4,y);
          trend[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",NDX_Period,NDX_Price,SmoothLength,SmoothPhase,SmoothDouble,5,y);
          slope[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",NDX_Period,NDX_Price,SmoothLength,SmoothPhase,SmoothDouble,6,y);
          ndxhuu[i] = EMPTY_VALUE;
          ndxhud[i] = EMPTY_VALUE;
          ndxhdd[i] = EMPTY_VALUE;
          ndxhdu[i] = EMPTY_VALUE;
            
          //
          //
          //
          //
          //
            
          if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

          //
          //
          //
          //
          //

          datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int s = 1; s < n; s++)
            {
  	            ndx[i+s] = ndx[i] + (ndx[i+n] - ndx[i]) * s/n;
  	  
            }
         
    }
    
    //
    //
    //
    //
    //
    
    for (i=limit;i>=0; i--)
    {     
       if (HistoOnSlope)
       {
         if (trend[i] ==  1 && slope[i] ==  1) ndxhuu[i] = ndx[i];
         if (trend[i] ==  1 && slope[i] == -1) ndxhud[i] = ndx[i];
         if (trend[i] == -1 && slope[i] == -1) ndxhdd[i] = ndx[i];
         if (trend[i] == -1 && slope[i] ==  1) ndxhdu[i] = ndx[i];
       }
       else
       {                  
         if (trend[i] ==  1) ndxhuu[i] = ndx[i];
         if (trend[i] == -1) ndxhdd[i] = ndx[i];
       }
    }  	            
return(0);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double wrk[][20];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

//
//
//
//
//

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0)
{
   if (isDouble)
         return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  return (iSmooth(price,length,phase,i,s));
}

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
}            

  