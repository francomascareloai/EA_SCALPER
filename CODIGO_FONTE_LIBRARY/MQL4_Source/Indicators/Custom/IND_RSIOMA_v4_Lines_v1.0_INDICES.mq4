//+--------------------------------------------------------------------------------+
//|  RSIOMA_v4  (MTF-std)   by   Mladen        Kalenzo      2007 | ForexTSD.com |ik|
//|  fxbs & Hornet ( 2007, ForexTSD.com)       MetaQuotes Software Corp.           |
//|  Hist & Levels 20/80;30/70 CrossSig        web: http://www.fxservice.eu        |
//|  Rsioma/MaRsioma X sig; ()                 email: bartlomiej.gorski@gmail.com  |
//+--------------------------------------------------------------------------------+
#property copyright "mladen. public domain. ForexTSD.com"
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/ Kalenzo|bartlomiej.gorski@gmail.com "

#property indicator_separate_window
#property indicator_buffers   8
#property indicator_minimum -20
#property indicator_maximum 110
#property indicator_color1     DodgerBlue
#property indicator_color2     Red
#property indicator_color3     Lime
#property indicator_color4     Magenta
#property indicator_color5     DodgerBlue
#property indicator_color6     Yellow//BlueViolet
#property indicator_color7     Lime//Aqua       
#property indicator_color8     Red//DeepPink   
//
#property indicator_width1  2   
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width7  2//1
#property indicator_width8  2//1
//
#property indicator_level1 100
#property indicator_level2 90   //76.4
#property indicator_level3 70   //61.8
#property indicator_level4 50
#property indicator_level5 30   //38.2
#property indicator_level6 10   //23.6
#property indicator_levelcolor DarkSlateGray
//------------------------------------------

//---- input parameters

extern string Timeframe       ="0"; //Current TF = 0
extern string TimeFrames_Periods  = "M1;M5;M15;M30;H1;H4;D1;W1;MN";

extern int    RSIOMA          = 14;//8
extern int    RSIOMA_MODE     = MODE_EMA;
extern int    RSIOMA_PRICE    = PRICE_CLOSE;
extern int    Ma_RSIOMA       = 34;//21
extern int    Ma_RSIOMA_MODE  = MODE_EMA;

extern double BuyTrigger          = 10.00;//20
extern double SellTrigger         = 90.00;//80
extern color  BuyTriggerColor     = Magenta;
extern color  SellTriggerColor    = DodgerBlue;

extern double MainTrendLong       = 70.00;
extern double MainTrendShort      = 30.00;
extern color  MainTrendLongColor  = LimeGreen;//Green
extern color  MainTrendShortColor = Red;
extern double MajorTrend          = 50;
extern color  marsiomaXupSigColor = Aqua;      //DeepSkyBlue
extern color  marsiomaXdnSigColor = DeepPink;  //Crimson

extern int    BarsToCount         = 500;

extern string note_Choose_TimeFrames  =   "TF as in MT4 Periodicity bar:";
extern string as_Periods          = "(M1;M5;M15;M30;H1;H4;D1;W1;MN; or:)";
extern string or_Minutes          = "(1,5,15,30,60,240,1440,10080,43200)";
extern string CurrentTF_0         = "Current TF = 0 (Zero)";

//---- buffers
//
//
//    "indexes"
//

double MABuffer1[];
double RSIBuffer1[];
double marsioma1[];

//
//
//    indexes  (real)
//
//

double RSIBuffer[];
double bdn[];
double bup[];
double sdn[];
double sup[];
double marsioma[];
double marsiomaXupSig[];
double marsiomaXdnSig[];

//
//
//
//
//

int      correction;
datetime lastBarTime;
string   short_name;

//
//
//
//
//

int      TimeFrame;
datetime TimeArray[];
bool     DiferentTimeFrame;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
   
   //
   //
   //
   //
   //
   
   SetIndexBuffer(0,RSIBuffer);
   SetIndexBuffer(2,bup);
   SetIndexBuffer(1,bdn);
   SetIndexBuffer(3,sdn);  //Magneta
   SetIndexBuffer(4,sup);  //DodgerBlue
   SetIndexBuffer(5,marsioma);
   SetIndexBuffer(6,marsiomaXupSig);
   SetIndexBuffer(7,marsiomaXdnSig);

      SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexStyle(4,DRAW_HISTOGRAM);
      SetIndexStyle(6,DRAW_HISTOGRAM);
    //  SetIndexArrow(6,159);
      SetIndexStyle(7,DRAW_HISTOGRAM);
   //   SetIndexArrow(7,159);
  
   SetIndexLabel(0,"Rsioma ["+Timeframe+"]("+RSIOMA+")");
   SetIndexLabel(5,"MaRsioma ["+Timeframe+"]("+Ma_RSIOMA+")");
   SetIndexLabel(1,"TrendDn ["+Timeframe+"]("+RSIOMA+")");
   SetIndexLabel(2,"TrendUp ["+Timeframe+"]("+RSIOMA+")");
     SetIndexLabel(3, "DnXLevel ["+Timeframe+"]("+RSIOMA+")");//Magneta
     SetIndexLabel(4, "UpXLevel ["+Timeframe+"]("+RSIOMA+")");//DodgerBlue

   SetIndexLabel(6,"Rs/MaRs UpXsig ["+Timeframe+"]("+RSIOMA+")");
   SetIndexLabel(7,"Rs/MaRs DnXsig ["+Timeframe+"]("+RSIOMA+")");
 
 
   //
   //
   //    additional buffer(s)
   //
   //


      TimeFrame         = stringToTimeFrame(Timeframe);
      DiferentTimeFrame = (TimeFrame!=Period());
      correction        = RSIOMA+RSIOMA+Ma_RSIOMA;
      BarsToCount       = MathMin(Bars,MathMax(BarsToCount,300));
          ArrayResize( MABuffer1 ,BarsToCount+correction);
          ArrayResize( RSIBuffer1,BarsToCount+correction);
          ArrayResize( marsioma1 ,BarsToCount+correction);
          ArraySetAsSeries(MABuffer1 ,true);
          ArraySetAsSeries(RSIBuffer1,true);
          ArraySetAsSeries(marsioma1 ,true);
                 lastBarTime = EMPTY_VALUE;

      //
      //
      //
      //
      //

   short_name = StringConcatenate("RSIOMA[",TimeFrameToString(TimeFrame),"](",RSIOMA,")(",Ma_RSIOMA,")");   
   IndicatorShortName(short_name);
   
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   static bool init=false;
   int    counted_bars=IndicatorCounted();
   int    limit,i,y;

   //
   //
   //
   //
   //

   if(!init) {
       init=true;
         drawLine(BuyTrigger,"BuyTrigger", BuyTriggerColor);
         drawLine(SellTrigger,"SellTrigger", SellTriggerColor );
         drawLine(MainTrendLong,"MainTrendLong", MainTrendLongColor );
         drawLine(MainTrendShort,"MainTrendShort",MainTrendShortColor );
      }         
      
   //
   //
   //
   //
   //
               
   if(counted_bars<0) return(-1);
   if(lastBarTime != Time[0]) {
      lastBarTime  = Time[0];
                  counted_bars = 0;
      }         
      if(counted_bars>0) counted_bars--;
              limit=Bars-counted_bars;
              limit=MathMin(MathMax(TimeFrame/Period(),limit),BarsToCount+correction);
         ArrayCopySeries(TimeArray ,MODE_TIME ,NULL,TimeFrame);
   
   //
   //
   //
   //
   //
   

      for(i=limit;i>=0;i--) MABuffer1[i]  = iMA(Symbol(),TimeFrame,RSIOMA,0,RSIOMA_MODE,RSIOMA_PRICE,i);
      for(i=limit;i>=0;i--) RSIBuffer1[i] = iRSIOnArray(MABuffer1,0,RSIOMA,i);
      for(i=limit;i>=0;i--) marsioma1[i]  = iMAOnArray(RSIBuffer1,0,Ma_RSIOMA,0,Ma_RSIOMA_MODE,i); 
      
      //
      //
      //
      //
      //

      for(i=0,y=0;i<limit;i++)
      {
         if  (DiferentTimeFrame) { if(Time[i]<TimeArray[y]) y++; }
         else y = i;

            RSIBuffer[i] = RSIBuffer1[y];
            marsioma[i]  = marsioma1[y];
      }

      //
      //
      //
      //
      //
      
      for(i=limit;i>=0;i--)
      {
            bup[i] = EMPTY_VALUE; bdn[i] = EMPTY_VALUE;
            sup[i] = EMPTY_VALUE; sdn[i] = EMPTY_VALUE;
            
               if(RSIBuffer[i] > 50)               bup[i] =   6;
               if(RSIBuffer[i] < 50)               bdn[i] =  -6;      
               if(RSIBuffer[i] > MainTrendLong)    bup[i] =  12;
               if(RSIBuffer[i] < MainTrendShort)   bdn[i] = -12;
            
               if(RSIBuffer[i]<20 && RSIBuffer[i]>RSIBuffer[i+1])                sup[i] =  -3;
               if(RSIBuffer[i]>80 && RSIBuffer[i]<RSIBuffer[i+1])                sdn[i] =   4;
               if(RSIBuffer[i]>20 && RSIBuffer[i+1]<=20)                         sup[i] =   5;
               if(RSIBuffer[i+1]>=80 && RSIBuffer[i]<80)                         sdn[i] =  -5;
               if(RSIBuffer[i+1]<=MainTrendShort && RSIBuffer[i]>MainTrendShort) sup[i] =  12;  
               if(RSIBuffer[i]<MainTrendLong && RSIBuffer[i+1]>=MainTrendLong)   sdn[i] = -12;

            marsiomaXupSig[i] = EMPTY_VALUE;
            marsiomaXdnSig[i] = EMPTY_VALUE;
            
               if(RSIBuffer[i+1]<=marsioma[i+1]&&RSIBuffer[i]>marsioma[i]) marsiomaXupSig[i] = 110; 
               if(RSIBuffer[i+1]>=marsioma[i+1]&&RSIBuffer[i]<marsioma[i]) marsiomaXdnSig[i] = 110;
   }

   //
   //
   //
   //
   //
   
   for (i=0;i<indicator_buffers;i++) SetIndexDrawBegin(i,Bars-BarsToCount);

   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void drawLine(double lvl,string name, color Col )
{
   ObjectDelete(name);
   ObjectCreate(name, OBJ_HLINE, WindowFind(short_name), Time[0], lvl,Time[0], lvl);
   ObjectSet(name   , OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(name   , OBJPROP_COLOR, Col);        
   ObjectSet(name   , OBJPROP_WIDTH, 1);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   int tf=0;
       tfs = StringUpperCase(tfs);
       
         if (tfs=="M1" ||tfs=="1")       tf=PERIOD_M1;
         if (tfs=="M5" ||tfs=="5")       tf=PERIOD_M5;
         if (tfs=="M15"||tfs=="15")      tf=PERIOD_M15;
         if (tfs=="M30"||tfs=="30")      tf=PERIOD_M30;
         if (tfs=="H1" ||tfs=="60")      tf=PERIOD_H1;
         if (tfs=="H4" ||tfs=="240")     tf=PERIOD_H4;
         if (tfs=="D1" ||tfs=="1440")    tf=PERIOD_D1;
         if (tfs=="W1" ||tfs=="10080")   tf=PERIOD_W1;
         if (tfs=="MN" ||tfs=="43200")   tf=PERIOD_MN1;
         
   return(tf);
}
string TimeFrameToString(int tf)
   {
   string tfs="0";
   switch(tf) {
      case PERIOD_M1:  tfs="Period M1"  ; break;
      case PERIOD_M5:  tfs="Period M5"  ; break;
      case PERIOD_M15: tfs="Period M15" ; break;
      case PERIOD_M30: tfs="Period M30" ; break;
      case PERIOD_H1:  tfs="Period H1"  ; break;
      case PERIOD_H4:  tfs="Period H4"  ; break;
      case PERIOD_D1:  tfs="Period D1"  ; break;
      case PERIOD_W1:  tfs="Period W1"  ; break;
      case PERIOD_MN1: tfs="Period MN1";
      }
   return(tfs);
}

//
//
//
//
//

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
                  
         //
         //
         //
         //
         //
                                 
         lenght--;
      }
   
   //
   //
   //
   //
   //
   
   return(s);
}