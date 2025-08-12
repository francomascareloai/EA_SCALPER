//+------------------------------------------------------------------+
//| Die Stärke des Corrected Average (CA) besteht darin,             |
//| dass der aktuelle Wert der Zeitreihe einen von der momentanen    |
//| Volatilität abhängigen Schwellenwert überschreiten muss,         |
//| damit der Filter steigt bzw. fällt, wodurch Fehlsignale          |
//| in trendschwachen Phasen vermieden werden.                       |
//| -A.Uhl-                                                          |
//+------------------------------------------------------------------+
//|Germany, 23.03.2007


#property copyright "A.Uhl, © RickD 2006, Alexander Piechotta"
#property link      "http://onix-trade.net/forum/"

#define major   1
#define minor   0


#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  DodgerBlue
#property indicator_width1 2

extern int MA.Period = 28;
extern int MA.method = MODE_EMA;
extern int MA.applied_price = PRICE_CLOSE;


double MABuf[];
double CABuf[];


void init()
{       
IndicatorBuffers(2);
SetIndexStyle(0, DRAW_LINE, STYLE_SOLID,2);
SetIndexDrawBegin(0, MA.Period);

SetIndexBuffer(0, CABuf);
SetIndexBuffer(1, MABuf);

IndicatorShortName("Corrected Average (CA) ("+MA.Period+")");
}


void deinit(){
}  


void start() 
{
  int counted = IndicatorCounted();
  if (counted < 0) return (-1);
  
  if (counted > 0) counted--;
  int limit = Bars-counted;
  
  double v1, v2, k;
  
  for (int i=limit-1; i >= 0; i--)
  {
    MABuf[i] = iMA(NULL, 0, MA.Period, 0, MA.method, MA.applied_price, i);
    
    if (i == Bars-1) {
      CABuf[i] = MABuf[i];
      continue;
    }
    
    v1 = MathPow(iStdDev(NULL, 0, MA.Period, 0, MA.method, MA.applied_price, i), 2);
    v2 = MathPow(CABuf[i+1] - MABuf[i], 2);
    
    k = 0;
    if (v2 < v1 || v2 == 0) k = 0; else k = 1 - v1/v2;

    CABuf[i] = CABuf[i+1] + k*(MABuf[i]-CABuf[i+1]);
  }
}