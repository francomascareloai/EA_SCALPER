//+------------------------------------------------------------------+
//| Squize_MA_E_mtf                        Digitel FLET ColorMOD.mq4 |
//| mtf:ForexTSD.com 2007                                            |
//| mladen's formula   ki                                            |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020"
#property link      ""
#property indicator_buffers 4

//#property indicator_color1 Black
//#property indicator_color2 Black
#property indicator_color3 Yellow
#property indicator_color4 Goldenrod

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 5
#property indicator_width4 5

double upma[];
double dnma[];
double SqLup[]; 
double SqLdn[]; 

extern int Ma1Period = 5;
extern int Ma1Type   = MODE_EMA;
extern int Ma1Price  = PRICE_CLOSE;
extern string     ___= "___";
extern int Ma2Period = 21;
extern int Ma2Type   = MODE_EMA;
extern int Ma2Price  = PRICE_CLOSE;
extern string  _____ = "_______";

extern int MAsThreSHoldPips = 15;
extern bool    ATRmode   =true; 
extern int     ATRperiod =50;
extern double  ATRmultipl=0.4;



extern int     TimeFrame = 0;
extern string  note_TimeFrames = "M1;5,15,30,60H1;240H4;1440D1;10080W1;43200MN|0-CurrentTF";
extern string   note_MA_Type    = "SMA0 EMA1 SMMA2 LWMA3";
extern string   note_Price      = "0C 1O 2H 3L 4Md 5Tp 6WghC: Md(HL/2)4,Tp(HLC/3)5,Wgh(HLCC/4)6";

string IndicatorFileName;
#property indicator_chart_window

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,upma);
   SetIndexBuffer(1,dnma);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   
   SetIndexBuffer(2,SqLup);
   SetIndexBuffer(3,SqLdn);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   
   SetIndexLabel(0,"SqMA1("+Ma1Period+")["+TimeFrame+"]");
   SetIndexLabel(1,"SqMA2("+Ma2Period+")["+TimeFrame+"]");
   SetIndexLabel(2,"SqMA Env("+MAsThreSHoldPips+")("+Ma1Period+","+Ma2Period+")["+TimeFrame+"]");
   SetIndexLabel(3,"SqMA Env("+MAsThreSHoldPips+")("+Ma1Period+","+Ma2Period+")["+TimeFrame+"]");

//----
   IndicatorShortName("SquizeMA ("+Ma1Period+","+Ma2Period+")["+TimeFrame+"]");
   if (TimeFrame < Period()) TimeFrame = Period();
   IndicatorFileName = WindowExpertName();



   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int limit,i,y;    
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit = Bars-counted_bars;
   
   
   if (TimeFrame != Period())
       {
         limit = MathMax(limit,TimeFrame/Period());
         datetime TimeArray[];
        
         ArrayCopySeries(TimeArray ,MODE_TIME ,NULL,TimeFrame);
          
           for(i=0, y=i; i<limit; i++)
           {
              if(Time[i]<TimeArray[y]) y++;
              
              upma  [i]  = iCustom(NULL,TimeFrame,IndicatorFileName,
                                    Ma1Period,Ma1Type,Ma1Price,"",Ma2Period,Ma2Type,Ma2Price,"",
                                    MAsThreSHoldPips,ATRmode,ATRperiod,ATRmultipl,0,y);

              dnma  [i]  = iCustom(NULL,TimeFrame,IndicatorFileName,
                                    Ma1Period,Ma1Type,Ma1Price,"",Ma2Period,Ma2Type,Ma2Price,"",
                                    MAsThreSHoldPips,ATRmode,ATRperiod,ATRmultipl,1,y);
 
              SqLup [i]   =iCustom(NULL,TimeFrame,IndicatorFileName,
                                    Ma1Period,Ma1Type,Ma1Price,"",Ma2Period,Ma2Type,Ma2Price,"",
                                    MAsThreSHoldPips,ATRmode,ATRperiod,ATRmultipl,2,y);

              SqLdn [i]   =iCustom(NULL,TimeFrame,IndicatorFileName,
                                    Ma1Period,Ma1Type,Ma1Price,"",Ma2Period,Ma2Type,Ma2Price,"",
                                    MAsThreSHoldPips,ATRmode,ATRperiod,ATRmultipl,3,y);


           }
         return(0);         
        }
//----
   
   for( i =0; i <=limit ;i++)
   {
      double ma1 = iMA(Symbol(),0,Ma1Period,0,Ma1Type,Ma1Price,i);
      double ma2 = iMA(Symbol(),0,Ma2Period,0,Ma2Type,Ma2Price,i);       
      double madif = MathAbs(ma1-ma2);
 
         upma[i] = ma1;
         dnma[i] = ma2;
          
      if (ATRmode)   double delta = iATR(NULL,0,ATRperiod,i) * ATRmultipl/Point;
      else                  delta = MAsThreSHoldPips;


    
      if(madif/Point< delta)
    
       {
       SqLup   [i] = ma2+ delta*Point; 
       SqLdn   [i] = ma2- delta*Point; 

//                               if (ma1>ma2)
//                upma[i]  = ma1 -  (madif/2);
//                dnma[i]  = ma1 -  (madif/2);
     
         
      }
      
   }
   
   
      return(0);
  }
//+------------------------------------------------------------------+