//+------------------------------------------------------------------+
//|                                           Volume Wave Expert.mq4 |
//|                                      credit Progammer Master TnR |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Volume Wave PT CEO Adi Putranto"

#property indicator_separate_window
#property indicator_minimum 0

#property indicator_buffers 5
#property indicator_color1  clrGray
#property indicator_color2  clrGreen
#property indicator_color3  clrRed
#property indicator_color4  clrMagenta
#property indicator_color5  clrMagenta
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2


input ENUM_TIMEFRAMES   TimeFrame         =     0;       // Timeframe
input bool              AlertEmail        = false;
input bool              AlertSound        =  true;
input bool              AlertPopup        =  true;

extern bool             ShowNormalVolume  =  true;
extern int              Search_Distance   =    10;

datetime       LastAlert;

double red[],green[];

//---- indicator buffers
double     ExtBuffer1[];
double     ExtBuffer2[];
double     ExtBuffer3[];
double     ExtBuffer4[];
double     ExtBuffer5[];
//----
int timeframe;
string IndicatorName, TF;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   timeframe = TimeFrame;
   if(timeframe <= Period()) timeframe = Period(); 
   TF = tf(timeframe);


//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexLabel(1,"GREEN");
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexLabel(2,"RED");
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexStyle(4,DRAW_ARROW);

   SetIndexBuffer(0,ExtBuffer1);
   SetIndexBuffer(1,ExtBuffer2);
   SetIndexBuffer(2,ExtBuffer3);
   SetIndexBuffer(3,ExtBuffer4);
   SetIndexBuffer(4,ExtBuffer5);
   SetIndexArrow(4,78);
   
   IndicatorName = WindowExpertName(); 
   
   IndicatorShortName("VOLUME WAVE CORE["+TF+"]("+Search_Distance+")");
   SetIndexLabel(0,"Volume");
   IndicatorDigits(0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
//----
  for(int i=0;i<Bars;i++)
     {
      ObjectDelete("ELxUP "+DoubleToStr(Time[i],0 ));
      ObjectDelete("EUxUP "+DoubleToStr(Time[i],0 ));
      ObjectDelete("ELxDN "+DoubleToStr(Time[i],0 ));
      ObjectDelete("EUxDN "+DoubleToStr(Time[i],0 ));
      }
     
//----
   return(0);
  }
//+------------------------------------------------------------------+  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit,status;
   int counted_bars=IndicatorCounted();
//----
	if (counted_bars>0) counted_bars--;
	limit=Bars-counted_bars;
	
	if(timeframe != Period())
	{
   limit = MathMax(limit,timeframe/Period());   
      
      for(int i=0;i<limit;i++) 
      {	
      int y = iBarShift(NULL,TimeFrame,Time[i]);
            
      ExtBuffer1[i] = iCustom(NULL,TimeFrame,IndicatorName,0,AlertEmail,AlertSound,AlertPopup,ShowNormalVolume,Search_Distance,0,y);    
      ExtBuffer2[i] = iCustom(NULL,TimeFrame,IndicatorName,0,AlertEmail,AlertSound,AlertPopup,ShowNormalVolume,Search_Distance,1,y);    
      ExtBuffer3[i] = iCustom(NULL,TimeFrame,IndicatorName,0,AlertEmail,AlertSound,AlertPopup,ShowNormalVolume,Search_Distance,2,y);    
      ExtBuffer4[i] = iCustom(NULL,TimeFrame,IndicatorName,0,AlertEmail,AlertSound,AlertPopup,ShowNormalVolume,Search_Distance,3,y);    
      ExtBuffer5[i] = iCustom(NULL,TimeFrame,IndicatorName,0,AlertEmail,AlertSound,AlertPopup,ShowNormalVolume,Search_Distance,4,y);    
      }  
 
	return(0);
	}
	
	for (i=limit; i>=0; i--){
		status=0;
		if (iHigh(NULL,0,i)>=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,Search_Distance,i))) status+=1;
		if (iLow(NULL,0,i)<=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,Search_Distance,i)))     status+=2;
		switch(status){
			case 0:  if (ShowNormalVolume) ExtBuffer1[i]=Volume[i]; break;
			case 1:  ExtBuffer2[i]=Volume[i]; break;
			case 2:  ExtBuffer3[i]=Volume[i]; break;
			default: ExtBuffer4[i]=Volume[i]; ExtBuffer5[i]=Volume[i]+(Period()*30); break;
	    		
		}
	}
			
	for( i=limit; i>=0; i--) 
   {
       if ( ExtBuffer3[i]>ExtBuffer2[i] )
      {
      //ExtMapBuffer6[i] = Low[1]-5*Point;
      ObjectCreate("ELxUP " + DoubleToStr(Time[i],0), OBJ_ARROW, 0, Time[i], (Low[i+1]-5*Point));
      ObjectSet   ("ELxUP " + DoubleToStr(Time[i],0), OBJPROP_ARROWCODE, 233);
      ObjectSet   ("ELxUP " + DoubleToStr(Time[i],0), OBJPROP_COLOR, White);
      }             
      if (ExtBuffer2[i]> ExtBuffer3[i] )
      {
      //ExtMapBuffer6[i] = Low[1]-5*Point;
      ObjectCreate("EUxDN " + DoubleToStr(Time[i],0), OBJ_ARROW, 0, Time[i], (High[i+1]+5*Point));
      ObjectSet   ("EUxDN " + DoubleToStr(Time[i],0), OBJPROP_ARROWCODE, 234);
      ObjectSet   ("EUxDN " + DoubleToStr(Time[i],0), OBJPROP_COLOR,  Yellow);
      }     
   }              
//----

//----Alert Code - gah

   if (AlertEmail || AlertSound || AlertPopup)
      if (Time[0] != LastAlert) {
         LastAlert = Time[0];

         if (ExtBuffer3[1] > 0 && ExtBuffer3[1] != EMPTY_VALUE) {
            if (AlertSound)
               PlaySound("alert.wav");
            if (AlertPopup)
               Alert(Symbol() +" "+TF+ " RED at " + TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES));
            if (AlertEmail)
               SendMail(IndicatorName + " - " + Symbol() +" "+TF+ " RED at " + TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES),"New Climax High");
         }//if (red[1] > 0)          

         if (ExtBuffer2[1] > 0 && ExtBuffer2[1] != EMPTY_VALUE) {
            if (AlertSound)
               PlaySound("alert.wav");
            if (AlertPopup)
               Alert(Symbol() +" "+TF+ " GREEN at " + TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES));
            if (AlertEmail)
               SendMail(IndicatorName + " - " + Symbol() +" "+TF+ " GREEN at " + TimeToStr(TimeLocal(),TIME_DATE|TIME_MINUTES),"New Climax Low");
         }//if (green[1] > 0) 
         
      }//if (Time[0] != LastAlert) 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

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

