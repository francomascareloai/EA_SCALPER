//+------------------------------------------------------------------+
//|                                                        DT_ZZ.mq4 +
//|                                                                  +
//|                           20.03.16 добавил звук поручик          +
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, klot."
#property link      "klot@mail.ru"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrMagenta
#property indicator_color2 clrDeepPink
#property indicator_color3 clrDodgerBlue

#property indicator_width2 1
#property indicator_width3 1 


//---- indicator parameters
extern int    ExtDepth        = 12;
extern bool   alertsOn        = true;
extern bool   alertsOnCurrent = true;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = true;
extern bool   alertsEmail     = false;

extern bool use_sound = true;
extern string up_sound = "Пробой_вверх";
extern string down_sound = "Пробой_вниз";



double zzL[];
double zzH[];
double zz[];


int init()
  {
   
   SetIndexBuffer(0,zz);  SetIndexStyle(0,DRAW_SECTION);  
   SetIndexBuffer(1,zzH); SetIndexStyle(1,DRAW_ARROW);   
   SetIndexBuffer(2,zzL); SetIndexStyle(2,DRAW_ARROW);   
   
   SetIndexArrow(1,236);
   SetIndexArrow(2,238);
   
   
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
     

   IndicatorShortName("DT_ZZ("+ExtDepth+")");

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    i,shift,pos,lasthighpos,lastlowpos,curhighpos,curlowpos;
   double curlow,curhigh,lasthigh,lastlow;
   double min, max;
   ArrayInitialize(zz,0.0);
   ArrayInitialize(zzL,0.0);
   ArrayInitialize(zzH,0.0);
   
   lasthighpos=Bars; lastlowpos=Bars;
   lastlow=Low[Bars];lasthigh=High[Bars];
  for(shift=Bars-ExtDepth; shift>=0; shift--)
    {
      curlowpos=Lowest(NULL,0,MODE_LOW,ExtDepth,shift);
      curlow=Low[curlowpos];
      curhighpos=Highest(NULL,0,MODE_HIGH,ExtDepth,shift);
      curhigh=High[curhighpos];
      //------------------------------------------------
      if( curlow>=lastlow ) { lastlow=curlow; }
      else
         { 
            //идем вниз
            if( lasthighpos>curlowpos  ) 
            { 
            zzL[curlowpos]=curlow;
              ///*
              min=100000; pos=lasthighpos;
               for(i=lasthighpos; i>=curlowpos; i--)
                  { 
                    if (zzL[i]==0.0) continue;
                    if (zzL[i]<min) { min=zzL[i]; pos=i; }
                    zz[i]=0.0;
                  } 
               zz[pos]=min;
               //*/
            } 
          lastlowpos=curlowpos;
          lastlow=curlow; 
         }
      //--- high
      if( curhigh<=lasthigh )  { lasthigh=curhigh;}
      else
         {  
            // идем вверх
            if( lastlowpos>curhighpos ) 
            {  
            zzH[curhighpos]=curhigh;
           ///*
               max=-100000; pos=lastlowpos;
               for(i=lastlowpos; i>=curhighpos; i--)
                  { 
                    if (zzH[i]==0.0) continue;
                    if (zzH[i]>max) { max=zzH[i]; pos=i; }
                    zz[i]=0.0;
                  } 
               zz[pos]=max;
           //*/     
            }  
         lasthighpos=curhighpos;
         lasthigh=curhigh;    
         } 
         }      
    //---------------------------------------------------------------------

   if (alertsOn)
   {
      if (alertsOnCurrent)
         int whichBar = 0;
      else   whichBar = 1;
      if (zzH[whichBar] > 0) PlaySound("Пробой_вверх.wav");
  
      if (zzL[whichBar] > 0) PlaySound("Пробой_вниз.wav");
    
   }   
   return(0);
}

//+------------------------------------------------------------------+
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

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," DT_ZZ ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," DT_ZZ "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}


