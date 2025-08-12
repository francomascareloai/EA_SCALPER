//+------------------------------------------------------------------+
//|                                              i-BigBarsFromH1.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 2005.09.16  На часовом графике показывает свечи старших ТФ       |
//+------------------------------------------------------------------+
#property copyright "Ким Игорь В. aka KimIV"
#property link      "http://www.kimiv.ru"

#property indicator_chart_window

//------- Внешние параметры ------------------------------------------
extern int TFBar       = 6;            // Период старших свечек
extern int offsetHour  = -2;           // Смещение часов
extern int NumberOfBar = 30;           // Количество старших свечек
extern color ColorUp   = Silver;       // Цвет восходящей свечи
extern color ColorDown = RoyalBlue;    // Цвет нисходящей свечи

//------- Глобальные переменные --------------------------------------

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  int i;

  for (i=0; i<NumberOfBar; i++) {
    ObjectDelete("BodyH"+TFBar+"Bar" + i);
    ObjectDelete("ShadowH"+TFBar+"Bar" + i);
  }
  for (i=0; i<NumberOfBar; i++) {
    ObjectCreate("BodyH"+TFBar+"Bar" + i, OBJ_RECTANGLE, 0, 0,0, 0,0);
    ObjectCreate("ShadowH"+TFBar+"Bar" + i, OBJ_TREND, 0, 0,0, 0,0);
  }
  Comment("");
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  // Удаление объектов
  for (int i=0; i<NumberOfBar; i++) {
    ObjectDelete("BodyH"+TFBar+"Bar" + i);
    ObjectDelete("ShadowH"+TFBar+"Bar" + i);
  }
  Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  int shb=0, sh1=1, d;
  double   po, pc;       // Цены открытия и закрытия старших свечек
  double   ph=0, pl=500; // Цены хай и лоу старших свечек
  datetime to, tc, ts;   // Время открытия, закрытия и теней старших свечек

  if (Period()!=60) Comment("Индикатор i-BigBarsFromH1 поддерживает ТФ только Н1!");
  else {
    if (MathMod(TFBar,2)==0) d=TFBar/2; else d=TFBar/2+1;
    pc = Close[0];
    tc = Time[0];
    // Бежим по старшим свечкам
    while (shb<NumberOfBar) {
      // Бежим по часовым свечкам
      ph = MathMax(ph, High[sh1-1]);
      pl = MathMin(pl, Low[sh1-1]);
      ts = StrToTime(TimeToStr(Time[sh1-d], TIME_DATE)+" "+TimeHour(Time[sh1-d])+":30");
      if (MathMod(TimeHour(Time[sh1])+1+offsetHour, TFBar)==0/* || TimeDay(Time[sh1])!=TimeDay(Time[sh1-1])*/) {
        po = Open[sh1-1];
        to = Time[sh1-1];
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_TIME1, to);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_PRICE1, po);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_TIME2, tc);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_PRICE2, pc);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_BACK, True);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_TIME1, ts);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_PRICE1, ph);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_TIME2, ts);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_PRICE2, pl);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_WIDTH, 3);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_BACK, True);
        ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_RAY, False);
        if (po<pc) {
          ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorUp);
          ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorUp);
        } else {
          ObjectSet("BodyH"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorDown);
          ObjectSet("ShadowH"+TFBar+"Bar"+shb, OBJPROP_COLOR, ColorDown);
        }
        pc = Close[sh1];
        tc = Time[sh1];
        ph = 0;
        pl = 500;
        ph = MathMax(ph, High[sh1]);
        pl = MathMin(pl, Low[sh1]);
        shb++;
      }
      sh1++;
    }
  }
}
//+------------------------------------------------------------------+

