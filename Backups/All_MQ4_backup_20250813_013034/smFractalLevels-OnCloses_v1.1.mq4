//+------------------------------------------------------------------+
//|                                           smFractalLevels-OnCloses_vX
//+------------------------------------------------------------------+
#property copyright "Copyright 03.05.2019, SwingMan"
#property strict

#include <stdlib.mqh>
#include <WinUser32.mqh>

/*+------------------------------------------------------------------+
smFractalLevels
23.04.2019  v1 - First version, with horizontal fractal lines
27.04.2019  v2 - H-Lines only for fractals Level2/3   yes/no
28.04.2019  v3 - Disable the draw of Level-1 arrows
smFractalLevels-OnCloses
03.05.2019  v3 - Replace High/Low with Close
//+-----------------------------------------------------------------*/

#property indicator_chart_window

#property indicator_buffers 6
//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ARROWS_TYPE
  {
   Circles,
   Arrows,
   Triangles,
   NONE
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_STOP_LINE
  {
   Candle_HighLow,
   Candle_Body
  };

//---- input parameters
//###################################################################
//===================================================================
input int               FractalBars_LeftRight   =1;
sinput ENUM_ARROWS_TYPE FractalArrows_Type      =Circles;
input bool              Draw_Fractals_WithoutLines=false;
sinput string           sLevels="Fractal levels 1, 2 and 3"; //=================================
input bool              Draw_Level1_Arrows      =false;
input bool              Draw_Level2_Arrows      =true;
sinput bool             Draw_LastLevel2_TrendLines=true;
input bool              Draw_Level3_Arrows      =true;
input int               TrendLines_Width        =4;
input ENUM_LINE_STYLE   TrendLines_Style        =STYLE_SOLID;
sinput string           sFractalLines="Fractal lines"; //=================================
input bool              DrawOnly_Level23Lines   =true;
input bool              DrawOnly_AliveLines     =false;
input ENUM_STOP_LINE    EndOfLines              =Candle_HighLow;
input int               FractalLines_Width      =1;
input ENUM_LINE_STYLE   FractalLines_Style      =STYLE_SOLID;
input color             Color_UpperFractal_Lines=clrDodgerBlue;
input color             Color_LowerFractal_Lines=clrMagenta;
sinput string           sArrows="ARROWS"; //=================================                                          
sinput int   Arrow_Level1_Width   =2;
sinput color Arrow_Level1_Color_UP=clrAqua;
sinput color Arrow_Level1_Color_DN=clrRed;
sinput int   Arrow_Level2_Width   =2;
sinput color Arrow_Level2_Color_UP=clrAqua;
sinput color Arrow_Level2_Color_DN=clrRed;
sinput int   Arrow_Level3_Width   =4;
sinput color Arrow_Level3_Color_UP=clrAqua;
sinput color Arrow_Level3_Color_DN=clrRed;
//extern int Arrow_Offset=0;
//
//input string sBars="BARS"; //=================================
input bool Show_Comments=true;
input int MaximumBarsBack=500;
//===================================================================
//###################################################################
//
int Equals=3; //5;
int nLeftUp=1; //2;
int nRightUp=1; //2;
int nLeftDown=1; //2;
int nRightDown=1; //2;
/*=================================================================*/

//---- constants
string objTS="objFLC_";
string CR="\n";

//---- buffers
double Fractal1_UP[],Fractal2_UP[],Fractal3_UP[];
double Fractal1_DN[],Fractal2_DN[],Fractal3_DN[];

//---- variables
int cntup=0,cntdown=0,cnt=0;
int r=0,l=0,e=0;
int fup=0,fdown=0;
string shortName;
int nBars;
//
int ArrowCode1_UP,ArrowCode1_DN; //Level 1

int ArrowCode2_UP=164;  //Level 2 - Circle with MiddlePoint
int ArrowCode2_DN=164;
int ArrowCode3_UP=168;  //Level 3 - Rectangle
int ArrowCode3_DN=168;
//double arrowOffset;
//
datetime thisTime,oldTime;
//bool newDailyBar;
double dailyADR,maxChannelHeight;
datetime lastTime1,lastTime2;
double lastPrice1,lastPrice2;
//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- fractal bars   
   nLeftUp   =FractalBars_LeftRight;
   nRightUp  =FractalBars_LeftRight;
   nLeftDown =FractalBars_LeftRight;
   nRightDown=FractalBars_LeftRight;
   Equals    =2*FractalBars_LeftRight+1;
////---- arrow offset
//   if(Arrow_Offset==0)
//      switch(Period())
//        {
//         case PERIOD_MN1: Arrow_Offset=480; break;
//         case PERIOD_W1: Arrow_Offset=240; break;
//         case PERIOD_D1: Arrow_Offset=120; break;
//         case PERIOD_H4: Arrow_Offset=70; break;
//         case PERIOD_H1: Arrow_Offset=30; break;
//         case PERIOD_M30:Arrow_Offset=15; break;
//         case PERIOD_M15:Arrow_Offset=10; break;
//         case PERIOD_M5: Arrow_Offset=7; break;
//         case PERIOD_M1: Arrow_Offset=5; break;
//        }
//---- arrows type
   int ArrowWidth1=2,ArrowWidth2=2;
   if(FractalArrows_Type==Circles)
     {
      ArrowCode1_UP=159;
      ArrowCode1_DN=159;
     }
   else
   if(FractalArrows_Type==Arrows)
     {
      ArrowCode1_UP=236;
      ArrowCode1_DN=238;
     }
   else
   if(FractalArrows_Type==Triangles)
     {
      ArrowCode1_UP=217;
      ArrowCode1_DN=218;
     }

//---- indicators
   SetIndexBuffer(0,Fractal1_UP);  SetIndexStyle(0,DRAW_ARROW,0,Arrow_Level1_Width,Arrow_Level1_Color_UP); SetIndexArrow(0,ArrowCode1_UP);
   SetIndexBuffer(1,Fractal1_DN);  SetIndexStyle(1,DRAW_ARROW,0,Arrow_Level1_Width,Arrow_Level1_Color_DN); SetIndexArrow(1,ArrowCode1_DN);

   SetIndexBuffer(2,Fractal2_UP);  SetIndexStyle(2,DRAW_ARROW,0,Arrow_Level2_Width,Arrow_Level2_Color_UP); SetIndexArrow(2,ArrowCode2_UP);
   SetIndexBuffer(3,Fractal2_DN);  SetIndexStyle(3,DRAW_ARROW,0,Arrow_Level2_Width,Arrow_Level2_Color_DN); SetIndexArrow(3,ArrowCode2_DN);

   SetIndexBuffer(4,Fractal3_UP);  SetIndexStyle(4,DRAW_ARROW,0,Arrow_Level3_Width,Arrow_Level3_Color_UP); SetIndexArrow(4,ArrowCode3_UP);
   SetIndexBuffer(5,Fractal3_DN);  SetIndexStyle(5,DRAW_ARROW,0,Arrow_Level3_Width,Arrow_Level3_Color_DN); SetIndexArrow(5,ArrowCode3_DN);

   SetIndexLabel(0,"Fractal Up");
   SetIndexLabel(1,"Fractal Down");

//---- Dont draw fractal arrows
   if(FractalArrows_Type==NONE)
     {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_NONE);
     }

   if(Draw_Level1_Arrows==false)
     {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexLabel(0,NULL);
      SetIndexLabel(1,NULL);
     }

   SetIndexLabel(2,NULL);
   SetIndexLabel(3,NULL);
   SetIndexLabel(4,NULL);
   SetIndexLabel(5,NULL);

//----
   cntup=nLeftUp+nRightUp+Equals+1;
   cntdown=nLeftDown+Equals+1;
   if(cntup>=cntdown)
      cnt=cntup;
   if(cntup<cntdown)
      cnt=cntdown;

//----
   shortName=StringConcatenate(WindowExpertName(),CR,"====================",CR);
   IndicatorShortName(shortName);
   if(Show_Comments)
      Comment(shortName);

   ObjectsDeleteAll(0,objTS);
   IndicatorDigits(Digits);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0,objTS);
   Comment("");
//----
   return(0);
  }
//  
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
   int cbars=IndicatorCounted();

   if(cbars<0) return(-1);
   if(cbars>0) cbars--;
   int pos=0;

//---- bars number
   nBars=Bars;
   if(Bars>MaximumBarsBack)
      nBars=MaximumBarsBack;

   if(cbars>(nBars-cnt-1))
      pos=(nBars-cnt-1);
   else
      pos=nBars -(cbars+nRightUp);
   if(cbars==0) pos-=Equals;

//----
   while(pos>=nRightUp)
     {
      Fractal1_UP[pos]=EMPTY_VALUE;
      Fractal1_DN[pos]=EMPTY_VALUE;

      //--- check new DailyBar
      thisTime=iTime(Symbol(),Period(),pos);
      if(thisTime!=oldTime)
        {
         //newDailyBar=true;
         oldTime=thisTime;
        }

      //===================================================
      Get_FractalLevels_1(pos);
      //===================================================

      pos--;
     }

//---
   if(Draw_Level2_Arrows || DrawOnly_Level23Lines) Get_FractalLevels_2();  // changed of Jagg / forexfactory
   if(Draw_Level3_Arrows || DrawOnly_Level23Lines) Get_FractalLevels_3();
//if(Draw_Level2_Arrows) Get_FractalLevels_2();
//if(Draw_Level3_Arrows) Get_FractalLevels_3();

//--- Draw Fractal lines     
   if(Draw_Fractals_WithoutLines==false)
      Draw_FractalLines();

//---
   if(Draw_LastLevel2_TrendLines)
      Draw_LastLevel2_TrendLines_Void();

//----
   return(0);
  }
//
//####################################################################
//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
void Draw_FractalLines()
  {
   int iBar1=0,iBar2=0;
   double dPrice1=0,dPrice2=0;

   ObjectsDeleteAll(0,objTS);

//-- 1. upper lines ----------------------------------------
   for(int i=0;i<=nBars-5;i++)
     {
      //if (i==5)
      //int ff=3;     
      if(Fractal1_UP[i]!=EMPTY_VALUE && Fractal1_UP[i]!=0)
        {
         //if(DrawOnly_Level23Lines==true && (Fractal2_UP[i]!=EMPTY_VALUE || Fractal3_UP[i]!=EMPTY_VALUE))
         if(DrawOnly_Level23Lines==false || (DrawOnly_Level23Lines==true && (Fractal2_UP[i]!=EMPTY_VALUE || Fractal3_UP[i]!=EMPTY_VALUE)))
           {
            iBar1=i;
            dPrice1=Fractal1_UP[i];

            iBar2=0;
            for(int j=iBar1-1;j>=0;j--)
              {
               if(EndOfLines==Candle_HighLow)
                 {
                  if(dPrice1<High[j] && dPrice1>Low[j])
                    {
                     iBar2=j;
                     break;
                    }
                 }
               else
               if(EndOfLines==Candle_Body)
                 {
                  double maxBody=MathMax(Open[j],Close[j]);
                  double minBody=MathMin(Open[j],Close[j]);
                  if(dPrice1<maxBody && dPrice1>minBody)
                    {
                     iBar2=j;
                     break;
                    }
                 }
              }
            if((DrawOnly_AliveLines==false) || (DrawOnly_AliveLines==true && iBar2==0))
               Paint_TrendLine(iBar1,dPrice1,iBar2,dPrice1,Color_UpperFractal_Lines,FractalLines_Width,FractalLines_Style,"up");
           }
        }
     }

//-- 2. lower lines ----------------------------------------
   for(int i=0;i<=nBars-5;i++)
     {
      if(Fractal1_DN[i]!=EMPTY_VALUE && Fractal1_DN[i]!=0)
        {
         if(DrawOnly_Level23Lines==false || (DrawOnly_Level23Lines==true && (Fractal2_DN[i]!=EMPTY_VALUE || Fractal3_DN[i]!=EMPTY_VALUE)))
           {
            iBar1=i;
            dPrice1=Fractal1_DN[i];

            iBar2=0;
            for(int j=iBar1-1;j>=0;j--)
              {
               if(EndOfLines==Candle_HighLow)
                 {
                  if(dPrice1<High[j] && dPrice1>Low[j])
                    {
                     iBar2=j;
                     break;
                    }
                 }
               else
               if(EndOfLines==Candle_Body)
                 {
                  double maxBody=MathMax(Open[j],Close[j]);
                  double minBody=MathMin(Open[j],Close[j]);
                  if(dPrice1<maxBody && dPrice1>minBody)
                    {
                     iBar2=j;
                     break;
                    }
                 }
              }
            if((DrawOnly_AliveLines==false) || (DrawOnly_AliveLines==true && iBar2==0))
               Paint_TrendLine(iBar1,dPrice1,iBar2,dPrice1,Color_LowerFractal_Lines,FractalLines_Width,FractalLines_Style,"dn");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_LastLevel2_TrendLines_Void()
  {
   int iBar1=0,iBar2=0;
   double dPrice1=0,dPrice2=0;
   double dPrice0=0;
//-- 1. upper line ----------------------------------------
   for(int i=0;i<=nBars-5;i++)
     {
      if(Fractal2_UP[i]!=EMPTY_VALUE && Fractal2_UP[i]!=0)
        {
         iBar2=i;
         dPrice2=Fractal2_UP[i];
         break;
        }
     }
   for(int i=iBar2+1;i<=nBars-5;i++)
     {
      if(Fractal2_UP[i]!=EMPTY_VALUE && Fractal2_UP[i]!=0)
        {
         iBar1=i;
         dPrice1=Fractal2_UP[i];
         break;
        }
     }

//-- 1.1 upper line at bar 0
   dPrice0=dPrice2+(dPrice2-dPrice1)*(iBar2)/(iBar1-iBar2);
   Paint_TrendLine(iBar1,dPrice1,0,dPrice0,clrDodgerBlue,TrendLines_Width,TrendLines_Style,"uT");

//-- 2. lover line ----------------------------------------
   iBar1=0;iBar2=0;
   dPrice1=0;dPrice2=0;
   for(int i=0;i<=nBars-5;i++)
     {
      if(Fractal2_DN[i]!=EMPTY_VALUE && Fractal2_DN[i]!=0)
        {
         iBar2=i;
         dPrice2=Fractal2_DN[i];
         break;
        }
     }
   for(int i=iBar2+1;i<=nBars-5;i++)
     {
      if(Fractal2_DN[i]!=EMPTY_VALUE && Fractal2_DN[i]!=0)
        {
         iBar1=i;
         dPrice1=Fractal2_DN[i];
         break;
        }
     }

//-- 2.1 lover line at bar 0
   dPrice0=dPrice2+(dPrice2-dPrice1)*(iBar2)/(iBar1-iBar2);
   Paint_TrendLine(iBar1,dPrice1,0,dPrice0,clrRed,TrendLines_Width,TrendLines_Style,"lT");

   WindowRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Paint_TrendLine(int bar1,double price1,int bar2,double price2,color dColor,int lineWidth,int lineStyle,string code)
  {
   datetime time1=Time[bar1];
   datetime time2=Time[bar2];
   string objName=objTS+TimeToString(time1)+code;
   if(ObjectFind(objName)>=0) ObjectDelete(objName);

   ObjectCreate(0,objName,OBJ_TREND,0,time1,price1,time2,price2);
   ObjectSet(objName,OBJPROP_COLOR,dColor);
   ObjectSet(objName,OBJPROP_WIDTH,lineWidth);
   ObjectSet(objName,OBJPROP_STYLE,lineStyle);

   ObjectSet(objName,OBJPROP_RAY,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
void Get_FractalLevels_3()
  {
   double thisFractal[4];
   int barNumber[4];

//-- 1. fractals UP ----------------------------------------------
   int index=0;
   int iBar=0;

   for(int i=0;i<=nBars-5;i++)
     {
      if(Fractal2_UP[i]!=EMPTY_VALUE && Fractal2_UP[i]!=0)
        {
         index++;
         thisFractal[index]=Fractal2_UP[i];
         barNumber[index]=i;

         if(index==3)
           {
            if(thisFractal[1]<thisFractal[2] && thisFractal[3]<thisFractal[2]) //-- major fractal
              {
               iBar=barNumber[2];
               Fractal3_UP[iBar]=bodyHigh(iBar);   //replace High with Close
               //Fractal3_UP[iBar]=Close[iBar];   //replace High with Close
                                                //-- move to position 1
               index=1;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
               index++;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
              }
            else
              {
               //-- move to position 1
               index=1;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
               index++;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
              }
           }
        }
     }

//-- 2. fractals DOWN --------------------------------------------
   index=0;
   iBar=0;

   for(int i=0;i<=nBars-5;i++)
     {
      if(Fractal2_DN[i]!=EMPTY_VALUE && Fractal2_DN[i]!=0)
        {
         index++;
         thisFractal[index]=Fractal2_DN[i];
         barNumber[index]=i;

         if(index==3)
           {
            if(thisFractal[1]>thisFractal[2] && thisFractal[3]>thisFractal[2]) //-- major fractal
              {
               iBar=barNumber[2];
               Fractal3_DN[iBar]=bodyLow(iBar);   //replace Low with Close
               //Fractal3_DN[iBar]=Close[iBar];   //replace Low with Close
                                                //-- move to position 1
               index=1;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
               index++;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
              }
            else
              {
               //-- move to position 1
               index=1;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
               index++;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
void Get_FractalLevels_2()
  {
   double thisFractal[4];
   int barNumber[4];

//-- 1. fractals UP ----------------------------------------------
   int index=0;
   int iBar=0;

   for(int i=0;i<=nBars-5;i++)
     {
      if(Fractal1_UP[i]!=EMPTY_VALUE && Fractal1_UP[i]!=0)
        {
         index++;
         thisFractal[index]=Fractal1_UP[i];
         barNumber[index]=i;

         if(index==3)
           {
            if(thisFractal[1]<thisFractal[2] && thisFractal[3]<thisFractal[2]) //-- major fractal
              {
               iBar=barNumber[2];
               Fractal2_UP[iBar]=bodyHigh(iBar); //replace High with Close
               //Fractal2_UP[iBar]=Close[iBar]; //replace High with Close
                                              //-- move to position 1
               index=1;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
               index++;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
              }
            else
              {
               //-- move to position 1
               index=1;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
               index++;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
              }
           }
        }
     }

//-- 2. fractals DOWN --------------------------------------------
   index=0;
   iBar=0;

   for(int i=0;i<=nBars-5;i++)
     {
      if(Fractal1_DN[i]!=EMPTY_VALUE && Fractal1_DN[i]!=0)
        {
         index++;
         thisFractal[index]=Fractal1_DN[i];
         barNumber[index]=i;

         if(index==3)
           {
            if(thisFractal[1]>thisFractal[2] && thisFractal[3]>thisFractal[2]) //-- major fractal
              {
               iBar=barNumber[2];
               Fractal2_DN[iBar]=bodyLow(iBar);  //replace Low with Close
               //Fractal2_DN[iBar]=Close[iBar];  //replace Low with Close
                                               //-- move to position 1
               index=1;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
               index++;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
              }
            else
              {
               //-- move to position 1
               index=1;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
               index++;
               thisFractal[index]=thisFractal[index+1];
               barNumber[index]=barNumber[index+1];
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double bodyHigh(int iBar)
  {
   double bodyHighM=MathMax(Open[iBar],Close[iBar]);
   return(bodyHighM);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double bodyLow(int iBar)
  {
   double bodyLowM=MathMin(Open[iBar],Close[iBar]);
   return(bodyLowM);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Get_FractalLevels_1(int pos)
  {
   int i,j;
   Fractal1_UP[pos]=0;
   Fractal1_DN[pos]=0;

//===================================================   
//FRACTAL UP
   r=nRightUp; // check the right side of the fractal
//---- Replace High with Close
   for(i=1; i<=r; i++)
     {
      if(bodyHigh(pos)<=bodyHigh(pos-i))
         break;
     }
//-- if everything is OK on the right then i must be equal to r + 1
   if(i==r+1) //Fractal1_UP[pos]=High[pos];
     {
      l=nLeftUp;  // check the left side of the fractal
      e= Equals;
      //----
      for(j=1; j<=l+Equals; j++)
        {
         if(bodyHigh(pos)<bodyHigh(pos+j))
            break;
         //----
         if(bodyHigh(pos)>bodyHigh(pos+j))
            l--;
         //----
         if(bodyHigh(pos)==bodyHigh(pos+j))
            e--;
         //----
         if(l==0)
           {
            Fractal1_UP[pos]=bodyHigh(pos); //+arrowOffset;
            break;
           }
         //----
         if(e<0)
            break;
        }
     }

//===================================================
//FRACTAL DOWN
   r=nRightDown; // check the right side of the fractal
//---- Replace Low with Close
   for(i=1; i<=r; i++)
     {
      if(bodyLow(pos)>=bodyLow(pos-i))
         break;
     }
//if(Time[i]==D'2019.01.25 00:00')
//int zz=4;     
//----
   if(i==r+1) //Fractal1_UP[pos]=High[pos];
     {
      l=nLeftDown;  // check the left side of the fractal
      e= Equals;
      //----
      for(j=1; j<=l+Equals; j++)
        {
         if(bodyLow(pos)>bodyLow(pos+j))
            break;
         //----
         if(bodyLow(pos)<bodyLow(pos+j))
            l--;
         //----
         if(bodyLow(pos)==bodyLow(pos+j))
            e--;
         //----
         if(l==0)
           {
            Fractal1_DN[pos]=bodyLow(pos); //-arrowOffset;
            break;
           }
         if(e<0)
            break;
        }
     }
  }
//+------------------------------------------------------------------+
