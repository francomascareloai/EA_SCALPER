//+------------------------------------------------------------------+
//|                                                 QQE Alert v3.mq4 |
//|                                                    Skyline, 2007 |
//|                                             www.forexpertutti.it |
//+------------------------------------------------------------------+
#property copyright "Skyline, 2007"
#property link      "www.forexpertutti.it"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Magenta

extern string Comment1             = "QQEA Alert v3 compiled by Skyline on 31 Oct 2007";
extern string Comment2             = "email : glicci@yahoo.it"; 
//extern bool   ShowCrossQQE_RSISlow = true;
extern int    QQE_SF               = 1;
extern int    QQE_RSI_Period       = 14;
extern double QQE_DARFACTOR        = 4.236; 
extern int    QQE_Width            = 1;
extern double QQE_Position         = 0.5;
extern bool   EnableSoundAlert     = true;
extern bool   EnableVisualAlert    = false;
extern bool   EnableEmailAlert     = true;

double CrossUp[];
double CrossDown[];

static datetime alertTag = D'1980.01.01'; 
static datetime soundTag = D'1980.01.01';
static datetime emailTag = D'1980.01.01';

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
    SetIndexStyle(0, DRAW_ARROW, EMPTY,QQE_Width);
    SetIndexArrow(0, 241);
    SetIndexBuffer(0, CrossUp);
    SetIndexStyle(1, DRAW_ARROW, EMPTY,QQE_Width);
    SetIndexArrow(1, 242);
    SetIndexBuffer(1, CrossDown);   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() 
{
   int limit, i, counter;
   //double fasterEMAnow, slowerEMAnow, fasterEMAprevious, slowerEMAprevious, fasterEMAafter, slowerEMAafter;
   double fasterRSInow,slowerRSInow,fasterRSIprevious,slowerRSIprevious,fasterRSIafter,slowerRSIafter;
   double Range, AvgRange;
   
   int counted_bars=IndicatorCounted();
//---- check for possible errors

   if(counted_bars<0) return(-1);
   
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) 
   {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
      
      fasterRSInow      = iCustom(NULL,0,"QQEA",QQE_SF,QQE_RSI_Period,QQE_DARFACTOR,0,i);
      fasterRSIprevious = iCustom(NULL,0,"QQEA",QQE_SF,QQE_RSI_Period,QQE_DARFACTOR,0,i+1); 
      fasterRSIafter    = iCustom(NULL,0,"QQEA",QQE_SF,QQE_RSI_Period,QQE_DARFACTOR,0,i-1); 

      slowerRSInow      = iCustom(NULL,0,"QQEA",QQE_SF,QQE_RSI_Period,QQE_DARFACTOR,1,i);
      slowerRSIprevious = iCustom(NULL,0,"QQEA",QQE_SF,QQE_RSI_Period,QQE_DARFACTOR,1,i+1); 
      slowerRSIafter    = iCustom(NULL,0,"QQEA",QQE_SF,QQE_RSI_Period,QQE_DARFACTOR,1,i-1); 


      if ((fasterRSInow > slowerRSInow) && (fasterRSIprevious < slowerRSIprevious) && (fasterRSIafter > slowerRSIafter)) 
      {
         CrossUp[i] = Low[i] - Range*QQE_Position;
      }
      else 
      if ((fasterRSInow < slowerRSInow) && (fasterRSIprevious > slowerRSIprevious) && (fasterRSIafter < slowerRSIafter)) 
      {
          CrossDown[i] = High[i] + Range*QQE_Position;
      }
      /*  if (SoundON==true && i==1 && CrossUp[i] > CrossDown[i] && alertTag!=Time[0])
        {
         Alert("EMA Cross Trend going Down on ",Symbol()," ",Period());
         alertTag = Time[0];
        }
        if (SoundON==true && i==1 && CrossUp[i] < CrossDown[i] && alertTag!=Time[0])
        {
         Alert("EMA Cross Trend going Up on ",Symbol()," ",Period());
         alertTag = Time[0];
        } */
        
        // Gestione Alert visivo //
        if (EnableVisualAlert==true && i==1 && CrossUp[i] > CrossDown[i] && alertTag!=Time[0])
        {
         Alert("QQE Cross Trend going DOWN on ",Symbol()," ",Periodo(Period()));
         alertTag = Time[0];
        }
        if (EnableVisualAlert==true && i==1 && CrossUp[i] < CrossDown[i] && alertTag!=Time[0])
        {
         Alert("QQE Cross Trend going UP on ",Symbol()," ",Periodo(Period()));
         alertTag = Time[0];
        }   
          
        // Gestione Alert sonoro //      
        if (EnableSoundAlert==true && i==1 && CrossUp[i] > CrossDown[i] && soundTag!=Time[0])
        {
         PlaySound ("short.wav");
         soundTag = Time[0];
        }
        if (EnableSoundAlert==true && i==1 && CrossUp[i] < CrossDown[i] && soundTag!=Time[0])
        {
         PlaySound ("long.wav");
         soundTag = Time[0];
        } 
        
        // Gestione Alert con email //      
        if (EnableEmailAlert==true && i==1 && CrossUp[i] > CrossDown[i] && emailTag!=Time[0])
        {
         SendMail("Supernova alert signal!","QQE Cross Trend going DONWN on " + (StringConcatenate(Symbol()," ",Periodo(Period()))));
         emailTag = Time[0];
        }
        if (EnableEmailAlert==true && i==1 && CrossUp[i] < CrossDown[i] && emailTag!=Time[0])
        {
         SendMail("Supernova alert signal!","QQE Cross Trend going UP on " + (StringConcatenate(Symbol()," ",Periodo(Period()))));
         emailTag = Time[0];
        } 
  }
   return(0);
}

string Periodo(int TF)
{
 if (TF==1)    { return("M1"); }
 if (TF==5)    { return("M5"); }
 if (TF==15)   { return("M15"); }
 if (TF==30)   { return("M30"); } 
 if (TF==60)   { return("H1"); } 
 if (TF==240)  { return("H4"); } 
 if (TF==1440) { return("D1"); }  
}

