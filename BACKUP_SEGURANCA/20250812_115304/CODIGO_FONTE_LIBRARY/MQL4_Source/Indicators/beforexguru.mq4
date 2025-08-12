/*
   G e n e r a t e d  by ex4-to-mq4 decompiler 4.0.500.6
   E-mail : P u R eBEaM @ G mAIL.coM
*/
#property copyright "Copyright © 2013, FSD Team"
#property link      "http://www.beforexguru.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Black
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 Red

int Gi_76 = 10;
extern double Sensitivity = 38.0;
extern bool PopUp_Alert = TRUE;
extern bool Email_Alert = FALSE;
extern string HomePage = "www.BeForexGuru.com";
int Gi_104 = 3;
int Gi_108 = 0;
int Gi_112 = 0;
double Gd_116 = 0.0;
double G_pips_124 = 0.0;
double G_pips_132 = 15.0;
bool Gi_140 = FALSE;
int Gi_144 = 2;
int G_bars_148 = 8000;
double Gd_152;
double Gda_160[];
double G_ibuf_164[];
double G_ibuf_168[];
double G_ibuf_172[];
double G_ibuf_176[];
double G_ibuf_180[];
double G_ibuf_184[];
double G_ibuf_188[];
double G_time_192;
double Gd_208 = 0.0;
double Gd_216 = 0.0;
double Gd_224 = -100000.0;
double Gd_232 = 1000000.0;
int Gi_240;

// BB63D4283583708E94A566ACAD581B18
double f0_0(int Ai_0, double Ad_4, int Ai_12, int Ai_16) {
   double Ld_ret_20;
   double Ld_28;
   double Ld_36;
   double Ld_48;
   if (Ai_12 == 0) {
      Ld_28 = 0;
      Ld_36 = 0;
      for (int Li_44 = Ai_0 - 1; Li_44 >= 0; Li_44--) {
         if (Gi_108 == 0) Ld_48 = 1.0;
         else Ld_48 = 1.0 * (Ai_0 - Li_44) / Ai_0;
         Ld_28 += Ld_48 * (High[Ai_16 + Li_44] - (Low[Ai_16 + Li_44]));
         Ld_36 += Ld_48;
      }
      Gd_216 = Ld_28 / Ld_36;
      if (Gd_216 > Gd_224) Gd_224 = Gd_216;
      if (Gd_216 < Gd_232) Gd_232 = Gd_216;
      Ld_ret_20 = MathRound(Ad_4 / 2.0 * (Gd_224 + Gd_232) / Point);
   } else Ld_ret_20 = Ad_4 * Gi_104;
   return (Ld_ret_20);
}
			     	   		 			 			 		  		 	  	 	    	   			 					  		 		 			   	  			  	  	 	 			 				 			  	  			    	      			 						  		 			  	 			 				  
// D7B59FC1FF468B9BCD57E69E1EA40FBF
double f0_1(bool Ai_0, double A_pips_4, int Ai_12) {
   double Ld_ret_20;
   int ind_counted_16 = IndicatorCounted();
   if (Ai_0) {
      G_ibuf_184[Ai_12] = Low[Ai_12] + 2.0 * A_pips_4 * Point;
      G_ibuf_180[Ai_12] = High[Ai_12] - 2.0 * A_pips_4 * Point;
   } else {
      G_ibuf_184[Ai_12] = Close[Ai_12] + 2.0 * A_pips_4 * Point;
      G_ibuf_180[Ai_12] = Close[Ai_12] - 2.0 * A_pips_4 * Point;
   }
   if (ind_counted_16 == 0) {
      G_ibuf_184[Gi_240 + 1] = G_ibuf_184[Gi_240];
      G_ibuf_180[Gi_240 + 1] = G_ibuf_180[Gi_240];
      G_ibuf_188[Gi_240 + 1] = 0;
   }
   G_ibuf_188[Ai_12] = G_ibuf_188[Ai_12 + 1];
   if (Close[Ai_12] > G_ibuf_184[Ai_12 + 1]) G_ibuf_188[Ai_12] = 1;
   if (Close[Ai_12] < G_ibuf_180[Ai_12 + 1]) G_ibuf_188[Ai_12] = -1;
   if (G_ibuf_188[Ai_12] > 0.0) {
      if (G_ibuf_180[Ai_12] < G_ibuf_180[Ai_12 + 1]) G_ibuf_180[Ai_12] = G_ibuf_180[Ai_12 + 1];
      Ld_ret_20 = G_ibuf_180[Ai_12] + A_pips_4 * Point;
   } else {
      if (G_ibuf_184[Ai_12] > G_ibuf_184[Ai_12 + 1]) G_ibuf_184[Ai_12] = G_ibuf_184[Ai_12 + 1];
      Ld_ret_20 = G_ibuf_184[Ai_12] - A_pips_4 * Point;
   }
   return (Ld_ret_20);
}
	 	 				 	    	    	  	  	 	 	 		  					 	     	  		 		  				   		 			   	 			 	 			 	     	  		 	 	  					 					 			     	 	  	  	 	 	    	   		
// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(8);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle(4, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(1, 159);
   SetIndexArrow(2, 159);
   SetIndexArrow(3, 233);
   SetIndexArrow(4, 234);
   SetIndexBuffer(1, G_ibuf_164);
   SetIndexBuffer(2, G_ibuf_168);
   SetIndexShift(1, Gi_112);
   SetIndexShift(2, Gi_112);
   SetIndexBuffer(3, G_ibuf_172);
   SetIndexBuffer(4, G_ibuf_176);
   SetIndexBuffer(5, G_ibuf_188);
   SetIndexBuffer(6, G_ibuf_180);
   SetIndexBuffer(7, G_ibuf_184);
   string Ls_0 = "Medium-Term Scalper";
   IndicatorShortName(Ls_0);
   SetIndexLabel(0, Ls_0);
   SetIndexLabel(1, "UpTrend");
   SetIndexLabel(2, "DownTrend");
   SetIndexDrawBegin(0, Gi_76);
   SetIndexDrawBegin(1, Gi_76);
   SetIndexDrawBegin(2, Gi_76);
   SetIndexDrawBegin(3, Gi_76);
   SetIndexDrawBegin(4, Gi_76);
   SetIndexDrawBegin(6, Gi_76);
   SetIndexDrawBegin(7, Gi_76);
   return (0);
}
					 		   	 		  	   		        			  	 		   	 	 	 		   	   	 		  	   	       	  	  	      	   			     				 			 					 		   					 	 						  	   	 		
// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}
	 		 		 		 		 			   	 				  		       		 		 		   	 	 							    	 	   	 			   	  			 		 		   	 	 		  	 	  			 		   	    		 		    	 		  			   	    
// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int bars_8;
   int Li_12;
   int ind_counted_4 = IndicatorCounted();
   Gd_152 = Sensitivity;
   if (G_bars_148 > 0) bars_8 = G_bars_148;
   else bars_8 = Bars;
   if (ind_counted_4 > 0) Gi_240 = Bars - ind_counted_4;
   if (ind_counted_4 < 0) return (0);
   if (ind_counted_4 == 0) Gi_240 = bars_8 - Gi_76 - 1;
   for (int Li_0 = Bars - ind_counted_4; Li_0 >= 0; Li_0--) {
      G_ibuf_164[Li_0] = EMPTY_VALUE;
      G_ibuf_172[Li_0] = EMPTY_VALUE;
      G_ibuf_168[Li_0] = EMPTY_VALUE;
      G_ibuf_176[Li_0] = EMPTY_VALUE;
   }
   for (Li_0 = Gi_240; Li_0 >= 0; Li_0--) {
      Li_12 = f0_0(Gi_76, Gd_152, Gi_104, Li_0);
      Gd_208 = f0_1(Gi_140, Li_12, Li_0) + Gd_116 / 100.0 * Li_12 * Point;
      if (Gi_144 == 2) {
         if (G_ibuf_188[Li_0] > 0.0) {
            G_ibuf_164[Li_0] = Gd_208 + G_pips_124 * Point;
            if (G_ibuf_188[Li_0 + 1] < 0.0) {
               G_ibuf_164[Li_0 + 1] = G_ibuf_168[Li_0 + 1];
               G_ibuf_172[Li_0] = G_ibuf_168[Li_0 + 1] - G_pips_132 * Point;
            }
            Gda_160[Li_0] = G_ibuf_164[Li_0];
            if (Li_0 < 3 && G_ibuf_168[Li_0] == G_ibuf_164[Li_0] && G_time_192 != Time[0]) {
               if (PopUp_Alert) Alert("Medium-Term Scalper - Sell signal on ", Symbol(), ", TimeFrame: ", Period());
               G_time_192 = Time[0];
               if (Email_Alert) {
                  SendMail("Sell signal on " + Symbol() + ", TimeFrame: " + Period() + " at " + TimeToStr(G_time_192, TIME_DATE), "Medium-Term Scalper Sell signal on " + Symbol() +
                     ", TimeFrame: " + Period() + " at " + TimeToStr(G_time_192, TIME_DATE));
               }
            }
            G_ibuf_168[Li_0] = EMPTY_VALUE;
         }
         if (G_ibuf_188[Li_0] < 0.0) {
            G_ibuf_168[Li_0] = Gd_208 - G_pips_124 * Point;
            if (G_ibuf_188[Li_0 + 1] > 0.0) {
               G_ibuf_168[Li_0 + 1] = G_ibuf_164[Li_0 + 1];
               G_ibuf_176[Li_0] = G_ibuf_164[Li_0 + 1] + G_pips_132 * Point;
            }
            Gda_160[Li_0] = G_ibuf_168[Li_0];
            if (Li_0 < 3 && G_ibuf_168[Li_0] == G_ibuf_164[Li_0] && G_time_192 != Time[0]) {
               if (PopUp_Alert) Alert("Medium-Term Scalper - Buy signal on ", Symbol(), ", TimeFrame: ", Period());
               G_time_192 = Time[0];
               if (Email_Alert) {
                  SendMail("Buy signal on " + Symbol() + ", TimeFrame: " + Period() + " at " + TimeToStr(G_time_192, TIME_DATE), "Medium-Term Scalper Buy signal on " + Symbol() + ", TimeFrame: " +
                     Period() + " at " + TimeToStr(G_time_192, TIME_DATE));
               }
            }
            G_ibuf_164[Li_0] = EMPTY_VALUE;
         }
      } else {
         Gda_160[Li_0] = Gd_208;
         G_ibuf_164[Li_0] = EMPTY_VALUE;
         G_ibuf_168[Li_0] = EMPTY_VALUE;
         G_ibuf_172[Li_0] = -1;
         G_ibuf_176[Li_0] = -1;
      }
   }
   return (0);
}