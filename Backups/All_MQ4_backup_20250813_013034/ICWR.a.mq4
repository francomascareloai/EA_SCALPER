//+------------------------------------------------------------------+
//|                                                   ICWR indicator |
//|                                   Copyright © 2005, John Lotoski |
//|                                       mailto:john@fayandjohn.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, john@fayandjohn.com"
#property link      "mailto:john@fayandjohn.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Black


//---- indicator parameters
extern int ExtDepth=10;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
extern int RequiredWaveHeight=40;

//---- indicator buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(2);

//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
   
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexEmptyValue(0,0.0);
   ArraySetAsSeries(ExtMapBuffer,true);
   ArraySetAsSeries(ExtMapBuffer2,true);
   
//---- indicator short name
   IndicatorShortName("ICWR("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");

//---- initialization done
   return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+

int deinit()                           // Removes all lines and text
{                                      // from the chart upon removal
                                       // of the indicator
   ObjectDelete("ActiveWave");
   ObjectDelete("Fibo");
   return(0);
}

//+------------------------------------------------------------------+
//| Main function                                                    |
//+------------------------------------------------------------------+
int start()
{
   if(Period()==5) {RequiredWaveHeight=40;}
   if(Period()==240) {RequiredWaveHeight=150;}
   int    shift,back,lasthighpos,lastlowpos,LastActivePos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow,LastActive;
   
   int AWStartPos, AWEndPos;
   double AWStart, AWEnd;
   
   double FiboL, FiboH, FiboLC, FiboLR, FiboHR, FiboHC;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
   {
                                       // The beginning code of this for loop is dedicated
                                       // to finding a low endpoint of a zig-zag
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
                                       // Start at beginning of data
                                       // - Get low of last depth (12) periods
                                       // - Repeat low search of 12 periods,
                                       //   advancing 1 bar every search (for loop)
      
      if(val==lastlow)                 // If this is not a new low
         val=0.0;                      // - Reset the val marker to dbl 0
      
      else                             // Otherwise, if it is a new low
      { 
         lastlow=val;                  // - Record this new low in lastlow for future reference
         if((Low[shift]-val)>(ExtDeviation*Point)) 
            val=0.0;                   // If the low of the current bar is 6 or
                                       // more pips greater than the lowest low of the last
                                       // depth (12) periods, then reset val to dbl 0.
                                       // Ie: continue the zig because the line is going up
         
         else                          // Otherwise, if the current low is within 6 pips
         {                             // of the lowest low of the last 12 bars
            for(back=1; back<=ExtBackstep; back++)
            {                          // Check back 3 bars, and if each value over those
                                       // three bars is greater than the current lowest low,
                                       // then reset the map buffer value to 0 because
                                       // we have a new lower low.
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) 
                  ExtMapBuffer[shift+back]=0.0; 
            }
         }
      } 

      ExtMapBuffer[shift]=val;         // Set our current bar to 0 (continuation of zig) if:
                                       //    - A new low has not been reached;
                                       //    - The current bar is 6 pips beyond the lowest low
                                       // Set our current bar to the lowest low if:
                                       //    - It is within 6 pips of the lowest low and
                                       //      and go back over the last three bars and set them
                                       //      to continuation of zig as well if they are greater
                                       //      than the new lowest value
      
      
                                       // Same deal for below, except the case is reversed
                                       // and everything is done in terms of trying to find
                                       // the high zig-zag endpoint
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];

      if(val==lasthigh) 
         val=0.0;
      else 
      {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) 
            val=0.0;
         else
         {
            for(back=1; back<=ExtBackstep; back++)
            {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) 
                  ExtMapBuffer2[shift+back]=0.0; 
            } 
         }
      }
      ExtMapBuffer2[shift]=val;
   }

   // final cutting 
   lasthigh=-1; 
   lasthighpos=-1;
   lastlow=-1;  
   lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
   {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      
      if((curlow==0)&&(curhigh==0))    // Break into the next cycle of the loop
         continue;                     // to try and find the next zig-zap endpoint
      
      if(curhigh!=0)                   // If there is a current high, then:
      {
         if(lasthigh>0)                   // If there was a previous high already:
         {
            if(lasthigh<curhigh)          //    - Set the last high to 0 if it is less than the current high
               ExtMapBuffer2[lasthighpos]=0;
            else                          //    - Set the current bar to 0 if it is less than the last high
               ExtMapBuffer2[shift]=0;
         }
         
         if(lasthigh<curhigh || lasthigh<0)
         {                             // If there was no last high or the last high was less than the current high
            lasthigh=curhigh;          //    - Set the current high to be the last high (keep record of it)
            lasthighpos=shift;         //    - Set the current bar to the lasthighpos (keep record of it)
         }
         lastlow=-1;                   // Since we just had a new high, reset the lastlow flag
      }

      if(curlow!=0)                    // If there is a low, then do the same as above, except for the case of lows instead of highs
      {
         if(lastlow>0)
         {
            if(lastlow>curlow) 
               ExtMapBuffer[lastlowpos]=0;
            else 
               ExtMapBuffer[shift]=0;
         }

         if((curlow<lastlow)||(lastlow<0))
         {
            lastlow=curlow;
            lastlowpos=shift;
         } 
         lasthigh=-1;
      }
   }
  
   for(shift=Bars-1; shift>=0; shift--)
   {                                   // Go through all the bars
      if(shift>=Bars-ExtDepth)         // If we are not at the beginning comparison bars,
         ExtMapBuffer[shift]=0.0;      //    then set the low buffer to 0
      else
      {                                // Otherwise:
         res=ExtMapBuffer2[shift];     //    - If the current bar has a high, set the low
         if(res!=0.0)                  //      buffer to contain the high
            ExtMapBuffer[shift]=res;
      }                                // Looks like this function brings the highs into the lows
   }                                   // so that all the zig-zags can be drawn from one function

   LastActive = -1;
   LastActivePos = -1;
      
   for(shift=0; shift<=Bars-ExtDepth; shift++)
   {
      if(ExtMapBuffer[shift]!=0.0)
      {
         if(LastActive > 0)
         {
            if(MathAbs(LastActive - ExtMapBuffer[shift]) >= RequiredWaveHeight*Point)
            {
               AWStartPos = shift;
               AWStart = ExtMapBuffer[shift];
               AWEndPos = LastActivePos;
               AWEnd = LastActive;

               if(ObjectFind("ActiveWave") != 0)
               {
                  ObjectCreate("ActiveWave", OBJ_TREND, 0, Time[AWStartPos], AWStart, Time[AWEndPos], AWEnd);
                  ObjectSet("ActiveWave", OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet("ActiveWave", OBJPROP_COLOR, Red);               
                  ObjectSet("ActiveWave", OBJPROP_WIDTH, 3);
                  ObjectSet("ActiveWave", OBJPROP_RAY, false);  
               }
               else
               {
                  ObjectMove("ActiveWave", 0, Time[AWStartPos], AWStart);
                  ObjectMove("ActiveWave", 1, Time[AWEndPos], AWEnd);
               }
            
               if(AWStart < AWEnd)
               {
                  FiboL = AWStart;
                  FiboH = AWEnd;
               }
               else
               {
                  FiboL = AWEnd;
                  FiboH = AWStart;
               }
               
               FiboLC = FiboL + (FiboH - FiboL)*0.25;
               FiboLR = FiboL + (FiboH - FiboL)*0.382;
               FiboHR = FiboL + (FiboH - FiboL)*0.618;
               FiboHC = FiboL + (FiboH - FiboL)*0.75;
            
            
               if(ObjectFind("Fibo") != 0)
               {
                  ObjectCreate("Fibo", OBJ_FIBO, 0, Time[AWStartPos], AWStart, Time[AWEndPos], AWEnd);
                  ObjectSet("Fibo", OBJPROP_STYLE, STYLE_SOLID);
                  ObjectSet("Fibo", OBJPROP_COLOR, Green);               
                  ObjectSet("Fibo", OBJPROP_WIDTH, 2);
                  ObjectSet("Fibo", OBJPROP_FIBOLEVELS, 6);
/*                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+0, FiboL);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+1, FiboLC);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+2, FiboLR);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+3, FiboHR);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+4, FiboHC);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+6, FiboH); */
                  
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+0, 0);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+1, 0.25);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+2, 0.382);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+3, 0.618);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+4, 0.75);
                  ObjectSet("Fibo", OBJPROP_FIRSTLEVEL+5, 1);
               }
               else
               {
                  ObjectMove("Fibo", 0, Time[AWStartPos], AWStart);
                  ObjectMove("Fibo", 1, Time[AWEndPos], AWEnd);
               }
               break;
            }
         }
         LastActive = ExtMapBuffer[shift];
         LastActivePos = shift;
      }
   }
/*double rsi=iRSI(Symbol(),1440,14,PRICE_CLOSE,0);
Comment("Daily RSI= ",rsi);*/
}