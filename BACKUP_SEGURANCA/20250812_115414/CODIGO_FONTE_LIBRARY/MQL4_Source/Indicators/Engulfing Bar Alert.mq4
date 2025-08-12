//+------------------------------------------------------------------+
//|                                          Engulfing Bar Alert.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Aqua
#property indicator_color2 Violet


//---- buffers
double Up[],Dn[];

//+------------------------------------------------------------------+

int init()
  {
   SetIndexBuffer(0,Up);
   SetIndexBuffer(1,Dn);
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);
   
   
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+

int start() {
   int i, counter;
   double Range, AvgRange;
   int CountBars=Bars;


   for(i=0; i<CountBars; i++)
   
   
   {
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+2;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
      
        
	     //  UP
	     if (Close[i+1]>Open[i+1]&&Close[i+2]<Open[i+2]&&Close[i+1]>Open[i+2]&&Open[i+1]<=Close[i+2])
           {
          	Up[i+1]=Low[i+1]-Range*1.5;
           }
		                                                         
           
        // DOWN
        if (Close[i+1]<Open[i+1]&&Close[i+2]>Open[i+2]&&Close[i+1]<Open[i+2]&&Open[i+1]>=Close[i+2])
           {                               
		      Dn[i+1]=High[i+1]+Range*1.5;
		     } 		          
           
   }
   return(0);
}


