//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_chart_window

//
//
//
//
//

extern string TimeFrame        = "current time frame";
extern int    CCIPeriod        = 55;
extern int    CCIPrice         = PRICE_TYPICAL;
extern string UniqueID         = "CCI zones";
extern color  ColorUp          = PaleGreen;
extern color  ColorDown        = C'249,200,225';
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;
extern double Dummy            = -1;

double colors[];

int    timeFrame;
string indicatorFileName;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int init()
{
   IndicatorBuffers(1);
   SetIndexBuffer(0,colors); SetIndexStyle(0,DRAW_NONE);
      timeFrame         = stringToTimeFrame(TimeFrame);
      indicatorFileName = WindowExpertName();
   return(0);
}
int deinit()
{
   string lookFor       = UniqueID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
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

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         
         //
         //
         //
         //
         //

         datetime tDummy = Dummy;
         if (timeFrame!=Period()) 
         { 
            iCustom(NULL,timeFrame,indicatorFileName,"",CCIPeriod,CCIPrice,UniqueID,ColorUp,ColorDown,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,Time[0],0,0); 
            return(0); 
         }
         else if (Dummy<=Time[0]) tDummy = Time[0];
         static bool secondTime=false;
         if (secondTime)
         {
            int count=0;
            for (;limit<Bars; limit++) if (colors[limit]!=colors[limit+1]) { count++; if (count>1) break; }
         }
         else secondTime=true;

   //
   //
   //
   //
   //

      double MaxValue = High[0]*10.0;   
      for(i = limit; i>=0 ; i--)
      {
         if (i>Bars-2) continue;

         //
         //
         //
         //
         //
         
         double cci = iCCI(NULL,0,CCIPeriod,CCIPrice,i);
         colors[i]  = colors[i+1];
            
            //
            //
            //
            //
            //

               if (cci>0) colors[i] =  1;
               if (cci<0) colors[i] = -1;
               for (int index=i; index<Bars; index++) if (colors[index]!=colors[index+1]) break;
               string name = UniqueID+":"+Time[index+1]; ObjectDelete(name); ObjectDelete(UniqueID+":"+Time[1]);
               
               //
               //
               //
               //
               //
               
               datetime lastTime = Time[i-1]; if (i==0) { lastTime = tDummy; if (Time[index]==lastTime) lastTime = Time[0]+Period()*60;}
               ObjectCreate(name,OBJ_RECTANGLE,0,Time[index],0,lastTime,MaxValue);
                  ObjectSet(name,OBJPROP_BACK,true);
                  switch ((int)colors[i])
                  {
                     case -1 : ObjectSet(name,OBJPROP_COLOR,ColorDown); break;
                     default : ObjectSet(name,OBJPROP_COLOR,ColorUp);   break;
                  }
   }
   manageAlerts();
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
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; 
      if (colors[whichBar] != colors[whichBar+1])
      {
         if (colors[whichBar] ==  1) doAlert(whichBar,"up");
         if (colors[whichBar] == -1) doAlert(whichBar,"down");
      }
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message = timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" CCI trend changed to "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," CCI zones "),message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
   StringToUpper(tfs);
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