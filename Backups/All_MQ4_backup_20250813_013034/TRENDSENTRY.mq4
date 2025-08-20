//=============================================================================================
//Decompiled by lptuyen at www.forexisbiz.com (FIB Forum)
//Profile: http://www.forexisbiz.com/member.php/11057-lptuyen?tab=aboutme#aboutme
//Email: Lptuyen_fx@yahoo.com
//Another forum: lptuyen at WWI
//Profile: http://worldwide-invest.org/members/48543-lptuyen?tab=aboutme#aboutme
//=============================================================================================

#property copyright "Forex Secret Protocol"
#property link      "http://www.forexsecretprotocol.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 Blue
#property indicator_color3 Red

extern bool ShowText = TRUE;
int Gi_80 = 14;
extern int TextHorOffset = 50;
double G_ibuf_88[];
double G_ibuf_92[];
double G_ibuf_96[];
string Gs_100 = "";
string G_name_108 = "TRENDSENTRY";
int G_datetime_116 = 0;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0, G_ibuf_88);
   SetIndexBuffer(1, G_ibuf_92);
   SetIndexBuffer(2, G_ibuf_96);
   IndicatorShortName(G_name_108);
   SetIndexLabel(1, "UP");
   SetIndexLabel(2, "DOWN");
   return (0);
}
	  		 	  			 			 					 	   	   	 		  	     		    			  		    		  	     	 	 				 				  						 	 				  			     	 				  			 	   				 					  		  	 		 
// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}
	     		 		 			  		  	      	    					 	       	 		 	 	    	 	 		  		 			 	  	  							 				  	 		 	 			   	  	 		 	 				  	 		  		  	 			 	  	  
// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double Ld_0;
   int Li_8 = IndicatorCounted();
   double Ld_12 = 0;
   double Ld_20 = 0;
   double Ld_28 = 0;
   double low_36 = 0;
   double high_44 = 0;
   if (ShowText) f0_0();
   int Li_52 = 16777215;
   if (Li_8 > 0) Li_8--;
   int Li_56 = Bars - Li_8;
   if (Li_56 < 35) Li_56 = 35;
   if (f0_1() && Li_56 < 40) Li_56 = 300;
   for (int Li_60 = 0; Li_60 < Li_56; Li_60++) {
      high_44 = High[iHighest(NULL, 0, MODE_HIGH, Gi_80, Li_60)];
      low_36 = Low[iLowest(NULL, 0, MODE_LOW, Gi_80, Li_60)];
      Ld_0 = (High[Li_60] + Low[Li_60] + Close[Li_60]) / 3.0;
      Ld_12 = 0.66 * ((Ld_0 - low_36) / (high_44 - low_36) - 0.5) + 0.67 * Ld_20;
      Ld_12 = MathMin(MathMax(Ld_12, -0.999), 0.999);
      G_ibuf_88[Li_60] = MathLog((Ld_12 + 1.0) / (1 - Ld_12)) / 2.0 + Ld_28 / 2.0;
      Ld_20 = Ld_12;
      Ld_28 = G_ibuf_88[Li_60];
   }
   bool Li_64 = TRUE;
   for (Li_60 = Li_56; Li_60 >= 0; Li_60--) {
      G_ibuf_92[Li_60] = EMPTY_VALUE;
      G_ibuf_96[Li_60] = EMPTY_VALUE;
      if (G_ibuf_88[Li_60] < 0.0) Li_64 = FALSE;
      else Li_64 = TRUE;
      if (!Li_64) {
         G_ibuf_96[Li_60] = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_HIGH, Li_60);
         G_ibuf_92[Li_60] = 0.0;
         Gs_100 = "SHORT";
         Li_52 = 255;
      } else {
         if (Li_64) {
            G_ibuf_92[Li_60] = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_LOW, Li_60);
            G_ibuf_96[Li_60] = 0.0;
            Gs_100 = "LONG";
            Li_52 = 65280;
         }
      }
   }
   if (ShowText) f0_2(G_name_108, Gs_100, 20, Li_52, TextHorOffset + 100, 50);
   return (0);
}
	  	 	 	 				    			  	    				  		 	 		   	 			 					        			   		 		 		  	 			 	   			  	  		     	     	  		     		        			  				   	   
// 19F6B3E57E7C3D034D6318C3C69149B4
void f0_0() {
   if (ObjectFind(G_name_108) == -1) ObjectCreate(G_name_108, OBJ_LABEL, 0, 0, 0);
   f0_2(G_name_108, "", 20, White, TextHorOffset + 100, 50);
}
	   	  	 		  	   		 			       	  			 			    	 		 		        						  	   		 	 			 				 	  					   		 			 	   		   		 			 		  			   		 						 		    
// F412C23B721CFEB0738FBC3525A5D9AC
void f0_2(string A_name_0, string A_text_8, int A_fontsize_16, color A_color_20, int A_x_24, int A_y_28) {
   ObjectSet(A_name_0, OBJPROP_CORNER, 1);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_24);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_28);
   ObjectSetText(A_name_0, A_text_8, A_fontsize_16, "Arial Bold", A_color_20);
}
		 	 	 	  			     		  	  	 				   	 	 		 	 	 			  				   	    				  		 					  	 	 	 	   	 	  	  	      	 	   	  	      			        		  			    	   
// 88F3AD7A7E7B65F5E0D00334A43C38C7
int f0_1() {
   int datetime_0 = iTime(Symbol(), PERIOD_M1, 0);
   if (G_datetime_116 == 0) G_datetime_116 = datetime_0;
   if (G_datetime_116 != datetime_0) {
      G_datetime_116 = datetime_0;
      return (1);
   }
   return (0);
}