//+------------------------------------------------------------------+
//|                                   Value Chart Deluxe Edition.mq4 |
//|                      Copyright 2013, William Kreider (Madhatt30) |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, William Kreider (Madhatt30)"
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_levelcolor SteelBlue
#property indicator_levelstyle 0
#property indicator_buffers 4
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 Black
#property indicator_color4 Black
#property indicator_level1 12.0
#property indicator_level2 10.0
#property indicator_level3 8.0
#property indicator_level4 6
#property indicator_level5 -6
#property indicator_level6 -8.0
#property indicator_level7 -10.0
#property indicator_level8 -12
#property indicator_maximum 15
#property indicator_minimum -15
//--- input parameters
extern int       NumBars=5;
extern string    Note00="True = using by way of iCustom";
extern bool      useExtern=false;
extern color     Bullish_Color=LimeGreen;
extern color     Bearish_Color=Red;
extern color     Actual_Color=Yellow;

extern string    Note0="**** VC Bar Width ****";
extern int       Wick=2;
extern int       Body=6;

extern string    Note1="**** OB/OS Levels ****";
extern int       OBHigh_Upper=12;
extern int       OBHigh_Lower=8;
extern int       NMid_Upper=8;
extern int       NMid_Lower=-8;
extern int       OSLow_Upper=-8;
extern int       OSLow_Lower=-12;
extern string    Note1b="barsback=Areas Displayed num bars back";
extern int       BarsBack=1000;
extern string    Note1c="BarsAhead=Areas Displayed ahead of current bar";
extern int       BarsAhead=20;

extern string    Note2="**** OB/OS Level Colors ****";
extern color     OBHigh_Color=C'255,164,177';
extern color     Normal_Color=C'5,116,5';
extern color     OSLow_Color=C'255,164,177';

extern string    Note3="**** Alert Settings ****";
extern bool      useAlerts=false;
extern int       NumLevels=4;
extern int       level1=10;
extern int       level2=-10;
extern int       level3=11;
extern int       level4=-11;
extern int       level5=10;
extern int       level6=-10;
extern double    exitSig=0.5;

double levels[6];
bool in[6],firstrun=true;

double VOpen[],VHigh[],VLow[],VClose[],Typical;

int VCBars;
int winTF;
int barsback;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
The formula of the indicator is:
OPEN = (OPEN - MVA(TYPICAL)) / (ATR / ATR_N)
HIGH = (HIGH - MVA(TYPICAL)) / (ATR / ATR_N)
LOW = (LOW - MVA(TYPICAL)) / (ATR / ATR_N)
CLOSE = (CLOSE - MVA(TYPICAL)) / (ATR / ATR_N)
TYPICAL = (HIGH + LOW + CLOSE) / 3
MVA is Market Value Added
*/

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,VHigh);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,VLow);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,VOpen);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,VClose);

   winTF=Period();
   string shortname="Value Chart Deluxe Edition("+winTF+")";
   IndicatorShortName(shortname);

   levels[0] = level1;
   levels[1] = level2;
   levels[2] = level3;
   levels[3] = level4;
   levels[4] = level5;
   levels[5] = level6;

   for(int i=0; i<NumLevels; i++)
     {
      in[i]=true;
     }
   firstrun=true;
   barsback=(Bars-Bars)+BarsBack;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
//Print("deinit: " + UninitializeReason());
   ObjectsDeleteAll(WindowFind("Value Chart Deluxe Edition("+winTF+")"));
   firstrun=true;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int  curBar,window,cnt;
   string Wicks,Bodies;
   double relativeClose;
   winTF=Period();
   window=WindowFind("Value Chart Deluxe Edition("+winTF+")");
   barsback=(Bars-Bars)+BarsBack;
//----
//Print("counted_bars = " + counted_bars);
   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0){ patchExtBars();}
   if(counted_bars==0) limit-=1+NumBars;

   for(int i=0; i<=limit; i++)
     {
      VOpen[i]    = (Open[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));
      VHigh[i]    = (High[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));
      VLow[i]     = (Low[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));
      VClose[i]   = (Close[i] - (MVA(NumBars,i))) / (ATR(NumBars,i));

      if(!useExtern)
        {
         curBar=limit-i;

         // ***************************** Start Colored Zones ************************************
         // Create Rectangles for top and bottom
         // Top
         if(ObjectFind("TopRec1")!=0)
           {
            if(barsback==0)
              {
               ObjectCreate("TopRec1",OBJ_RECTANGLE,window,Time[WindowBarsPerChart()],OBHigh_Upper,(Time[0]+((Period()*60)*BarsAhead)),OBHigh_Lower);
                 }else{
               ObjectCreate("TopRec1",OBJ_RECTANGLE,window,Time[barsback],OBHigh_Upper,(Time[0]+((Period()*60)*BarsAhead)),OBHigh_Lower);
              }
           }
         ObjectSet("TopRec1",OBJPROP_COLOR,OBHigh_Color);
         ObjectSet("TopRec1",OBJPROP_TIME1,Time[barsback]);
         ObjectSet("TopRec1",OBJPROP_TIME2,(Time[0]+((Period()*60)*BarsAhead)));
         ObjectSet("TopRec1",OBJPROP_PRICE1,OBHigh_Upper);
         ObjectSet("TopRec1",OBJPROP_PRICE2,OBHigh_Lower);

         // Mid
         if(ObjectFind("MidRec1")!=0)
           {
            if(barsback==0)
              {
               ObjectCreate("MidRec1",OBJ_RECTANGLE,window,Time[WindowBarsPerChart()],NMid_Upper,(Time[0]+((Period()*60)*BarsAhead)),NMid_Lower);
                 }else{
               ObjectCreate("MidRec1",OBJ_RECTANGLE,window,Time[barsback],NMid_Upper,(Time[0]+((Period()*60)*BarsAhead)),NMid_Lower);
              }
           }
         ObjectSet("MidRec1",OBJPROP_COLOR,Normal_Color);
         ObjectSet("MidRec1",OBJPROP_TIME1,Time[barsback]);
         ObjectSet("MidRec1",OBJPROP_TIME2,(Time[0]+((Period()*60)*BarsAhead)));
         ObjectSet("MidRec1",OBJPROP_PRICE1,NMid_Upper);
         ObjectSet("MidRec1",OBJPROP_PRICE2,NMid_Lower);

         // Bottom
         if(ObjectFind("BotRec2")!=0)
           {
            if(barsback==0)
              {
               ObjectCreate("BotRec2",OBJ_RECTANGLE,window,Time[WindowBarsPerChart()],OSLow_Lower,(Time[0]+((Period()*60)*BarsAhead)),OSLow_Upper);
                 }else{
               ObjectCreate("BotRec2",OBJ_RECTANGLE,window,Time[barsback],OSLow_Lower,(Time[0]+((Period()*60)*BarsAhead)),OSLow_Upper);
              }
           }
         ObjectSet("BotRec2",OBJPROP_COLOR,OSLow_Color);
         ObjectSet("BotRec2",OBJPROP_TIME1,Time[barsback]);
         ObjectSet("BotRec2",OBJPROP_TIME2,(Time[0]+((Period()*60)*BarsAhead)));
         ObjectSet("BotRec2",OBJPROP_PRICE1,OSLow_Lower);
         ObjectSet("BotRec2",OBJPROP_PRICE2,OSLow_Upper);
         // ****************************** End Colored Zones *************************************
         // *************************** Plot VC Bars on Chart ***************************

         Wicks="VC_HL_"+curBar;
         // *** If Bar doesn't exist then create it, if it does then change paramaters
         if(ObjectFind(Wicks)!=0)
           {
            ObjectCreate(Wicks,OBJ_TREND,window,Time[i],VHigh[i],Time[i],VLow[i]);
           }
         ObjectSet(Wicks,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet(Wicks,OBJPROP_RAY,FALSE);
         ObjectSet(Wicks,OBJPROP_WIDTH,Wick);
         ObjectSet(Wicks,OBJPROP_TIME1,Time[i]);
         ObjectSet(Wicks,OBJPROP_PRICE1,VHigh[i]);
         ObjectSet(Wicks,OBJPROP_TIME2,Time[i]);
         ObjectSet(Wicks,OBJPROP_PRICE2,VLow[i]);

         Bodies="VC_OC_"+curBar;
         if(ObjectFind(Bodies)!=0)
           {
            ObjectCreate(Bodies,OBJ_TREND,window,Time[i],VOpen[i],Time[i],VClose[i]);
           }
         ObjectSet(Bodies,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSet(Bodies,OBJPROP_RAY,FALSE);
         ObjectSet(Bodies,OBJPROP_WIDTH,Body);
         ObjectSet(Bodies,OBJPROP_TIME1,Time[i]);
         ObjectSet(Bodies,OBJPROP_PRICE1,VOpen[i]);
         ObjectSet(Bodies,OBJPROP_TIME2,Time[i]);
         ObjectSet(Bodies,OBJPROP_PRICE2,VClose[i]);

         relativeClose=VClose[0];
         if(Open[i]<=Close[i])
           {
            ObjectSet(Wicks,OBJPROP_COLOR,Bullish_Color);
            ObjectSet(Bodies,OBJPROP_COLOR,Bullish_Color);
              }else{
            ObjectSet(Wicks,OBJPROP_COLOR,Bearish_Color);
            ObjectSet(Bodies,OBJPROP_COLOR,Bearish_Color);
           }

         // Create Price Line on VC
         ObjectCreate("VC_BarPrice",OBJ_HLINE,window,0,VClose[0]);
         ObjectSet("VC_BarPrice",OBJPROP_COLOR,Actual_Color);
         ObjectSet("VC_BarPrice",OBJPROP_PRICE1,relativeClose);

         // Begin Alerts Section
         if(useAlerts)
           {
            for(cnt=0; cnt<NumLevels; cnt++)
              {
               double level=levels[cnt];
               if(level>0)
                 {
                  if(relativeClose>=level && in[cnt]==false)
                    {
                     in[cnt]=true;
                     Alert(Symbol()," (",Period()," min) signal: Value chart above ",level,"!");
                    }
                  if(relativeClose<level-exitSig && in[cnt]==true)
                    {
                     in[cnt]=false;
                    }
                 }
               if(level<0)
                 {
                  if(relativeClose<=level && in[cnt]==false)
                    {
                     in[cnt]=true;
                     Alert(Symbol()," (",Period()," min) signal: Value chart below ",level,"!");
                    }

                  if(relativeClose>level+exitSig && in[cnt]==true)
                    {
                     in[cnt]=false;
                    }
                 }
              }
           }
        }
      // End Alerts Section
     }
   return(0);
  }
//----
// Market Value Added function
double MVA(int NumBars1,int CBar)
  {
   double sum,floatingAxis;
   for(int k=CBar; k<NumBars1+CBar; k++)
     {
      sum+=((High[k]+Low[k])/2.0);
     }
   floatingAxis=(sum/NumBars1);
   return(floatingAxis);
  }
// Average True Range Function
double ATR(int NumBars1,int CBar)
  {
   double sum,volitilityUnit;
   for(int k=CBar; k<NumBars1+CBar; k++)
     {
      sum+=(High[k]-Low[k]);
     }
   volitilityUnit=(0.2 *(sum/NumBars1));
   if(volitilityUnit==0 || volitilityUnit==0.0)
     {
      volitilityUnit=0.00000001;
     }
   return(volitilityUnit);
  }
//+------------------------------------------------------------------+
void patchExtBars()
  {
   ObjectsDeleteAll(WindowFind("Value Chart Deluxe Edition("+winTF+")"));
  }
//+------------------------------------------------------------------+
