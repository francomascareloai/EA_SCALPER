//+------------------------------------------------------------------+
//|                                          NB_SHI_Channel_true.mq5 |
//|                                 Copyright © 2004, Shurka & Kevin |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2004, Shurka & Kevin"
//---- link to the website of the author
#property link      ""
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- only 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Label drawing parameters                    |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type1   DRAW_ARROW
//---- magenta color is used for the indicator line
#property indicator_color1  Magenta
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "SHI Channel"
//+----------------------------------------------+
//|  Low channel line drawing parameters         |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type2   DRAW_LINE
//---- magenta color is used for the indicator line
#property indicator_color2  Lime
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "SHI Channel Up"
//+----------------------------------------------+
//|  Top channel line drawing parameters         |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type3   DRAW_LINE
//---- magenta color is used for the indicator line
#property indicator_color3  Red
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "SHI Channel Down"
//+----------------------------------------------+
//|  Middle channel line drawing parameters      |
//+----------------------------------------------+
//---- drawing the indicator as a label
#property indicator_type4   DRAW_LINE
//---- magenta color is used for the indicator line
#property indicator_color4  Blue
//---- the indicator line is a continuous curve
#property indicator_style4  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4  "SHI Channel Middle"

//---- indicator input parameters
input int AllBars=240;
input int BarsForFract=0;
input color UpChannelColor=Lime;
input color MdChannelColor=Blue;
input color DnChannelColor=Red;

//---- declaration of a dynamic array that 
//---- will be used as an indicator buffer
double ExtBuffer[];
double buf1[];
double buf2[];
double buf3[];

int count,BFF;
//---- declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+
//|  Creating a trend line                                           |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,// chart ID
                 string   name,          // object name
                 int      nwin,          // window index
                 datetime time1,         // time 1 of the price level
                 double   price1,        // price level 1
                 datetime time2,         // time 2 of the price level
                 double   price2,        // price level 2
                 color    Color,         // line color
                 int      style,         // line style
                 int      width,         // line width
                 string   text)          // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline
(long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // time 1 of the price level
 double   price1,        // price level 1
 datetime time2,         // time 2 of the price level
 double   price2,        // price level 2
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 string   text)           // text
   {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables
   if(BarsForFract>0) BFF=BarsForFract;
   else switch(Period())
     {
      case PERIOD_M1:  BFF=12; break;
      case PERIOD_M2:  BFF=24; break;
      case PERIOD_M3:  BFF=36; break;
      case PERIOD_M4:  BFF=40; break;
      case PERIOD_M5:  BFF=48; break;
      case PERIOD_M6:  BFF=12; break;
      case PERIOD_M10: BFF=15; break;
      case PERIOD_M12: BFF=20; break;
      case PERIOD_M15: BFF=24; break;
      case PERIOD_M20: BFF=24; break;
      case PERIOD_M30: BFF=24; break;
      case PERIOD_H1:  BFF=12; break;
      case PERIOD_H2:  BFF=12; break;
      case PERIOD_H3:  BFF=12; break;
      case PERIOD_H4:  BFF=15; break;
      case PERIOD_H6:  BFF=12; break;
      case PERIOD_H8:  BFF=12; break;
      case PERIOD_H12: BFF=12; break;
      case PERIOD_D1:  BFF=10; break;
      case PERIOD_W1:  BFF=6;  break;
      case PERIOD_MN1: BFF=6;  break;
     }
   count=BFF*2+1;
   StartBars=MathMax(BFF-1,AllBars);
//---- set ExtBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtBuffer,INDICATOR_DATA);
//---- set the position, from which the indicator drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtBuffer,true);
//---- initializations of a variable for the indicator short name
   string shortname="SHI Channel true";
//---- create label to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,shortname);
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- selecting a symbol for drawing
   PlotIndexSetInteger(0,PLOT_ARROW,108);

//---- set buf1[] dynamic array as an indicator buffer
   SetIndexBuffer(1,buf1,INDICATOR_DATA);
//---- set the position, from which the indicator drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(buf1,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- set buf2[] dynamic array as an indicator buffer
   SetIndexBuffer(2,buf2,INDICATOR_DATA);
//---- set the position, from which the indicator drawing starts
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(buf2,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,buf3,INDICATOR_DATA);
//---- set the position, from which the indicator drawing starts
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(buf3,true);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//----
  }
//+------------------------------------------------------------------+
//| Deleting objects from a chart                                    |
//+------------------------------------------------------------------+
void DelObj()
  {
//----
   ObjectDelete(0,"Upper SHI");
   ObjectDelete(0,"Lower SHI");
   ObjectDelete(0,"Middle SHI");
   Comment("");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   DelObj();
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

   double Step=0,iprice=0,P1=0,P2=0,PP=0;
   int nbar,bar,B1,B2,UpDown=0,ishift=0,i=0,AB;
   datetime T1,T2;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   ArrayInitialize(ExtBuffer,0.0);

   if(AllBars==0 || rates_total<AllBars)
      AB=rates_total;
   else AB=AllBars; //AB-quantity of calculated bars

   bar=2; //calculating from the third bar to let the fractal "fix"
   B1 = -1;
   B2 = -1;
   UpDown=0;

   while((B1==-1 || B2==-1) && bar<AB)
     {
      ExtBuffer[bar]=0.0;
      nbar=bar-BFF;
      if(nbar<0)nbar=0;
      //UpDown = 1, that means the first fractal is found above, UpDown = -1 means that the first fractal
      //is found below, UpDown = 0 means that the fractal is not found yet.
      //Â1 and Â2 are the indexes of bars with fractals. The reference line is built through them.
      //Ð1 and Ð2 are prices, through which the line is drawn
      if(UpDown<1 && bar==ArrayMinimum(low,nbar,count))
        {
         if(UpDown==0)
           {
            UpDown=-1;
            B1 = bar;
            P1 = low[B1];
           }
         else
           {
            B2 = bar;
            P2 = low[B2];
           }
        }
      if(UpDown>-1 && bar==ArrayMaximum(high,nbar,count))
        {
         if(UpDown==0)
           {
            UpDown=1;
            B1 = bar;
            P1 = high[B1];
           }
         else
           {
            B2 = bar;
            P2 = high[B2];
           }
        }
      bar++;
     }

   if(B1==-1 || B2==-1)
     {
      DelObj();
      return(0);
     } // It means thaere are no fractals among 300 bars
   Step=(P2-P1)/(B2-B1); //The step is calculated. If it is positive, the channel is descending
   P1=P1-B1*Step;
   B1=0; //relocate the price and the first bar to zero
         //And now it is the turn for the reference point of the channel's opposite line.

   ishift = 0;
   iprice = 0;

   if(UpDown==1)
     {
      PP=low[2]-2*Step;

      for(i=3; i<=B2; i++) if(low[i]<PP+Step*i) PP=low[i]-i*Step;

      if(low[0]<PP)
        {
         ishift = 0;
         iprice = PP;
        }
      if(low[1]<PP+Step)
        {
         ishift = 1;
         iprice = PP + Step;
        }
      if(high[0]>P1)
        {
         ishift = 0;
         iprice = P1;
        }
      if(low[1]>P1+Step)
        {
         ishift = 1;
         iprice = P1 + Step;
        }
     }
   else
     {
      PP=high[2]-2*Step;

      for(i=3; i<=B2; i++) if(high[i]>PP+Step*i) PP=high[i]-i*Step;

      if(low[0]<P1)
        {
         ishift = 0;
         iprice = P1;
        }
      if(low[1]<P1+Step)
        {
         ishift = 1;
         iprice = P1 + Step;
        }
      if(high[0]>PP)
        {
         ishift = 0;
         iprice = PP;
        }
      if(high[1]>PP+Step)
        {
         ishift = 1;
         iprice = PP + Step;
        }
     }

//---- now, let's relocate the final price and bar to AB for the channel lines to be drawn longer
   P2 = P1 + AB*Step;
   T1 = time[B1];
   T2 = time[AB];
//---- if there has been no channel crossing. then 0, otherwise, set the reference point price.
   if(iprice!=0) ExtBuffer[ishift]=iprice;
   else ExtBuffer[ishift]=0.0;

   SetTline(0,"Upper SHI",0,T2,PP+Step*AB,T1,PP,UpChannelColor,STYLE_SOLID,2,"Upper SHI");
   SetTline(0,"Lower SHI",0,T2,P2,T1,P1,DnChannelColor,STYLE_SOLID,2,"Lower SHI");
   SetTline(0,"Middle SHI",0,T2,(P2+PP+Step*AB)/2,T1,(P1+PP)/2,MdChannelColor,STYLE_DOT,1,"Middle SHI");
   Comment(" Channel size = ",DoubleToString(MathAbs(PP-P1)/_Point,0)," Slope = ",DoubleToString(-Step/_Point,2));

   double cbars=AB-B1;
   double startPP=PP+Step*AB, endPP=PP;
   double startP1=P2, endP1=P1;
   double startP2=(P2+PP+Step*AB)/2, endP2=(P1+PP)/2;
   double deltaPP=(startPP-endPP)/cbars;
   double deltaP1=(startP1-endP1)/cbars;
   double deltaP2=(startP2-endP2)/cbars;

   ArrayInitialize(buf1, 0.0);
   ArrayInitialize(buf2, 0.0);
   ArrayInitialize(buf3, 0.0);

   buf1[AB]=startPP;
   buf2[AB]=startP1;
   buf3[AB]=startP2;
   for(int j=AB-1; j>=0; j--)
     {
      buf1[j]=buf1[j+1]-deltaPP;
      buf2[j]=buf2[j+1]-deltaP1;
      buf3[j]=buf3[j+1]-deltaP2;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
