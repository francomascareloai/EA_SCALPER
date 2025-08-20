//------------------------------------------------------------------
//
//
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 1
extern int     ExtDepth         = 30;
extern int     ExtDeviation     = 5;
extern int     ExtBackstep      = 3;
extern string  FiboLevels       = "0;23.6;38.2;50;61.8;100";
extern color   Fibo1Color       = clrDodgerBlue;
extern int     Fibo1Width       = 1;
extern int     Fibo1Style       = STYLE_DOT;
extern int     Fibo1LevelsStyle = STYLE_SOLID;
extern bool    ShowSecondFibo   = true;
extern color   Fibo2Color       = clrDarkSlateGray;
extern int     Fibo2Width       = 1;
extern int     Fibo2Style       = STYLE_DOT;
extern int     Fibo2LevelsStyle = STYLE_SOLID;
extern bool    ShowThirdFibo    = true;
extern color   Fibo3Color       = clrGoldenrod;
extern int     Fibo3Width       = 1;
extern int     Fibo3Style       = STYLE_DOT;
extern int     Fibo3LevelsStyle = STYLE_SOLID;

//
//
//
//
//

extern string _                      = "alerts behaviour";
extern bool   alertsOn               = false;
extern double alertsTolerance        = 1.0;
extern bool   touchChanell           = false;
extern bool   alertsOnCurrent        = false;
extern bool   alertsMessage          = true;
extern bool   alertsSound            = false;
extern bool   alertsNotify           = false;
extern bool   alertsEmail            = false;
extern bool   alertsShowTouched      = true;
extern string soundFile              = "alert2.wav"; 
extern int    barsToShowCandles      = 1000;
extern color  BarUpColor             = Green; 
extern color  BarDownColor           = Red; 
extern color  WickColor              = Gray;
extern int    CandleWidth            = 3;

//
//
//
//
//

double ExtMapBuffer[];
double ExtLowBuffer[];
double ExtHighBuffer[];

//
//
//
//
//

int    totalCandles;
string windowID;
double levelv[];
string levels[];
double values[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{

      FiboLevels = StringTrimLeft(StringTrimRight(FiboLevels));
      if (StringSubstr(FiboLevels,StringLen(FiboLevels),1) != ";")
                       FiboLevels = StringConcatenate(FiboLevels,";");

         //
         //
         //
         //
         //                                   

         int  s      = 0;
         int  i      = StringFind(FiboLevels,";",s);
         string current;
            while (i > 0)
            {
               current = StringSubstr(FiboLevels,s,i-s);
               ArrayResize(levels,ArraySize(levels)+1); levels[ArraySize(levels)-1] =             current+" price %$ ";
               ArrayResize(levelv,ArraySize(levelv)+1); levelv[ArraySize(levelv)-1] = StrToDouble(current);
                           s = i + 1;
                               i = StringFind(FiboLevels,";",s);
            }
         ArrayResize(values,ArraySize(levelv));
   //
   //
   //
   //
   //
   
   IndicatorBuffers(4);
      SetIndexBuffer(1,ExtMapBuffer);
      SetIndexBuffer(2,ExtLowBuffer);
      SetIndexBuffer(3,ExtHighBuffer);
      SetIndexEmptyValue(1,0.0);
      SetIndexEmptyValue(2,0.0);
      SetIndexEmptyValue(3,0.0);
   IndicatorShortName("fibo retracement("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
   return(0);
}
int deinit()
{
	ObjectDelete("Fibo1");
	ObjectDelete("Fibo2");
	ObjectDelete("Fibo3");
	deleteCandles();
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

int start()
{
   CalculateZigZag();

   //
   //
   //
   //
   //
   
   string fibo;
   int i;
  	int LastZigZag;
  	int PreviousZigZag;
  	int PPreviousZigZag;
  	int PPPreviousZigZag;
      for (int z=0;z<Bars;z++) { if (ExtMapBuffer[z]!=0) break; } LastZigZag=z;
      for (    z++;z<Bars;z++) { if (ExtMapBuffer[z]!=0) break; } PreviousZigZag=z;
      for (    z++;z<Bars;z++) { if (ExtMapBuffer[z]!=0) break; } PPreviousZigZag=z;
      for (    z++;z<Bars;z++) { if (ExtMapBuffer[z]!=0) break; } PPPreviousZigZag=z;
      
      //
      //
      //
      //
      //
      
      
      fibo = "Fibo3";           
      if( ObjectFind(fibo)==-1 )
         {
            ObjectCreate(fibo, OBJ_FIBO, 0,Time[PreviousZigZag], ExtMapBuffer[LastZigZag], Time[LastZigZag], ExtMapBuffer[PreviousZigZag]);
            ObjectSet(fibo,OBJPROP_COLOR,Fibo1Color);
            ObjectSet(fibo,OBJPROP_STYLE,Fibo1Style);
            ObjectSet(fibo,OBJPROP_WIDTH,Fibo1Width);
            ObjectSet(fibo,OBJPROP_LEVELCOLOR,Fibo1Color);
            ObjectSet(fibo,OBJPROP_LEVELSTYLE,Fibo1LevelsStyle);
               ObjectSet(fibo,OBJPROP_FIBOLEVELS,ArraySize(levelv));
               for (i=ArraySize(levelv)-1;i>=0;i--)
                  {
                     ObjectSet(fibo,OBJPROP_FIRSTLEVEL+i,levelv[i]/100);
                     ObjectSetFiboDescription(fibo,i,levels[i]);
                  }                     
          }
          ObjectSet(fibo,OBJPROP_TIME1,Time[PreviousZigZag]);
          ObjectSet(fibo,OBJPROP_TIME2,Time[LastZigZag]);
          ObjectSet(fibo,OBJPROP_PRICE1,ExtMapBuffer[LastZigZag]);
          ObjectSet(fibo,OBJPROP_PRICE2,ExtMapBuffer[PreviousZigZag]);
          
      //
      //
      //
      //
      //
                
      if (ShowSecondFibo)          
      {
         fibo = "Fibo2";           
         if( ObjectFind(fibo)==-1 )
         {
            ObjectCreate(fibo, OBJ_FIBO, 0,Time[PPreviousZigZag], ExtMapBuffer[PreviousZigZag], Time[PreviousZigZag], ExtMapBuffer[PPreviousZigZag]);
            ObjectSet(fibo,OBJPROP_COLOR,Fibo2Color);
            ObjectSet(fibo,OBJPROP_STYLE,Fibo2Style);
            ObjectSet(fibo,OBJPROP_WIDTH,Fibo2Width);
            ObjectSet(fibo,OBJPROP_LEVELCOLOR,Fibo2Color);
               ObjectSet(fibo,OBJPROP_FIBOLEVELS,ArraySize(levelv));
               for (i=ArraySize(levelv)-1;i>=0;i--)
                  {
                     ObjectSet(fibo,OBJPROP_FIRSTLEVEL+i,levelv[i]/100);
                     ObjectSetFiboDescription(fibo,i,levels[i]);
                  }                     
          }
          ObjectSet(fibo,OBJPROP_TIME1,Time[PPreviousZigZag]);
          ObjectSet(fibo,OBJPROP_TIME2,Time[PreviousZigZag]);
          ObjectSet(fibo,OBJPROP_PRICE1,ExtMapBuffer[PreviousZigZag]);
          ObjectSet(fibo,OBJPROP_PRICE2,ExtMapBuffer[PPreviousZigZag]);
      }
      
      //
      //
      //
      //
      //
      
                 
      if (ShowThirdFibo)          
      {
         fibo = "Fibo1";           
         if( ObjectFind(fibo)==-1 )
         {
            ObjectCreate(fibo, OBJ_FIBO, 0,Time[PPPreviousZigZag], ExtMapBuffer[PPreviousZigZag], Time[PPreviousZigZag], ExtMapBuffer[PPPreviousZigZag]);
            ObjectSet(fibo,OBJPROP_COLOR,Fibo3Color);
            ObjectSet(fibo,OBJPROP_STYLE,Fibo3Style);
            ObjectSet(fibo,OBJPROP_WIDTH,Fibo3Width);
            ObjectSet(fibo,OBJPROP_LEVELCOLOR,Fibo3Color);
               ObjectSet(fibo,OBJPROP_FIBOLEVELS,ArraySize(levelv));
               for (i=ArraySize(levelv)-1;i>=0;i--)
                  {
                     ObjectSet(fibo,OBJPROP_FIRSTLEVEL+i,levelv[i]/100);
                     ObjectSetFiboDescription(fibo,i,levels[i]);
                  }                     
          }
          ObjectSet(fibo,OBJPROP_TIME1,Time[PPPreviousZigZag]);
          ObjectSet(fibo,OBJPROP_TIME2,Time[PPreviousZigZag]);
          ObjectSet(fibo,OBJPROP_PRICE1,ExtMapBuffer[PPreviousZigZag]);
          ObjectSet(fibo,OBJPROP_PRICE2,ExtMapBuffer[PPPreviousZigZag]);
      }                   

   //
   //
   //
   //
   //
   
   if (alertsShowTouched) ShowCandles();
   if (alertsOn)          CheckTouches();
   return(0);
}   


//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

void CalculateZigZag()
{
   int    shift, back,lasthighpos,lastlowpos,index;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
//----
   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      index=iLowest(NULL,0,MODE_LOW,ExtDepth,shift);
      val=Low[index];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtLowBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtLowBuffer[shift+back]=0.0; 
              }
           }
        } 
      ExtLowBuffer[shift]=0.0;
      if(val!=0.0) ExtLowBuffer[index]=val;
      //--- high
      index=iHighest(NULL,0,MODE_HIGH,ExtDepth,shift);
      val=High[index];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtHighBuffer[shift+back];
               if((res!=0)&&(res<val)) ExtHighBuffer[shift+back]=0.0; 
              } 
           }
        }
      ExtHighBuffer[shift]=0.0;
      if(val!=0.0) ExtHighBuffer[index]=val;
     }
//---- final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ExtLowBuffer[shift];
      curhigh=ExtHighBuffer[shift];
      if(curlow==0 && curhigh==0) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtHighBuffer[lasthighpos]=0;
            else ExtHighBuffer[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ExtLowBuffer[lastlowpos]=0;
            else ExtLowBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
//---- merge 2 buffers
   lasthighpos=-1;
   lastlowpos=-1;
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         curlow=ExtLowBuffer[shift];
         curhigh=ExtHighBuffer[shift];
         //----
         res=0;
         if(curlow!=0)
           {
            if(lastlowpos==-1)
              {
               res=curlow;
               lastlowpos=shift;
              }
            else
              {
               if(lasthighpos!=-1 && lastlowpos>lasthighpos)
                 {
                  res=curlow;
                  lastlowpos=shift;
                 }
              }
           }
         if(curhigh!=0)
           {
            if(lasthighpos==-1)
              {
               res=curhigh;
               lasthighpos=shift;
              }
            else
              {
               if(lastlowpos!=-1 && lasthighpos>lastlowpos)
                 {
                  res=curhigh;
                  lasthighpos=shift;
                 }
              }
           }
         //----
         ExtMapBuffer[shift]=res;
        }
     }
}

//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

void fillValues(string forFibo)
{
   int fibLines = ObjectGet(forFibo,OBJPROP_FIBOLEVELS);
   int i;
   
   double price1 = ObjectGet(forFibo,OBJPROP_PRICE1);
   double price2 = ObjectGet(forFibo,OBJPROP_PRICE2);
   for (i=0;i<fibLines;i++)
      {
         if (price1 > price2)  values[i] = NormalizeDouble(price2 + (levelv[i]/100*(price1-price2)),Digits);
         if (price1 < price2)  values[i] = NormalizeDouble(price1 + (levelv[i]/100*(price2-price1)),Digits);
      }
}

//
//
//
//
//

void CheckTouches()
{
   if (ShowSecondFibo)          
   {
      fillValues("Fibo2");
      for (int i = 0;i<ArraySize(levelv);i++) CheckIfTouched(i,values[i]);
   } 
   if (ShowThirdFibo)          
   {
      fillValues("Fibo1");
      for (i = 0;i<ArraySize(levelv);i++)     CheckIfTouched(i,values[i]);
   }             
      fillValues("Fibo3");
      for (i = 0;i<ArraySize(levelv);i++)     CheckIfTouched(i,values[i]);
}

//
//
//
//
//

int CheckIfTouched(int index, double compareTo,bool checking=false,int forBar=0)
{
   int    answer = 0;
   double diff   = NormalizeDouble(alertsTolerance*Point,Digits);
   double correction;
   double highDiff;
   double lowDiff;
   
   if (touchChanell)
      {
         correction = NormalizeDouble(alertsTolerance*Point,  Digits);
         diff       = NormalizeDouble(alertsTolerance*Point*2,Digits);
      }         
   else  correction = 0.00;    
   //
   //
   //
   //
   //
      
   int add;
      if (alertsOnCurrent) add = 0;
      else                 add = 1;      
      double value = NormalizeDouble(compareTo,Digits);
          highDiff = NormalizeDouble((value+correction)-High[add+forBar],Digits);
          lowDiff  = NormalizeDouble(Low[add+forBar]-(value-correction),Digits);
          
   //
   //
   //
   //
   //
   
   if (checking)
      {
         if ((highDiff >= 0) && (highDiff <= diff)) answer = -1;
         if ((lowDiff  >= 0) && (lowDiff  <= diff)) answer =  1;
      }
   else
      {
         if ((highDiff >= 0) && (highDiff <= diff)) doAlert("fibo level "+DoubleToStr(levelv[index],1)+" line touched from down");
         if ((lowDiff  >= 0) && (lowDiff  <= diff)) doAlert("fibo level "+DoubleToStr(levelv[index],1)+" line touched from up");
      }
   return(answer);
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

       message =  StringConcatenate(Symbol()," - ",TimeFrameToString(Period())," chart, at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(StringConcatenate(Symbol(), Period() ," pivot line touch " +" "+message));
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," pivot line touch"),message);
          if (alertsSound)   PlaySound(soundFile);
   }
}


//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

void deleteCandles()
{
   while(totalCandles>0) { ObjectDelete(StringConcatenate(windowID,"c-",totalCandles)); totalCandles -= 1; }
}

//
//
//
//
//

void ShowCandles()
{
   datetime time1;
   datetime time2;
   
   deleteCandles();
   
   //
   //
   //
   //
   //
   
   if (ShowSecondFibo)          
   {
      fillValues("Fibo2");
      time1 = MathMin(ObjectGet("Fibo2",OBJPROP_TIME1),ObjectGet("Fibo2",OBJPROP_TIME2));
      time2 = MathMax(ObjectGet("Fibo2",OBJPROP_TIME1),ObjectGet("Fibo2",OBJPROP_TIME2));
      for (int i = 0;i<barsToShowCandles;i++)
      {
         if ((Time[i] >= time1) && (Time[i] <= time2))
            {
               for (int k = 0;k<ArraySize(levelv);k++) if (CheckSingle(k,values[k],i)) continue;
            }                    
      }
   } 
   if (ShowThirdFibo)          
   {
      fillValues("Fibo1");
      time1 = MathMin(ObjectGet("Fibo1",OBJPROP_TIME1),ObjectGet("Fibo1",OBJPROP_TIME2));
      time2 = MathMax(ObjectGet("Fibo1",OBJPROP_TIME1),ObjectGet("Fibo1",OBJPROP_TIME2));
      for (i = 0;i<barsToShowCandles;i++)
      {
         if ((Time[i] >= time1) && (Time[i] <= time2))
            {
               for (k = 0;k<ArraySize(levelv);k++) if (CheckSingle(k,values[k],i)) continue;
            }                    
      }
   }                
   
   //
   //
   //
   //
   //
   
   fillValues("Fibo3");
   time1 = MathMin(ObjectGet("Fibo3",OBJPROP_TIME1),ObjectGet("Fibo3",OBJPROP_TIME2));
   time2 = MathMax(ObjectGet("Fibo3",OBJPROP_TIME1),ObjectGet("Fibo3",OBJPROP_TIME2));
   
   //
   //
   //
   //
   //
   
      for (i = 0;i<barsToShowCandles;i++)
      {
         if ((Time[i] >= time1) && (Time[i] <= time2))
            {
               for (k = 0;k<ArraySize(levelv);k++) if (CheckSingle(k,values[k],i)) continue;
            }                    
      }
}

//
//
//
//
//

bool CheckSingle(int index,double array,int shift)
{
   int result = CheckIfTouched(index,array,true,shift);
   if (result != 0)
      {
         if (alertsOnCurrent) DrawCandle(shift  ,result);
         else                 DrawCandle(shift+1,result);
         return(true);
      }
   else
      {
         return(false);
      }         
}

//
//
//
//
//

void DrawCandle(int shift,int upDown)
{
   datetime time  = Time[shift];
   double   high  = iHigh (NULL,0,shift);
   double   low   = iLow  (NULL,0,shift);
   double   open  = iOpen (NULL,0,shift);
   double   close = iClose(NULL,0,shift);
   string name;


   
   totalCandles += 1;
   name    = windowID+"c-"+totalCandles;
      ObjectCreate(name,OBJ_TREND,0,time,high,time,low);
         ObjectSet(name,OBJPROP_COLOR,WickColor);
         ObjectSet(name,OBJPROP_RAY  ,false);
      
   //
   //
   //
   //
   //
         
   totalCandles += 1;
   name    = windowID+"c-"+totalCandles;
      ObjectCreate(name,OBJ_TREND,0,time,open,time,close);
         ObjectSet(name,OBJPROP_WIDTH,CandleWidth);
         ObjectSet(name,OBJPROP_RAY  ,false);
         if (upDown>0)
               ObjectSet(name,OBJPROP_COLOR,BarUpColor);
         else  ObjectSet(name,OBJPROP_COLOR,BarDownColor);
}


//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

string TimeFrameToString(int tf)
{
   string tfs="Current time frame";
   switch(tf) {
      case PERIOD_M1:  tfs="M1"  ; break;
      case PERIOD_M5:  tfs="M5"  ; break;
      case PERIOD_M15: tfs="M15" ; break;
      case PERIOD_M30: tfs="M30" ; break;
      case PERIOD_H1:  tfs="H1"  ; break;
      case PERIOD_H4:  tfs="H4"  ; break;
      case PERIOD_D1:  tfs="D1"  ; break;
      case PERIOD_W1:  tfs="W1"  ; break;
      case PERIOD_MN1: tfs="MN1";
   }
   return(tfs);
}