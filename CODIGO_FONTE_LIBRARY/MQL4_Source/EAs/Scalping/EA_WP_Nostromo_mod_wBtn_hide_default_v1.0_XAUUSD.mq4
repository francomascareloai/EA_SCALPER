//+------------------------------------------------------------------+
//|                                                  WyattsPivots.mq4|
//+------------------------------------------------------------------+
//modified aug 2020
// - optional show/hide btn
//modified 2 sept 2020
// - btn visible, load on hide by default

#property indicator_chart_window
#property indicator_buffers   0

extern int              CountPeriods=10;
extern ENUM_TIMEFRAMES  TimePeriod=PERIOD_W1;
extern bool             PlotPivots=true;
extern bool             PlotFuturePivots=false;
extern bool             PlotPivotLabels=false;
extern bool             PlotPivotPrices=true;
extern ENUM_LINE_STYLE  StylePivots=STYLE_SOLID;
extern int              WidthPivots=3;
extern color            ColorRes=clrMaroon;
extern color            ColorPP=clrLightGray;
extern color            ColorSup=clrGreen;
extern bool             PlotMiddle=false;
extern ENUM_LINE_STYLE  StyleMidpoints=STYLE_DASH;
extern int              WidthMidpoints=1;
extern color            ColorM35=clrRed;
extern color            ColorM02=clrGreen;
extern bool             PlotZones=true;
extern color            ColorBuyZone=clrLightSeaGreen;
extern color            ColorSellZone=clrLightSalmon;
extern bool             PlotBorders=true;
extern ENUM_LINE_STYLE  StyleBorder=STYLE_SOLID;
extern int              WidthBorder=3;
extern color            ColorBorder=0x222222;
extern bool             PlotFibots=true;
extern bool             PlotFibotLabels=true;
extern bool             PlotFibotPrices=false;
extern ENUM_LINE_STYLE  StyleFibots1=STYLE_DOT;
extern ENUM_LINE_STYLE  StyleFibots2=STYLE_SOLID;
extern int              WidthFibots1=1;
extern int              WidthFibots2=1;
extern color            ColorFibots=0x555555;
extern bool             PlotYesterdayOHLC=true;
extern bool             PlotOHLCPrices=false;
extern ENUM_LINE_STYLE  StyleOHLC=STYLE_DOT;
extern int              WidthOHLC=1;
extern color            ColorO=clrGold;
extern color            ColorH=clrRed;
extern color            ColorL=clrGreen;
extern color            ColorC=clrMagenta;

extern string note_10 = "";                         //Button
extern bool btn_show = true;                        //__ show
extern string btn_pressed = "WP Show";              //__ pressed text
extern string btn_unpressed = "WP Hide";            //__ unpressed text
extern int btn_offset_x = 10;                       //__ x
extern int btn_offset_y = 20;                       //__ y
extern int btn_width = 70;                          //__ width
extern int btn_height = 20;                         //__ height
extern int btn_font_size = 10;                      //__ font size
extern color btn_font_clr = clrBlack;               //__ font color
extern color btn_bg_color = clrGray;                //__ bg color
extern color btn_border_clr = clrWhiteSmoke;        //__ border color

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
         S1,
         S2,
         S3,
         S4,
         S5,
         S6,         
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
   
   ObjectDelete("M0"+name);
   ObjectDelete("M1"+name);
   ObjectDelete("M2"+name);
   ObjectDelete("M3"+name);
   ObjectDelete("M4"+name);
   ObjectDelete("M5"+name);
                 
   ObjectDelete("M0P"+name);     
   ObjectDelete("M1P"+name);     
   ObjectDelete("M2P"+name);     
   ObjectDelete("M3P"+name);     
   ObjectDelete("M4P"+name);     
   ObjectDelete("M5P"+name);     

   ObjectDelete("M0L"+name);     
   ObjectDelete("M1L"+name);     
   ObjectDelete("M2L"+name);     
   ObjectDelete("M3L"+name);     
   ObjectDelete("M4L"+name);     
   ObjectDelete("M5L"+name);     

   ObjectDelete("BZ"+name);     
   ObjectDelete("SZ"+name);     
   
   ObjectDelete("BDU"+name);     
   ObjectDelete("BDD"+name);     
   ObjectDelete("BDL"+name);     
   ObjectDelete("BDR"+name);     
     
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
      
   ObjectDelete("f214l"+name);
   ObjectDelete("f236l"+name);
   ObjectDelete("f382l"+name);
   ObjectDelete("f50l"+name);
   ObjectDelete("f618l"+name);
   ObjectDelete("f764l"+name);
   ObjectDelete("f786l"+name);
      
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

void CreateButton()
{
   ButtonCreate(NULL,"wp btn",0,btn_offset_x,btn_offset_y,btn_width,btn_height,CORNER_LEFT_UPPER,btn_unpressed,"Arial",btn_font_size,btn_font_clr,btn_bg_color,btn_border_clr,false,true,false,false,0);
}

bool ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selectable=true,      //object can be selected        
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=false,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
   ResetLastError();
   ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0);
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
  
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if (id == CHARTEVENT_OBJECT_CLICK && sparam=="wp btn") 
   { 
      if(ObjectGetInteger(0,"wp btn",OBJPROP_STATE))
      {
         ObjectSetString(0,"wp btn",OBJPROP_TEXT,btn_pressed);
            for(shift=0;shift<=CountPeriods;shift++)
            {
               LevelsDelete(period+shift);
            }
            LevelsDelete("F"+period);      }
      if(!ObjectGetInteger(0,"wp btn",OBJPROP_STATE))
      {
         ObjectSetString(0,"wp btn",OBJPROP_TEXT,btn_unpressed);
         start_drawing();
      }
   }
}
       
void LevelsDraw(  int      shft,
                  datetime tmestrt, 
                  datetime tmend, 
                  string   name,
                  bool     future)
{
   if(ObjectGetInteger(0,"wp btn",OBJPROP_STATE)==false){
   high  = iHigh(NULL,TimePeriod,shft);
   low   = iLow(NULL,TimePeriod,shft);
   open  = iOpen(NULL,TimePeriod,shft);
   if(future==false){close = iClose(NULL,TimePeriod,shft);}else{close = Bid;}      
     
   PP  = (high+low+close)/3.0;
           
   R1 = PP+(high - low)*0.382;
   R2 = PP+(high - low)*0.618;
   R3 = PP+(high - low)*0.786;
   R4 = PP+(high - low)*1.00;
   R5 = PP+(high - low)*1.382;
   R6 = PP+(high - low)*1.618;
               
   S1 = PP-(high - low)*0.382;
   S2 = PP-(high - low)*0.618;
   S3 = PP-(high - low)*0.786;
   S4 = PP-(high - low)*1.00;
   S5 = PP-(high - low)*1.382;
   S6 = PP-(high - low)*1.618;
                
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
   
   
   if(PlotZones){
      PlotRectangle(0,"BZ"+name,0,tmestrt,S3,tmend,S4,ColorBuyZone);    
      PlotRectangle(0,"SZ"+name,0,tmestrt,R3,tmend,R4,ColorSellZone);}

   if(PlotPivots){                                 
      PlotTrend(0,"R6"+name,0,tmestrt,R6,tmend,R6,ColorRes,StylePivots,WidthPivots);     
      PlotTrend(0,"R5"+name,0,tmestrt,R5,tmend,R5,ColorRes,StylePivots,WidthPivots);     
      PlotTrend(0,"R4"+name,0,tmestrt,R4,tmend,R4,ColorRes,StylePivots,WidthPivots);  
      PlotTrend(0,"R3"+name,0,tmestrt,R3,tmend,R3,ColorRes,StylePivots,WidthPivots);     
      PlotTrend(0,"R2"+name,0,tmestrt,R2,tmend,R2,ColorRes,StylePivots,WidthPivots);     
      PlotTrend(0,"R1"+name,0,tmestrt,R1,tmend,R1,ColorRes,StylePivots,WidthPivots);     
      PlotTrend(0,"PP"+name,0,tmestrt,PP,tmend,PP,ColorPP,StylePivots,WidthPivots);     
      PlotTrend(0,"S1"+name,0,tmestrt,S1,tmend,S1,ColorSup,StylePivots,WidthPivots);     
      PlotTrend(0,"S2"+name,0,tmestrt,S2,tmend,S2,ColorSup,StylePivots,WidthPivots);     
      PlotTrend(0,"S3"+name,0,tmestrt,S3,tmend,S3,ColorSup,StylePivots,WidthPivots);
      PlotTrend(0,"S4"+name,0,tmestrt,S4,tmend,S4,ColorSup,StylePivots,WidthPivots);     
      PlotTrend(0,"S5"+name,0,tmestrt,S5,tmend,S5,ColorSup,StylePivots,WidthPivots);     
      PlotTrend(0,"S6"+name,0,tmestrt,S6,tmend,S6,ColorSup,StylePivots,WidthPivots);
      if(PlotPivotLabels){
         PlotText(0,"R6L"+name,0,tmestrt,R6,"R161","Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"R5L"+name,0,tmestrt,R5,"R138","Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"R4L"+name,0,tmestrt,R4,"R100","Arial",8,ColorRes,ANCHOR_LEFT_UPPER);      
         PlotText(0,"R3L"+name,0,tmestrt,R3,"R78","Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"R2L"+name,0,tmestrt,R2,"R61","Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"R1L"+name,0,tmestrt,R1,"R38","Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"PPL"+name,0,tmestrt,PP,"PP","Arial",8,ColorPP,ANCHOR_LEFT_UPPER);
         PlotText(0,"S1L"+name,0,tmestrt,S1,"S38","Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"S2L"+name,0,tmestrt,S2,"S61","Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"S3L"+name,0,tmestrt,S3,"S78","Arial",8,ColorSup,ANCHOR_LEFT_UPPER);            
         PlotText(0,"S4L"+name,0,tmestrt,S4,"S100","Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"S5L"+name,0,tmestrt,S5,"S138","Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"S6L"+name,0,tmestrt,S6,"S161","Arial",8,ColorSup,ANCHOR_LEFT_UPPER);}    
      if(PlotPivotPrices){
         PlotText(0,"R6P"+name,0,tmend,R6,DoubleToString(R6,4),"Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"R5P"+name,0,tmend,R5,DoubleToString(R5,4),"Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"R4P"+name,0,tmend,R4,DoubleToString(R4,4),"Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"R3P"+name,0,tmend,R3,DoubleToString(R3,4),"Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"R2P"+name,0,tmend,R2,DoubleToString(R2,4),"Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"R1P"+name,0,tmend,R1,DoubleToString(R1,4),"Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"PPP"+name,0,tmend,PP,DoubleToString(PP,4),"Arial",8,ColorPP,ANCHOR_RIGHT_UPPER);
         PlotText(0,"S1P"+name,0,tmend,S1,DoubleToString(S1,4),"Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"S2P"+name,0,tmend,S2,DoubleToString(S2,4),"Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"S3P"+name,0,tmend,S3,DoubleToString(S3,4),"Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"S4P"+name,0,tmend,S4,DoubleToString(S4,4),"Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"S5P"+name,0,tmend,S5,DoubleToString(S5,4),"Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"S6P"+name,0,tmend,S6,DoubleToString(S6,4),"Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);}}    

   if(PlotMiddle){
      PlotTrend(0,"M0"+name,0,tmestrt,M0,tmend,M0,ColorM02,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M1"+name,0,tmestrt,M1,tmend,M1,ColorM02,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M2"+name,0,tmestrt,M2,tmend,M2,ColorM02,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M3"+name,0,tmestrt,M3,tmend,M3,ColorM35,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M4"+name,0,tmestrt,M4,tmend,M4,ColorM35,StyleMidpoints,WidthMidpoints);     
      PlotTrend(0,"M5"+name,0,tmestrt,M5,tmend,M5,ColorM35,StyleMidpoints,WidthMidpoints);
      if(PlotPivotLabels){
         PlotText(0,"M0L"+name,0,tmend,M0,"M0","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M1L"+name,0,tmend,M1,"M1","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M2L"+name,0,tmend,M2,"M2","Arial",8,ColorSup,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M3L"+name,0,tmend,M3,"M3","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M4L"+name,0,tmend,M4,"M4","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);
         PlotText(0,"M5L"+name,0,tmend,M5,"M5","Arial",8,ColorRes,ANCHOR_RIGHT_UPPER);}
      if(PlotPivotPrices){
         PlotText(0,"M0P"+name,0,tmestrt,M0,DoubleToString(M0,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"M1P"+name,0,tmestrt,M1,DoubleToString(M1,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"M2P"+name,0,tmestrt,M2,DoubleToString(M2,4),"Arial",8,ColorSup,ANCHOR_LEFT_UPPER);
         PlotText(0,"M3P"+name,0,tmestrt,M3,DoubleToString(M3,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"M4P"+name,0,tmestrt,M4,DoubleToString(M4,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);
         PlotText(0,"M5P"+name,0,tmestrt,M5,DoubleToString(M5,4),"Arial",8,ColorRes,ANCHOR_LEFT_UPPER);}}   

   if(PlotFibots){
      PlotTrend(0,"f236a"+name,0,tmestrt,f236,tmend,f236,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f382a"+name,0,tmestrt,f382,tmend,f382,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f50a"+name,0,tmestrt,f50,tmend,f50,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f618a"+name,0,tmestrt,f618,tmend,f618,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f786a"+name,0,tmestrt,f786,tmend,f786,ColorFibots,StyleFibots1,WidthFibots1);
      PlotTrend(0,"f236b"+name,0,tmestrt+TimePeriod*10,f236,tmend,f236,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f382b"+name,0,tmestrt+TimePeriod*10,f382,tmend,f382,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f50b"+name,0,tmestrt+TimePeriod*10,f50,tmend,f50,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f618b"+name,0,tmestrt+TimePeriod*10,f618,tmend,f618,ColorFibots,StyleFibots2,WidthFibots2);
      PlotTrend(0,"f786b"+name,0,tmestrt+TimePeriod*10,f786,tmend,f786,ColorFibots,StyleFibots2,WidthFibots2);
      if(PlotFibotLabels){
         PlotText(0,"f236l"+name,0,tmend,f236,"23.6%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);         
         PlotText(0,"f382l"+name,0,tmend,f382,"38.2%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);         
         PlotText(0,"f50l"+name,0,tmend,f50,"50%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);         
         PlotText(0,"f618l"+name,0,tmend,f618,"61.8%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);         
         PlotText(0,"f786l"+name,0,tmend,f786,"78.6%","Arial",8,ColorFibots,ANCHOR_RIGHT_UPPER);}
      if(PlotFibotPrices){
         PlotText(0,"f236p"+name,0,tmestrt,f236,DoubleToString(f236,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);         
         PlotText(0,"f382p"+name,0,tmestrt,f382,DoubleToString(f382,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);         
         PlotText(0,"f50p"+name,0,tmestrt,f50,DoubleToString(f50,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);         
         PlotText(0,"f618p"+name,0,tmestrt,f618,DoubleToString(f618,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);         
         PlotText(0,"f786p"+name,0,tmestrt,f786,DoubleToString(f786,4),"Arial",8,ColorFibots,ANCHOR_LEFT_UPPER);}}
         
   if(PlotYesterdayOHLC){
      PlotTrend(0,"open"+name,0,tmestrt,open,tmestrt+TimePeriod*13,open,ColorO,StyleOHLC,WidthOHLC);
      PlotTrend(0,"high"+name,0,tmestrt,high,tmestrt+TimePeriod*20,high,ColorH,StyleOHLC,WidthOHLC);
      PlotTrend(0,"low"+name,0,tmestrt,low,tmestrt+TimePeriod*20,low,ColorL,StyleOHLC,WidthOHLC);
      PlotTrend(0,"close"+name,0,tmestrt,close,tmestrt+TimePeriod*13,close,ColorC,StyleOHLC,WidthOHLC);         
      if(PlotOHLCPrices){
         PlotText(0,"openp"+name,0,tmestrt+TimePeriod*10,open,DoubleToString(rangeopen1,1)+"/"+DoubleToString(rangeopen2,1)+"%","Arial",8,ColorO,6);
         PlotText(0,"closep"+name,0,tmestrt+TimePeriod*10,close,DoubleToString(rangeclose1,1)+"/"+DoubleToString(rangeclose2,1)+"%","Arial",8,ColorC,6);}}   

   if(PlotBorders){
   if((future==false)&&(shift != 0)){
//    PlotTrend(0,"BDU"+name,0,tmestrt,R3,tmend,R3,ColorBorder,StyleBorder,WidthBorder);      // top
//    PlotTrend(0,"BDD"+name,0,tmestrt,S3,tmend,S3,ColorBorder,StyleBorder,WidthBorder);      // bottom
      PlotTrend(0,"BDL"+name,0,tmestrt,R3,tmestrt,S3,ColorBorder,StyleBorder,WidthBorder);    // left
      PlotTrend(0,"BDR"+name,0,tmend,R3,tmend,S3,ColorBorder,StyleBorder,WidthBorder);}}      // right
   }
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
   
   if(btn_show){CreateButton();}
   ObjectSetInteger(NULL,"wp btn",OBJPROP_STATE,true);
   ObjectSetString(NULL,"wp btn",OBJPROP_TEXT,btn_pressed);
   return(0);
}   
   
int deinit()
{
   for(shift=0;shift<=CountPeriods;shift++)
   {
      LevelsDelete(period+shift);
   }
   LevelsDelete("F"+period);
   ObjectDelete(NULL,"wp btn");
   Comment("");
   return(0);
}

int start()
{
   if(ObjectGetInteger(NULL,"wp btn",OBJPROP_STATE)){start_drawing();}
//   for(shift=0;shift<=CountPeriods;shift++)
//   {
//      LevelsDelete(period+shift);
//   }
//   LevelsDelete("F"+period);
//   
//   for(shift=CountPeriods-1;shift>=0;shift--)
//   {
//      timestart = iTime(NULL,TimePeriod,shift);
//      timeend   = iTime(NULL,TimePeriod,shift)+TimePeriod*60;   
//         
//      LevelsDraw(shift+1,timestart,timeend,period+shift,false);                
//   }
//   
//   if(PlotFuturePivots)
//   {
//      timestart=iTime(NULL,TimePeriod,0)+TimePeriod*60;
//      timeend=iTime(NULL,TimePeriod,0)+TimePeriod*120;
//
//      LevelsDraw(0,timestart,timeend,"F"+period,true);      
//   }
   
   return(0);
}

void start_drawing()
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

}