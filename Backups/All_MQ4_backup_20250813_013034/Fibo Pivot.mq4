//+------------------------------------------------------------------+
//|                                                   Fibo Pivot.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#property description ""
#property indicator_chart_window
#property indicator_buffers   0

extern int              CountPeriods         = 2;
extern ENUM_TIMEFRAMES  TimePeriod           = PERIOD_W1;
extern bool             PlotPivots           = true;
extern bool             PlotFuturePivots     = false;
extern bool             PlotPivotLabels      = true;
extern bool             PlotPivotPrices      = false;
extern ENUM_LINE_STYLE  StylePivots          = STYLE_SOLID;
extern ENUM_LINE_STYLE  StylePP              = STYLE_DASHDOTDOT;
extern int              WidthPivots          = 1;
extern color            chose_color_R23      = clrOrchid;
extern color            chose_color_R38      = clrLime;
extern color            chose_color_R50      = clrTomato;
extern color            chose_color_R61     = clrAqua;
extern color            chose_color_R76     = clrOrange;
extern color            chose_color_R78     = clrOlive;
extern color            chose_color_R100      = clrOrchid;
extern color            chose_color_R123      = clrLime;
extern color            chose_color_R138      = clrTomato;
extern color            chose_color_R150     = clrAqua;
extern color            chose_color_R161     = clrOrange;
extern color            chose_color_R176     = clrOlive;
extern color            chose_color_R178     = clrOrange;
extern color            chose_color_R200     = clrOlive;

extern color            label_color_PP       = clrYellow;

extern color            chose_color_S23      = clrOrchid;
extern color            chose_color_S38      = clrLime;
extern color            chose_color_S50      = clrTomato;
extern color            chose_color_S61     = clrAqua;
extern color            chose_color_S76     = clrOrange;
extern color            chose_color_S78     = clrOlive;
extern color            chose_color_S100      = clrOrchid;
extern color            chose_color_S123      = clrLime;
extern color            chose_color_S138      = clrTomato;
extern color            chose_color_S150     = clrAqua;
extern color            chose_color_S161     = clrOrange;
extern color            chose_color_S176     = clrOlive;
extern color            chose_color_S178     = clrOrange;
extern color            chose_color_S200     = clrOlive;


extern bool             PlotZones            = false;
extern color            ColorBuyZone         = clrMidnightBlue;
extern color            ColorSellZone        = clrMaroon;
extern bool             PlotBorders          = false;
extern ENUM_LINE_STYLE  StyleBorder          = STYLE_SOLID;
extern int              WidthBorder          = 3;
extern color            ColorBorder          = 0x222222;



string   period;

datetime timestart,
         timeend;

double   open,
         close,
         high,
         low;

double   PP,         // Pivot Levels
         R1,
         R2,
         R3,
         R4,
         R5,
         R6,
         R7,
         R8,
         R9,
         R10,
         R11,
         R12,
         R13,
         R14,        
         S1,
         S2,
         S3,
         S4,
         S5,
         S6,
         S7,
         S8,
         S9,
         S10,
         S11,
         S12,
         S13,
         S14;         
         

int      shift;
     
void LevelsDelete(string name)
{
   ObjectDelete("R14"+name);
   ObjectDelete("R13"+name);
   ObjectDelete("R12"+name);
   ObjectDelete("R11"+name);
   ObjectDelete("R10"+name);
   ObjectDelete("R9"+name);
   ObjectDelete("R8"+name);
   ObjectDelete("R7"+name);
   ObjectDelete("R6"+name);
   ObjectDelete("R5"+name);
   ObjectDelete("R4"+name);
   ObjectDelete("R3"+name);
   ObjectDelete("R2"+name);
   ObjectDelete("R1"+name);
   ObjectDelete("PP"+name);
   ObjectDelete("S1"+name);
   ObjectDelete("S2"+name);
   ObjectDelete("S3"+name);
   ObjectDelete("S4"+name);
   ObjectDelete("S5"+name);
   ObjectDelete("S6"+name);
   ObjectDelete("S7"+name);
   ObjectDelete("S8"+name);
   ObjectDelete("S9"+name);
   ObjectDelete("S10"+name);
   ObjectDelete("S11"+name);
   ObjectDelete("S12"+name);
   ObjectDelete("S13"+name);
   ObjectDelete("S14"+name);
   
   ObjectDelete("R14P"+name);     
   ObjectDelete("R13P"+name); 
   ObjectDelete("R12P"+name);     
   ObjectDelete("R11P"+name);     
   ObjectDelete("R10P"+name);  
   ObjectDelete("R9P"+name);     
   ObjectDelete("R8P"+name);     
   ObjectDelete("R7P"+name);    
   ObjectDelete("R6P"+name);     
   ObjectDelete("R5P"+name);     
   ObjectDelete("R4P"+name);  
   ObjectDelete("R3P"+name);     
   ObjectDelete("R2P"+name);     
   ObjectDelete("R1P"+name);     
   ObjectDelete("PPP"+name);     
   ObjectDelete("S1P"+name);     
   ObjectDelete("S2P"+name);     
   ObjectDelete("S3P"+name);     
   ObjectDelete("S4P"+name);     
   ObjectDelete("S5P"+name);     
   ObjectDelete("S6P"+name);
   ObjectDelete("S7P"+name);     
   ObjectDelete("S8P"+name);     
   ObjectDelete("S9P"+name);     
   ObjectDelete("S10P"+name);     
   ObjectDelete("S11P"+name);     
   ObjectDelete("S12P"+name);
   ObjectDelete("S13P"+name);     
   ObjectDelete("S14P"+name);
     

   ObjectDelete("R14L"+name);     
   ObjectDelete("R13L"+name);   
   ObjectDelete("R12L"+name);     
   ObjectDelete("R11L"+name);     
   ObjectDelete("R10L"+name);                
   ObjectDelete("R9L"+name);     
   ObjectDelete("R8L"+name);     
   ObjectDelete("R7L"+name);    
   ObjectDelete("R6L"+name);     
   ObjectDelete("R5L"+name);     
   ObjectDelete("R4L"+name);                
   ObjectDelete("R3L"+name);     
   ObjectDelete("R2L"+name);     
   ObjectDelete("R1L"+name);     
   ObjectDelete("PPL"+name);     
   ObjectDelete("S1L"+name);     
   ObjectDelete("S2L"+name);     
   ObjectDelete("S3L"+name);     
   ObjectDelete("S4L"+name);     
   ObjectDelete("S5L"+name);     
   ObjectDelete("S6L"+name);
   ObjectDelete("S7L"+name);     
   ObjectDelete("S8L"+name);     
   ObjectDelete("S9L"+name);     
   ObjectDelete("S10L"+name);     
   ObjectDelete("S11L"+name);     
   ObjectDelete("S12L"+name);
   ObjectDelete("S13L"+name);     
   ObjectDelete("S14L"+name);
   
     

   ObjectDelete("BZ"+name);     
   ObjectDelete("SZ"+name);     
   
   ObjectDelete("BDU"+name);     
   ObjectDelete("BDD"+name);     
   ObjectDelete("BDL"+name);     
   ObjectDelete("BDR"+name);     
     
   
}

bool PlotTrend(const long              chart_ID=0,
               string                  name="trendline",
               const int               subwindow=0,
               datetime                time1=0,
               double                  price1=0,
               datetime                time2=0,
               double                  price2=0,             
               const color             clr=clrBlack,
               const ENUM_LINE_STYLE   style=STYLE_SOLID,
               const int               width=2,
               const bool              back=true,
               const bool              selection=false,
               const bool              ray=false,
               const bool              hidden=true)
{
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,subwindow,time1,price1,time2,price2))
   {
      Print(__FUNCTION__,": failed to create arrow = ",GetLastError());
      return(false);
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   return(true);
}

bool PlotRectangle(  const long        chart_ID=0,
                     string            name="rectangle", 
                     const int         subwindow=0,
                     datetime          time1=0,
                     double            price1=1,
                     datetime          time2=0, 
                     double            price2=0, 
                     const color       clr=clrGray,
                     const bool        back=true,
                     const bool        selection=false,
                     const bool        hidden=true)
{
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,subwindow,time1,price1,time2,price2))
   {
      Print(__FUNCTION__,": failed to create arrow = ",GetLastError());
      return(false);
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   return(true);
}

bool PlotText(       const long        chart_ID=0,
                     string            name="text", 
                     const int         subwindow=0,
                     datetime          time1=0, 
                     double            price1=0, 
                     const string      text="text",
                     const string      font="Arial",
                     const int         font_size=10,
                     const color       clr=clrGray,
                     const ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER,
                     const bool        back=true,
                     const bool        selection=false,
                     const bool        hidden=true)
{
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,subwindow,time1,price1))
   {
      Print(__FUNCTION__,": failed to create arrow = ",GetLastError());
      return(false);
   }
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   return(true);
} 
       
void LevelsDraw(  int      shft,
                  datetime tmestrt, 
                  datetime tmend, 
                  string   name,
                  bool     future)
{
   high  = iHigh(NULL,TimePeriod,shft);
   low   = iLow(NULL,TimePeriod,shft);
   open  = iOpen(NULL,TimePeriod,shft);
   if(future==false){close = iClose(NULL,TimePeriod,shft);}else{close = Bid;}      
     
   PP  = (high+low+close)/3.0;
           
   R1 = PP+(high - low)*0.236;
   R2 = PP+(high - low)*0.382;
   R3 = PP+(high - low)*0.50;
   R4 = PP+(high - low)*0.618;
   R5 = PP+(high - low)*0.764;
   R6 = PP+(high - low)*0.786;
   R7 = PP+(high - low)*1.00;
   R8 = PP+(high - low)*1.236;
   R9 = PP+(high - low)*1.382;
   R10 = PP+(high - low)*1.500;
   R11 = PP+(high - low)*1.618;
   R12 = PP+(high - low)*1.764;
   R13 = PP+(high - low)*1.786;
   R14 = PP+(high - low)*2.00;
               
   S1 = PP-(high - low)*0.236;
   S2 = PP-(high - low)*0.382;
   S3 = PP-(high - low)*0.50;
   S4 = PP-(high - low)*0.618;
   S5 = PP-(high - low)*0.764;
   S6 = PP-(high - low)*0.786;
   S7 = PP-(high - low)*1.00;
   S8 = PP-(high - low)*1.236;
   S9 = PP-(high - low)*1.382;
   S10 = PP-(high - low)*1.500;
   S11 = PP-(high - low)*1.618;
   S12 = PP-(high - low)*1.764;
   S13 = PP-(high - low)*1.786;
   S14 = PP-(high - low)*2.00;            
     
   
   
   if(PlotZones){
      PlotRectangle(0,"BZ"+name,0,tmestrt,S4,tmend,S7,ColorBuyZone);    
      PlotRectangle(0,"SZ"+name,0,tmestrt,R4,tmend,R7,ColorSellZone);}

   if(PlotPivots){
      PlotTrend(0,"R14"+name,0,tmestrt,R14,tmend,R14,chose_color_R200,StylePivots,WidthPivots);     
      PlotTrend(0,"R13"+name,0,tmestrt,R13,tmend,R13,chose_color_R178,StylePivots,WidthPivots);
      PlotTrend(0,"R12"+name,0,tmestrt,R12,tmend,R12,chose_color_R176,StylePivots,WidthPivots);     
      PlotTrend(0,"R11"+name,0,tmestrt,R11,tmend,R11,chose_color_R161,StylePivots,WidthPivots);     
      PlotTrend(0,"R10"+name,0,tmestrt,R10,tmend,R10,chose_color_R150,StylePivots,WidthPivots);  
      PlotTrend(0,"R9"+name,0,tmestrt,R9,tmend,R9,chose_color_R138,StylePivots,WidthPivots);     
      PlotTrend(0,"R8"+name,0,tmestrt,R8,tmend,R8,chose_color_R123,StylePivots,WidthPivots);     
      PlotTrend(0,"R7"+name,0,tmestrt,R7,tmend,R7,chose_color_R100,StylePivots,WidthPivots);                                  
      PlotTrend(0,"R6"+name,0,tmestrt,R6,tmend,R6,chose_color_R78,StylePivots,WidthPivots);     
      PlotTrend(0,"R5"+name,0,tmestrt,R5,tmend,R5,chose_color_R76,StylePivots,WidthPivots);     
      PlotTrend(0,"R4"+name,0,tmestrt,R4,tmend,R4,chose_color_R61,StylePivots,WidthPivots);  
      PlotTrend(0,"R3"+name,0,tmestrt,R3,tmend,R3,chose_color_R50,StylePivots,WidthPivots);     
      PlotTrend(0,"R2"+name,0,tmestrt,R2,tmend,R2,chose_color_R38,StylePivots,WidthPivots);     
      PlotTrend(0,"R1"+name,0,tmestrt,R1,tmend,R1,chose_color_R23,StylePivots,WidthPivots);
           
      PlotTrend(0,"PP"+name,0,tmestrt,PP,tmend,PP,label_color_PP,StylePP,WidthPivots);
           
      PlotTrend(0,"S1"+name,0,tmestrt,S1,tmend,S1,chose_color_S23,StylePivots,WidthPivots);     
      PlotTrend(0,"S2"+name,0,tmestrt,S2,tmend,S2,chose_color_S38,StylePivots,WidthPivots);     
      PlotTrend(0,"S3"+name,0,tmestrt,S3,tmend,S3,chose_color_S50,StylePivots,WidthPivots);
      PlotTrend(0,"S4"+name,0,tmestrt,S4,tmend,S4,chose_color_S61,StylePivots,WidthPivots);     
      PlotTrend(0,"S5"+name,0,tmestrt,S5,tmend,S5,chose_color_S76,StylePivots,WidthPivots);     
      PlotTrend(0,"S6"+name,0,tmestrt,S6,tmend,S6,chose_color_S78,StylePivots,WidthPivots);
      PlotTrend(0,"S7"+name,0,tmestrt,S7,tmend,S7,chose_color_S100,StylePivots,WidthPivots);     
      PlotTrend(0,"S8"+name,0,tmestrt,S8,tmend,S8,chose_color_S123,StylePivots,WidthPivots);     
      PlotTrend(0,"S9"+name,0,tmestrt,S9,tmend,S9,chose_color_S138,StylePivots,WidthPivots);
      PlotTrend(0,"S10"+name,0,tmestrt,S10,tmend,S10,chose_color_S150,StylePivots,WidthPivots);     
      PlotTrend(0,"S11"+name,0,tmestrt,S11,tmend,S11,chose_color_S161,StylePivots,WidthPivots);     
      PlotTrend(0,"S12"+name,0,tmestrt,S12,tmend,S12,chose_color_S176,StylePivots,WidthPivots);
      PlotTrend(0,"S13"+name,0,tmestrt,S13,tmend,S13,chose_color_S178,StylePivots,WidthPivots);     
      PlotTrend(0,"S14"+name,0,tmestrt,S14,tmend,S14,chose_color_S200,StylePivots,WidthPivots);
      
      
      if(PlotPivotLabels){
      
         PlotText(0,"R14L"+name,0,tmestrt,R14,"R200","Arial",7,chose_color_R200,ANCHOR_LEFT_UPPER);
         PlotText(0,"R13L"+name,0,tmestrt,R13,"R178","Arial",7,chose_color_R178,ANCHOR_LEFT_UPPER);
         PlotText(0,"R12L"+name,0,tmestrt,R12,"R176","Arial",7,chose_color_R176,ANCHOR_LEFT_UPPER);
         PlotText(0,"R11L"+name,0,tmestrt,R11,"R161","Arial",7,chose_color_R161,ANCHOR_LEFT_UPPER);
         PlotText(0,"R10L"+name,0,tmestrt,R10,"R150","Arial",7,chose_color_R150,ANCHOR_LEFT_UPPER);      
         PlotText(0,"R9L"+name,0,tmestrt,R9,"R138","Arial",7,chose_color_R138,ANCHOR_LEFT_UPPER);
         PlotText(0,"R8L"+name,0,tmestrt,R8,"R123","Arial",7,chose_color_R123,ANCHOR_LEFT_UPPER);
         PlotText(0,"R7L"+name,0,tmestrt,R7,"R100","Arial",7,chose_color_R100,ANCHOR_LEFT_UPPER);
         PlotText(0,"R6L"+name,0,tmestrt,R6,"R78","Arial",7,chose_color_R78,ANCHOR_LEFT_UPPER);
         PlotText(0,"R5L"+name,0,tmestrt,R5,"R76","Arial",7,chose_color_R76,ANCHOR_LEFT_UPPER);
         PlotText(0,"R4L"+name,0,tmestrt,R4,"R61","Arial",7,chose_color_R61,ANCHOR_LEFT_UPPER);      
         PlotText(0,"R3L"+name,0,tmestrt,R3,"R50","Arial",7,chose_color_R50,ANCHOR_LEFT_UPPER);
         PlotText(0,"R2L"+name,0,tmestrt,R2,"R38","Arial",7,chose_color_R38,ANCHOR_LEFT_UPPER);
         PlotText(0,"R1L"+name,0,tmestrt,R1,"R23","Arial",7,chose_color_R23,ANCHOR_LEFT_UPPER);
         
         PlotText(0,"PPL"+name,0,tmestrt,PP,"PP","Arial",7,label_color_PP,ANCHOR_LEFT_UPPER);
         
         PlotText(0,"S1L"+name,0,tmestrt,S1,"S23","Arial",7,chose_color_S23,ANCHOR_LEFT_UPPER);
         PlotText(0,"S2L"+name,0,tmestrt,S2,"S38","Arial",7,chose_color_S38,ANCHOR_LEFT_UPPER);
         PlotText(0,"S3L"+name,0,tmestrt,S3,"S50","Arial",7,chose_color_S50,ANCHOR_LEFT_UPPER);            
         PlotText(0,"S4L"+name,0,tmestrt,S4,"S61","Arial",7,chose_color_S61,ANCHOR_LEFT_UPPER);
         PlotText(0,"S5L"+name,0,tmestrt,S5,"S76","Arial",7,chose_color_S76,ANCHOR_LEFT_UPPER);
         PlotText(0,"S6L"+name,0,tmestrt,S6,"S78","Arial",7,chose_color_S78,ANCHOR_LEFT_UPPER);}    
         PlotText(0,"S7L"+name,0,tmestrt,S7,"S100","Arial",7,chose_color_S100,ANCHOR_LEFT_UPPER);
         PlotText(0,"S8L"+name,0,tmestrt,S8,"S123","Arial",7,chose_color_S123,ANCHOR_LEFT_UPPER);
         PlotText(0,"S9L"+name,0,tmestrt,S9,"S138","Arial",7,chose_color_S138,ANCHOR_LEFT_UPPER);            
         PlotText(0,"S10L"+name,0,tmestrt,S10,"S150","Arial",7,chose_color_S150,ANCHOR_LEFT_UPPER);
         PlotText(0,"S11L"+name,0,tmestrt,S11,"S161","Arial",7,chose_color_S161,ANCHOR_LEFT_UPPER);
         PlotText(0,"S12L"+name,0,tmestrt,S12,"S176","Arial",7,chose_color_S176,ANCHOR_LEFT_UPPER); 
         PlotText(0,"S13L"+name,0,tmestrt,S13,"S178","Arial",7,chose_color_S178,ANCHOR_LEFT_UPPER);
         PlotText(0,"S14L"+name,0,tmestrt,S14,"S200","Arial",7,chose_color_S200,ANCHOR_LEFT_UPPER);} 
      
      
      if(PlotPivotPrices){
      
      
         PlotText(0,"R14P"+name,0,tmestrt,R14,DoubleToString(R14,4),"Arial",7,chose_color_R200,ANCHOR_LEFT_LOWER);
         PlotText(0,"R13P"+name,0,tmestrt,R13,DoubleToString(R13,4),"Arial",7,chose_color_R178,ANCHOR_LEFT_LOWER);
         PlotText(0,"R12P"+name,0,tmestrt,R12,DoubleToString(R12,4),"Arial",7,chose_color_R176,ANCHOR_LEFT_LOWER);
         PlotText(0,"R11P"+name,0,tmestrt,R11,DoubleToString(R11,4),"Arial",7,chose_color_R161,ANCHOR_LEFT_LOWER);
         PlotText(0,"R10P"+name,0,tmestrt,R10,DoubleToString(R10,4),"Arial",7,chose_color_R150,ANCHOR_LEFT_LOWER);
         PlotText(0,"R9P"+name,0,tmestrt,R9,DoubleToString(R9,4),"Arial",7,chose_color_R138,ANCHOR_LEFT_LOWER);
         PlotText(0,"R8P"+name,0,tmestrt,R8,DoubleToString(R8,4),"Arial",7,chose_color_R123,ANCHOR_LEFT_LOWER);
         PlotText(0,"R7P"+name,0,tmestrt,R7,DoubleToString(R7,4),"Arial",7,chose_color_R100,ANCHOR_LEFT_LOWER);
         PlotText(0,"R6P"+name,0,tmestrt,R6,DoubleToString(R6,4),"Arial",7,chose_color_R78,ANCHOR_LEFT_LOWER);
         PlotText(0,"R5P"+name,0,tmestrt,R5,DoubleToString(R5,4),"Arial",7,chose_color_R76,ANCHOR_LEFT_LOWER);
         PlotText(0,"R4P"+name,0,tmestrt,R4,DoubleToString(R4,4),"Arial",7,chose_color_R61,ANCHOR_LEFT_LOWER);
         PlotText(0,"R3P"+name,0,tmestrt,R3,DoubleToString(R3,4),"Arial",7,chose_color_R50,ANCHOR_LEFT_LOWER);
         PlotText(0,"R2P"+name,0,tmestrt,R2,DoubleToString(R2,4),"Arial",7,chose_color_R38,ANCHOR_LEFT_LOWER);
         PlotText(0,"R1P"+name,0,tmestrt,R1,DoubleToString(R1,4),"Arial",7,chose_color_R23,ANCHOR_LEFT_LOWER);
         
         PlotText(0,"PPP"+name,0,tmestrt,PP,DoubleToString(PP,4),"Arial",7,label_color_PP,ANCHOR_LEFT_LOWER);
         
         PlotText(0,"S1P"+name,0,tmestrt,S1,DoubleToString(S1,4),"Arial",7,chose_color_S23,ANCHOR_LEFT_LOWER);
         PlotText(0,"S2P"+name,0,tmestrt,S2,DoubleToString(S2,4),"Arial",7,chose_color_S38,ANCHOR_LEFT_LOWER);
         PlotText(0,"S3P"+name,0,tmestrt,S3,DoubleToString(S3,4),"Arial",7,chose_color_S50,ANCHOR_LEFT_LOWER);
         PlotText(0,"S4P"+name,0,tmestrt,S4,DoubleToString(S4,4),"Arial",7,chose_color_S61,ANCHOR_LEFT_LOWER);
         PlotText(0,"S5P"+name,0,tmestrt,S5,DoubleToString(S5,4),"Arial",7,chose_color_S76,ANCHOR_LEFT_LOWER);
         PlotText(0,"S6P"+name,0,tmestrt,S6,DoubleToString(S6,4),"Arial",7,chose_color_S78,ANCHOR_LEFT_LOWER);    
         PlotText(0,"S7P"+name,0,tmestrt,S7,DoubleToString(S7,4),"Arial",7,chose_color_S100,ANCHOR_LEFT_LOWER);
         PlotText(0,"S8P"+name,0,tmestrt,S8,DoubleToString(S8,4),"Arial",7,chose_color_S123,ANCHOR_LEFT_LOWER);
         PlotText(0,"S9P"+name,0,tmestrt,S9,DoubleToString(S9,4),"Arial",7,chose_color_S138,ANCHOR_LEFT_LOWER);
         PlotText(0,"S10P"+name,0,tmestrt,S10,DoubleToString(S10,4),"Arial",7,chose_color_S150,ANCHOR_LEFT_LOWER);
         PlotText(0,"S11P"+name,0,tmestrt,S11,DoubleToString(S11,4),"Arial",7,chose_color_S161,ANCHOR_LEFT_LOWER);
         PlotText(0,"S12P"+name,0,tmestrt,S12,DoubleToString(S12,4),"Arial",7,chose_color_S176,ANCHOR_LEFT_LOWER);   
         PlotText(0,"S13P"+name,0,tmestrt,S13,DoubleToString(S13,4),"Arial",7,chose_color_S178,ANCHOR_LEFT_LOWER);
         PlotText(0,"S14P"+name,0,tmestrt,S14,DoubleToString(S14,4),"Arial",7,chose_color_S200,ANCHOR_LEFT_LOWER);}}

  
   if(PlotBorders){
   if((future==false)&&(shift != 0)){
//    PlotTrend(0,"BDU"+name,0,tmestrt,R3,tmend,R3,ColorBorder,StyleBorder,WidthBorder);      // top
//    PlotTrend(0,"BDD"+name,0,tmestrt,S3,tmend,S3,ColorBorder,StyleBorder,WidthBorder);      // bottom
      PlotTrend(0,"BDL"+name,0,tmestrt,R6,tmestrt,S6,ColorBorder,StyleBorder,WidthBorder);    // left
      PlotTrend(0,"BDR"+name,0,tmend,R6,tmend,S6,ColorBorder,StyleBorder,WidthBorder);}}      // right



int init()
{
   if(TimePeriod==PERIOD_M1||TimePeriod==PERIOD_CURRENT){TimePeriod=PERIOD_M5;period="M5";}
   if(TimePeriod==PERIOD_M5){period="M5";}
   if(TimePeriod==PERIOD_M15){period="M15";}
   if(TimePeriod==PERIOD_M30){period="M30";}
   if(TimePeriod==PERIOD_H1){period="H1";}
   if(TimePeriod==PERIOD_H4){period="H4";}
   if(TimePeriod==PERIOD_D1){period="D1";}
   if(TimePeriod==PERIOD_W1){period="W1";}
   if(TimePeriod==PERIOD_MN1){period="MN1";}  
   return(0);
}   
   
int deinit()
{
   for(shift=0;shift<=CountPeriods;shift++)
   {
      LevelsDelete(period+shift);
   }
   LevelsDelete("F"+period);
   Comment("");
   return(0);
}

int start()
{
   for(shift=0;shift<=CountPeriods;shift++)
   {
      LevelsDelete(period+shift);
   }
   LevelsDelete("F"+period);
   
   for(shift=CountPeriods-1;shift>=0;shift--)
   {
      timestart = iTime(NULL,TimePeriod,shift);
      timeend   = iTime(NULL,TimePeriod,shift)+TimePeriod*60;   
         
      LevelsDraw(shift+1,timestart,timeend,period+shift,false);                
   }
   
   if(PlotFuturePivots)
   {
      timestart=iTime(NULL,TimePeriod,0)+TimePeriod*60;
      timeend=iTime(NULL,TimePeriod,0)+TimePeriod*120;

      LevelsDraw(0,timestart,timeend,"F"+period,true);      
   }
   
   return(0);
}