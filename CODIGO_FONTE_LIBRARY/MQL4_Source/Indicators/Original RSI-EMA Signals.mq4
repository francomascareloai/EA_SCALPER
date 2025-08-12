//+------------------------------------------------------------------+
//|RSI-EMA Signals    jan 22, 2011      Original RSI-EMA Signals.mq4 |
//|                                                          Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+


#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Orange
#property indicator_width1 2

extern string TimeFrame        = "M5";
extern int    RsiPeriod        = 14;
extern int    MaType           = MODE_EMA;
extern int    MaPeriod         = 40;
extern bool   Interpolate      = true;
extern string arrowsIdentifier = "RsiEmaArrows";
extern color  arrowsUpColor    = Lime;
extern color  arrowsDnColor    = Red;

extern bool   alertsOn          = true;
extern bool   alertsSound       = true;
extern bool   alertsOnCurrent   = false;
extern bool   alertsMessage     = false;
extern bool   alertsEmail       = false;

double rsi[],ema[],trend[];

string indicatorFileName;
bool   calculating   = false;
bool   returningBars = false;
int    timeFrame;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   
   IndicatorBuffers(3);      
   SetIndexBuffer(0,rsi);     SetIndexLabel(0,"rsi");
   SetIndexBuffer(1,ema);     SetIndexLabel(1,"ema");
   SetIndexBuffer(2,trend);   SetIndexLabel(2,"trend");
   if (TimeFrame=="calculate")
   {
      calculating=true;
      return(0);
   }
   if (TimeFrame=="returnBars")
   {
      returningBars=true;
      return(0);
   }
   timeFrame = stringToTimeFrame(TimeFrame);
      
   indicatorFileName = WindowExpertName();
   IndicatorShortName("RK-ml-RSI_EMA_mtf v1.2 "+tf());
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
      deleteArrows();
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars < 0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returningBars)  { rsi[0] = limit+1; return(0); }
         if (timeFrame > Period()) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));

   //
   //
   //
   //
   //

     if (calculating)
     {
         for(i=0; i<limit; i++) rsi[i] = iRSI(NULL,0,RsiPeriod,PRICE_CLOSE,i);
         for(i=0; i<limit; i++) ema[i] = iMAOnArray(rsi,0,MaPeriod,0,MaType,i);
         return(0);
     }         
     for(i=limit; i>=0; i--)
     {
         int y = iBarShift(NULL,timeFrame,Time[i]);
            rsi[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculate",RsiPeriod,MaType,MaPeriod,0,y);
            ema[i]   = iCustom(NULL,timeFrame,indicatorFileName,"calculate",RsiPeriod,MaType,MaPeriod,1,y);
            
            //
            //
            //    must be done before interpolation
            //
            //
            
                 trend[i] = trend[i+1];
                  if (rsi[i]>ema[i]) trend[i]= 1;
                  if (rsi[i]<ema[i]) trend[i]=-1;
                  
                  if (trend[i]!=trend[i+1])
                  {
                     if (trend[i] == 1) drawArrow(i,arrowsUpColor,233,false);
                     if (trend[i] ==-1) drawArrow(i,arrowsDnColor,234,true);
                  }

            //
            //
            //
            //
            //
      
               if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
               if (!Interpolate) continue;

            //
            //
            //
            //
            //

            datetime time = iTime(NULL,timeFrame,y);
               for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               double factor = 1.0 / n;
               for(int k = 1; k < n; k++)
               {
                  rsi[i+k] = k*factor*rsi[i+n] + (1.0-k*factor)*rsi[i];
                  ema[i+k] = k*factor*ema[i+n] + (1.0-k*factor)*ema[i];
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
           int whichBar = 0;
      else     whichBar = 1;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert("up");
         if (trend[whichBar] ==-1) doAlert("down");
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

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," RSI crossed EMA ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"RsiEma"),message);
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

int stringToTimeFrame(string tfs)
{
   for(int l = StringLen(tfs)-1; l >= 0; l--)
   {
      int char = StringGetChar(tfs,l);
          if((char > 96 && char < 123) || (char > 223 && char < 256))
               tfs = StringSetChar(tfs, l, char - 32);
          else 
              if(char > -33 && char < 0)
                  tfs = StringSetChar(tfs, l, char + 224);
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


string tf()
{
   switch(timeFrame)
   {
      case PERIOD_M1:  return("M(1)");
      case PERIOD_M5:  return("M(5)");
      case PERIOD_M15: return("M(15)");
      case PERIOD_M30: return("M(30)");
      case PERIOD_H1:  return("H(1)");
      case PERIOD_H4:  return("H(4)");
      case PERIOD_D1:  return("D(1)");
      case PERIOD_W1:  return("W(1)");
      case PERIOD_MN1: return("MN(1)");
      default:         return("Unknown timeframe");
   }
}