
#property  copyright "Mr. X"


#property indicator_separate_window
#property indicator_levelcolor clrDimGray
#property indicator_buffers 2
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_level1 25.0
#property indicator_level2 15.0

extern int     Len = 150;
extern int     HistoryBars = 500;
extern int     TF1 = 0;
extern int     TF2 = 0;
extern bool    ModeHL = TRUE;
extern bool    ModeOnline = TRUE;
extern bool    ModeinFile = FALSE;
extern bool    ModeHistory = FALSE;
extern bool    alert = FALSE;
extern bool    sound = FALSE;
extern bool    email = FALSE;
extern bool    GV = FALSE;
extern double  UrovenSignal = 25.0; 

double g_ibuf_148[];
double g_ibuf_152[];
double gd_156;
double gd_164;
double gd_172;
int gi_188;
int g_shift_192;
int gi_196;
int g_shift_200;
int g_count_208;
double gd_212;
double gd_220;
double gd_228;
double gd_236;
double gd_244;
double gd_252;
double gda_260[][240];
double gda_264[][240];
double gda_268[][240];
int g_timeframe_272;
int g_datetime_276;
int gi_280;
bool gi_284;
int g_file_288;
bool gi_292;

int init()
{
   IndicatorDigits(0);
   string short_name="Peak";
//---- indicator short name
   IndicatorShortName(short_name+" ("+Len+", "+TF1+", "+TF2+")");
   if (ModeinFile) FileDelete(Symbol() + "-SP-" + Period() + ".ini");
   if (TF2 == 0) TF2 = Period();
   HistoryBars = NormalizeDouble(HistoryBars / (TF2 / Period()), 0);
   SetIndexBuffer(0, g_ibuf_148);
   SetIndexLabel (0,"Line UP");
   SetIndexBuffer(1, g_ibuf_152);
   SetIndexLabel (1,"Line DN");
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   ArrayResize(gda_260, HistoryBars + Len);
   ArrayResize(gda_264, HistoryBars + Len);
   ArrayResize(gda_268, HistoryBars + Len);
   g_timeframe_272 = Period();
   if (ModeinFile) g_file_288 = FileOpen(Symbol() + "-SP-" + Period() + ".ini", FILE_WRITE, " ");
   return (0);
}
	        		 		 	 		  		 		 				  	    	 		 				 	 			 	  	  	   	  	 			 		  		 	 	 					   		 			 			  				    	 	    		    	 	  	  		  	 		  		
int start()
{
   int count_0;
   int li_4;
   int li_12;
   int li_20;
   int str2time_24;
   int str2int_28;
   int str2int_32;
   int file_36;
   if (ModeOnline || ModeinFile) {
      if (iTime(NULL, TF2, 0) == g_datetime_276) return (0);
      g_datetime_276 = iTime(NULL, TF2, 0);
      for (gi_188 = HistoryBars + Len; gi_188 > 0; gi_188--) {
         g_shift_200 = iBarShift(NULL, TF1, iTime(NULL, TF2, gi_188));
         count_0 = 0;
         for (g_shift_192 = g_shift_200; g_shift_192 > g_shift_200 - TF2; g_shift_192--) {
            gda_260[gi_188][count_0] = iClose(NULL, TF1, g_shift_192);
            if (ModeHL) gda_264[gi_188][count_0] = iHigh(NULL, TF1, g_shift_192);
            else gda_264[gi_188][count_0] = MathMax(iOpen(NULL, TF1, g_shift_192), iClose(NULL, TF1, g_shift_192));
            if (ModeHL) gda_268[gi_188][count_0] = iLow(NULL, TF1, g_shift_192);
            else gda_268[gi_188][count_0] = MathMin(iOpen(NULL, TF1, g_shift_192), iClose(NULL, TF1, g_shift_192));
            count_0++;
         }
      }
      li_4 = NormalizeDouble((Bars - IndicatorCounted()) / (TF2 / Period()), 0);
      if (ModeOnline && (!IsTesting())) li_4 = HistoryBars;
      for (gi_188 = li_4; gi_188 > 0; gi_188--) {
         g_count_208 = 0;
         gd_228 = 0;
         gd_236 = 0;
         gd_212 = 0;
         gd_220 = 1000000;
         while (g_count_208 < Len) {
            gi_196 = gi_188 + g_count_208;
            gd_244 = 0;
            gd_252 = 0;
            for (int count_8 = 0; count_8 < TF2; count_8++) {
               if (gda_260[gi_196][count_8] > 0.0) gd_156 = gda_260[gi_196][count_8];
               if (gda_264[gi_196][count_8] > 0.0) gd_164 = gda_264[gi_196][count_8];
               if (gda_268[gi_196][count_8] > 0.0) gd_172 = gda_268[gi_196][count_8];
               if (gd_164 > gd_212) {
                  gd_212 = gd_164;
                  gd_244 += gd_156;
               }
               if (gd_172 < gd_220) {
                  gd_220 = gd_172;
                  gd_252 += gd_156;
               }
            }
            if (gd_244 > 0.0) gd_228 += gd_244;
            if (gd_252 > 0.0) gd_236 += gd_252;
            g_count_208++;
         }
         if (gd_228 > 0.0 && gd_236 > 0.0) {
            if (ModeinFile && gi_280 != Time[gi_188]) {
               gi_280 = Time[gi_188];
               FileWrite(g_file_288, StringConcatenate(TimeToStr(Time[gi_188]), ";", DoubleToStr(gd_228 / gd_236, 0), ";", DoubleToStr(gd_236 / gd_228, 0)));
            }
            li_12 = iBarShift(NULL, 0, iTime(NULL, TF2, gi_188));
            for (int li_16 = li_12; li_16 > li_12 - TF2 / Period(); li_16--) {
               g_ibuf_148[li_16] = gd_228 / gd_236;
               g_ibuf_152[li_16] = gd_236 / gd_228;
            }
         }
      }
   }
   if (ModeHistory && (!ModeOnline) && (!ModeinFile) && gi_284 == FALSE) {
      gi_284 = TRUE;
      file_36 = FileOpen(Symbol() + "-SP-" + TF2 + ".ini", FILE_READ);
      while (!FileIsEnding(file_36)) {
         str2time_24 = StrToTime(FileReadString(file_36));
         str2int_28 = StrToInteger(FileReadString(file_36));
         str2int_32 = StrToInteger(FileReadString(file_36));
         li_20 = iBarShift(NULL, 0, str2time_24, FALSE);
         for (int li_40 = li_20; li_40 > li_20 - TF2 / Period(); li_40--) {
            g_ibuf_148[li_40] = str2int_28;
            g_ibuf_152[li_40] = str2int_32;
         }
      }
      FileClose(file_36);
   }
   string ls_44 = "";
   if (sound || alert || email || GV) {
      if (g_ibuf_148[li_16 + 1] > UrovenSignal && g_ibuf_148[li_16 + 1] < 1000000.0) ls_44 = Symbol() + " Signal " + WindowExpertName() + " BUY ( " + DoubleToStr(g_ibuf_148[li_16 + 1], 1) + " )";
      if (g_ibuf_152[li_16 + 1] > UrovenSignal && g_ibuf_152[li_16 + 1] < 1000000.0) ls_44 = Symbol() + " Signal " + WindowExpertName() + " SELL ( " + DoubleToStr(g_ibuf_152[li_16 + 1], 1) + " )";
      if (GV && (!IsTesting())) GlobalVariableSet(Symbol() + WindowExpertName(), g_ibuf_148[li_16 + 1] - (g_ibuf_152[li_16 + 1]));
      if (ls_44 != "" && (!IsTesting())) {
         if (sound && gi_292 == FALSE) PlaySound("Wait.wav");
         if (alert && gi_292 == FALSE) Alert(ls_44);
         if (email && gi_292 == FALSE) f0_0(ls_44);
         gi_292 = TRUE;
      } else gi_292 = FALSE;
   }
   return (0);
}
				 	 		  		   	  	  		  	 	 			 		 			  	 	 		 	  					 				 	 		   	 	  	  		 	 		 	  				     	 	  	     	 	 	 	 	   			    		 	  			 	 		   
void f0_0(string as_0) {
   if (IsTesting() == FALSE && IsOptimization() == FALSE && IsVisualMode() == FALSE) SendMail(WindowExpertName(), as_0);
}
	 		 	  		 		  			 	  	  		 	 	 				 		  		 	 	     			 						    	   				 	  	    		 		  			  	 		 	    	   	     	 	 	  		   		  	  	 			 		 	 
void deinit() {
   if (ModeinFile) FileClose(g_file_288);
}
