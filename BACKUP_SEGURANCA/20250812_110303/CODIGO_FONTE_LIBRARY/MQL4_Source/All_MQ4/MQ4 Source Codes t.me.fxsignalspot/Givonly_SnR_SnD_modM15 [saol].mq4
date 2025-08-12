//+------------------------------------------------------------------+
//|                                              Givonly_SnR_SnD.mq4 |
//|                                                          Givonly |
//|                                      http://www.kgforexworld.com |
//+------------------------------------------------------------------+
#property copyright "Givonly"
#property link      "http://www.kgforexworld.com"
#property indicator_chart_window

extern bool SHOW_M15=true;
extern bool SHOW_M30=true;
extern bool SHOW_H1=true;
extern bool SHOW_H4=true;
extern bool SHOW_D1=true;
extern bool SHOW_W1=false;
extern int Supply_Demand_Area=10;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("M15 RESISTANCE");
   ObjectDelete("M30 RESISTANCE");
   ObjectDelete("H1 RESISTANCE");
   ObjectDelete("H4 RESISTANCE");
   ObjectDelete("D1 RESISTANCE");
   ObjectDelete("W1 RESISTANCE");
   ObjectDelete("M15 SUPPORT");
   ObjectDelete("M30 SUPPORT");
   ObjectDelete("H1 SUPPORT");
   ObjectDelete("H4 SUPPORT");
   ObjectDelete("D1 SUPPORT");
   ObjectDelete("W1 SUPPORT");
   ObjectDelete("GIVONLY M15 RESISTANCE LINE");
   ObjectDelete("GIVONLY M30 RESISTANCE LINE");  
   ObjectDelete("GIVONLY H1 RESISTANCE LINE");
   ObjectDelete("GIVONLY H4 RESISTANCE LINE");
   ObjectDelete("GIVONLY D1 RESISTANCE LINE");
   ObjectDelete("GIVONLY W1 RESISTANCE LINE");
   ObjectDelete("GIVONLY M15 SUPPORT LINE");
   ObjectDelete("GIVONLY M30 SUPPORT LINE");  
   ObjectDelete("GIVONLY H1 SUPPORT LINE");
   ObjectDelete("GIVONLY H4 SUPPORT LINE");
   ObjectDelete("GIVONLY D1 SUPPORT LINE");
   ObjectDelete("GIVONLY W1 SUPPORT LINE");
   ObjectDelete("M15 SUPPLY AREA");
   ObjectDelete("M30 SUPPLY AREA");
   ObjectDelete("H1 SUPPLY AREA");
   ObjectDelete("H4 SUPPLY AREA");
   ObjectDelete("D1 SUPPLY AREA");
   ObjectDelete("W1 SUPPLY AREA");
   ObjectDelete("M15 DEMAND AREA");
   ObjectDelete("M30 DEMAND AREA");  
   ObjectDelete("H1 DEMAND AREA");
   ObjectDelete("H4 DEMAND AREA");
   ObjectDelete("D1 DEMAND AREA");
   ObjectDelete("W1 DEMAND AREA");
//----
   return(0);
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
   if(SHOW_M15) GAMBAR(15);
   if(SHOW_M30) GAMBAR(30);
   if(SHOW_H1) GAMBAR(60);
   if(SHOW_H4) GAMBAR(240);
   if(SHOW_D1) GAMBAR(1440);
   if(SHOW_W1) GAMBAR(10080);
   if(Supply_Demand_Area>0)   {
      if(SHOW_M15)   SND(15);
      if(SHOW_M30)   SND(30);  
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
         if( (SNR(period,MODE_HIGH)==SNR(15,MODE_HIGH) && period>15 && SHOW_M15)
            || (SNR(period,MODE_HIGH)==SNR(30,MODE_HIGH) && period>30 && SHOW_M30)
            || (SNR(period,MODE_HIGH)==SNR(60,MODE_HIGH) && period>60 && SHOW_H1)
            || (SNR(period,MODE_HIGH)==SNR(240,MODE_HIGH) && period>240 && SHOW_H4)
            || (SNR(period,MODE_HIGH)==SNR(1440,MODE_HIGH) && period>1440 && SHOW_D1)
            || (SNR(period,MODE_HIGH)==SNR(10080,MODE_HIGH) && period>10080 && SHOW_W1)
           )   ada=true;
         if(!ada) {
            ObjectCreate(name,OBJ_RECTANGLE,0,0,0);
            ObjectSet(name,OBJPROP_TIME1,Time[0]);
            ObjectSet(name,OBJPROP_TIME2,Time[Bars-1]);
            ObjectSet(name,OBJPROP_COLOR,CadetBlue);
            ObjectSet(name,OBJPROP_PRICE1,atas);
            ObjectSet(name,OBJPROP_PRICE2,bawah);
            ObjectMove(name,0,Time[0],atas);
            ObjectMove(name,1,Time[Bars-1],bawah);
            }

         name = StringConcatenate(TF(period)," DEMAND AREA");
         bawah= SNR(period,MODE_LOW);
         atas = bawah+Supply_Demand_Area*Point;
         ada=false;
         if( (SNR(period,MODE_LOW)==SNR(15,MODE_LOW) && period>15 && SHOW_M15)
            || (SNR(period,MODE_LOW)==SNR(30,MODE_LOW) && period>30 && SHOW_M30)
            || (SNR(period,MODE_LOW)==SNR(60,MODE_LOW) && period>60 && SHOW_H1)
            || (SNR(period,MODE_LOW)==SNR(240,MODE_LOW) && period>240 && SHOW_H4)
            || (SNR(period,MODE_LOW)==SNR(1440,MODE_LOW) && period>1440 && SHOW_D1)
            || (SNR(period,MODE_LOW)==SNR(10080,MODE_LOW) && period>10080 && SHOW_W1)
           )   ada=true;
         if(!ada) {
            ObjectCreate(name,OBJ_RECTANGLE,0,0,0);
            ObjectSet(name,OBJPROP_TIME1,Time[0]);
            ObjectSet(name,OBJPROP_TIME2,Time[Bars-1]);
            ObjectSet(name,OBJPROP_COLOR, Peru);
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
      if(period==15)    {warna1=LightSkyBlue;       warna2=LightCoral;}
      if(period==30)    {warna1=CornflowerBlue;     warna2=Tomato;}
      if(period==60)    {warna1=SlateBlue;          warna2=Red;}
      if(period==240)    {warna1=DarkBlue;   warna2=OrangeRed;}
      if(period==1440)    {warna1=Blue;   warna2=Crimson;}
      if(period==10080)    {warna1=RoyalBlue;   warna2=Brown;}

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
         if(period==15)      tf="M15";
         if(period==30)      tf="M30";
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
         ObjectSetText(NamaTeks, ValueTeks, 10, "Tahoma", warna);
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

