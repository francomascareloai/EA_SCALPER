//+------------------------------------------------------------------+
//|                                                       TMA+CG.mq4 |
//|                                                           mladen |
//| arrows coded acording to idea presented by rajiv                 |                                                                                |
//+------------------------------------------------------------------+                                                             |

//#property copyright "rajivxxx"
//#property link      "rajivxxx@gmail.com"



// chart window settings
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  clrLimeGreen	//middle line color
#property indicator_color2  clrLimeGreen	//upper band color
#property indicator_color3  clrLimeGreen	//lower band color
#property indicator_color4  clrSkyBlue	//up arrow
#property indicator_color5  clrCrimson	//down arrow
#property indicator_style1  STYLE_DASH	//centerline style
#property indicator_width1  1 //middle band line width
#property indicator_width2  2 //upper band line width
#property indicator_width3  2 //lower band line width

//----extern 
extern string TimeFrame       = "current time frame";
extern int    HalfLength      = 33;
extern int    Price           = PRICE_WEIGHTED;
extern double BandsDeviations = 2.5;
extern bool   Interpolate     = true;  //does what exactly?
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = false;
extern bool   alertsOnHighLow = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsEmail     = false;

//----
double tmBuffer[];   //timeframe buffer?
double upBuffer[];
double dnBuffer[];
double wuBuffer[];   //what starts with w?
double wdBuffer[];
double upArrow[];    //buffers for the signal arrows presumably
double dnArrow[];


//----
string IndicatorFileName;
bool   calculatingTma = false;
bool   returningBars  = false;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   timeFrame  = stringToTimeFrame(TimeFrame);
   HalfLength = MathMax(HalfLength,1);		//error protect? note halflength difference

   
      IndicatorBuffers(7);
         SetIndexBuffer(0,tmBuffer);  SetIndexDrawBegin(0,HalfLength);
         SetIndexBuffer(1,upBuffer);  SetIndexDrawBegin(1,HalfLength);
         SetIndexBuffer(2,dnBuffer);  SetIndexDrawBegin(2,HalfLength);
         
         SetIndexBuffer(3,dnArrow);   SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,233);
         SetIndexBuffer(4,upArrow);   SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,234);
         
         SetIndexBuffer(5,wuBuffer);
         SetIndexBuffer(6,wdBuffer);


         
		if (TimeFrame=="calculateTma")  { calculatingTma=true; return(0); }
        if (TimeFrame=="returnBars")    { returningBars=true;  return(0); }

   IndicatorFileName = WindowExpertName();
   
	return(0);
}
//----------
int deinit() { return(0); }





















//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   



int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=MathMin(Bars-1,Bars-counted_bars+HalfLength);

           if (returningBars)  { tmBuffer[0] = limit; return(0); }
           if (calculatingTma) { calculateTma(limit); return(0); }
           if (timeFrame > Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,IndicatorFileName,"returnBars",0,0)*timeFrame/Period()));

//----
   
 	for(i = limit; i >= 0; i--)
   {
      int      shift1 = iBarShift(NULL,timeFrame,Time[i]);
      datetime time1  = iTime    (NULL,timeFrame,shift1);

      //
      //
      //
      //
      //
      
         tmBuffer[i] = iCustom(NULL,timeFrame,IndicatorFileName,"calculateTma",HalfLength,Price,BandsDeviations,0,shift1);
         upBuffer[i] = iCustom(NULL,timeFrame,IndicatorFileName,"calculateTma",HalfLength,Price,BandsDeviations,1,shift1);
         dnBuffer[i] = iCustom(NULL,timeFrame,IndicatorFileName,"calculateTma",HalfLength,Price,BandsDeviations,2,shift1);

         upArrow[i] = EMPTY_VALUE;
         dnArrow[i] = EMPTY_VALUE;            
            if (High[i+1]>upBuffer[i+1] && Close[i+1]>Open[i+1] && Close[i]<Open[i]) upArrow[i] = High[i]+iATR(NULL,0,20,i);
            if ( Low[i+1]<dnBuffer[i+1] && Close[i+1]<Open[i+1] && Close[i]>Open[i]) dnArrow[i] = High[i]-iATR(NULL,0,20,i);

         if (timeFrame <= Period() || shift1==iBarShift(NULL,timeFrame,Time[i-1])) continue;
         if (!Interpolate) continue;

      //
      //
      //
      //
      //

         for(int n = 1; i+n < Bars && Time[i+n] >= time1; n++) continue;
         double factor = 1.0 / n;
         for(int k = 1; k < n; k++)
            {
               tmBuffer[i+k] = k*factor*tmBuffer[i+n] + (1.0-k*factor)*tmBuffer[i];
               upBuffer[i+k] = k*factor*upBuffer[i+n] + (1.0-k*factor)*upBuffer[i];
               dnBuffer[i+k] = k*factor*dnBuffer[i+n] + (1.0-k*factor)*dnBuffer[i];
            }               
   }

   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      if (alertsOnCurrent)
            int forBar = 0;
      else      forBar = 1;
      if (alertsOnHighLow)       
      {
         if (High[forBar] > upBuffer[forBar] && High[forBar+1] < upBuffer[forBar+1]) doAlert("high penetrated upper bar"+" on TF:"+TimeFrame);
         if (Low[forBar]  < dnBuffer[forBar] && Low[forBar+1]  > dnBuffer[forBar+1]) doAlert("low penetrated lower bar"+" on TF:"+TimeFrame);
      }
      else
      {
         if (Close[forBar] > upBuffer[forBar] && Close[forBar+1] < upBuffer[forBar+1]) doAlert("close penetrated upper bar"+" on TF:"+TimeFrame);
         if (Close[forBar] < dnBuffer[forBar] && Close[forBar+1] > dnBuffer[forBar+1]) doAlert("close penetrated lower bar"+" on TF:"+TimeFrame);
      }
   } 

   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void calculateTma(int limit)
{
   int i,j,k;
   double FullLength = 2.0*HalfLength+1.0;
   
   //
   //
   //
   //
   //
   
   for (i=limit; i>=0; i--)
   {
      double sum  = (HalfLength+1)*iMA(NULL,0,1,0,MODE_SMA,Price,i);
      double sumw = (HalfLength+1);
      for(j=1, k=HalfLength; j<=HalfLength; j++, k--)
      {
         sum  += k*iMA(NULL,0,1,0,MODE_SMA,Price,i+j);
         sumw += k;

         if (j<=i)
         {
            sum  += k*iMA(NULL,0,1,0,MODE_SMA,Price,i-j);
            sumw += k;
         }
      }
      tmBuffer[i] = sum/sumw;

      //
      //
      //
      //
      //
            
         double diff = iMA(NULL,0,1,0,MODE_SMA,Price,i)-tmBuffer[i];
         if (i> (Bars-HalfLength-1)) continue;
         if (i==(Bars-HalfLength-1))
         {
            upBuffer[i] = tmBuffer[i];
            dnBuffer[i] = tmBuffer[i];
            if (diff>=0)
               {
                  wuBuffer[i] = MathPow(diff,2);
                  wdBuffer[i] = 0;
               }
            else
               {               
                  wdBuffer[i] = MathPow(diff,2);
                  wuBuffer[i] = 0;
               }                  
            continue;
         }
      
         //
         //
         //
         //
         //
         
         if(diff>=0)
            {
               wuBuffer[i] = (wuBuffer[i+1]*(FullLength-1)+MathPow(diff,2))/FullLength;
               wdBuffer[i] =  wdBuffer[i+1]*(FullLength-1)/FullLength;
            }
         else
            {
               wdBuffer[i] = (wdBuffer[i+1]*(FullLength-1)+MathPow(diff,2))/FullLength;
               wuBuffer[i] =  wuBuffer[i+1]*(FullLength-1)/FullLength;
            }
         upBuffer[i] = tmBuffer[i] + BandsDeviations*MathSqrt(wuBuffer[i]);
         dnBuffer[i] = tmBuffer[i] - BandsDeviations*MathSqrt(wdBuffer[i]);
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

void doAlert(string doWhat)
{
   static string   previousAlert="";
   static datetime previousTime;
   string message;

   //
   //
   //
   //
   //
   
   if (previousAlert!=doWhat || previousTime!=Time[0]) 
   {
      previousAlert = doWhat;
      previousTime  = Time[0];

      message= StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," THA : ",doWhat);
         if (alertsMessage) Alert(message);
         if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"TMA "),message);
         if (alertsSound)   PlaySound("alert2.wav");
    }
}

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   for(int l = StringLen(tfs)-1; l >= 0; l--)
   {
      int char2 = StringGetChar(tfs,l);
          if((char2 > 96 && char2 < 123) || (char2 > 223 && char2 < 256))
               tfs = StringSetChar(tfs, 1, char2 - 32);
          else 
              if(char2 > -33 && char2 < 0)
                  tfs = StringSetChar(tfs, 1, char2 + 224);
   }
   int tf=0;
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
         if (tf==0 || tf<Period())      tf=Period();
   return(tf);
} 

//test