//+------------------------------------------------------------------+
//|                                                    Color RSI.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      ""

#property indicator_separate_window
#property indicator_buffers   3
#property indicator_minimum  35
#property indicator_maximum  65
#property indicator_color1 Yellow
#property indicator_color2 LimeGreen
#property indicator_color3 Tomato
#property indicator_width2 1
#property indicator_width3 1
#define SignalName "RSISignal"

#property indicator_level1 50
#property indicator_levelcolor Yellow
#property indicator_levelstyle 0

//---- input parameters
//
//
//
//

extern int       RSIPeriod          = 42;
extern int       PriceType          =  0;
extern string    timeFrame          = "Current Time Frame";
extern int       overBought         = 50;
extern int       overSold           = 50;
extern bool      showArrows         = false;
extern bool      alertsOn           = false;
extern bool      alertsMessage      = false;
extern bool      alertsSound        = false;
extern bool      alertsEmail        = false;
extern int       repaintSignalStep  =  0;
extern int       repaintSignalPrice =  0;
  
//---- buffers
//
//
//
//
//

double   RSIBuffer[];
double   Upper[];
double   Lower[];
double   Prices[];

//
//
//
//
//

int      TimeFrame;
datetime TimeArray[];
int      maxArrows;
int      SignalGap;
string   prevSignal;
int      prevBar;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   string shortName  = "RSI (";
      SetIndexBuffer(0,RSIBuffer);
      SetIndexBuffer(1,Upper);
      SetIndexBuffer(2,Lower);
      SetIndexLabel(0,"RSI");
      SetIndexLabel(1,NULL);
      SetIndexLabel(2,NULL);
         
         //
         //
         //
         //
         //
         

      TimeFrame         = stringToTimeFrame(timeFrame);
      if (TimeFrame != Period()) shortName  = shortName+TimeFrameToString(TimeFrame)+",";
                                 shortName  = shortName+PriceTypeToString(PriceType);
      
            if (overBought < overSold) overBought = overSold;
            if (overBought < 100)      shortName  = shortName+","+overBought;
            if (overSold   >   0)      shortName  = shortName+","+overSold;
      IndicatorShortName(shortName+") ("+RSIPeriod+")");
   return(0);
}

//
//
//
//
//

int deinit()
{
   DeleteArrows();
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int    counted_bars=IndicatorCounted();
   int    limit;
   int    i,y;
   
   
   
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit=MathMax(Bars-counted_bars,TimeFrame/Period());
         ArrayCopySeries(TimeArray ,MODE_TIME ,NULL,TimeFrame);
            
      
   //
   //
   //
   //
   //
   
   for(i=0,y=0; i<limit; i++)
      {
            if(Time[i]<TimeArray[y]) y++;
               RSIBuffer[i] = iRSI(NULL,TimeFrame,RSIPeriod,PriceType,y);
      }
   for(i=limit; i>=0; i--)
      {
            if (RSIBuffer[i] > overBought) { Upper[i] = RSIBuffer[i]; Upper[i+1] = RSIBuffer[i+1]; }
            else                           { Upper[i] = EMPTY_VALUE;
                                           if (Upper[i+2] == EMPTY_VALUE)
                                               Upper[i+1]  = EMPTY_VALUE; }
            if (RSIBuffer[i] < overSold)   { Lower[i] = RSIBuffer[i]; Lower[i+1] = RSIBuffer[i+1]; }
            else                           { Lower[i] = EMPTY_VALUE;
                                           if (Lower[i+2] == EMPTY_VALUE)
                                               Lower[i+1]  = EMPTY_VALUE; }
      }
   
   //
   //
   //
   //
   //
   
   DeleteArrows();
   if (showArrows)
      {
         SignalGap = MathCeil(iATR(NULL,0,50,0)/Point);
         for (i=WindowBarsPerChart(); i>=0 ;i--)
            {
               if (RSIBuffer[i]>overBought && RSIBuffer[i+1]<overBought) DrawArrow(i,"up");
               if (RSIBuffer[i]<overSold   && RSIBuffer[i+1]>overSold)   DrawArrow(i,"down");
               
               //
               //
               //    should we try to repaint the previous alert signal
               //
               //
               
               if ((TimeFrame==Period()) && (repaintSignalStep>0))
               if (prevBar==i+1)
               {
                  double currPrice = iMA(NULL,0,1,0,MODE_SMA,repaintSignalPrice,i);
                  double prevPrice = iMA(NULL,0,1,0,MODE_SMA,repaintSignalPrice,i+1);
                  
                  //
                  //
                  //
                  //
                  //
                  
                  if (prevSignal == "down")
                     if (RSIBuffer[i]<overSold)
                     if ((prevPrice-currPrice)/Point >= repaintSignalStep)
                        {
                           ObjectSet(StringConcatenate(SignalName,maxArrows),OBJPROP_TIME1,Time[i]);
                           ObjectSet(StringConcatenate(SignalName,maxArrows),OBJPROP_PRICE1,Low[i] -(SignalGap*Point));
                        }
                  if (prevSignal == "up")
                     if (RSIBuffer[i]>overBought)
                     if ((currPrice-prevPrice)/Point >= repaintSignalStep)
                        {
                           ObjectSet(StringConcatenate(SignalName,maxArrows),OBJPROP_TIME1,Time[i]);
                           ObjectSet(StringConcatenate(SignalName,maxArrows),OBJPROP_PRICE1,High[i]+(SignalGap*Point));
                        }
                }                              
            }
      }            

   //
   //
   //
   //
   
   if (alertsOn) {
            if (RSIBuffer[0]>overBought && RSIBuffer[1]<overBought) doAlert(overBought+" line crossed up");
            if (RSIBuffer[0]<overSold   && RSIBuffer[1]>overSold)   doAlert(overBought+" line crossed down");
         }

   //
   //
   //
   //
   //
 
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

void DrawArrow(int i,string type)
{
   string name;
      
   maxArrows++;
   name = StringConcatenate(SignalName,maxArrows);
         ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         if (type=="up")
            {
               ObjectSet(name,OBJPROP_PRICE1,High[i]+(SignalGap*Point));
               ObjectSet(name,OBJPROP_ARROWCODE,241);
               ObjectSet(name,OBJPROP_COLOR,LimeGreen);
            }
         else
            {
               ObjectSet(name,OBJPROP_PRICE1,Low[i]-(SignalGap*Point));
               ObjectSet(name,OBJPROP_ARROWCODE,242);
               ObjectSet(name,OBJPROP_COLOR,Tomato);
            }
   prevSignal = type;
   prevBar    = i;
}
void DeleteArrows()
{
   while(maxArrows>0) { ObjectDelete(StringConcatenate(SignalName,maxArrows)); maxArrows--; }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

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
            
          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," RSI ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsSound)   PlaySound("alert2.wav");
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," RSI crossing"),message);
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

string PriceTypeToString(int pt)
{
   string answer;
   switch(pt)
   {
      case 0:  answer = "Close"    ; break; 
      case 1:  answer = "Open"     ; break;
      case 2:  answer = "High"     ; break;
      case 3:  answer = "Low"      ; break;
      case 4:  answer = "Median"   ; break;
      case 5:  answer = "Typical"  ; break;
      case 6:  answer = "Wighted"  ; break;
      default: answer = "Invalid price field requested";
                                    Alert(answer);
   }
   return(answer);
}
int stringToTimeFrame(string tfs)
{
   int tf=0;
       tfs = StringUpperCase(tfs);
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
         if (tf<Period()) tf=Period();
  return(tf);
}
string TimeFrameToString(int tf)
{
   string tfs="Current time frame";
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN1";
   }
   return(tfs);
}

//
//
//
//
//

string StringUpperCase(string str)
{
   string   s = str;
   int      lenght = StringLen(str) - 1;
   int      char;
   
   while(lenght >= 0)
      {
         char = StringGetChar(s, lenght);
         
         //
         //
         //
         //
         //
         
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                  s = StringSetChar(s, lenght, char - 32);
         else 
              if(char > -33 && char < 0)
                  s = StringSetChar(s, lenght, char + 224);
         lenght--;
   }
   
   //
   //
   //
   //
   //

//+------------------------------------------------------------------+
   
   return(s);
}

