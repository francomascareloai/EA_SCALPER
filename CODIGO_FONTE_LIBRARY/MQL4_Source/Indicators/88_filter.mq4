#property copyright "Mr. X"
#property link      "www.metaquotes.net"

#property indicator_separate_window
#property indicator_levelcolor DimGray
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_level1 25.0
#property indicator_level2 6.0
#property indicator_width1 2
#property indicator_width2 2

extern int        Len         = 15;
extern int        HistoryBars = 500;
extern double     UrovenSignal = 6.0;

extern int        TF1         = 0;
extern int        TF2         = 0;
extern bool       ModeHL      = TRUE;
extern bool       ModeOnline  = TRUE;
extern bool       ModeinFile  = FALSE;
extern bool       ModeHistory = FALSE;
extern bool       alert       = FALSE;
extern bool       sound       = FALSE;
extern bool       email       = FALSE;
extern bool       GV          = FALSE;


double UP[];
double DN[];
double Clos;
double Hig;
double Loww;
int i;
int j;
int Gi_172;
int G_shift_176;
int G_count_180;
double Highest;
double Lowest;
double Gd_200;
double Gd_208;
double Gd_216;
double Gd_224;
double ArrayClose[][240];
double ArrayHi[][240];
double ArrayLo[][240];
int G_timeframe_244;
int LatBarTime;
int Gi_252;
bool Gi_256;
int G_file_260;
bool Gi_264;

double SignUp[];
double SignDn[];

//==================================================================
//
//==================================================================
int init() 
{
   if (ModeinFile) FileDelete(Symbol() + "-SP-" + Period() + ".ini");
   if (TF2 == 0) TF2 = Period();
   HistoryBars = NormalizeDouble(HistoryBars / (TF2 / Period()), 0);
   SetIndexBuffer(0, UP);
   SetIndexBuffer(1, DN);

   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   
   SetIndexLabel(0, "UP");
   SetIndexLabel(1, "DN");
   
   ArrayResize(ArrayClose, HistoryBars + Len);
   ArrayResize(ArrayHi, HistoryBars + Len);
   ArrayResize(ArrayLo, HistoryBars + Len);
   G_timeframe_244 = Period();
   if (ModeinFile) G_file_260 = FileOpen(Symbol() + "-SP-" + Period() + ".ini", FILE_WRITE, " ");
   return (0);
}
//==================================================================

//==================================================================
void Signals() 
{
  RefreshRates();
  ChartRedraw();
}
//==================================================================
//
//==================================================================
int start() 
{
   int cnt;
   int Li_4;
   int Li_8;
//   int Li_12;
//   int str2time_16;
//   int str2int_20;
//   int str2int_24;
//   int file_28;
   if (ModeOnline || ModeinFile) 
   {
      if (iTime(NULL, TF2, 0) == LatBarTime) return (0);
      LatBarTime = iTime(NULL, TF2, 0);
      
      for (i = HistoryBars + Len; i > 0; i--) 
      {
         G_shift_176 = iBarShift(NULL, TF1, iTime(NULL, TF2, i));
         cnt = 0;
         for (j = G_shift_176; j > G_shift_176 - TF2; j--) 
         {
            ArrayClose[i][cnt] = iClose(NULL, TF1, j);
            if (ModeHL) 
               ArrayHi[i][cnt] = iHigh(NULL, TF1, j);
            else 
               ArrayHi[i][cnt] = MathMax(iOpen(NULL, TF1, j), iClose(NULL, TF1, j));
            
            if (ModeHL) 
               ArrayLo[i][cnt] = iLow(NULL, TF1, j);
            else 
               ArrayLo[i][cnt] = MathMin(iOpen(NULL, TF1, j), iClose(NULL, TF1, j));
            cnt++;
         }
      }
//-----------------------------------------------------------------------------------------------------------------------------+

//-----------------------------------------------------------------------------------------------------------------------------+
      Li_4 = NormalizeDouble((Bars - IndicatorCounted()) / (TF2 / Period()), 0);
      if (ModeOnline && (!IsTesting())) Li_4 = HistoryBars;
      for (i = Li_4; i > 0; i--) 
      {
         G_count_180 = 0;
         Gd_200 = 0;
         Gd_208 = 0;
         Highest = 0;
         Lowest = 1000000;
         while (G_count_180 < Len) 
         {
            Gi_172 = i + G_count_180;
            Gd_216 = 0;
            Gd_224 = 0;
            for (int k = 0; k < TF2; k++) 
            {
               if (ArrayClose[Gi_172][k] > 0.0)    Clos = ArrayClose[Gi_172][k];
               if (ArrayHi[Gi_172][k] > 0.0)       Hig = ArrayHi[Gi_172][k];
               if (ArrayLo[Gi_172][k] > 0.0)       Loww = ArrayLo[Gi_172][k];
               if (Hig > Highest) 
               {
                  Highest = Hig;
                  Gd_216 += Clos;
               }
               if (Loww < Lowest) 
               {
                  Lowest = Loww;
                  Gd_224 += Clos;
               }
            }
            if (Gd_216 > 0.0) Gd_200 += Gd_216;
            if (Gd_224 > 0.0) Gd_208 += Gd_224;
            G_count_180++;
         }
         if (Gd_200 > 0.0 && Gd_208 > 0.0) 
         {
            if (ModeinFile && Gi_252 != Time[i]) 
            {
               Gi_252 = Time[i];
               FileWrite(G_file_260, StringConcatenate(TimeToStr(Time[i]), ";", DoubleToStr(Gd_200 / Gd_208, 0), ";", DoubleToStr(Gd_208 / Gd_200, 0)));
               RefreshRates();
               ChartRedraw();
            }
            Li_8 = iBarShift(NULL, 0, iTime(NULL, TF2, i));
            for (int Li_36 = Li_8; Li_36 > Li_8 - TF2 / Period(); Li_36--) 
            {
               UP[Li_36] = Gd_200 / Gd_208;
               DN[Li_36] = Gd_208 / Gd_200;
               RefreshRates();
               ChartRedraw();
            }
         }
      }
   }
/*
   if (ModeHistory && (!ModeOnline) && (!ModeinFile) && Gi_256 == FALSE) {
      Gi_256 = TRUE;
      file_28 = FileOpen(Symbol() + "-SP-" + TF2 + ".ini", FILE_READ);
      while (!FileIsEnding(file_28)) {
         str2time_16 = StrToTime(FileReadString(file_28));
         str2int_20 = StrToInteger(FileReadString(file_28));
         str2int_24 = StrToInteger(FileReadString(file_28));
         Li_12 = iBarShift(NULL, 0, str2time_16, FALSE);
         for (int Li_40 = Li_12; Li_40 > Li_12 - TF2 / Period(); Li_40--) {
            UP[Li_40] = str2int_20;
            DN[Li_40] = str2int_24;
         }
      }
      FileClose(file_28);
   }
*/
   string Ls_44 = "";
   if (sound || alert || email || GV) 
   {
      if (UP[Li_36 + 1] > UrovenSignal && UP[Li_36 + 1] < 1000000.0) Ls_44 = Symbol() + " Signal " + WindowExpertName() + " BUY ( " + DoubleToStr(UP[Li_36 + 1], 1) + " )";
      if (DN[Li_36 + 1] > UrovenSignal && DN[Li_36 + 1] < 1000000.0) Ls_44 = Symbol() + " Signal " + WindowExpertName() + " SELL ( " + DoubleToStr(DN[Li_36 + 1], 1) + " )";
      if (GV && (!IsTesting())) GlobalVariableSet(Symbol() + WindowExpertName(), UP[Li_36 + 1] - (DN[Li_36 + 1]));
      if (Ls_44 != "" && (!IsTesting())) {
         if (sound && Gi_264 == FALSE) PlaySound("Wait.wav");
         if (alert && Gi_264 == FALSE) Alert(Ls_44);
         if (email && Gi_264 == FALSE) f0_0(Ls_44);
         Gi_264 = TRUE;
      } else Gi_264 = FALSE;
   }
   Signals();
   return (0);
}

//==================================================================
//
//==================================================================
void f0_0(string As_0) {
   if (IsTesting() == FALSE && IsOptimization() == FALSE && IsVisualMode() == FALSE) SendMail(WindowExpertName(), As_0);
}

//==================================================================
//
//==================================================================
void deinit() {
   if (ModeinFile) FileClose(G_file_260);
    ObjectsDeleteAll();
    ChartRedraw();
}
