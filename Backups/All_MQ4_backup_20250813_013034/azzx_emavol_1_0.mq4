// ---------------------------------------------------------------------------
//  Чота захотелось вспомнить... EMA от объёмов по барам, разложенных на
//  движение вверх и вниз по методу "кратчайшего пути".
// ---------------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1  PaleGreen
#property indicator_color2  Red
#property indicator_color3  Blue
#property indicator_width1  3
#property indicator_width2  2
#property indicator_width3  2
#property indicator_minimum 0

// Период усреднения индикатора.
extern int PERIOD = 15;

// Буферы индикатора.
double buf_av[], buf_up[], buf_dn[];
// Коэффициенты EMA.
double ema_k0, ema_k1;
// Рабочий период.
int    work_period;

// Инициализация.
int init() {
  IndicatorShortName(StringConcatenate(
    "AZZX - EMA VOLUME (", PERIOD, ")"));
  IndicatorDigits(0);

  SetIndexBuffer(0, buf_av);  
  SetIndexBuffer(1, buf_up);
  SetIndexBuffer(2, buf_dn);
  
  SetIndexEmptyValue(0, -1);
  SetIndexEmptyValue(1, -1);
  SetIndexEmptyValue(2, -1);
  
  SetIndexLabel(0, "HALF OF AVERAGE VOLUME");
  SetIndexLabel(1, "UP VOLUME");
  SetIndexLabel(2, "DOWN VOLUME");

  ema_k0 = 2.0 / (PERIOD + 1);
  ema_k1 = 1.0 - ema_k0;
  
  work_period = Bars - PERIOD - 2;

  return(0);
}

// Главный цикл.
int start() {
  int    i, j;
  double u, d;
  
  for(i = Bars - IndicatorCounted() - 1; i >= 0; i--) {
    if(i > work_period) {
      buf_av[i] = -1;
      buf_up[i] = -1;
      buf_dn[i] = -1;
    } else if(i == work_period) {
      buf_av[i] = 0;
      buf_up[i] = 0;
      buf_dn[i] = 0;
      
      for(j = Bars - 1; j >= i; j--) {
        calc(j, u, d);
      
        buf_av[i] += 0.5 * Volume[j];
        buf_up[i] += u   * Volume[j];
        buf_dn[i] += d   * Volume[j];
      }
      
      buf_av[i] /= PERIOD;
      buf_up[i] /= PERIOD;
      buf_dn[i] /= PERIOD;
    } else {
      calc(i, u, d);
      
      buf_av[i] = buf_av[i + 1] * ema_k1 + 0.5 * Volume[i] * ema_k0;
      buf_up[i] = buf_up[i + 1] * ema_k1 + u   * Volume[i] * ema_k0;
      buf_dn[i] = buf_dn[i + 1] * ema_k1 + d   * Volume[i] * ema_k0;
    }
  }

  return(0);
}

// Расчёт величин для бара.
void calc(int bar, double &up, double &dn) {
  if(High[bar] == Low[bar]) {
    up = 0;
    dn = 0;
    
    return;
  }

  double range = High[bar] - Low[bar];
  double path  = 2.0 * range - MathAbs(Open[bar] - Close[bar]);

  if(Close[bar] > Open[bar]) {
    up = range / path;
    dn = 1.0 - up;
  } else {
    dn = range / path;
    up = 1.0 - dn;
  }
}

