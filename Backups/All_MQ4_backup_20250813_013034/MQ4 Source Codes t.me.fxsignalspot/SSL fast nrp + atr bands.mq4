//+------------------------------------------------------------------+
//|                                                     SSL fast.mq4 |
//|                                                           mladen |
//|                                                                  |
//| initial SSL for metatrader developed by Kalenzo                  |
//+------------------------------------------------------------------+
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_label1  "SSL"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrCornflowerBlue
#property indicator_width1  2
#property indicator_label2  "SSL"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_width2  2
#property indicator_label3  "SSL"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_width3  2
#property indicator_label4  "Upper atr band"
#property indicator_color4  clrGray 
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Lower atr band"
#property indicator_color5  clrGray 
#property indicator_style5  STYLE_DOT
#property strict

//
//
//
//
//

input int    Lb              = 10;                // Look back period
input int    AtrPeriod       = 30;                // Atr period
input double KATR            = 2.0;               // Atr deviation
input bool   DrawUpperBand   = true;              // Show upper band true/false?
input bool   DrawLowerBand   = true;              // Show lower band true/false?
input bool   alertsOn        = true;              // Alerts on true/false?
input bool   alertsOnCurrent = false;             // Alerts on open bar true/false?
input bool   alertsMessage   = true;              // Alerts popup message true/false?
input bool   alertsSound     = false;             // Alerts sound true/false?
input bool   alertsEmail     = false;             // Alerts email true/false?
input bool   alertsPushNotif = false;             // Alerts notification true/false?
input string soundfile       = "alert2.wav";      // Sound file for alerts

double ssl[],sslda[],ssldb[],keltUp[],keltDn[],Hlv[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0,ssl,   INDICATOR_DATA); 
   SetIndexBuffer(1,sslda, INDICATOR_DATA);
   SetIndexBuffer(2,ssldb, INDICATOR_DATA);
   SetIndexBuffer(3,keltUp,INDICATOR_DATA); SetIndexStyle(3, DrawUpperBand  ? DRAW_LINE : DRAW_NONE);    
   SetIndexBuffer(4,keltDn,INDICATOR_DATA); SetIndexStyle(4, DrawLowerBand  ? DRAW_LINE : DRAW_NONE);    
   SetIndexBuffer(5,Hlv);
return(INIT_SUCCEEDED);
}

//
//
//
//
//

int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1; 
   if (Hlv[i]==-1) iCleanPoint(i,sslda,ssldb);
   for (; i>=0 && !_StopFlag; i--)
   {
      sslda[i] = ssldb[i] = EMPTY_VALUE;
      Hlv[i] = (i<rates_total-1) ? (close[i]>iMA(NULL,0,Lb,0,MODE_SMA,PRICE_HIGH,i+1)) ?  1 : 
                                   (close[i]<iMA(NULL,0,Lb,0,MODE_SMA, PRICE_LOW,i+1)) ? -1 : Hlv[i+1] : 0;
      
      if(Hlv[i] == -1)
            ssl[i] = iMA(NULL,0,Lb,0,MODE_SMA,PRICE_HIGH,i+1);
      else  ssl[i] = iMA(NULL,0,Lb,0,MODE_SMA,PRICE_LOW, i+1); 
      if (Hlv[i] == -1) iPlotPoint(i,sslda,ssldb,ssl);
      keltUp[i] = ssl[i] + (KATR * iATR(NULL,0,AtrPeriod,i));
      keltDn[i] = ssl[i] - (KATR * iATR(NULL,0,AtrPeriod,i));
   }

   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (Hlv[whichBar] != Hlv[whichBar+1])
      if (Hlv[whichBar] == 1)
            doAlert(" up");
      else  doAlert(" down");       
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

void iCleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
void iPlotPoint(int i,double& first[],double& second[],double& from[])
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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" SSL "+doWhat;
             if (alertsMessage)   Alert(message);
             if (alertsPushNotif) SendNotification(message);
             if (alertsEmail)     SendMail(_Symbol+" SSL ",message);
             if (alertsSound)     PlaySound(soundfile);
      }
}




