//------------------------------------------------------------------
//
//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1  clrDimGray
#property indicator_color2  clrWhite
#property indicator_color3  clrDodgerBlue
#property indicator_color4  clrDodgerBlue
#property indicator_color5  clrSandyBrown
#property indicator_color6  clrSandyBrown
#property indicator_minimum -1.05
#property indicator_maximum  1.05
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame   = PERIOD_CURRENT;   // Time frame to use
extern int                CCI_Period  = 50;               // CCI Period
extern ENUM_APPLIED_PRICE CCI_Price   = PRICE_TYPICAL;    // Price to use
extern int                MA_Period   = 10;               // MaPeriod (1== no ma)
extern ENUM_MA_METHOD     MA_Method   = MODE_LWMA;        // Ma Method
extern double             levelOb     = 0.9;              // overbought level
extern double             levelOs     = -0.9;             // oversold level 
extern double             Sensitivity = 30;               // Sensitivity for inverse fisher transform
extern int                LineWidth   = 3;                // Lines width
extern bool               Interpolate = true;             // Interpolating when using multi time frame mode 

//
//
//
//
//

double Value[];
double iFish[];
double iFishua[];
double iFishub[];
double iFishda[];
double iFishdb[];
double state[];
double shadow[];
string indicatorFileName;
bool   returnBars;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init() 
{ 
   IndicatorBuffers(8);
   SetIndexBuffer(0,shadow);    SetIndexStyle(0,EMPTY,EMPTY,LineWidth+6);
   SetIndexBuffer(1,iFish);     SetIndexStyle(1,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(2,iFishua);   SetIndexStyle(2,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(3,iFishub);   SetIndexStyle(3,EMPTY,EMPTY,LineWidth); 
   SetIndexBuffer(4,iFishda);   SetIndexStyle(4,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(5,iFishdb);   SetIndexStyle(5,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(6,Value);
   SetIndexBuffer(7,state);
   SetLevelValue(0, levelOs);
   SetLevelValue(1, levelOb);
   SetLevelValue(2, 0);
        indicatorFileName = WindowExpertName();
        returnBars        = TimeFrame==-99;
        TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" ift of CCI ("+(string)CCI_Period+","+(string)MA_Period+","+(string)Sensitivity+")" );
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
   int i,counted_bars = IndicatorCounted(); 
      if (counted_bars < 0) return(-1); 
      if (counted_bars > 0) counted_bars--;  
         int limit=MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { shadow[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
      
   if (TimeFrame==Period())
   {
      if (state[limit] ==  1) CleanPoint(limit,iFishua,iFishub);
      if (state[limit] == -1) CleanPoint(limit,iFishda,iFishdb);
      for (i= limit; i >= 0; i--) Value[i] = (1/Sensitivity)*iCCI(NULL,0,CCI_Period,CCI_Price,i);    
      for (i= limit; i >= 0; i--)    
      {
         double MA = iMAOnArray(Value,0,MA_Period,0,MA_Method,i); 
         iFish[i]  = (MathExp(2.0*MA)-1.0)/(MathExp(2.0*MA)+1.0);
         iFishua[i] = EMPTY_VALUE;
         iFishub[i] = EMPTY_VALUE;
         iFishda[i] = EMPTY_VALUE;
         iFishdb[i] = EMPTY_VALUE;
         if (i<Bars-1)
         {
           shadow[i]  = iFish[i];
           state[i]   = 0;
           if (iFish[i]>levelOb) state[i] =  1;
           if (iFish[i]<levelOs) state[i] = -1;
           if (state[i] ==  1) PlotPoint(i,iFishua,iFishub,iFish);
           if (state[i] == -1) PlotPoint(i,iFishda,iFishdb,iFish);
         }
     }
     return(0); 
    }
    
    //
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));;
   if (state[limit] ==  1) CleanPoint(limit,iFishua,iFishub);
   if (state[limit] == -1) CleanPoint(limit,iFishda,iFishdb);
   for (i=limit;i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
        iFish[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,CCI_Period,CCI_Price,MA_Period,MA_Method,levelOb,levelOs,Sensitivity,1,y);
        state[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,CCI_Period,CCI_Price,MA_Period,MA_Method,levelOb,levelOs,Sensitivity,7,y);
        shadow[i]  = iFish[i];
        iFishua[i] = EMPTY_VALUE;
        iFishub[i] = EMPTY_VALUE;
        iFishda[i] = EMPTY_VALUE;
        iFishdb[i] = EMPTY_VALUE;
        
          //
          //
          //
          //
          //
            
          if (!Interpolate || (i>0 &&y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;

          //
          //
          //
          //
          //

          int n,s; datetime time = iTime(NULL,TimeFrame,y);
             for(n = 1; i+n<Bars && Time[i+n] >= time; n++) continue;
             for(s = 1; i+n<Bars && i+s<Bars && s<n; s++)
             {
                iFish[i+s]  = iFish[i] + (iFish[i+n] - iFish[i]) * s/n;
                shadow[i+s] = iFish[i+s];
  	          }   
   }
   for (i=limit;i>=0;i--)
   {
      if (state[i] ==  1) PlotPoint(i,iFishua,iFishub,iFish);
      if (state[i] == -1) PlotPoint(i,iFishda,iFishdb,iFish);
   }
return(0);
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
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
