#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 LimeGreen

extern bool ShowStrongReversalPatterns = TRUE;
extern bool ShowWeakReversalPatterns = FALSE;
extern bool ShowContinuationPatterns = FALSE;
extern bool ShowUnclassified = FALSE;
extern int ViewBars = 350;
extern bool SoundAlert = TRUE;
extern bool EmailAlert = FALSE;
extern color SellColor = Red;
extern color BuyColor = LimeGreen;
extern color TextColor = Yellow;
double g_ibuf_116[];
double g_ibuf_120[];
datetime g_time_124;
bool gi_128 = FALSE;
string gs_unused_132 = "10.";
string gs_unused_140 = "20";
int gi_148 = -1;
int gi_152 = 0;
int gi_156 = 1;
int gi_160 = 2;
int gi_164 = 3;
int gi_unused_168 = 39;
int gia_172[];
int gia_176[];
string gs_mymmobj_180 = "MyMMObj";
int gi_188 = 0;
int gi_192 = 1;
int gi_196 = 2;
int gi_200 = 3;
int gi_204 = 4;
int gi_208 = 5;
int gi_212 = 6;
int gi_216 = 7;
int gi_220 = 8;
int gi_224 = 9;
int gi_228 = 10;
int gi_232 = 11;
int gi_236 = 12;
int gi_240 = 13;
int gi_244 = 14;
int gi_248 = 15;
int gi_252 = 16;
int gi_256 = 17;
int gi_260 = 18;
int gi_264 = 19;
int gi_268 = 20;
int gi_272 = 21;
int gi_276 = 22;
int gi_280 = 23;
int gi_284 = 24;
int gi_288 = 25;
int gi_292 = 26;
int gi_296 = 27;
int gi_300 = 28;
int gi_304 = 29;
int gi_308 = 30;
int gi_312 = 31;
int gi_316 = 32;
int gi_320 = 33;
int gi_324 = 34;
int gi_328 = 35;
int gi_332 = 36;
int gi_336 = 37;
int gi_340 = 38;
string gsa_344[39];
int gia_348[39];
int gia_352[39];

int initDefine() {
   gsa_344[gi_188] = "Hammer";
   gia_352[gi_188] = 0;
   gsa_344[gi_304] = "Hanging";
   gia_352[gi_304] = 0;
   gsa_344[gi_192] = "Engulfing";
   gia_352[gi_192] = 0;
   gsa_344[gi_196] = "Morning star";
   gia_352[gi_196] = 0;
   gsa_344[gi_200] = "Evening star";
   gia_352[gi_200] = 0;
   gsa_344[gi_212] = "Dark-cloud cover";
   gia_352[gi_212] = 0;
   gsa_344[gi_216] = "Piercing pattern";
   gia_352[gi_216] = 0;
   gsa_344[gi_204] = "Shooting star";
   gia_352[gi_204] = 0;
   gsa_344[gi_208] = "Inverted hammer";
   gia_352[gi_208] = 0;
   gsa_344[gi_220] = "Harami";
   gia_352[gi_220] = 1;
   gsa_344[gi_224] = "Tweezers top";
   gia_352[gi_224] = 1;
   gsa_344[gi_228] = "Tweezers bottom";
   gia_352[gi_228] = 1;
   gsa_344[gi_232] = "Belt-hold line";
   gia_352[gi_232] = 1;
   gsa_344[gi_236] = "Upside gap two crow";
   gia_352[gi_236] = 1;
   gsa_344[gi_244] = "Three crows";
   gia_352[gi_244] = 1;
   gsa_344[gi_240] = "Mot-hold";
   gia_352[gi_240] = 2;
   gsa_344[gi_248] = "Counterattack lines";
   gia_352[gi_248] = 3;
   gsa_344[gi_252] = "Separating lines";
   gia_352[gi_252] = 2;
   gsa_344[gi_256] = "Gravestone doji";
   gia_352[gi_256] = 3;
   gsa_344[gi_260] = "Long-legged doji";
   gia_352[gi_260] = 3;
   gsa_344[gi_264] = "Bear doji";
   gia_352[gi_264] = 0;
   gsa_344[gi_324] = "Bull doji";
   gia_352[gi_324] = 0;
   gsa_344[gi_268] = "Tasuki gap";
   gia_352[gi_268] = 2;
   gsa_344[gi_272] = "Eide-by-side tuhite lines";
   gia_352[gi_272] = 2;
   gsa_344[gi_276] = "Three methods";
   gia_352[gi_276] = 2;
   gsa_344[gi_280] = "Three river bottom";
   gia_352[gi_280] = 3;
   gsa_344[gi_284] = "GAP Buy";
   gia_352[gi_284] = 3;
   gsa_344[gi_288] = "GAP Sell";
   gia_352[gi_288] = 3;
   gsa_344[gi_292] = "Three white soldiers";
   gia_352[gi_292] = 3;
   gsa_344[gi_296] = "Advance block";
   gia_352[gi_296] = 1;
   gsa_344[gi_300] = "Stalled pattern";
   gia_352[gi_300] = 3;
   gsa_344[gi_316] = "Doji Absorption";
   gia_352[gi_316] = 3;
   gsa_344[gi_320] = "Inverted hammer";
   gia_352[gi_320] = 3;
   gsa_344[gi_328] = "Upside Gap";
   gia_352[gi_328] = 2;
   gsa_344[gi_332] = "Downside Gap ";
   gia_352[gi_332] = 2;
   gsa_344[gi_336] = "Three-line strike";
   gia_352[gi_336] = 1;
   gsa_344[gi_340] = "on-neckline";
   gia_352[gi_340] = 1;
   gia_348[gi_316] = -150;
   gia_348[gi_188] = -100;
   gia_348[gi_304] = -100;
   gia_348[gi_192] = -100;
   gia_348[gi_196] = -100;
   gia_348[gi_200] = -100;
   gia_348[gi_212] = -100;
   gia_348[gi_216] = -100;
   gia_348[gi_204] = -90;
   gia_348[gi_208] = -90;
   gia_348[gi_220] = -80;
   gia_348[gi_224] = -50;
   gia_348[gi_228] = -50;
   gia_348[gi_232] = -80;
   gia_348[gi_236] = -80;
   gia_348[gi_244] = -90;
   gia_348[gi_240] = 0;
   gia_348[gi_248] = -80;
   gia_348[gi_252] = 0;
   gia_348[gi_256] = 0;
   gia_348[gi_260] = 0;
   gia_348[gi_264] = 0;
   gia_348[gi_324] = 0;
   gia_348[gi_268] = 0;
   gia_348[gi_272] = 0;
   gia_348[gi_276] = 0;
   gia_348[gi_280] = -90;
   gia_348[gi_284] = 100;
   gia_348[gi_288] = 100;
   gia_348[gi_292] = 100;
   gia_348[gi_296] = -80;
   gia_348[gi_300] = -80;
   return (0);
}

double GetUpperShadowHeight(int ai_0) {
   return (MathAbs(High[ai_0] - MathMax(Close[ai_0], Open[ai_0])));
}

double GetLowerShadowHeight(int ai_0) {
   return (MathAbs(MathMin(Close[ai_0], Open[ai_0]) - Low[ai_0]));
}

double GetBodyHeight(int ai_0) {
   return (MathAbs(Close[ai_0] - Open[ai_0]));
}

double GetAllHeight(int ai_0) {
   return (MathAbs(High[ai_0] - Low[ai_0]));
}

bool IsHigher(int ai_0) {
   if (High[ai_0] >= High[ai_0 + 1] + 2.0 * Point && High[ai_0] >= High[ai_0 + 2] + 2.0 * Point && High[ai_0] >= High[ai_0 + 3] + 2.0 * Point) return (TRUE);
   return (FALSE);
}

int IsBodyHigher(int ai_0) {
   if (Close[ai_0] > GetHighCloseOpen(ai_0 + 1) + 2.0 * Point && Close[ai_0] > GetHighCloseOpen(ai_0 + 2) + 2.0 * Point) return (1);
   return (0);
}

bool IsLower(int ai_0) {
   if (Low[ai_0] + 2.0 * Point < Low[ai_0 + 1] && Low[ai_0] + 2.0 * Point < Low[ai_0 + 2] && Low[ai_0] + 2.0 * Point < Low[ai_0 + 3]) return (TRUE);
   return (FALSE);
}

int IsYing(int ai_0) {
   if (Close[ai_0] < Open[ai_0]) return (1);
   return (0);
}

int IsYang(int ai_0) {
   if (Close[ai_0] > Open[ai_0]) return (1);
   return (0);
}

int RemoveObjects() {
   for (int li_0 = GetFirstMyObjectandText(); li_0 > -1; li_0 = GetFirstMyObjectandText()) ObjectDelete(ObjectName(li_0));
   return (0);
}

int GetFirstMyObjectandText() {
   for (int li_ret_0 = 0; li_ret_0 < ObjectsTotal(); li_ret_0++)
      if (StringFind(ObjectName(li_ret_0), "My", 0) >= 0) return (li_ret_0);
   return (-1);
}

double GetLowCloseOpen(int ai_0) {
   return (MathMin(Close[ai_0], Open[ai_0]));
}

double GetHighCloseOpen(int ai_0) {
   return (MathMax(Close[ai_0], Open[ai_0]));
}

string GetNextObjectName(string as_0) {
   return (as_0 + DoubleToStr(ObjectsTotal(), 0));
}

int testBodyHeight(int ai_0, int ai_4) {
   if (GetBodyHeight(ai_0) >= ai_4 * Point) return (1);
   return (0);
}

int AlmostSameBodyHeight(int ai_0, int ai_4) {
   if (MathAbs(GetBodyHeight(ai_0) - GetBodyHeight(ai_4)) < 5.0 * Point) return (1);
   return (0);
}

void CreateTextObject(int a_datetime_0, double a_price_4, color a_color_12, string a_text_16) {
   string l_name_24 = GetNextObjectName(gs_mymmobj_180);
   ObjectCreate(l_name_24, OBJ_TEXT, 0, a_datetime_0, a_price_4);
   ObjectSetText(l_name_24, a_text_16, 7);
   ObjectSet(l_name_24, OBJPROP_COLOR, a_color_12);
}

int AddintoCFArray(int ai_0, int ai_4) {
   int l_arr_size_8 = ArraySize(gia_172);
   ArrayResize(gia_172, l_arr_size_8 + 1);
   ArrayResize(gia_176, l_arr_size_8 + 1);
   gia_172[l_arr_size_8] = ai_0;
   gia_176[l_arr_size_8] = ai_4;
   return (0);
}

bool IsHammer(int ai_0) {
   if (GetAllHeight(ai_0) >= 10.0 * Point && GetUpperShadowHeight(ai_0) < GetAllHeight(ai_0) / 5.0 && GetLowerShadowHeight(ai_0) > 2.0 * GetBodyHeight(ai_0) && GetUpperShadowHeight(ai_0) > 2.0 * Point)
      if (IsHigher(ai_0)) return (TRUE);
   return (FALSE);
}

bool IsHammerCFM(int ai_0) {
   if (IsHammer(ai_0 + 1) && Open[ai_0] < GetLowCloseOpen(ai_0 + 2) && Close[ai_0] < GetLowCloseOpen(ai_0 + 2)) return (TRUE);
   return (FALSE);
}

bool IsHangMan(int ai_0) {
   if (GetAllHeight(ai_0) >= 10.0 * Point && GetUpperShadowHeight(ai_0) < GetAllHeight(ai_0) / 5.0 && GetLowerShadowHeight(ai_0) > 2.0 * GetBodyHeight(ai_0))
      if (IsHigher(ai_0)) return (TRUE);
   return (FALSE);
}

bool IsHangManCFM(int ai_0) {
   if (IsHangMan(ai_0 + 1) && Open[ai_0] > GetHighCloseOpen(ai_0 + 2) && Close[ai_0] > GetHighCloseOpen(ai_0 + 2)) return (TRUE);
   return (FALSE);
}

bool IsDoji(int ai_0) {
   if (MathAbs(Open[ai_0] - Close[ai_0]) < 3.0 * Point) return (TRUE);
   return (FALSE);
}

bool IsInvertHammer(int ai_0) {
   if (GetLowerShadowHeight(ai_0) < GetAllHeight(ai_0) / 5.0) {
      if (GetUpperShadowHeight(ai_0) > 2.0 * GetBodyHeight(ai_0))
         if (IsLower(ai_0)) return (TRUE);
   }
   return (FALSE);
}

bool IsInvertHammerCFM(int ai_unused_0) {
   return (FALSE);
}

bool IsThree_Crows(int ai_0) {
   if (IsHigher(ai_0 + 2) && High[ai_0 + 1] > High[ai_0 + 2] && IsYing(ai_0 + 2) && IsYing(ai_0 + 1) && IsYing(ai_0) && Open[ai_0 + 1] < Open[ai_0 + 2] && Close[ai_0 +
      1] < Close[ai_0 + 2] && Open[ai_0] < Open[ai_0 + 1] && Close[ai_0] < Close[ai_0 + 1]) return (TRUE);
   return (FALSE);
}

bool IsThree_White_Soldiers(int ai_0) {
   if (IsYang(ai_0 + 2) && IsYang(ai_0 + 1) && IsYang(ai_0 + 0) && Open[ai_0 + 1] > Open[ai_0 + 2] + GetBodyHeight(ai_0 + 2) / 2.0 && Open[ai_0 + 0] > Open[ai_0 + 1] +
      GetBodyHeight(ai_0 + 1) / 2.0 && Close[ai_0 + 1] > Close[ai_0 + 2] && Close[ai_0 + 0] > Close[ai_0 + 1] && High[ai_0 + 1] > High[ai_0 + 2] && High[ai_0 + 0] > High[ai_0 + 1] && testBodyHeight(ai_0 + 2, 20) && testBodyHeight(ai_0 + 1, 20) && testBodyHeight(ai_0 + 0, 20) && AlmostSameBodyHeight(ai_0 + 2, ai_0 + 1) && AlmostSameBodyHeight(ai_0 + 1, ai_0 + 0)) return (TRUE);
   return (FALSE);
}

int MMCFCondition(int ai_0) {
   int l_count_4;
   if (!IsDoji(ai_0 + 2)) {
      if (IsYang(ai_0 + 2) != IsYang(ai_0 + 1)) {
         if (MathMax(Close[ai_0 + 1], Open[ai_0 + 1]) > MathMax(Close[ai_0 + 2], Open[ai_0 + 2]) && MathMin(Close[ai_0 + 1], Open[ai_0 + 1]) < MathMin(Close[ai_0 + 2], Open[ai_0 +
            2])) {
            if (IsLower(ai_0 + 2) || IsLower(ai_0 + 1) && IsYang(ai_0 + 1)) AddintoCFArray(gi_192, gi_152);
            if (IsHigher(ai_0 + 2) || IsHigher(ai_0 + 1) && IsYing(ai_0 + 1)) AddintoCFArray(gi_192, gi_156);
            if (GetBodyHeight(ai_0 + 2) >= 15.0 * Point || IsLower(ai_0 + 1) && IsYang(ai_0 + 1)) AddintoCFArray(gi_192, gi_152);
            if (GetBodyHeight(ai_0 + 2) >= 15.0 * Point || IsHigher(ai_0 + 1) && IsYing(ai_0 + 1)) AddintoCFArray(gi_192, gi_156);
         }
      }
   }
   if (IsDoji(ai_0 + 2)) {
      if (MathMax(Close[ai_0 + 1], Open[ai_0 + 1]) > MathMax(Close[ai_0 + 2], Open[ai_0 + 2]) && MathMin(Close[ai_0 + 1], Open[ai_0 + 1]) < MathMin(Close[ai_0 + 2], Open[ai_0 +
         2])) {
         if (IsLower(ai_0 + 2) || IsLower(ai_0 + 1) && IsYang(ai_0 + 1)) AddintoCFArray(gi_316, gi_152);
         if (IsHigher(ai_0 + 2) || IsHigher(ai_0 + 1) && IsYing(ai_0 + 1)) AddintoCFArray(gi_316, gi_156);
      }
   }
   if (IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && IsHigher(ai_0 + 2) && GetBodyHeight(ai_0 + 2) >= 20.0 * Point && Open[ai_0 + 1] > High[ai_0 + 2] && Close[ai_0 + 1] < Open[ai_0 +
      2] + (Close[ai_0 + 2] - (Open[ai_0 + 2])) / 2.0 && GetLowCloseOpen(ai_0 + 1) > GetLowCloseOpen(ai_0 + 2)) AddintoCFArray(gi_212, gi_156);
   if (MathAbs(Close[ai_0 + 2] - (Open[ai_0 + 2])) > 5.0 * Point) {
      if (MathMax(Close[ai_0 + 1], Open[ai_0 + 1]) < MathMax(Close[ai_0 + 2], Open[ai_0 + 2]) && MathMin(Close[ai_0 + 1], Open[ai_0 + 1]) > MathMin(Close[ai_0 + 2], Open[ai_0 +
         2])) {
         if ((IsYang(ai_0 + 2) && IsHigher(ai_0 + 2)) || (IsYang(ai_0 + 2) && GetBodyHeight(ai_0 + 2) >= 15.0 * Point)) AddintoCFArray(gi_220, gi_156);
         if ((IsYing(ai_0 + 2) && IsLower(ai_0 + 2)) || (IsYing(ai_0 + 2) && GetBodyHeight(ai_0 + 2) >= 15.0 * Point)) AddintoCFArray(gi_220, gi_152);
      }
   }
   if (IsHammer(ai_0 + 1)) AddintoCFArray(gi_188, gi_160);
   if (IsHangMan(ai_0 + 1)) AddintoCFArray(gi_304, gi_164);
   if (IsHammerCFM(ai_0 + 1)) AddintoCFArray(gi_308, gi_152);
   if (IsHangManCFM(ai_0 + 1)) AddintoCFArray(gi_312, gi_156);
   if (IsInvertHammer(ai_0 + 1)) AddintoCFArray(gi_208, gi_160);
   if (IsInvertHammerCFM(ai_0 + 1)) AddintoCFArray(gi_320, gi_152);
   if (IsYang(ai_0 + 1) && IsYing(ai_0 + 2) && GetBodyHeight(ai_0 + 2) >= 10.0 * Point && Open[ai_0 + 1] < Low[ai_0 + 2] && Close[ai_0 + 1] > Close[ai_0 + 2] + (Open[ai_0 +
      2] - (Close[ai_0 + 2])) / 2.0 && GetHighCloseOpen(ai_0 + 1) < GetHighCloseOpen(ai_0 + 2)) AddintoCFArray(gi_216, gi_152);
   if (IsYing(ai_0 + 3) && IsYang(ai_0 + 1) && IsLower(ai_0 + 3)) {
      if (GetLowCloseOpen(ai_0 + 3) > GetHighCloseOpen(ai_0 + 2) || GetLowCloseOpen(ai_0 + 1) > GetHighCloseOpen(ai_0 + 2) && GetHighCloseOpen(ai_0 + 1) > GetLowCloseOpen(ai_0 +
         3) && GetBodyHeight(ai_0 + 2) <= 10.0 * Point && GetBodyHeight(ai_0 + 3) >= 8.0 * Point && GetBodyHeight(ai_0 + 1) >= 8.0 * Point) AddintoCFArray(gi_196, gi_152);
   }
   if (IsYang(ai_0 + 3) && IsYing(ai_0 + 1) && IsHigher(ai_0 + 3)) {
      if (GetHighCloseOpen(ai_0 + 3) < GetLowCloseOpen(ai_0 + 2) || GetHighCloseOpen(ai_0 + 1) < GetLowCloseOpen(ai_0 + 2) && GetLowCloseOpen(ai_0 + 1) < GetHighCloseOpen(ai_0 +
         3) && GetBodyHeight(ai_0 + 2) <= 10.0 * Point && GetBodyHeight(ai_0 + 3) > 8.0 * Point && GetBodyHeight(ai_0 + 1) > 8.0 * Point) AddintoCFArray(gi_200, gi_156);
   }
   if (GetLowerShadowHeight(ai_0 + 1) < GetAllHeight(ai_0 + 1) / 4.0) {
      if (GetUpperShadowHeight(ai_0 + 1) > 2.0 * GetBodyHeight(ai_0 + 1))
         if (IsHigher(ai_0 + 1) || IsBodyHigher(ai_0 + 1) || IsBodyHigher(ai_0 + 2)) AddintoCFArray(gi_204, gi_156);
   }
   if (GetAllHeight(ai_0 + 1) > 10.0 * Point && IsYang(ai_0 + 2) && IsHigher(ai_0 + 2) && High[ai_0 + 2] == High[ai_0 + 1] || High[ai_0 + 3] == High[ai_0 + 1] || High[ai_0 +
      4] == High[ai_0 + 1]) AddintoCFArray(gi_224, gi_156);
   if (GetAllHeight(ai_0 + 1) > 10.0 * Point && IsYing(ai_0 + 2) && IsLower(ai_0 + 2) && Low[ai_0 + 2] == Low[ai_0 + 1] || Low[ai_0 + 3] == Low[ai_0 + 1] || Low[ai_0 +
      4] == Low[ai_0 + 1]) AddintoCFArray(gi_228, gi_152);
   if (GetBodyHeight(ai_0 + 1) >= 20.0 * Point && IsYang(ai_0 + 1) && GetLowerShadowHeight(ai_0) == 0.0 && IsLower(ai_0 + 1) && GetBodyHeight(ai_0 + 1) > GetAllHeight(ai_0 +
      1) / 2.0) AddintoCFArray(gi_232, gi_152);
   if (GetBodyHeight(ai_0 + 1) >= 20.0 * Point && IsYing(ai_0 + 1) && GetUpperShadowHeight(ai_0) == 0.0 && IsHigher(ai_0 + 1) && GetBodyHeight(ai_0 + 1) > GetAllHeight(ai_0 +
      1) / 2.0) AddintoCFArray(gi_232, gi_156);
   if (IsHigher(ai_0 + 3) && IsYang(ai_0 + 3) && IsYing(ai_0 + 2) && IsYing(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] && Open[ai_0 + 1] > Open[ai_0 + 2] && Close[ai_0 +
      1] < Close[ai_0 + 2] && GetLowCloseOpen(ai_0 + 1) > GetHighCloseOpen(ai_0 + 3) && GetLowCloseOpen(ai_0 + 2) > GetHighCloseOpen(ai_0 + 3)) AddintoCFArray(gi_236, gi_156);
   if (IsYang(ai_0 + 5) && IsYing(ai_0 + 4) && IsYing(ai_0 + 3) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && Close[ai_0 + 4] > Close[ai_0 + 5] + 2.0 * Point && Open[ai_0 +
      3] > Open[ai_0 + 4] && Close[ai_0 + 3] < Close[ai_0 + 4] && Open[ai_0 + 2] > Open[ai_0 + 3] && Close[ai_0 + 2] < Close[ai_0 + 3] && Open[ai_0 + 1] > Close[ai_0 + 2] &&
      GetBodyHeight(ai_0 + 5) >= 20.0 * Point && GetBodyHeight(ai_0 + 1) >= 20.0 * Point) AddintoCFArray(gi_240, gi_152);
   if (IsThree_Crows(ai_0 + 1)) AddintoCFArray(gi_244, gi_156);
   if (GetBodyHeight(ai_0 + 1) > 5.0 * Point && GetBodyHeight(ai_0 + 2) > 5.0 * Point) {
      if (IsHigher(ai_0 + 1) && IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && MathAbs(GetLowCloseOpen(ai_0 + 2) - GetHighCloseOpen(ai_0 + 1)) <= 2.0 * Point) AddintoCFArray(gi_248, gi_156);
      if (IsLower(ai_0 + 1) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && MathAbs(GetLowCloseOpen(ai_0 + 1) - GetHighCloseOpen(ai_0 + 2)) <= 2.0 * Point) AddintoCFArray(gi_248, gi_152);
   }
   if (GetBodyHeight(ai_0 + 1) > 5.0 * Point && GetBodyHeight(ai_0 + 2) > 5.0 * Point) {
      if (IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && MathAbs(Open[ai_0 + 1] - (Open[ai_0 + 2])) <= 2.0 * Point) AddintoCFArray(gi_252, gi_156);
      if (IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && MathAbs(Open[ai_0 + 1] - (Open[ai_0 + 2])) <= 2.0 * Point) AddintoCFArray(gi_252, gi_152);
   }
   if (Close[ai_0 + 1] == Open[ai_0 + 1] && Close[ai_0 + 1] == Low[ai_0 + 1]) AddintoCFArray(gi_256, gi_156);
   if (MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 3.0 * Point && GetAllHeight(ai_0 + 1) > 20.0 * Point && High[ai_0 + 1] > High[ai_0 + 2]) AddintoCFArray(gi_260, gi_156);
   if (GetBodyHeight(ai_0 + 2) > 20.0 * Point && IsHigher(ai_0 + 2) || IsHigher(ai_0 + 1) && IsYang(ai_0 + 2) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 2.0 * Point &&
      MathAbs(High[ai_0 + 1] - MathMax(Close[ai_0 + 1], Open[ai_0 + 1])) > 2.0 * Point && MathAbs(Low[ai_0 + 1] - MathMin(Close[ai_0 + 1], Open[ai_0 + 1])) > 2.0 * Point) AddintoCFArray(gi_264, gi_156);
   if (GetBodyHeight(ai_0 + 2) > 20.0 * Point && IsLower(ai_0 + 2) || IsLower(ai_0 + 1) && IsYing(ai_0 + 2) && MathAbs(Close[ai_0 + 1] - (Open[ai_0 + 1])) < 2.0 * Point &&
      MathAbs(High[ai_0 + 1] - MathMax(Close[ai_0 + 1], Open[ai_0 + 1])) > 2.0 * Point && MathAbs(Low[ai_0 + 1] - MathMin(Close[ai_0 + 1], Open[ai_0 + 1])) > 2.0 * Point) AddintoCFArray(gi_324, gi_152);
   if (IsHigher(ai_0 + 3) || IsHigher(ai_0 + 2) && (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYing(ai_0 + 1)) && Low[ai_0 + 2] - (High[ai_0 + 3]) >= 2.0 * Point && Low[ai_0 +
      1] - (High[ai_0 + 3]) >= 2.0 * Point && (Open[ai_0 + 1] > Open[ai_0 + 2] && Open[ai_0 + 1] < Close[ai_0 + 2]) && Close[ai_0 + 1] < Close[ai_0 + 2] && MathAbs(GetBodyHeight(ai_0 +
      1) - GetBodyHeight(ai_0 + 2)) < 5.0 * Point) AddintoCFArray(gi_268, gi_152);
   if (IsLower(ai_0 + 3) || IsLower(ai_0 + 2) && (IsYing(ai_0 + 3) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1)) && Low[ai_0 + 3] - (High[ai_0 + 2]) >= 2.0 * Point && Low[ai_0 +
      3] - (High[ai_0 + 1]) >= 2.0 * Point && (Open[ai_0 + 1] > Close[ai_0 + 2] && Open[ai_0 + 1] < Open[ai_0 + 2]) && Close[ai_0 + 1] > Open[ai_0 + 2] && MathAbs(GetBodyHeight(ai_0 +
      1) - GetBodyHeight(ai_0 + 2)) < 5.0 * Point) AddintoCFArray(gi_268, gi_156);
   if (IsHigher(ai_0 + 3) && (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1)) && Low[ai_0 + 2] - (High[ai_0 + 3]) >= 2.0 * Point && MathAbs(Open[ai_0 + 1] > Open[ai_0 +
      2]) < 2.0 * Point && MathAbs(GetBodyHeight(ai_0 + 1) > GetBodyHeight(ai_0 + 2)) < 4.0 * Point) AddintoCFArray(gi_272, gi_152);
   if (IsLower(ai_0 + 3) && (IsYing(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1)) && Low[ai_0 + 2] - (High[ai_0 + 3]) >= 2.0 * Point && MathAbs(Open[ai_0 + 1] > Open[ai_0 +
      2]) < 2.0 * Point && MathAbs(GetBodyHeight(ai_0 + 1) > GetBodyHeight(ai_0 + 2)) < 4.0 * Point) AddintoCFArray(gi_272, gi_156);
   if (IsHigher(ai_0 + 5) && IsYang(ai_0 + 5) && IsYang(ai_0 + 1) && IsYing(ai_0 + 2) && IsYing(ai_0 + 3) && IsYing(ai_0 + 4) && GetBodyHeight(ai_0 + 5) > 20.0 * Point &&
      GetBodyHeight(ai_0 + 1) > 20.0 * Point && Open[ai_0 + 1] > Open[ai_0 + 5] && Close[ai_0 + 1] > Close[ai_0 + 5] && Open[ai_0 + 2] > Open[ai_0 + 5] && Close[ai_0 + 2] < Close[ai_0 + 5] && Open[ai_0 + 3] > Open[ai_0 + 5] && Close[ai_0 + 3] < Close[ai_0 + 5] && Open[ai_0 + 4] > Open[ai_0 + 5] && Close[ai_0 + 4] < Close[ai_0 + 5]) AddintoCFArray(gi_276, gi_152);
   if (IsLower(ai_0 + 5) && IsYing(ai_0 + 5) && IsYing(ai_0 + 1) && IsYang(ai_0 + 2) && IsYang(ai_0 + 3) && IsYang(ai_0 + 4) && GetBodyHeight(ai_0 + 5) > 20.0 * Point &&
      GetBodyHeight(ai_0 + 1) > 20.0 * Point && Open[ai_0 + 1] < Open[ai_0 + 5] && Close[ai_0 + 1] < Close[ai_0 + 5] && Open[ai_0 + 2] < Open[ai_0 + 5] && Close[ai_0 + 2] > Close[ai_0 + 5] && Open[ai_0 + 3] < Open[ai_0 + 5] && Close[ai_0 + 3] > Close[ai_0 + 5] && Open[ai_0 + 4] < Open[ai_0 + 5] && Close[ai_0 + 4] > Close[ai_0 + 5]) AddintoCFArray(gi_276, gi_156);
   if (IsYing(ai_0 + 3) && IsYing(ai_0 + 2) && IsLower(ai_0 + 3) && IsLower(ai_0 + 2) && GetBodyHeight(ai_0 + 3) > 20.0 * Point && GetAllHeight(ai_0 + 3) - GetBodyHeight(ai_0 +
      3) < 10.0 * Point && GetBodyHeight(ai_0 + 2) < 10.0 * Point && GetLowerShadowHeight(ai_0 + 2) > GetBodyHeight(ai_0 + 2) && GetUpperShadowHeight(ai_0 + 2) <= 2.0 * Point &&
      GetBodyHeight(ai_0 + 1) < 10.0 * Point && GetLowerShadowHeight(ai_0 + 1) <= 2.0 * Point && GetUpperShadowHeight(ai_0 + 1) <= 2.0 * Point) AddintoCFArray(gi_280, gi_152);
   if (IsYang(ai_0 + 1) && Low[ai_0 + 1] > Low[ai_0 + 2] + 2.0 * Point) {
      for (int li_8 = 4; li_8 <= 11; li_8++) {
         if (GetBodyHeight(ai_0 + 2 + li_8) > 40.0 * Point) {
            l_count_4 = 0;
            for (int li_12 = li_8 + 1; li_12 > 0; li_12--) {
               if (High[li_12 + ai_0 + 2] < Close[ai_0 + 2 + li_8] && Low[li_12 + ai_0 + 2] > Open[ai_0 + 2 + li_8]) continue;
               l_count_4++;
            }
            if (l_count_4 == 0) AddintoCFArray(gi_284, gi_152);
         }
      }
   }
   if (IsThree_White_Soldiers(ai_0 + 1)) AddintoCFArray(gi_292, gi_152);
   if (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] + GetBodyHeight(ai_0 + 3) / 2.0 && Open[ai_0 + 1] > Open[ai_0 + 2] +
      GetBodyHeight(ai_0 + 2) / 2.0 && Close[ai_0 + 2] > Close[ai_0 + 3] && Close[ai_0 + 1] > Close[ai_0 + 2] && High[ai_0 + 2] > High[ai_0 + 3] && High[ai_0 + 1] > High[ai_0 + 2] && testBodyHeight(ai_0 + 3, 20) && GetBodyHeight(ai_0 + 3) > GetBodyHeight(ai_0 + 2) && GetBodyHeight(ai_0 + 2) > GetBodyHeight(ai_0 + 1) && Open[0] < Open[1]) AddintoCFArray(gi_296, gi_156);
   if (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYang(ai_0 + 1) && Open[ai_0 + 2] > Open[ai_0 + 3] + GetBodyHeight(ai_0 + 3) / 2.0 && Open[ai_0 + 1] > Open[ai_0 + 2] +
      GetBodyHeight(ai_0 + 2) / 2.0 && Close[ai_0 + 2] > Close[ai_0 + 3] && Close[ai_0 + 1] > Close[ai_0 + 2] && High[ai_0 + 2] > High[ai_0 + 3] && High[ai_0 + 1] > High[ai_0 + 2] && testBodyHeight(ai_0 + 2, 20) && GetBodyHeight(ai_0 + 3) < 10.0 * Point && GetBodyHeight(ai_0 + 1) < 10.0 * Point && Open[0] < Open[1]) AddintoCFArray(gi_300, gi_156);
   if (IsYang(ai_0 + 3) && IsYang(ai_0 + 2) && IsYing(ai_0 + 1) && IsHigher(ai_0 + 3) && Low[ai_0 + 2] > High[ai_0 + 3] + 2.0 * Point && Open[ai_0 + 1] > Open[ai_0 +
      2] && Open[ai_0 + 1] < Close[ai_0 + 2] && Close[ai_0 + 1] > Open[ai_0 + 3] + (Close[ai_0 + 1]) < Close[ai_0 + 3]) AddintoCFArray(gi_328, gi_152);
   if (IsYing(ai_0 + 3) && IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && IsLower(ai_0 + 3) && High[ai_0 + 2] < Low[ai_0 + 3] - 2.0 * Point && Open[ai_0 + 1] > Close[ai_0 +
      2] && Open[ai_0 + 1] < Open[ai_0 + 2] && Close[ai_0 + 1] > Close[ai_0 + 3] + (Close[ai_0 + 1]) < Open[ai_0 + 3]) AddintoCFArray(gi_332, gi_156);
   if (IsYang(ai_0 + 1) && IsThree_Crows(ai_0 + 2) && High[ai_0 + 1] > iHighest(NULL, 0, MODE_HIGH, 3, 2) && Low[ai_0 + 1] < iLowest(NULL, 0, MODE_LOW, 3, 2)) AddintoCFArray(gi_336, gi_156);
   if (IsYing(ai_0 + 1) && IsThree_White_Soldiers(ai_0 + 2) && High[ai_0 + 1] > iHighest(NULL, 0, MODE_HIGH, 3, 2) && Low[ai_0 + 1] < iLowest(NULL, 0, MODE_LOW, 3, 2)) AddintoCFArray(gi_336, gi_152);
   if (IsYing(ai_0 + 2) && IsYang(ai_0 + 1) && testBodyHeight(ai_0 + 1, 20) && testBodyHeight(ai_0 + 2, 20) && Close[ai_0 + 1] < Open[ai_0 + 2] - (Open[ai_0 + 2] - (Close[ai_0 +
      2])) / 2.0 && Open[ai_0 + 1] < GetLowCloseOpen(ai_0 + 2)) AddintoCFArray(gi_340, gi_156);
   return (gi_148);
}

int init() {
   gi_128 = TRUE;
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(0, 226);
   SetIndexBuffer(0, g_ibuf_120);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(1, 225);
   SetIndexBuffer(1, g_ibuf_116);
   SetIndexEmptyValue(0, 0.0);
   SetIndexEmptyValue(1, 0.0);
   initDefine();
   return (0);
}

int deinit() {
   RemoveObjects();
   return (0);
}

int start() {
   RemoveObjects();
   if (gi_128 == FALSE) return (0);
   for (int l_count_0 = 0; l_count_0 <= ViewBars; l_count_0++) getCFResult(l_count_0);
   return (0);
}

int getCFResult(int ai_0) {
   int li_4;
   double ld_8;
   string ls_16;
   int li_ret_24 = gi_148;
   int l_arr_size_28 = 0;
   ArrayResize(gia_172, 0);
   ArrayResize(gia_176, 0);
   MMCFCondition(ai_0);
   l_arr_size_28 = ArraySize(gia_172);
   for (int l_index_32 = 0; l_index_32 < l_arr_size_28; l_index_32++) {
      li_ret_24 = gia_176[l_index_32];
      li_4 = gia_172[l_index_32];
      if (l_index_32 == 0) ld_8 = 15.0 * Point;
      else ld_8 = 15.0 * Point + l_index_32 * 8;
      if (li_ret_24 == gi_164 || li_ret_24 == gi_156 && (ShowStrongReversalPatterns == TRUE && gia_352[li_4] == 0) || (ShowWeakReversalPatterns == TRUE && gia_352[li_4] == 1) ||
         (ShowContinuationPatterns == TRUE && gia_352[li_4] == 2) || (ShowUnclassified == TRUE && gia_352[li_4] == 3)) {
         g_ibuf_120[ai_0 + 1] = High[ai_0 + 1] + 8.0 * Point;
         CreateTextObject(Time[ai_0 + 1], High[ai_0 + 1] + ld_8, TextColor, gsa_344[li_4]);
         ls_16 = gsa_344[li_4];
      }
      if (li_ret_24 == gi_160 || li_ret_24 == gi_152 && (ShowStrongReversalPatterns == TRUE && gia_352[li_4] == 0) || (ShowWeakReversalPatterns == TRUE && gia_352[li_4] == 1) ||
         (ShowContinuationPatterns == TRUE && gia_352[li_4] == 2) || (ShowUnclassified == TRUE && gia_352[li_4] == 3)) {
         g_ibuf_116[ai_0 + 1] = Low[ai_0 + 1] - 8.0 * Point;
         CreateTextObject(Time[ai_0 + 1], Low[ai_0 + 1] - ld_8, TextColor, gsa_344[li_4]);
         ls_16 = gsa_344[li_4];
      }
   }
   if (li_ret_24 != gi_148 && ai_0 < 1) {
      if (g_time_124 != Time[0]) {
         Print(TimeToStr(Time[0]), Period(), ls_16, " in ", Symbol());
         if (EmailAlert) SendMail(Period() + ls_16 + " in " + Symbol(), "");
         if (SoundAlert) PlaySound("alert2.wav");
         g_time_124 = Time[0];
      }
   }
   return (li_ret_24);
}
