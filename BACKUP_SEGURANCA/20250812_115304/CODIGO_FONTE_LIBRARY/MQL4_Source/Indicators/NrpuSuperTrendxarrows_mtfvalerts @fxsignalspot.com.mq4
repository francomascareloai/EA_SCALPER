//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrYellow
#property indicator_color2 clrMagenta

//
//
//
//
//

extern string TimeFrame          = "Current time frame";
extern int    Nbr_Periods        = 10;
extern double Multiplier         = 1.7;
extern int MA_Period             = 1;

extern bool   alertsOn           = false;
extern bool   alertsOnCurrent    = false;
extern bool   alertsMessage      = false;
extern bool   alertsNotification = false;
extern bool   alertsSound        = false;
extern bool   alertsEmail        = false;

extern int    arrowthickness     = 3;
extern int    linethickness      = 1;


//
//
//
//
//

double CrossUp[];
double CrossDn[];
double Up[];
double Dn[];
double Direction[];


string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

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
   IndicatorBuffers(5);
      SetIndexBuffer(0,CrossUp); SetIndexStyle(0,DRAW_ARROW,0,arrowthickness ); SetIndexArrow(0,115);
      SetIndexBuffer(1,CrossDn); SetIndexStyle(1,DRAW_ARROW,0,arrowthickness ); SetIndexArrow(1,115);
      SetIndexBuffer(2,Up);
      SetIndexBuffer(3,Dn);
      SetIndexBuffer(4,Direction);
      
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue"; if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";     if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
       
      //
      //
      //
      //
      //
      
      IndicatorShortName(timeFrameToString(timeFrame)+" SuperTrend");
     

  return(0);

}

int deinit() 
{ 
return(0); 
}
//
//
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
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { CrossUp[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
      for(int i=limit; i>=0; i--)
      {
         double atr    = iATR(NULL,0,Nbr_Periods,i);
         double cprice = Close[i];
         double mprice = iMA(NULL,0,MA_Period,0,MODE_SMA,PRICE_MEDIAN,i);
                Up[i]  = mprice+Multiplier*atr;
                Dn[i]  = mprice-Multiplier*atr;
         
         //
         //
         //
         //
         //

         Direction[i] = Direction[i+1];
            if (cprice > Up[i+1])  Direction[i] =  1;
            if (cprice < Dn[i+1])  Direction[i] = -1;
            if (Direction[i] > 0) { Dn[i] = MathMax(Dn[i],Dn[i+1]); }
            else                  { Up[i] = MathMin(Up[i],Up[i+1]); }
            
            //
            //
            //
            //
            //
            
            CrossUp[i] = EMPTY_VALUE;
            CrossDn[i] = EMPTY_VALUE;
            if (Direction[i] != Direction[i+1])
            if (Direction[i] == 1)
                  CrossUp[i] = Low[i] - iATR(NULL,0,20,i)/2.0;
            else  CrossDn[i] = High[i]+ iATR(NULL,0,20,i)/2.0;
      }
      
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         Direction[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Nbr_Periods,Multiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,4,y);
         CrossUp[i] = EMPTY_VALUE;
         CrossDn[i] = EMPTY_VALUE;
            if (Direction[i] != Direction[i+1])
            if (Direction[i] == 1)
                  CrossUp[i] = Low[i] - iATR(NULL,0,20,i)/2.0;
            else  CrossDn[i] = High[i]+ iATR(NULL,0,20,i)/2.0;
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

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar=0;
      if (Direction[whichBar] != Direction[whichBar+1])
      {
         if (Direction[whichBar] ==  1) doAlert("up"  );
         if (Direction[whichBar] == -1) doAlert("down");
      }
   }
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
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message =  timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" super trend changed to "+doWhat;
          if (alertsMessage)      Alert(message);
          if (alertsEmail)        SendMail(Symbol()+" super trend",message);
          if (alertsNotification) SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
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

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int chart = StringGetChar(s, length);
         if((chart > 96 && chart < 123) || (chart > 223 && chart < 256))
                     s = StringSetChar(s, length, chart - 32);
         else if(chart > -33 && chart < 0)
                     s = StringSetChar(s, length, chart + 224);
   }
   return(s);
}


