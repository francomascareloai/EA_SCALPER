//+------------------------------------------------------------------+
//|                                          LastHighLowStopLoss.mq4 |
//|                                    zigzag modified by John Burch |
//|                                    joho2004@forex-tools-cafe.com |
//|                                  http://www.forex-tools-cafe.com |
//+------------------------------------------------------------------+
//
// The core of this code is the zigzag indicator with a few modifications to turn 
// it into a stoploss calculator to put the SL behind the last high or low 
// 
//+------------------------------------------------------------------+
//|                                                       ZigZag.mq4 |
//|                                    zigzag modified by Dr. Gaines |
//|                                      dr_richard_gaines@yahoo.com |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_width1 1
#property indicator_color2 Red
#property indicator_width2 1
//---- indicator parameters
extern int ExtDepth=4;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
extern int MinimumStopLoss=15; 
extern int BackLookBars=24; 

extern int NumericalOffset=6;

double ExtMapBuffer[];
double ExtMapBuffer2[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(2);

   SetIndexStyle(0,DRAW_NONE);
   SetIndexArrow(0, 233);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexArrow(1, 234);

   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(0,0.0);

   IndicatorShortName("ZigZag("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");

   return(0);
}

int deinit()
{
   ObjectDelete("LastHighRay");
   ObjectDelete("LastLowRay");
   ObjectDelete("LastHighLabel");
   ObjectDelete("LastLowLabel");
   
   return(0);
}

int start()
  {
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   int  limit=Bars-ExtDepth; 
   if ( limit > BackLookBars ) limit = BackLookBars; 
   
   for(shift=limit; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
              }
           }
        } 
      ExtMapBuffer[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0; 
              } 
           }
        }
      ExtMapBuffer2[shift]=val;
     }

   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=limit; shift>=0; shift--)
     {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
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
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
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
  
   for(shift=limit; shift>=0; shift--)
   {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         res=ExtMapBuffer2[shift];
         if(res!=0.0) ExtMapBuffer2[shift]=res;
        }
   }
   
   int spread = MarketInfo(Symbol(), MODE_SPREAD ) ;
   
   int    lasth=0, lastl = 0;
   
   double LastHigh, LastLow; 
   int i, H, L; 
   int lowpips, highpips;
   
   for(i=0,H=0, L=0; i<=limit; i++)
   { 
      if ( H==0 && ExtMapBuffer2[i] > 0.1 )
      {
         LastHigh = High[i] + spread*Point ;
         H++; 
         lasth=i; 
      }
      if ( L==0 &&  ExtMapBuffer[i] > 0.1  )
      {
         LastLow = Low[i] - spread*Point ; 
         L++ ;
         lastl = i; 
      }
      if ( H != 0 && L != 0 )
         break; 
   }
   
   double minTop = Close[0] + (MinimumStopLoss+spread)*Point ; // Bid
   double maxBot = (Close[0]+spread*Point) - MinimumStopLoss*Point; // Ask
   
   if (  minTop > LastHigh ) LastHigh = minTop; 
     
   if ( maxBot  < LastLow )  LastLow = maxBot; 
   
   highpips=( LastHigh - Close[0] )/Point ;
   lowpips= (Close[0]+spread*Point - LastLow)/Point ;
   

//  Comment("i: " + i + "\nLast High SL: " + LastHigh + "\nLast Low SL: " + LastLow ); 
   
   
   if ( ObjectFind("LastHighRay")>= 0)
   {
      ObjectMove("LastHighRay", 0, Time[lasth]-3*60*Period(), LastHigh);
      ObjectMove("LastHighRay", 1, Time[lasth]+3*60*Period(), LastHigh);
      
      ObjectMove("LastHighLabel",0, Time[lasth] + (NumericalOffset*60*Period()) , LastHigh  );
      ObjectSetText("LastHighLabel", DoubleToStr(LastHigh,Digits)+" ("+highpips+")", 12, "Ariel", Red );
   }
   else
   {
      ObjectCreate("LastHighRay", OBJ_TREND, 0, Time[lasth]-3*60*Period(), LastHigh, Time[lasth]+3*60*Period(), LastHigh);
      ObjectSet("LastHighRay", OBJPROP_COLOR, Red );
      ObjectSet("LastHighRay", OBJPROP_STYLE, STYLE_DASH );
      ObjectSet("LastHighRay", OBJPROP_WIDTH, 1 );
      ObjectSet("LastHighRay", OBJPROP_RAY, true ); 
      
      ObjectCreate("LastHighLabel", OBJ_TEXT, 0, Time[lasth]+ (NumericalOffset*60*Period()) , LastHigh ); 
      ObjectSetText(  "LastHighLabel", DoubleToStr(LastHigh,Digits)+" ("+highpips+")", 12, "Ariel", Red );
   }
   
    /************************************************/
    
   if ( ObjectFind("LastLowRay")>= 0)
   {
      ObjectMove("LastLowRay", 0, Time[lastl]-3*60*Period(), LastLow);
      ObjectMove("LastLowRay", 1, Time[lastl]+3*60*Period(), LastLow);
      
      ObjectMove("LastLowLabel",0, Time[lasth]+ (NumericalOffset*60*Period()), LastLow   );
      ObjectSetText(  "LastLowLabel", DoubleToStr(LastLow,Digits)+" ("+lowpips+")", 12, "Ariel", Blue );
      
   }
   else
   {
      ObjectCreate("LastLowRay", OBJ_TREND, 0, Time[lastl]-3*60*Period(), LastLow, Time[lastl]+3*60*Period(), LastLow);
      ObjectSet("LastLowRay", OBJPROP_COLOR, Blue );
      ObjectSet("LastLowRay", OBJPROP_STYLE, STYLE_DASH );
      ObjectSet("LastLowRay", OBJPROP_WIDTH, 1 );
      ObjectSet("LastLowRay", OBJPROP_RAY, true ); 
      
      ObjectCreate("LastLowLabel", OBJ_TEXT, 0, Time[lastl]+ (NumericalOffset*60*Period()) , LastLow  ); 
      ObjectSetText(  "LastLowLabel", DoubleToStr(LastLow,Digits)+" ("+lowpips+")", 12, "Ariel", Blue );
      
   }
   
   
   
}
  
 