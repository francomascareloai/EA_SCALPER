// -------------------------------------------------------------------------------- //
// Since I've started coding a few indicators/experts I was asked about donations.  //
//                                                                                  //
// Yes, of course they're greatly appreciated. You may donate to me via Paypal:     //
//                                                                                  //
//                              paypal@webtemp.org                                  //
//                                                                                  //
// It's mainly for motivation. ;-) Do it if you find the stuff useful!              //
// -------------------------------------------------------------------------------- //

#property copyright "mail@webtemp.org"
#property link      "mail@webtemp.org"

#property indicator_chart_window

extern int    CustomPeriod    = 0;        // In Minutes: 1, 5, 15, 30, 60, 240, 1440
extern int    MaxBars         = 500;      // Bars to be processed (to save CPU time)
extern double MinFactor       = 2;        // Minimum multiple of previous bar to cause a line
extern bool   Mail            = false;
extern string SoundFile       = "alert.wav";
extern color  ColLineLong     = Lime;
extern color  ColLineShort    = Red;
extern color  ColZoneLong     = Green;
extern color  ColZoneShort    = Maroon;
extern color  ColZoneLongOld  = 0x004000;
extern color  ColZoneShortOld = 0x000040;

int MaxLines = 2000;
double L[2000], S[2000];
double LM[2000], SM[2000];
datetime LT[2000], ST[2000];
int Trend;
double RealPoint;
string PeriodNice;

int init() {
  for(int i = 0; i < MaxLines; i++) {
    L[i] = 0;
    S[i] = 0;
    LM[i] = 0;
    SM[i] = 0;
  }
  Trend = 0;
  RealPoint = GetRealPoint();
  PeriodNice = GetPeriodNice(CustomPeriod);
  return(0);
}

int deinit() {
  for(int j = 0; j < MaxLines; j++) {
    ObjectDelete("ZS"+j+PeriodNice);
    ObjectDelete("ZSA"+j+PeriodNice);
    ObjectDelete("ZSB"+j+PeriodNice);
    ObjectDelete("ZL"+j+PeriodNice);
    ObjectDelete("ZLA"+j+PeriodNice);
    ObjectDelete("ZLB"+j+PeriodNice);
  }
  for(j = 0; j < Trend; j++) ObjectDelete("ZR"+j+PeriodNice);
  return(0);
}

double GetRealPoint() {
  switch (Digits) {
    case 3: return(0.01);
    case 5: return(0.0001);
  }
  return(Point);
}

string GetPeriodNice(int s) {
  if (s == 0) s = Period();
  if (s % 60 > 0) return("M"+s);
  s /= 60;
  if (s % 24 > 0) return("H"+s);
  s /= 24;
  if (s % 7 > 0) return("D"+s);
  return("W"+s);
}

double Ti(int s) {
  return(iTime(NULL, CustomPeriod, s));
}

double Op(int s) {
  return(iOpen(NULL, CustomPeriod, s));
}

double Cl(int s) {
  return(iClose(NULL, CustomPeriod, s));
}

string GetTimeDiffNice(int t) {
  t = Time[0] - t;
  if (t < 120) return(t+" seconds ago");
  t /= 60;
  if (t < 120) return(t+" minutes ago");
  t /= 60;
  if (t < 48) return(t+" hours ago");
  t /= 24;
  return(t+" days ago");
}

void DisplayAlert(string s) {
  if (SoundFile != "") PlaySound(SoundFile);
  Alert(s);
  Comment(TimeToStr(TimeCurrent(), TIME_MINUTES)+" "+s);
  if (Mail) SendMail(s, s);
}

int start() {
  static double old = 0;
  static datetime latestWicking = 0;
  if ((Time[0] > latestWicking) && (old > 0)) for(int j = 0; j < MaxLines; j++) {
    if ((S[j] > 0) && (Close[0] > S[j]) && (old <= S[j])) {
      DisplayAlert("Look for a "+Symbol()+" SHORT on "+PeriodNice+" (MightyZone)");
      latestWicking = Time[0];
      break;
    }
    if ((L[j] > 0) && (Close[0] < L[j]) && (old >= L[j])) {
      DisplayAlert("Look for a "+Symbol()+" LONG on "+PeriodNice+" (MightyZone)");
      latestWicking = Time[0];
      break;
    }
  }
  old = Close[0];

  static datetime latest = 0;
  int changed = Bars - IndicatorCounted();
  if (changed < 2) return(0);
  
  for(int i = MathMin(changed-1, MaxBars); i > 0; i--) {
    if (latest >= Ti(i)) continue;
    latest = Ti(i);

    for(j = 0; j < MaxLines; j++) {
      if ((L[j] > 0) && (Cl(i) <= LM[j])) {
        string n = "ZR"+Trend+PeriodNice;
        ObjectCreate(n, OBJ_RECTANGLE, 0, 0, 0);
        ObjectSet(n, OBJPROP_TIME1, LT[j]);
        ObjectSet(n, OBJPROP_PRICE1, L[j]);
        ObjectSet(n, OBJPROP_TIME2, Ti(i));
        ObjectSet(n, OBJPROP_PRICE2, LM[j]);
        ObjectSet(n, OBJPROP_COLOR, ColZoneLongOld);
        ObjectSet(n, OBJPROP_BACK, true);
        L[j] = 0;
        Trend++;
      }
      if ((S[j] > 0) && (Cl(i) >= SM[j])) {
        n = "ZR"+Trend+PeriodNice;
        ObjectCreate(n, OBJ_RECTANGLE, 0, 0, 0);
        ObjectSet(n, OBJPROP_TIME1, ST[j]);
        ObjectSet(n, OBJPROP_PRICE1, S[j]);
        ObjectSet(n, OBJPROP_TIME2, Ti(i));
        ObjectSet(n, OBJPROP_PRICE2, SM[j]);
        ObjectSet(n, OBJPROP_COLOR, ColZoneShortOld);
        ObjectSet(n, OBJPROP_BACK, true);
        S[j] = 0;
        Trend++;
      }
    }

    double r = MathAbs(Cl(i+1) - Cl(i+2)) * MinFactor;
    double h = (Cl(i+1) + Cl(i)) / 2;
    if (Cl(i) - Cl(i+1) > r) {
      for(j = 0; j < MaxLines; j++) {
        if (L[j] == h) break;
        if (L[j] != 0) continue;
        L[j] = h;
        LM[j] = MathMax(Op(i+1), Cl(i+1));
        LT[j] = Ti(i);
        break;
      }
    }
    if (Cl(i) - Cl(i+1) < -r) {
      for(j = 0; j < MaxLines; j++) {
        if (S[j] == h) break;
        if (S[j] != 0) continue;
        S[j] = h;
        SM[j] = MathMin(Op(i+1), Cl(i+1));
        ST[j] = Ti(i);
        break;
      }
    }
  }

  for(j = 0; j < MaxLines; j++) {
    n = "ZL"+j+PeriodNice;
    string na = "ZLA"+j+PeriodNice;
    string nb = "ZLB"+j+PeriodNice;

    if (L[j] == 0) {
      ObjectDelete(n);
      ObjectDelete(na);
      ObjectDelete(nb);
      continue;
    } 

    ObjectCreate(n, OBJ_RECTANGLE, 0, 0, 0);
    ObjectSet(n, OBJPROP_COLOR, ColZoneLong);
    ObjectSet(n, OBJPROP_TIME1, LT[j]);
    ObjectSet(n, OBJPROP_PRICE1, L[j]);
    ObjectSet(n, OBJPROP_TIME2, D'01.01.2019');
    ObjectSet(n, OBJPROP_PRICE2, LM[j]);
    
    ObjectCreate(na, OBJ_FIBO, 0, 0, 0);
    ObjectSet(na, OBJPROP_FIBOLEVELS, 1);
    ObjectSet(na, OBJPROP_LEVELCOLOR, ColLineLong);
    ObjectSet(na, OBJPROP_TIME1, LT[j]);
    ObjectSet(na, OBJPROP_PRICE1, LM[j]);
    ObjectSet(na, OBJPROP_TIME2, Time[0]);
    ObjectSet(na, OBJPROP_PRICE2, LM[j]);
    ObjectSet(na, OBJPROP_BACK, true);
    ObjectSetFiboDescription(na, 0, PeriodNice+" "+GetTimeDiffNice(LT[j])+" "+DoubleToStr(LM[j], Digits));
    
    ObjectCreate(nb, OBJ_FIBO, 0, 0, 0);
    ObjectSet(nb, OBJPROP_FIBOLEVELS, 1);
    ObjectSet(nb, OBJPROP_LEVELCOLOR, ColLineLong);
    ObjectSet(nb, OBJPROP_TIME1, LT[j]);
    ObjectSet(nb, OBJPROP_PRICE1, L[j]);
    ObjectSet(nb, OBJPROP_TIME2, Time[0]);
    ObjectSet(nb, OBJPROP_PRICE2, L[j]);
    ObjectSet(nb, OBJPROP_BACK, true);
    ObjectSetFiboDescription(nb, 0, DoubleToStr((L[j]-LM[j])/RealPoint, 0)+" pips above: "+DoubleToStr(L[j], Digits));
  }

  for(j = 0; j < MaxLines; j++) {
    n = "ZS"+j+PeriodNice;
    na = "ZSA"+j+PeriodNice;
    nb = "ZSB"+j+PeriodNice;

    if (S[j] == 0) {
      ObjectDelete(n);
      ObjectDelete(na);
      ObjectDelete(nb);
      continue;
    } 

    ObjectCreate(n, OBJ_RECTANGLE, 0, 0, 0);
    ObjectSet(n, OBJPROP_COLOR, ColZoneShort);
    ObjectSet(n, OBJPROP_TIME1, ST[j]);
    ObjectSet(n, OBJPROP_PRICE1, S[j]);
    ObjectSet(n, OBJPROP_TIME2, D'01.01.2019');
    ObjectSet(n, OBJPROP_PRICE2, SM[j]);

    ObjectCreate(na, OBJ_FIBO, 0, 0, 0);
    ObjectSet(na, OBJPROP_FIBOLEVELS, 1);
    ObjectSet(na, OBJPROP_LEVELCOLOR, ColLineShort);
    ObjectSet(na, OBJPROP_TIME1, ST[j]);
    ObjectSet(na, OBJPROP_PRICE1, SM[j]);
    ObjectSet(na, OBJPROP_TIME2, Time[0]);
    ObjectSet(na, OBJPROP_PRICE2, SM[j]);
    ObjectSet(na, OBJPROP_BACK, true);
    ObjectSetFiboDescription(na, 0, PeriodNice+" "+GetTimeDiffNice(ST[j])+" "+DoubleToStr(SM[j], Digits));

    ObjectCreate(nb, OBJ_FIBO, 0, 0, 0);
    ObjectSet(nb, OBJPROP_FIBOLEVELS, 1);
    ObjectSet(nb, OBJPROP_LEVELCOLOR, ColLineShort);
    ObjectSet(nb, OBJPROP_TIME1, ST[j]);
    ObjectSet(nb, OBJPROP_PRICE1, S[j]);
    ObjectSet(nb, OBJPROP_TIME2, Time[0]);
    ObjectSet(nb, OBJPROP_PRICE2, S[j]);
    ObjectSet(nb, OBJPROP_BACK, true);
    ObjectSetFiboDescription(nb, 0, DoubleToStr((SM[j]-S[j])/RealPoint, 0)+" pips below: "+DoubleToStr(S[j], Digits));
  }

  return(0);
}

