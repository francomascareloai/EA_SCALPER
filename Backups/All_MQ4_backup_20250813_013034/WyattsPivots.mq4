//+------------------------------------------------------------------+
//|                                                  WyattsPivots.mq4|
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers   0

extern int              CountPeriods=20;
extern ENUM_TIMEFRAMES  TimePeriod=PERIOD_D1;
extern bool             PlotPivots=true;
extern bool             PlotFuturePivots=true;
extern bool             PlotPivotPrices=false;
extern ENUM_LINE_STYLE  StylePivots=STYLE_SOLID;
extern int              WidthPivots=2;
extern color            ColorRes=clrRed;
extern color            ColorPP=clrGray;
extern color            ColorSup=clrGreen;
extern bool             PlotMiddle=true;
extern ENUM_LINE_STYLE  StyleMidpoints=STYLE_DASH;
extern int              WidthMidpoints=1;
extern color            ColorM35=clrRed;
extern color            ColorM02=clrGreen;
extern bool             PlotZones=true;
extern color            ColorBuyZone=clrLightGreen;
extern color            ColorSellZone=clrPink;
extern bool             PlotBorders=true;
extern ENUM_LINE_STYLE  StyleBorder=STYLE_SOLID;
extern int              WidthBorder=2;
extern color            ColorBorder=clrBlack;
extern bool             PlotFibots=false;
extern bool             PlotFibotPrices=true;
extern ENUM_LINE_STYLE  StyleFibots1=STYLE_DOT;
extern ENUM_LINE_STYLE  StyleFibots2=STYLE_SOLID;
extern int              WidthFibots1=1;
extern int              WidthFibots2=1;
extern color            ColorFibots=clrSilver;
extern bool             PlotYesterdayOHLC=false;
extern bool             PlotOHLCPrices=true;
extern ENUM_LINE_STYLE  StyleOHLC=STYLE_DOT;
extern int              WidthOHLC=1;
extern color            ColorO=clrGold;
extern color            ColorH=clrRed;
extern color            ColorL=clrGreen;
extern color            ColorC=clrMagenta;

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
         S1,
         S2,
         S3,
         M0,
         M1,
         M2,
         M3,
         M4,
         M5,   
         f214,       // Fibot Levels
         f236,
         f382,
         f50,
         f618,
         f764,
         f786,
         rangeopen1, // OHLC Levels
         rangeopen2,
         rangeclose1,
         rangeclose2;

int      shift; 
     
void LevelsDelete(string name)
{
   ObjectDelete("R3"+name);
   ObjectDelete("R2"+name);
   ObjectDelete("R1"+name);
   ObjectDelete("PP"+name);
   ObjectDelete("S1"+name);
   ObjectDelete("S2"+name);
   ObjectDelete("S3"+name);

   ObjectDelete("R3P"+name);     
   ObjectDelete("R2P"+name);     
   ObjectDelete("R1P"+name);     
   ObjectDelete("PPP"+name);     
   ObjectDelete("S1P"+name);     
   ObjectDelete("S2P"+name);     
   ObjectDelete("S3P"+name);     
           
   ObjectDelete("M0"+name);
   ObjectDelete("M1"+name);
   ObjectDelete("M2"+name);
   ObjectDelete("M3"+name);
   ObjectDelete("M4"+name);
   ObjectDelete("M5"+name);
                 
   ObjectDelete("BZ"+name);     
   ObjectDelete("SZ"+name);     
   
   ObjectDelete("BDU"+name);     
   ObjectDelete("BDD"+name);     
   ObjectDelete("BDL"+name);     
   ObjectDelete("BDR"+name);     
     
   ObjectDelete("M0P"+name);     
   ObjectDelete("M1P"+name);     
   ObjectDelete("M2P"+name);     
   ObjectDelete("M3P"+name);     
   ObjectDelete("M4P"+name);     
   ObjectDelete("M5P"+name);     

   ObjectDelete("f214a"+name);
   ObjectDelete("f236a"+name);
   ObjectDelete("f382a"+name);
   ObjectDelete("f50a"+name);
   ObjectDelete("f618a"+name);
   ObjectDelete("f764a"+name);
   ObjectDelete("f786a"+name);
      
   ObjectDelete("f214b"+name);
   ObjectDelete("f236b"+name);
   ObjectDelete("f382b"+name);
   ObjectDelete("f50b"+name);
   ObjectDelete("f618b"+name);
   ObjectDelete("f764b"+name);
   ObjectDelete("f786b"+name);
      
   ObjectDelete("f214p"+name);
   ObjectDelete("f236p"+name);
   ObjectDelete("f382p"+name);
   ObjectDelete("f50p"+name);
   ObjectDelete("f618p"+name);
   ObjectDelete("f764p"+name);
   ObjectDelete("f786p"+name);
      
   ObjectDelete("open"+name);
   ObjectDelete("high"+name);
   ObjectDelete("low"+name);
   ObjectDelete("close"+name);

   ObjectDelete("openp"+name);
   ObjectDelete("highp"+name);
   ObjectDelete("lowp"+name);
   ObjectDelete("closep"+name);
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
                     const ENUM_ANCHOR_POINT anchor = ANCHOR_RIGHT_UPPER,
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
   if(future==false){close = iClose(NULL,TimePeriod,shft);}
   else{close = Bid;}      
     
   PP  = (high+low+close)/3.0;
           
   R1 = 2*PP-low;
   R2 = PP+(high - low);
   R3 = (2*PP)+(high-(2*low));
            
   S1 = 2*PP-high;
   S2 = PP-(high - low);
   S3 = (2*PP)-((2*high)-low);
             
   M0=0.5*(S2+S3);
   M1=0.5*(S1+S2);
   M2=0.5*(PP+S1);
   M3=0.5*(PP+R1);
   M4=0.5*(R1+R2);
   M5=0.5*(R2+R3);
      
   f214 = (low+(((high-low)/100)*(100-21.4)));
   f236 = (low+(((high-low)/100)*(100-23.6)));
   f382 = (low+(((high-low)/100)*(100-38.2)));
   f50  = (low+(((high-low)/100)*(100-50)));
   f618 = (low+(((high-low)/100)*(38.2)));
   f764 = (low+(((high-low)/100)*(23.6)));
   f786 = (low+(((high-low)/100)*(21.4)));
      
   rangeopen1  = (open-low)/((high-low)/100);
   rangeopen2  = 100-((open-low)/((high-low)/100));
   rangeclose1 = (close-low)/((high-low)/100);
   rangeclose2 = 100-((close-low)/((high-low)/100));   

   if(PlotPivots){                                 
      PlotTrend(0,"R3"+name,0,tmestrt,R3,tmend,R3,ColorRes,StylePivots,WidthPivots);     
      PlotTrend(0,"R2"+name,0,tmestrt,R2,tmend,R2,ColorRes,StylePivots,WidthPivots);     
      PlotTrend(0,"R1"+name,0,tmestrt,R1,tmend,R1,ColorRes,StylePivots,WidthPivots);     
      PlotTrend(0,"PP"+name,0,tmestrt,PP,tmend,PP,ColorPP,StylePivots,WidthPivots);     
      PlotTrend(0,"S1"+name,0,tmestrt,S1,tmend,S1,ColorSup,StylePivots,WidthPivots);     
      PlotTrend(0,"S2"+name,0,tmestrt,S2,tmend,S2,ColorSup,StylePivots,WidthPivots);     
      PlotTrend(0,"S3"+name,0,tmestrt,S3,tmend,S3,ColorSup,StylePivots,WidthPivots);
      if(PlotPivotPrices){
         PlotText(0,"R3P"+name,0,tmend,R3,DoubleToString(R3,4),"Arial",8,ColorRes,6);
         PlotText(0,"R2P"+name,0,tmend,R2,DoubleToString(R2,4),"Arial",8,ColorRes,6);
         PlotText(0,"R1P"+name,0,tmend,R1,DoubleToString(R1,4),"Arial",8,ColorRes,6);
         PlotText(0,"PPP"+name,0,tmend,PP,DoubleToString(PP,4),"Arial",8,ColorPP,6);
         PlotText(0,"S1P"+name,0,tmend,S1,DoubleToString(S1,4),"Arial",8,ColorSup,6);
         PlotText(0,"S2P"+name,0,tmend,S2,DoubleToString(S2,4),"Arial",8,ColorSup,6);
         PlotText(0,"S3P"+name,0,tmend,S3,DoubleToString(S3,4),"Arial",8,ColorSup,6);}}    

   if(PlotMiddle){
      PlotTrend(0,"M0"+name,0,tmestrt,M0,tmend,M0,ColorM02,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M1"+name,0,tmestrt,M1,tmend,M1,ColorM02,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M2"+name,0,tmestrt,M2,tmend,M2,ColorM02,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M3"+name,0,tmestrt,M3,tmend,M3,ColorM35,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M4"+name,0,tmestrt,M4,tmend,M4,ColorM35,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M5"+name,0,tmestrt,M5,tmend,M5,ColorM35,StyleMidpoints,WidthMidpoints);
      if(PlotPivotPrices){
         PlotText(0,"M0P"+name,0,tmend,M0,DoubleToString(M0,4),"Arial",8,ColorSup,6);
         PlotText(0,"M1P"+name,0,tmend,M1,DoubleToString(M1,4),"Arial",8,ColorSup,6);
         PlotText(0,"M2P"+name,0,tmend,M2,DoubleToString(M2,4),"Arial",8,ColorSup,6);
         PlotText(0,"M3P"+name,0,tmend,M3,DoubleToString(M3,4),"Arial",8,ColorRes,6);
         PlotText(0,"M4P"+name,0,tmend,M4,DoubleToString(M4,4),"Arial",8,ColorRes,6);
         PlotText(0,"M5P"+name,0,tmend,M5,DoubleToString(M5,4),"Arial",8,ColorRes,6);}}   
 
   if(PlotZones){
      PlotRectangle(0,"BZ"+name,0,tmestrt,M1,tmend,S2,ColorBuyZone);    
      PlotRectangle(0,"SZ"+name,0,tmestrt,M4,tmend,R2,ColorSellZone);}
   
   if(PlotBorders){
      PlotTrend(0,"BDU"+name,0,tmestrt,R2,tmend,R2,ColorBorder,StyleBorder,WidthBorder);     
      PlotTrend(0,"BDD"+name,0,tmestrt,S2,tmend,S2,ColorBorder,StyleBorder,WidthBorder);     
      PlotTrend(0,"BDL"+name,0,tmestrt,R2,tmestrt,S2,ColorBorder,StyleBorder,WidthBorder);     
      PlotTrend(0,"BDR"+name,0,tmend,R2,tmend,S2,ColorBorder,StyleBorder,WidthBorder);}
              
   if(PlotFibots){
      PlotTrend(0,"f214a"+name,0,tmestrt,f214,tmend,f214,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f382a"+name,0,tmestrt,f382,tmend,f382,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f50a"+name,0,tmestrt,f50,tmend,f50,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f618a"+name,0,tmestrt,f618,tmend,f618,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f786a"+name,0,tmestrt,f786,tmend,f786,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f214b"+name,0,tmestrt+TimePeriod*10,f214,tmend,f214,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f382b"+name,0,tmestrt+TimePeriod*10,f382,tmend,f382,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f50b"+name,0,tmestrt+TimePeriod*10,f50,tmend,f50,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f618b"+name,0,tmestrt+TimePeriod*10,f618,tmend,f618,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f786b"+name,0,tmestrt+TimePeriod*10,f786,tmend,f786,ColorFibots,StyleFibots2,WidthFibots2);
      if(PlotFibotPrices){
         PlotText(0,"f214p"+name,0,tmend,f214,"21.4%","Arial",8,ColorFibots,6);         
         PlotText(0,"f382p"+name,0,tmend,f382,"38.2%","Arial",8,ColorFibots,6);         
         PlotText(0,"f50p"+name,0,tmend,f50,"50%","Arial",8,ColorFibots,6);         
         PlotText(0,"f618p"+name,0,tmend,f618,"61.8%","Arial",8,ColorFibots,6);         
         PlotText(0,"f786p"+name,0,tmend,f786,"78.8%","Arial",8,ColorFibots,6);}}
         
   if(PlotYesterdayOHLC){
      PlotTrend(0,"open"+name,0,tmestrt,open,tmestrt+TimePeriod*10,open,ColorO,StyleOHLC,WidthOHLC);
      PlotTrend(0,"high"+name,0,tmestrt,high,tmestrt+TimePeriod*10,high,ColorH,StyleOHLC,WidthOHLC);
      PlotTrend(0,"low"+name,0,tmestrt,low,tmestrt+TimePeriod*10,low,ColorL,StyleOHLC,WidthOHLC);
      PlotTrend(0,"close"+name,0,tmestrt,close,tmestrt+TimePeriod*10,close,ColorC,StyleOHLC,WidthOHLC);         
      if(PlotOHLCPrices){
         PlotText(0,"openp"+name,0,tmestrt+TimePeriod*10,open,DoubleToString(rangeopen1,1)+"/"+DoubleToString(rangeopen2,1)+"%","Arial",8,ColorO,6);
         PlotText(0,"closep"+name,0,tmestrt+TimePeriod*10,close,DoubleToString(rangeclose1,1)+"/"+DoubleToString(rangeclose2,1)+"%","Arial",8,ColorC,6);}}   
}

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