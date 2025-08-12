//+------------------------------------------------------------------+
//|                                             super-signals_v2.mq4 |
//|                Copyright ?2006, Nick Bilak, beluck[AT]gmail.com  |
//|                               Modified by mtuppers[AT]gmail.com  |
//|			                took away time, add periods  |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2006, Nick Bilak"
#property copyright "alterations by Mark Tomlinson"
#property copyright "alterations by Money Duck @ 4xCampus.com"
#property link      "http://www.forex-tsd.com/"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Aqua
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1

//input properties

extern int  dist2           = 21;
extern int  dist1           = 14;
extern bool alertsOn        = true;
extern bool alertsOnCurrent = true;
extern bool alertsMessage   = true;
extern bool alertsSound     = true;
extern bool alertsEmail     = false;

double b1[];
double b2[];
double b3[];
double b4[];


int init()
{
   SetIndexBuffer(0,b1);
   SetIndexBuffer(1,b2);
   SetIndexBuffer(2,b3);
   SetIndexBuffer(3,b4);
   SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,334);
   SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,333);
   SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(1,233);
   SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(0,234);
   return(0);
}
int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit,hhb,llb,hhb1,llb1;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           limit=Bars-counted_bars;
           limit=MathMax(limit,dist1);
           limit=MathMax(limit,dist2);

   //
   //
   //
   //
   //

   for (i=limit;i>=0;i--)
      {
         hhb1 = Highest(NULL,0,MODE_HIGH,dist1,i-dist1/2);
         llb1 = Lowest(NULL,0,MODE_LOW,dist1,i-dist1/2);
         hhb  = Highest(NULL,0,MODE_HIGH,dist2,i-dist2/2);
         llb  = Lowest(NULL,0,MODE_LOW,dist2,i-dist2/2);

            b1[i] = EMPTY_VALUE;
            b2[i] = EMPTY_VALUE;
            b3[i] = EMPTY_VALUE;
            b4[i] = EMPTY_VALUE;
      
         double tr = iATR(NULL,0,50,i);
         if (i==hhb)  b1[i]=High[hhb] +tr;
         if (i==llb)  b2[i]=Low[llb]  -tr;
         if (i==hhb1) b3[i]=High[hhb1]+tr/2;
         if (i==llb1) b4[i]=Low[llb1] -tr/2;
      }
      
   //
   //
   //
   //
   //
   
   if (alertsOn)
      {
         int forBar = 1;
            if (alertsOnCurrent) forBar = 0;
            if (b1[forBar] != EMPTY_VALUE && b3[forBar] != EMPTY_VALUE) doAlert("strong sell");
            if (b1[forBar] != EMPTY_VALUE && b3[forBar] == EMPTY_VALUE) doAlert("sell");
            if (b1[forBar] == EMPTY_VALUE && b3[forBar] != EMPTY_VALUE) doAlert("minor sell or exit buy");
            if (b2[forBar] != EMPTY_VALUE && b4[forBar] != EMPTY_VALUE) doAlert("strong buy");
            if (b2[forBar] != EMPTY_VALUE && b4[forBar] == EMPTY_VALUE) doAlert("buy");
            if (b2[forBar] == EMPTY_VALUE && b4[forBar] != EMPTY_VALUE) doAlert("minor buy or exit sell");
      }
  return(0);
}

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
   string TimePeriod;
   
   if (Period()== 1)       TimePeriod = "1 MIN";
   if (Period()== 5)       TimePeriod = "5 MIN";
   if (Period()== 15)      TimePeriod = "15 MIN";
   if (Period()== 30)      TimePeriod = "30 MIN";
   if (Period()== 60)      TimePeriod = "1 HR";
   if (Period()== 240)     TimePeriod = "4 HR";
   if (Period()== 1440)    TimePeriod = "DAILY";
   if (Period()== 10080)   TimePeriod = "WEEKLY";
   if (Period()== 43200)   TimePeriod = "MONTHLY";

      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ", TimePeriod, " Super signal : ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Super signal "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}