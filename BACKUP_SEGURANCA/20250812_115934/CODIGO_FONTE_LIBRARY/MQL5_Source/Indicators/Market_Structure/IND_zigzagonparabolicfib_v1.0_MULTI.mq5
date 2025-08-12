//+------------------------------------------------------------------+
//|                                              ZigZag on Parabolic |
//|                                      Copyright © 2009, EarnForex |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, EarnForex"
//---- link to the website of the author
#property link      "http://www.earnforex.com"
//---- indicator version
#property version   "1.01"
#property description "ZigZag on Parabolic"
//+----------------------------------------------+ 
//|  Indicator drawing parameters                |
//+----------------------------------------------+ 
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- 3 buffers are used for calculation and drawing the indicator
#property indicator_buffers 3
//---- only 1 plot is used
#property indicator_plots   1
//---- ZIGZAG is used for the indicator
#property indicator_type1   DRAW_COLOR_ZIGZAG
//---- displaying the indicator label
#property indicator_label1  "ZigZag"
//---- DarkSalmon and DodgerBlue colors are used for the indicator line
#property indicator_color1 DarkSalmon,DodgerBlue
//---- the indicator line is a long dashed line
#property indicator_style1  STYLE_DASH
//---- indicator line width is equal to 1
#property indicator_width1  1
//+----------------------------------------------+ 
//| Declaration of enumerations                  |
//+----------------------------------------------+ 
enum ENUM_WIDTH // Type of constant
  {
   w_1 = 1,     // 1
   w_2,         // 2
   w_3,         // 3
   w_4,         // 4
   w_5          // 5
  };
//+----------------------------------------------+ 
//| iSAR indicator input parameters              |
//+----------------------------------------------+ 
input double Step=0.02;          // SAR step
input double Maximum=0.2;        // SAR maximum
input bool ExtremumsShift=true;  // Extremum shift flag
//+----------------------------------------------+ 
//| Channel creation input parameters            |
//+----------------------------------------------+ 
input int FirstExtrNumb=1;                           // First extremum number (0,1,2,3...)
input color Upper_color=DarkViolet;                  // Channel upper line color
input ENUM_LINE_STYLE Upper_style=STYLE_SOLID;       // Channel upper line style
input ENUM_WIDTH Upper_width=w_3;                    // Channel upper line width
input color Middle_color=Blue;                       // Middle line color
input ENUM_LINE_STYLE Middle_style=STYLE_DASHDOTDOT; // Middle line style
input ENUM_WIDTH Middle_width=w_1;                   // Middle line width
input color Lower_color=MediumVioletRed;             // Channel lower line color
input ENUM_LINE_STYLE Lower_style=STYLE_SOLID;       // Channel lower line style
input ENUM_WIDTH Lower_width=w_3;                    // Channel lower line width
//+----------------------------------------------+ 
//| Fibo levels generation input parameters      |
//+----------------------------------------------+ 
//---- Fibo properties at the last extremum
input bool DynamicFiboFlag=true;                          // DynamicFibo display flag 
input color DynamicFibo_color=DeepPink;                   // DynamicFibo color 
input ENUM_LINE_STYLE DynamicFibo_style=STYLE_DASHDOTDOT; // DynamicFibo style 
input ENUM_WIDTH DynamicFibo_width=w_1;                   // DynamicFibo line width 
input bool DynamicFibo_AsRay=true;                        // DynamicFibo ray 
//---- Fibo properties at the second-to-last extremum
input bool StaticFiboFlag=true;                           // StaticFibo display flag
input color StaticFibo_color=Teal;                        // StaticFibo color
input ENUM_LINE_STYLE StaticFibo_style=STYLE_DASH;        // StaticFibo style
input ENUM_WIDTH StaticFibo_width=w_1;                    // StaticFibo line width
input bool StaticFibo_AsRay=false;                        // StaticFibo ray
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double LowestBuffer[];
double HighestBuffer[];
double ColorBuffer[];
//---- declaration of integer variables
int EShift;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of variables for the indicators handles
int SAR_Handle;
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,      // chart ID
                 string   name,          // object name
                 int      nwin,          // window index
                 datetime time1,         // price level time 1
                 double   price1,        // price level 1
                 datetime time2,         // price level time 2
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
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
//----
  }
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,      // chart ID
              string   name,          // object name
              int      nwin,          // window index
              datetime time1,         // price level time 1
              double   price1,        // price level 1
              datetime time2,         // price level time 2
              double   price2,        // price level 2
              color    Color,         // line color
              int      style,         // line style
              int      width,         // line width
              string   text)          // text
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
//|  Fibo creation                                                   |
//+------------------------------------------------------------------+
void CreateFibo(long     chart_id,      // chart ID
                string   name,          // object name
                int      nwin,          // window index
                datetime time1,         // price level time 1
                double   price1,        // price level 1
                datetime time2,         // price level time 2
                double   price2,        // price level 2
                color    Color,         // line color
                int      style,         // line style
                int      width,         // line width
                int      ray,           // ray direction: -1 - to the left, +1 - to the right, other values - no ray
                string   text)          // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_FIBO,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);

   if(ray>0)ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   if(ray<0)ObjectSetInteger(chart_id,name,OBJPROP_RAY_LEFT,true);

   if(ray==0)
     {
      ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(chart_id,name,OBJPROP_RAY_LEFT,false);
     }

   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);

   for(int numb=0; numb<10; numb++)
     {
      ObjectSetInteger(chart_id,name,OBJPROP_LEVELCOLOR,numb,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_LEVELSTYLE,numb,style);
      ObjectSetInteger(chart_id,name,OBJPROP_LEVELWIDTH,numb,width);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Fibo reinstallation                                             |
//+------------------------------------------------------------------+
void SetFibo(long     chart_id,      // chart ID
             string   name,          // object name
             int      nwin,          // window index
             datetime time1,         // price level time 1
             double   price1,        // price level 1
             datetime time2,         // price level time 2
             double   price2,        // price level 2
             color    Color,         // line color
             int      style,         // line style
             int      width,         // line width
             int      ray,           // ray direction: -1 - to the left, 0 - no ray, +1 - to the right
             string   text)          // text
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateFibo(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,ray,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
     }
//----
  }
//+------------------------------------------------------------------+
//| Searching for the very first ZigZag high in time series buffers  |
//+------------------------------------------------------------------+     
int FindFirstExtremum(int StartPos,int Rates_total,double &UpArray[],double &DnArray[],int &Sign,double &Extremum)
  {
//----
   if(StartPos>=Rates_total)StartPos=Rates_total-1;

   for(int bar=StartPos; bar<Rates_total; bar++)
     {
      if(UpArray[bar]!=0.0 && UpArray[bar]!=EMPTY_VALUE)
        {
         Sign=+1;
         Extremum=UpArray[bar];
         return(bar);
        }

      if(DnArray[bar]!=0.0 && DnArray[bar]!=EMPTY_VALUE)
        {
         Sign=-1;
         Extremum=DnArray[bar];
         return(bar);
        }
     }
//----
   return(-1);
  }
//+------------------------------------------------------------------+
//| Searching for the second ZigZag high in time series buffers      |
//+------------------------------------------------------------------+     
int FindSecondExtremum(int Direct,int StartPos,int Rates_total,double &UpArray[],double &DnArray[],int &Sign,double &Extremum)
  {
//----
   if(StartPos>=Rates_total)StartPos=Rates_total-1;

   if(Direct==-1)
      for(int bar=StartPos; bar<Rates_total; bar++)
        {
         if(UpArray[bar]!=0.0 && UpArray[bar]!=EMPTY_VALUE)
           {
            Sign=+1;
            Extremum=UpArray[bar];
            return(bar);
            break;
           }
        }

   if(Direct==+1)
      for(int bar=StartPos; bar<Rates_total; bar++)
        {
         if(DnArray[bar]!=0.0 && DnArray[bar]!=EMPTY_VALUE)
           {
            Sign=-1;
            Extremum=DnArray[bar];
            return(bar);
            break;
           }
        }
//----
   return(-1);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=1;

//---- initialization of constants   
   if(ExtremumsShift) EShift=1;
   else               EShift=0;

//---- getting handle of the SAR indicator
   SAR_Handle=iSAR(NULL,0,Step,Maximum);
   if(SAR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the SAR indicator");

//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- create labels to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag Lowest");
   PlotIndexSetString(1,PLOT_LABEL,"ZigZag Highest");
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);
//---- set the position, from which the Bollinger Bands drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string shortname;
   StringConcatenate(shortname,"ZigZag on Parabolic(",
                     double(Step),", ",double(Maximum),", ",bool(ExtremumsShift),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"DynamicFibo");
   ObjectDelete(0,"StaticFibo");
   ObjectDelete(0,"Upper Line");
   ObjectDelete(0,"Middle Line");
   ObjectDelete(0,"Lower Line");
//----
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
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(SAR_Handle)<rates_total || rates_total<min_rates_total)return(0);

//---- declaration of local variables 
   static int j_,lastcolor_;
   static bool dir_;
   static double h_,l_;
   int j,limit,climit,to_copy,bar,shift,NewBar,lastcolor;
   double h,l,mid0,mid1,SAR[];
   bool dir;

//---- declarations of local variables for creating the channel and Fibo
   int bar1=0,bar2,bar3,bar4,sign;
   double price1=0.0,price2,price3,price4,dprice;

//---- calculate the limit starting index for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for calculation of all bars
      h_=0.0;
      l_=999999999;
      dir_=false;
      j_=0;
      lastcolor_=0;
     }
   else
     {
      limit=rates_total-prev_calculated;  // starting index for calculation of new bars
     }

   climit=limit; // starting index for the indicator coloring

   to_copy=limit+2;
   if(limit==0) NewBar=1;
   else         NewBar=0;

//---- indexing elements in arrays as timeseries 
   ArraySetAsSeries(SAR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);

//--- copy newly appeared data in the array
   if(CopyBuffer(SAR_Handle,0,0,to_copy,SAR)<=0) return(0);

//---- restore values of the variables
   j=j_;
   dir=dir_;
   h=h_;
   l=l_;
   lastcolor=lastcolor_;

//---- first big indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0)
        {
         j_=j;
         dir_=dir;
         h_=h;
         l_=l;
        }

      mid0=(high[bar]+low[bar])/2;
      mid1=(high[bar+1]+low[bar+1])/2;

      HighestBuffer[bar]=0.0;
      LowestBuffer[bar]=0.0;

      if(bar>0) j++;

      if(dir)
        {
         if(h<high[bar])
           {
            h=high[bar];
            j=NewBar;
           }
         if(SAR[bar+1]<=mid1 && SAR[bar]>mid0)
           {
            shift=bar+EShift *(j+NewBar);
            if(shift>rates_total-1) shift=rates_total-1;
            HighestBuffer[shift]=h;
            dir=false;
            l=low[bar];
            j=0;
            if(shift>climit) climit=shift;
           }
        }
      else
        {
         if(l>low[bar])
           {
            l=low[bar];
            j=NewBar;
           }
         if(SAR[bar+1]>=mid1 && SAR[bar]<mid0)
           {
            shift=bar+EShift *(j+NewBar);
            if(shift>rates_total-1) shift=rates_total-1;
            LowestBuffer[shift]=l;
            dir=true;
            h=high[bar];
            j=0;
            if(shift>climit) climit=shift;
           }
        }
     }

//---- the third big indicator coloring loop
   for(bar=climit; bar>=0 && !IsStopped(); bar--)
     {
      if(rates_total!=prev_calculated && bar==0)
        {
         lastcolor_=lastcolor;
        }

      if(HighestBuffer[bar]==0.0 || LowestBuffer[bar]==0.0)
         ColorBuffer[bar]=lastcolor;

      if(HighestBuffer[bar]!=0.0 || LowestBuffer[bar]!=0.0)
        {
         if(lastcolor==0)
           {
            ColorBuffer[bar]=1;
            lastcolor=1;
           }
         else
           {
            ColorBuffer[bar]=0;
            lastcolor=0;
           }
        }

      if(HighestBuffer[bar]!=0.0 || LowestBuffer[bar]==0.0)
        {
         ColorBuffer[bar]=1;
         lastcolor=1;
        }

      if(HighestBuffer[bar]==0.0 || LowestBuffer[bar]!=0.0)
        {
         ColorBuffer[bar]=0;
         lastcolor=0;
        }
     }

//---- channel creation
   bar1=FindFirstExtremum(0,rates_total,HighestBuffer,LowestBuffer,sign,price1);

   for(int numb=1; numb<=FirstExtrNumb && bar1>-1; numb++)
      bar1=FindSecondExtremum(sign,bar1,rates_total,HighestBuffer,LowestBuffer,sign,price1);

   if(bar1==-1)
     {
      ObjectDelete(0,"Upper Line");
      ObjectDelete(0,"Middle Line");
      ObjectDelete(0,"Lower Line");
      return(rates_total);
     }

   bar2=FindSecondExtremum(sign,bar1,rates_total,HighestBuffer,LowestBuffer,sign,price2);
   bar3=FindSecondExtremum(sign,bar2,rates_total,HighestBuffer,LowestBuffer,sign,price3);

   bar4=bar2+bar3-bar1;
   price4=price2+price3-price1;

   if(sign==+1)
     {
      SetTline(0,"Upper Line",0,time[bar3],price3,time[bar1],price1,Upper_color,Upper_style,Upper_width,"Upper Line");
      SetTline(0,"Lower Line",0,time[bar4],price4,time[bar2],price2,Lower_color,Lower_style,Lower_width,"Lower Line");
     }

   if(sign==-1)
     {
      SetTline(0,"Upper Line",0,time[bar4],price4,time[bar2],price2,Upper_color,Upper_style,Upper_width,"Upper Line");
      SetTline(0,"Lower Line",0,time[bar3],price3,time[bar1],price1,Lower_color,Lower_style,Lower_width,"Lower Line");
     }

   dprice=-(price3-price1)/(bar3-bar1);
   dprice=(price3-price4-dprice*(bar4-bar3))/2.0;
   price4+=dprice;
   price2+=dprice;
   SetTline(0,"Middle Line",0,time[bar4],price4,time[bar2],price2,Middle_color,Middle_style,Middle_width,"Middle Line");

//---- Fibo creation
   if(StaticFiboFlag || DynamicFiboFlag)
     {
      bar1=FindFirstExtremum(0,rates_total,HighestBuffer,LowestBuffer,sign,price1);
      bar2=FindSecondExtremum(sign,bar1,rates_total,HighestBuffer,LowestBuffer,sign,price2);

      if(DynamicFiboFlag)
        {
         SetFibo(0,"DynamicFibo",0,time[bar2],price2,time[bar1],price1,
                 DynamicFibo_color,DynamicFibo_style,DynamicFibo_width,DynamicFibo_AsRay,"DynamicFibo");
        }

      if(StaticFiboFlag)
        {
         bar3=FindSecondExtremum(sign,bar2,rates_total,HighestBuffer,LowestBuffer,sign,price3);
         SetFibo(0,"StaticFibo",0,time[bar3],price3,time[bar2],price2,
                 StaticFibo_color,StaticFibo_style,StaticFibo_width,StaticFibo_AsRay,"StaticFibo");
        }
     }
//---- 
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
