//+------------------------------------------------------------------+
//|              ICT The Big Figures.mq4     Version 0.17 09/01/2012 |
//|                                                                  |
//|                                                          Tailung |
//|                                                                  |
//|                                                          NO Link |
//+------------------------------------------------------------------+
//
//
// If you want to use show the price of the bigfigures on the left you have to
// Have to select the show object discription setting in your chart properties.
//
// Known isseus
// Doesn't work so well on JPY pairs.Try to fix this in futher updates. Fixed
//
//
//
//

#property copyright "Tailung"
#property link      "NO Link"

#property indicator_chart_window
//--- input parameters
extern string    BigFigure="Big Figure Settings";
extern bool      ShowBigFigure=True;
extern bool      ShowBigFigurePrice=True;
extern color     BigFigureColor=C'25,20,20';
extern int       BigFigureStyle=0;
extern int       BigFigureWidth=3;
extern string    InstitutionalLevels="Institutional Levels Settings";
extern bool      ShowInstLevel=True;
extern bool      ShowInstLevelPrice=True;
extern color     InstLevelColor=C'20,25,20';
extern int       InstLevelStyle=0;
extern int       InstLevelWidth=2;
extern string    MidFigure="MidFigure Settings";
extern bool      ShowMidFigure=True;
extern bool      ShowMidFigurePrice=True;
extern color     MidFigureColor=C'20,20,25';
extern int       MidFigureStyle=1;
extern int       MidFigureWidth=1;


double ChartHigh, ChartLow, Range, NextBF,NextIL;
string sBF,sIL,sMF;
static double PrevRange,MaxHigh,MaxLow;
int Dig,Fact;


//+------------------------------------------------------------------+
//| Custom Functions                                                 |
//+------------------------------------------------------------------+
void DrawGrid()
  {
   int i=0;
   int BFLow=(MathRound(ChartLow*Fact))-Fact;
   int BFHigh=(MathRound(ChartHigh*Fact)+Fact);
       
   for(i=BFLow;i<=BFHigh;i++)
   {
   NextBF=i;
   if(ShowBigFigure){
   sBF=DoubleToStr(NextBF/Fact, Dig);
         if(ObjectFind("BigFigure"+sBF) !=0)
            {
            ObjectCreate("BigFigure"+sBF, OBJ_HLINE, 0, Time[1], NextBF/Fact);
            ObjectSet("BigFigure"+sBF, OBJPROP_STYLE, BigFigureStyle);
            ObjectSet("BigFigure"+sBF, OBJPROP_WIDTH, BigFigureWidth);
            ObjectSet("BigFigure"+sBF, OBJPROP_COLOR, BigFigureColor);
            ObjectSet("BigFigure"+sBF, OBJPROP_BACK, true);
            if(ShowBigFigurePrice){
            ObjectSetText("BigFigure"+sBF,"  "+ sBF , 10, "Arial", BigFigureColor);
            }
            }}
   if(ShowInstLevel)
   {
   sIL=DoubleToStr((NextBF+0.2)/Fact, Dig);         
         if(ObjectFind("InstLevel"+sIL) !=0)
            {
            ObjectCreate("InstLevel"+sIL, OBJ_HLINE, 0, Time[1], (NextBF+0.2)/Fact);
            ObjectSet("InstLevel"+sIL, OBJPROP_STYLE, InstLevelStyle);
            ObjectSet("InstLevel"+sIL, OBJPROP_WIDTH, InstLevelWidth);
            ObjectSet("InstLevel"+sIL, OBJPROP_COLOR, InstLevelColor);
            ObjectSet("InstLevel"+sIL, OBJPROP_BACK, true);
            if(ShowInstLevelPrice){
            ObjectSetText("InstLevel"+sIL,"    "+ sIL , 10, "Arial", InstLevelColor);
            }
            }
   sIL=DoubleToStr((NextBF-0.2)/Fact, Dig);         
         if(ObjectFind("InstLevel"+sIL) !=0)
            {
            ObjectCreate("InstLevel"+sIL, OBJ_HLINE, 0, Time[1], (NextBF-0.2)/Fact);
            ObjectSet("InstLevel"+sIL, OBJPROP_STYLE, InstLevelStyle);
            ObjectSet("InstLevel"+sIL, OBJPROP_WIDTH, InstLevelWidth);
            ObjectSet("InstLevel"+sIL, OBJPROP_COLOR, InstLevelColor);
            ObjectSet("InstLevel"+sIL, OBJPROP_BACK, true);
            if(ShowInstLevelPrice){
            ObjectSetText("InstLevel"+sIL,"    "+ sIL , 10, "Arial", InstLevelColor);
            }
            }
   }
   if(ShowMidFigure){
   sMF=DoubleToStr((NextBF+0.5)/Fact, Dig);         
         if(ObjectFind("MidFigure"+sMF) !=0)
            {
            ObjectCreate("MidFigure"+sMF, OBJ_HLINE, 0, Time[1], (NextBF+0.5)/Fact);
            ObjectSet("MidFigure"+sMF, OBJPROP_STYLE, MidFigureStyle);
            ObjectSet("MidFigure"+sMF, OBJPROP_WIDTH, MidFigureWidth);
            ObjectSet("MidFigure"+sMF, OBJPROP_COLOR, MidFigureColor);
            ObjectSet("MidFigure"+sMF, OBJPROP_BACK, true);
            if(ShowMidFigurePrice){
            ObjectSetText("MidFigure"+sMF,"      "+ sMF , 10, "Arial", MidFigureColor);
            }
            }
   }
   }
  return(0);
  }
  
void RemoveGrid()
  {
   int j=0;
   int BFLow=(MathRound(MaxLow*Fact))-Fact;
   int BFHigh=(MathRound(MaxHigh*Fact)+Fact);
       
   for(j=BFHigh;j>=BFLow;j--)
   {
   NextBF=j;
   sBF=DoubleToStr(NextBF/Fact, Dig); ObjectDelete("BigFigure"+sBF);
   sIL=DoubleToStr((NextBF+0.2)/Fact, Dig); ObjectDelete("InstLevel"+sIL);
   sIL=DoubleToStr((NextBF-0.2)/Fact, Dig); ObjectDelete("InstLevel"+sIL);
   sMF=DoubleToStr((NextBF+0.5)/Fact, Dig); ObjectDelete("MidFigure"+sMF);        
   }
  return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
 ChartHigh = WindowPriceMax(0);
 ChartLow = WindowPriceMin(0);
 MaxHigh=ChartHigh;
 MaxLow=ChartLow;
 PrevRange=0;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  RemoveGrid(); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
 {
 Dig = MarketInfo(Symbol(),MODE_DIGITS);
  if (Dig == 4 || Dig == 5){Dig = 4; Fact = 100;}  
  if (Dig == 2 || Dig == 3){Dig = 2; Fact = 1;}
 ChartHigh = WindowPriceMax(0);
 ChartLow = WindowPriceMin(0);
 Range = ChartHigh - ChartLow;
 
 if (MaxHigh < ChartHigh)MaxHigh=ChartHigh;
 if (MaxLow > ChartLow)MaxLow=ChartLow;
 
 if (PrevRange != Range)
 {
    PrevRange = Range;
    deinit();
    DrawGrid();
    ObjectsRedraw();
 }
  
//----
   return(0);
  }
//+------------------------------------------------------------------+