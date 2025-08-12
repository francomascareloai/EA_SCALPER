
#property copyright "Chumachenko Alexander, signalcash@gmail.com"
#property link      "http://www.webmehanikov.net"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red

extern int timeFrame = 0;
extern int Length = 1;
extern int barsback = 500;
extern bool alertsOn = TRUE;
extern bool alertsOnCurrent = FALSE;
extern bool alertsMessage = TRUE;
extern bool alertsSound = FALSE;
extern bool alertsNotify = FALSE;
extern bool alertsEmail = FALSE;
extern string soundfile = "alert2.wav";
extern bool arrowsVisible = TRUE;
extern string arrowsIdentifier = "filterArrows";
extern double arrowsDisplacement = 0.5;
extern color arrowsUpColor = DeepSkyBlue;
extern color arrowsDnColor = Red;
extern int arrowsUpCode = 233;
extern int arrowsDnCode = 234;
extern int arrowsUpSize = 1;
extern int arrowsDnSize = 1;
double Gda_164[];
double Gda_168[];
double Gda_172[];
double Gda_176[];
bool Gi_180;
bool Gi_184;
bool Gi_188 = TRUE;
string Gs_192;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gi_188 = TRUE;
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, Gda_164);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, Gda_168);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2,arrowsUpCode);
   SetIndexBuffer(2, Gda_172);
   SetIndexLabel(2,"UP");
   SetIndexArrow(3,arrowsDnCode);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexBuffer(3, Gda_176);
   SetIndexLabel(3,"DN");
   Gs_192 = WindowExpertName();
   timeFrame = MathMax(timeFrame, Period());
   return (0);
}
	 				 			 	    		  			  	 		 	   				  	 	 		       											  	   				  	   		    		 	 	   	 		   	 	  				 	 	 	     	 	 			 						  	  	 		
// 52D46093050F38C27267BCE42543EF60
int deinit() {
   string Ls_16;
   string Ls_0 = arrowsIdentifier + ":";
   int Li_8 = StringLen(Ls_0);
   for (int Li_12 = ObjectsTotal() - 1; Li_12 >= 0; Li_12--) {
      Ls_16 = ObjectName(Li_12);
      if (StringSubstr(Ls_16, 0, Li_8) == Ls_0) ObjectDelete(Ls_16);
   }
   return (0);
}
	 	 		   	     	 	 							  	 			 	 		 	  				 		  	 		  		 			 	 		  	  	 		  	 	 	  	 		      				  		    				  			  		 			 	   	 			 	 		 	   
// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_0;
   int Li_8;
   double Ld_12;
   double Ld_20;
   double Lda_28[10000][3];
   if (timeFrame != Period()) {
      Li_0 = MathMin(Bars - 1, barsback * timeFrame / Period());
      for (int Li_4 = Li_0; Li_4 >= 0; Li_4--) {
         Li_8 = iBarShift(NULL, timeFrame, Time[Li_4]);
         Gda_164[Li_4] = iCustom(NULL, timeFrame, Gs_192, 0, Length, barsback, alertsOn, alertsOnCurrent, alertsMessage, alertsSound, alertsNotify, alertsEmail, soundfile,
            arrowsVisible, arrowsIdentifier, arrowsDisplacement, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, arrowsUpSize, arrowsDnSize, 0, Li_8);
         Gda_168[Li_4] = iCustom(NULL, timeFrame, Gs_192, 0, Length, barsback, alertsOn, alertsOnCurrent, alertsMessage, alertsSound, alertsNotify, alertsEmail, soundfile,
            arrowsVisible, arrowsIdentifier, arrowsDisplacement, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, arrowsUpSize, arrowsDnSize, 1, Li_8);
      }
      return (0);
   }
   if (!Gi_188) return (0);
   int Li_32 = 0;
   int Li_36 = 0;
   int Li_40 = 0;
   double Ld_44 = High[barsback];
   double Ld_52 = Low[barsback];
   int Li_60 = barsback;
   int Li_64 = barsback;
   for (int Li_68 = barsback; Li_68 >= 0; Li_68--) {
      Ld_12 = 10000000;
      Ld_20 = -100000000;
      for (int Li_72 = Li_68 + Length; Li_72 >= Li_68 + 1; Li_72--) {
         if (Low[Li_72] < Ld_12) Ld_12 = Low[Li_72];
         if (High[Li_72] > Ld_20) Ld_20 = High[Li_72];
      }
      if (Low[Li_68] < Ld_12 && High[Li_68] > Ld_20) {
         Li_36 = 2;
         if (Li_32 == 1) Li_60 = Li_68 + 1;
         if (Li_32 == -1) Li_64 = Li_68 + 1;
      } else {
         if (Low[Li_68] < Ld_12) Li_36 = -1;
         if (High[Li_68] > Ld_20) Li_36 = 1;
      }
      if (Li_36 != Li_32 && Li_32 != 0) {
         if (Li_36 == 2) {
            Li_36 = -Li_32;
            Ld_44 = High[Li_68];
            Ld_52 = Low[Li_68];
            Gi_180 = FALSE;
            Gi_184 = FALSE;
         }
         Li_40++;
         if (Li_36 == 1) {
            Lda_28[Li_40][1] = Li_64;
            Lda_28[Li_40][2] = Ld_52;
            Gi_180 = FALSE;
            Gi_184 = TRUE;
         }
         if (Li_36 == -1) {
            Lda_28[Li_40][1] = Li_60;
            Lda_28[Li_40][2] = Ld_44;
            Gi_180 = TRUE;
            Gi_184 = FALSE;
         }
         Ld_44 = High[Li_68];
         Ld_52 = Low[Li_68];
      }
      if (Li_36 == 1) {
         if (High[Li_68] >= Ld_44) {
            Ld_44 = High[Li_68];
            Li_60 = Li_68;
         }
      }
      if (Li_36 == -1) {
         if (Low[Li_68] <= Ld_52) {
            Ld_52 = Low[Li_68];
            Li_64 = Li_68;
         }
      }
      Li_32 = Li_36;
      if (Gi_184 == TRUE) {
         Gda_168[Li_68] = 1;
         Gda_164[Li_68] = 0;
      }
      if (Gi_180 == TRUE) {
         Gda_168[Li_68] = 0;
         Gda_164[Li_68] = 1;
      }
      double Ld_28 = iATR(NULL, 0, 20, Li_68);
      if (Gda_168[Li_68] == 1.0 && Gda_168[Li_68 + 1] == 0.0){// f0_1(Ai_0, arrowsUpColor, arrowsUpCode, arrowsUpSize, 0);
      Gda_172[Li_68]=Low[Li_68] - arrowsDisplacement * Ld_28; Gda_176[Li_68]=EMPTY_VALUE;}
      if (Gda_164[Li_68] == 1.0 && Gda_164[Li_68 + 1] == 0.0){// f0_1(Ai_0, arrowsDnColor, arrowsDnCode, arrowsDnSize, 1);
      Gda_172[Li_68]=EMPTY_VALUE; Gda_176[Li_68]=High[Li_68] + arrowsDisplacement * Ld_28;}
//      f0_0(Li_68);
   }
   return (0);
}
		 		 	 	 		 				 	 	  	  				 	 	 		 				  	 		 		     	  		    	   	  	 	 					 	  	    		 		      	 						  			  				 	  		  		 		    	    	 	
// 83352185C0DFB1AB94B9BFBEB80DECFE
void f0_0(int Ai_0) {
   if (arrowsVisible) {
      ObjectDelete(arrowsIdentifier + ":" + Time[Ai_0]);
      if (Gda_168[Ai_0] == 1.0 && Gda_168[Ai_0 + 1] == 0.0) f0_1(Ai_0, arrowsUpColor, arrowsUpCode, arrowsUpSize, 0);
      if (Gda_164[Ai_0] == 1.0 && Gda_164[Ai_0 + 1] == 0.0) f0_1(Ai_0, arrowsDnColor, arrowsDnCode, arrowsDnSize, 1);
   }
}
	   	  				  	  					 	  		 			     	   	  		     		  				  	 		   	 									  				 			 		  	 	 	 	 		 	 	 	 	 	  			     						   	 		   	   		
// 8D889266138297DD92247DFDC01E6723
void f0_1(int Ai_0, color Ai_4, int Ai_8, int Ai_12, bool Ai_16) {
   string Ls_20 = arrowsIdentifier + ":" + Time[Ai_0];
   double Ld_28 = iATR(NULL, 0, 20, Ai_0);
   ObjectCreate(Ls_20, OBJ_ARROW, 0, Time[Ai_0], 0);
   ObjectSet(Ls_20, OBJPROP_ARROWCODE, Ai_8);
   ObjectSet(Ls_20, OBJPROP_COLOR, Ai_4);
   ObjectSet(Ls_20, OBJPROP_WIDTH, Ai_12);
   if (Ai_16) {
      ObjectSet(Ls_20, OBJPROP_PRICE1, High[Ai_0] + arrowsDisplacement * Ld_28);
      return;
   }
   ObjectSet(Ls_20, OBJPROP_PRICE1, Low[Ai_0] - arrowsDisplacement * Ld_28);
}