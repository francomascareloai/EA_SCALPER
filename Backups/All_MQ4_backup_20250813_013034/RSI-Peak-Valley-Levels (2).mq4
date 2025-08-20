//+------------------------------------------------------------------+
//|                                            RSI Peak & Bottom.mq4 |
//|                                   Copyright © 2009, Ahmad Yahya. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Ahmad Yahya."
#property link      "fx.power@yahoo.com"

#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    3
#property indicator_color1     LimeGreen
#property indicator_width1     2
#property indicator_color2     DodgerBlue
#property indicator_color3     DeepPink
#property indicator_levelcolor DarkSlateGray



//
//
//
//
//

extern int    PeriodRSI       = 7;
extern int    Price           = 0;
extern double levelOb         = 75.0;
extern double levelOs         = 25.0;
extern int    arrowSize       = 1;

extern string note            = "turn on Alert = true; turn off = false";
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsEmail     = false;
extern string soundfile       = "alert2.wav";

//
//
//
//
//

double RSILine1[];
double SupLevel2[];
double ResLevel3[];
double trend[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//
//

int init()
{

   IndicatorBuffers(4);
   SetIndexBuffer(0,RSILine1); 
   SetIndexBuffer(1,SupLevel2); SetIndexStyle(1,DRAW_ARROW,0,arrowSize); SetIndexLabel(1,"SupLevel");
   SetIndexBuffer(2,ResLevel3); SetIndexStyle(2,DRAW_ARROW,0,arrowSize); SetIndexLabel(2,"ResLevel");
   SetIndexBuffer(3,trend);
   
   SetLevelValue(0,levelOb);
   SetLevelValue(1,50);
   SetLevelValue(2,levelOs);
   
   IndicatorShortName("RSI Peak/Valley Levels ("+PeriodRSI+")");
   return(0);
  }
  
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
//
//

int deinit()  {   return(0);  }

//
//
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
   
   //
   //
   //
   //
   //
   
       for(i=limit; i >= 0; i--)
       {
         RSILine1[i] = iRsi(iMA(NULL,0,1,0,MODE_SMA,Price,i),PeriodRSI,i);
   
         if  ((RSILine1[i+1] < RSILine1[i+2] && RSILine1[i+2] > RSILine1[i+3]) || (RSILine1[i+1] < RSILine1[i+2] && RSILine1[i+2] == RSILine1[i+3] && RSILine1[i+3] > RSILine1[i+4]))                   
              { ResLevel3[i+2] = RSILine1[i+2]; trend[i]= -1; }  //Menandai Level Resistance
            
         if  ((RSILine1[i+1] > RSILine1[i+2] && RSILine1[i+2] < RSILine1[i+3]) || (RSILine1[i+1] > RSILine1[i+2] && RSILine1[i+2] == RSILine1[i+3] && RSILine1[i+3] < RSILine1[i+4])) 
            
              { SupLevel2[i+2] = RSILine1[i+2]; trend[i]= 1; }  //Menandai Level Support    
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

       //
       //
       //
       //
       //
         
       if (trend[whichBar] != trend[whichBar+1])
       if (trend[whichBar] == 1)
             doAlert("support");
       else  doAlert("resistance");       
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," rsi ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," rsi "),message);
             if (alertsSound)   PlaySound(soundfile);
      }
}
//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

double workRsi[][3];
#define _price  0
#define _change 1
#define _changa 2

//
//
//
//

double iRsi(double price, double period, int shift, int forz=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int    z     = forz*3; 
      int    i     = Bars-shift-1;
      double alpha = 1.0/period; 

   //
   //
   //
   //
   //
   
   workRsi[i][_price+z] = price;
   if (i<period)
      {
         int k; double sum = 0; for (k=0; k<period && (i-k-1)>=0; k++) sum += MathAbs(workRsi[i-k][_price+z]-workRsi[i-k-1][_price+z]);
            workRsi[i][_change+z] = (workRsi[i][_price+z]-workRsi[0][_price+z])/MathMax(k,1);
            workRsi[i][_changa+z] =                                         sum/MathMax(k,1);
      }
   else
      {
         double change = workRsi[i][_price+z]-workRsi[i-1][_price+z];
                         workRsi[i][_change+z] = workRsi[i-1][_change+z] + alpha*(        change  - workRsi[i-1][_change+z]);
                         workRsi[i][_changa+z] = workRsi[i-1][_changa+z] + alpha*(MathAbs(change) - workRsi[i-1][_changa+z]);
      }
   if (workRsi[i][_changa+z] != 0)
         return(50.0*(workRsi[i][_change+z]/workRsi[i][_changa+z]+1));
   else  return(0);
}

//
//
//
//
//

