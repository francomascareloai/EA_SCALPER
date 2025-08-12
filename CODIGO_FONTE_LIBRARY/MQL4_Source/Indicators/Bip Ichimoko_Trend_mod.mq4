//+------------------------------------------------------------------+
//|                                                    unkown        |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//Modified, 27/07/2022, by jeanlouie, www.forexfactory.com/jeanlouie
// - max timeseries index to bars-1, from 10,000

#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red

double CrossUp[];
double CrossDown[];
int shift;

int init()
  {
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
   return(0);
  }


int deinit()
  {
   return(0);
  }
  
//+++-----------------------------------------------------------+++-----------------------------------------------------------                     
//+++-----------------------------------------------------------+++-----------------------------------------------------------
int start()   
   {
   double Range, AvgRange;

   
   //CrossUp[CountBars] = Low[CountBars];
   int ilimit = Bars-1;
   //for(shift=1; shift<=10000; shift++) 
   for(shift=1; shift<=ilimit; shift++) 
      { 
      Range=0;
      AvgRange=0;
      AvgRange=AvgRange+MathAbs(High[shift]-Low[shift]);
      Range=AvgRange/10;
      
      if(iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift)>iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift))
         {
         if(iClose(NULL,0,shift)>iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift) && iIchimoku(NULL,0,9,26,52,MODE_CHIKOUSPAN,26+shift)>iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,26+shift) && iIchimoku(NULL,0,9,26,52,MODE_CHIKOUSPAN,26+shift)>iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,26+shift)
            && iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift-26)>=iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift-26))
            CrossUp[shift] = Low[shift]- Range;
         }
         
      if(iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift)>iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift))
         {
         if(iClose(NULL,0,shift)>iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift) && iIchimoku(NULL,0,9,26,52,MODE_CHIKOUSPAN,26+shift)>iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,26+shift) && iIchimoku(NULL,0,9,26,52,MODE_CHIKOUSPAN,26+shift)>iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,26+shift)
            && iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift-26)>=iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift-26))
            CrossUp[shift] = Low[shift]- Range;
         }
      
      }    
      
   //for(shift=1; shift<=10000; shift++) 
   for(shift=1; shift<=ilimit; shift++) 
      { 
      Range=0;
      AvgRange=0;
      AvgRange=AvgRange+MathAbs(High[shift]-Low[shift]);
      Range=AvgRange/10;
      
      if(iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift)<iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift))
         {
         if(iClose(NULL,0,shift)<iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift) && iIchimoku(NULL,0,9,26,52,MODE_CHIKOUSPAN,26+shift)<iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,26+shift) && iIchimoku(NULL,0,9,26,52,MODE_CHIKOUSPAN,26+shift)<iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,26+shift)
            && iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift-26)<=iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift-26))
            CrossDown[shift] = High[shift]+Range;
         }
         
      if(iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift)<iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift))
         {
         if(iClose(NULL,0,shift)<iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift) && iIchimoku(NULL,0,9,26,52,MODE_CHIKOUSPAN,26+shift)<iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,26+shift) && iIchimoku(NULL,0,9,26,52,MODE_CHIKOUSPAN,26+shift)<iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,26+shift)
            && iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANA,shift-26)<=iIchimoku(NULL,0,9,26,52,MODE_SENKOUSPANB,shift-26))           
            CrossDown[shift] = High[shift]+Range;
         }
      
      }    
         
   
   //Comment(iIchimoku(NULL,0,9,26,52,MODE_CHIKOUSPAN,26));
   return(0);
   }

