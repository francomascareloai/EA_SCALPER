//+------------------------------------------------------------------+
//|                                    UniEMACrossover_v1.0 600+.mq4 |
//|                                Copyright © 2016, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
#property link      "http://newdigital-world.com"


#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1  C' 30,160,160'
#property indicator_color2  C'225, 55,  0'
#property indicator_color3  C' 20, 90, 90'
#property indicator_color4  C'160, 40,  0'
#property indicator_color5  clrDeepSkyBlue
#property indicator_color6  clrOrangeRed
#property indicator_color7  clrDeepSkyBlue
#property indicator_color8  clrOrangeRed

#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  0
#property indicator_width4  0
#property indicator_width5  2 
#property indicator_width6  2
#property indicator_width7  1 
#property indicator_width8  1


enum ENUM_PRICE
{
   close,               // Close
   open,                // Open
   high,                // High
   low,                 // Low
   median,              // Median
   typical,             // Typical
   weightedClose,       // Weighted Close
   heikenAshiClose,     // Heiken Ashi Close
   heikenAshiOpen,      // Heiken Ashi Open
   heikenAshiHigh,      // Heiken Ashi High   
   heikenAshiLow,       // Heiken Ashi Low
   heikenAshiMedian,    // Heiken Ashi Median
   heikenAshiTypical,   // Heiken Ashi Typical
   heikenAshiWeighted   // Heiken Ashi Weighted Close   
};

#define pi 3.14159265358979323846

//---- 

input ENUM_TIMEFRAMES   TimeFrame            =     0;
input string            FastMA               = "=== Fast UniEMA ===";
input ENUM_PRICE        FastPrice            =     0;   // Fast UniEMA Price
input int               FastLength           =    12;   // Fast UniEMA Period
input int               FastPole             =     1;   // Fast UniEMA Pole
input int               FastOrder            =     1;   // Fast UniEMA order
input double            FastWeightFactor     =     2;   // Fast UniEMA Weight Factor   
input double            FastDampingFactor    =   0.5;   // Fast UniEMA Damping Factor
input int               FastShift            =     0;   // Fast UniEMA Displace

input string            SlowMA               = "=== Slow UniEMA ===";
input ENUM_PRICE        SlowPrice            =     0;   // Slow MA Price
input int               SlowLength           =    26;   // Slow MA Period
input int               SlowPole             =     1;   // Slow UniEMA Pole
input int               SlowOrder            =     1;   // Slow UniEMA Order
input double            SlowWeightFactor     =     2;   // Slow UniEMA Weight Factor   
input double            SlowDampingFactor    =   0.5;   // Slow UniEMA Damping Factor
input int               SlowShift            =     0;   // Slow MA Displace

input bool              ShowFilled           = false;
input int               CountBars            =     0;   //Number of bars counted: 0-all bars   
   
input string            Alerts               = "=== Alerts & Emails ===";
input bool              AlertOn              = false;
input int               AlertShift           =     1;       // Alert Shift:0-current bar,1-previous bar
input int               SoundsNumber         =     5;       // Number of sounds after Signal
input int               SoundsPause          =     5;       // Pause in sec between sounds 
input string            UpTrendSound         = "alert.wav";
input string            DnTrendSound         = "alert2.wav";
input bool              EmailOn              = false;       
input int               EmailsNumber         =     1;          
input bool              PushNotificationOn   = false;

double upgrow[];
double dngrow[];
double upfall[];
double dnfall[];
double fast[];
double slow[];
double buy[];
double sell[];
double trend[];
double fastshift[];
double slowshift[];
double counter[];



int      timeframe, cBars, draw_begin, fastsize, slowsize;
string   IndicatorName, TF, fast_name, slow_name;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   timeframe = TimeFrame;
   if(timeframe <= Period()) timeframe = Period(); 
   TF = tf(timeframe);
   
   IndicatorDigits(Digits);
//----    
   IndicatorBuffers(12);
   SetIndexBuffer( 0,   upgrow); SetIndexStyle(0,DRAW_HISTOGRAM); 
   SetIndexBuffer( 1,   dngrow); SetIndexStyle(1,DRAW_HISTOGRAM); 
   SetIndexBuffer( 2,   upfall); SetIndexStyle(2,DRAW_HISTOGRAM); 
   SetIndexBuffer( 3,   dnfall); SetIndexStyle(3,DRAW_HISTOGRAM); 
   SetIndexBuffer( 4,     fast); SetIndexStyle(4,     DRAW_LINE); 
   SetIndexBuffer( 5,     slow); SetIndexStyle(5,     DRAW_LINE); 
   SetIndexBuffer( 6,      buy); SetIndexStyle(6,    DRAW_ARROW); SetIndexArrow(6,233);    
   SetIndexBuffer( 7,     sell); SetIndexStyle(7,    DRAW_ARROW); SetIndexArrow(7,234);    
   SetIndexBuffer( 8,    trend);
   SetIndexBuffer( 9,fastshift); 
   SetIndexBuffer(10,slowshift);
   SetIndexBuffer(11,  counter);
   
//----   
   IndicatorName = WindowExpertName();
   
   IndicatorShortName(IndicatorName+"["+TF+"]("+FastLength+","+SlowLength+")");
   
   SetIndexLabel(4,"Fast UniEMA("+FastLength+")");
   SetIndexLabel(5,"Slow UniEMA("+SlowLength+")");
   SetIndexLabel(6,"buySignal");
   SetIndexLabel(7,"sellSignal");
//----         
   if(CountBars == 0) cBars = iBars(NULL,timeframe)*timeframe/Period() - MathMax(FastLength,SlowLength); else cBars = CountBars*timeframe/Period();
  
   draw_begin = Bars - cBars;
     
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   SetIndexDrawBegin(4,draw_begin);
   SetIndexDrawBegin(5,draw_begin);   
//----   
   uniema_size = MathMax(FastPole,SlowPole)*MathMax(FastOrder,SlowOrder);
   ArrayResize(uniema_tmp,uniema_size*2);
   ArrayResize(uniema_prevtime,2);
    
   
   return(0);
}
//-----
int deinit()
{
   Comment("");
   return(0);
}


//+------------------------------------------------------------------+
//| UniEMACrossover_v1.0 600+                                  |
//+------------------------------------------------------------------+
int start()
{
   int shift,limit, counted_bars=IndicatorCounted();
   double fastprice, slowprice;
      
   if(counted_bars > 0) limit = Bars - counted_bars - 1;
   if(counted_bars < 0) return(0);
   if(counted_bars < 1)
   { 
   limit = cBars + MathMax(FastLength,SlowLength) - 1;   
      for(int i=limit;i>=0;i--) 
      {
      upgrow[i] = EMPTY_VALUE;   
      dngrow[i] = EMPTY_VALUE;
      upfall[i] = EMPTY_VALUE;   
      dnfall[i] = EMPTY_VALUE;
      fast[i]   = EMPTY_VALUE;   
      slow[i]   = EMPTY_VALUE;
      buy [i]   = EMPTY_VALUE;   
      sell[i]   = EMPTY_VALUE;
      }
   }   
  
   if(FastShift < 0) int fastlimit = MathAbs(FastShift); else fastlimit = limit;
   if(SlowShift < 0) int slowlimit = MathAbs(SlowShift); else slowlimit = limit; 
      
   int limit1 = MathMax(limit,MathMax(fastlimit,slowlimit));  
   
   
   if(timeframe != Period())
   {
   limit = timeframe/Period()*(limit1 + 1);   
   
      for(shift=0;shift<limit;shift++) 
      {	
      int y = iBarShift(NULL,timeframe,Time[shift]);
	   
	   fast[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,"",FastPrice,FastLength,FastPole,FastOrder,FastWeightFactor,FastDampingFactor,FastShift,
	                         "",SlowPrice,SlowLength,SlowPole,SlowOrder,SlowWeightFactor,SlowDampingFactor,SlowShift,ShowFilled,CountBars,
	                         "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,4,y);
      slow[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,"",FastPrice,FastLength,FastPole,FastOrder,FastWeightFactor,FastDampingFactor,FastShift,
	                         "",SlowPrice,SlowLength,SlowPole,SlowOrder,SlowWeightFactor,SlowDampingFactor,SlowShift,ShowFilled,CountBars,
	                         "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,5,y);
	   buy [shift] = iCustom(NULL,TimeFrame,IndicatorName,0,"",FastPrice,FastLength,FastPole,FastOrder,FastWeightFactor,FastDampingFactor,FastShift,
	                         "",SlowPrice,SlowLength,SlowPole,SlowOrder,SlowWeightFactor,SlowDampingFactor,SlowShift,ShowFilled,CountBars,
	                         "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,6,y);
      sell[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,"",FastPrice,FastLength,FastPole,FastOrder,FastWeightFactor,FastDampingFactor,FastShift,
	                         "",SlowPrice,SlowLength,SlowPole,SlowOrder,SlowWeightFactor,SlowDampingFactor,SlowShift,ShowFilled,CountBars,
	                         "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,7,y);
      
         if(ShowFilled)
         {
         upgrow[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,"",FastPrice,FastLength,FastPole,FastOrder,FastWeightFactor,FastDampingFactor,FastShift,
	                         "",SlowPrice,SlowLength,SlowPole,SlowOrder,SlowWeightFactor,SlowDampingFactor,SlowShift,ShowFilled,CountBars,
	                         "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,0,y);
         dngrow[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,"",FastPrice,FastLength,FastPole,FastOrder,FastWeightFactor,FastDampingFactor,FastShift,
	                         "",SlowPrice,SlowLength,SlowPole,SlowOrder,SlowWeightFactor,SlowDampingFactor,SlowShift,ShowFilled,CountBars,
	                         "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,1,y);
	      upfall[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,"",FastPrice,FastLength,FastPole,FastOrder,FastWeightFactor,FastDampingFactor,FastShift,
	                         "",SlowPrice,SlowLength,SlowPole,SlowOrder,SlowWeightFactor,SlowDampingFactor,SlowShift,ShowFilled,CountBars,
	                         "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,2,y);
         dnfall[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,"",FastPrice,FastLength,FastPole,FastOrder,FastWeightFactor,FastDampingFactor,FastShift,
	                         "",SlowPrice,SlowLength,SlowPole,SlowOrder,SlowWeightFactor,SlowDampingFactor,SlowShift,ShowFilled,CountBars,
	                         "",AlertOn,AlertShift,SoundsNumber,SoundsPause,UpTrendSound,DnTrendSound,EmailOn,EmailsNumber,PushNotificationOn,3,y);
	      
	      }
      }
      
      if(CountBars > 0)
      {
      SetIndexDrawBegin(0,Bars - cBars);   
      SetIndexDrawBegin(1,Bars - cBars);
      SetIndexDrawBegin(2,Bars - cBars);
      SetIndexDrawBegin(3,Bars - cBars);   
      SetIndexDrawBegin(4,Bars - cBars);
      SetIndexDrawBegin(5,Bars - cBars);
      SetIndexDrawBegin(6,Bars - cBars);
      SetIndexDrawBegin(7,Bars - cBars);
      }   
	
	return(0);
	}
   else
   {
      for(shift=limit;shift>=0;shift--) 
      {
         if(FastPrice <= 6) fastprice = iMA(NULL,0,1,0,0,(int)FastPrice,shift);   
         else
         if(FastPrice > 6 && FastPrice <= 13) fastprice = HeikenAshi(0,FastPrice-7,shift);
      
         if(SlowPrice <= 6) slowprice = iMA(NULL,0,1,0,0,(int)SlowPrice,shift);   
         else
         if(SlowPrice > 6 && SlowPrice <= 13) slowprice = HeikenAshi(1,SlowPrice-7,shift);   
      
      
      
      fastshift[shift] = UniXMA(0,fastprice,FastLength,FastPole,FastOrder,FastWeightFactor,FastDampingFactor,shift); 
      slowshift[shift] = UniXMA(1,slowprice,SlowLength,SlowPole,SlowOrder,SlowWeightFactor,SlowDampingFactor,shift); 
      }
       
      
      for(shift=limit1;shift>=0;shift--) 
      {
      if(FastShift >= 0 ||(FastShift < 0 && shift >= MathAbs(FastShift))) fast[shift] = fastshift[shift+FastShift]; 
      if(SlowShift >= 0 ||(SlowShift < 0 && shift >= MathAbs(SlowShift))) slow[shift] = slowshift[shift+SlowShift]; 
      
      trend[shift] = trend[shift+1];
      
      buy [shift]  = EMPTY_VALUE;
      sell[shift]  = EMPTY_VALUE;
   
      counter[shift] = counter[shift+1];
      counter[shift] += 1;
      if(fast[shift] > slow[shift] && fast[shift] != EMPTY_VALUE && trend[shift+1] != 1) {trend[shift] = 1; counter[shift] = 0;}
      if(fast[shift] < slow[shift] && slow[shift] != EMPTY_VALUE && trend[shift+1] !=-1) {trend[shift] =-1; counter[shift] = 0;}
      
      
      
      double gap = 0.5*MathCeil(iATR(NULL,0,14,shift)/Point);
         
         if(trend[shift] != trend[shift+1])
         {
         if(trend[shift] > 0) buy [shift] = MathMin(fast[shift],slow[shift]) -   gap*Point;  
         if(trend[shift] < 0) sell[shift] = MathMax(fast[shift],slow[shift]) + 2*gap*Point; 
         }
         
      
         if(ShowFilled)
         {
         upgrow[shift] = EMPTY_VALUE;
         dngrow[shift] = EMPTY_VALUE;   
         upfall[shift] = EMPTY_VALUE;
         dnfall[shift] = EMPTY_VALUE;    
         
         
         double currdiff = MathAbs(fast[shift]   - slow[shift]  );
         double prevdiff = MathAbs(fast[shift+1] - slow[shift+1]);
            
            if(trend[shift] > 0)
            {
               if(trend[shift+1] <= 0) {upgrow[shift] = fast[shift]; dngrow[shift] = slow[shift];}
               else
               {
                  if(currdiff > prevdiff) {upgrow[shift] = fast[shift]; dngrow[shift] = slow[shift];}
                  else {upfall[shift] = fast[shift]; dnfall[shift] = slow[shift];}
               }
            }
            
            
            if(trend[shift] < 0)
            {
               if(trend[shift+1] >= 0) {dngrow[shift] = fast[shift]; upgrow[shift] = slow[shift];}
               else
               {
                  if(currdiff > prevdiff) {dngrow[shift] = slow[shift]; upgrow[shift] = fast[shift];}
                  else {dnfall[shift] = slow[shift]; upfall[shift] = fast[shift];}
               }
            }
         }
      }
         
      if(CountBars > 0)
      {
      SetIndexDrawBegin(0,Bars - cBars);   
      SetIndexDrawBegin(1,Bars - cBars);
      SetIndexDrawBegin(2,Bars - cBars);
      SetIndexDrawBegin(3,Bars - cBars);   
      SetIndexDrawBegin(4,Bars - cBars);
      SetIndexDrawBegin(5,Bars - cBars);
      SetIndexDrawBegin(6,Bars - cBars);
      SetIndexDrawBegin(7,Bars - cBars);
      }   
   }   
   
   if(AlertOn || EmailOn || PushNotificationOn)
   {
   bool crossAbove = trend[limit1+AlertShift] > 0 && trend[limit1+AlertShift+1] <= 0;                  
   bool crossBelow = trend[limit1+AlertShift] < 0 && trend[limit1+AlertShift+1] >= 0;
         
      if(crossAbove || crossBelow)
      {
         if(isNewBar(timeframe))
         {
            if(AlertOn)
            {
            BoxAlert(crossAbove," : BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits));   
            BoxAlert(crossBelow," : SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits)); 
            }
                   
            if(EmailOn)
            {
            EmailAlert(crossAbove,"BUY" ," : BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits),EmailsNumber); 
            EmailAlert(crossBelow,"SELL"," : SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits),EmailsNumber); 
            }
         
            if(PushNotificationOn)
            {
            PushAlert(crossAbove," : BUY Signal @ " +DoubleToStr(Close[AlertShift],Digits));   
            PushAlert(crossBelow," : SELL Signal @ "+DoubleToStr(Close[AlertShift],Digits)); 
            }
         }
         else
         {
            if(AlertOn)
            {
            WarningSound(crossAbove,SoundsNumber,SoundsPause,UpTrendSound,Time[AlertShift]);
            WarningSound(crossBelow,SoundsNumber,SoundsPause,DnTrendSound,Time[AlertShift]);
            }
         }   
      }
   }   
  
     
   return(0);
}

int      uniema_size;
double   uniema_tmp[][2];
datetime uniema_prevtime[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//----
double UniXMA(int index,double price,int len,int pole,int order,double wf,double df,int bar)
{
   int m = index*uniema_size; 
   double alpha = (wf*order)/(len + wf*order-1);
         
   if(uniema_prevtime[index] != Time[bar])
   {
   for(int k=0;k<order;k++) 
      for(int j=0;j<pole;j++) uniema_tmp[m+pole*k+j][1] = uniema_tmp[m+pole*k+j][0];
   
   uniema_prevtime[index] = Time[bar];
   }
   
   if(bar >= cBars+MathMax(FastLength,SlowLength)-2) 
   {
   for(k=0;k<order;k++) 
      for(j=0;j<pole;j++) uniema_tmp[m+pole*k+j][0] = price; 
   }
   else  
   {
      for(k=0;k<order;k++)
      {
         for(j=0;j<pole;j++)
         {   
         uniema_tmp[m+pole*k+j][0] = (1 - alpha)*uniema_tmp[m+pole*k+j][1] + alpha*price; 
         if(j > 0) price += df*(uniema_tmp[m+pole*k][0] - uniema_tmp[m+pole*k+j][0]); else price = uniema_tmp[m+pole*k+j][0];
         }
      }   
   }
   
   return(price); 
}


// HeikenAshi Price
double   haClose[2][2], haOpen[2][2], haHigh[2][2], haLow[2][2];
datetime prevhatime[2];

double HeikenAshi(int index,int price,int bar)
{ 
   if(prevhatime[index] != Time[bar])
   {
   haClose[index][1] = haClose[index][0];
   haOpen [index][1] = haOpen [index][0];
   haHigh [index][1] = haHigh [index][0];
   haLow  [index][1] = haLow  [index][0];
   prevhatime[index] = Time[bar];
   }
   
   if(bar == cBars + MathMax(FastLength,SlowLength) - 1) 
   {
   haClose[index][0] = Close[bar];
   haOpen [index][0] = Open [bar];
   haHigh [index][0] = High [bar];
   haLow  [index][0] = Low  [bar];
   }
   else
   {
   haClose[index][0] = (Open[bar] + High[bar] + Low[bar] + Close[bar])/4;
   haOpen [index][0] = (haOpen[index][1] + haClose[index][1])/2;
   haHigh [index][0] = MathMax(High[bar],MathMax(haOpen[index][0],haClose[index][0]));
   haLow  [index][0] = MathMin(Low [bar],MathMin(haOpen[index][0],haClose[index][0]));
   }
   
   switch(price)
   {
   case  0: return(haClose[index][0]); break;
   case  1: return(haOpen [index][0]); break;
   case  2: return(haHigh [index][0]); break;
   case  3: return(haLow  [index][0]); break;
   case  4: return((haHigh[index][0] + haLow[index][0])/2); break;
   case  5: return((haHigh[index][0] + haLow[index][0] +   haClose[index][0])/3); break;
   case  6: return((haHigh[index][0] + haLow[index][0] + 2*haClose[index][0])/4); break;
   default: return(haClose[index][0]); break;
   }
}     



string tf(int itimeframe)
{
   string result = "";
   
   switch(itimeframe)
   {
   case PERIOD_M1:   result = "M1" ;
   case PERIOD_M5:   result = "M5" ;
   case PERIOD_M15:  result = "M15";
   case PERIOD_M30:  result = "M30";
   case PERIOD_H1:   result = "H1" ;
   case PERIOD_H4:   result = "H4" ;
   case PERIOD_D1:   result = "D1" ;
   case PERIOD_W1:   result = "W1" ;
   case PERIOD_MN1:  result = "MN1";
   default:          result = "N/A";
   }
   
   if(result == "N/A")
   {
   if(itimeframe <  PERIOD_H1 ) result = "M"  + itimeframe;
   if(itimeframe >= PERIOD_H1 ) result = "H"  + itimeframe/PERIOD_H1;
   if(itimeframe >= PERIOD_D1 ) result = "D"  + itimeframe/PERIOD_D1;
   if(itimeframe >= PERIOD_W1 ) result = "W"  + itimeframe/PERIOD_W1;
   if(itimeframe >= PERIOD_MN1) result = "MN" + itimeframe/PERIOD_MN1;
   }
   
   return(result); 
}                  




datetime prevnbtime;

bool isNewBar(int tf)
{
   bool res = false;
   
   if(tf >= 0)
   {
      if(iTime(NULL,tf,0) != prevnbtime)
      {
      res   = true;
      prevnbtime = iTime(NULL,tf,0);
      }   
   }
   else res = true;
   
   return(res);
}

string prevmess;
 
bool BoxAlert(bool cond,string text)   
{      
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text;
   
   if (cond && mess != prevmess)
	{
	Alert (mess);
	prevmess = mess; 
	return(true);
	} 
  
   return(false);  
}

datetime pausetime;

bool Pause(int sec)
{
   if(TimeCurrent() >= pausetime + sec) {pausetime = TimeCurrent(); return(true);}
   
   return(false);
}

datetime warningtime;

void WarningSound(bool cond,int num,int sec,string sound,datetime curtime)
{
   static int i;
   
   if(cond)
   {
   if(curtime != warningtime) i = 0; 
   if(i < num && Pause(sec)) {PlaySound(sound); warningtime = curtime; i++;}       	
   }
}

string prevemail;

bool EmailAlert(bool cond,string text1,string text2,int num)   
{      
   string subj = "New " + text1 +" Signal from " + IndicatorName + "!!!";    
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text2;
   
   if (cond && mess != prevemail)
	{
	if(subj != "" && mess != "") for(int i=0;i<num;i++) SendMail(subj, mess);  
	prevemail = mess; 
	return(true);
	} 
  
   return(false);  
}

string prevpush;
 
bool PushAlert(bool cond,string text)   
{      
   string push = IndicatorName + "("+Symbol() + "," + TF + ")" + text;
   
   if(cond && push != prevpush)
	{
	SendNotification(push);
	
	prevpush = push; 
	return(true);
	} 
  
   return(false);  
}

