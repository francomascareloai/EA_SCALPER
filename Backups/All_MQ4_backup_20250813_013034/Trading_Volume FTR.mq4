//+------------------------------------------------------------------+
//|                                                  Trading_Vol.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                   https://M2P_Design@hotmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://M2P_Design@hotmail.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Pos
  {
   UpperLeft,
   UpperRight,
   LowerLeft,
   LowerRight
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum way
  {
   BidRatio,
   OpenRatio,
   BodyRatio,
  };

input way    CalculationBy =BodyRatio;
input int    InpPeriod     =13;

input Pos    Position      =LowerLeft;
input int    X_Offset      =5;
input int    Y_Offset      =-125;

double BullO[],BearO[],BullC[],BearC[],BullS[],BearS[],Bulli[],Beari[];
double Bull,Bear;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   Object();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---

   ObjectDelete("VolBG1");
   ObjectDelete("Text1");
   ObjectDelete("Bulls1");
   ObjectDelete("Bullish1");
   ObjectDelete("UpPer1");
   ObjectDelete("Bears1");
   ObjectDelete("Bearish1");
   ObjectDelete("DnPer1");

//---
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
//---
   ArrayResize(BullO,Bars+InpPeriod);
   ArrayResize(BearO,Bars+InpPeriod);
   ArrayResize(BullC,Bars+InpPeriod);
   ArrayResize(BearC,Bars+InpPeriod);
   ArrayResize(BullS,Bars+InpPeriod);
   ArrayResize(BearS,Bars+InpPeriod);
   ArrayResize(Bulli,Bars+1);
   ArrayResize(Beari,Bars+1);

   for(int i=0; i<rates_total; i++)
     {
      //===================================PowerClose
      if(CalculationBy==BidRatio)
        {
         PowerClose(i);
         if(InpPeriod==0)
           {
            Bulli[i]=BullC[i];
            Beari[i]=BearC[i];
           }

         if(InpPeriod>0)
           {
            double Bull1=0,Bear1=0;

            for(int cnt=i; cnt<(i+InpPeriod); cnt++)
              {
               Bull1=Bull1+BullC[cnt];
               Bear1=Bear1+BearC[cnt];
              }
            Bulli[i]=Bull1/InpPeriod;
            Beari[i]=Bear1/InpPeriod;
           }
        }
      //===================================PowerOpen
      if(CalculationBy==OpenRatio)
        {
         PowerOpen(i);
         if(InpPeriod==0)
           {
            Bulli[i]=BullO[i];
            Beari[i]=BearO[i];
           }

         if(InpPeriod>0)
           {
            double Bull1=0,Bear1=0;

            for(int cnt=i; cnt<(i+InpPeriod); cnt++)
              {
               Bull1=Bull1+BullO[cnt];
               Bear1=Bear1+BearO[cnt];
              }
            Bulli[i]=Bull1/InpPeriod;
            Beari[i]=Bear1/InpPeriod;
           }
        }
      //===================================Sentiment
      if(CalculationBy==BodyRatio)
        {
         Sentiment(i);
         if(InpPeriod==0)
           {
            Bulli[i]=BullS[i];
            Beari[i]=BearS[i];
           }

         if(InpPeriod>0)
           {
            double Bull1=0,Bear1=0;

            for(int cnt=i; cnt<(i+InpPeriod); cnt++)
              {
               Bull1=Bull1+BullS[cnt];
               Bear1=Bear1+BearS[cnt];
              }
            Bulli[i]=Bull1/InpPeriod;
            Beari[i]=Bear1/InpPeriod;
           }
        }
     }
   Bull=Bulli[0];
   Bear=Beari[0];
   ObjectS(Bull,Bear);
//--- 
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| PowerOpen Calculations function                                  |
//+------------------------------------------------------------------+
void PowerOpen(int i)
  {
   double BidRatio=0;
   double Bulls=0,Bears=0;

   double PairH=iHigh(Symbol(),0,i);
   double PairL=iLow(Symbol(),0,i);

   double PairB=iOpen(Symbol(),0,i);
   double PRange=(PairH-PairL)*Point;
   if(PRange>0)
      BidRatio=(PairH-PairB)/(PairH-PairL);

   Bulls=BidRatio;
   Bears=1-Bulls;

   BullO[i] = MathRound(Bulls*100);
   BearO[i] = MathRound(Bears*100);
  }
//+------------------------------------------------------------------+
//| PowerClose Calculations function                                 |
//+------------------------------------------------------------------+
void PowerClose(int i)
  {
   double BidRatio=0;
   double Bulls=0,Bears=0;

   double PairH=iHigh(Symbol(),0,i);
   double PairL=iLow(Symbol(),0,i);

   double PairB=iClose(Symbol(),0,i);
   double PRange=(PairH-PairL)*Point;
   if(PRange>0)
      BidRatio=(PairB-PairL)/(PairH-PairL);

   Bulls=BidRatio;
   Bears=1-Bulls;

   BullC[i] = MathRound(Bulls*100);
   BearC[i] = MathRound(Bears*100);
  }
//+------------------------------------------------------------------+
//| Sentiment Calculations function                                  |
//+------------------------------------------------------------------+
void Sentiment(int i)
  {
   double Percent=0;
   double Bulls=0,Bears=0;
   double Length0=(iHigh(Symbol(),0,i)-iLow(Symbol(),0,i));

   double Body0=MathAbs(iOpen(Symbol(),0,i)-iClose(Symbol(),0,i));

   if(Length0>0)
      Percent=Body0/Length0;
   double Remain=1-Percent;

//DownCandle
   if(iOpen(Symbol(),0,i)>iClose(Symbol(),0,i))
     {
      Bulls = Remain/2;
      Bears = Percent + Bulls;
     }

//UpCandle
   else if(iOpen(Symbol(),0,i)<=iClose(Symbol(),0,i))
     {
      Bears = Remain/2;
      Bulls = Percent + Bears;
     }

   BullS[i] = MathRound(Bulls*100);
   BearS[i] = MathRound(Bears*100);
  }
//+------------------------------------------------------------------+
//| Object Modify function                                           |
//+------------------------------------------------------------------+
void ObjectS(double Bulls,double Bears)
  {
   ObjectSet("Bullish1",OBJPROP_XSIZE,Bulls);
   ObjectSetString(0,"UpPer1",OBJPROP_TEXT,(DoubleToString(Bulls,0)+" %"));

   ObjectSet("Bearish1",OBJPROP_XSIZE,Bears);
   ObjectSetString(0,"DnPer1",OBJPROP_TEXT,(DoubleToString(Bears,0)+" %"));
  }
//+------------------------------------------------------------------+
//| Object Creation function                                         |
//+------------------------------------------------------------------+
void Object()
  {
   int X=0,Y=0;
   if(Position==UpperLeft)
     {
      X=X_Offset;
      Y=Y_Offset;
     }
   if(Position==UpperRight)
     {
      X=555+X_Offset;
      Y=Y_Offset;
     }
   if(Position==LowerLeft)
     {
      X=X_Offset;
      Y=320+Y_Offset;
     }
   if(Position==LowerRight)
     {
      X=555+X_Offset;
      Y=320+Y_Offset;
     }
//===============BackGround====================
   ObjectCreate("VolBG1",OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSet("VolBG1",OBJPROP_XDISTANCE,X);
   ObjectSet("VolBG1",OBJPROP_YDISTANCE,Y);
   ObjectSet("VolBG1",OBJPROP_XSIZE,225);
   ObjectSet("VolBG1",OBJPROP_YSIZE,100);
   ObjectSet("VolBG1",OBJPROP_BGCOLOR,clrBlack);

//==================Label======================
   ObjectCreate("Text1",OBJ_LABEL,0,0,0);
   ObjectSet("Text1",OBJPROP_COLOR,clrGold);
   ObjectSetString(0,"Text1",OBJPROP_TEXT,"-- Trading Volume --");
   ObjectSetString(0,"Text1",OBJPROP_FONT,"Arial");
   ObjectSet("Text1",OBJPROP_FONTSIZE,14);
   ObjectSet("Text1",OBJPROP_STYLE,STYLE_SOLID);
   ObjectSet("Text1",OBJPROP_XDISTANCE,(X+30));
   ObjectSet("Text1",OBJPROP_YDISTANCE,(Y+5));

//==================Bullish====================
   ObjectCreate("Bulls1",OBJ_LABEL,0,0,0);
   ObjectSet("Bulls1",OBJPROP_COLOR,clrGreen);
   ObjectSetString(0,"Bulls1",OBJPROP_TEXT,"Bulls");
   ObjectSetString(0,"Bulls1",OBJPROP_FONT,"Arial");
   ObjectSet("Bulls1",OBJPROP_FONTSIZE,14);
   ObjectSet("Bulls1",OBJPROP_XDISTANCE,(X+5));
   ObjectSet("Bulls1",OBJPROP_YDISTANCE,(Y+40));

   ObjectCreate("Bullish1",OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSet("Bullish1",OBJPROP_XDISTANCE,(X+60));
   ObjectSet("Bullish1",OBJPROP_YDISTANCE,(Y+40));
   ObjectSet("Bullish1",OBJPROP_YSIZE,20);
   ObjectSet("Bullish1",OBJPROP_BGCOLOR,clrLimeGreen);

   ObjectCreate("UpPer1",OBJ_LABEL,0,0,0);
   ObjectSet("UpPer1",OBJPROP_COLOR,clrGreen);
   ObjectSetString(0,"UpPer1",OBJPROP_FONT,"Arial");
   ObjectSet("UpPer1",OBJPROP_FONTSIZE,14);
   ObjectSet("UpPer1",OBJPROP_XDISTANCE,(X+165));
   ObjectSet("UpPer1",OBJPROP_YDISTANCE,(Y+40));

//==================Bearish====================
   ObjectCreate("Bears1",OBJ_LABEL,0,0,0);
   ObjectSet("Bears1",OBJPROP_COLOR,clrFireBrick);
   ObjectSetString(0,"Bears1",OBJPROP_TEXT,"Bears");
   ObjectSetString(0,"Bears1",OBJPROP_FONT,"Arial");
   ObjectSet("Bears1",OBJPROP_FONTSIZE,14);
   ObjectSet("Bears1",OBJPROP_XDISTANCE,(X+5));
   ObjectSet("Bears1",OBJPROP_YDISTANCE,(Y+70));

   ObjectCreate("Bearish1",OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSet("Bearish1",OBJPROP_XDISTANCE,(X+60));
   ObjectSet("Bearish1",OBJPROP_YDISTANCE,(Y+70));
   ObjectSet("Bearish1",OBJPROP_YSIZE,20);
   ObjectSet("Bearish1",OBJPROP_BGCOLOR,clrRed);

   ObjectCreate("DnPer1",OBJ_LABEL,0,0,0);
   ObjectSet("DnPer1",OBJPROP_COLOR,clrFireBrick);
   ObjectSetString(0,"DnPer1",OBJPROP_FONT,"Arial");
   ObjectSet("DnPer1",OBJPROP_FONTSIZE,14);
   ObjectSet("DnPer1",OBJPROP_XDISTANCE,(X+165));
   ObjectSet("DnPer1",OBJPROP_YDISTANCE,(Y+70));
  }
//+------------------------------------------------------------------+
