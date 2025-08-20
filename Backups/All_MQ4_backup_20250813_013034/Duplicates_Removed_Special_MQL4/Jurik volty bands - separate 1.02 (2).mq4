//+------------------------------------------------------------------
//| Jurik volty simple
//+------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrRed
#property indicator_color5  clrDeepSkyBlue
#property indicator_color6  clrPaleVioletRed
#property indicator_color7  clrDimGray
#property indicator_style4  STYLE_DOT
#property indicator_width3  2
#property indicator_style7  STYLE_DOT

//
//
//
//
//

enum enMaTypes
{
   ma_sma,     // Simple moving average
   ma_ema,     // Exponential moving average
   ma_smma,    // Smoothed MA
   ma_lwma,    // Linear weighted MA
};

extern string TimeFrame               = "Current time frame";
extern int    Length                  =  14;
extern int    Price                   =   0;
extern int    Shift                   =   0;
input int       MaPeriod              = 21;          // Ma period
input enMaTypes MaMethod              = ma_lwma;     // Moving average method 
extern bool   ShowMiddle              = true;
extern bool   ZeroBind                = true;
extern bool   Normalize               = false;
input bool    ShowHisto               = true;              // Show Histogram
input int     HistoWidth              = 3;                 // Histogram bars width
input color   UpHistoColor            = clrLimeGreen;      // Bullish color
input color   DnHistoColor            = clrRed;            // Bearish color
extern bool   alertsOnZeroCross       = true;
extern bool   alertsOnAllBreakOuts    = false;
extern bool   alertsOnAllBreakOutBars = false;
extern bool   alertsOn                = false;
extern bool   alertsOnCurrent         = false;
extern bool   alertsMessage           = true;
extern bool   alertsSound             = false;
extern bool   alertsEmail             = false;
extern bool   Interpolate             = true;
extern bool   arrowsVisible           = false;
extern string arrowsIdentifier        = "JurkiVltyArrows";
extern color  arrowsUpColor           = DeepSkyBlue;
extern color  arrowsDnColor           = Red;

//
//
//
//
//

double upValues[];
double dnValues[];
double miValues[];
double prc[],ma[],upH[],dnH[],valc[];
double trend[];

//
//
//
//
//

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------
//|                                                                 
//+------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorDigits(5);
   IndicatorBuffers(9);
   SetIndexBuffer(0,upH,     INDICATOR_DATA); SetIndexStyle(0,ShowHisto ? DRAW_HISTOGRAM : DRAW_NONE,EMPTY,HistoWidth,UpHistoColor);
   SetIndexBuffer(1,dnH,     INDICATOR_DATA); SetIndexStyle(1,ShowHisto ? DRAW_HISTOGRAM : DRAW_NONE,EMPTY,HistoWidth,DnHistoColor);
   SetIndexBuffer(2,prc,     INDICATOR_DATA); SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3,ma,      INDICATOR_DATA); SetIndexStyle(3,DRAW_LINE);  
   SetIndexBuffer(4,upValues,INDICATOR_DATA); SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(5,dnValues,INDICATOR_DATA); SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(6,miValues,INDICATOR_DATA); SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(7,trend);
   SetIndexBuffer(8,valc);
   
      //
      //
      //
      //
      //
                  
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);   
      IndicatorShortName(timeFrameToString(timeFrame)+" Jurik volty bands ("+Length+")");
      
   return(0);
}

//
//
//
//
//

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

//+------------------------------------------------------------------
//|                                                                 
//+------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int i,limit,counted_bars=IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { upH[0] = limit+1; return(0); }
         
   //
   //
   //
   //
   //
            
   if (calculateValue || timeFrame==Period())
   {
      for(i=limit; i>=0; i--)
      {
         double vprice = iMA(NULL,0,1,0,MODE_SMA,Price,i+Shift);
         double cprice = iMA(NULL,0,1,0,MODE_SMA,Price,i);
         double upValue;
         double dnValue;
         double miValue;
         
         iVolty(vprice,upValue,dnValue,miValue,Length,i);
         
         //
         //
         //
         //
         //
         
            if (ZeroBind)
            {
               if (Normalize)
               {
                  upValues[i] =  1;
                  dnValues[i] = -1;
                  double diff = (upValue-miValue);
                     if (diff != 0)
                           prc[i] = (cprice-miValue)/diff;
                     else  prc[i] = 0;              
               }
               else
               {
                  upValues[i] = upValue-miValue;
                  dnValues[i] = dnValue-miValue;
                  prc[i]      = (cprice-miValue);
               }
            }
            else
            {
               upValues[i] = upValue;
               dnValues[i] = dnValue;
               prc[i]      = cprice;
            }               
            if (ShowMiddle)
            {
               if (ZeroBind) 
                     miValues[i] = 0;
               else  miValues[i] = miValue;
            }
         
            //
            //
            //
            //
            //
               
            if (alertsOnZeroCross)
            {
               if (cprice>miValue) trend[i] =  1;
               if (cprice<miValue) trend[i] = -1;
            }               
            else
            {
               if (cprice>upValue)                   trend[i] =  1;
               if (cprice<dnValue)                   trend[i] = -1;
               if (alertsOnAllBreakOuts || alertsOnAllBreakOutBars)
               if (cprice<upValue && cprice>dnValue) trend[i] =  0;
            }
            valc[i] = (i<Bars-1) ? (cprice>miValue)   ? 1 : (cprice<miValue) ? -1 : valc[i+1] : 0; 
            upH[i] = (valc[i] ==  1) ? prc[i] : EMPTY_VALUE;
            dnH[i] = (valc[i] == -1) ? prc[i] : EMPTY_VALUE; 
            manageArrow(i);
            ma[i] = iCustomMa(MaMethod,prc[i],MaPeriod,i,Bars);
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         upH[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,MaPeriod,MaMethod,ShowMiddle,ZeroBind,Normalize,ShowHisto,HistoWidth,UpHistoColor,DnHistoColor,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,0,y);
         dnH[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,MaPeriod,MaMethod,ShowMiddle,ZeroBind,Normalize,ShowHisto,HistoWidth,UpHistoColor,DnHistoColor,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,1,y);
         prc[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,MaPeriod,MaMethod,ShowMiddle,ZeroBind,Normalize,ShowHisto,HistoWidth,UpHistoColor,DnHistoColor,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,2,y);
         ma[i]       = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,MaPeriod,MaMethod,ShowMiddle,ZeroBind,Normalize,ShowHisto,HistoWidth,UpHistoColor,DnHistoColor,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,3,y);
         upValues[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,MaPeriod,MaMethod,ShowMiddle,ZeroBind,Normalize,ShowHisto,HistoWidth,UpHistoColor,DnHistoColor,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,4,y);
         dnValues[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,MaPeriod,MaMethod,ShowMiddle,ZeroBind,Normalize,ShowHisto,HistoWidth,UpHistoColor,DnHistoColor,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,5,y);
         trend[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,MaPeriod,MaMethod,ShowMiddle,ZeroBind,Normalize,ShowHisto,HistoWidth,UpHistoColor,DnHistoColor,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,7,y);
         manageArrow(i);
         if (ShowMiddle)
            miValues[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Length,Price,Shift,MaPeriod,MaMethod,ShowMiddle,ZeroBind,Normalize,ShowHisto,HistoWidth,UpHistoColor,DnHistoColor,alertsOnZeroCross,alertsOnAllBreakOuts,alertsOnAllBreakOutBars,6,y);

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
            for(int k = 1; k < n; k++)
            {
               prc[i+k]      = prc[i]      + (prc[i+n]     -prc[i])     *k/n;
               if (upH[i]   != EMPTY_VALUE) upH[i+k] = prc[i+k];
  	            if (dnH[i]   != EMPTY_VALUE) dnH[i+k] = prc[i+k];
               ma[i+k]       = ma[i]       + (ma[i+n]      -ma[i])      *k/n;
               upValues[i+k] = upValues[i] + (upValues[i+n]-upValues[i])*k/n;
               dnValues[i+k] = dnValues[i] + (dnValues[i+n]-dnValues[i])*k/n;
               if (ShowMiddle) 
               miValues[i+k] = miValues[i] + (miValues[i+n]-miValues[i])*k/n;
                               
            }               
   }                      
   manageAlerts();
   return(0);         
}

  
//+------------------------------------------------------------------
//|                                                                 
//+------------------------------------------------------------------
//
//
//
//
//

double wrk[][6];
#define bsmax  0
#define bsmin  1
#define volty  2
#define vsum   3
#define avolty 4
#define vprice 5
#define avgLen 65

//
//
//
//
//

void iVolty(double tprice, double& upValue, double& dnValue, double& miValue, double length, int i)
{
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; if (r==0) { for(int k=0; k<5; k++) wrk[0][k]=0; return ; }

   //
   //
   //
   //
   //
   
      double hprice = tprice;
      double lprice = tprice;
        wrk[r][vprice] = tprice;

           for (k=1; k<length && (r-k)>=0; k++)
           {
               hprice = MathMax(wrk[r-k][vprice],hprice);
               lprice = MathMin(wrk[r-k][vprice],lprice);
           }
      
      //
      //
      //
      //
      //
      
      double len1 = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1 = MathMax(len1-2.0,0.5);
      double del1 = hprice - wrk[r-1][bsmax];
      double del2 = lprice - wrk[r-1][bsmin];
	
         wrk[r][volty] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty] = MathAbs(del2); 
         wrk[r][vsum] =	wrk[r-1][vsum] + 0.1*(wrk[r][volty]-wrk[r-10][volty]);
   
         double avg = wrk[r][vsum];  for (k=1; k<avgLen && (r-k)>=0 ; k++) avg += wrk[r-k][vsum];
                                                                           avg /= k;
         wrk[r][avolty] = avg;                                           
            if (wrk[r][avolty] > 0)
               double dVolty = wrk[r][volty]/wrk[r][avolty]; else dVolty = 0;   
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
	
         if (del1 > 0) wrk[r][bsmax] = hprice; else wrk[r][bsmax] = hprice - Kv*del1;
         if (del2 < 0) wrk[r][bsmin] = lprice; else wrk[r][bsmin] = lprice - Kv*del2;

   //
   //
   //
   //
   //
      
   dnValue = wrk[r][bsmin];
   upValue = wrk[r][bsmax];
   miValue = (upValue+dnValue)/2.0;
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)ceil(length),r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo+0] = price;
   double avg = price; int k=1;  for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  
   return(avg/(double)k);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}


//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));

      //
      //
      //
      //
      //
            
      static datetime alertTime1 = 0;
      static string   alertWhat1 = "";
      if (alertsOnZeroCross)
      {
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] ==  1) doAlert(alertTime1,alertWhat1,whichBar,"price crossed zero (middle) line up");
            if (trend[whichBar] == -1) doAlert(alertTime1,alertWhat1,whichBar,"price crossed zero (middle) line down");
         }
      }
      else
      {
         if (alertsOnAllBreakOutBars)
               bool condition = true;
         else       condition = (trend[whichBar] != trend[whichBar+1]);
         if (condition)
         {
            if (trend[whichBar] ==  1) doAlert(alertTime1,alertWhat1,whichBar,"price broke upper band");
            if (trend[whichBar] == -1) doAlert(alertTime1,alertWhat1,whichBar,"price broke lower band");
         }
      }         
   }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ",timeFrameToString(timeFrame)+" jurik volty bands ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"jurik volty bands"),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void manageArrow(int i)
{
   if (!calculateValue && arrowsVisible )
   {
         deleteArrow(Time[i]);
         if (trend[i]!=trend[i+1])
         {
            if (trend[i] == 1) drawArrow(i,arrowsUpColor,241,false);
            if (trend[i] ==-1) drawArrow(i,arrowsDnColor,242,true);
         }
   }
}               

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
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