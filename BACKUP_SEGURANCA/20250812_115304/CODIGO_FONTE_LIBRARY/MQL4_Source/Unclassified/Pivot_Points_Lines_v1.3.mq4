//+------------------------------------------------------------------+
//|                                      Pivot_Points_Lines_v1.3.mq4 |
//|                                         Copyright 2021, NickBixy |
//|             https://www.forexfactory.com/showthread.php?t=904734 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, NickBixy"
#property link      "https://www.forexfactory.com/showthread.php?t=904734"
//#property version   "1.3"
#property strict
#property indicator_chart_window
enum pivotTypes
  {
   Standard,//Standard(Floor)
   Fibonacci,//Fibonacci
   Camarilla,//Camarilla
   Woodie,//Woodie
   Traditional,//Traditional
   Demark,//Demark
   Classic//Classic
  };
enum yesnoChoiceToggle
  {
   No,
   Yes
  };
enum enabledisableChoiceToggle
  {
   Disable,
   Enable
  };
enum labelLocation1
  {
   Left_1,//Left
   Middle_1,//Middle
   Right_1,//Right
  };
enum labelLocation2
  {
   Follow_Price_2,//Follow Price
   Left_2,//Left
   Middle_2,//Middle
   Right_2,//Right
  };
input string indiLink="https://www.forexfactory.com/showthread.php?t=904734";//Indicator's Support Thread On Forex Factory
input int UniqueID=1;//Unique ID
input int historicalPP=0;//Historical Pivot Points,Set 0 for NONE
input string Header="----------------- Pivot Point Settings------------------------------------------";//----- Pivot Point Settings
input pivotTypes pivotSelection=Standard;//Formula
input ENUM_TIMEFRAMES timeFrame=PERIOD_D1;//TimeFrame
input yesnoChoiceToggle drawFuturePlot=No;//Draw Future Plot?
input yesnoChoiceToggle showPriceLabel=No;//Show Price In Label?
input yesnoChoiceToggle useShortLines=No;//Draw Short Lines For Current Period?
input int ShiftLabel=3;//Label Follow Price Shift -Move Left, +Move Right
input int Line_Length=15;//Length Of Short Line
input string HeaderStandardAdditionalSettings="----------------- Standard(Floor) Additional Settings------------------------------------------";//----- Standard(Floor) Additional Settings
input yesnoChoiceToggle drawFloorMidPP=No;//Show Mid Pivot Points?
input yesnoChoiceToggle floorCPR=Yes;//Show Central Pivot Range?
input string Header2="----------------- Line/Label Customize Settings------------------------------------------";//----- Line/Label Customize Settings
input string customMSG="";//MSG Before Pivot Point Name
input ENUM_LINE_STYLE lineStyle=STYLE_SOLID;//Line Style
input int lineWidth=1;//Line Width
input string Font="Arial";//Label Font
input int labelFontSize=8;//Label Text Size
input labelLocation1 historicalLabelLocation=Left_1;//Historical Label Location?
input labelLocation2 currentLabelLocation=Follow_Price_2;//Current Label Location?
input labelLocation1 futureLabelLocation=Right_1;//Future Label Location?
input yesnoChoiceToggle hideHistoricalLabels=No;//Hide Historical Pivot Points Labels?
input yesnoChoiceToggle hideCurrentLabels=No;//Hide Current Pivot Points Labels?
input yesnoChoiceToggle hideFutureLabels=No;//Hide Future Pivot Points Labels?
input yesnoChoiceToggle useSameColorLabelChoice=Yes;//Label Use Same Color?
input color useSameColorLabelColor=clrWhite;//Label Color For Label Use Same Color
input color resistantColor=clrRed;//Resistant Line/Label Color
input color pivotColor=clrYellow;//Pivot Line/Label Color
input color supportColor=clrLime;//Support Line/Label Color
input color midColor=clrGreen;//Standard(Floor)Mid PP Line/Label Color
input color CPRColor=clrViolet;//Standard(Floor)CPR PP Line/Label Color
string indiName="PPL"+(string)UniqueID+" "+EnumToString(pivotSelection)+" "+EnumToString(timeFrame)+" ";
string camarillaPivotNames[]=
  {
   "PP",
   "L1",
   "L2",
   "L3",
   "L4",
   "H1",
   "H2",
   "H3",
   "H4",
   "H5",
   "L5",
  };
double camarillaValueArray[11];
bool showCamarilla[11];
string standardPivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "S3",
   "R1",
   "R2",
   "R3",
   "R4",
   "S4",
   "MR4",
   "MR3",
   "MR2",
   "MR1",
   "MS1",
   "MS2",
   "MS3",
   "MS4",
  };
double standardValueArray[17];
bool showStandard[17];
string traditionalPivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "S3",
   "R1",
   "R2",
   "R3",
   "R4",
   "S4",
   "S5",
   "R5",
  };
double traditionalValueArray[11];
bool showTraditional[11];
string demarkPivotNames[]=
  {
   "PP",
   "R1",
   "S1"
  };
double demarkValueArray[3];
bool showDemark[3];
string woodiePivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "R1",
   "R2",
   "S3",
   "S4",
   "R3",
   "R4",
  };
double woodieValueArray[9];
bool showWoodie[9];
string fibonacciPivotNames[]=
  {
   "PP",
   "R38",
   "R61",
   "R78",
   "R100",
   "R138",
   "R161",
   "R200",
   "S38",
   "S61",
   "S78",
   "S100",
   "S138",
   "S161",
   "S200",
  };
double fibonacciValueArray[15];
bool showFibonacci[15];
string classicPivotNames[]=
  {
   "PP",
   "S1",
   "S2",
   "S3",
   "S4",
   "R1",
   "R2",
   "R3",
   "R4"
  };
//+------------------------------------------------------------------+
double classicValueArray[9];
bool showClassic[9];
string floorCPRPivotNames[]=
  {
   "BC",
   "TC"
  };
double floorCPRValueArray[2];
bool showFloorCPR[2];
input string showHeader="-----------------Enable/Disable Specified Pivot Point----------------------------------------------";//----- Enable/Disable Specified Pivot Point
input string showStandardPivotHeader="Standard(Floor) Pivot Point--------------------------------------------";//----- Standard(Floor) Pivot Point Settings
input enabledisableChoiceToggle showStandardPivotR4=Enable;//Standard Pivot R4
input enabledisableChoiceToggle showStandardPivotR3=Enable;//Standard Pivot R3
input enabledisableChoiceToggle showStandardPivotR2=Enable;//Standard Pivot R2
input enabledisableChoiceToggle showStandardPivotR1=Enable;//Standard Pivot R1
input enabledisableChoiceToggle showStandardPivotPP=Enable;//Standard Pivot PP
input enabledisableChoiceToggle showStandardPivotS1=Enable;//Standard Pivot S1
input enabledisableChoiceToggle showStandardPivotS2=Enable;//Standard Pivot S2
input enabledisableChoiceToggle showStandardPivotS3=Enable;//Standard Pivot S3
input enabledisableChoiceToggle showStandardPivotS4=Enable;//Standard Pivot S4
input string StandardMidPivotHeader="-----------------Standard(Floor) Mid Pivot Points";//----- Standard(Floor) Mid PP
input enabledisableChoiceToggle showStandardPivotMR4=Enable;//Standard Pivot MR4
input enabledisableChoiceToggle showStandardPivotMR3=Enable;//Standard Pivot MR3
input enabledisableChoiceToggle showStandardPivotMR2=Enable;//Standard Pivot MR2
input enabledisableChoiceToggle showStandardPivotMR1=Enable;//Standard Pivot MR1
input enabledisableChoiceToggle showStandardPivotMS1=Enable;//Standard Pivot MS1
input enabledisableChoiceToggle showStandardPivotMS2=Enable;//Standard Pivot MS2
input enabledisableChoiceToggle showStandardPivotMS3=Enable;//Standard Pivot MS3
input enabledisableChoiceToggle showStandardPivotMS4=Enable;//Standard Pivot MS4
input string showCPRPivotHeader="Standard(Floor) CPR Pivot Point--------------------------------------------";//----- Standard(Floor) CPR Pivot Point
input enabledisableChoiceToggle showCPRTC=Enable;//Standard CPR Pivot TC
input enabledisableChoiceToggle showCPRBC=Enable;//Standard CPR Pivot BC
input string showFibonacciPivotHeader="Fibonacci Pivot Point--------------------------------------------";//----- Fibonacci Pivot Point Settings
input enabledisableChoiceToggle showFibonacciPivotR200=Enable;//Fibonacci Pivot R200
input enabledisableChoiceToggle showFibonacciPivotR161=Enable;//Fibonacci Pivot R161
input enabledisableChoiceToggle showFibonacciPivotR138=Enable;//Fibonacci Pivot R138
input enabledisableChoiceToggle showFibonacciPivotR100=Enable;//Fibonacci Pivot R100
input enabledisableChoiceToggle showFibonacciPivotR78=Enable;//Fibonacci Pivot R78
input enabledisableChoiceToggle showFibonacciPivotR61=Enable;//Fibonacci Pivot R61
input enabledisableChoiceToggle showFibonacciPivotR38=Enable;//Fibonacci Pivot R38
input enabledisableChoiceToggle showFibonacciPivotPP=Enable;//Fibonacci Pivot PP
input enabledisableChoiceToggle showFibonacciPivotS38=Enable;//Fibonacci Pivot S38
input enabledisableChoiceToggle showFibonacciPivotS61=Enable;//Fibonacci Pivot S61
input enabledisableChoiceToggle showFibonacciPivotS78=Enable;//Fibonacci Pivot S78
input enabledisableChoiceToggle showFibonacciPivotS100=Enable;//Fibonacci Pivot S100
input enabledisableChoiceToggle showFibonacciPivotS138=Enable;//Fibonacci Pivot S138
input enabledisableChoiceToggle showFibonacciPivotS161=Enable;//Fibonacci Pivot S161
input enabledisableChoiceToggle showFibonacciPivotS200=Enable;//Fibonacci Pivot S200
input string showWoodiePivotHeader="Woodie Pivot Point--------------------------------------------";//----- Woodie Pivot Point Settings
input enabledisableChoiceToggle showWoodieR4=Enable;//Woodie Pivot R4
input enabledisableChoiceToggle showWoodieR3=Enable;//Woodie Pivot R3
input enabledisableChoiceToggle showWoodieR2=Enable;//Woodie Pivot R2
input enabledisableChoiceToggle showWoodieR1=Enable;//Woodie Pivot R1
input enabledisableChoiceToggle showWoodiePP=Enable;//Woodie Pivot PP
input enabledisableChoiceToggle showWoodieS1=Enable;//Woodie Pivot S1
input enabledisableChoiceToggle showWoodieS2=Enable;//Woodie Pivot S2
input enabledisableChoiceToggle showWoodieS3=Enable;//Woodie Pivot S3
input enabledisableChoiceToggle showWoodieS4=Enable;//Woodie Pivot S4
input string showCamarillaPivotHeader="Camarilla Pivot Point--------------------------------------------";//----- Camarilla Pivot Point Settings
input enabledisableChoiceToggle showCamarillaH5=Enable;//Camarilla Pivot H5
input enabledisableChoiceToggle showCamarillaH4=Enable;//Camarilla Pivot H4
input enabledisableChoiceToggle showCamarillaH3=Enable;//Camarilla Pivot H3
input enabledisableChoiceToggle showCamarillaH2=Enable;//Camarilla Pivot H2
input enabledisableChoiceToggle showCamarillaH1=Enable;//Camarilla Pivot H1
input enabledisableChoiceToggle showCamarillaPP=Disable;//Camarilla Pivot PP
input enabledisableChoiceToggle showCamarillaL1=Enable;//Camarilla Pivot L1
input enabledisableChoiceToggle showCamarillaL2=Enable;//Camarilla Pivot L2
input enabledisableChoiceToggle showCamarillaL3=Enable;//Camarilla Pivot L3
input enabledisableChoiceToggle showCamarillaL4=Enable;//Camarilla Pivot L4
input enabledisableChoiceToggle showCamarillaL5=Enable;//Camarilla Pivot L5
input string showTraditionalPivotHeader="Traditional Pivot Point--------------------------------------------";//----- Traditional Pivot Point Settings
input enabledisableChoiceToggle showTraditionalR5=Enable;//Traditional Pivot R5
input enabledisableChoiceToggle showTraditionalR4=Enable;//Traditional Pivot R4
input enabledisableChoiceToggle showTraditionalR3=Enable;//Traditional Pivot R3
input enabledisableChoiceToggle showTraditionalR2=Enable;//Traditional Pivot R2
input enabledisableChoiceToggle showTraditionalR1=Enable;//Traditional Pivot R1
input enabledisableChoiceToggle showTraditionalPP=Enable;//Traditional Pivot PP
input enabledisableChoiceToggle showTraditionalS1=Enable;//Traditional Pivot S1
input enabledisableChoiceToggle showTraditionalS2=Enable;//Traditional Pivot S2
input enabledisableChoiceToggle showTraditionalS3=Enable;//Traditional Pivot S3
input enabledisableChoiceToggle showTraditionalS4=Enable;//Traditional Pivot S4
input enabledisableChoiceToggle showTraditionalS5=Enable;//Traditional Pivot S5
input string showDemarkPivotHeader="Demark Pivot Point--------------------------------------------";//----- Demark Pivot Point Settings
input enabledisableChoiceToggle showDemarkR1=Enable;//Demark Pivot R1
input enabledisableChoiceToggle showDemarkPP=Enable;//Demark Pivot PP
input enabledisableChoiceToggle showDemarkS1=Enable;//Demark Pivot S1
input string showClassicPivotHeader="Classic Pivot Point--------------------------------------------";//----- Classic Pivot Point Settings
input enabledisableChoiceToggle showClassicR4=Enable;//Classic Pivot R4
input enabledisableChoiceToggle showClassicR3=Enable;//Classic Pivot R3
input enabledisableChoiceToggle showClassicR2=Enable;//Classic Pivot R2
input enabledisableChoiceToggle showClassicR1=Enable;//Classic Pivot R1
input enabledisableChoiceToggle showClassicPP=Enable;//Classic Pivot PP
input enabledisableChoiceToggle showClassicS1=Enable;//Classic Pivot S1
input enabledisableChoiceToggle showClassicS2=Enable;//Classic Pivot S2
input enabledisableChoiceToggle showClassicS3=Enable;//Classic Pivot S3
input enabledisableChoiceToggle showClassicS4=Enable;//Classic Pivot S4
//+------------------------------------------------------------------+
int OnInit()
  {
   EnableDisablePivotPoint();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void  OnDeinit(const int  reason)
  {
   if(reason==1 || reason==2 || reason==3 || reason==4 || reason==5 || reason==7 || reason==9)
     {
      ObjectsDeleteAll(0,"PPL"+(string)UniqueID,0,OBJ_TREND) ;
      ObjectsDeleteAll(0,"PPL"+(string)UniqueID,0,OBJ_TEXT) ;
     }
   /*
   REASON_PROGRAM
   0
   Expert Advisor terminated its operation by calling the ExpertRemove() function

   REASON_REMOVE
   1
   Program has been deleted from the chart

   REASON_RECOMPILE
   2
   Program has been recompiled

   REASON_CHARTCHANGE
   3
   Symbol or chart period has been changed

   REASON_CHARTCLOSE
   4
   Chart has been closed

   REASON_PARAMETERS
   5
   Input parameters have been changed by a user

   REASON_ACCOUNT
   6
   Another account has been activated or reconnection to the trade server has occurred due to changes in the account settings

   REASON_TEMPLATE
   7
   A new template has been applied

   REASON_INITFAILED
   8
   This value means that OnInit() handler has returned a nonzero value

   REASON_CLOSE
   9
   Terminal has been closed
   */
  }
//+------------------------------------------------------------------+
int start()
  {
   if(pivotSelection==Camarilla)
     {
      camarillaPivotPoint(camarillaValueArray,0,false);
      for(int i=0; i<ArraySize(camarillaValueArray); i++)
        {
         if(showCamarilla[i])
           {
            DrawPivotLines(camarillaValueArray[i],camarillaPivotNames[i]);
           }
        }
      int numHistoricalPP=historicalPP;
      if(numHistoricalPP>0)
        {
         for(int j=1; j<=numHistoricalPP; j++)
           {
            if(timeFrame==PERIOD_D1)
              {
               if(foundWeekend(j))
                 {
                  numHistoricalPP++;
                  continue;
                 }
              }
            camarillaPivotPoint(camarillaValueArray,j,false);
            for(int k=0; k<ArraySize(camarillaValueArray); k++)
              {
               if(showCamarilla[k])
                 {
                  DrawHistoricalLines(camarillaValueArray[k],camarillaPivotNames[k],j);
                 }
              }
           }
        }
      if(drawFuturePlot==Yes)
        {
         camarillaPivotPoint(camarillaValueArray,0,true);
         for(int k=0; k<ArraySize(camarillaValueArray); k++)
           {
            if(showCamarilla[k])
              {
               DrawFuturePlot(camarillaValueArray[k],camarillaPivotNames[k]);
              }
           }
        }
     }
//+------------------------------------------------------------------+
   if(pivotSelection==Standard)
     {
      if(drawFloorMidPP==Yes)
        {
         standardPivotPoint(standardValueArray,0,false);
         for(int i=0; i<17; i++)
           {
            if(showStandard[i])
              {
               DrawPivotLines(standardValueArray[i],standardPivotNames[i]);
              }
           }
         if(floorCPR==Yes)//current
           {
            standardPivotPointCPR(floorCPRValueArray,0,false);
            for(int k=0; k<ArraySize(floorCPRValueArray); k++)
              {
               if(showFloorCPR[k])
                 {
                  DrawCPRPivotLines(floorCPRValueArray[k],floorCPRPivotNames[k]);
                 }
              }
           }
         int numHistoricalPP=historicalPP;
         if(numHistoricalPP>0)
           {
            for(int j=1; j<=numHistoricalPP; j++)
              {
               if(timeFrame==PERIOD_D1)
                 {
                  if(foundWeekend(j))
                    {
                     numHistoricalPP++;
                     continue;
                    }
                 }
               standardPivotPoint(standardValueArray,j,false);
               for(int k=0; k<17; k++)
                 {
                  if(showStandard[k])
                    {
                     DrawHistoricalLines(standardValueArray[k],standardPivotNames[k],j);
                    }
                 }
               if(floorCPR==Yes)//historical
                 {
                  standardPivotPointCPR(floorCPRValueArray,j,false);
                  for(int k=0; k<ArraySize(floorCPRValueArray); k++)
                    {
                     if(showFloorCPR[k])
                       {
                        DrawCPRHistoricalLines(floorCPRValueArray[k],floorCPRPivotNames[k],j);
                       }
                    }
                 }
              }
           }
         if(drawFuturePlot==Yes)
           {
            standardPivotPoint(standardValueArray,0,true);
            for(int k=0; k<17; k++)
              {
               if(showStandard[k])
                 {
                  DrawFuturePlot(standardValueArray[k],standardPivotNames[k]);
                 }
              }
            if(floorCPR==Yes)
              {
               standardPivotPointCPR(floorCPRValueArray,0,true);
               for(int k=0; k<ArraySize(floorCPRValueArray); k++)
                 {
                  if(showFloorCPR[k])
                    {
                     DrawCPRFuturePlot(floorCPRValueArray[k],floorCPRPivotNames[k]);
                    }
                 }
              }
           }
        }
      else
        {
         standardPivotPoint(standardValueArray,0,false);
         for(int i=0; i<9; i++)
           {
            if(showStandard[i])
              {
               DrawPivotLines(standardValueArray[i],standardPivotNames[i]);
              }
            if(floorCPR==Yes)//current
              {
               standardPivotPointCPR(floorCPRValueArray,0,false);
               for(int k=0; k<ArraySize(floorCPRValueArray); k++)
                 {
                  if(showFloorCPR[k])
                    {
                     DrawCPRPivotLines(floorCPRValueArray[k],floorCPRPivotNames[k]);
                    }
                 }
              }
           }
         int numHistoricalPP=historicalPP;
         if(numHistoricalPP>0)
           {
            for(int j=1; j<=numHistoricalPP; j++)
              {
               if(timeFrame==PERIOD_D1)
                 {
                  if(foundWeekend(j))
                    {
                     numHistoricalPP++;
                     continue;
                    }
                 }
               standardPivotPoint(standardValueArray,j,false);
               for(int k=0; k<9; k++)
                 {
                  if(showStandard[k])
                    {
                     DrawHistoricalLines(standardValueArray[k],standardPivotNames[k],j);
                    }
                 }
               if(floorCPR==Yes)//historical
                 {
                  standardPivotPointCPR(floorCPRValueArray,j,false);
                  for(int k=0; k<ArraySize(floorCPRValueArray); k++)
                    {
                     if(showFloorCPR[k])
                       {
                        DrawCPRHistoricalLines(floorCPRValueArray[k],floorCPRPivotNames[k],j);
                       }
                    }
                 }
              }
           }
         if(drawFuturePlot==Yes)
           {
            standardPivotPoint(standardValueArray,0,true);
            for(int k=0; k<9; k++)
              {
               if(showStandard[k])
                 {
                  DrawFuturePlot(standardValueArray[k],standardPivotNames[k]);
                 }
              }
            if(floorCPR==Yes)//future
              {
               standardPivotPointCPR(floorCPRValueArray,0,true);
               for(int k=0; k<ArraySize(floorCPRValueArray); k++)
                 {
                  if(showFloorCPR[k])
                    {
                     DrawCPRFuturePlot(floorCPRValueArray[k],floorCPRPivotNames[k]);
                    }
                 }
              }
           }
        }
     }
//+------------------------------------------------------------------+
   if(pivotSelection==Fibonacci)
     {
      fibonacciPivotPoint(fibonacciValueArray,0,false);
      for(int i=0; i<ArraySize(fibonacciValueArray); i++)
        {
         if(showFibonacci[i])
           {
            DrawPivotLines(fibonacciValueArray[i],fibonacciPivotNames[i]);
           }
        }
      int numHistoricalPP=historicalPP;
      if(numHistoricalPP>0)
        {
         for(int j=1; j<=numHistoricalPP; j++)
           {
            if(timeFrame==PERIOD_D1)
              {
               if(foundWeekend(j))
                 {
                  numHistoricalPP++;
                  continue;
                 }
              }
            fibonacciPivotPoint(fibonacciValueArray,j,false);
            for(int k=0; k<ArraySize(fibonacciValueArray); k++)
              {
               if(showFibonacci[k])
                 {
                  DrawHistoricalLines(fibonacciValueArray[k],fibonacciPivotNames[k],j);
                 }
              }
           }
        }
      if(drawFuturePlot==Yes)
        {
         fibonacciPivotPoint(fibonacciValueArray,0,true);
         for(int k=0; k<ArraySize(fibonacciValueArray); k++)
           {
            if(showFibonacci[k])
              {
               DrawFuturePlot(fibonacciValueArray[k],fibonacciPivotNames[k]);
              }
           }
        }
     }
//+------------------------------------------------------------------+
   if(pivotSelection==Woodie)
     {
      woodiePivotPoint(woodieValueArray,0,false);
      for(int i=0; i<ArraySize(woodieValueArray); i++)
        {
         if(showWoodie[i])
           {
            DrawPivotLines(woodieValueArray[i],woodiePivotNames[i]);
           }
        }
      int numHistoricalPP=historicalPP;
      if(numHistoricalPP>0)
        {
         for(int j=1; j<=numHistoricalPP; j++)
           {
            if(timeFrame==PERIOD_D1)
              {
               if(foundWeekend(j))
                 {
                  numHistoricalPP++;
                  continue;
                 }
              }
            woodiePivotPoint(woodieValueArray,j,false);
            for(int k=0; k<ArraySize(woodieValueArray); k++)
              {
               if(showWoodie[k])
                 {
                  DrawHistoricalLines(woodieValueArray[k],woodiePivotNames[k],j);
                 }
              }
           }
        }
      if(drawFuturePlot==Yes)
        {
         woodiePivotPoint(woodieValueArray,0,true);
         for(int k=0; k<ArraySize(woodieValueArray); k++)
           {
            if(showWoodie[k])
              {
               DrawFuturePlot(woodieValueArray[k],woodiePivotNames[k]);
              }
           }
        }
     }
//+------------------------------------------------------------------+
   if(pivotSelection==Traditional)
     {
      traditionalPivotPoint(traditionalValueArray,0,false);
      for(int i=0; i<ArraySize(traditionalValueArray); i++)
        {
         if(showTraditional[i])
           {
            DrawPivotLines(traditionalValueArray[i],traditionalPivotNames[i]);
           }
        }
      int numHistoricalPP=historicalPP;
      if(numHistoricalPP>0)
        {
         for(int j=1; j<=numHistoricalPP; j++)
           {
            if(timeFrame==PERIOD_D1)
              {
               if(foundWeekend(j))
                 {
                  numHistoricalPP++;
                  continue;
                 }
              }
            traditionalPivotPoint(traditionalValueArray,j,false);
            for(int k=0; k<ArraySize(traditionalValueArray); k++)
              {
               if(showTraditional[k])
                 {
                  DrawHistoricalLines(traditionalValueArray[k],traditionalPivotNames[k],j);
                 }
              }
           }
        }
      if(drawFuturePlot==Yes)
        {
         traditionalPivotPoint(traditionalValueArray,0,true);
         for(int k=0; k<ArraySize(traditionalValueArray); k++)
           {
            if(showTraditional[k])
              {
               DrawFuturePlot(traditionalValueArray[k],traditionalPivotNames[k]);
              }
           }
        }
     }
//+------------------------------------------------------------------+
   if(pivotSelection==Demark)
     {
      demarkPivotPoint(demarkValueArray,0,false);
      for(int i=0; i<ArraySize(demarkValueArray); i++)
        {
         if(showDemark[i])
           {
            DrawPivotLines(demarkValueArray[i],demarkPivotNames[i]);
           }
        }
      int numHistoricalPP=historicalPP;
      if(numHistoricalPP>0)
        {
         for(int j=1; j<=numHistoricalPP; j++)
           {
            if(timeFrame==PERIOD_D1)
              {
               if(foundWeekend(j))
                 {
                  numHistoricalPP++;
                  continue;
                 }
              }
            demarkPivotPoint(demarkValueArray,j,false);
            for(int k=0; k<ArraySize(demarkValueArray); k++)
              {
               if(showDemark[k])
                 {
                  DrawHistoricalLines(demarkValueArray[k],demarkPivotNames[k],j);
                 }
              }
           }
        }
      if(drawFuturePlot==Yes)
        {
         demarkPivotPoint(demarkValueArray,0,true);
         for(int k=0; k<ArraySize(demarkValueArray); k++)
           {
            if(showDemark[k])
              {
               DrawFuturePlot(demarkValueArray[k],demarkPivotNames[k]);
              }
           }
        }
     }
//+------------------------------------------------------------------+
   if(pivotSelection==Classic)
     {
      classicPivotPoint(classicValueArray,0,false);
      for(int i=0; i<ArraySize(classicValueArray); i++)
        {
         if(showClassic[i])
           {
            DrawPivotLines(classicValueArray[i],classicPivotNames[i]);
           }
        }
      int numHistoricalPP=historicalPP;
      if(numHistoricalPP>0)
        {
         for(int j=1; j<=numHistoricalPP; j++)
           {
            if(timeFrame==PERIOD_D1)
              {
               if(foundWeekend(j))
                 {
                  numHistoricalPP++;
                  continue;
                 }
              }
            classicPivotPoint(classicValueArray,j,false);
            for(int k=0; k<ArraySize(classicValueArray); k++)
              {
               if(showClassic[k])
                 {
                  DrawHistoricalLines(classicValueArray[k],classicPivotNames[k],j);
                 }
              }
           }
        }
      if(drawFuturePlot==Yes)
        {
         classicPivotPoint(classicValueArray,0,true);
         for(int k=0; k<ArraySize(classicValueArray); k++)
           {
            if(showClassic[k])
              {
               DrawFuturePlot(classicValueArray[k],classicPivotNames[k]);
              }
           }
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
void DrawPivotLines(double value,string pivotName)
  {
   color lineLabelColor=clrNONE;
   string message="";
   if(showPriceLabel==Yes)
     {
      message=customMSG+pivotName+": "+DoubleToString(value,Digits);
     }
   else
     {
      message=customMSG+pivotName;
     }
   if('R'==StringGetChar(pivotName,0))
     {
      lineLabelColor=resistantColor;
     }
   if('P'==StringGetChar(pivotName,0))
     {
      lineLabelColor=pivotColor;
     }
   if('S'==StringGetChar(pivotName,0))
     {
      lineLabelColor=supportColor;
     }
   if('M'==StringGetChar(pivotName,0))
     {
      lineLabelColor=midColor;
     }
   if('H'==StringGetChar(pivotName,0))
     {
      lineLabelColor=resistantColor;
     }
   if('L'==StringGetChar(pivotName,0))
     {
      lineLabelColor=supportColor;
     }
   string nameLine=  indiName+pivotName+" Line";
   string nameLabel= indiName+pivotName+" Label";
   if(ObjectFind(nameLine) != 0)
     {
      if(useShortLines==Yes)
        {
         ObjectCreate(nameLine, OBJ_TREND, 0, Time[1]+Period()*60, value, Time[0]+Period()*60*Line_Length, value);
        }
      else
        {
         ObjectCreate(nameLine,OBJ_TREND,0,iTime(NULL,timeFrame,0),value,iTime(NULL,timeFrame,0)+timeFrame*60,value);
        }
      ObjectSet(nameLine,OBJPROP_RAY,false);
      ObjectSet(nameLine,OBJPROP_COLOR,lineLabelColor);
      ObjectSet(nameLine,OBJPROP_STYLE,lineStyle);
      ObjectSet(nameLine,OBJPROP_WIDTH,lineWidth);
      ObjectSet(nameLine,OBJPROP_BACK,true);
      ObjectSet(nameLine,OBJPROP_SELECTED,false);
      ObjectSet(nameLine,OBJPROP_SELECTABLE,false);
      ChartRedraw(0);
     }
   else
     {
      if(useShortLines==Yes)
        {
         ObjectMove(nameLine, 0, Time[1]+Period()*60, value);
         ObjectMove(nameLine, 1, Time[0]+Period()*60*Line_Length, value);
        }
      else
        {
         ObjectMove(nameLine,0,iTime(NULL,timeFrame,0),value);
         ObjectMove(nameLine,1,iTime(NULL,timeFrame,0)+timeFrame*60,value);
        }
     }
   if(hideCurrentLabels==No)
     {
      if(ObjectFind(nameLabel) != 0)
        {
         if(useShortLines==Yes)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,Time[0]+Period()*60*ShiftLabel,value);
            if(useSameColorLabelChoice==Yes)
              {
               ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
              }
            else
              {
               ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
              }
            ObjectSet(nameLabel,OBJPROP_BACK,true);
            ObjectSet(nameLabel,OBJPROP_SELECTED,false);
            ObjectSet(nameLabel,OBJPROP_SELECTABLE,false);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
           }
         else
           {
            if(currentLabelLocation==Follow_Price_2)
              {
               ObjectCreate(nameLabel,OBJ_TEXT,0,Time[0]+Period()*60*ShiftLabel,value);
               ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
              }
            if(currentLabelLocation==Left_2)
              {
               ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0),value);
               ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
              }
            if(currentLabelLocation==Middle_2)
              {
               ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*30,value);
               ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_UPPER);
              }
            if(currentLabelLocation==Right_2)
              {
               ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
               ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
              }
            if(useSameColorLabelChoice==Yes)
              {
               ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
              }
            else
              {
               ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
              }
            ObjectSet(nameLabel,OBJPROP_BACK,true);
            ObjectSet(nameLabel,OBJPROP_SELECTED,false);
            ObjectSet(nameLabel,OBJPROP_SELECTABLE,false);
           }
         ChartRedraw(0);
        }
      else
        {
         if(currentLabelLocation==Follow_Price_2)
           {
            ObjectMove(nameLabel,0,Time[0]+Period()*60*ShiftLabel,value);
           }
         if(currentLabelLocation==Left_2)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0),value);
           }
         if(currentLabelLocation==Middle_2)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*30,value);
           }
         if(currentLabelLocation==Right_2)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
           }
        }
     }
  }
//camarilla formula
void camarillaPivotPoint(double &ppArrayRef[],int timeframeShift,bool futurePlot)//camrilla pivot point formula
  {
   int shift=0;
   if(futurePlot)
     {
      shift=0;
     }
   else
     {
      shift=1+timeframeShift;
     }
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck1) == 0)//found sunday
        {
         shift+=1;
        }
      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck2) == 6)//found saturday
        {
         shift+=1;
        }
     }
   double camRange= iHigh(NULL,timeFrame,shift)-iLow(NULL,timeFrame,shift);
   double prevHigh=iHigh(NULL,timeFrame,shift);
   double prevLow=iLow(NULL,timeFrame,shift);
   double prevClose=iClose(NULL,timeFrame,shift);
   if(futurePlot)
     {
      RefreshRates();
      prevClose= Bid;
     }
   double H5=((prevHigh/prevLow)*prevClose);
   double H4=prevClose+camRange*1.1/2;
   double H3=((1.1/4) * camRange) + prevClose;
   double H2=prevClose+camRange*1.1/6;
   double H1=prevClose+camRange*1.1/12;
   double L1=prevClose-camRange*1.1/12;
   double L2=prevClose-camRange*1.1/6;
   double L3=prevClose-camRange*1.1/4;
   double L4=prevClose-camRange*1.1/2;
   double L5=prevClose-(H5-prevClose);
   double PP = (prevHigh+prevLow+prevClose)/3;
   ppArrayRef[0]=PP;
   ppArrayRef[1]=L1;
   ppArrayRef[2]=L2;
   ppArrayRef[3]=L3;
   ppArrayRef[4]=L4;
   ppArrayRef[5]=H1;
   ppArrayRef[6]=H2;
   ppArrayRef[7]=H3;
   ppArrayRef[8]=H4;
   ppArrayRef[9]=H5;
   ppArrayRef[10]=L5;
  }
//+------------------------------------------------------------------+
//standard pivot point formula
void standardPivotPoint(double &ppArrayRef[],int timeframeShift,bool futurePlot)//the formula for the standard floor pivot points
  {
   int shift=0;
   if(futurePlot)
     {
      shift=0;
     }
   else
     {
      shift=1+timeframeShift;
     }
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck1) == 0)//found sunday - skip over
        {
         shift+=1;
        }
      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck2) == 6)//found saturday - skip over
        {
         shift+=1;
        }
     }
   double prevHigh = iHigh(NULL,timeFrame,shift);
   double prevLow=iLow(NULL,timeFrame,shift);
   double prevClose=iClose(NULL,timeFrame,shift);
   if(futurePlot)
     {
      RefreshRates();
      prevClose= Bid;
     }
   double PP = (prevHigh+prevLow+prevClose)/3;
   double R1 = (PP * 2)-prevLow;
   double S1 = (PP * 2)-prevHigh;
   double R2 = PP + prevHigh - prevLow;
   double S2 = PP - prevHigh + prevLow;
   double R3 = R1 + (prevHigh-prevLow);
   double S3 = prevLow - 2 * (prevHigh-PP);
   double R4 = R3+(R2-R1);
   double S4 = S3-(S1-S2);
   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=S3;
   ppArrayRef[4]=R1;
   ppArrayRef[5]=R2;
   ppArrayRef[6]=R3;
   ppArrayRef[7]=R4;
   ppArrayRef[8]=S4;
   if(drawFloorMidPP==Yes)
     {
      //mid pivots
      ppArrayRef[9]=(R3+R4)/2;
      ppArrayRef[10]=(R2+R3)/2;
      ppArrayRef[11]=(R1+R2)/2;
      ppArrayRef[12]=(PP+R1)/2;
      ppArrayRef[13]=(PP+S1)/2;
      ppArrayRef[14]=(S1+S2)/2;
      ppArrayRef[15]=(S2+S3)/2;
      ppArrayRef[16]=(S3+S4)/2;
     }
  }
//+------------------------------------------------------------------+
void woodiePivotPoint(double &ppArrayRef[],int timeframeShift,bool futurePlot)//woodie pivot point formula
  {
   int shift=0;
   if(futurePlot)
     {
      shift=0;
     }
   else
     {
      shift=1+timeframeShift;
     }
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck1) == 0)//found sunday
        {
         shift+=1;
        }
      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck2) == 6)//found saturday
        {
         shift+=1;
        }
     }
   double prevRange= iHigh(NULL,timeFrame,shift)-iLow(NULL,timeFrame,shift);
   double prevHigh = iHigh(NULL,timeFrame,shift);
   double prevLow=iLow(NULL,timeFrame,shift);
   double prevClose = iClose(NULL, timeFrame,shift);
   if(futurePlot)
     {
      RefreshRates();
      prevClose= Bid;
     }
   double todayOpen = iOpen(NULL, timeFrame,shift-1);
   double PP = (prevHigh+prevLow+(todayOpen*2))/4;
   double R1 = (PP * 2)-prevLow;
   double R2 = PP + prevRange;
   double S1 = (PP * 2)-prevHigh;
   double S2 = PP - prevRange;
   double S3 = (prevLow-2*(prevHigh-PP));
   double S4 = (S3-prevRange);
   double R3 = (prevHigh+2*(PP-prevLow));
   double R4 = (R3+prevRange);
   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=R1;
   ppArrayRef[4]=R2;
   ppArrayRef[5]=S3;
   ppArrayRef[6]=S4;
   ppArrayRef[7]=R3;
   ppArrayRef[8]=R4;
  }
//fibonacci formula
void fibonacciPivotPoint(double &ppArrayRef[],int timeframeShift,bool futurePlot)//fibonacchi pivot point formula
  {
   int shift=0;
   if(futurePlot)
     {
      shift=0;
     }
   else
     {
      shift=1+timeframeShift;
     }
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck1) == 0)//found sunday
        {
         shift+=1;
        }
      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck2) == 6)//found saturday
        {
         shift+=1;
        }
     }
   double prevRange= iHigh(NULL,timeFrame,shift)-iLow(NULL,timeFrame,shift);
   double prevHigh = iHigh(NULL,timeFrame,shift);
   double prevLow=iLow(NULL,timeFrame,shift);
   double prevClose=iClose(NULL,timeFrame,shift);
   if(futurePlot)
     {
      RefreshRates();
      prevClose= Bid;
     }
   double Pivot=(prevHigh+prevLow+prevClose)/3;
   double R38=  Pivot + ((prevRange) * 0.382);
   double R61=  Pivot + ((prevRange) * 0.618);
   double R78=  Pivot + ((prevRange) * 0.786);
   double R100= Pivot + ((prevRange) * 1.000);
   double R138= Pivot + ((prevRange) * 1.382);
   double R161= Pivot + ((prevRange) * 1.618);
   double R200= Pivot + ((prevRange) * 2.000);
   double S38 = Pivot - ((prevRange) * 0.382);
   double S61 = Pivot - ((prevRange) * 0.618);
   double S78 = Pivot -((prevRange)  * 0.786);
   double S100= Pivot - ((prevRange) * 1.000);
   double S138= Pivot - ((prevRange) * 1.382);
   double S161= Pivot - ((prevRange) * 1.618);
   double S200= Pivot - ((prevRange) * 2.000);
   ppArrayRef[0]=Pivot;
   ppArrayRef[1]=R38;
   ppArrayRef[2]=R61;
   ppArrayRef[3]=R78;
   ppArrayRef[4]=R100;
   ppArrayRef[5]=R138;
   ppArrayRef[6]=R161;
   ppArrayRef[7]=R200;
   ppArrayRef[8]=S38;
   ppArrayRef[9]=S61;
   ppArrayRef[10]=S78;
   ppArrayRef[11]=S100;
   ppArrayRef[12]=S138;
   ppArrayRef[13]=S161;
   ppArrayRef[14]=S200;
  }
//+------------------------------------------------------------------+
//traditional pivot point formula
void traditionalPivotPoint(double &ppArrayRef[],int timeframeShift,bool futurePlot)//the formula for the traditional floor pivot points
  {
   int shift=0;
   if(futurePlot)
     {
      shift=0;
     }
   else
     {
      shift=1+timeframeShift;
     }

   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck1) == 0)//found sunday - skip over
        {
         shift+=1;
        }
      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck2) == 6)//found saturday - skip over
        {
         shift+=1;
        }
     }
   double prevHigh = iHigh(NULL,timeFrame,shift);
   double prevLow=iLow(NULL,timeFrame,shift);
   double prevClose=iClose(NULL,timeFrame,shift);
   if(futurePlot)
     {
      RefreshRates();
      prevClose= Bid;
     }
   double PP = (prevHigh+prevLow+prevClose)/3;
   double R1 = PP * 2 - prevLow;
   double S1 = PP * 2 - prevHigh;
   double R2 = PP + prevHigh - prevLow;
   double S2 = PP - prevHigh + prevLow;
   double R3 = PP * 2 + (prevHigh - 2 * prevLow);
   double S3 = PP * 2 - (2 * prevHigh - prevLow);
   double R4 = PP * 3 + (prevHigh - 3 * prevLow);
   double S4 = PP * 3 - (3 * prevHigh - prevLow);
   double R5 = PP * 4 + (prevHigh - 4 * prevLow);
   double S5 = PP * 4 - (4 * prevHigh - prevLow) ;
   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=S3;
   ppArrayRef[4]=R1;
   ppArrayRef[5]=R2;
   ppArrayRef[6]=R3;
   ppArrayRef[7]=R4;
   ppArrayRef[8]=S4;
   ppArrayRef[9]=S5;
   ppArrayRef[10]=R5;
  }
//+------------------------------------------------------------------+
void demarkPivotPoint(double &ppArrayRef[],int timeframeShift,bool futurePlot)//demark pivot point formula
  {
   int shift=0;
   if(futurePlot)
     {
      shift=0;
     }
   else
     {
      shift=1+timeframeShift;
     }
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck1) == 0)//found sunday
        {
         shift+=1;
        }
      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck2) == 6)//found saturday
        {
         shift+=1;
        }
     }
   double prevHigh =    iHigh(NULL,timeFrame,shift);
   double prevLow=      iLow(NULL,timeFrame,shift);
   double prevClose =   iClose(NULL, timeFrame,shift);
   if(futurePlot)
     {
      RefreshRates();
      prevClose= Bid;
     }
   double prevOpen =    iOpen(NULL, timeFrame,shift);
   double X=1;
   if(prevOpen==prevClose)
     {
      X=(prevHigh+prevLow+(2*prevClose));
     }
   if(prevClose>prevOpen)
     {
      X=((2*prevHigh)+prevLow+prevClose);
     }
   if(prevClose<prevOpen)
     {
      X=(prevHigh+(prevLow*2)+prevClose);
     }
   double PP =X/4;
   double R1 =X/2-prevLow;
   double S1 =X/2-prevHigh;
   ppArrayRef[0]=PP;
   ppArrayRef[1]=R1;
   ppArrayRef[2]=S1;
  }
//+------------------------------------------------------------------+
void classicPivotPoint(double &ppArrayRef[],int timeframeShift,bool futurePlot)//classic pivot point formula
  {
   int shift=0;
   if(futurePlot)
     {
      shift=0;
     }
   else
     {
      shift=1+timeframeShift;
     }
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck1) == 0)//found sunday
        {
         shift+=1;
        }
      datetime dayCheck2=iTime(NULL,PERIOD_D1,shift);
      if(TimeDayOfWeek(dayCheck2) == 6)//found saturday
        {
         shift+=1;
        }
     }
   double prevHigh =    iHigh(NULL,timeFrame,shift);
   double prevLow=      iLow(NULL,timeFrame,shift);
   double prevClose =   iClose(NULL, timeFrame,shift);
   if(futurePlot)
     {
      RefreshRates();
      prevClose= Bid;
     }
   double PP =(prevHigh+prevLow+prevClose)/3;
   double R1 =(2*PP)-prevLow;
   double S1 =(2*PP)-prevHigh;
   double R2=PP+(prevHigh-prevLow);
   double S2=PP-(prevHigh-prevLow);
   double R3=PP+2*(prevHigh-prevLow);
   double S3=PP-2*(prevHigh-prevLow);
   double R4=PP+3*(prevHigh-prevLow);
   double S4=PP-3*(prevHigh-prevLow);
   ppArrayRef[0]=PP;
   ppArrayRef[1]=S1;
   ppArrayRef[2]=S2;
   ppArrayRef[3]=S3;
   ppArrayRef[4]=S4;
   ppArrayRef[5]=R1;
   ppArrayRef[6]=R2;
   ppArrayRef[7]=R3;
   ppArrayRef[8]=R4;
  }
//+------------------------------------------------------------------+
void EnableDisablePivotPoint()//Enable/DisablePivotPoint
  {
//Standard(Floor)
   if(showStandardPivotPP==Disable)//Standard(Floor) PP
      showStandard[0]=false;
   else
      showStandard[0]=true;
   if(showStandardPivotS1==Disable)//Standard(Floor) S1
      showStandard[1]=false;
   else
      showStandard[1]=true;
   if(showStandardPivotS2==Disable)//Standard(Floor) S2
      showStandard[2]=false;
   else
      showStandard[2]=true;
   if(showStandardPivotS3==Disable)//Standard(Floor) S3
      showStandard[3]=false;
   else
      showStandard[3]=true;
   if(showStandardPivotR1==Disable)//Standard(Floor) R1
      showStandard[4]=false;
   else
      showStandard[4]=true;
   if(showStandardPivotR2==Disable)//Standard(Floor) R2
      showStandard[5]=false;
   else
      showStandard[5]=true;
   if(showStandardPivotR3==Disable)//Standard(Floor) R3
      showStandard[6]=false;
   else
      showStandard[6]=true;
   if(showStandardPivotR4==Disable)//Standard(Floor) R4
      showStandard[7]=false;
   else
      showStandard[7]=true;
   if(showStandardPivotS4==Disable)//Standard(Floor) S4
      showStandard[8]=false;
   else
      showStandard[8]=true;
   if(showStandardPivotMR4==Disable)//Standard(Floor) MR4
      showStandard[9]=false;
   else
      showStandard[9]=true;
   if(showStandardPivotMR3==Disable)//Standard(Floor) MR3
      showStandard[10]=false;
   else
      showStandard[10]=true;
   if(showStandardPivotMR2==Disable)//Standard(Floor) MR2
      showStandard[11]=false;
   else
      showStandard[11]=true;
   if(showStandardPivotMR1==Disable)//Standard(Floor) MR1
      showStandard[12]=false;
   else
      showStandard[12]=true;
   if(showStandardPivotMS1==Disable)//Standard(Floor) MS1
      showStandard[13]=false;
   else
      showStandard[13]=true;
   if(showStandardPivotMS2==Disable)//Standard(Floor) MS2
      showStandard[14]=false;
   else
      showStandard[14]=true;
   if(showStandardPivotMS3==Disable)//Standard(Floor) MS3
      showStandard[15]=false;
   else
      showStandard[15]=true;
   if(showStandardPivotMS4==Disable)//Standard(Floor) MS4
      showStandard[16]=false;
   else
      showStandard[16]=true;

//Camarilla
   if(showCamarillaPP==Disable) //Camarilla PP
      showCamarilla[0]=false;
   else
      showCamarilla[0]=true;
   if(showCamarillaL1==Disable)//Camarilla L1
      showCamarilla[1]=false;
   else
      showCamarilla[1]=true;
   if(showCamarillaL2==Disable)//Camarilla L2
      showCamarilla[2]=false;
   else
      showCamarilla[2]=true;
   if(showCamarillaL3==Disable)//Camarilla L3
      showCamarilla[3]=false;
   else
      showCamarilla[3]=true;
   if(showCamarillaL4==Disable)//Camarilla L4
      showCamarilla[4]=false;
   else
      showCamarilla[4]=true;
   if(showCamarillaH1==Disable)//Camarilla H1
      showCamarilla[5]=false;
   else
      showCamarilla[5]=true;
   if(showCamarillaH2==Disable)//Camarilla H2
      showCamarilla[6]=false;
   else
      showCamarilla[6]=true;
   if(showCamarillaH3==Disable)//Camarilla H3
      showCamarilla[7]=false;
   else
      showCamarilla[7]=true;
   if(showCamarillaH4==Disable)//Camarilla H4
      showCamarilla[8]=false;
   else
      showCamarilla[8]=true;
   if(showCamarillaH5==Disable)//Camarilla H5
      showCamarilla[9]=false;
   else
      showCamarilla[9]=true;
   if(showCamarillaL5==Disable)//Camarilla L5
      showCamarilla[10]=false;
   else
      showCamarilla[10]=true;

//Woodie
   if(showWoodiePP==Disable)//Woodie PP
      showWoodie[0]=false;
   else
      showWoodie[0]=true;
   if(showWoodieS1==Disable)//Woodie S1
      showWoodie[1]=false;
   else
      showWoodie[1]=true;
   if(showWoodieS2==Disable)//Woodie S2
      showWoodie[2]=false;
   else
      showWoodie[2]=true;
   if(showWoodieR1==Disable)//Woodie R1
      showWoodie[3]=false;
   else
      showWoodie[3]=true;
   if(showWoodieR2==Disable)//Woodie R2
      showWoodie[4]=false;
   else
      showWoodie[4]=true;
   if(showWoodieS3==Disable)//Woodie S3
      showWoodie[5]=false;
   else
      showWoodie[5]=true;
   if(showWoodieS4==Disable)//Woodie S4
      showWoodie[6]=false;
   else
      showWoodie[6]=true;
   if(showWoodieR3==Disable)//Woodie R3
      showWoodie[7]=false;
   else
      showWoodie[7]=true;
   if(showWoodieR4==Disable)//Woodie R4
      showWoodie[8]=false;
   else
      showWoodie[8]=true;

//Fibonacci
   if(showFibonacciPivotPP==Disable)//Fibonacci PP
      showFibonacci[0]=false;
   else
      showFibonacci[0]=true;
   if(showFibonacciPivotR38==Disable)//Fibonacci R38
      showFibonacci[1]=false;
   else
      showFibonacci[1]=true;
   if(showFibonacciPivotR61==Disable)//Fibonacci R61
      showFibonacci[2]=false;
   else
      showFibonacci[2]=true;
   if(showFibonacciPivotR78==Disable)//Fibonacci R78
      showFibonacci[3]=false;
   else
      showFibonacci[3]=true;
   if(showFibonacciPivotR100==Disable)//Fibonacci R100
      showFibonacci[4]=false;
   else
      showFibonacci[4]=true;
   if(showFibonacciPivotR138==Disable)//Fibonacci R138
      showFibonacci[5]=false;
   else
      showFibonacci[5]=true;
   if(showFibonacciPivotR161==Disable)//Fibonacci R161
      showFibonacci[6]=false;
   else
      showFibonacci[6]=true;
   if(showFibonacciPivotR200==Disable)//Fibonacci R200
      showFibonacci[7]=false;
   else
      showFibonacci[7]=true;
   if(showFibonacciPivotS38==Disable)//Fibonacci S38
      showFibonacci[8]=false;
   else
      showFibonacci[8]=true;
   if(showFibonacciPivotS61==Disable)//Fibonacci S61
      showFibonacci[9]=false;
   else
      showFibonacci[9]=true;
   if(showFibonacciPivotS78==Disable)//Fibonacci S78
      showFibonacci[10]=false;
   else
      showFibonacci[10]=true;
   if(showFibonacciPivotS100==Disable)//Fibonacci S100
      showFibonacci[11]=false;
   else
      showFibonacci[11]=true;
   if(showFibonacciPivotS138==Disable)//Fibonacci S138
      showFibonacci[12]=false;
   else
      showFibonacci[12]=true;
   if(showFibonacciPivotS161==Disable)//Fibonacci S161
      showFibonacci[13]=false;
   else
      showFibonacci[13]=true;
   if(showFibonacciPivotS200==Disable)//Fibonacci S200
      showFibonacci[14]=false;
   else
      showFibonacci[14]=true;

//Traditional
   if(showTraditionalPP==Disable)//Traditional PP
      showTraditional[0]=false;
   else
      showTraditional[0]=true;
   if(showTraditionalS1==Disable)//Traditional S1
      showTraditional[1]=false;
   else
      showTraditional[1]=true;
   if(showTraditionalS2==Disable)//Traditional S2
      showTraditional[2]=false;
   else
      showTraditional[2]=true;
   if(showTraditionalS3==Disable)//Traditional S3
      showTraditional[3]=false;
   else
      showTraditional[3]=true;
   if(showTraditionalR1==Disable)//Traditional R1
      showTraditional[4]=false;
   else
      showTraditional[4]=true;
   if(showTraditionalR2==Disable)//Traditional R2
      showTraditional[5]=false;
   else
      showTraditional[5]=true;
   if(showTraditionalR3==Disable)//Traditional R3
      showTraditional[6]=false;
   else
      showTraditional[6]=true;
   if(showTraditionalR4==Disable)//Traditional R4
      showTraditional[7]=false;
   else
      showTraditional[7]=true;
   if(showTraditionalS4==Disable)//Traditional S4
      showTraditional[8]=false;
   else
      showTraditional[8]=true;
   if(showTraditionalS5==Disable)//Traditional S5
      showTraditional[9]=false;
   else
      showTraditional[9]=true;
   if(showTraditionalR5==Disable)//Traditional R5
      showTraditional[10]=false;
   else
      showTraditional[10]=true;

//Demark
   if(showDemarkPP==Disable)//Demark PP
      showDemark[0]=false;
   else
      showDemark[0]=true;
   if(showDemarkR1==Disable)//Demark R1
      showDemark[1]=false;
   else
      showDemark[1]=true;
   if(showDemarkS1==Disable)//Demark S1
      showDemark[2]=false;
   else
      showDemark[2]=true;

//Classic
   if(showClassicPP==Disable)//Classic PP
      showClassic[0]=false;
   else
      showClassic[0]=true;
   if(showClassicS1==Disable)//Classic S1
      showClassic[1]=false;
   else
      showClassic[1]=true;
   if(showClassicS2==Disable)//Classic S2
      showClassic[2]=false;
   else
      showClassic[2]=true;
   if(showClassicS3==Disable)//Classic S3
      showClassic[3]=false;
   else
      showClassic[3]=true;
   if(showClassicS4==Disable)//Classic S4
      showClassic[4]=false;
   else
      showClassic[4]=true;
   if(showClassicR1==Disable)//Classic R1
      showClassic[5]=false;
   else
      showClassic[5]=true;
   if(showClassicR2==Disable)//Classic R2
      showClassic[6]=false;
   else
      showClassic[6]=true;
   if(showClassicR3==Disable)//Classic R3
      showClassic[7]=false;
   else
      showClassic[7]=true;
   if(showClassicR4==Disable)//Classic R4
      showClassic[8]=false;
   else
      showClassic[8]=true;

//CPR
   if(showCPRBC==Disable)//CPR BC
      showFloorCPR[0]=false;
   else
      showFloorCPR[0]=true;
   if(showCPRTC==Disable)//CPR TC
      showFloorCPR[1]=false;
   else
      showFloorCPR[1]=true;
  }
//+------------------------------------------------------------------+
void DrawHistoricalLines(double value,string pivotName,int index)
  {
   color lineLabelColor=clrNONE;
   string message="";
   if(showPriceLabel==Yes)
     {
      message=customMSG+pivotName+": "+DoubleToString(value,Digits);
     }
   else
     {
      message=customMSG+pivotName;
     }
   if('R'==StringGetChar(pivotName,0))
     {
      lineLabelColor=resistantColor;
     }

   if('P'==StringGetChar(pivotName,0))
     {
      lineLabelColor=pivotColor;
     }

   if('S'==StringGetChar(pivotName,0))
     {
      lineLabelColor=supportColor;
     }

   if('M'==StringGetChar(pivotName,0))
     {
      lineLabelColor=midColor;
     }

   if('H'==StringGetChar(pivotName,0))
     {
      lineLabelColor=resistantColor;
     }

   if('L'==StringGetChar(pivotName,0))
     {
      lineLabelColor=supportColor;
     }
   string nameLine=  indiName+pivotName+" Line"+" "+(string)index;
   string nameLabel= indiName+pivotName+" Label"+" "+(string)index;
   if(ObjectFind(nameLine) != 0)
     {
      ObjectCreate(nameLine,OBJ_TREND,0,iTime(NULL,timeFrame,index),value,iTime(NULL,timeFrame,index)+timeFrame*60,value);
      ObjectSet(nameLine,OBJPROP_RAY,false);
      ObjectSet(nameLine,OBJPROP_COLOR,lineLabelColor);
      ObjectSet(nameLine,OBJPROP_STYLE,lineStyle);
      ObjectSet(nameLine,OBJPROP_WIDTH,lineWidth);
      ObjectSet(nameLine,OBJPROP_BACK,true);
      ObjectSet(nameLine,OBJPROP_SELECTED,false);
      ObjectSet(nameLine,OBJPROP_SELECTABLE,false);
      ChartRedraw(0);
     }
   else
     {
      ObjectMove(nameLine,0,iTime(NULL,timeFrame,index),value);
      ObjectMove(nameLine,1,iTime(NULL,timeFrame,index)+timeFrame*60,value);
     }
   if(hideHistoricalLabels==No)
     {
      if(ObjectFind(nameLabel) != 0)
        {
         if(historicalLabelLocation==Left_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,index),value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
           }
         if(historicalLabelLocation==Middle_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,index)+timeFrame*30,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_UPPER);
           }
         if(historicalLabelLocation==Right_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,index)+timeFrame*60,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
           }

         if(useSameColorLabelChoice==Yes)
           {
            ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
           }
         else
           {
            ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
           }
         ObjectSet(nameLabel,OBJPROP_BACK,true);
         ObjectSet(nameLabel,OBJPROP_SELECTED,false);
         ObjectSet(nameLabel,OBJPROP_SELECTABLE,false);
         ChartRedraw(0);
        }
      else
        {
         if(historicalLabelLocation==Left_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,index),value);
           }
         if(historicalLabelLocation==Middle_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,index)+timeFrame*30,value);
           }
         if(historicalLabelLocation==Right_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,index)+timeFrame*60,value);
           }
        }
     }
  }
//+------------------------------------------------------------------+
bool foundWeekend(int index)
  {
   bool result=false;
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,index);
      if(TimeDayOfWeek(dayCheck1) == 0)//found sunday
        {
         result=true;
        }
      datetime dayCheck2=iTime(NULL,PERIOD_D1,index);
      if(TimeDayOfWeek(dayCheck2) == 6)//found saturday
        {
         result=true;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
void DrawFuturePlot(double value,string pivotName)
  {
   color lineLabelColor=clrNONE;
   string message="";
   if(showPriceLabel==Yes)
     {
      message=customMSG+pivotName+": "+DoubleToString(value,Digits);
     }
   else
     {
      message=customMSG+pivotName;
     }
   if('R'==StringGetChar(pivotName,0))
     {
      lineLabelColor=resistantColor;
     }

   if('P'==StringGetChar(pivotName,0))
     {
      lineLabelColor=pivotColor;
     }

   if('S'==StringGetChar(pivotName,0))
     {
      lineLabelColor=supportColor;
     }

   if('M'==StringGetChar(pivotName,0))
     {
      lineLabelColor=midColor;
     }

   if('H'==StringGetChar(pivotName,0))
     {
      lineLabelColor=resistantColor;
     }

   if('L'==StringGetChar(pivotName,0))
     {
      lineLabelColor=supportColor;
     }
   string nameLine=  indiName+pivotName+" Line"+" Future";
   string nameLabel= indiName+pivotName+" Label"+" Future";
   if(ObjectFind(nameLine) != 0)
     {
      ObjectCreate(nameLine,OBJ_TREND,0,iTime(NULL,timeFrame,0)+timeFrame*60,value,iTime(NULL,timeFrame,0)+timeFrame*120,value);
      ObjectSet(nameLine,OBJPROP_RAY,false);
      ObjectSet(nameLine,OBJPROP_COLOR,lineLabelColor);
      ObjectSet(nameLine,OBJPROP_STYLE,lineStyle);
      ObjectSet(nameLine,OBJPROP_WIDTH,lineWidth);
      ObjectSet(nameLine,OBJPROP_BACK,true);
      ObjectSet(nameLine,OBJPROP_SELECTED,false);
      ObjectSet(nameLine,OBJPROP_SELECTABLE,false);
      ChartRedraw(0);
     }
   else
     {
      ObjectMove(nameLine,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
      ObjectMove(nameLine,1,iTime(NULL,timeFrame,0)+timeFrame*120,value);
     }
   if(hideFutureLabels==No)
     {
      if(ObjectFind(nameLabel) != 0)
        {
         if(futureLabelLocation==Left_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
           }
         if(futureLabelLocation==Middle_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*90,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_UPPER);
           }
         if(futureLabelLocation==Right_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*120,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
           }
         if(useSameColorLabelChoice==Yes)
           {
            ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
           }
         else
           {
            ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
           }
         ObjectSet(nameLabel,OBJPROP_BACK,true);
         ObjectSet(nameLabel,OBJPROP_SELECTED,false);
         ObjectSet(nameLabel,OBJPROP_SELECTABLE,false);
         ChartRedraw(0);
        }
      else
        {
         if(futureLabelLocation==Left_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
           }
         if(futureLabelLocation==Middle_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*90,value);
           }
         if(futureLabelLocation==Right_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*120,value);
           }
        }
     }
  }
//standard pivot point formula
void standardPivotPointCPR(double &ppArrayRef[],int timeframeShift,bool futurePlot)//the formula for the standard floor pivot points
  {
   int shift=0;
   if(futurePlot)
     {
      shift=0;
     }
   else
     {
      shift=1;
     }
   /*
   Returned value
   The zero-based day of week (0 means Sunday,1,2,3,4,5,6) of the specified date.
   */
   if(timeFrame==PERIOD_D1)
     {
      datetime dayCheck1=iTime(NULL,PERIOD_D1,timeframeShift+shift);
      if(TimeDayOfWeek(dayCheck1) == 0)//found sunday - skip over
        {
         shift+=1;
        }
      datetime dayCheck2=iTime(NULL,PERIOD_D1,timeframeShift+shift);
      if(TimeDayOfWeek(dayCheck2) == 6)//found saturday - skip over
        {
         shift+=1;
        }
     }
   double prevHigh = iHigh(NULL,timeFrame,timeframeShift+shift);
   double prevLow=iLow(NULL,timeFrame,timeframeShift+shift);
   double prevClose=iClose(NULL,timeFrame,timeframeShift+shift);
   if(futurePlot)
     {
      RefreshRates();
      prevClose= Bid;
     }
   double PP = (prevHigh+prevLow+prevClose)/3;
   double BC = (prevHigh+prevLow)/2;
   double TC = (PP-BC)+PP;
   ppArrayRef[0]=BC;
   ppArrayRef[1]=TC;
  }
//+------------------------------------------------------------------+
void DrawCPRPivotLines(double value,string pivotName)
  {
   color lineLabelColor=clrNONE;
   string message="Poop";
   if(showPriceLabel==Yes)
     {
      message=customMSG+pivotName+": "+DoubleToString(value,Digits);
     }
   else
     {
      message=customMSG+pivotName;
     }
   if('B'==StringGetChar(pivotName,0))
     {
      lineLabelColor=CPRColor;
     }
   else
      if('T'==StringGetChar(pivotName,0))
        {
         lineLabelColor=CPRColor;
        }
   string nameLine=  indiName+pivotName+" Line";
   string nameLabel= indiName+pivotName+" Label";
   if(ObjectFind(nameLine) != 0)
     {
      if(useShortLines==Yes)
        {
         ObjectCreate(nameLine, OBJ_TREND, 0, Time[1]+Period()*60, value, Time[0]+Period()*60*Line_Length, value);
        }
      else
        {
         ObjectCreate(nameLine,OBJ_TREND,0,iTime(NULL,timeFrame,0),value,iTime(NULL,timeFrame,0)+timeFrame*60,value);
        }
      ObjectSet(nameLine,OBJPROP_RAY,false);
      ObjectSet(nameLine,OBJPROP_COLOR,lineLabelColor);
      ObjectSet(nameLine,OBJPROP_STYLE,lineStyle);
      ObjectSet(nameLine,OBJPROP_WIDTH,lineWidth);
      ObjectSet(nameLine,OBJPROP_BACK,true);
      ObjectSet(nameLine,OBJPROP_SELECTED,false);
      ObjectSet(nameLine,OBJPROP_SELECTABLE,false);
      ChartRedraw(0);
     }
   else
     {
      if(useShortLines==Yes)
        {
         ObjectMove(nameLine, 0, Time[1]+Period()*60, value);
         ObjectMove(nameLine, 1, Time[0]+Period()*60*Line_Length, value);
        }
      else
        {
         ObjectMove(nameLine,0,iTime(NULL,timeFrame,0),value);
         ObjectMove(nameLine,1,iTime(NULL,timeFrame,0)+timeFrame*60,value);
        }
     }
   if(hideCurrentLabels==No)
     {
      if(ObjectFind(nameLabel) != 0)
        {
         if(useShortLines==Yes)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,Time[0]+Period()*60*ShiftLabel,value);
            if(useSameColorLabelChoice==Yes)
              {
               ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
              }
            else
              {
               ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
              }
            ObjectSet(nameLabel,OBJPROP_BACK,true);
            ObjectSet(nameLabel,OBJPROP_SELECTED,false);
            ObjectSet(nameLabel,OBJPROP_SELECTABLE,false);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
           }
         else
           {
            if(currentLabelLocation==Follow_Price_2)
              {
               ObjectCreate(nameLabel,OBJ_TEXT,0,Time[0]+Period()*60*ShiftLabel,value);
               ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
              }
            if(currentLabelLocation==Left_2)
              {
               ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0),value);
               ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
              }
            if(currentLabelLocation==Middle_2)
              {
               ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*30,value);
               ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_UPPER);
              }
            if(currentLabelLocation==Right_2)
              {
               ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
               ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
              }
            if(useSameColorLabelChoice==Yes)
              {
               ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
              }
            else
              {
               ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
              }
            ObjectSet(nameLabel,OBJPROP_BACK,true);
            ObjectSet(nameLabel,OBJPROP_SELECTED,false);
            ObjectSet(nameLabel,OBJPROP_SELECTABLE,false);
           }
           ChartRedraw(0);
        }
      else
        {
         if(currentLabelLocation==Follow_Price_2)
           {
            ObjectMove(nameLabel,0,Time[0]+Period()*60*ShiftLabel,value);
           }
         if(currentLabelLocation==Left_2)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0),value);
           }
         if(currentLabelLocation==Middle_2)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*30,value);
           }
         if(currentLabelLocation==Right_2)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
           }
        }
     }
  }
//+------------------------------------------------------------------+
void DrawCPRHistoricalLines(double value,string pivotName,int index)
  {
   color lineLabelColor=clrNONE;
   string message="";
   if(showPriceLabel==Yes)
     {
      message=customMSG+pivotName+": "+DoubleToString(value,Digits);
     }
   else
     {
      message=customMSG+pivotName;
     }
   if('B'==StringGetChar(pivotName,0))
     {
      lineLabelColor=CPRColor;
     }
   if('T'==StringGetChar(pivotName,0))
     {
      lineLabelColor=CPRColor;
     }
   string nameLine=  indiName+pivotName+" Line"+" "+(string)index;
   string nameLabel= indiName+pivotName+" Label"+" "+(string)index;
   if(ObjectFind(nameLine) != 0)
     {
      ObjectCreate(nameLine,OBJ_TREND,0,iTime(NULL,timeFrame,index),value,iTime(NULL,timeFrame,index)+timeFrame*60,value);
      ObjectSet(nameLine,OBJPROP_RAY,false);
      ObjectSet(nameLine,OBJPROP_COLOR,lineLabelColor);
      ObjectSet(nameLine,OBJPROP_STYLE,lineStyle);
      ObjectSet(nameLine,OBJPROP_WIDTH,lineWidth);
      ObjectSet(nameLine,OBJPROP_BACK,true);
      ObjectSet(nameLine,OBJPROP_SELECTED,false);
      ObjectSet(nameLine,OBJPROP_SELECTABLE,false);
      ChartRedraw(0);
     }
   else
     {
      ObjectMove(nameLine,0,iTime(NULL,timeFrame,index),value);
      ObjectMove(nameLine,1,iTime(NULL,timeFrame,index)+timeFrame*60,value);
     }
   if(hideHistoricalLabels==No)
     {
      if(ObjectFind(nameLabel) != 0)
        {
         if(historicalLabelLocation==Left_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,index),value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
           }
         if(historicalLabelLocation==Middle_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,index)+timeFrame*30,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_UPPER);
           }
         if(historicalLabelLocation==Right_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,index)+timeFrame*60,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
           }

         if(useSameColorLabelChoice==Yes)
           {
            ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
           }
         else
           {
            ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
           }
         ObjectSet(nameLabel,OBJPROP_BACK,true);
         ObjectSet(nameLabel,OBJPROP_SELECTED,false);
         ObjectSet(nameLabel,OBJPROP_SELECTABLE,false);
         ChartRedraw(0);
        }
      else
        {
         if(historicalLabelLocation==Left_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,index),value);
           }
         if(historicalLabelLocation==Middle_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,index)+timeFrame*30,value);
           }
         if(historicalLabelLocation==Right_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,index)+timeFrame*60,value);
           }
        }
     }
  }
//+------------------------------------------------------------------+
void DrawCPRFuturePlot(double value,string pivotName)
  {
   color lineLabelColor=clrNONE;
   string message="";
   if(showPriceLabel==Yes)
     {
      message=customMSG+pivotName+": "+DoubleToString(value,Digits);
     }
   else
     {
      message=customMSG+pivotName;
     }
   if('B'==StringGetChar(pivotName,0))
     {
      lineLabelColor=CPRColor;
     }
   if('T'==StringGetChar(pivotName,0))
     {
      lineLabelColor=CPRColor;
     }
   string nameLine=  indiName+pivotName+" Line"+" Future";
   string nameLabel= indiName+pivotName+" Label"+" Future";
   if(ObjectFind(nameLine) != 0)
     {
      ObjectCreate(nameLine,OBJ_TREND,0,iTime(NULL,timeFrame,0)+timeFrame*60,value,iTime(NULL,timeFrame,0)+timeFrame*120,value);
      ObjectSet(nameLine,OBJPROP_RAY,false);
      ObjectSet(nameLine,OBJPROP_COLOR,lineLabelColor);
      ObjectSet(nameLine,OBJPROP_STYLE,lineStyle);
      ObjectSet(nameLine,OBJPROP_WIDTH,lineWidth);
      ObjectSet(nameLine,OBJPROP_BACK,true);
      ObjectSet(nameLine,OBJPROP_SELECTED,false);
      ObjectSet(nameLine,OBJPROP_SELECTABLE,false);
      ChartRedraw(0);
     }
   else
     {
      ObjectMove(nameLine,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
      ObjectMove(nameLine,1,iTime(NULL,timeFrame,0)+timeFrame*120,value);
     }
   if(hideFutureLabels==No)
     {
      if(ObjectFind(nameLabel) != 0)
        {
         if(futureLabelLocation==Left_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
           }
         if(futureLabelLocation==Middle_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*90,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_UPPER);
           }
         if(futureLabelLocation==Right_1)
           {
            ObjectCreate(nameLabel,OBJ_TEXT,0,iTime(NULL,timeFrame,0)+timeFrame*120,value);
            ObjectSet(nameLabel,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
           }
         if(useSameColorLabelChoice==Yes)
           {
            ObjectSetText(nameLabel,message,labelFontSize,Font,useSameColorLabelColor);
           }
         else
           {
            ObjectSetText(nameLabel,message,labelFontSize,Font,lineLabelColor);
           }
         ObjectSet(nameLabel,OBJPROP_BACK,true);
         ObjectSet(nameLabel,OBJPROP_SELECTED,false);
         ObjectSet(nameLabel,OBJPROP_SELECTABLE,false);
         ChartRedraw(0);
        }
      else
        {
         if(futureLabelLocation==Left_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*60,value);
           }
         if(futureLabelLocation==Middle_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*90,value);
           }
         if(futureLabelLocation==Right_1)
           {
            ObjectMove(nameLabel,0,iTime(NULL,timeFrame,0)+timeFrame*120,value);
           }
        }
     }
  }
//+------------------------------------------------------------------+
