//+------------------------------------------------------------------+
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property indicator_chart_window

extern bool SHOW_H1=true;
extern bool SHOW_H4=true;
extern bool SHOW_D1=true;
extern bool SHOW_W1=true;
extern int Supply_Demand_Area=10;
extern color SupportColor = DodgerBlue;
extern color ResistanceColor = OrangeRed;
extern color P60R=Indigo;
extern color P60S=Indigo;
extern color P240R=Indigo;
extern color P240S=Indigo;
extern color P1440R=Indigo;
extern color P1440S=Indigo;
extern color P10080R=Indigo;
extern color P10080S=Indigo;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   if(ObjectFind("H1 RESISTANCE")==0) ObjectDelete("H1 RESISTANCE");
   if(ObjectFind("H4 RESISTANCE")==0) ObjectDelete("H4 RESISTANCE");
   if(ObjectFind("D1 RESISTANCE")==0) ObjectDelete("D1 RESISTANCE");
   if(ObjectFind("W1 RESISTANCE")==0) ObjectDelete("W1 RESISTANCE");
   if(ObjectFind("H1 SUPPORT")==0) ObjectDelete("H1 SUPPORT");
   if(ObjectFind("H4 SUPPORT")==0) ObjectDelete("H4 SUPPORT");
   if(ObjectFind("D1 SUPPORT")==0) ObjectDelete("D1 SUPPORT");
   if(ObjectFind("W1 SUPPORT")==0) ObjectDelete("W1 SUPPORT");
   if(ObjectFind("GIVONLY H1 RESISTANCE LINE")==0) ObjectDelete("GIVONLY H1 RESISTANCE LINE");
   if(ObjectFind("GIVONLY H4 RESISTANCE LINE")==0) ObjectDelete("GIVONLY H4 RESISTANCE LINE");
   if(ObjectFind("GIVONLY D1 RESISTANCE LINE")==0) ObjectDelete("GIVONLY D1 RESISTANCE LINE");
   if(ObjectFind("GIVONLY W1 RESISTANCE LINE")==0) ObjectDelete("GIVONLY W1 RESISTANCE LINE");
   if(ObjectFind("GIVONLY H1 SUPPORT LINE")==0) ObjectDelete("GIVONLY H1 SUPPORT LINE");
   if(ObjectFind("GIVONLY H4 SUPPORT LINE")==0) ObjectDelete("GIVONLY H4 SUPPORT LINE");
   if(ObjectFind("GIVONLY D1 SUPPORT LINE")==0) ObjectDelete("GIVONLY D1 SUPPORT LINE");
   if(ObjectFind("GIVONLY W1 SUPPORT LINE")==0) ObjectDelete("GIVONLY W1 SUPPORT LINE");
   if(ObjectFind("H1 SUPPLY AREA")==0) ObjectDelete("H1 SUPPLY AREA");
   if(ObjectFind("H4 SUPPLY AREA")==0) ObjectDelete("H4 SUPPLY AREA");
   if(ObjectFind("D1 SUPPLY AREA")==0) ObjectDelete("D1 SUPPLY AREA");
   if(ObjectFind("W1 SUPPLY AREA")==0) ObjectDelete("W1 SUPPLY AREA");
   if(ObjectFind("H1 DEMAND AREA")==0) ObjectDelete("H1 DEMAND AREA");
   if(ObjectFind("H4 DEMAND AREA")==0) ObjectDelete("H4 DEMAND AREA");
   if(ObjectFind("D1 DEMAND AREA")==0) ObjectDelete("D1 DEMAND AREA");
   if(ObjectFind("W1 DEMAND AREA")==0) ObjectDelete("W1 DEMAND AREA");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  { 
    if(prev_calculated==0 || (prev_calculated>0 && prev_calculated<rates_total)) {
      if(SHOW_H1) GAMBAR(60);
      if(SHOW_H4) GAMBAR(240);
      if(SHOW_D1) GAMBAR(1440);
      if(SHOW_W1) GAMBAR(10080);
      if(Supply_Demand_Area>0) {
        if(SHOW_H1)    SND(60);
        if(SHOW_H4)    SND(240);
        if(SHOW_D1)    SND(1440);
        if(SHOW_W1)    SND(10080);
      }
    }
    return(rates_total);
  }
//+------------------------------------------------------------------+
   void  SND(int period)
      {
         string name;
         name = StringConcatenate(TF(period)," SUPPLY AREA");
         double atas, bawah;
         atas = SNR(period,MODE_HIGH);
         bawah= atas-Supply_Demand_Area*Point;
         bool ada=false;
         if(   (SNR(period,MODE_HIGH)==SNR(60,MODE_HIGH) && period>60 && SHOW_H1)
            || (SNR(period,MODE_HIGH)==SNR(240,MODE_HIGH) && period>240 && SHOW_H4)
            || (SNR(period,MODE_HIGH)==SNR(1440,MODE_HIGH) && period>1440 && SHOW_D1)
            || (SNR(period,MODE_HIGH)==SNR(10080,MODE_HIGH) && period>10080 && SHOW_W1)
           )   ada=true;
         if(!ada) {
            ObjectCreate(name,OBJ_RECTANGLE,0,0,0);
            ObjectSet(name,OBJPROP_TIME1,Time[0]);
            ObjectSet(name,OBJPROP_TIME2,Time[Bars-1]);
            ObjectSet(name,OBJPROP_COLOR,ResistanceColor);
            ObjectSet(name,OBJPROP_PRICE1,atas);
            ObjectSet(name,OBJPROP_PRICE2,bawah);
            ObjectMove(name,0,Time[0],atas);
            ObjectMove(name,1,Time[Bars-1],bawah);
            }
         name = StringConcatenate(TF(period)," DEMAND AREA");
         bawah= SNR(period,MODE_LOW);
         atas = bawah+Supply_Demand_Area*Point;
         ada=false;
         if(   (SNR(period,MODE_LOW)==SNR(60,MODE_LOW) && period>60 && SHOW_H1)
            || (SNR(period,MODE_LOW)==SNR(240,MODE_LOW) && period>240 && SHOW_H4)
            || (SNR(period,MODE_LOW)==SNR(1440,MODE_LOW) && period>1440 && SHOW_D1)
            || (SNR(period,MODE_LOW)==SNR(10080,MODE_LOW) && period>10080 && SHOW_W1)
           )   ada=true;
         if(!ada) {
            ObjectCreate(name,OBJ_RECTANGLE,0,0,0);
            ObjectSet(name,OBJPROP_TIME1,Time[0]);
            ObjectSet(name,OBJPROP_TIME2,Time[Bars-1]);
            ObjectSet(name,OBJPROP_COLOR, SupportColor);
            ObjectSet(name,OBJPROP_PRICE1,bawah);
            ObjectSet(name,OBJPROP_PRICE2,atas);
            ObjectMove(name,0,Time[0],bawah);
            ObjectMove(name,1,Time[Bars-1],atas);
            }
       }     
//+------------------------------------------------------------------+
   void  GAMBAR(int period)
   {
      double ResistanceValue=SNR(period,MODE_HIGH);
      double SupportValue=SNR(period,MODE_LOW);

      color warna1, warna2;
      if(period==60)    {warna1=P60R;   warna2=P60S;}
      if(period==240)    {warna1=P240R;   warna2=P240S;}
      if(period==1440)    {warna1=P1440R;   warna2=P1440S;}
      if(period==10080)    {warna1=P10080R;   warna2=P10080S;}

      string name;
      name = StringConcatenate("GIVONLY ",TF(period)," RESISTANCE LINE");
      GARIS(name, ResistanceValue, warna1);
      name = StringConcatenate(TF(period)," RESISTANCE");
      TULIS(name, ResistanceValue, warna1);
   
      name = StringConcatenate("GIVONLY ",TF(period)," SUPPORT LINE");
      GARIS(name, SupportValue, warna2);
      name = StringConcatenate(TF(period)," SUPPORT");
      TULIS(name, SupportValue, warna2);
   }
//+------------------------------------------------------------------+
   double SNR(int period, int mode)
   {
      bool FindLow=false, FindHigh=false;
      double snr, PassedLow=999, PassedHigh=0, HIGHEST, LOWEST;
      int i=1;
      while(!FindLow || !FindHigh)
         {
            if(HIGH(period,i)>PassedHigh) PassedHigh = HIGH(period,i);
            if(LOW(period,i)<PassedLow)   PassedLow = LOW(period,i);
            PassedHigh = MathMax(PassedHigh, HIGH(period,0));
            PassedLow  = MathMin(PassedLow, LOW(period,0));

            if(!FindHigh && HIGH(period,i)>=HIGH(period,i-1) && HIGH(period,i)>=HIGH(period,i+1) && HIGH(period,i)>=PassedHigh)
               {
                  HIGHEST = HIGH(period,i);
                  FindHigh=true;
               }   
            if(!FindLow && LOW(period,i)<=LOW(period,i-1) && LOW(period,i)<=LOW(period,i+1) && LOW(period,i)<=PassedLow)
               {
                  LOWEST = LOW(period,i);
                  FindLow=true;
               }   
            i++;
         }
      if(mode==MODE_HIGH)  snr=HIGHEST;
      if(mode==MODE_LOW)   snr=LOWEST;
      return(snr);
   }
//+------------------------------------------------------------------+
   string TF(int period)
      {
         string tf;
         if(period==60)      tf="H1";
         if(period==240)     tf="H4";
         if(period==1440)    tf="D1";
         if(period==10080)   tf="W1";
         return(tf);
      }
//+------------------------------------------------------------------+
   double HIGH(int period, int shift)
      {
         double hi=iHigh(Symbol(), period, shift);
         return(hi);
      }   
//+------------------------------------------------------------------+
   double LOW(int period, int shift)
      {
         double lo=iLow(Symbol(), period, shift);
         return(lo);
      }   
//+------------------------------------------------------------------+
   void TULIS(string NamaTeks, double value, color warna)
      {
         string ValueTeks = StringConcatenate(NamaTeks," ",DoubleToStr(value,Digits));
         double Value=value;
         if(value<Bid)  Value=value+Supply_Demand_Area*Point;
         ObjectCreate(NamaTeks, OBJ_TEXT, 0, Time[35], Value);
         ObjectSetText(NamaTeks, StringSubstr(NamaTeks,0,4), 13, "Tahoma", warna);
         ObjectMove(NamaTeks, 0,  Time[35], Value);
      }
//+------------------------------------------------------------------+
   void GARIS(string name, double value, color warna)
      {
         ObjectCreate(name, OBJ_HLINE, 0,  Time[0], value);
         ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
         ObjectSet(name, OBJPROP_COLOR, warna);
         ObjectMove(name, 0,  Time[0], value);
      }