
#property indicator_separate_window
#property indicator_minimum -1.0
#property indicator_maximum 1.0
#property indicator_buffers 6
#property indicator_color1 Black
#property indicator_color2 Aqua
#property indicator_width2 4
#property indicator_color3 Crimson
#property indicator_width3 4
#property indicator_color4 Black
#property indicator_color5 Black
#property indicator_color6 Black

extern int PriceActionFilter = 1;
extern int Length = 4;
extern int MajorCycleStrength = 4;
extern bool UseCycleFilter = FALSE;
extern int UseFilterSMAorRSI = 1;
extern int FilterStrengthSMA = 12;
extern int FilterStrengthRSI = 21;
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];
double g_ibuf_120[];
double g_ibuf_124[];
double g_ima_128 = 0.0;
double gd_136 = 0.0;
double gd_144 = 0.0;
double gd_152 = 0.0;
int gi_160 = 0;
int gi_164 = 0;
int gi_168 = 0;
int gi_172 = 0;
int gi_176 = 0;
int gi_unused_180 = 0;
int gi_unused_184 = 0;
int gi_unused_188 = 0;
int gi_unused_192 = 0;
double g_applied_price_196 = 0.0;
double g_applied_price_204 = 0.0;
int gi_212 = 1;
int gi_216 = 1;
double g_applied_price_220 = 0.0;
double g_applied_price_228 = 0.0;
int gi_236 = 0;
int gi_240 = 0;
bool gi_244 = TRUE;
bool gi_248 = FALSE;
bool gi_252 = FALSE;
bool gi_256 = FALSE;
bool gi_260 = FALSE;
int gi_264 = 1;
int gi_268;
int gi_272;

int init() {
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, g_ibuf_104);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, g_ibuf_108);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(2, g_ibuf_112);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, g_ibuf_116);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, g_ibuf_120);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, g_ibuf_124);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);
   SetIndexEmptyValue(3, 0.0);
   SetIndexEmptyValue(4, 0.0);
   SetIndexEmptyValue(5, 0.0);
   IndicatorShortName(" ");
   SetIndexLabel(0, NULL);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   SetIndexLabel(3, NULL);
   SetIndexLabel(4, NULL);
   SetIndexLabel(5, NULL);
   SetIndexLabel(6, NULL);
   SetIndexLabel(7, NULL);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int l_count_0;
   int li_4;
   int li_8;
   double l_ima_12;
   double l_ima_20;
   double l_ima_28;
   double l_ima_36;
   int l_ind_counted_44 = IndicatorCounted();
   if (l_ind_counted_44 < 0) return (-1);
   int li_48 = Bars - l_ind_counted_44;
   if (li_48 < 0) li_48 = 0;
   int li_52 = 250;
   double ld_56 = 0.0;
   double ld_64 = 0.0;
   for (int li_72 = li_48; li_72 >= 0; li_72--) {
      ld_64 = 0.0;
      l_count_0 = 0;
      for (int l_count_76 = 0; l_count_76 < li_52; l_count_76++) {
         l_count_0++;
         li_4 = li_72 + l_count_76;
         if (li_4 >= Bars) break;
         ld_64 += High[li_4] - Low[li_4];
      }
      ld_56 = ld_64 / l_count_0 * Length;
      li_8 = Bars - li_72;
      if (li_8 < 0) li_8 = 0;
      g_ima_128 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, li_72);
      if (UseFilterSMAorRSI == 1) g_ibuf_124[li_72] = ZeroLag(g_ima_128, FilterStrengthSMA, li_72);
      if (UseFilterSMAorRSI == 2) g_ibuf_124[li_72] = ZeroLag(iRSI(NULL, 0, 14, g_ima_128, FilterStrengthRSI), FilterStrengthRSI, li_72);
      if (g_ibuf_124[li_72] > g_ibuf_124[li_72 + 1]) gi_176 = 1;
      if (g_ibuf_124[li_72] < g_ibuf_124[li_72 + 1]) gi_176 = 2;
      if (li_8 <= 1) {
         if (gd_136 == 0.0) gd_144 = ld_56;
         else gd_144 = gd_136;
         g_applied_price_196 = g_ima_128;
         g_applied_price_220 = g_ima_128;
      }
      if (li_8 > 1) {
         if (gi_160 > -1) {
            if (g_ima_128 < g_applied_price_196) {
               if (UseCycleFilter && gi_176 == 2 && gi_248) {
                  g_ibuf_116[li_72 + li_8 - gi_212] = 0;
                  g_ibuf_104[li_72 + li_8 - gi_212] = 0;
               }
               if (!UseCycleFilter && gi_248) {
                  g_ibuf_116[li_72 + li_8 - gi_212] = 0;
                  g_ibuf_104[li_72 + li_8 - gi_212] = 0;
               }
               g_applied_price_196 = g_ima_128;
               gi_212 = li_8;
               gi_248 = TRUE;
            } else {
               if (g_ima_128 > g_applied_price_196) {
                  gi_168 = li_8 - gi_212;
                  if (!UseCycleFilter) {
                     g_ibuf_116[li_72 + gi_168] = -1;
                     g_ibuf_104[li_72 + gi_168] = -1;
                  }
                  if (UseCycleFilter && gi_176 == 1) {
                     g_ibuf_116[li_72 + gi_168] = -1;
                     g_ibuf_104[li_72 + gi_168] = -1;
                     gi_unused_180 = 1;
                  } else gi_unused_180 = 0;
                  gi_248 = TRUE;
                  l_ima_12 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, li_72 + gi_168);
                  if (gi_244) gi_268 = g_ima_128 - l_ima_12 >= gd_144;
                  else gi_268 = g_ima_128 >= l_ima_12 * (gd_144 / 1000.0 + 1.0);
                  if (gi_268 && gi_168 >= gi_264) {
                     gi_160 = -1;
                     g_applied_price_220 = g_ima_128;
                     gi_236 = li_8;
                     gi_256 = FALSE;
                     gi_248 = FALSE;
                  }
               }
            }
         }
         if (gi_160 < 1) {
            if (g_ima_128 > g_applied_price_220) {
               if (UseCycleFilter && gi_176 == 1 && gi_256) {
                  g_ibuf_120[li_72 + li_8 - gi_236] = 0;
                  g_ibuf_104[li_72 + li_8 - gi_236] = 0;
               }
               if (!UseCycleFilter && gi_256) {
                  g_ibuf_120[li_72 + li_8 - gi_236] = 0;
                  g_ibuf_104[li_72 + li_8 - gi_236] = 0;
               }
               g_applied_price_220 = g_ima_128;
               gi_236 = li_8;
               gi_256 = TRUE;
            } else {
               if (g_ima_128 < g_applied_price_220) {
                  gi_168 = li_8 - gi_236;
                  if (!UseCycleFilter) {
                     g_ibuf_120[li_72 + gi_168] = 1;
                     g_ibuf_104[li_72 + gi_168] = 1;
                  }
                  if (UseCycleFilter && gi_176 == 2) {
                     g_ibuf_120[li_72 + gi_168] = 1;
                     g_ibuf_104[li_72 + gi_168] = 1;
                     gi_unused_180 = 2;
                  } else gi_unused_180 = 0;
                  gi_256 = TRUE;
                  l_ima_20 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, li_72 + gi_168);
                  if (gi_244) gi_268 = l_ima_20 - g_ima_128 >= gd_144;
                  else gi_268 = g_ima_128 <= l_ima_20 * (1 - gd_144 / 1000.0);
                  if (gi_268 && gi_168 >= gi_264) {
                     gi_160 = 1;
                     g_applied_price_196 = g_ima_128;
                     gi_212 = li_8;
                     gi_256 = FALSE;
                     gi_248 = FALSE;
                  }
               }
            }
         }
      }
      g_ibuf_104[li_72] = 0;
      g_ibuf_116[li_72] = 0;
      g_ibuf_120[li_72] = 0;
      if (li_8 == 1) {
         if (gd_136 == 0.0) gd_152 = ld_56 * MajorCycleStrength;
         else gd_152 = gd_136 * MajorCycleStrength;
         g_applied_price_204 = g_ima_128;
         g_applied_price_228 = g_ima_128;
      }
      if (li_8 > 1) {
         if (gi_164 > -1) {
            if (g_ima_128 < g_applied_price_204) {
               if (UseCycleFilter && gi_176 == 2 && gi_252) g_ibuf_108[li_72 + li_8 - gi_216] = 0;
               if (!UseCycleFilter && gi_252) g_ibuf_108[li_72 + li_8 - gi_216] = 0;
               g_applied_price_204 = g_ima_128;
               gi_216 = li_8;
               gi_252 = TRUE;
            } else {
               if (g_ima_128 > g_applied_price_204) {
                  gi_172 = li_8 - gi_216;
                  if (!UseCycleFilter) g_ibuf_108[li_72 + gi_172] = -1;
                  if (UseCycleFilter && gi_176 == 1) {
                     g_ibuf_108[li_72 + gi_172] = -1;
                     gi_unused_184 = 1;
                  } else gi_unused_184 = 0;
                  gi_252 = TRUE;
                  l_ima_28 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, li_72 + gi_172);
                  if (gi_244) gi_272 = g_ima_128 - l_ima_28 >= gd_152;
                  else gi_272 = g_ima_128 >= l_ima_28 * (gd_152 / 1000.0 + 1.0);
                  if (gi_272 && gi_172 >= gi_264) {
                     gi_164 = -1;
                     g_applied_price_228 = g_ima_128;
                     gi_240 = li_8;
                     gi_260 = FALSE;
                     gi_252 = FALSE;
                  }
               }
            }
         }
         if (gi_164 < 1) {
            if (g_ima_128 > g_applied_price_228) {
               if (UseCycleFilter && gi_176 == 1 && gi_260) g_ibuf_112[li_72 + li_8 - gi_240] = 0;
               if (!UseCycleFilter && gi_260) g_ibuf_112[li_72 + li_8 - gi_240] = 0;
               g_applied_price_228 = g_ima_128;
               gi_240 = li_8;
               gi_260 = TRUE;
            } else {
               if (g_ima_128 < g_applied_price_228) {
                  gi_172 = li_8 - gi_240;
                  if (!UseCycleFilter) g_ibuf_112[li_72 + gi_172] = 1;
                  if (UseCycleFilter && gi_176 == 2) {
                     g_ibuf_112[li_72 + gi_172] = 1;
                     gi_unused_184 = 2;
                  } else gi_unused_184 = 0;
                  gi_260 = TRUE;
                  l_ima_36 = iMA(NULL, 0, PriceActionFilter, 0, MODE_SMMA, PRICE_CLOSE, li_72 + gi_172);
                  if (gi_244) gi_272 = l_ima_36 - g_ima_128 >= gd_152;
                  else gi_272 = g_ima_128 <= l_ima_36 * (1.0 - gd_152 / 1000.0);
                  if (gi_272 && gi_172 >= gi_264) {
                     gi_164 = 1;
                     g_applied_price_204 = g_ima_128;
                     gi_216 = li_8;
                     gi_260 = FALSE;
                     gi_252 = FALSE;
                  }
               }
            }
         }
      }
      g_ibuf_104[li_72] = 0;
      g_ibuf_112[li_72] = 0;
      g_ibuf_108[li_72] = 0;
   }
   return (0);
}

double ZeroLag(double ad_0, int ai_8, int ai_12) {
   if (ai_8 < 3) return (ad_0);
   double ld_16 = MathExp(-4.44220826 / ai_8);
   double ld_24 = 2.0 * ld_16 * MathCos(254.52 / ai_8);
   double ld_32 = ld_24;
   double ld_40 = (-ld_16) * ld_16;
   double ld_48 = 1 - ld_32 - ld_40;
   double ld_ret_56 = ld_48 * ad_0 + ld_32 * (g_ibuf_124[ai_12 + 1]) + ld_40 * (g_ibuf_124[ai_12 + 2]);
   return (ld_ret_56);
}

// ------------------------------------------------------------------------------------------ //
//                                     E N D   P R O G R A M                                  //
// ------------------------------------------------------------------------------------------ //
/*                                                                                                                 
                              ud$$$**$$$$$$$bc.                          
                          u@**"        4$$$$$$$Nu                       
                        J                ""#$$$$$$r                     
                       @                       $$$$b                    
                     .F                        ^*3$$$                   
                    :% 4                         J$$$N                  
                    $  :F                       :$$$$$                  
                   4F  9                       J$$$$$$$                 
                   4$   k             4$$$$bed$$$$$$$$$                 
                   $$r  'F            $$$$$$$$$$$$$$$$$r                
                   $$$   b.           $$$$$$$$$$$$$$$$$N                
                   $$$$$k 3eeed$$b    XARD777."$$$$$$$$$                
    .@$**N.        $$$$$" $$$$$$F'L $$$$$$$$$$$  $$$$$$$                
    :$$L  'L       $$$$$ 4$$$$$$  * $$$$$$$$$$F  $$$$$$F         edNc   
   @$$$$N  ^k      $$$$$  3$$$$*%   $F4$$$$$$$   $$$$$"        d"  z$N  
   $$$$$$   ^k     '$$$"   #$$$F   .$  $$$$$c.u@$$$          J"  @$$$$r 
   $$$$$$$b   *u    ^$L            $$  $$$$$$$$$$$$u@       $$  d$$$$$$ 
    ^$$$$$$.    "NL   "N. z@*     $$$  $$$$$$$$$$$$$P      $P  d$$$$$$$ 
       ^"*$$$$b   '*L   9$E      4$$$  d$$$$$$$$$$$"     d*   J$$$$$r   
            ^$$$$u  '$.  $$$L     "#" d$$$$$$".@$$    .@$"  z$$$$*"     
              ^$$$$. ^$N.3$$$       4u$$$$$$$ 4$$$  u$*" z$$$"          
                '*$$$$$$$$ *$b      J$$$$$$$b u$$P $"  d$$P             
                   #$$$$$$ 4$ 3*$"$*$ $"$'c@@$$$$ .u@$$$P               
                     "$$$$  ""F~$ $uNr$$$^&J$$$$F $$$$#                 
                       "$$    "$$$bd$.TZUMAN$$$$F $$"                   
                         ?k         ?$$$$$$$$$$$F'*                     
                          9$$bL     z$$$$$$$$$$$F                       
                           $$$$    $$$$$$$$$$$$$                        
                            '#$$c  '$$$$$$$$$"                          
                             .@"#$$$$$$$$$$$$b                          
                           z*      $$$$$$$$$$$$N.                       
                         e"      z$$"  #$$$k  '*$$.                     
                     .u*      u@$P"      '#$$c   "$$c                   
              u@$*"""       d$$"            "$$$u  ^*$$b.               
            :$F           J$P"                ^$$$c   '"$$$$$$bL        
           d$$  ..      @$#                      #$$b         '#$       
           9$$$$$$b   4$$                          ^$$k         '$      
            "$$6""$b u$$                             '$    d$$$$$P      
              '$F $$$$$"                              ^b  ^$$$$b$       
               '$W$$$$"                                'b@$$$$"         
                                                        ^$$$*  
*/     

