//+------------------------------------------------------------------+
//|                                                  AutoDayFibs.mq5 |
//|               Copyright © 2005-2008, Jason Robinson (jnrtrading) |
//|                                   http://www.spreadtrade2win.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005-2008, Jason Robinson (jnrtrading)"
//---- link to the website of the author
#property link      "http://www.spreadtrade2win.com"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- no buffers are used for the calculation and drawing of the indicator
#property indicator_buffers 0
//---- 0 graphical plots are used
#property indicator_plots   0
//+----------------------------------------------+
//|  declaration of enumerations                 |
//+----------------------------------------------+
enum Hour //Type of constant
  {
   H00=0,    //00
   H01,      //01
   H02,      //02
   H03,      //03
   H04,      //04
   H05,      //05
   H06,      //06
   H07,      //07
   H08,      //08
   H09,      //09
   H10,      //10
   H11,      //11
   H12,      //12
   H13,      //13
   H14,      //14
   H15,      //15
   H16,      //16
   H17,      //17
   H18,      //18
   H19,      //19
   H20,      //20
   H21,      //21
   H22,      //22
   H23,      //23
  };
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+
enum Number
  {
   Number_0,
   Number_1,
   Number_2,
   Number_3
  };
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+  
enum Width
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+-----------------------------------+
//|  enumeration declaration          |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,//Solid line
   DASH_,//Dashed line
   DOT_,//Dotted line
   DASHDOT_,//Dot-dash line
   DASHDOTDOT_   //Dot-dash line with double dots
  };
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input bool  AutomaticallyAdjustToToday = true; //adjustment under the current prices
input Hour  TimeToAdjust=H00;                  //the hour of shifting Fibo
input uint  iDaysBackForHigh=0;                //number of days back to obtain low
input uint  iDaysBackForLow=0;                 //number of days back to obtain low
input uint  TextSize=10;                       //text font size
//----
input color  Color_fib000 = clrBlueViolet; //color for the fib000 level
input STYLE  Style_fib000 = SOLID_;         //fib000 level style
input Width  Width_fib000 = Width_2;        //fib000 level line width
//----
input color  Color_fib236 = clrBlueViolet; //color for the fib236 level
input STYLE  Style_fib236 = SOLID_;         //fib236 level line style
input Width  Width_fib236 = Width_2;        //fib236 level line width
//----
input color  Color_fib382 = clrBlueViolet; //color for the fib382 level
input STYLE  Style_fib382 = SOLID_;         //fib382 level line style
input Width  Width_fib382 = Width_2;        //fib382 level line width
//----
input color  Color_fib500 = clrBlueViolet; //color for the fib500 level
input STYLE  Style_fib500 = SOLID_;         //fib500 level line style
input Width  Width_fib500 = Width_2;        //fib500 level line width
//----
input color  Color_fib618 = clrBlueViolet; //color for the fib618 level
input STYLE  Style_fib618 = SOLID_;         //fib618 level line style
input Width  Width_fib618 = Width_2;        //fib618 level line width
//----
input color  Color_fib764 = clrBlueViolet; //color for the fib764 level
input STYLE  Style_fib764 = SOLID_;         //fib764 level line style
input Width  Width_fib764 = Width_2;        //fib764 level line width
//----
input color  Color_fib1000 = clrBlueViolet; //color for the fib1000 level
input STYLE  Style_fib1000 = SOLID_;         //fib1000 level line style
input Width  Width_fib1000 = Width_2;        //fib1000 level line width
//----
input color  Color_fib1618 = clrBlueViolet; //color for the fib1618 level
input STYLE  Style_fib1618 = SOLID_;         //fib1618 level line style
input Width  Width_fib1618 = Width_2;        //fib1618 level line width
//----
input color  Color_fib2618 = clrBlueViolet; //color for the fib2618 level
input STYLE  Style_fib2618 = SOLID_;         //fib2618 level line style
input Width  Width_fib2618 = Width_1;        //fib2618 level line width
//----
input color  Color_fib4236 = clrBlueViolet; //color for the fib4236 level
input STYLE  Style_fib4236 = SOLID_;         //fib4236 level line style
input Width  Width_fib4236 = Width_2;        //fib4236 level line width
//+----------------------------------------------+
double fib000,
fib236,
fib382,
fib500,
fib618,
fib764,
fib1000,
fib1618,
fib2618,
fib4236,
range,
prevRange;
bool objectsExist,highFirst;
//---- Declaration of integer variables of data starting point
int min_rates_total,DaysBackForHigh,DaysBackForLow;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   DaysBackForHigh=int(iDaysBackForHigh);
   DaysBackForLow=int(iDaysBackForLow);
   min_rates_total=int((1+MathMax(DaysBackForHigh,DaysBackForLow))*PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT));
   prevRange=0;
   objectsExist=true;

//---- determine the accuracy of displaying indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- creating labels for displaying in DataWindow and the name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"AutoDayFibs");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"fib000");
   ObjectDelete(0,"fib000_label");
   ObjectDelete(0,"fib236");
   ObjectDelete(0,"fib236_label");
   ObjectDelete(0,"fib382");
   ObjectDelete(0,"fib382_label");
   ObjectDelete(0,"fib500");
   ObjectDelete(0,"fib500_label");
   ObjectDelete(0,"fib618");
   ObjectDelete(0,"fib618_label");
   ObjectDelete(0,"fib764");
   ObjectDelete(0,"fib764_label");
   ObjectDelete(0,"fib1000");
   ObjectDelete(0,"fib1000_label");
   ObjectDelete(0,"fib1618");
   ObjectDelete(0,"fib1618_label");
   ObjectDelete(0,"fib2618");
   ObjectDelete(0,"fib2618_label");
   ObjectDelete(0,"fib4236");
   ObjectDelete(0,"fib4236_label");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- 
   if(_Period>=PERIOD_D1 || rates_total<min_rates_total) return(0);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   if(AutomaticallyAdjustToToday==true)
     {
      MqlDateTime tm;
      TimeToStruct(time[0],tm);

      if(tm.hour>=0 && tm.hour<TimeToAdjust)
        {
         DaysBackForHigh=H01;
         DaysBackForLow =H01;
        }
      else if(tm.hour>=DaysBackForLow && tm.hour<=H23)
        {
         DaysBackForHigh=H00;
         DaysBackForLow =H00;
        }
     }

   double iLow[1],iHigh[1];
   if(CopyLow(NULL,PERIOD_D1,DaysBackForLow,1,iLow)<1)return(0);
   if(CopyHigh(NULL,PERIOD_D1,DaysBackForHigh,1,iHigh)<1)return(0);
   range=iHigh[0]-iLow[0];

   for(int iii=0; iii<rates_total; iii++)
     {
      if(high[iii]==iHigh[0])
        {
         highFirst=true;
         break;
        }
      else if(low[iii]==iLow[0])
        {
         highFirst=false;
         break;
        }
     }

   if(prevRange!=range)
     {
      objectsExist=false;
      prevRange=range;
     }

   if(!highFirst)
     {
      fib000 = iLow[0];
      fib236 = (range * 0.236) + iLow[0];
      fib382 = (range * 0.382) + iLow[0];
      fib500 = (iHigh[0] + iLow[0]) / 2;
      fib618 = (range * 0.618) + iLow[0];
      fib764 = (range * 0.764) + iLow[0];
      fib1000 = iHigh[0];
      fib1618 = (range * 0.618) + iHigh[0];
      fib2618 = (range * 0.618) + (iHigh[0] + range);
      fib4236 = (range * 0.236) + iHigh[0] + (range * 3);
     }
   else if(highFirst)
     {
      fib000 = iHigh[0];
      fib236 = iHigh[0] - (range * 0.236);
      fib382 = iHigh[0] - (range * 0.382);
      fib500 = (iHigh[0] + iLow[0]) / 2;
      fib618 = iHigh[0] - (range * 0.618);
      fib764 = iHigh[0] - (range * 0.764);
      fib1000 = iLow[0];
      fib1618 = iLow[0] - (range * 0.618);
      fib2618 = (iLow[0] - range) - (range * 0.618);
      fib4236 = iLow[0] - (range * 3) - (range * 0.236);
     }

   if(!objectsExist)
     {
      string word;

      SetHline(0,"fib000",0,fib000,Color_fib000,Style_fib000,Width_fib000,"fib000 "+DoubleToString(fib000,_Digits));
      word="                      0.0";
      SetText(0,"fib000_label",0,time[0],fib000,word,Color_fib000,"Arial Black",TextSize,ANCHOR_LOWER);

      SetHline(0,"fib236",0,fib236,Color_fib236,Style_fib236,Width_fib236,"fib236 "+DoubleToString(fib236,_Digits));
      word="                      23.6";
      SetText(0,"fib236_label",0,time[0],fib236,word,Color_fib236,"Arial Black",TextSize,ANCHOR_LOWER);

      SetHline(0,"fib382",0,fib382,Color_fib382,Style_fib382,Width_fib382,"fib382 "+DoubleToString(fib382,_Digits));
      word="                      38.2";
      SetText(0,"fib382_label",0,time[0],fib382,word,Color_fib382,"Arial Black",TextSize,ANCHOR_LOWER);

      SetHline(0,"fib500",0,fib500,Color_fib500,Style_fib500,Width_fib500,"fib500 "+DoubleToString(fib500,_Digits));
      word="                      50.0";
      SetText(0,"fib500_label",0,time[0],fib500,word,Color_fib500,"Arial Black",TextSize,ANCHOR_LOWER);

      SetHline(0,"fib618",0,fib618,Color_fib618,Style_fib618,Width_fib618,"fib618 "+DoubleToString(fib618,_Digits));
      word="                      61.8";
      SetText(0,"fib618_label",0,time[0],fib618,word,Color_fib618,"Arial Black",TextSize,ANCHOR_LOWER);

      SetHline(0,"fib764",0,fib764,Color_fib764,Style_fib764,Width_fib764,"fib764 "+DoubleToString(fib764,_Digits));
      word="                      76.4";
      SetText(0,"fib764_label",0,time[0],fib764,word,Color_fib764,"Arial Black",TextSize,ANCHOR_LOWER);

      SetHline(0,"fib1000",0,fib1000,Color_fib1000,Style_fib1000,Width_fib1000,"fib1000 "+DoubleToString(fib1000,_Digits));
      word="                      100.0";
      SetText(0,"fib1000_label",0,time[0],fib1000,word,Color_fib1000,"Arial Black",TextSize,ANCHOR_LOWER);

      SetHline(0,"fib1618",0,fib1618,Color_fib1618,Style_fib1618,Width_fib1618,"fib1618 "+DoubleToString(fib1618,_Digits));
      word="                      161.8";
      SetText(0,"fib1618_label",0,time[0],fib1618,word,Color_fib1618,"Arial Black",TextSize,ANCHOR_LOWER);

      SetHline(0,"fib2618",0,fib2618,Color_fib2618,Style_fib2618,Width_fib2618,"fib2618 "+DoubleToString(fib2618,_Digits));
      word="                      261.8";
      SetText(0,"fib2618_label",0,time[0],fib2618,word,Color_fib2618,"Arial Black",TextSize,ANCHOR_LOWER);

      SetHline(0,"fib4236",0,fib4236,Color_fib4236,Style_fib4236,Width_fib4236,"fib4236 "+DoubleToString(fib4236,_Digits));
      word="                      423.6";
      SetText(0,"fib4236_label",0,time[0],fib4236,word,Color_fib4236,"Arial Black",TextSize,ANCHOR_LOWER);
     }
//----
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline
(
 long   chart_id,      // chart ID.
 string name,          // object name
 int    nwin,          // window index
 double price,         // the price level
 color  Color,         // color of the line
 int    style,         // style of a line
 int    width,         // width of a line
 string text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline
(
 long   chart_id,      // chart ID.
 string name,          // object name
 int    nwin,          // window index
 double price,         // the price level
 color  Color,         // color of the line
 int    style,         // style of a line
 int    width,         // width of a line
 string text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      //ObjectSetDouble(chart_id,name,OBJPROP_PRICE,price);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+
//|  creating a text label                                           |
//+------------------------------------------------------------------+
void CreateText(long chart_id,// chart ID
                string   name,              // object name
                int      nwin,              // window index
                datetime time,              // price level time
                double   price,             // price level
                string   text,              // Labels text
                color    Color,             // Text color
                string   Font,              // Text font
                int      Size,              // Text size
                ENUM_ANCHOR_POINT point     // The chart corner to Which an text is attached
                )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TEXT,nwin,time,price);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
//----
  }
//+------------------------------------------------------------------+
//|  changing a text label                                           |
//+------------------------------------------------------------------+
void SetText(long chart_id,// chart ID
             string   name,              // object name
             int      nwin,              // window index
             datetime time,              // price level time
             double   price,             // price level
             string   text,              // Labels text
             color    Color,             // Text color
             string   Font,              // Text font
             int      Size,              // Text size
             ENUM_ANCHOR_POINT point     // The chart corner to Which an text is attached
             )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateText(chart_id,name,nwin,time,price,text,Color,Font,Size,point);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time,price);
     }
//----
  }
//+------------------------------------------------------------------+
