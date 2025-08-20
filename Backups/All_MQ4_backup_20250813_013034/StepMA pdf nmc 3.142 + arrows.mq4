//------------------------------------------------------------------
#property copyright ""
#property link      ""
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Orange
#property indicator_color4  DodgerBlue
#property indicator_color5  Magenta


//
//

enum enPModes
{
   pr_hl,      // High/low
   pr_lh,      // Low/high
   pr_co,      // Close/open
   pr_oc,      // Open/close
   pr_hahl,    // Heiken ashi high/low
   pr_halh,    // Heiken ashi low/high
   pr_haco,    // Heiken ashi close/open
   pr_haoc     // Heiken ashi open/close
};

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen,     // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};


//
//
//


extern bool             PriceFirstList      = true;        // First or second price list (below)
extern enPModes         MaPriceFirstList    = pr_hl;
extern enPrices         MaPriceSecondList   = pr_close;

extern int    PdfMaLength         = 10;      // Pdfma Length
extern double Sensitivity         = 5.0;     // Sensivity Factor
extern double StepSize            = 2.0;     // Constant Step Size
extern double Variance            = 1.0;     // Pdfma variance
extern double Mean                = 0.0;     // Pdfma mean
extern enPrices         StepMaPrice         = pr_close;
extern bool             ATRScaling          = false;

extern int              LineWidth           = 3;
extern int              Shift               = 0;


extern bool             alertsOn            = false;
extern bool             alertsOnCurrent     = true;
extern bool             alertsMessage       = true;
extern bool             alertsNotification  = false;
extern bool             alertsSound         = false;
extern bool             alertsEmail         = false;

extern bool             ShowArrows          = true;
extern int              arrowSize           = 2;
extern int              uparrowCode         = 233;
extern int              dnarrowCode         = 234;
extern double           uparrowGap          = 0.5;
extern double           dnarrowGap          = 0.5;
// extern bool             ArrowsOnFirstBar    = true;

//
//
//
//
//

double LineBuffer[];
double DnBuffera[];
double DnBufferb[];
double arrowUp[];
double arrowDn[];
double smin[];
double smax[];
double trend[];
double _coeffs[];



//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define maxx 3.5
int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,LineBuffer); SetIndexShift(0,Shift); SetIndexLabel(0,"StepMA("+PdfMaLength+","+Sensitivity+","+StepSize+")");
   SetIndexBuffer(1,DnBuffera);  SetIndexShift(1,Shift);
   SetIndexBuffer(2,DnBufferb);  SetIndexShift(2,Shift);
   SetIndexBuffer(3,arrowUp);   
   SetIndexBuffer(4,arrowDn);  
   SetIndexBuffer(5,smin);
   SetIndexBuffer(6,smax);
   SetIndexBuffer(7,trend);

   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,LineWidth);    // SetIndexLabel(0,NULL);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,LineWidth);    // SetIndexLabel(1,NULL);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,LineWidth);    // SetIndexLabel(2,NULL);


   if (ShowArrows)
   {
     SetIndexStyle(3,DRAW_ARROW,0,arrowSize); SetIndexArrow(3,uparrowCode);
     SetIndexStyle(4,DRAW_ARROW,0,arrowSize); SetIndexArrow(4,dnarrowCode);   
   }
   else
   {
     SetIndexStyle(3,DRAW_NONE);
     SetIndexStyle(4,DRAW_NONE);
   }       
   IndicatorShortName("StepMA("+PdfMaLength+","+Sensitivity+","+StepSize+")");
      PdfMaLength = MathMax(PdfMaLength,2);
      ArrayResize(_coeffs,PdfMaLength);   
         double step = maxx/(PdfMaLength-1); for(int i=0; i<PdfMaLength; i++) _coeffs[i] = pdf(i*step,Variance,Mean*maxx);

   return(0);
}
int deinit() { return(0); }     

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int i, counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

      double useSize = Point*MathPow(10,MathMod(Digits,2));
      if (trend[limit]==-1) CleanPoint(limit,DnBuffera,DnBufferb);
      for(i=limit; i>=0; i--)
      {
         double thigh;
         double tlow;


         if(PriceFirstList==true){

            if (MaPriceFirstList == pr_hl)    { thigh=iPdfma(getPrice(pr_high,Open,Close,High,Low,i,0),PdfMaLength,_coeffs,i,0);
                                               tlow =iPdfma(getPrice(pr_low,Open,Close,High,Low,i,1),PdfMaLength,_coeffs,i,1); }

            if (MaPriceFirstList == pr_lh)    { thigh=iPdfma(getPrice(pr_low,Open,Close,High,Low,i,0),PdfMaLength,_coeffs,i,0);
                                               tlow =iPdfma(getPrice(pr_high,Open,Close,High,Low,i,1),PdfMaLength,_coeffs,i,1); }

            if (MaPriceFirstList == pr_co)    { thigh=iPdfma(getPrice(pr_close,Open,Close,High,Low,i,0),PdfMaLength,_coeffs,i,0);
                                               tlow =iPdfma(getPrice(pr_open,Open,Close,High,Low,i,1),PdfMaLength,_coeffs,i,1); }

            if (MaPriceFirstList == pr_oc)    { thigh=iPdfma(getPrice(pr_open,Open,Close,High,Low,i,0),PdfMaLength,_coeffs,i,0);
                                               tlow =iPdfma(getPrice(pr_close,Open,Close,High,Low,i,1),PdfMaLength,_coeffs,i,1); }

            if (MaPriceFirstList == pr_hahl)  { thigh=iPdfma(getPrice(pr_hahigh,Open,Close,High,Low,i,0),PdfMaLength,_coeffs,i,0);
                                               tlow =iPdfma(getPrice(pr_halow,Open,Close,High,Low,i,1),PdfMaLength,_coeffs,i,1); }

            if (MaPriceFirstList == pr_halh)  { thigh=iPdfma(getPrice(pr_halow,Open,Close,High,Low,i,0),PdfMaLength,_coeffs,i,0);
                                               tlow =iPdfma(getPrice(pr_hahigh,Open,Close,High,Low,i,1),PdfMaLength,_coeffs,i,1); }

            if (MaPriceFirstList == pr_haco)  { thigh=iPdfma(getPrice(pr_haclose,Open,Close,High,Low,i,0),PdfMaLength,_coeffs,i,0);
                                               tlow =iPdfma(getPrice(pr_haopen,Open,Close,High,Low,i,1),PdfMaLength,_coeffs,i,1); }

            if (MaPriceFirstList == pr_haoc)  { thigh=iPdfma(getPrice(pr_haopen,Open,Close,High,Low,i,0),PdfMaLength,_coeffs,i,0);
                                               tlow =iPdfma(getPrice(pr_haclose,Open,Close,High,Low,i,1),PdfMaLength,_coeffs,i,1); }

        }  else  {

/*
           double maprmode = getPrice(MaPriceSecondList,Open,Close,High,Low,i,0);
           thigh=iPdfma(maprmode,PdfMaLength,_coeffs,i,0);
           tlow =iPdfma(maprmode,PdfMaLength,_coeffs,i,1);
*/

           thigh=iPdfma(getPrice(MaPriceSecondList,Open,Close,High,Low,i,0),PdfMaLength,_coeffs,i,0);
           tlow =iPdfma(getPrice(MaPriceSecondList,Open,Close,High,Low,i,1),PdfMaLength,_coeffs,i,1);

        }


           double smprice = getPrice(StepMaPrice,Open,Close,High,Low,i,2);
   	   
       if (ATRScaling == false)    
           { LineBuffer[i] = iStepMa(Sensitivity,StepSize,useSize,thigh,tlow,smprice,i); }
           else
           { int ATRPeriod = NormalizeDouble(MathRound(10.0*StepSize),0);  double SensitScal = 0.1*Sensitivity;      
             LineBuffer[i] = iStepMa(SensitScal,iATR(NULL,0,ATRPeriod,i),1.0,thigh,tlow,smprice,i); }    // e.g. SensitScal = 0.5, ATRPeriod = 50



   	   DnBuffera[i]  = EMPTY_VALUE;
   	   DnBufferb[i]  = EMPTY_VALUE;
   	   if (trend[i]==-1) PlotPoint(i,DnBuffera,DnBufferb,LineBuffer);
   	   
         //
         //
         //
         //
         //
      
         arrowUp[i] = EMPTY_VALUE;
         arrowDn[i] = EMPTY_VALUE;
         if (trend[i]!= trend[i+1])
         if (trend[i] == 1)
               arrowUp[i] = LineBuffer[i] - iATR(NULL,0,20,i)*uparrowGap;
         else  arrowDn[i] = LineBuffer[i] + iATR(NULL,0,20,i)*dnarrowGap;
      }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      if (alertsOnCurrent)
            int whichBar = 0;
      else      whichBar = 1;
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("up");
      else  doAlert("down");       
   }   
	return(0);	
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workStep[][3];
#define _smin   0
#define _smax   1
#define _trend  2

double iStepMa(double sensitivity, double stepSize, double stepMulti, double phigh, double plow, double pprice, int r)
{
   if (ArrayRange(workStep,0)!=Bars) ArrayResize(workStep,Bars);
   if (sensitivity == 0) sensitivity = 0.0001; r = Bars-r-1;
   if (stepSize    == 0) stepSize    = 0.0001;
      double result; 
	   double size = sensitivity*stepSize;

      //
      //
      //
      //
      //
      
      if (r==0)
      {
         workStep[r][_smax]  = phigh+2.0*size*stepMulti;
         workStep[r][_smin]  = plow -2.0*size*stepMulti;
         workStep[r][_trend] = 1;
         return(pprice);
      }

      //
      //
      //
      //
      //
      
      workStep[r][_smax]  = phigh+2.0*size*stepMulti;
      workStep[r][_smin]  = plow -2.0*size*stepMulti;
      workStep[r][_trend] = workStep[r-1][_trend];
            if (pprice>workStep[r-1][_smax]) workStep[r][_trend] =  1;
            if (pprice<workStep[r-1][_smin]) workStep[r][_trend] = -1;
            if (workStep[r][_trend] ==  1) { if (workStep[r][_smin] < workStep[r-1][_smin]) workStep[r][_smin]=workStep[r-1][_smin]; result = workStep[r][_smin]+size*stepMulti; }
            if (workStep[r][_trend] == -1) { if (workStep[r][_smax] > workStep[r-1][_smax]) workStep[r][_smax]=workStep[r-1][_smax]; result = workStep[r][_smax]-size*stepMulti; }
      trend[Bars-r-1] = workStep[r][_trend]; 

   return(result); 
} 

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" StepMa pdf changed trend to "+doWhat;
             if (alertsMessage)      Alert(message);
             if (alertsNotification) SendNotification(message);
             if (alertsEmail)        SendMail(StringConcatenate(Symbol()," StepMa pdf "),message);
             if (alertsSound)        PlaySound("alert2.wav");
      }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//    normal probability density function
//
//

#define Pi 3.141592653589793238462643

double pdf(double x, double variance=1.0, double mean=0) { return((1.0/MathSqrt(2*Pi*MathPow(variance,2))*MathExp(-MathPow(x-mean,2)/(2*MathPow(variance,2))))); }
double workPdfma[][2];
double iPdfma(double price, double period, double& coeffs[], int r, int instanceNo=0)
{
   if (ArraySize(workPdfma)!= Bars) ArrayResize(workPdfma,Bars); r = Bars-r-1;
   
   //
   //
   //
   //
   //
   
   workPdfma[r][instanceNo] = price;
      double sumw = coeffs[0];
      double sum  = coeffs[0]*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = coeffs[k];
                sumw  += weight;
                sum   += weight*workPdfma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

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

//
//
//
//
//

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances 3
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               if (haClose<haOpen)  
                     return((haLow+haClose)/2.0);
                     return(haClose);
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               if (close[i]<open[i])      
                     return((low[i]+close[i])/2.0);   
                     return(close[i]);     
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}

//
//
//
//
//
//