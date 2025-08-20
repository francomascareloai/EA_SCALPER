//+------------------------------------------------------------------+
//|                                                          SSL.mq4 |
//|ssl  fast bar mtf                                         Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
//mtf2008fxtsd   

#property copyright "Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  Green
#property indicator_color2  Red
#property indicator_width1  3
#property indicator_width2  3
#property indicator_minimum 10
#property indicator_maximum 90

//
//
//
//
//

extern int     Lb           = 3;
extern int     sslMA_method =  0;
extern int     SSL_BarLevel = 50;    //BarLevel 10-90



extern bool alertsOn             = false;
extern bool alertsMessageBox     = false;
extern bool alertsSound          = false;
extern string alertsSoundFile    = "TP1M.wav";  //enterSoundFile
extern bool alertsEmail          = false;
extern bool alertsAfterBarClose  = false;

extern int     TimeFrame    =  0;
extern string  TimeFrames   = "M1;5,15,30,60H1;240H4;1440D1;10080W1;43200MN|0-CurrentTF";
extern string  MA_method_   = "SMA0 EMA1 SMMA2 LWMA3";

//
//
//
//
//

double sslHup[];
double sslHdn[];
double hlv[];
string IndicatorFileName;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   string TimeFrameStr;
   TimeFrame=MathMax(TimeFrame,Period());
      
      switch(TimeFrame)
      {
         case PERIOD_M1:  TimeFrameStr="M1"  ; break;
         case PERIOD_M5:  TimeFrameStr="M5"  ; break;
         case PERIOD_M15: TimeFrameStr="M15" ; break;
         case PERIOD_M30: TimeFrameStr="M30" ; break;
         case PERIOD_H1:  TimeFrameStr="H1"  ; break;
         case PERIOD_H4:  TimeFrameStr="H4"  ; break;
         case PERIOD_D1:  TimeFrameStr="D1"  ; break;
         case PERIOD_W1:  TimeFrameStr="W1"  ; break;
         case PERIOD_MN1: TimeFrameStr="MN1" ; break;
         default :        TimeFrameStr="TF0";
      } 


   IndicatorBuffers(3);
   SetIndexBuffer (0,sslHup); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,167); SetIndexLabel(0,"SSLup "+Lb+" ["+TimeFrame+"]");
   SetIndexBuffer (1,sslHdn); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,167); SetIndexLabel(1,"SSLdn "+Lb+" ["+TimeFrame+"]");
   SetIndexBuffer (2,hlv);

   IndicatorShortName("SSL Bar "+Lb+" ["+TimeFrameStr+"]");
   IndicatorFileName = WindowExpertName();

   return(0);
}


int deinit()
{
   return(0);
}

//
//
//
//
//

int start()
 {
   int  counted_bars=IndicatorCounted();
   int  i,limit;

   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
            limit=Bars-counted_bars;


   if (TimeFrame != Period())
   {
      datetime TimeArray[];
         limit = MathMax(limit,TimeFrame/Period());
         ArrayCopySeries(TimeArray, MODE_TIME, NULL,TimeFrame);
         
         //
         //
         //
         //
         //
                  
         for(i=0,int y=0; i<limit; i++)
         {
            if(Time[i]<TimeArray[y]) y++;

         sslHup[i] = iCustom(NULL,TimeFrame,IndicatorFileName,Lb,sslMA_method,SSL_BarLevel,alertsOn,alertsMessageBox,
                                          alertsSound,alertsSoundFile,alertsEmail,alertsAfterBarClose,0,y);
         sslHdn[i] = iCustom(NULL,TimeFrame,IndicatorFileName,Lb,sslMA_method,SSL_BarLevel,alertsOn,alertsMessageBox,
                                          alertsSound,alertsSoundFile,alertsEmail,alertsAfterBarClose,1,y);


         }
   
         
      return(0);         
   }

 
   //
   //
   //
   //
   //
    
   for(i=limit;i>=0;i--)
   {
      hlv[i] = hlv[i+1];
 
         if(Close[i]>iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_HIGH,i+1))  hlv[i] =  1;
         if(Close[i]<iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_LOW, i+1))  hlv[i] = -1;
      
         if(hlv[i] == -1) { sslHdn[i] = SSL_BarLevel; sslHup[i] = EMPTY_VALUE;  }
         else             { sslHdn[i] = EMPTY_VALUE;  sslHup[i] = SSL_BarLevel; }                  
   }
   
  
   if (alertsOn)
   {
      int alertBar=0; 
      if (alertsAfterBarClose)alertBar = 1;

      if (hlv[0+alertBar] != hlv[1+alertBar])
      if (hlv[0+alertBar] == 1)
            doAlert("Up");
      else  doAlert("Down");    
   }



   return(0);
}

//+------------------------------------------------------------------+


//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) 
      
      {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //

          message =  StringConcatenate(Symbol()," M",TimeFrame," at ",Close[0]," SSL Bar: trend changed to ",doWhat);
             if (alertsMessageBox)  Alert(message);
             if (alertsEmail)       SendMail(StringConcatenate(Symbol(),"SSL "),message);
             if (alertsSound)       PlaySound(alertsSoundFile);
      }
}

