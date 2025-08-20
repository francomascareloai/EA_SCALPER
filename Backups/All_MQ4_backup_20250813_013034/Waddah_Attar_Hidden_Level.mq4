//+------------------------------------------------------------------+
//|                                      Waddah Attar Hidden Level   |
//|           Copyright © 2007, Waddah Attar waddahattar@hotmail.com |
//|                             Waddah Attar waddahattar@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Waddah Attar waddahattar@hotmail.com"
#property link      "waddahattar@hotmail.com"
//---- 
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Blue

//---- buffers
double P1Buffer[];
double P2Buffer[];
double P3Buffer[];
double P4Buffer[];
double P5Buffer[];
//---- 

bool FixSunday;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0, P1Buffer);
   SetIndexBuffer(1, P2Buffer);
   SetIndexBuffer(2, P3Buffer);
   SetIndexBuffer(3, P4Buffer);
   SetIndexBuffer(4, P5Buffer);
//---- 
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 1);
   SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 1);
   SetIndexStyle(4, DRAW_LINE, STYLE_DOT, 1);
//---- 
   FixSunday=false;
   for(int i = 0; i <7; i++)
     {
       if (TimeDayOfWeek(iTime(Symbol(),PERIOD_D1,i))==0)
       {
         FixSunday=true;
       }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("hlevel1");
   ObjectDelete("hlevel2");
   ObjectDelete("hlevel3");
   ObjectDelete("hlevel4");
   ObjectDelete("hlevel5");
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
  DrawPeriod();
  return(0);
}
  
int DrawPeriod()
{
   int i, ii, counted_bars = IndicatorCounted();
   double c1, c2;
//---- check for possible errors
   if(counted_bars < 0) 
       return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;  
   int limit = Bars - counted_bars;
//---- 
   for(i = limit - 1; i >= 0; i--)
   {
     ii = iBarShift(Symbol(), PERIOD_D1, Time[i],true);
     if (TimeDayOfWeek(Time[i])==1 && FixSunday==true)
     {
       ii=ii+1;
     }

     if(ii != -1)
     {
       if(iClose(Symbol(), PERIOD_D1, ii + 1)>=iOpen(Symbol(), PERIOD_D1, ii + 1))
       {
         c1 = (iHigh(Symbol(), PERIOD_D1, ii + 1)-iClose(Symbol(), PERIOD_D1, ii + 1))/2+iClose(Symbol(), PERIOD_D1, ii + 1);
         c2 = (iOpen(Symbol(), PERIOD_D1, ii + 1)-iLow(Symbol(), PERIOD_D1, ii + 1))/2+iLow(Symbol(), PERIOD_D1, ii + 1);
       }
       else
       {
         c1 = (iHigh(Symbol(), PERIOD_D1, ii + 1)-iOpen(Symbol(), PERIOD_D1, ii + 1))/2+iOpen(Symbol(), PERIOD_D1, ii + 1);
         c2 = (iClose(Symbol(), PERIOD_D1, ii + 1)-iLow(Symbol(), PERIOD_D1, ii + 1))/2+iLow(Symbol(), PERIOD_D1, ii + 1);
       }
       P1Buffer[i] = c1;
       P2Buffer[i] = c2;
       P3Buffer[i] = (c1+c2)/2;
       P4Buffer[i] = c1+(c1-c2)*0.618;
       P5Buffer[i] = c2-(c1-c2)*0.618;
    }
    SetPrice("hlevel1", Time[0],P1Buffer[0], Red);
    SetPrice("hlevel2", Time[0],P2Buffer[0], Green);
    SetPrice("hlevel3", Time[0],P3Buffer[0], Blue);
    SetPrice("hlevel4", Time[0],P4Buffer[0], Blue);
    SetPrice("hlevel5", Time[0],P5Buffer[0], Blue);
  }
  return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+ 
void SetPrice(string name, datetime Tm, double Prc, color clr)
  {
   if(ObjectFind(name) == -1)
     {
       ObjectCreate(name, OBJ_ARROW, 0, Tm, Prc);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_WIDTH, 1);
       ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
     }
   else
     {
       ObjectSet(name, OBJPROP_TIME1, Tm);
       ObjectSet(name, OBJPROP_PRICE1, Prc);
       ObjectSet(name, OBJPROP_COLOR, clr);
       ObjectSet(name, OBJPROP_WIDTH, 1);
       ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
     } 
  }

