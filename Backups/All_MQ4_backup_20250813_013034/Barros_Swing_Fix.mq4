//+------------------------------------------------------------------+
//|                                                 Barros Swing.mq4 |
//|                                    Copyright ? 2009, Walter Choy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright ? 2009, Walter Choy"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 OrangeRed
#property indicator_color2 MediumPurple
#property indicator_color3 Red
#property indicator_color4 Black
#property indicator_color5 Black
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 4
//---- input parameters
extern int       period = 18;
extern bool      show_d1_swing = false;

extern string    XABC_setting = "<<-- XABC Settings -->>";
extern bool      XABC_enabled = true;
extern datetime  XABC_spec_time = 0; //D'2008.12.1 00:00';
extern string    XABC_font = "Arial";
extern int       XABC_font_size = 16;
extern color     XABC_font_color = White;
extern color     XABC_ME_line_color = Yellow;
//---- constants
#define LINE_DIRECT_UP  1
#define LINE_DIRECT_DN  -1
#define LINE_NO_DIRECT  -2

#define XABC_A             0
#define XABC_A_BAR         1
#define XABC_B             2
#define XABC_B_BAR         3
#define XABC_C             4
#define XABC_C_BAR         5
#define XABC_UPPER_ME      6
#define XABC_LOWER_ME      7
#define XABC_PBZ           8
#define XABC_PSZ           9
#define XABC_SWING_COUNT   10
//---- buffers
double d1_swing[];
double dn_swing[];
double XABC[];
double imean[];
double signals[];
double d1_line_direct[];
double dn_line_direct[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(7);

   if (show_d1_swing)
      SetIndexStyle(0,DRAW_SECTION);
   else 
      SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,d1_swing);
   SetIndexEmptyValue(0, 0);
   SetIndexLabel(0, "1-period Swing");
   
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,dn_swing);
   SetIndexEmptyValue(1, 0);
   SetIndexLabel(1, period + "-period Swing");
   
   SetIndexStyle(2,DRAW_SECTION);
   SetIndexBuffer(2,XABC);
   SetIndexEmptyValue(2, 0);
   SetIndexLabel(2, "XABC");

   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,imean);
   SetIndexLabel(3, "Impluse mean");

   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, signals);
   SetIndexLabel(4, "Signals");
   
   SetIndexBuffer(5,d1_line_direct);
   SetIndexBuffer(6,dn_line_direct);

   IndicatorDigits(Digits);   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
      clear_label();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int   counted_bars=IndicatorCounted();
   double shd_h, shd_l;
   int direct;
   static double impulse_mean, impulse_count, last_val_1, last_val_2, last_val_3;
   double val_0, val_1, val_2, val_3;
   int   i, j, n;
//----
   n = Bars - counted_bars - 1;
   i = n;
   
   while (i>=0){
      if (i == Bars - 1){
         shd_h = High[i] - High[i-1];
         shd_l = Low[i]- Low[i-1];
         if (shd_h > shd_l){ 
            d1_swing[i] = High[i];            
            d1_line_direct[i] = LINE_DIRECT_UP;
         } else {
            d1_swing[i] = Low[i];            
            d1_line_direct[i] = LINE_DIRECT_DN;
         }
      } else {
         direct = d1_direct(i);
         switch (direct){
            case LINE_DIRECT_UP:
               d1_swing[i] = High[i];            
               d1_line_direct[i] = LINE_DIRECT_UP;
               if (d1_line_direct[i+1] == LINE_DIRECT_UP) d1_swing[i+1] = 0;
               if (d1_line_direct[i+1] == LINE_NO_DIRECT){
                  j = i+1;
                  while(d1_line_direct[j] == LINE_NO_DIRECT && j <= Bars) j++;
                  if(d1_line_direct[j] == LINE_DIRECT_UP){
                     if(High[j] < High[i]){
                        d1_swing[j] = 0;
                     } else {
                        d1_swing[i] = 0;
                        d1_line_direct[i] = LINE_NO_DIRECT;
                     }
                  }
               }
               break;
               
            case LINE_DIRECT_DN:
               d1_swing[i] = Low[i];            
               d1_line_direct[i] = LINE_DIRECT_DN;
               if (d1_line_direct[i+1] == LINE_DIRECT_DN) d1_swing[i+1] = 0;
               if (d1_line_direct[i+1] == LINE_NO_DIRECT){
                  j = i+1;
                  while(d1_line_direct[j] == LINE_NO_DIRECT && j <= Bars) j++;
                  if(d1_line_direct[j] == LINE_DIRECT_DN){
                     if(Low[j] > Low[i]){
                        d1_swing[j] = 0;
                     } else {
                        d1_swing[i] = 0;
                        d1_line_direct[i] = LINE_NO_DIRECT;
                     }
                  }
               }
               break;
               
            case LINE_NO_DIRECT:
               d1_swing[i] = 0;
               d1_line_direct[i] = LINE_NO_DIRECT;            
               break;
         }
      } 
      i--;
   }

   i = n;

   while (i>=0){
      if (i == Bars - 1){
         shd_h = High[i] - High[i-1];
         shd_l = Low[i]- Low[i-1];
         if (shd_h > shd_l){ 
            dn_swing[i] = High[i];            
            dn_line_direct[i] = LINE_DIRECT_UP;
         } else {
            dn_swing[i] = Low[i];            
            dn_line_direct[i] = LINE_DIRECT_DN;
         }
      } else {
         direct = dn_direct(i, period);
         switch (direct){
            case LINE_DIRECT_UP:
               dn_swing[i] = High[i];            
               dn_line_direct[i] = LINE_DIRECT_UP;
               if (dn_line_direct[i+1] == LINE_DIRECT_UP) dn_swing[i+1] = 0;
               if (dn_line_direct[i+1] == LINE_NO_DIRECT){
                  j = i+1;
                  while(dn_line_direct[j] == LINE_NO_DIRECT && j <= Bars) j++;
                  if(dn_line_direct[j] == LINE_DIRECT_UP){
                     if(High[j] < High[i]){
                        dn_swing[j] = 0;
                     } else {
                        dn_swing[i] = 0;
                        dn_line_direct[i] = LINE_NO_DIRECT;
                     }
                  }
               }
               break;
               
            case LINE_DIRECT_DN:
               dn_swing[i] = Low[i];            
               dn_line_direct[i] = LINE_DIRECT_DN;
               if (dn_line_direct[i+1] == LINE_DIRECT_DN) dn_swing[i+1] = 0;
               if (dn_line_direct[i+1] == LINE_NO_DIRECT){
                  j = i+1;
                  while(dn_line_direct[j] == LINE_NO_DIRECT && j <= Bars) j++;
                  if(dn_line_direct[j] == LINE_DIRECT_DN){
                     if(Low[j] > Low[i]){
                        dn_swing[j] = 0;
                     } else {
                        dn_swing[i] = 0;
                        dn_line_direct[i] = LINE_NO_DIRECT;
                     }
                  }
               }
               break;
               
            case LINE_NO_DIRECT:
               dn_swing[i] = 0;
               dn_line_direct[i] = LINE_NO_DIRECT;            
               break;
         }
      } 

      // Calculate impulse means
      val_0 = 0; val_1 = 0; val_2 = 0; val_3 = 0; j = i;
      while(val_3 == 0 && j <= Bars){
         if (dn_swing[j] > 0){
            if (val_0 == 0){
               val_0 = dn_swing[j];
            } else {
               if (val_1 == 0){
                  val_1 = dn_swing[j];
               } else {
                  if (val_2 == 0){
                     val_2 = dn_swing[j];
                  } else {
                     val_3 = dn_swing[j];
                  }
               }
            }
         }
         j++;
      }
      
      bool isimpulse = false;
      if (val_2 > val_1){
         if (val_3 > val_1) isimpulse = true;
      } else {
         if (val_3 < val_1) isimpulse = true;
      }
      
      if ((last_val_1 != val_1 && last_val_2 != val_2 && last_val_3 != val_3) ||
         (last_val_1 == 0 && last_val_2 == 0 && last_val_3 == 0)){
         last_val_1 = val_1; last_val_2 = val_2; last_val_3 = val_3;
         if(val_1 > 0 && val_2 > 0 && val_3 > 0 && isimpulse){
            if(impulse_mean > 0){
               if(MathAbs(val_1 - val_2) <= (impulse_mean * 5.0)){
                  impulse_mean = impulse_mean * impulse_count + MathAbs(val_1 - val_2);
                  impulse_count++;
                  impulse_mean /= impulse_count;
               }
            } else {        
               impulse_mean = MathAbs(val_1 - val_2);
               impulse_count = 1;
            }
         }
      }
 
      GlobalVariableSet(period+"d_Impluse_Mean", impulse_mean);
      GlobalVariableSet(period+"d_Impluse_Count", impulse_count);
 
      imean[i] = impulse_mean;   
      
      i--;
   }
   
   if (XABC_enabled) identify_XABC();   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

int d1_direct(int idx){
   double shd_h, shd_l;

   shd_h = High[idx] - High[idx+1];
   shd_l = Low[idx+1] - Low[idx];

   if (shd_h > shd_l && shd_h > 0) 
      return (LINE_DIRECT_UP);

   if (shd_h < shd_l && shd_l > 0) 
      return (LINE_DIRECT_DN);

   return (LINE_NO_DIRECT);
}

int dn_direct(int idx, int n){
   double shd_h, shd_l, nHigh, nLow, ten_pc;
   double val_1, val_2;
   int i, j;
   
   nHigh = High[idx+1]; nLow = Low[idx+1];
   for (i=1; i<=n; i++){
      nHigh = MathMax(nHigh, High[idx+i]);
      nLow = MathMin(nLow, Low[idx+i]);
   }

   j = idx+1; val_1 = 0; val_2 = 0;
   while(val_2 == 0 && j <= Bars){
      if (d1_swing[j] > 0){
         if (val_1 <= 0){
            val_1 = d1_swing[j];
         } else {
            val_2 = d1_swing[j];
         }
      }
      j++;   
   }
   ten_pc = 0;   
   if(val_1 > 0 && val_2 > 0) ten_pc = MathAbs(val_1 - val_2) * 10 / 100;
   
   nHigh += ten_pc; nLow -= ten_pc;
   
   shd_h = High[idx] - nHigh;
   shd_l = nLow - Low[idx];
   
   if (shd_h > shd_l && shd_h > 0) 
      return (LINE_DIRECT_UP);

   if (shd_h < shd_l && shd_l > 0) 
      return (LINE_DIRECT_DN);
   
   return (LINE_NO_DIRECT);
}

int num_label = 0;
int total_swing_pt = 0;
datetime sDateTime[];
double swing_point[];

int total_XABC_swing_pt = 0;
datetime XABC_DateTime[];
double XABC_swing_point[];

void identify_XABC(){
   clear_label();
   clear_swing_pts();
   if(XABC_spec_time > 0) 
      catch_swing_pt_ex(); 
   else 
      catch_swing_pt();   
   catch_XABC();
   show_XABC();   
}

void catch_XABC(){
   double X_pt, A_pt, B_pt, ME, XA_10pc, AB_20pc, A_Max, A_Min, B_Max, B_Min, imp_mean;
   datetime X_dt, A_dt, B_dt, sp_dt;
   int i, j, A_pos, B_pos;
   bool is_A_Vtop, is_B_Vtop;

   clear_XABC_swing_pts();

   if (XABC_spec_time > 0){
      sp_dt = XABC_spec_time; 
      imp_mean = imean[iBarShift(NULL, 0, sp_dt)];
   } else {
      sp_dt = TimeCurrent();
      imp_mean = imean[0];
   }
            
   X_pt = swing_point[total_swing_pt - 1];
   X_dt = sDateTime[total_swing_pt - 1];

   A_pt = swing_point[total_swing_pt - 2];
   A_dt = sDateTime[total_swing_pt - 2];
   A_pos = 2;

   B_pt = swing_point[total_swing_pt - 3];
   B_dt = sDateTime[total_swing_pt - 3];
   B_pos = 3;
      
   XA_10pc = MathAbs(A_pt - X_pt) * 10 / 100;
   AB_20pc = MathAbs(B_pt - A_pt) * 20 / 100;
   
   ME = MathMax(XA_10pc, AB_20pc);

   if (A_pt > X_pt) is_A_Vtop = true; else is_A_Vtop = false;
   if (B_pt > A_pt) is_B_Vtop = true; else is_B_Vtop = false;

   A_Max = A_pt; A_Min = A_pt;
      
   for(i=4; i<total_swing_pt-1; i+=2){
      if (is_A_Vtop){
         A_Max = MathMax(A_Max, swing_point[total_swing_pt - i]);
         if (swing_point[total_swing_pt - i] >= A_pt && swing_point[total_swing_pt - i] <= A_pt + ME 
            && swing_point[total_swing_pt - i] >= A_Max && sDateTime[total_swing_pt - i] < sp_dt){
            A_pt = swing_point[total_swing_pt - i];
            A_dt = sDateTime[total_swing_pt - i];
  
            for (j=i-1; j>=0; j-=2){
               if(MathAbs(swing_point[total_swing_pt - j] - A_pt) >= imp_mean){
                  X_pt = swing_point[total_swing_pt - j];
                  X_dt = sDateTime[total_swing_pt - j];
                  break;
               }
            }
                        
            XA_10pc = MathAbs(A_pt - X_pt) * 10 / 100;
   
            ME = MathMax(XA_10pc, AB_20pc);

            if (A_pt > X_pt) is_A_Vtop = true; else is_A_Vtop = false;
            
            A_pos = i;            
         }
         if (swing_point[total_swing_pt - i - 1] < A_pt && swing_point[total_swing_pt - i] > A_pt + ME 
            && swing_point[total_swing_pt - i] >= A_Max && sDateTime[total_swing_pt - i] < sp_dt){
            A_pt = swing_point[total_swing_pt - i];
            A_dt = sDateTime[total_swing_pt - i];
  
            for (j=i-1; j>=0; j-=2){
               if(MathAbs(swing_point[total_swing_pt - j] - A_pt) >= imp_mean){
                  X_pt = swing_point[total_swing_pt - j];
                  X_dt = sDateTime[total_swing_pt - j];
                  break;
               }
            }

            XA_10pc = MathAbs(A_pt - X_pt) * 10 / 100;
   
            ME = MathMax(XA_10pc, AB_20pc);

            if (A_pt > X_pt) is_A_Vtop = true; else is_A_Vtop = false;
            
            A_pos = i;            
         }         
      } else {
         A_Min = MathMin(A_Min, swing_point[total_swing_pt - i]);
         if (swing_point[total_swing_pt - i] <= A_pt && swing_point[total_swing_pt - i] >= A_pt - ME 
            && swing_point[total_swing_pt - i] <= A_Min && sDateTime[total_swing_pt - i] < sp_dt){
            A_pt = swing_point[total_swing_pt - i];
            A_dt = sDateTime[total_swing_pt - i];
  
            for (j=i-1; j>=0; j-=2){
               if(MathAbs(swing_point[total_swing_pt - j] - A_pt) >= imp_mean){
                  X_pt = swing_point[total_swing_pt - j];
                  X_dt = sDateTime[total_swing_pt - j];
                  break;
               }
            }

            XA_10pc = MathAbs(A_pt - X_pt) * 10 / 100;
   
            ME = MathMax(XA_10pc, AB_20pc);

            if (A_pt > X_pt) is_A_Vtop = true; else is_A_Vtop = false;
            
            A_pos = i;            
         }
         if (swing_point[total_swing_pt - i - 1] > A_pt && swing_point[total_swing_pt - i] < A_pt - ME 
            && swing_point[total_swing_pt - i] <= A_Min && sDateTime[total_swing_pt - i] < sp_dt){
            A_pt = swing_point[total_swing_pt - i];
            A_dt = sDateTime[total_swing_pt - i];
  
            for (j=i-1; j>=0; j-=2){
               if(MathAbs(swing_point[total_swing_pt - j] - A_pt) >= imp_mean){
                  X_pt = swing_point[total_swing_pt - j];
                  X_dt = sDateTime[total_swing_pt - j];
                  break;
               }
            }

            XA_10pc = MathAbs(A_pt - X_pt) * 10 / 100;
   
            ME = MathMax(XA_10pc, AB_20pc);

            if (A_pt > X_pt) is_A_Vtop = true; else is_A_Vtop = false;
            
            A_pos = i;            
         }         
      }
   }

   add_XABC_swing_pt(X_pt, X_dt);   
   add_XABC_swing_pt(A_pt, A_dt);

   if(A_pos != 2){
      B_pt = swing_point[total_swing_pt - (A_pos + 1)];
      B_dt = sDateTime[total_swing_pt - (A_pos + 1)];
      B_pos = (A_pos + 1);
      
      AB_20pc = MathAbs(B_pt - A_pt) * 20 / 100;
   
      ME = MathMax(XA_10pc, AB_20pc);

      if (B_pt > A_pt) is_B_Vtop = true; else is_B_Vtop = false;
   }
   
   B_Max = B_pt; B_Min = B_pt;
   
   for(i=B_pos+2; i<total_swing_pt; i+=2){
      if (is_B_Vtop){
         B_Max = MathMax(B_Max, swing_point[total_swing_pt - i]);   
         if (swing_point[total_swing_pt - i] >= B_pt && swing_point[total_swing_pt - i] <= B_pt + ME 
            && swing_point[total_swing_pt - i] >= B_Max && sDateTime[total_swing_pt - i] < sp_dt){
            B_pt = swing_point[total_swing_pt - i];
            B_dt = sDateTime[total_swing_pt - i];
            B_pos = i;
      
            AB_20pc = MathAbs(B_pt - A_pt) * 20 / 100;
   
            ME = MathMax(XA_10pc, AB_20pc);

            if (B_pt > A_pt) is_B_Vtop = true; else is_B_Vtop = false;
         }
         if (swing_point[total_swing_pt - i - 1] < B_pt && swing_point[total_swing_pt - i] > B_pt + ME 
            && swing_point[total_swing_pt - i] >= B_Max && sDateTime[total_swing_pt - i] < sp_dt){
            B_pt = swing_point[total_swing_pt - i];
            B_dt = sDateTime[total_swing_pt - i];
            B_pos = i;
      
            AB_20pc = MathAbs(B_pt - A_pt) * 20 / 100;
   
            ME = MathMax(XA_10pc, AB_20pc);

            if (B_pt > A_pt) is_B_Vtop = true; else is_B_Vtop = false;
         }      
      } else {
         B_Min = MathMin(B_Min, swing_point[total_swing_pt - i]);
         if (swing_point[total_swing_pt - i] <= B_pt && swing_point[total_swing_pt - i] >= B_pt - ME 
            && swing_point[total_swing_pt - i] <= B_Min && sDateTime[total_swing_pt - i] < sp_dt){
            B_pt = swing_point[total_swing_pt - i];
            B_dt = sDateTime[total_swing_pt - i];
            B_pos = i;
      
            AB_20pc = MathAbs(B_pt - A_pt) * 20 / 100;
   
            ME = MathMax(XA_10pc, AB_20pc);

            if (B_pt > A_pt) is_B_Vtop = true; else is_B_Vtop = false;
         }
         if (swing_point[total_swing_pt - i - 1] > B_pt && swing_point[total_swing_pt - i] < B_pt - ME 
            && swing_point[total_swing_pt - i] <= B_Min && sDateTime[total_swing_pt - i] < sp_dt){
            B_pt = swing_point[total_swing_pt - i];
            B_dt = sDateTime[total_swing_pt - i];
            B_pos = i;
      
            AB_20pc = MathAbs(B_pt - A_pt) * 20 / 100;
   
            ME = MathMax(XA_10pc, AB_20pc);

            if (B_pt > A_pt) is_B_Vtop = true; else is_B_Vtop = false;
         }      
      }   
   }   

   add_XABC_swing_pt(B_pt, B_dt);

   for(i=B_pos+1; i<=total_swing_pt; i++)
      add_XABC_swing_pt(swing_point[total_swing_pt-i], sDateTime[total_swing_pt-i]);
}

string get_XABC_label(int num){
   int n, m, r;
   string str;
   string labels_1[] = {"X", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", 
                     "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
   string labels[] = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", 
                     "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
   str = "";
   if (num < 27){
      str = labels_1[num];
   } else {
      n = num-1;
      while (n > 0){
         m = n;
         n = m / 26;
         r = m % 26;
         if (n == 0)
            str = labels[r-1] + str;
         else
            str = labels[r] + str;
      }
   }
   return (str);
}

void show_XABC(){
   string strlabel;
   double sp, pos, X_pt, A_pt, B_pt, C_pt, ME, XA_10pc, AB_20pc, ABdiv8;
   datetime A_dt, B_dt, C_dt;
   int A_bar, B_bar, C_bar;
   int i, n, align; 
   
   ArrayInitialize(XABC, 0);
   
   clear_XABC_signals();
   
   for(i=0; i<total_XABC_swing_pt; i++){
      strlabel =  "XABC_label_" + i;
      
      if (i == total_XABC_swing_pt-1){
         if (XABC_swing_point[i] > XABC_swing_point[i - 1])
            sp = imean[0] * 20 / 100;
         else
            sp = -(imean[0] * 10 / 100);
      } else {
         if (XABC_swing_point[i] > XABC_swing_point[i + 1])
            sp = imean[0] * 20 / 100;
         else
            sp = -(imean[0] * 10 / 100);
      }
      
      pos = XABC_swing_point[i] + sp;
      
      ObjectCreate(strlabel, OBJ_TEXT, 0, XABC_DateTime[i], pos);
      ObjectSetText(strlabel, get_XABC_label(i), XABC_font_size, XABC_font, XABC_font_color);
      num_label++;
      
      n = iBarShift(NULL, 0, XABC_DateTime[i]);
      XABC[n] = XABC_swing_point[i];   
   }

   X_pt = XABC_swing_point[0];

   A_pt = XABC_swing_point[1];
   A_dt = XABC_DateTime[1];

   B_pt = XABC_swing_point[2];
   B_dt = XABC_DateTime[2];

   C_pt = XABC_swing_point[3];
   C_dt = XABC_DateTime[3];
   
   A_bar = iBarShift(NULL, 0, A_dt);
   B_bar = iBarShift(NULL, 0, B_dt);
   C_bar = iBarShift(NULL, 0, C_dt);
      
   XA_10pc = MathAbs(A_pt - X_pt) * 10 / 100;
   AB_20pc = MathAbs(B_pt - A_pt) * 20 / 100;
   ABdiv8 = MathAbs(A_pt - B_pt) / 8;

   align = WindowBarsPerChart() * 10 / 100;
      
   if (X_pt < A_pt){
      ME = MathMax(XA_10pc, AB_20pc);
      ObjectCreate("XABC_PSZ", OBJ_TREND, 0, A_dt, A_pt-ABdiv8, Time[0], A_pt-ABdiv8);
      ObjectCreate("XABC_PSZ_Label", OBJ_TEXT, 0, Time[0]+Period()*60*align, A_pt-ABdiv8);
      ObjectCreate("XABC_PBZ", OBJ_TREND, 0, B_dt, B_pt+ABdiv8, Time[0], B_pt+ABdiv8);
      ObjectCreate("XABC_PBZ_Label", OBJ_TEXT, 0, Time[0]+Period()*60*align, B_pt+ABdiv8);
      ObjectSetText("XABC_PSZ_Label", "Primary Sell Zone @"+DoubleToStr(A_pt-ABdiv8, Digits), 8, XABC_font ,XABC_ME_line_color);
      ObjectSetText("XABC_PBZ_Label", "Primary Buy Zone @"+DoubleToStr(B_pt+ABdiv8, Digits), 8, XABC_font ,XABC_ME_line_color);
      pop_XABC_signals(X_pt, A_pt, A_bar, B_pt, B_bar, C_pt, C_bar, A_pt+ME, B_pt-ME, B_pt+ABdiv8, A_pt-ABdiv8, total_XABC_swing_pt);
   } else {
      ME = -MathMax(XA_10pc, AB_20pc);
      ObjectCreate("XABC_PBZ", OBJ_TREND, 0, A_dt, A_pt+ABdiv8, Time[0], A_pt+ABdiv8);
      ObjectCreate("XABC_PBZ_Label", OBJ_TEXT, 0, Time[0]+Period()*60*align, A_pt+ABdiv8);
      ObjectCreate("XABC_PSZ", OBJ_TREND, 0, B_dt, B_pt-ABdiv8, Time[0], B_pt-ABdiv8);
      ObjectCreate("XABC_PSZ_Label", OBJ_TEXT, 0, Time[0]+Period()*60*align, B_pt-ABdiv8);
      ObjectSetText("XABC_PSZ_Label", "Primary Sell Zone @"+DoubleToStr(B_pt-ABdiv8, Digits), 8, XABC_font ,XABC_ME_line_color);
      ObjectSetText("XABC_PBZ_Label", "Primary Buy Zone @"+DoubleToStr(A_pt+ABdiv8, Digits), 8, XABC_font ,XABC_ME_line_color);
      pop_XABC_signals(X_pt, A_pt, A_bar, B_pt, B_bar, C_pt, C_bar, B_pt-ME, A_pt+ME, A_pt+ABdiv8, B_pt-ABdiv8, total_XABC_swing_pt);
   }
   
   ObjectCreate("XABC_A", OBJ_TREND, 0, A_dt, A_pt, Time[0], A_pt);   
   ObjectCreate("XABC_A_Label", OBJ_TEXT, 0, Time[0]+Period()*60*align, A_pt);
   ObjectSetText("XABC_A_Label", "A Boundary @"+DoubleToStr(A_pt, Digits), 8, XABC_font ,XABC_ME_line_color);

   ObjectCreate("XABC_A_ME", OBJ_TREND, 0, A_dt, A_pt+ME, Time[0], A_pt+ME);
   ObjectCreate("XABC_A_ME_Label", OBJ_TEXT, 0, Time[0]+Period()*60*align, A_pt+ME);
   ObjectSetText("XABC_A_ME_Label", "Maximum Extension @"+DoubleToStr(A_pt+ME, Digits), 8, XABC_font ,XABC_ME_line_color);

   ObjectCreate("XABC_B", OBJ_TREND, 0, B_dt, B_pt, Time[0], B_pt);
   ObjectCreate("XABC_B_Label", OBJ_TEXT, 0, Time[0]+Period()*60*align, B_pt);
   ObjectSetText("XABC_B_Label", "B Boundary @"+DoubleToStr(B_pt, Digits), 8, XABC_font ,XABC_ME_line_color);

   ObjectCreate("XABC_B_ME", OBJ_TREND, 0, B_dt, B_pt-ME, Time[0], B_pt-ME);
   ObjectCreate("XABC_B_ME_Label", OBJ_TEXT, 0, Time[0]+Period()*60*align, B_pt-ME);
   ObjectSetText("XABC_B_ME_Label", "Maximum Extension @"+DoubleToStr(B_pt-ME, Digits), 8, XABC_font ,XABC_ME_line_color);

   ObjectSet("XABC_PSZ", OBJPROP_COLOR, XABC_ME_line_color);
   ObjectSet("XABC_PBZ", OBJPROP_COLOR, XABC_ME_line_color);
   ObjectSet("XABC_A", OBJPROP_COLOR, XABC_ME_line_color);
   ObjectSet("XABC_B", OBJPROP_COLOR, XABC_ME_line_color);
   ObjectSet("XABC_A_ME", OBJPROP_COLOR, XABC_ME_line_color);
   ObjectSet("XABC_B_ME", OBJPROP_COLOR, XABC_ME_line_color);

   ObjectSet("XABC_PSZ", OBJPROP_STYLE, STYLE_DOT);
   ObjectSet("XABC_PBZ", OBJPROP_STYLE, STYLE_DOT);
   ObjectSet("XABC_A", OBJPROP_STYLE, STYLE_DOT);
   ObjectSet("XABC_B", OBJPROP_STYLE, STYLE_DOT);
   ObjectSet("XABC_A_ME", OBJPROP_STYLE, STYLE_DOT);
   ObjectSet("XABC_B_ME", OBJPROP_STYLE, STYLE_DOT);
}

void pop_XABC_signals(double X_pt, double A_pt, int A_pt_bar, double B_pt, int B_pt_bar, double C_pt, int C_pt_bar,
   double upper_me, double lower_me, double pbz, double psz, int count){
   double XA_height, AB_height;

   XA_height = MathAbs(X_pt - A_pt);
   AB_height = MathAbs(A_pt - B_pt);
   
   if (AB_height > XA_height){
      signals[XABC_A] = 0;
      signals[XABC_B] = 0;
      signals[XABC_C] = 0;
      signals[XABC_A_BAR] = 0;
      signals[XABC_B_BAR] = 0;
      signals[XABC_C_BAR] = 0;
      signals[XABC_UPPER_ME] = 0;      
      signals[XABC_LOWER_ME] = 0;      
      signals[XABC_PBZ] = 0;           
      signals[XABC_PSZ] = 0;           
      signals[XABC_SWING_COUNT] = 0;   
   } else {
      signals[XABC_A] = A_pt;
      signals[XABC_B] = B_pt;
      signals[XABC_C] = C_pt;
      signals[XABC_A_BAR] = A_pt_bar;
      signals[XABC_B_BAR] = B_pt_bar;
      signals[XABC_C_BAR] = C_pt_bar;
      signals[XABC_UPPER_ME] = upper_me;      
      signals[XABC_LOWER_ME] = lower_me;      
      signals[XABC_PBZ] = pbz;           
      signals[XABC_PSZ] = psz;           
      signals[XABC_SWING_COUNT] = count;   
   }
}

void clear_XABC_signals(){
   signals[XABC_A] = 0;
   signals[XABC_B] = 0;
   signals[XABC_C] = 0;
   signals[XABC_A_BAR] = 0;
   signals[XABC_B_BAR] = 0;
   signals[XABC_C_BAR] = 0;
   signals[XABC_UPPER_ME] = 0;      
   signals[XABC_LOWER_ME] = 0;      
   signals[XABC_PBZ] = 0;           
   signals[XABC_PSZ] = 0;           
   signals[XABC_SWING_COUNT] = 0;   
}

void catch_swing_pt(){
   double imp_mean, sw_pt_1, sw_pt_2;
   int count, i;
   
   imp_mean = imean[0];
   count = 0; sw_pt_1 = 0; sw_pt_2 = 0; i = 0;
   while((count <= 3 || MathAbs(sw_pt_1 - sw_pt_2) < imp_mean) && i <= Bars){
      if(dn_swing[i] > 0){
         if (sw_pt_1 == 0){
            sw_pt_1 = dn_swing[i];
            sw_pt_2 = dn_swing[i];
            add_swing_pt(sw_pt_1, Time[i]);
            count++;
         } else {
            sw_pt_2 = sw_pt_1;
            sw_pt_1 = dn_swing[i];
            add_swing_pt(sw_pt_1, Time[i]);
            count++;            
         }
      }
      i++;
   }
}

void catch_swing_pt_ex(){
   double imp_mean, sw_pt_1, sw_pt_2;
   int i, spt, count;
   datetime pt_1_dt, pt_2_dt;
   bool imp_mean_hit;
   
   spt = iBarShift(NULL, 0, XABC_spec_time);
   
   imp_mean = imean[spt];
   count = 0; sw_pt_1 = 0; sw_pt_2 = 0; i = 0; imp_mean_hit = false;
   
   while(!imp_mean_hit && i <= Bars){
      if(dn_swing[i] > 0){
         if (sw_pt_1 == 0){
            sw_pt_1 = dn_swing[i];
            sw_pt_2 = dn_swing[i];
            pt_1_dt = Time[i];
            pt_2_dt = Time[i];
            add_swing_pt(sw_pt_1, pt_1_dt);
            if (i > spt) count++;
         } else {
            sw_pt_2 = sw_pt_1;
            pt_2_dt = pt_1_dt;
            sw_pt_1 = dn_swing[i];
            pt_1_dt = Time[i];
            add_swing_pt(sw_pt_1, pt_1_dt);
            if (i > spt) count++;
         }
      }
      if (MathAbs(sw_pt_1 - sw_pt_2) >= imp_mean && pt_2_dt < XABC_spec_time) imp_mean_hit = true; // count > 3
      i++;
   }
}

void clear_label(){
   string strlabel;
   
   for (int i=0; i<=num_label; i++){
      strlabel = "XABC_label_" + i;
      ObjectDelete(strlabel);
   }
   ObjectDelete("XABC_A");
   ObjectDelete("XABC_A_ME");
   ObjectDelete("XABC_B");
   ObjectDelete("XABC_B_ME");
   ObjectDelete("XABC_PBZ");
   ObjectDelete("XABC_PSZ");

   ObjectDelete("XABC_A_Label");
   ObjectDelete("XABC_B_Label");
   ObjectDelete("XABC_A_ME_Label");
   ObjectDelete("XABC_B_ME_Label");
   ObjectDelete("XABC_PBZ_Label");
   ObjectDelete("XABC_PSZ_Label");
}

int add_swing_pt(double pt, datetime dt){
   int rst;
   
   total_swing_pt++;
   rst = ArrayResize(sDateTime, total_swing_pt);
   if (rst == -1) return (-1);
   rst = ArrayResize(swing_point, total_swing_pt);
   if (rst == -1) return (-1);
   sDateTime[total_swing_pt - 1] = dt;
   swing_point[total_swing_pt - 1] = pt;  
   return (0);
}

int clear_swing_pts(){
   int rst;
   
   total_swing_pt = 0;
   rst = ArrayResize(sDateTime, 0);
   if (rst == -1) return (-1);
   rst = ArrayResize(swing_point, 0);
   if (rst == -1) return (-1);
   return (0);
}

int add_XABC_swing_pt(double pt, datetime dt){
   int rst;
   
   total_XABC_swing_pt++;
   rst = ArrayResize(XABC_DateTime, total_XABC_swing_pt);
   if (rst == -1) return (-1);
   rst = ArrayResize(XABC_swing_point, total_XABC_swing_pt);
   if (rst == -1) return (-1);
   XABC_DateTime[total_XABC_swing_pt - 1] = dt;
   XABC_swing_point[total_XABC_swing_pt - 1] = pt;  
   return (0);
}

int clear_XABC_swing_pts(){
   int rst;
   
   total_XABC_swing_pt = 0;
   rst = ArrayResize(XABC_DateTime, 0);
   if (rst == -1) return (-1);
   rst = ArrayResize(XABC_swing_point, 0);
   if (rst == -1) return (-1);
   return (0);
}   