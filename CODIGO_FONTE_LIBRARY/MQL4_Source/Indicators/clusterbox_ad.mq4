//+------------------------------------------------------------------+
//|                                                clusterbox_ad.mq4 |
//|                                        Copyright 2015, Scriptong |
//|                                          http://advancetools.net |
//+------------------------------------------------------------------+
#property copyright "Scriptong"
#property link      "http://advancetools.net"
#property description "English: Displays the ticks volume of candles in the form of clusters.\nRussian: ����������� ������� ������� ����� � ���� ���������."
#property strict

#property indicator_chart_window
#property indicator_buffers 1

#define MAX_POINTS_IN_CANDLE 30000                                                                 // ��������� ��� ������ ��������� ������� ���������
#define MAX_TICKS_IN_CANDLE 1000000                                                                // ��������� ��� ������ ��������� ������� ���������
#define MAX_VOLUMES_SHOW      5                                                                    // ���������� ������� ������������� ������, ������� ������� ����������
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct LevelVolumeColor                                                                            // ��������� ������������ ������� ������, ���������� ������� �� ������� ������ ������������.. 
  {                                                                                                 // ..��������������� ������
   color             levelColor;
   int               levelMinVolume;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TickStruct                                                                                  // ��������� ��� ������ ������ �� ����� ����
  {
   datetime          time;
   double            bid;
   double            ask;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_YESNO
  {
   YES,                                                                                           // Yes / ��
   NO                                                                                             // No / ���
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CHARTSCALE
  {
   SCALE_SMALLER,                                                                                  // Smallest / ����������
   SCALE_SMALL,                                                                                    // Small / �����
   SCALE_MEDIUM,                                                                                   // Medium / �������
   SCALE_BIG,                                                                                      // Big / �������
   SCALE_BIGGEST,                                                                                  // Greater / �������
   SCALE_LARGE                                                                                     // Biggest / ����������
  };

//--- ����������� ��������� ����������
input int      i_pointsInBox           = 50;                                                       // Points in one cluster / ���������� ������� � ����� ��������
input string   i_string1               = "Min volumes and colors / ���. ������ � �����";           // ==============================================
input int      i_minVolumeLevel1       = 1;                                                        // Minimal volume. Level 1 / ����������� �����. ������� 1
input color    i_colorLevel1           = clrSkyBlue;                                               // Color of level 1 / ���� ������ 1
input int      i_minVolumeLevel2       = 250;                                                      // Minimal volume. Level 2 / ����������� �����. ������� 2
input color    i_colorLevel2           = clrTurquoise;                                             // Color of level 2 / ���� ������ 2
input int      i_minVolumeLevel3       = 500;                                                      // Minimal volume. Level 3 / ����������� �����. ������� 3
input color    i_colorLevel3           = clrRoyalBlue;                                             // Color of level 3 / ���� ������ 3
input int      i_minVolumeLevel4       = 1000;                                                     // Minimal volume. Level 4 / ����������� �����. ������� 4
input color    i_colorLevel4           = clrBlue;                                                  // Color of level 4 / ���� ������ 4
input int      i_minVolumeLevel5       = 2000;                                                     // Minimal volume. Level 5 / ����������� �����. ������� 5
input color    i_colorLevel5           = clrMagenta;                                               // Color of level 5 / ���� ������ 5
input string   i_string2               = "��������� �������";                                      // ==============================================
input ENUM_YESNO i_useNeededScale      = YES;                                                      // Use the specific chart scale? / ������ ������� �������?
input ENUM_CHARTSCALE i_chartScale     = SCALE_LARGE;                                              // Chart scale / �������
input ENUM_YESNO i_showClusterGrid     = YES;                                                      // Display the cluster grid / ���������� ����� ���������
input color    i_gridColor             = clrDarkGray;                                              // Color of clusters lines / ���� ����� ���������

input int      i_indBarsCount=10000;                                                    // Number of bars to display / ���-�� ����� �����������

//--- ������ ���������� ���������� ����������
bool g_activate,                                                                              // ������� �������� ������������� ����������
g_isShowInfo,                                                                                 // ������� ������������� ����������� ������ ����������
g_chartForeground,                                                                            // ������� ���������� ������ �� �������� �����
g_init;                                                                                       // ���������� ��� ������������� ����������� ���������� ������ ������� � ������ ����������..
                                                                                              // ..��������� �������������
int g_currentScale,// ������� ������� ����������� �� ������ ������������� ����������
g_volumePriceArray[MAX_POINTS_IN_CANDLE];                                                      // ������� ������ �������, � ������� ������������ ���������� �����, ������� ������ ��..
                                                                                               // ..��������������� ���� �����. ���������� ����������� ��������� ������� - ������ �����
double g_ticksPrice[MAX_TICKS_IN_CANDLE];                                                      // ������ ��� ���������� �������� ������ �����, ������������ �� ���� �����

double g_point,
g_tickSize;

TickStruct        g_ticks[];                                                                       // ������ ��� �������� �����, ����������� ����� ������ ������ ����������                    
LevelVolumeColor g_volumeLevelsColor[MAX_VOLUMES_SHOW];                                            // ������ ������� �, ��������������� ��, ������ �������

#define PREFIX                                  "CLSTRBX_"                                         // ������� ����������� ��������, ������������ ����������� 

#define SIGN_BUTTON                             "INFO_BUTTON_"                                     // ������ ����� ������������ ������� "������"
#define BUTTON_FONT_NAME                        "MS Sans Serif"                                    // ��� ������ ��� ����������� ������ ������
#define BUTTON_TOOLTIP                          "���/���� ����������� ��������� � �����"           // ��������� � ���������� ������
#define BUTTON_XCOORD                           2                                                  // �-���������� ������ �������� ���� ������
#define BUTTON_YCOORD                           14                                                 // Y-���������� ������ �������� ���� ������
#define BUTTON_WIDTH                            110                                                // ������ ������
#define BUTTON_HEIGHT                           20                                                 // ������ ������
#define BUTTON_FONT_SIZE                        7                                                  // ������ ������ ��� ������ ������
#define BUTTON_TEXT_COLOR                       clrBlack                                           // ���� ������ ������ � ������
#define BUTTON_BORDER_COLOR                     clrNONE                                            // ���� ������� ������
#define BUTTON_BACKGROUND_COLOR                 clrLightGray                                       // ���� ������� ������

#define FONT_NAME                               "MS Sans Serif"
#define FONT_SIZE                               7
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
  {
   g_activate=false;                                                                             // ��������� �� ���������������
   g_init=true;

   if(!IsTuningParametersCorrect()) // ������� ��������� �������� ����������� ���������� - ������� ��������� �������������
      return INIT_FAILED;

   if(!IsLoadTempTicks()) // �������� ������ � �����, ����������� �� ���������� ������ ������ ����������   
      return INIT_FAILED;

   CreateVolumeColorsArray();                                                                    // ����������� ������ � ����� � �������� ������� � ������
   SetChartView();                                                                               // ��������� �������������� ���� �������

   g_activate=true;                                                                              // ��������� ������� ���������������

   return INIT_SUCCEEDED;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ������������ ����������� ����������                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTuningParametersCorrect()
  {
   string name=WindowExpertName();

   int period= Period();
   if(period == 0)
     {
      Alert(name,": ��������� ������ ��������� - ������ 0 �����. ��������� ��������.");
      return (false);
     }

   g_point=Point;
   if(g_point==0)
     {
      Alert(name,": ��������� ������ ��������� - �������� ������ ����� ����. ��������� ��������.");
      return (false);
     }

   g_tickSize=MarketInfo(Symbol(),MODE_TICKSIZE);
   if(g_tickSize==0)
     {
      Alert(name,": ��������� ������ ��������� - �������� ���� ������ ���� ����� ����. ��������� ��������.");
      return (false);
     }

   if(i_pointsInBox<1)
     {
      Alert(name,": ���������� ������� � �������� ������ ���� �������������. ��������� ��������.");
      return (false);
     }

   return (true);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ � �����, ����������� � ������� ���������� ������� ������ ���������                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsLoadTempTicks()
  {
//--- �������� ����� ������� �������
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return true;

//--- ������������� ������ ��� ������� g_ticks
   int recSize=(int)(FileSize(hTicksFile)/sizeof(TickStruct));
   if(ArrayResize(g_ticks,recSize,1000)<0)
     {
      Alert(WindowExpertName(),": �� ������� ������������ ������ ��� �������� ������ �� ���������� ����� �����. ��������� ��������.");
      FileClose(hTicksFile);
      return false;
     }

//--- ������ �����
   int i=0;
   while(i<recSize)
     {
      if(FileReadStruct(hTicksFile,g_ticks[i])==0)
        {
         Alert(WindowExpertName(),": ������ ������ ������ �� ���������� �����. ��������� ��������.");
         return false;
        }
      i++;
     }

   FileClose(hTicksFile);
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������������ ������� �������� ������� � ��������������� �� ������ �������                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void CreateVolumeColorsArray()
  {
   g_volumeLevelsColor[0].levelMinVolume = i_minVolumeLevel1;
   g_volumeLevelsColor[1].levelMinVolume = i_minVolumeLevel2;
   g_volumeLevelsColor[2].levelMinVolume = i_minVolumeLevel3;
   g_volumeLevelsColor[3].levelMinVolume = i_minVolumeLevel4;
   g_volumeLevelsColor[4].levelMinVolume = i_minVolumeLevel5;

   g_volumeLevelsColor[0].levelColor = i_colorLevel1;
   g_volumeLevelsColor[1].levelColor = i_colorLevel2;
   g_volumeLevelsColor[2].levelColor = i_colorLevel3;
   g_volumeLevelsColor[3].levelColor = i_colorLevel4;
   g_volumeLevelsColor[4].levelColor = i_colorLevel5;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ��������� ������� �������� ������� ��� ������ ����������                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SetChartView()
  {
//--- ��������� �������� ������� ������������ ������ �������
   g_chartForeground=(bool)ChartGetInteger(0,CHART_FOREGROUND);
   ChartSetInteger(0,CHART_FOREGROUND,false);

   if(i_useNeededScale==NO)
      return;

//--- ������� �������
   g_currentScale=(int)ChartGetInteger(0,CHART_SCALE);
   ChartSetInteger(0,CHART_SCALE,(long)i_chartScale);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(!IsSavedFile())    // ���� �� ���� �� ������������ ����������� �� �������� ������, �� �� �������� ������� ���������
      SaveTempTicks();   // ���������� ������ � �����, ����������� �� ������� ������ ������ ����������   
   DeleteAllObjects();
   RestoreChartView();
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ������� ���������� ������ ������ �����������                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsSavedFile()
  {
//--- ��������� ������� ����������� ���������� ����������� ����
   int lastTickIndex=ArraySize(g_ticks)-1;
   if(lastTickIndex<0) // �� ���� ��� �� ��� �������. ������ ������ �� ���������
      return true;

//--- �������� ����� ������� �������
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return false;

//--- ����������� � ��������� ������ � �����
   if(!FileSeek(hTicksFile,-sizeof(TickStruct),SEEK_END))
     {
      FileClose(hTicksFile);
      return false;
     }

//--- ������ ��������� ������ � �������� �����
   TickStruct tick;
   uint readBytes=FileReadStruct(hTicksFile,tick);
   FileClose(hTicksFile);
   if(readBytes==0)
      return false;

//--- ��������� ���� ����, ����������� � �����, � ���� ���������� ������������ ����
   return tick.time >= g_ticks[lastTickIndex].time;                                                // ����/����� ���������� ����������� � ����� ���� ������ ��� ����� ����/�������..
                                                                                                   // ..������������������� ����. ������, ���� ��� �������, � ��������� ������ �� ���������
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������ � �����, ����������� �� ������� ������� ������ ���������                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SaveTempTicks()
  {
//--- �������� ����� ������� �������
   int hTicksFile=FileOpen(Symbol()+"temp.tks",FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE);
   if(hTicksFile<1)
      return;

//--- ������ �����
   int total=ArraySize(g_ticks),i=0;
   while(i<total)
     {
      if(FileWriteStruct(hTicksFile,g_ticks[i])==0)
        {
         Print("������ ���������� ������ �� ��������� ����...");
         return;
        }
      i++;
     }

   FileClose(hTicksFile);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������ ���./����. ������������ ��������� ����������                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowInfoViewButton()
  {
   if(!g_init)
      return;

   g_isShowInfo=true;
   ShowButton(BUTTON_XCOORD,BUTTON_YCOORD,"�������� ����.");
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������������ ������� "������"                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowButton(int x,int y,string text)
  {
   string name=PREFIX+SIGN_BUTTON+IntegerToString(x)+IntegerToString(y);

   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_BUTTON,0,0,0);

      ObjectSetInteger(0,name,OBJPROP_CORNER,0);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);

      ObjectSetInteger(0,name,OBJPROP_XSIZE,BUTTON_WIDTH);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,BUTTON_HEIGHT);

      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetString(0,name,OBJPROP_FONT,BUTTON_FONT_NAME);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,BUTTON_TOOLTIP);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,BUTTON_FONT_SIZE);

      ObjectSetInteger(0,name,OBJPROP_COLOR,BUTTON_TEXT_COLOR);
      ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,BUTTON_BORDER_COLOR);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,BUTTON_BACKGROUND_COLOR);

      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      return;
     }

   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �������� ���� ��������, ��������� ����������                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void DeleteAllObjects()
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
      if(StringSubstr(ObjectName(i),0,StringLen(PREFIX))==PREFIX)
         ObjectDelete(ObjectName(i));

   g_init=true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������������ �������� �������                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void RestoreChartView()
  {
   ChartSetInteger(0,CHART_FOREGROUND,g_chartForeground);

   if(i_useNeededScale==NO)
      return;

   ChartSetInteger(0,CHART_SCALE,g_currentScale);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������� ����, � �������� ���������� ����������� ����������                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int &total,const int ratesTotal,const int prevCalculated)
  {
//--- ����������� ������� ���� �������, �� ������� ����� �������� ���������� �������� ����������
   total=ratesTotal-1;

//--- � ����� �������� ���������� �� ����� ���������� �� ���� �������?
   if(i_indBarsCount>0 && i_indBarsCount<total)
      total=MathMin(i_indBarsCount,total);

//--- ������ ����������� ���������� ��� ��������� �������� ������, �. �. �� ���������� ���� ����� ���� �� �� ���� ��� ������, ��� ��� ���������� �������� �������, � �� ��� ��� ����� ����� ������
   if(prevCalculated<ratesTotal-1)
     {
      DeleteAllObjects();
      return (total);
     }

//--- ���������� �������� �������. ���������� ����� �������� ���� ���������� �� ���������� ����� ����������� ���� �� ������, ��� �� ���� ���
   return (MathMin(ratesTotal - prevCalculated, total));
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ �� ������ �����, ��� ������?                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsFirstMoreThanSecond(double first,double second)
  {
   return (first - second > Point / 10);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����� �� �����?                                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsValuesEquals(double first,double second)
  {
   return (MathAbs(first - second) < Point / 10);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ ���� �� �����                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsReadTimeAndBidAskOfTick(int hTicksFile,TickStruct &tick)
  {
   if(FileIsEnding(hTicksFile))
     {
      FileClose(hTicksFile);
      return false;
     }

   uint bytesCnt=FileReadStruct(hTicksFile,tick);
   if(bytesCnt==sizeof(TickStruct))
      return true;

   FileClose(hTicksFile);
   return false;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� �������� ���� � ���� �������� � ������ ��� ������                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double CastPriceToCluster(double price)
  {
   int priceInPoints=(int)MathRound(price/Point);
   int clusterPrice =(int)MathRound(priceInPoints/1.0/i_pointsInBox);
   return NormalizeDouble(clusterPrice * Point * i_pointsInBox, Digits);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� �����, ������������� ����� �����                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ReadTicksFromFile(int hTicksFile,datetime limitTime,TickStruct &tick,int &ticksCount,bool &fileClose)
  {
   while(!fileClose)
     {
      fileClose=!IsReadTimeAndBidAskOfTick(hTicksFile,tick);
      if(tick.time>=limitTime || fileClose || tick.time==0)
         break;

      g_ticksPrice[ticksCount]=CastPriceToCluster(tick.bid);
      ticksCount++;
      if(ticksCount>MAX_TICKS_IN_CANDLE)
         break;
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������������� ����� �� ���������                                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SortTicksByCluster(int ticksCount,int &arraySize)
  {
   arraySize=1;
   ArrayInitialize(g_volumePriceArray,0);
   g_volumePriceArray[0]=1;
   for(int i=1; i<ticksCount; i++)
     {
      if(!IsValuesEquals(g_ticksPrice[i-1],g_ticksPrice[i]))
        {
         arraySize+=(int)MathRound((g_ticksPrice[i]-g_ticksPrice[i-1])/g_tickSize);
         if(arraySize>MAX_POINTS_IN_CANDLE)
            break;
        }
      g_volumePriceArray[arraySize-1]++;
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������� ������ �� ������ �����                                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void AddDataFromBuffer(datetime limitTime,TickStruct &tick,int &ticksCount)
  {
//--- ����� � ������ ����, ����� �������� ������ ���������� ���������� ����
   int total=ArraySize(g_ticks),i=0;
   while(i<total && tick.time>=g_ticks[i].time)
      i++;

//--- �������� ����� ������ - ������
   if(i>=total)
     {
      tick.time=0;                                                                               // �������� ����� while � ������� ProcessOldCandles �� ��, ��� ������ � ������ �����������
      return;
     }

//--- ���������� ������ �� ������ ������ � ������
   while(i<total && g_ticks[i].time<limitTime)
     {
      g_ticksPrice[ticksCount]=CastPriceToCluster(g_ticks[i].bid);
      ticksCount++;
      i++;
     }

//--- ���������� ������ � ���� ���������� ����
   if(i<total)
      tick=g_ticks[i];
   else
      tick.time=0;                                                                               // �������� ����� while � ������� ProcessOldCandles �� ��, ��� ������ � ������ �����������
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������ ��� ������ ����                                                                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void FormDataForOneBar(int hTicksFile,datetime limitTime,TickStruct &tick,double &lowPrice,int &arraySize,bool &fileClose)
  {
//--- ���������� �����, ������������� ����� �����
   int ticksCount=1;
   g_ticksPrice[0]=CastPriceToCluster(tick.bid);
   if(!fileClose)
      ReadTicksFromFile(hTicksFile,limitTime,tick,ticksCount,fileClose);

   if(fileClose) // ��� �� ������ - else �� �����, �. �. ����� ���������� ReadTicksFromFile ����� ���������� fileClose
      AddDataFromBuffer(limitTime,tick,ticksCount);

//--- ���������� ������� � ������� �����������. ����� ��� ������� ������� �������� ������� �����, � ������� [ticksCount - 1] - ��������
   ArraySort(g_ticksPrice,ticksCount);
   lowPrice=g_ticksPrice[0];

//--- ������������� ����� �� ���������
   SortTicksByCluster(ticksCount,arraySize);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� �������������� �����                                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowHLine(double price,color clr)
  {
   string name=PREFIX+"HLINE_"+IntegerToString((int)(price/g_point));

   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_HLINE,0,0,price);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      return;
     }

   ObjectMove(0,name,0,1,price);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������� "�����"                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowText(int index,datetime time,double price,string text,string toolTip,color clr)
  {
   string name=PREFIX+IntegerToString(time)+IntegerToString(index);
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_TEXT,0,time,price);
      ObjectSetString(0,name,OBJPROP_FONT,FONT_NAME);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONT_SIZE);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetString(0,name,OBJPROP_TOOLTIP,toolTip);
      ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      return;
     }

   ObjectMove(0,name,0,time,price);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| �����������, ������ �� ��������� ������� ������������� ��������������� �������� ������                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetVolumeLevel(int index)
  {
   for(int i=0; i<MAX_VOLUMES_SHOW; i++)
      if(g_volumeLevelsColor[i].levelMinVolume>g_volumePriceArray[index])
         return i - 1;

   return MAX_VOLUMES_SHOW - 1;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ���������� ������ ����                                                                                                                                                                |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowBarHistogramms(int barIndex,double lowPrice,int arraySize)
  {
   if(!g_isShowInfo)
      return;

   for(int i=0; i<arraySize; i+=i_pointsInBox)
     {
      //--- �������� �� ����� ������ ���������� �������?
      int volumeLevel=GetVolumeLevel(i);
      if(volumeLevel<0)
         continue;

      //--- ����������� �������
      double price=lowPrice+i*g_tickSize;
      ShowText(i,Time[barIndex],price,IntegerToString(g_volumePriceArray[i]),DoubleToString(price,Digits),g_volumeLevelsColor[volumeLevel].levelColor);
     }
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������ �� ������������ �����, ������� � ����������                                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessOldCandles(int limit,double &lowPrice,int &arraySize)
  {
//--- �������� ����� ������� �������
   bool fileClose = false;
   int hTicksFile = FileOpen(Symbol() + ".tks", FILE_BIN | FILE_READ | FILE_SHARE_READ | FILE_SHARE_WRITE);
   if(hTicksFile<1)
      fileClose=true;

//--- ����� ������� ����, �������������� ���� limit ��� ������ ����� �������� ����
   TickStruct tick;
   tick.time= Time[limit];
   tick.bid = Open[limit];
   while(!IsStopped() && !fileClose)
     {
      if(!IsReadTimeAndBidAskOfTick(hTicksFile,tick))
         return;

      if(tick.time>=Time[limit])
         break;
     }

//--- ����������� ������
   datetime extremeTime=Time[0]+PeriodSeconds();
   while(tick.time<extremeTime && tick.time!=0)
     {
      int barIndex=iBarShift(NULL,0,tick.time);
      FormDataForOneBar(hTicksFile,Time[barIndex]+PeriodSeconds(),tick,lowPrice,arraySize,fileClose);
      ShowBarHistogramms(barIndex,lowPrice,arraySize);
     }

   if(!fileClose)
      FileClose(hTicksFile);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������ ����                                                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessNewBarForming(double bid,double &lowPrice,int &arraySize)
  {
   ArrayInitialize(g_volumePriceArray,0);
   arraySize= 1;
   lowPrice = bid;
   g_volumePriceArray[0]=1;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� �������� ������� �����                                                                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessCandleMinimumUpdate(int priceIndex,double bid,double &lowPrice,int &arraySize)
  {
   priceIndex = MathAbs(priceIndex);
   arraySize += priceIndex;
   if(arraySize>MAX_POINTS_IN_CANDLE)
      return;

//--- ���������� ���������� �������� ��������� ������� �� priceIndex ���������
   for(int i=arraySize-1; i>priceIndex-1; i--)
      g_volumePriceArray[i]=g_volumePriceArray[i-priceIndex];

//--- ���������� ������ ���������, ��������������� ����� ����� ���������� ��������� � �������
   for(int i=priceIndex-1; i>=0; i--)
      g_volumePriceArray[i]=0;
   g_volumePriceArray[0]=1;

//--- ����� �������
   lowPrice=bid;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ������ ������ � ���� � ������ g_ticks                                                                                                                                                             |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsUpdateTicksArray(TickStruct &tick)
  {
   int total=ArraySize(g_ticks);
   if(ArrayResize(g_ticks,total+1,100)<0)
     {
      Alert(WindowExpertName(),": ���������� �� ������� ������ ��� ���������� ������ �� ��������� ����.");
      return false;
     }

   g_ticks[total]=tick;
   return true;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������ ������ ���� � ��������� �����                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessOneTick(int limit,double &lowPrice,int &arraySize)
  {
   TickStruct tick;
   tick.time= TimeCurrent();
   tick.ask = Ask;
   tick.bid = Bid;

//--- ���������� ������ ���� � ������ �������� �����   
   if(!IsUpdateTicksArray(tick))
     {
      g_activate=false;
      return;
     }

   double bid=CastPriceToCluster(Bid);

//--- ����������� ������ ���� ��� ������ ������ "� ����"
   if(limit==1 || lowPrice==0 || arraySize==0)
     {
      ProcessNewBarForming(bid,lowPrice,arraySize);
      return;
     }

//--- ���� ���������� ����� �� ���������, �� ������ ����������� ����� ������ �� ������������ �������
   int priceIndex=(int)MathRound((bid-lowPrice)/g_tickSize);                                 // ������ �������� ������� g_volumePriceArray, �������� ������������� ���� Bid
   if(priceIndex>=0 && priceIndex < arraySize)
     {
      g_volumePriceArray[priceIndex]++;
      return;
     }

//--- �������� ������� ������� �����. ����� �������� ��� �������� ������� g_volumePriceArray �� priceIndex �����
   if(IsFirstMoreThanSecond(lowPrice,bid))
     {
      ProcessCandleMinimumUpdate(priceIndex,bid,lowPrice,arraySize);
      return;
     }

//--- �������� �������� ������� �����. 
   if(priceIndex+1>MAX_POINTS_IN_CANDLE)
      return;

   arraySize=priceIndex+1;
   g_volumePriceArray[priceIndex]=1;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ����� ���������                                                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowGrid()
  {
   if(!g_init)
      return;

   g_init=false;

   if(i_showClusterGrid==NO)
      return;

//--- ����������� ������������ �����������
   double highPrice= CastPriceToCluster(High[iHighest(NULL,0,MODE_HIGH)]);
   double lowPrice = CastPriceToCluster(Low[iLowest(NULL,0,MODE_LOW)]);

//--- ����������� ����� ���������
   for(double price=lowPrice; price<=highPrice; price=NormalizeDouble(price+i_pointsInBox*g_point,Digits))
      ShowHLine(price,i_gridColor);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ����������� ������ ����������                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowIndicatorData(int limit,int total)
  {
   static double lowPrice = 0;                                                                     // ����, ��������������� �������� ����� � �������� �������� ������� g_volumePriceArray. �������..
                                                                                                   // ..�������� ����� ��������������� ���� lowPrice + Point � �.�.;
   static int arraySize = 0;                                                                       // ���������� ���������, ���������� � ������ g_volumePriceArray. � ������ ��� �������� ������ ����..
                                                                                                   // ..����� ���������� �������, �� ������� ������� �����. �� ��-�� ���������� ������ ����� �..
                                                                                                   // ..��������� ������������ ������ �������� ������
   if(limit>1)   // ����� ���������� ������ � ������ ����������� ���� ������� - ��������� �������� ��� ����������..
     {           // ..����� � �������� ����� 1
      ProcessOldCandles(limit,lowPrice,arraySize);
      return;
     }

//--- ���������� ���������� - ������ ������ ���� ��� ����������� ������ ����
   ProcessOneTick(limit,lowPrice,arraySize);
   ShowBarHistogramms(0,lowPrice,arraySize);
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
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
   if(!g_activate) // ���� ��������� �� ������ �������������, �� �������� �� �� ������
      return rates_total;

   ProcessGlobalTick(rates_total,prev_calculated);

   return rates_total;
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ����� �������� ����������� ������                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessGlobalTick(const int rates_total,const int prev_calculated)
  {
   int total;
   int limit=GetRecalcIndex(total,rates_total,prev_calculated);                                // � ������ ���� �������� ����������?

   ShowInfoViewButton();                                                                           // ����������� ������ ���./����. ������������ ��������� ����������
   ShowGrid();                                                                                     // ����������� ����� ���������
   ShowIndicatorData(limit, total);                                                                // ����������� ������ ����������
  }
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| ���������� ������� �����                                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id!=CHARTEVENT_OBJECT_CLICK)
      return;

   if(sparam!=PREFIX+SIGN_BUTTON+IntegerToString(BUTTON_XCOORD)+IntegerToString(BUTTON_YCOORD))
      return;

//--- ���������� ���������   
   if(g_isShowInfo)
     {
      DeleteAllObjects();
      ShowButton(BUTTON_XCOORD,BUTTON_YCOORD,"�������� ���.");
      g_isShowInfo=false;
      g_init=false;
      return;
     }

//--- ��������� ���������
   g_init=true;
   ProcessGlobalTick(Bars,0);
  }
//+------------------------------------------------------------------+
