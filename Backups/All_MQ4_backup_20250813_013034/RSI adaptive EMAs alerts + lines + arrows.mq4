//+------------------------------------------------------------------+ 
//| ARSI.mq4 
//+------------------------------------------------------------------+ 
#property copyright "Alexander Kirilyuk M." 
#property link "" 

#property indicator_separate_window
//#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DRAW_NONE
#property indicator_color2 DRAW_NONE
#property indicator_color3 DRAW_NONE
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1

//
//
//
//
//

extern int    ARSI1Period     = 21;
extern int    ARSI2Period     = 5;
extern int    ARSI3Period     = 89;
extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsNotify    = false;
extern bool   alertsEmail     = false;
extern string soundFile       = "alert2.wav";

extern bool   LinesVisible    = true;
extern string LinesID         = "3rsiadpema";
extern color  LinesUpColor    = Green;
extern color  LinesDnColor    = Purple;
extern int    LinesStyle      = STYLE_SOLID;
extern int    LinesWidth      = 2;

extern bool   ShowArrows       = false;
extern string arrowsIdentifier = "rsiadapt Arrows1";
extern double arrowsUpperGap   = 1.0;
extern double arrowsLowerGap   = 1.0;
extern color  arrowsUpColor    = LimeGreen;
extern color  arrowsDnColor    = Red;
extern int    arrowsUpCode     = 241;
extern int    arrowsDnCode     = 242;


//---- buffers 
double ARSI1[]; 
double ARSI2[]; 
double ARSI3[]; 
double trend[];
string shortName;

int init()
{ 
	
   IndicatorBuffers(4);
	SetIndexBuffer(0,ARSI1); 
	SetIndexBuffer(1,ARSI2);
   SetIndexBuffer(2,ARSI3);
   SetIndexBuffer(3,trend); 
   shortName = LinesID+" 2+1 RSI adaptive EMAs (" + ARSI1Period + "," + ARSI2Period+")";
   IndicatorShortName(shortName);
	return(0); 
} 
int deinit()
{
   string find = LinesID+":";
   for (int i=ObjectsTotal()-1; i>= 0; i--)
   {
      string name = ObjectName(i); if (StringFind(name,find)==0) ObjectDelete(name);
   }
   deleteArrows(); 
return(0); 
}

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
           int window = WindowFind(shortName);

   //
   //
   //
   //
   //
	
	for(int i=limit; i>=0; i--)
	{
		double sc = MathAbs(iRSI(NULL, 0, ARSI1Period, PRICE_CLOSE, i)/100.0 - 0.5) * 2.0;
		if( Bars - i <= ARSI1Period)
   			ARSI1[i] = Close[i];
		else	ARSI1[i] = ARSI1[i+1] + sc * (Close[i] - ARSI1[i+1]);
		sc = MathAbs(iRSI(NULL, 0, ARSI2Period, PRICE_CLOSE, i)/100.0 - 0.5) * 2.0;
		if( Bars - i <= ARSI2Period)
   			ARSI2[i] = Close[i];
		else	ARSI2[i] = ARSI2[i+1] + sc * (Close[i] - ARSI2[i+1]);
		sc = MathAbs(iRSI(NULL, 0, ARSI3Period, PRICE_CLOSE, i)/100.0 - 0.5) * 2.0;
		if( Bars - i <= ARSI3Period)
   			ARSI3[i] = Close[i];
		else	ARSI3[i] = ARSI3[i+1] + sc * (Close[i] - ARSI3[i+1]);
		trend[i] = trend[i+1];
		if (ARSI1[i]<ARSI2[i]) trend[i] = 1;
		if (ARSI1[i]>ARSI2[i]) trend[i] =-1;
		
		//
      //
      //
      //
      //
            
      if (LinesVisible && window>-1)
 	   {
 	      string name = LinesID+":"+Time[i];
 	         ObjectDelete(name);
 	         if (trend[i] != trend[i+1])
 	         {
 	            color theColor  = LinesUpColor; if (trend[i]==-1) theColor = LinesDnColor;
 	             ObjectCreate(name,OBJ_VLINE,window,Time[i],0);
 	                ObjectSet(name,OBJPROP_WIDTH,LinesWidth);
 	                ObjectSet(name,OBJPROP_STYLE,LinesStyle);
 	                ObjectSet(name,OBJPROP_COLOR,theColor);
 	         }
 	   } 
 	   
 	   //
      //
      //
      //
      //
            
      if (ShowArrows)
      {
         deleteArrow(Time[i]);
         if (trend[i] != trend[i+1])
         {
            if (trend[i] == 1)  drawArrow(i,arrowsUpColor,arrowsUpCode,false);
            if (trend[i] ==-1)  drawArrow(i,arrowsDnColor,arrowsDnCode, true);
         }
      } 
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
      if (trend[whichBar] != trend[whichBar+1])
      if (trend[whichBar] == 1)
            doAlert("crossing up");
      else  doAlert("crossing down");       
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," 3 RSI adaptive EMAs ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," 3 RSI adaptive EMAs  "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}
      


