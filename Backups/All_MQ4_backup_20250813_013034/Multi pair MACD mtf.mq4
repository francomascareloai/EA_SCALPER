//+------------------------------------------------------------------+
//|                                          Multi pair MACD mtf.mq4 |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property  indicator_buffers 6
#property  indicator_color1  Green
#property  indicator_color2  Green
#property  indicator_color3  Red
#property  indicator_color4  Red
#property  indicator_color5  Gray
#property  indicator_color6  Gold
#property  indicator_width1  2
#property  indicator_width3  2

//
//
//
//
//

extern int       FastEma     = 12;
extern int       SlowEma     = 26;
extern int       SignalEma   =  9;
extern int       barsPerPair = 70;
extern string    pairs       = "EURUSD;GBPUSD;USDCAD";
extern string    TimeFrame   = "Current time frame";
extern bool      equalize    = false;
extern string    text        = "color";
extern color     textColor   = Silver;
extern color     backColor   = C'48,48,48';
extern int       separatorWidth = 6;

//
//
//
//
//

double   ind_buffer1[];
double   ind_buffer2[];
double   ind_buffer3[];
double   ind_buffer4[];
double   ind_buffer5[];
double   ind_buffer6[];
double   ind_buffer7[];
double   ind_buffer8[];
double   ind_buffer9[];

//
//
//
//
//

double   minMacd;
double   maxMacd;

//
//
//
//
//

double   maxValues[];
string   aPairs[];
string   shortName;
int      window;  
int      add;
int      timeFrame;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   IndicatorBuffers(7);
   IndicatorDigits(Digits+1);
   SetIndexBuffer(0,ind_buffer1);
   SetIndexBuffer(1,ind_buffer2);
   SetIndexBuffer(2,ind_buffer3);
   SetIndexBuffer(3,ind_buffer4);
   SetIndexBuffer(4,ind_buffer5);
   SetIndexBuffer(5,ind_buffer6);
   SetIndexBuffer(6,ind_buffer7);
      SetIndexLabel(0,NULL);
      SetIndexLabel(1,NULL);
      SetIndexLabel(2,NULL);
      SetIndexLabel(3,NULL);
      SetIndexLabel(4,"Macd");
      SetIndexLabel(5,"Signal");

   //
   //
   //
   //
   //
   
   add = MathMax(FastEma,SlowEma);
   add = MathMax(SignalEma,add);
      ArrayResize(ind_buffer9,barsPerPair+add+1);
      ArrayResize(ind_buffer8,barsPerPair+add+1);
      ArraySetAsSeries(ind_buffer8,true);
      ArraySetAsSeries(ind_buffer9,true);

   //
   //
   //
   //
   //
      
   SetIndexStyle(0,DRAW_HISTOGRAM); 
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);   
   SetIndexStyle(4,DRAW_LINE); 
   SetIndexStyle(5,DRAW_LINE); 

   //
   //
   //
   //
   //

      pairs = StringTrimLeft(StringTrimRight(pairs));
      if (StringSubstr(pairs,StringLen(pairs),1) != ";")
                       pairs = StringConcatenate(pairs,";");

         //
         //
         //
         //
         //                                   
            
         int s =  0;
         int i =  StringFind(pairs,";",s);
         string current;
         string temp;
            while (i > 0)
            {
               current = StringSubstr(pairs,s,i-s);
               if (iClose(current,0,0) > 0)
                  {
                     ArrayResize(aPairs,ArraySize(aPairs)+1);
                                 aPairs[ArraySize(aPairs)-1] = current;
                                 if (current == Symbol())
                                 {
                                       temp      = aPairs[0];
                                       aPairs[0] = current;
                                       aPairs[ArraySize(aPairs)-1] = temp;
                                 }                                       
                  }
                  s = i + 1;
                  i = StringFind(pairs,";",s);
            }
      ArrayResize(maxValues,ArraySize(aPairs));

   //
   //
   //
   //
   //

   timeFrame = stringToTimeFrame(TimeFrame);
   separatorWidth = MathMax(separatorWidth,4);
   shortName = MakeUniqueName(" Multi MACD "+TimeFrameToString(timeFrame)," ("+FastEma+","+SlowEma+","+SignalEma+")");
   IndicatorShortName(shortName);
 
   //
   //
   //
   //
   //
   
   return(0);
}

int deinit()
{
   for (int i = 0; i < ArraySize(aPairs); i++) { 
         ObjectDelete(shortName+i);
         ObjectDelete(shortName+i+i);
      }         
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int    limit = ArraySize(aPairs);
   int    i,k;
   double max;
   
   //
   //
   //
   //
   //

   window = WindowFind(shortName);  
   ArrayInitialize(maxValues,0);

   //
   //
   //
   //
   //

         minMacd = 0;
         maxMacd = 0;
                for(i=0,k=0; i<limit; i++) calculateMacd(aPairs[i],barsPerPair,k,i);
                for(i=0;     i<limit; i++) if (max < maxValues[i]) max = maxValues[i];
                for(i=0,k=0; i<limit; i++) plotGraph(aPairs[i],barsPerPair,k,i,max);

   //
   //
   //
   //
   //

   for (i=0;i<indicator_buffers;i++) SetIndexDrawBegin(i,Bars-k);
   return(0);
}


//+------------------------------------------------------------------+
//+                                                                  +
//+------------------------------------------------------------------+

void plotGraph(string symbol,int limit, int& shift,int element, double max)
{
   double koef   = 1;
   
   //
   //
   //
   //
   //
   
   if (equalize) koef = max/maxValues[element];

   //
   //
   //
   //
   //

   for(int i=limit-1; i>=0; i--) {   
      ind_buffer5[i+shift] = ind_buffer5[i+shift]*koef;
      ind_buffer6[i+shift] = ind_buffer6[i+shift]*koef;
      
      //
      //
      //
      //
      
      if (ind_buffer7[i+shift] > 0) {
            ind_buffer3[i+shift] = EMPTY_VALUE;
            ind_buffer4[i+shift] = EMPTY_VALUE;
            ind_buffer1[i+shift] = ind_buffer1[i+shift+1];
            ind_buffer2[i+shift] = ind_buffer2[i+shift+1];
            if (ind_buffer7[i+shift] > ind_buffer7[i+shift+1])
               {
                  ind_buffer1[i+shift] = ind_buffer7[i+shift]*koef;
                  ind_buffer2[i+shift] = EMPTY_VALUE;
               }
            if (ind_buffer7[i+shift] < ind_buffer7[i+shift+1])
               {
                  ind_buffer2[i+shift] = ind_buffer7[i+shift]*koef;
                  ind_buffer1[i+shift] = EMPTY_VALUE;
               }
         }
      else {
            ind_buffer1[i+shift] = EMPTY_VALUE;
            ind_buffer2[i+shift] = EMPTY_VALUE;
            ind_buffer3[i+shift] = ind_buffer3[i+shift+1];
            ind_buffer4[i+shift] = ind_buffer4[i+shift+1];
            if (ind_buffer7[i+shift] < ind_buffer7[i+shift+1])
               {
                  ind_buffer3[i+shift] = ind_buffer7[i+shift]*koef;
                  ind_buffer4[i+shift] = EMPTY_VALUE;
               }
            if (ind_buffer7[i+shift] > ind_buffer7[i+shift+1])
               {
                  ind_buffer4[i+shift] = ind_buffer7[i+shift]*koef;
                  ind_buffer3[i+shift] = EMPTY_VALUE;
               }
         }
   }

   //
   //
   //
   //
   //

   createLabel(symbol,element,shift+limit+separatorWidth-2,max,isSignalCrossing(shift));
   
   //
   //
   //
   //
   //
   
   shift += (limit+separatorWidth-1);
}
bool isSignalCrossing(int shift)
{
   double res = (ind_buffer5[shift]   - ind_buffer6[shift])*
                (ind_buffer5[shift+1] - ind_buffer6[shift+1]); 
   return(res<=0);
}

//+------------------------------------------------------------------+
//+                                                                  +
//+------------------------------------------------------------------+

void calculateMacd(string symbol,int limit,int& shift,int element)
{
   bool   start=true;
   double max, alpha=2.0/(1.0+SignalEma);
   int    i,y;

   
   //
   //
   //
   //
   //

   for(i=limit+add; i>=0; i--)
   {
      ind_buffer8[i]=iMA(symbol,timeFrame,FastEma,0,MODE_EMA,PRICE_CLOSE,i)-
                     iMA(symbol,timeFrame,SlowEma,0,MODE_EMA,PRICE_CLOSE,i);
      if (start)
      {                     
         ind_buffer9[i]=ind_buffer8[i]; start=false;
      }
      else ind_buffer9[i] = ind_buffer9[i+1]+alpha*(ind_buffer8[i]-ind_buffer9[i+1]);
   }           
   
   //
   //
   //
   //
   //
   
   for(i=0; i<limit; i++) {
      y = iBarShift(symbol,timeFrame,Time[i]);
      ind_buffer5[i+shift]=ind_buffer8[y];
      ind_buffer6[i+shift]=ind_buffer9[y];
      ind_buffer7[i+shift]=ind_buffer8[y];
      
      //
      //
      //
      //
      //

      max = MathMax(MathAbs(ind_buffer5[i+shift]),
                    MathAbs(ind_buffer6[i+shift]));
                    if (maxValues[element] < max)
                        maxValues[element] = max;

      //
      //
      //
      //
      //
                              
      max = MathMax(ind_buffer5[i+shift],ind_buffer6[i+shift]);
         if (maxMacd < max) maxMacd = max;
      max = MathMin(ind_buffer5[i+shift],ind_buffer6[i+shift]);
         if (minMacd > max) minMacd = max;
   }            

   //
   //
   //
   //
   //

   for (i=0;i<separatorWidth;i++) {
         ind_buffer1[shift+limit+i] = EMPTY_VALUE;                     
         ind_buffer2[shift+limit+i] = EMPTY_VALUE;                     
         ind_buffer3[shift+limit+i] = EMPTY_VALUE;                     
         ind_buffer4[shift+limit+i] = EMPTY_VALUE;                     
         ind_buffer5[shift+limit+i] = EMPTY_VALUE;                     
         ind_buffer6[shift+limit+i] = EMPTY_VALUE;                     
      }         
   shift += (limit+separatorWidth-1);
   return;
}



//+------------------------------------------------------------------+
//+                                                                  +
//+------------------------------------------------------------------+
//
//
//
//
//

void createLabel(string symbol,int element, int shift, double max, bool signalCrossing)
{
   string name = shortName+element;
   double price1;
   double price2;
   
   
   //
   //
   //
   //
   //
   
   if (equalize) {
         price1 = MathMax(MathAbs(minMacd),MathAbs(maxMacd));
         price2 = -price1;
      }
   else {
         price1 = maxMacd;
         price2 = minMacd;
      }         
   
   //
   //
   //
   //
   //
   
   if (ObjectFind(name) == -1)
      {
         ObjectCreate(name,OBJ_TEXT,window,0,0);
         ObjectSet(name,OBJPROP_ANGLE,90);
         ObjectSetText(name,symbol);
      }
      ObjectSet(name,OBJPROP_TIME1 ,Time[shift]);
      ObjectSet(name,OBJPROP_PRICE1,(price1+price2)/2);
      if (signalCrossing)
           ObjectSet(name,OBJPROP_COLOR,Gold);
      else ObjectSet(name,OBJPROP_COLOR,textColor);

   //
   //
   //
   //
   //

 
   name = shortName+element+element;
   if (ObjectFind(name) == -1)
      {
         ObjectCreate(name,OBJ_RECTANGLE,window,0,0,0,0);
         ObjectSet(name,OBJPROP_COLOR,backColor);
      }         
      ObjectSet(name,OBJPROP_TIME1,Time[shift]);
      ObjectSet(name,OBJPROP_PRICE1,price1);
      ObjectSet(name,OBJPROP_TIME2,Time[shift-(separatorWidth-2)]);
      ObjectSet(name,OBJPROP_PRICE2,price2);
}

//+------------------------------------------------------------------+
//+                                                                  +
//+------------------------------------------------------------------+
//
//
//
//
//

//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   int tf=0;
       tfs = StringTrimLeft(StringTrimRight(StringUpperCase(tfs)));
         if (tfs=="M1" || tfs=="1")     tf=PERIOD_M1;
         if (tfs=="M5" || tfs=="5")     tf=PERIOD_M5;
         if (tfs=="M15"|| tfs=="15")    tf=PERIOD_M15;
         if (tfs=="M30"|| tfs=="30")    tf=PERIOD_M30;
         if (tfs=="H1" || tfs=="60")    tf=PERIOD_H1;
         if (tfs=="H4" || tfs=="240")   tf=PERIOD_H4;
         if (tfs=="D1" || tfs=="1440")  tf=PERIOD_D1;
         if (tfs=="W1" || tfs=="10080") tf=PERIOD_W1;
         if (tfs=="MN" || tfs=="43200") tf=PERIOD_MN1;
         if (tf<Period()) tf=Period();
  return(tf);
}
string TimeFrameToString(int tf)
{
   string tfs="";
   
   if (tf!=Period())
      switch(tf) {
         case PERIOD_M1:  tfs="M1"  ; break;
         case PERIOD_M5:  tfs="M5"  ; break;
         case PERIOD_M15: tfs="M15" ; break;
         case PERIOD_M30: tfs="M30" ; break;
         case PERIOD_H1:  tfs="H1"  ; break;
         case PERIOD_H4:  tfs="H4"  ; break;
         case PERIOD_D1:  tfs="D1"  ; break;
         case PERIOD_W1:  tfs="W1"  ; break;
         case PERIOD_MN1: tfs="MN1";
      }
   if (tfs!="") tfs = tfs+" ";
   return(tfs);
}
string StringUpperCase(string str)
{
   string   s = str;
   int      lenght = StringLen(str) - 1;
   int      char;
   
   while(lenght >= 0)
      {
         char = StringGetChar(s, lenght);
         
         //
         //
         //
         //
         //
         
         if((char > 96 && char < 123) || (char > 223 && char < 256))
                  s = StringSetChar(s, lenght, char - 32);
          else 
              if(char > -33 && char < 0)
                  s = StringSetChar(s, lenght, char + 224);
         lenght--;
   }
   
   //
   //
   //
   //
   //
   
   return(s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string MakeUniqueName(string first, string rest)
{
   string result = first+(MathRand()%1001)+rest;

   while (WindowFind(result)> 0)
          result = first+(MathRand()%1001)+rest;
   return(result);
}