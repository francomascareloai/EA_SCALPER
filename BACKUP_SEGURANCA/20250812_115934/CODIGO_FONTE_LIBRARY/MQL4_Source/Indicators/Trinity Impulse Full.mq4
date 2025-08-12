#property copyright "DOWNLOADMQ4.COM "
#property link      "https://downloadmq4.com/"
//----
#property indicator_separate_window
//----
#property indicator_buffers 1
#property indicator_color1 Chartreuse
//----
extern int nPeriod = 5;
extern int nLevel  = 34;
//----
double c[];
double f[];
double iCF[];
//+------------------------------------------------------------------+
int init()
 {
   ObjectCreate("textir",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("textir",OBJPROP_CORNER,1);
   ObjectSet("textir",OBJPROP_XDISTANCE,50);
   ObjectSet("textir",OBJPROP_YDISTANCE,40);
   ObjectSetText("textir","DOWNLOADMQ4.COM",10,"Times New Roman",Gold);
   ObjectCreate("textiNr",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("textiNr",OBJPROP_CORNER,1);
   ObjectSet("textiNr",OBJPROP_XDISTANCE,50);
   ObjectSet("textiNr",OBJPROP_YDISTANCE,58);
   ObjectSetText("textiNr","FREE FOREX LIBRARY",10,"Times New Roman",Gold);
   ObjectCreate("textiKr",OBJ_LABEL,0,0,0,0,0);
   ObjectSet("textiKr",OBJPROP_CORNER,1);
   ObjectSet("textiKr",OBJPROP_XDISTANCE,54);
   ObjectSet("textiKr",OBJPROP_YDISTANCE,72);
   ObjectSetText("textiKr","https://t.me/downloadmq4",10,"Times New Roman",Gold); 
   //---
   string short_name;
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, iCF);
   SetIndexBuffer(1, c);
   SetIndexBuffer(2, f);
   short_name = "Trinity-Impulse("+nPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
   SetIndexDrawBegin(0, nPeriod);
   return(0);
 }
//+------------------------------------------------------------------+
int start()
 {
   int counted_bars = IndicatorCounted();
   int j;
   j = Bars - nPeriod - 1;
   if(counted_bars >= nPeriod) j = Bars - counted_bars - 1;
   while(j >= 0)
    {      
       c[j] = iCCI(NULL, 0, nPeriod, PRICE_WEIGHTED, j);     
       f[j] = iForce(NULL, 0, nPeriod, MODE_LWMA, PRICE_WEIGHTED, j);
       //----- 
       if(c[j] * f[j] >= nLevel)
        {
          if(c[j] > 0 &&  f[j] > 0)
           {
             iCF[j] = 1;
           }
          if(c[j] < 0 &&  f[j] < 0)
           {
             iCF[j] = -1;
           }
        }           
       else iCF[j] = 0;
       j--;
    }
   return(0);
 }
//+------------------------------------------------------------------+