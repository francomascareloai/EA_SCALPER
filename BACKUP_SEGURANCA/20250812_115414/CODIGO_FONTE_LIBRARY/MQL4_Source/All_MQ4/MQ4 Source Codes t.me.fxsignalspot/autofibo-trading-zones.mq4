//---------------------------------------------+
//                          AutoFib TradeZones |
//         © 2010 Eagleye777, www.fxtools.info |
//           *Mod of AutoFibo by Julien Loutre |
//                           www.forexcomm.com |
//---------------------------------------------+
#property link "http://www.fxtools.info"
#property  indicator_chart_window
#property indicator_buffers  2
#property  indicator_color1  MidnightBlue
#property  indicator_color2  FireBrick
 
extern int Fib_Period = 240; 
extern bool Show_StartLine = false;
extern bool Show_EndLine = false;
extern bool Show_Channel = false;
extern int Fib_Style = 5;
extern color Fib_Color = Gold;
extern color StartLine_Color = RoyalBlue; 
extern color EndLine_Color = FireBrick; 
extern color BuyZone_Color = MidnightBlue;
extern color SellZone_Color = FireBrick;
 
//---- buffers
double WWBuffer1[];
double WWBuffer2[];
 
double level_array[10]={0,0.236,0.382,0.5,0.618,0.764,1,1.618,2.618,4.236};
string leveldesc_array[13]={"0","23.6%","38.2%","50%","61.8%","76.4%","100%","161.8%","261.80%","423.6%"};
int level_count;
string level_name;
string StartLine = "Start Line";
string EndLine = "End Line";
 
int init() {
   IndicatorBuffers(2);
if (Show_Channel)
   {
   SetIndexStyle(0,DRAW_LINE,1);
   SetIndexStyle(1,DRAW_LINE,1);
   
   SetIndexLabel(0, "High");
   SetIndexLabel(1, "Low");
   
   SetIndexBuffer(0, WWBuffer1);
   SetIndexBuffer(1, WWBuffer2);
   }
   IndicatorDigits(Digits+2);
   
   IndicatorShortName("AutoFib TradeZones");
   
   ObjectCreate("FibLevels", OBJ_FIBO, 0, Time[0],High[0],Time[0],Low[0]);
   ObjectCreate("BuyZone", OBJ_RECTANGLE, 0,0,0,0);
   ObjectCreate("SellZone", OBJ_RECTANGLE, 0,0,0,0);
   
   if (Show_StartLine)
        {if (ObjectFind(StartLine)==-1)
           {
            ObjectCreate(StartLine,OBJ_VLINE,0,Time[Fib_Period],Close[0]);
            ObjectSet(StartLine,OBJPROP_COLOR,StartLine_Color);
           }
        } 
    if (Show_EndLine)
        {if (ObjectFind(EndLine)==-1)
           {
            ObjectCreate(EndLine,OBJ_VLINE,0,Time[0],Close[0]);
            ObjectSet(EndLine,OBJPROP_COLOR,EndLine_Color);
           }
        } 
   return(0);
}
int deinit() {
   ObjectDelete("FibLevels");
   ObjectDelete("BuyZone");
   ObjectDelete("SellZone");
}
int start() {
 
 //Start Line -------------------------------------------
   int BarShift;
  if (Show_StartLine)
  {   
   datetime HLineTime=ObjectGet(StartLine,OBJPROP_TIME1);

   if (HLineTime>=Time[0]) {BarShift=0;}
     BarShift=iBarShift(NULL,0,HLineTime);
  }   
   else if (!Show_StartLine){BarShift=0;}
   if (ObjectFind(StartLine)==-1) {BarShift=0;}
   
 //End Line -------------------------------------------
   int BarShift2;
  if (Show_EndLine)
  {   
   datetime HLine2Time=ObjectGet(EndLine,OBJPROP_TIME1);

   if (HLine2Time>=Time[0]) {BarShift2=0;}
     BarShift2=iBarShift(NULL,0,HLine2Time);
  }   
   else if (!Show_EndLine){BarShift2=0;}
   if (ObjectFind(EndLine)==-1) {BarShift2=0;}   
//----------------------------------------------------------
 
   double SellZoneHigh,BuyZoneLow;
   if (Show_StartLine)
    {
    SellZoneHigh = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,BarShift-BarShift2,BarShift2+1));
    BuyZoneLow = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,BarShift-BarShift2,BarShift2+1));
    }
      if (!Show_StartLine)
    {
    SellZoneHigh = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,Fib_Period,1));
    BuyZoneLow = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,Fib_Period,1));
    } 
   double PriceRange = SellZoneHigh - BuyZoneLow; 
   double BuyZoneHigh = BuyZoneLow + (0.236*PriceRange);
   double SellZoneLow = SellZoneHigh - (0.236*PriceRange);
   datetime StartZoneTime =Time[Fib_Period];
   datetime EndZoneTime =Time[0]+Time[0];
   
   level_count=ArraySize(level_array);
   
   int    counted_bars=IndicatorCounted();
   int    limit,i;
   
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for(i=limit-1; i>=0; i--) {
 
      WWBuffer1[i] = getPeriodHigh(Fib_Period,i);
      WWBuffer2[i] = getPeriodLow(Fib_Period,i);
      
      if (Show_StartLine)
      {ObjectSet("FibLevels", OBJPROP_TIME1, Time[BarShift]);
       ObjectSet("FibLevels", OBJPROP_TIME2, Time[BarShift2]);}
      if (!Show_StartLine)
      {ObjectSet("FibLevels", OBJPROP_TIME1, StartZoneTime);}
      ObjectSet("FibLevels", OBJPROP_TIME2, Time[0]);
      if (Open[Fib_Period] < Open[0]) // Up
      { 
        if (Show_StartLine)
         {
         ObjectSet("FibLevels", OBJPROP_PRICE1, SellZoneHigh);
         ObjectSet("FibLevels", OBJPROP_PRICE2, BuyZoneLow);
         }
        if (!Show_StartLine)
         {
         ObjectSet("FibLevels", OBJPROP_PRICE1, getPeriodHigh(Fib_Period,i));
         ObjectSet("FibLevels", OBJPROP_PRICE2, getPeriodLow(Fib_Period,i));
         } 
      } else {
        if (Show_StartLine)
         {
         ObjectSet("FibLevels", OBJPROP_PRICE1, BuyZoneLow);
         ObjectSet("FibLevels", OBJPROP_PRICE2, SellZoneHigh);
         }
        if (!Show_StartLine)
         {
         ObjectSet("FibLevels", OBJPROP_PRICE1, getPeriodLow(Fib_Period,i));
         ObjectSet("FibLevels", OBJPROP_PRICE2, getPeriodHigh(Fib_Period,i));
         }
      }
      ObjectSet("FibLevels", OBJPROP_LEVELCOLOR, Fib_Color);
      ObjectSet("FibLevels", OBJPROP_STYLE, Fib_Style);
      ObjectSet("FibLevels", OBJPROP_FIBOLEVELS, level_count);
         for(int j=0; j<level_count; j++)
      {
      ObjectSet("FibLevels", OBJPROP_FIRSTLEVEL+j, level_array[j]);
      ObjectSetFiboDescription("FibLevels",j,leveldesc_array[j]);
      }
   
      if (Show_StartLine)
      {ObjectSet("BuyZone", OBJPROP_TIME2, Time[BarShift]);
       ObjectSet("BuyZone", OBJPROP_TIME1, Time[BarShift2]);}
      if (!Show_StartLine)
      {ObjectSet("BuyZone", OBJPROP_TIME2, StartZoneTime);}
      ObjectSet("BuyZone", OBJPROP_TIME1, EndZoneTime);
      ObjectSet("BuyZone", OBJPROP_PRICE1, BuyZoneLow);
      ObjectSet("BuyZone", OBJPROP_PRICE2, BuyZoneHigh);
      ObjectSet("BuyZone", OBJPROP_COLOR, BuyZone_Color);
      
      if (Show_StartLine)
      {ObjectSet("SellZone", OBJPROP_TIME2, Time[BarShift]);
      ObjectSet("SellZone", OBJPROP_TIME1, Time[BarShift2]);}
      if (!Show_StartLine)
      {ObjectSet("SellZone", OBJPROP_TIME2, StartZoneTime);}
      ObjectSet("SellZone", OBJPROP_TIME1, EndZoneTime);
      ObjectSet("SellZone", OBJPROP_PRICE1, SellZoneLow);
      ObjectSet("SellZone", OBJPROP_PRICE2, SellZoneHigh);
      ObjectSet("SellZone", OBJPROP_COLOR, SellZone_Color);
   }
   return(0);
}
 
double getPeriodHigh(int period, int pos) 
{
   int i;
   double buffer = 0;
   for (i=pos;i<=pos+period;i++) 
   {
       if (High[i] > buffer) 
         {
            buffer = High[i];
         }
       else {
         if (Open[i] > Close[i]) // Down
         { 
            if (Open[i] > buffer) 
            {
               buffer = Open[i];
            }
         } 
      }
   }
   return (buffer);
}
double getPeriodLow(int period, int pos) {
   int i;
   double buffer = 100000;
   for (i=pos;i<=pos+period;i++) 
   {
         if (Low[i] < buffer) 
         {
            buffer = Low[i];
         }
       else {
         if (Open[i] > Close[i]) // Down
         {
            if (Close[i] < buffer) 
            {
               buffer = Close[i];
            }
         } else {
            if (Open[i] < buffer) {
               buffer = Open[i];
            }
         }
      }
   }
   return (buffer);
}