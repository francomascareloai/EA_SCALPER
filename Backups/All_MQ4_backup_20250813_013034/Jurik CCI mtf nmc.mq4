//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DimGray
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2


extern string TimeFrame           = "current time frame";
extern int    CCIPeriod           = 6;
extern int    CCIPrice            = PRICE_TYPICAL;
extern double OverSold            = -100;
extern double OverBought          =  100;
extern double SmoothLength        =    5;
extern double SmoothPhase         =  100;
extern color  OverSoldColor       = LimeGreen;
extern color  OverBoughtColor     = Orange;
extern bool   ShowArrows          = true;
extern bool   ShowArrowsZoneEnter = false;
extern bool   ShowArrowsZoneExit  = true;
extern string arrowsIdentifier    = "cci arrows";
extern color  arrowsUpColor       = DeepSkyBlue;
extern color  arrowsDnColor       = Goldenrod;
extern bool   Interpolate         = true;


double cci[];
double cciUpa[];
double cciUpb[];
double cciDna[];
double cciDnb[];
double prices[];
double trend[];


string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;


int init()
{
   IndicatorBuffers(7);
      SetIndexBuffer(0,cci);
      SetIndexBuffer(1,cciUpa); SetIndexStyle(1,DRAW_LINE,EMPTY,EMPTY,OverSoldColor);
      SetIndexBuffer(2,cciUpb); SetIndexStyle(2,DRAW_LINE,EMPTY,EMPTY,OverSoldColor);
      SetIndexBuffer(3,cciDna); SetIndexStyle(3,DRAW_LINE,EMPTY,EMPTY,OverBoughtColor);
      SetIndexBuffer(4,cciDnb); SetIndexStyle(4,DRAW_LINE,EMPTY,EMPTY,OverBoughtColor);
      SetIndexBuffer(5,prices);
      SetIndexBuffer(6,trend);
         SetLevelValue(0,OverBought);
         SetLevelValue(1,OverSold);

                  
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="CalculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);
         
       
         
   IndicatorShortName(timeFrameToString(timeFrame)+"Jurik CCI mtf ("+CCIPeriod+")");
   return(0);
}
int deinit()
{
   if (!calculateValue && ShowArrows) deleteArrows();
   return(0);
}



int start()
{
   int counted_bars=IndicatorCounted();
   int i,k,n,limit;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { cci[0] = limit+1; return(0); }

   
   if (calculateValue || timeFrame==Period())
   {
      if (trend[limit]== 1) CleanPoint(limit,cciUpa,cciUpb);
      if (trend[limit]==-1) CleanPoint(limit,cciDna,cciDnb);
      for(i=limit; i>=0; i--)
      {
         prices[i]  = iMA(NULL,0,1,0,MODE_SMA,CCIPrice,i);
         double avg = 0; for(k=0; k<CCIPeriod; k++) avg +=         prices[i+k];      avg /= CCIPeriod;
         double dev = 0; for(k=0; k<CCIPeriod; k++) dev += MathAbs(prices[i+k]-avg); dev /= CCIPeriod;
            if (dev!=0)
                  cci[i] = iSmooth((prices[i]-avg)/(0.015*dev),SmoothLength,SmoothPhase,i);
            else  cci[i] = iSmooth(0                          ,SmoothLength,SmoothPhase,i);
         
           
         
            cciUpa[i] = EMPTY_VALUE;
            cciUpb[i] = EMPTY_VALUE;
            cciDna[i] = EMPTY_VALUE;
            cciDnb[i] = EMPTY_VALUE;
            trend[i] = trend[i+1];
               if (cci[i]>OverBought)                    trend[i] =  1;
               if (cci[i]<OverSold)                      trend[i] = -1;
               if (cci[i]>OverSold && cci[i]<OverBought) trend[i] =  0;
               if (trend[i] ==  1) PlotPoint(i,cciUpa,cciUpb,cci);
               if (trend[i] == -1) PlotPoint(i,cciDna,cciDnb,cci);
               if (!calculateValue) manageArrow(i);
      }
      return(0);
   }      
   

   
   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (trend[limit]== 1) CleanPoint(limit,cciUpa,cciUpb);
   if (trend[limit]==-1) CleanPoint(limit,cciDna,cciDnb);
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         cci[i]    = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",CCIPeriod,CCIPrice,OverSold,OverBought,SmoothLength,SmoothPhase,0,y);
         trend[i]  = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",CCIPeriod,CCIPrice,OverSold,OverBought,SmoothLength,SmoothPhase,6,y);
         cciUpa[i] = EMPTY_VALUE;
         cciUpb[i] = EMPTY_VALUE;
         cciDna[i] = EMPTY_VALUE;
         cciDnb[i] = EMPTY_VALUE;
         manageArrow(i);

     
      
         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

       

         datetime time = iTime(NULL,timeFrame,y);
            for(n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(k = 1; k < n; k++)
               cci[i+k] = cci[i] + (cci[i+n]-cci[i])*k/n;
   }
   for (i=limit;i>=0;i--)
   {
      if (trend[i]== 1) PlotPoint(i,cciUpa,cciUpb,cci);
      if (trend[i]==-1) PlotPoint(i,cciDna,cciDnb,cci);
   }

   
   
   return(0);   
}



void manageArrow(int i)
{
   if (ShowArrows)
   {
      deleteArrow(Time[i]);
      if (trend[i]!=trend[i+1])
      {
         if (ShowArrowsZoneEnter && trend[i]   == 1)                    drawArrow(i,arrowsUpColor,241,false);
         if (ShowArrowsZoneEnter && trend[i]   ==-1)                    drawArrow(i,arrowsDnColor,242,true);
         if (ShowArrowsZoneExit  && trend[i+1] ==-1 && (trend[i] !=-1)) drawArrow(i,arrowsDnColor,241,false);
         if (ShowArrowsZoneExit  && trend[i+1] == 1 && (trend[i] != 1)) drawArrow(i,arrowsUpColor,242,true);
      }
   }
}               



void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
   
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}



void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}
void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}

double wrk[][10];
#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9



double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { for(int k=0; k<7; k++) wrk[0][k+s]=price; for(; k<10; k++) wrk[0][k+s]=0; return(price); }

 
   
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
         
       
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            if (wrk[r][avolty+s] > 0)
               double dVolty = wrk[r][volty+s]/wrk[r][avolty+s]; else dVolty = 0;   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

    
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
  
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

 

   return(wrk[r][4+s]);
}




void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}



void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]  = from[i];
         second[i] = EMPTY_VALUE;
      }
}



string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};



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