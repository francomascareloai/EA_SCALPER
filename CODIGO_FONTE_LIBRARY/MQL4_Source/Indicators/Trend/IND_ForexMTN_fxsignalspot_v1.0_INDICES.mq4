
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum -35.0
#property indicator_maximum 35.0
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_level2 12.0
#property indicator_level3 -12.0

double AboveBuff[];
double ShortBuff[];
double LongBuffe[];
double BelowBuff[];

// ---
int init() {
   SetIndexBuffer(0, AboveBuff); SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2);                          // Lime Above 0
   SetIndexBuffer(1, BelowBuff); SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 2);                          // Lime Below 0
   SetIndexBuffer(2, ShortBuff); SetIndexStyle(2, DRAW_ARROW, EMPTY, 2);       SetIndexArrow(2, 108); // Red
   SetIndexBuffer(3, LongBuffe); SetIndexStyle(3, DRAW_ARROW, EMPTY, 2);       SetIndexArrow(3, 108); // Blue
   

   SetIndexLabel(0, "Above");
   SetIndexLabel(1, "Below");   
   SetIndexLabel(2, NULL);  
   SetIndexLabel(3, NULL);  
   
   SetLevelStyle(STYLE_DOT, 0, SteelBlue);

   IndicatorShortName("Forex MTN");
   return (0);
}
	 	    			  		  		   		 	 	 	 	 		 						 	   				  	   	 		 			  			  	     		  	 			   	 	     			 	 		 		     			 	 	  		 	  		   			 			    	
// ---
void deinit() {
   Comment("");
}
		    			 	 			 	 	  	  		  	   	 				 			     		 	 	 	 		 	 	 	 	 		 		 		  	    					   		  	    	 					 	  	    	 			 	 	 		 	 	  	 	   	  	 	
// ---
void start() {
   double Temp;
   double Main;
   double Minr;
   int Limit;
   int CntBr = IndicatorCounted();
   if (CntBr >= 0) {
      if (CntBr > 0) CntBr--;
      Limit = Bars - CntBr;
      for (int i = 0; i < Bars; i++) {
         Temp = 0.0;
         for (int j = i; j < i + 5; j++) Temp += (High[j] + Low[j]) / 2.0;
         Main = Temp / 5.0;
         Temp = 0.0;
         for (j = i; j < i + 5; j++) Temp += High[j] - Low[j];
         Minr = 0.2 * (Temp / 5.0);
         AboveBuff[i] = 3.0 * (High[i]  - Main) / Minr;
         BelowBuff[i] = 3.0 * (Low[i]   - Main) / Minr;
      }
      for (i = 0; i < Limit; i++) {
         if (AboveBuff[i] >  24.0) ShortBuff[i] =  25;
         if (BelowBuff[i] < -24.0) LongBuffe[i] = -25;
      }
   }
}