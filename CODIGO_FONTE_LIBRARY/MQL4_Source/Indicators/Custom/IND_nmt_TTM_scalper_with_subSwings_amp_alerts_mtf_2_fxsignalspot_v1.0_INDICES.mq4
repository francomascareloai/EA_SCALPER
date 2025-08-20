//+------------------------------------------------------------------+
//|                                                  TTM scalper.mq4 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers  4
#property indicator_color1   DeepSkyBlue
#property indicator_color2   Red
#property indicator_color3   DeepSkyBlue
#property indicator_color4   Red
#property indicator_width1   2
#property indicator_width2   2
#property indicator_style3   STYLE_DOT
#property indicator_style4   STYLE_DOT

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame          = PERIOD_CURRENT;
extern bool            showSubSwings      = false;
extern bool            alertsOn           = false;
extern bool            alertsMessage      = true;
extern bool            alertsSound        = false;
extern bool            alertsEmail        = false;
extern bool            alertsNotification = false;

//
//
//
//
//

double upBuffer[];
double dnBuffer[];
double upsBuffer[];
double dnsBuffer[];
double trendBuffer[];
double swing[];
double subswing[];

string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(7);
   SetIndexBuffer(0,upBuffer);  SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,dnBuffer);  SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,upsBuffer); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,dnsBuffer); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,trendBuffer);
   SetIndexBuffer(5,swing);
   SetIndexBuffer(6,subswing);
   
   //
   //
   //
   //
   //
       
   indicatorFileName = WindowExpertName();
   returnBars        = TimeFrame == -99;
   TimeFrame         = MathMax(TimeFrame,_Period);
   return(0);
}
int deinit() { return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define trendUp    1
#define trendDown -1

//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         
            //
            //
            //
            //
            //
            
            for (int k=3,i=limit;i<(Bars-1) && k>0;i++) if (dnBuffer[i]!=EMPTY_VALUE) k--;
                       limit = MathMax(limit,MathMin(Bars-1,i));
            if (returnBars) { upBuffer[0] = limit+1; return(0); }
         
   //
   //
   //
   //
   //
            
   if (TimeFrame == Period())
   {
      int swingBar;
      for(i=limit; i>=0; i--)
      {
         upBuffer[i]  = EMPTY_VALUE;
         dnBuffer[i]  = EMPTY_VALUE;
         upsBuffer[i] = EMPTY_VALUE;
         dnsBuffer[i] = EMPTY_VALUE;
         if (i==Bars-1)
               trendBuffer[i] = 1;
         else  trendBuffer[i] = trendBuffer[i+1];
         swing[i]    = 0;
         subswing[i] = 0;

         //
         //
         //
         //
         //

         if (trendBuffer[i] == trendUp)
         {
            for (k=1; (i+k)<Bars; k++)
               if (upBuffer[i+k]!=EMPTY_VALUE && trendBuffer[i+k]==trendDown) break;
         
               //
               //
               //
               //
               //
            
               swingBar = swingHighBar(i,1,PRICE_HIGH,2,k);
               if (swingBar>-1)
               if (isLess(Close[i],Low[swingBar-1]) && isLess(High[iHighest(NULL,0,MODE_HIGH,swingBar-i,i)],High[swingBar]))
               { 
                  upBuffer[swingBar] = High[swingBar];
                  dnBuffer[swingBar] = Low[swingBar];
                  trendBuffer[i]     = trendDown;
                  swing[swingBar]    = trendDown;
                  continue;
               }
         }

      //
      //
      //
      //
      //
                  
         if (trendBuffer[i] == trendDown)
         {
            for (k=1;(i+k)<Bars;k++)
               if (dnBuffer[i+k]!=EMPTY_VALUE && trendBuffer[i+k]==trendUp) break;

               //
               //
               //
               //
               //
               
               swingBar = swingLowBar(i,1,PRICE_LOW,2,k);
               if (swingBar>-1)
               if (isGreater(Close[i],High[swingBar-1]) && isGreater(Low[iLowest(NULL,0,MODE_LOW,swingBar-i,i)],Low[swingBar]))
               {
                  dnBuffer[swingBar] = High[swingBar];
                  upBuffer[swingBar] = Low[swingBar];
                  trendBuffer[i]     = trendUp;
                  swing[swingBar]    = trendUp;
               }                  
         }
         
         //
         //
         //
         //
         //

         if (!showSubSwings) continue;

         swingBar = swingHighBar(i,1,PRICE_HIGH,2,k);
            if (swingBar>-1) { upsBuffer[swingBar] = High[swingBar]; dnsBuffer[swingBar] = Low[swingBar]; subswing[swingBar] = trendDown;}
         swingBar = swingLowBar(i,1,PRICE_LOW,2,k);
            if (swingBar>-1) { dnsBuffer[swingBar] = High[swingBar]; upsBuffer[swingBar] = Low[swingBar]; subswing[swingBar] = trendUp;  }
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);               
      int x = iBarShift(NULL,TimeFrame,Time[i+1]);               
      if (x!=y)
      {
         upBuffer[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,showSubSwings,alertsOn,alertsMessage,alertsSound,alertsEmail,alertsNotification,0,y);
         dnBuffer[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,showSubSwings,alertsOn,alertsMessage,alertsSound,alertsEmail,alertsNotification,1,y);
         upsBuffer[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,showSubSwings,alertsOn,alertsMessage,alertsSound,alertsEmail,alertsNotification,2,y);
         dnsBuffer[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,showSubSwings,alertsOn,alertsMessage,alertsSound,alertsEmail,alertsNotification,3,y);
      }
      else
      {
         upBuffer[i]  = EMPTY_VALUE;
         dnBuffer[i]  = EMPTY_VALUE;
         upsBuffer[i] = EMPTY_VALUE;
         dnsBuffer[i] = EMPTY_VALUE;
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

void manageAlerts()
{
   if (alertsOn)
   {
      static datetime previousSwingBarTime    = -1;
      static datetime previousSubSwingBarTime = -1;

      //
      //
      //
      //
      //
               
      for (int i=0; i<Bars; i++) if (swing[i]!=0) break;
         if (previousSwingBarTime != Time[i])
         {
            previousSwingBarTime = Time[i];
            if (swing[i] == trendUp)
                  doAlert("last low swing bar formed at "+TimeToStr(Time[i],TIME_MINUTES));
            else  doAlert("last high swing bar fromed at "+TimeToStr(Time[i],TIME_MINUTES));
         }       
         
      //
      //
      //
      //
      //
                   
      if (showSubSwings)
      {
         for (i=0; i<Bars; i++) if (subswing[i]!=0) break;
         if (previousSubSwingBarTime!=Time[i])
         {
            previousSubSwingBarTime = Time[i];
            if (swing[i] == trendUp)
                  doAlert("last low sub-swing bar formed at "+TimeToStr(Time[i],TIME_MINUTES));
            else  doAlert("last high sub-swing bar fromed at "+TimeToStr(Time[i],TIME_MINUTES));
         }                  
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
   string message;
   
   if (previousAlert != doWhat) {
       previousAlert  = doWhat;

       //
       //
       //
       //
       //

       message =  timeFrameToString(_Period)+" "+Symbol()+" at : "+TimeToStr(TimeLocal(),TIME_SECONDS)+" TTM scalper "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"TTM scalper "),message);
          if (alertsSound)   PlaySound("alert2.wav");
          if (alertsNotification)  SendNotification(StringConcatenate(Symbol(),"TTM scalper ",message));
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

bool isLess(double first, double second)
{
   return(NormalizeDouble(first,Digits)<NormalizeDouble(second,Digits));
}
bool isGreater(double first, double second)
{
   return(NormalizeDouble(first,Digits)>NormalizeDouble(second,Digits));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int swingHighBar(int shift, int instance, int price, int strength, int length)
{
   double pivotPrice = 0; 
	int    pivotBar   = 0 ;

      pivot(shift, price, length, strength, strength, instance, 1, pivotPrice,  pivotBar);
      
   return(pivotBar);
}   
int swingLowBar(int shift, int instance, int price, int strength, int length)
{
   double pivotPrice = 0; 
	int    pivotBar   = 0 ;

      pivot(shift, price, length, strength, strength, instance, -1, pivotPrice,  pivotBar);
      
   return(pivotBar);
}   

//
//
//
//
//

int pivot(int shift, int price, int length, int leftStrength, int rightStrength, int instance, int hiLo, double& pivotPrice, int& pivotBar)
{
   double testPrice;
   double candidatePrice;
   bool   instanceTest = false;
   int    strengthCntr = 0;
   int    instanceCntr = 0;
   int    lengthCntr   = rightStrength;
   
   //
   //
   //
   //
   //
   
   while (lengthCntr<length && !instanceTest)
   {
      bool pivotTest = true;
      candidatePrice = iMA(NULL,0,1,0,MODE_SMA,price,shift+lengthCntr);
         
      //
      //
      //
      //
      //
            
      strengthCntr = 1;
      while (pivotTest && (strengthCntr <= leftStrength))
      {
         testPrice = iMA(NULL,0,1,0,MODE_SMA,price,shift+lengthCntr+strengthCntr);
         if ((hiLo== 1 && candidatePrice < testPrice) ||
             (hiLo==-1 && candidatePrice > testPrice))
               pivotTest    =  false;
         else  strengthCntr += 1;
      }
      strengthCntr = 1;
      while(pivotTest && (strengthCntr <= rightStrength))
      {
         testPrice = iMA(NULL,0,1,0,MODE_SMA,price,shift+lengthCntr-strengthCntr); 
         if ((hiLo== 1 && candidatePrice <= testPrice) ||
             (hiLo==-1 && candidatePrice >= testPrice))
               pivotTest    =  false;
         else  strengthCntr += 1;
      }
         
      //
      //
      //
      //
      //
         
      if (pivotTest) instanceCntr += 1;
      if (instanceCntr == instance)
            instanceTest = true;
      else  lengthCntr += 1;           
   }
   
   //
   //
   //
   //
   //
   
   if (instanceTest)
   {
      pivotPrice = candidatePrice;
      pivotBar   = shift+lengthCntr;
      return(1);
   }
   else
   {
      pivotPrice = -1;
      pivotBar   = -1;
      return(-1);
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

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}