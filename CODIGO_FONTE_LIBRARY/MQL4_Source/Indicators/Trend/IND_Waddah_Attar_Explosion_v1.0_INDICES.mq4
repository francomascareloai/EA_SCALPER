//+------------------------------------------------------------------+
//|                                       Waddah_Attar_Explosion.mq4 |
//|                              Copyright © 2006, Eng. Waddah Attar |
//|                                          waddahattar@hotmail.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, Eng. Waddah Attar"
#property  link      "waddahattar@hotmail.com"
//----
#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_color3  Sienna
#property  indicator_color4  Blue
#property  indicator_minimum 0.0
//----
extern int  Sensetive = 150;
extern int  DeadZonePip = 30;
extern int  ExplosionPower = 15;
extern int  TrendPower = 15;
extern bool AlertWindow = true;
extern int  AlertCount = 500;
extern bool AlertLong = true;
extern bool AlertShort = true;
extern bool AlertExitLong = true;
extern bool AlertExitShort = true;
//----
double   ind_buffer1[];
double   ind_buffer2[];
double   ind_buffer3[];
double   ind_buffer4[];
//----
int LastTime1 = 1;
int LastTime2 = 1;
int LastTime3 = 1;
int LastTime4 = 1;
int Status = 0, PrevStatus = -1;
double bask, bbid;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 1);
//----   
   SetIndexBuffer(0, ind_buffer1);
   SetIndexBuffer(1, ind_buffer2);
   SetIndexBuffer(2, ind_buffer3);
   SetIndexBuffer(3, ind_buffer4);
//----   
   IndicatorShortName("Waddah Attar Explosion: [S(" + Sensetive + 
                      ") - DZ(" + DeadZonePip + ") - EP(" + ExplosionPower + 
                      ") - TP(" + TrendPower + ")]");
   Comment("copyright waddahwttar@hotmail.com");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double Trend1, Trend2, Explo1, Explo2, Dead;
   double pwrt, pwre;
   int    limit, i, counted_bars = IndicatorCounted();
//----
   if(counted_bars < 0) 
       return(-1);
//----
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars;
//----
   for(i = limit - 1; i >= 0; i--)
     {
       Trend1 = (iMACD(NULL, 0, 20, 40, 9, PRICE_CLOSE, MODE_MAIN, i) - 
                 iMACD(NULL, 0, 20, 40, 9, PRICE_CLOSE, MODE_MAIN, i + 1))*Sensetive;
       Trend2 = (iMACD(NULL, 0, 20, 40, 9, PRICE_CLOSE, MODE_MAIN, i + 2) - 
                 iMACD(NULL, 0, 20, 40, 9, PRICE_CLOSE, MODE_MAIN, i + 3))*Sensetive;
       Explo1 = (iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, i) - 
                 iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, i));
       Explo2 = (iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, i + 1) - 
                 iBands(NULL, 0, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, i + 1));
       Dead = Point * DeadZonePip;
       ind_buffer1[i] = 0;
       ind_buffer2[i] = 0;
       ind_buffer3[i] = 0;
       ind_buffer4[i] = 0;
       if(Trend1 >= 0)
           ind_buffer1[i] = Trend1;
       if(Trend1 < 0)
           ind_buffer2[i] = (-1*Trend1);
       ind_buffer3[i] = Explo1;
       ind_buffer4[i] = Dead;
       if(i == 0)
         {
           if(Trend1 > 0 && Trend1 > Explo1 && Trend1 > Dead && 
              Explo1 > Dead && Explo1 > Explo2 && Trend1 > Trend2 && 
              LastTime1 < AlertCount && AlertLong == true && Ask != bask)
             {
               pwrt = 100*(Trend1 - Trend2) / Trend1;
               pwre = 100*(Explo1 - Explo2) / Explo1;
               bask = Ask;
               if(pwre >= ExplosionPower && pwrt >= TrendPower)
                 {
                   if(AlertWindow == true)
                     {
                       Alert(LastTime1, "- ", Symbol(), " - BUY ", " (", 
                             DoubleToStr(bask, Digits) , ") Trend PWR " , 
                             DoubleToStr(pwrt,0), " - Exp PWR ", DoubleToStr(pwre, 0));
                     }
                   else
                     {
                       Print(LastTime1, "- ", Symbol(), " - BUY ", " (", 
                             DoubleToStr(bask, Digits), ") Trend PWR ", 
                             DoubleToStr(pwrt, 0), " - Exp PWR ", DoubleToStr(pwre, 0));
                     }
                   LastTime1++;
                 }
               Status = 1;
             }
           if(Trend1 < 0 && MathAbs(Trend1) > Explo1 && MathAbs(Trend1) > Dead && 
              Explo1 > Dead && Explo1 > Explo2 && MathAbs(Trend1) > MathAbs(Trend2) && 
              LastTime2 < AlertCount && AlertShort == true && Bid != bbid)
             {
               pwrt = 100*(MathAbs(Trend1) - MathAbs(Trend2)) / MathAbs(Trend1);
               pwre = 100*(Explo1 - Explo2) / Explo1;
               bbid = Bid;
               if(pwre >= ExplosionPower && pwrt >= TrendPower)
                 {
                   if(AlertWindow == true)
                     {
                       Alert(LastTime2, "- ", Symbol(), " - SELL ", " (", 
                             DoubleToStr(bbid, Digits), ") Trend PWR ", 
                             DoubleToStr(pwrt,0), " - Exp PWR ", DoubleToStr(pwre, 0));
                     }
                   else
                     {
                       Print(LastTime2, "- ", Symbol(), " - SELL ", " (", 
                             DoubleToStr(bbid, Digits), ") Trend PWR " , 
                             DoubleToStr(pwrt, 0), " - Exp PWR ", DoubleToStr(pwre, 0));
                     }
                   LastTime2++;
                 }
               Status = 2;
             }
           if(Trend1 > 0 && Trend1 < Explo1 && Trend1 < Trend2 && Trend2 > Explo2 && 
              Trend1 > Dead && Explo1 > Dead && LastTime3 <= AlertCount && 
              AlertExitLong == true && Bid != bbid)
             {
               bbid = Bid;
               if(AlertWindow == true)
                 {
                   Alert(LastTime3, "- ", Symbol(), " - Exit BUY ", " ", 
                         DoubleToStr(bbid, Digits));
                 }
               else
                 {
                   Print(LastTime3, "- ", Symbol(), " - Exit BUY ", " ", 
                         DoubleToStr(bbid, Digits));
                 }
               Status = 3;
               LastTime3++;
             }
           if(Trend1 < 0 && MathAbs(Trend1) < Explo1 && 
              MathAbs(Trend1) < MathAbs(Trend2) && MathAbs(Trend2) > Explo2 && 
              Trend1 > Dead && Explo1 > Dead && LastTime4 <= AlertCount && 
              AlertExitShort == true && Ask != bask)
             {
               bask = Ask;
               if(AlertWindow == true)
                 {
                   Alert(LastTime4, "- ", Symbol(), " - Exit SELL ", " ", 
                         DoubleToStr(bask, Digits));
                 }
               else
                 {
                   Print(LastTime4, "- ", Symbol(), " - Exit SELL ", " ", 
                         DoubleToStr(bask, Digits));
                 }
               Status = 4;
               LastTime4++;
             }
           PrevStatus = Status;
         }
       if(Status != PrevStatus)
         {
           LastTime1 = 1;
           LastTime2 = 1;
           LastTime3 = 1;
           LastTime4 = 1;
         }
     }
   return(0);
  }
//+------------------------------------------------------------------+


