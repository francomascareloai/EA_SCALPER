//+------------------------------------------------------------------+
//|                                           AA_MTF_Stoch_Histo.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_separate_window

#property indicator_buffers 4
#property indicator_minimum -2.5
#property indicator_maximum 102.5

sinput string text_01 = "====== You can define 4 TF's ======";
sinput ENUM_TIMEFRAMES _TF_1 = PERIOD_M5;             // TF1
sinput bool default_TF1= true;                        // TF1 default visible;
sinput ENUM_TIMEFRAMES _TF_2 = PERIOD_M15;            // TF2
sinput bool default_TF2= true;                        // TF2 default visible;
sinput ENUM_TIMEFRAMES _TF_3 = PERIOD_M30;            // TF3
sinput bool default_TF3= true;                        // TF3 default visible;
sinput ENUM_TIMEFRAMES _TF_4 = PERIOD_H1;             // TF4
sinput bool default_TF4= false;                       // TF4 default visible;
sinput bool autoTimeframes = true;                    // TF1, TF1+1, TF1+2, TF1+3
sinput int nbrOfBars = 750;                           // Number of bars to display
sinput string text_02 = "====== Layout settings 4 TF's ======";
sinput color clrTF_1 = clrLime;                       // Color TF 1
sinput ENUM_LINE_STYLE  style_TF_1 = STYLE_SOLID;     // Line style TF 1
sinput int lineWidth_TF_1 = 2;                        // Line width TF 1
sinput color clrTF_2 = clrRed;                        // Color TF 2
sinput ENUM_LINE_STYLE  style_TF_2 = STYLE_SOLID;     // Line style TF 2
sinput int lineWidth_TF_2 = 2;                        // Line width TF 2
sinput color clrTF_3 = clrGold;                       // Color TF 3
sinput ENUM_LINE_STYLE  style_TF_3 = STYLE_SOLID;     // Line style TF 3
sinput int lineWidth_TF_3 = 2;                        // Line width TF 3
sinput color clrTF_4 = clrMagenta;                    // Color TF 4
sinput ENUM_LINE_STYLE  style_TF_4 = STYLE_SOLID;     // Line style TF 4
sinput int lineWidth_TF_4 = 2;                        // Line width TF 4

sinput string text_03 = "====== DDS settings ======";
sinput double Slw = 8;                                // Settings 1
sinput double Pds = 13;                               // Settings 2
sinput double Slwsignal = 9;                          // Settings 3

sinput string objectPreamble ="DDS_mtf_";             // Objects unique id

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];


int timeFrame_1 = 1;
int timeFrame_2 = 1;
int timeFrame_3 = 1;
int timeFrame_4 = 1;

bool displayLegend = false;
int chartWindow;

static bool glbTF_1 = true;
static bool glbTF_2 = true;
static bool glbTF_3 = true;
static bool glbTF_4 = true;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   
   deleteObjects();
   EventSetTimer(5);
   if (!autoTimeframes)
   {
      timeFrame_1 = _TF_1;
      if (_TF_1 < Period())
      {
         timeFrame_1 = Period();
      }
      timeFrame_2 = _TF_2;
      if (_TF_2 < Period())
      {
         timeFrame_2 = Period();
      }
      timeFrame_3 = _TF_3;
      if (_TF_3 < Period())
      {
         timeFrame_3 = Period();
      }
      timeFrame_4 = _TF_4;
      if (_TF_4 < Period())
      {
         timeFrame_4 = Period();
      }
   }
   else
   {
      timeFrame_1 = _TF_1;
      if (_TF_1 < Period())
      {
         timeFrame_1 = Period();
      }
      timeFrame_2 = getNextTF(timeFrame_1);
      timeFrame_3 = getNextTF(timeFrame_2);
      timeFrame_4 = getNextTF(timeFrame_3);
   }
   
//--- indicator buffers mapping
   
//---
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0, DRAW_LINE,style_TF_1,lineWidth_TF_1,clrTF_1);
   SetIndexLabel(0, getTfAsString(timeFrame_1));
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1, DRAW_LINE,style_TF_2,lineWidth_TF_2,clrTF_2);
   SetIndexLabel(1, getTfAsString(timeFrame_2));
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(2, DRAW_LINE,style_TF_3,lineWidth_TF_3,clrTF_3);
   SetIndexLabel(2, getTfAsString(timeFrame_3));
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(3, DRAW_LINE,style_TF_4,lineWidth_TF_4,clrTF_4);
   SetIndexLabel(3, getTfAsString(timeFrame_4));
   
   
   chartWindow = ChartWindowFind();
   
   if (default_TF1)
   {
      Create_Button(objectPreamble+"btn_TF1",getTfAsString(timeFrame_1), chartWindow, 70, 20, 80, 30, clrTF_1, clrBlack, clrWhite, 8);
      SetIndexStyle(0, DRAW_LINE,style_TF_1,lineWidth_TF_1,clrTF_1);
   }
   else
   {
      Create_Button(objectPreamble+"btn_TF1",getTfAsString(timeFrame_1), chartWindow, 70, 20, 80, 30, clrLightGray, clrBlack, clrWhite, 8);
      SetIndexStyle(0, DRAW_NONE,style_TF_1,lineWidth_TF_1,clrTF_1);
      glbTF_1 = false;
   }
   if (default_TF2)
   {
      Create_Button(objectPreamble+"btn_TF2",getTfAsString(timeFrame_2), chartWindow, 70, 20, 80, 55, clrTF_2, clrBlack, clrWhite, 8);
      SetIndexStyle(1, DRAW_LINE,style_TF_2,lineWidth_TF_2,clrTF_2);
   }
   else
   {
      Create_Button(objectPreamble+"btn_TF2",getTfAsString(timeFrame_2), chartWindow, 70, 20, 80, 55, clrLightGray, clrBlack, clrWhite, 8);
      SetIndexStyle(1, DRAW_NONE,style_TF_2,lineWidth_TF_2,clrTF_2);
      glbTF_2 = false;
   }
   if (default_TF3)
   {
      Create_Button(objectPreamble+"btn_TF3",getTfAsString(timeFrame_3), chartWindow, 70, 20, 80, 80, clrTF_3, clrBlack, clrWhite, 8);
      SetIndexStyle(2, DRAW_LINE,style_TF_3,lineWidth_TF_3,clrTF_3);
   }
   else
   {
      Create_Button(objectPreamble+"btn_TF3",getTfAsString(timeFrame_3), chartWindow, 70, 20, 80, 80, clrLightGray, clrBlack, clrWhite, 8);
      SetIndexStyle(2, DRAW_NONE,style_TF_3,lineWidth_TF_3,clrTF_3);
      glbTF_3 = false;
   }
   if (default_TF4)
   {
      Create_Button(objectPreamble+"btn_TF4",getTfAsString(timeFrame_4), chartWindow, 70, 20, 80, 105, clrTF_4, clrBlack, clrWhite, 8);
      SetIndexStyle(3, DRAW_LINE,style_TF_4,lineWidth_TF_4,clrTF_4);
   }
   else
   {
      Create_Button(objectPreamble+"btn_TF4",getTfAsString(timeFrame_4), chartWindow, 70, 20, 80, 105, clrLightGray, clrBlack, clrWhite, 8);
      SetIndexStyle(3, DRAW_NONE,style_TF_4,lineWidth_TF_4,clrTF_4);
      glbTF_4 = false;
   }
   
   // bars in chart
   
   //Chart
   return(INIT_SUCCEEDED);
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
   ddsCalculate();   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
 
   
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
   if (id == CHARTEVENT_OBJECT_CLICK)
   {
   
      if (StringFind(sparam, objectPreamble+"btn_TF1") >= 0)
      {
         // check global
         if (glbTF_1)
         {
            SetIndexStyle(0, DRAW_NONE,style_TF_1,lineWidth_TF_1,clrTF_1);
            glbTF_1 = false;
            ObjectSetInteger(0, objectPreamble+"btn_TF1", OBJPROP_BGCOLOR, clrLightGray);
         }
         else
         {
            SetIndexStyle(0, DRAW_LINE,style_TF_1,lineWidth_TF_1,clrTF_1);
            glbTF_1 = true;
            ObjectSetInteger(0, objectPreamble+"btn_TF1", OBJPROP_BGCOLOR,clrTF_1 );
         }
         ObjectSetInteger(0, objectPreamble+"btn_TF1", OBJPROP_STATE, 0);
      }
      else if (StringFind(sparam, objectPreamble+"btn_TF2") >= 0)
      {
         // check global
         if (glbTF_2)
         {
            SetIndexStyle(1, DRAW_NONE,style_TF_2,lineWidth_TF_2,clrTF_2);
            glbTF_2 = false;
            ObjectSetInteger(0, objectPreamble+"btn_TF2", OBJPROP_BGCOLOR, clrLightGray);
         }
         else
         {
            SetIndexStyle(1, DRAW_LINE,style_TF_2,lineWidth_TF_2,clrTF_2);
            glbTF_2 = true;
            ObjectSetInteger(0, objectPreamble+"btn_TF2", OBJPROP_BGCOLOR,clrTF_2 );
         }
         ObjectSetInteger(0, objectPreamble+"btn_TF2", OBJPROP_STATE, 0);
      }
      else if (StringFind(sparam, objectPreamble+"btn_TF3") >= 0)
      {
         // check global
         if (glbTF_3)
         {
            SetIndexStyle(2, DRAW_NONE,style_TF_3,lineWidth_TF_3,clrTF_3);
            glbTF_3 = false;
            ObjectSetInteger(0, objectPreamble+"btn_TF3", OBJPROP_BGCOLOR, clrLightGray);
         }
         else
         {
            SetIndexStyle(2, DRAW_LINE,style_TF_3,lineWidth_TF_3,clrTF_3);
            glbTF_3 = true;
            ObjectSetInteger(0, objectPreamble+"btn_TF3", OBJPROP_BGCOLOR,clrTF_3 );
         }
         ObjectSetInteger(0, objectPreamble+"btn_TF3", OBJPROP_STATE, 0);
      }
      else if (StringFind(sparam, objectPreamble+"btn_TF4") >= 0)
      {
         // check global
         if (glbTF_4)
         {
            SetIndexStyle(3, DRAW_NONE,style_TF_4,lineWidth_TF_4,clrTF_4);
            glbTF_4 = false;
            ObjectSetInteger(0, objectPreamble+"btn_TF4", OBJPROP_BGCOLOR, clrLightGray);
         }
         else
         {
            SetIndexStyle(3, DRAW_LINE,style_TF_4,lineWidth_TF_4,clrTF_4);
            glbTF_4 = true;
            ObjectSetInteger(0, objectPreamble+"btn_TF4", OBJPROP_BGCOLOR,clrTF_4 );
         }
         ObjectSetInteger(0, objectPreamble+"btn_TF4", OBJPROP_STATE, 0);
      }
   }
}
//+------------------------------------------------------------------+

void ddsCalculate()
{

   datetime TimeArray[];
   int    i, limit ,y = 0, counted_bars = IndicatorCounted();
   int limit_A;
   
   
   limit = Bars - 25 - counted_bars;
   //limit = limit - 50;
   //Alert(limit);
   if (limit > nbrOfBars)
   {
      limit = nbrOfBars;
   }
   //Alert(limit);
   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),timeFrame_1);
   if (limit < timeFrame_1 / Period())
   {
      limit_A = timeFrame_1 / Period() + 1;
   }
   else { limit_A = limit + 1;}
   for(i = 0, y = 0; i < limit;i++)
   {
      if (Time[i] < TimeArray[y]) y++;
      
      ExtMapBuffer1[i] = iCustom(Symbol(), timeFrame_1, "DDS", Slw, Pds, Slwsignal, nbrOfBars, 0, y);
   }
   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),timeFrame_2);
   if (limit < timeFrame_2 / timeFrame_1)
   {
      limit_A = timeFrame_2 / timeFrame_1 + 1;
   }
   else { limit_A = limit + 1;}
   for(i = 0, y = 0; i < limit_A;i++)
   {
      if (Time[i] < TimeArray[y]) y++;
      ExtMapBuffer2[i] = iCustom(Symbol(), timeFrame_2, "DDS", Slw, Pds, Slwsignal, nbrOfBars, 0, y);
   }
   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),timeFrame_3);
   if (limit < timeFrame_3 / timeFrame_1)
   {
      limit_A = timeFrame_3 / timeFrame_1 + 1;
   }
   else { limit_A = limit + 1;}
   for(i = 0, y = 0; i < limit_A;i++)
   {
      if (Time[i] < TimeArray[y]) y++;
      ExtMapBuffer3[i] = iCustom(Symbol(), timeFrame_3, "DDS", Slw, Pds, Slwsignal, nbrOfBars, 0, y);
   }
   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),timeFrame_4);
   if (limit < timeFrame_4 / timeFrame_1)
   {
      limit_A = timeFrame_4 / timeFrame_1 + 1;
   }
   else { limit_A = limit + 1;}
   for(i = 0, y = 0; i < limit_A;i++)
   {
      if (Time[i] < TimeArray[y]) y++;
      ExtMapBuffer4[i] = iCustom(Symbol(), timeFrame_4, "DDS", Slw, Pds, Slwsignal, nbrOfBars, 0, y);
   }

}

int getNextTF(int _tf)
{
   if (_tf == PERIOD_M1) {return PERIOD_M5;}
   if (_tf == PERIOD_M5) {return PERIOD_M15;}
   if (_tf == PERIOD_M15) {return PERIOD_H1;}
   if (_tf == PERIOD_M30) {return PERIOD_H1;}
   if (_tf == PERIOD_H1) {return PERIOD_H4;}
   if (_tf == PERIOD_H4) {return PERIOD_D1;}
   if (_tf == PERIOD_D1) {return PERIOD_W1;}
   if (_tf == PERIOD_W1) {return PERIOD_MN1;}
   
   return PERIOD_MN1;
}

string getTfAsString( int _tf)
{

   if (_tf == PERIOD_M1) {return "M1";}
   if (_tf == PERIOD_M5) {return "M5";}
   if (_tf == PERIOD_M15) {return "M15";}
   if (_tf == PERIOD_M30) {return "M30";}
   if (_tf == PERIOD_H1) {return "H1";}
   if (_tf == PERIOD_H4) {return "H4";}
   if (_tf == PERIOD_D1) {return "D1";}
   if (_tf == PERIOD_W1) {return "W1";}
   if (_tf == PERIOD_MN1) {return "MN1";}
   
   return "--";

}


//+------------------------------------------------------------------+
void SetText(string name,string text, int window, int x,int y,color colour,int fontsize=12)
{
   if (ObjectFind(0,name)<0)
      ObjectCreate(0,name,OBJ_LABEL,window,0,0);

    ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
    ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
    ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
    ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
    ObjectSetInteger(0,name,OBJPROP_ALIGN,ALIGN_RIGHT);
    ObjectSetString(0,name,OBJPROP_TEXT,text);
}

void Create_Button(string but_name, string label, int window, int xsize, int ysize, 
                     int xdist, int ydist, int bgcolor, int fcolor, int bcolor, int _fontSize)
{
    
   if(ObjectFind(0,but_name)<0)
   {
      if(!ObjectCreate(0,but_name,OBJ_BUTTON, window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",GetLastError());
         return;
        }
      ObjectSetString(0,but_name,OBJPROP_TEXT,label);
      ObjectSetInteger(0,but_name,OBJPROP_XSIZE,xsize);
      ObjectSetInteger(0,but_name,OBJPROP_YSIZE,ysize);
      ObjectSetInteger(0,but_name,OBJPROP_CORNER,CORNER_RIGHT_LOWER);     
      ObjectSetInteger(0,but_name,OBJPROP_XDISTANCE,xdist);      
      ObjectSetInteger(0,but_name,OBJPROP_YDISTANCE,ydist);         
      ObjectSetInteger(0,but_name,OBJPROP_BGCOLOR,bgcolor);
      ObjectSetInteger(0,but_name,OBJPROP_COLOR,fcolor);
      ObjectSetInteger(0,but_name,OBJPROP_BORDER_COLOR,bcolor);
      ObjectSetInteger(0,but_name,OBJPROP_FONTSIZE,_fontSize);
      ObjectSetInteger(0,but_name,OBJPROP_HIDDEN,true);
      //ObjectSetInteger(0,but_name, OBJPROP_CORNER,4);
      //ObjectSetInteger(0,but_name,OBJPROP_BORDER_COLOR,ChartGetInteger(0,CHART_COLOR_FOREGROUND));
      ObjectSetInteger(0,but_name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      
      ChartRedraw();      
   }
}

void deleteObjects()
{
   string s;
   string name;
   s = objectPreamble; //_symbolPair;
   //s = Symbol();
   for (int i = ObjectsTotal() - 1; i >= 0; i--)
   {
     name = ObjectName(i);
     if (StringSubstr(name, 0, StringLen(s)) == s)
     {
         ObjectDelete(name);
     }
   }
}