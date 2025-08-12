//+------------------------------------------------------------------+
//|                                                Zero lag MACD.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 clrDeepSkyBlue
#property indicator_color2 clrDimGray
#property indicator_color3 clrDeepSkyBlue
#property indicator_color4 clrRed
#property indicator_width2 2
#property indicator_width3 2

extern string timeFrame        = "current time frame";
extern int    FastEMA          = 12;
extern int    SlowEMA          = 26;
extern int    SignalEMA        =  9;
extern int    AlertsArrowsOn   =  0;
extern int    MacdPrice        = PRICE_CLOSE;
extern bool   Interpolate      = true;
extern bool   arrowsVisible    = true;
extern string arrowsIdentifier = "ZLMacdArrows";
extern int    UpArrowSymbolCode = 241;
extern int    DownArrowSymbolCode = 242;
extern color  arrowsUpColor    = clrDeepSkyBlue;
extern color  arrowsDnColor    = clrRed;
extern int    UpArrowSize      = 1;
extern int    DownArrowSize      = 1;
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = false;
extern bool   alertsMessage    = false;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;

double macdBuffer[], machBuffer[], signBuffer[], osmaBuffer[], trend[];
double workBuffer[][6];

string CrossDescription, IndicatorFileName;
bool   calculatingMacd = false;
bool   returningBars   = false;
int    TimeFrame;
//+-------------------------------------------------------------------
int OnInit()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,machBuffer); SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexLabel(0,NULL);
   SetIndexBuffer(1,osmaBuffer); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,macdBuffer); 
   SetIndexBuffer(3,signBuffer);
   SetIndexBuffer(4,trend);
   
      AlertsArrowsOn = MathMax(MathMin(AlertsArrowsOn,2),0);
      switch(AlertsArrowsOn)
      {
         case 0 : CrossDescription = "Zero lag MACD - MACD crossed signal line ";      break;
         case 1 : CrossDescription = "Zero lag MACD - MACD crossed zero line ";        break;
         case 2 : CrossDescription = "Zero lag MACD - Signal line crossed zero line "; break;
      }
      if (timeFrame=="calculateMACD") { calculatingMacd=true; return(0); }
      if (timeFrame=="returnBars")    { returningBars=true;   return(0); }

   TimeFrame = stringToTimeFrame(timeFrame);
   
   string TimeFrameStr;
   switch(TimeFrame)
   {
      case PERIOD_M1:  TimeFrameStr="(M1)";      break;
      case PERIOD_M5:  TimeFrameStr="(M5)";      break;
      case PERIOD_M15: TimeFrameStr="(M15)";     break;
      case PERIOD_M30: TimeFrameStr="(M30)";     break;
      case PERIOD_H1:  TimeFrameStr="(H1)";      break;
      case PERIOD_H4:  TimeFrameStr="(H4)";      break;
      case PERIOD_D1:  TimeFrameStr="(Dayly)";   break;
      case PERIOD_W1:  TimeFrameStr="(Weekly)";  break;
      case PERIOD_MN1: TimeFrameStr="(Monthly)"; break;
      default :        TimeFrameStr="";
   }
   IndicatorFileName = WindowExpertName();               
   IndicatorShortName(" zero lag MACD ("+FastEMA+","+SlowEMA+","+SignalEMA+")"+TimeFrameStr);
   return(0);
}
//+-------------------------------------------------------------------
int deinit()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   int limit,i;

   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
           limit = MathMin(Bars-counted_bars,Bars-1);

           if (returningBars)   { macdBuffer[0] = limit; return(0); }
           if (calculatingMacd) { CalculateMacd(limit);  return(0); }
           if (TimeFrame > Period()) limit = MathMax(limit,MathMin(Bars,iCustom(NULL,TimeFrame,IndicatorFileName,"returnBars",0,0)*TimeFrame/Period()));
   
 	for(i = limit; i >= 0; i--)
   {
      int      shift1 = iBarShift(NULL,TimeFrame,Time[i]);
      datetime time1  = iTime    (NULL,TimeFrame,shift1);
               
         macdBuffer[i] = iCustom(NULL,TimeFrame,IndicatorFileName,"calculateMACD",FastEMA,SlowEMA,SignalEMA,MacdPrice,2,shift1);
         signBuffer[i] = iCustom(NULL,TimeFrame,IndicatorFileName,"calculateMACD",FastEMA,SlowEMA,SignalEMA,MacdPrice,3,shift1);
         machBuffer[i] = macdBuffer[i];
         osmaBuffer[i] = macdBuffer[i]-signBuffer[i];
         switch(AlertsArrowsOn)
         {
            case 0 : 
                  if (osmaBuffer[i]>0) trend[i] =  1;
                  if (osmaBuffer[i]<0) trend[i] = -1;
                  break;
            case 1 : 
                  if (macdBuffer[i]>0) trend[i] =  1;
                  if (macdBuffer[i]<0) trend[i] = -1;
                  break;
            case 2 : 
                  if (signBuffer[i]>0) trend[i] =  1;
                  if (signBuffer[i]<0) trend[i] = -1;
                  break;
         }
         manageArrow(i);
         if (TimeFrame <= Period() || shift1==iBarShift(NULL,TimeFrame,Time[i-1])) continue;
         if (!Interpolate) continue;		 

         for(int n = 1; i+n < Bars && Time[i+n] >= time1; n++) continue;	
         double factor = 1.0 / n;
         for(int k = 1; k < n; k++)
            {
               macdBuffer[i+k] = k*factor*macdBuffer[i+n] + (1.0-k*factor)*macdBuffer[i];
    	         signBuffer[i+k] = k*factor*signBuffer[i+n] + (1.0-k*factor)*signBuffer[i];
    	         machBuffer[i+k] = macdBuffer[i+k];
    	         osmaBuffer[i+k] = macdBuffer[i+k]-signBuffer[i+k];
            }    	             
   }
   manageAlerts();
   return(0);           
}
//+------------------------------------------------------------------+
#define ema11 0
#define ema12 1
#define ema21 2
#define ema22 3
#define ema31 4
#define ema32 5

//+-------------------------------------------------------------------
void CalculateMacd(int limit)
{
   double alpha1 = 2.0/(1.0+FastEMA);
   double alpha2 = 2.0/(1.0+SlowEMA);
   double alpha3 = 2.0/(1.0+SignalEMA);
   int i,r;

      if (ArrayRange(workBuffer,0)!=Bars) ArrayResize(workBuffer,Bars);
         
   for (i=limit, r=Bars-i-1; i>= 0; i--,r++)
   {
      double price = iMA(NULL,0,1,0,MODE_SMA,MacdPrice,i);
      if (i==(Bars-1))
      {
         workBuffer[r][ema11] = price;
         workBuffer[r][ema12] = price;
         workBuffer[r][ema21] = price;
         workBuffer[r][ema22] = price;
         continue;
      }
      workBuffer[r][ema11] = workBuffer[r-1][ema11]+alpha1*(price               -workBuffer[r-1][ema11]);
      workBuffer[r][ema12] = workBuffer[r-1][ema12]+alpha1*(workBuffer[r][ema11]-workBuffer[r-1][ema12]);
      workBuffer[r][ema21] = workBuffer[r-1][ema21]+alpha2*(price               -workBuffer[r-1][ema21]);
      workBuffer[r][ema22] = workBuffer[r-1][ema22]+alpha2*(workBuffer[r][ema21]-workBuffer[r-1][ema22]);
      macdBuffer[i]        = (2.0*workBuffer[r][ema11]-workBuffer[r][ema12])-
                             (2.0*workBuffer[r][ema21]-workBuffer[r][ema22]);
      machBuffer[i]        = macdBuffer[i];                      
      
      workBuffer[r][ema31] = workBuffer[r-1][ema31]+alpha3*(macdBuffer[i]       -workBuffer[r-1][ema31]);
      workBuffer[r][ema32] = workBuffer[r-1][ema32]+alpha3*(workBuffer[r][ema31]-workBuffer[r-1][ema32]);
      signBuffer[i]        = (2.0*workBuffer[r][ema31]-workBuffer[r][ema32]);
      osmaBuffer[i]        = macdBuffer[i]-signBuffer[i];            
   }

}
//+------------------------------------------------------------------+
void manageArrow(int i)
{
   if (arrowsVisible )
   {
         deleteArrow(Time[i]);
         if (trend[i]!=trend[i+1])
         {
            if (trend[i] == 1) drawArrow(i,arrowsUpColor,UpArrowSymbolCode,UpArrowSize,false);
            if (trend[i] ==-1) drawArrow(i,arrowsDnColor,DownArrowSymbolCode,DownArrowSize,true);
         }
   }
}               
//+-------------------------------------------------------------------
void drawArrow(int i,color theColor,int theCode, int ArrowSize, bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,ArrowSize);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}
//+------------------------------------------------------------------+
void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"down");
      }         
   }
}   
//+-------------------------------------------------------------------
void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS),CrossDescription+doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Zero lag MACD "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}                                                                
//+-------------------------------------------------------------------
string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

int stringToTimeFrame(string tfs)
{
   tfs = StringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
//+-------------------------------------------------------------------
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
//+-------------------------------------------------------------------
string StringUpperCase(string str)
   {
   string   s = str;
   int      lenght = StringLen(str) - 1;
   int      character;
   
   while(lenght >= 0)
      {
      character = StringGetChar(s, lenght);
      if((character > 96 && character < 123) || (character > 223 && character < 256))
         {
         s = StringSetChar(s, lenght, character - 32);
         }
      else 
      if(character > -33 && character < 0)
         {
         s = StringSetChar(s, lenght, character + 224);
         }                              
      lenght--;
      }
  
   return(s);
   }
//+-------------------------------------------------------------------
