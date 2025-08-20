//+------------------------------------------------------------------+
//|   BetterVolumeTicks.mq4
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_color1  clrRed
#property indicator_color2  clrDarkGray
#property indicator_color3  clrYellow
#property indicator_color4  clrLime
#property indicator_color5  clrWhite
#property indicator_color6  clrMagenta
#property indicator_color7  clrLime
#property indicator_color8  clrRed
#property indicator_color9  clrRed
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2
#property indicator_width9  2

//
//
//
//
//

input int       VolPeriod          = 15;
input double    VolPhase           = 0.0;              // Jurik phase 
input bool      VolDouble          = false;            // Jurik smooth double
input int       LookBack           = 7;
input double    BuySellDistance    = 50;
input string    note               = "turn on Alert = true; turn off = false";
input bool      alertsOn           = true;
input bool      alertsOnCurrent    = true;
input bool      alertsMessage      = true;
input bool      alertsSound        = true;
input bool      alertsEmail        = false;
input bool      alertsNotify       = false;
input string    soundFile          = "alert2.wav";
input bool      ShowLabels         = true;
input string    labelsIdentifier   = "better volume1";
input int       fontSize           = 8;
input int       xDistance          = 10;
input int       yDistance          = 10;
input color     LabelsColorUp      = clrLimeGreen;
input color     LabelsColorNeutral = clrDimGray;
input color     LabelsColorDown    = clrRed;

//
//
//
//
//

double modifier = 1,ClimaxHi[],Neutral[],LoVolume[],Churn[],ClimaxLo[],ClimaxChurn[],AvgVol[],avda[],avdb[],UpTicks[],DnTicks[],VolRange[],VolSort[],slope[];
string symbol,shortName;
int    digits;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//
//

int OnInit()
{
   IndicatorBuffers(14);
   SetIndexBuffer(0, ClimaxHi,   INDICATOR_DATA); SetIndexStyle(0,DRAW_HISTOGRAM); SetIndexLabel(0,"ClimaxHi");
   SetIndexBuffer(1, Neutral,    INDICATOR_DATA); SetIndexStyle(1,DRAW_HISTOGRAM); SetIndexLabel(1,"Neutral");
   SetIndexBuffer(2, LoVolume,   INDICATOR_DATA); SetIndexStyle(2,DRAW_HISTOGRAM); SetIndexLabel(2,"LoVolume");
   SetIndexBuffer(3, Churn,      INDICATOR_DATA); SetIndexStyle(3,DRAW_HISTOGRAM); SetIndexLabel(3,"Churn");
   SetIndexBuffer(4, ClimaxLo,   INDICATOR_DATA); SetIndexStyle(4,DRAW_HISTOGRAM); SetIndexLabel(4,"ClimaxLo");
   SetIndexBuffer(5, ClimaxChurn,INDICATOR_DATA); SetIndexStyle(5,DRAW_HISTOGRAM); SetIndexLabel(5,"ClimaxChurn");
   SetIndexBuffer(6, AvgVol,     INDICATOR_DATA); SetIndexStyle(6,DRAW_LINE);      SetIndexLabel(6,"AvgVolume");
   SetIndexBuffer(7, avda,       INDICATOR_DATA); SetIndexStyle(7,DRAW_LINE);      SetIndexLabel(7,"AvgVolume");
   SetIndexBuffer(8, avdb,       INDICATOR_DATA); SetIndexStyle(8,DRAW_LINE);      SetIndexLabel(8,"AvgVolume");
   SetIndexBuffer(9, UpTicks);  
   SetIndexBuffer(10,DnTicks);  
   SetIndexBuffer(11,VolRange);   
   SetIndexBuffer(12,VolSort);
   SetIndexBuffer(13,slope);                              

   symbol = Symbol(); if (StringSubstr(symbol,0,2)=="_t") symbol = StringSubstr(symbol,2);
   digits = MarketInfo(symbol,MODE_DIGITS);   
	if(digits == 3 || digits == 5) modifier = 10;
	
	shortName = labelsIdentifier+":  Better Volume";
   IndicatorShortName(shortName);   
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   string lookFor       = labelsIdentifier+":";
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

int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1; 
   
   //
   //
   //
   
   if  (slope[i] == -1) CleanPoint(i,avda,avdb);
   for (; i>=0 && !_StopFlag; i--)
   {
      VolSort[i]   = tick_volume[i]/modifier;
      AvgVol[i]    = iDSmooth(VolSort[i],VolPeriod,VolPhase,VolDouble,i);
      double Range = high[i]-low[i];
      double CountUp = (tick_volume[i]+(close[i]-open[i])/_Point)/2;
      double CountDn = tick_volume[i]-CountUp;
      double diff    = fabs(CountUp-CountDn);
      slope[i] = (i<rates_total-1) ? (AvgVol[i]>AvgVol[i+1]) ? 1 : (AvgVol[i]<AvgVol[i+1]) ? -1 : slope[i+1] : 0;  
      avda[i]  = avdb[i]  = EMPTY_VALUE; if (slope[i] == -1) PlotPoint(i,avda,avdb,AvgVol);  
      

      UpTicks[i] = CountUp*Range;
      DnTicks[i] = CountDn*Range;
      
      if (Range != 0) { VolRange[i] = tick_volume[i]/Range; }
      
      double LoVol = tick_volume[iLowest(NULL, 0,MODE_VOLUME,LookBack,i)];
      double HiVol = tick_volume[iHighest(NULL,0,MODE_VOLUME,LookBack,i)];

      double HiUpTick = UpTicks[FindMaxUp(i)];
      double HiDnTick = DnTicks[FindMaxDn(i)];
      double MaxVol   = VolRange[FindMaxVol(i)];
      
      Neutral[i]     = tick_volume[i]/modifier;
      ClimaxHi[i]    = EMPTY_VALUE;      
      ClimaxLo[i]    = EMPTY_VALUE;      
      Churn[i]       = EMPTY_VALUE;      
      LoVolume[i]    = EMPTY_VALUE;      
      ClimaxChurn[i] = EMPTY_VALUE;      
      
      if (tick_volume[i] == LoVol)
      {
         LoVolume[i] = tick_volume[i]/modifier;
         Neutral[i]  = EMPTY_VALUE;
      }

      if (VolRange[i] == MaxVol)
      {
         Churn[i]    = tick_volume[i]/modifier;                
         Neutral[i]  = EMPTY_VALUE;
         LoVolume[i] = EMPTY_VALUE;
      }

      if (UpTicks[i] == HiUpTick && close[i] >= (high[i]+low[i])*0.5)
      {
         ClimaxHi[i] = tick_volume[i]/modifier;
         Neutral[i]  = EMPTY_VALUE;
         LoVolume[i] = EMPTY_VALUE;
         Churn[i]    = EMPTY_VALUE;
      }   
         
      if (DnTicks[i] == HiDnTick && close[i] <= (high[i]+low[i])*0.5)
      {
         ClimaxLo[i] = tick_volume[i]/modifier;
         Neutral[i]  = EMPTY_VALUE;
         LoVolume[i] = EMPTY_VALUE;
         Churn[i]    = EMPTY_VALUE;
      }   
         
      if (VolRange[i] == MaxVol && (ClimaxHi[i] != EMPTY_VALUE || ClimaxLo[i] != EMPTY_VALUE))
      {
         ClimaxChurn[i] = tick_volume[i]/modifier;
         ClimaxHi[i]    = EMPTY_VALUE;
         ClimaxLo[i]    = EMPTY_VALUE;
         Churn[i]       = EMPTY_VALUE;
         Neutral[i]     = EMPTY_VALUE;
       }
        
      }
     
      //
      //
      //
      //
      //
      
      if (alertsOn)
      {
        int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
        static datetime time1 = 0;
        static string   mess1 = "";
           if (ClimaxHi[whichBar+1]    == EMPTY_VALUE && ClimaxHi[whichBar]    != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Climax High");
           if (Neutral[whichBar+1]     == EMPTY_VALUE && Neutral[whichBar]     != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Neutral");
           if (LoVolume[whichBar+1]    == EMPTY_VALUE && LoVolume[whichBar]    != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Low");
           if (Churn[whichBar+1]       == EMPTY_VALUE && Churn[whichBar]       != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"High Churn");
           if (ClimaxLo[whichBar+1]    == EMPTY_VALUE && ClimaxLo[whichBar]    != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Climax Low");
           if (ClimaxChurn[whichBar+1] == EMPTY_VALUE && ClimaxChurn[whichBar] != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Climax Churn");          
      }                   
      if (ShowLabels) manageLabels();
return(rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

double wrk[][20];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0) 
{
   if (isDouble)
         return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  return (iSmooth(price,length,phase,i,s));
}

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { int k; for(k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            double dVolty = 0;
            if (wrk[r][avolty+s] > 0)
                  dVolty = wrk[r][volty+s]/wrk[r][avolty+s];   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
}

//
//
//
//
//

int FindMaxUp(int i)      
{
   int x,y;
   double max=0;
   for(x=LookBack-1;x>=0;x--) { if(UpTicks[i+x] > max) { y = i+x; max = UpTicks[y];  } }
return(y);
}

//
//
//
//
//

int FindMaxDn(int i)      
{
   int x,y;
   double max=0;
   for(x=LookBack-1;x>=0;x--) { if(DnTicks[i+x] > max) { y = i+x; max = DnTicks[y]; } }
return(y);
}

//
//
//
//
//

int FindMaxVol(int i)      
{
   int x,y;
   double max=0;
   for(x=LookBack-1;x>=0;x--)  { if(VolRange[i+x] > max) { y = i+x; max = VolRange[y]; }}
return(y);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];
       
       //
       //
       //
       //
       //

       message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Better Volume "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(_Symbol+" Better Volume ",message);
          if (alertsSound)   PlaySound(soundFile);
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

void manageLabels()
{
   int window = WindowFind(shortName);
   double ut = (Volume[0]+(Close[0]-Open[0])/_Point) / 2.0;
   double dt = (Volume[0] - ut);
   color theColor = LabelsColorNeutral;
      if (ut > dt) theColor = LabelsColorUp;
      if (ut < dt) theColor = LabelsColorDown;
   
   //
   //
   //
   //
   //
      
   string name = labelsIdentifier+":"+"label_bv";
         if(ObjectFind (name) == -1)
            ObjectCreate(name, OBJ_LABEL, window, 0, 0);
               ObjectSet(name, OBJPROP_XDISTANCE, xDistance);
               ObjectSet(name, OBJPROP_YDISTANCE, yDistance);
               ObjectSet(name, OBJPROP_CORNER, 1);
               ObjectSetText(name,"Buyers : " + DoubleToStr(ut,0), fontSize, "Arial Black", theColor);

      name = labelsIdentifier+":"+"label_sv";
         if(ObjectFind (name) == -1)
            ObjectCreate(name, OBJ_LABEL, window, 0, 0);
               ObjectSet(name, OBJPROP_XDISTANCE, xDistance);
               ObjectSet(name, OBJPROP_YDISTANCE, yDistance+14);
               ObjectSet(name, OBJPROP_CORNER, 1);
               ObjectSetText(name,"Sellers : " + DoubleToStr(dt,0), fontSize, "Arial Black", theColor);

}

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
      
                  