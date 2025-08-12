
/*
Version  November 28, 2007

���  ������  ����������  �������  �������� ����� 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
MAMA_NK.mq4
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+X================================================================X+
//|                                                    MAMAXX_NK.mq4 |
//|                    MAMA skript:                      John Ehlers |
//|                    MQL4 CODE: Copyright � 2007, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+X================================================================X+
#property link  "farria@mail.redcom.ru/"
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ���������� ������������ �������
#property indicator_buffers 2 
//---- ����� ����������
#property indicator_color1 Blue
#property indicator_color2 Red
//---- ������� ������������ �����
#property indicator_width1 1
#property indicator_width2 1
//---- ������� ��������� ���������� 
extern double FastLimit = 0.2;
extern double SlowLimit = 0.05;
extern int IPC = 4;/* ����� ���, �� ������� ������������ ������ ���������� 
(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 
7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW, 
11-Heiken Ashi Low, 12-Heiken Ashi High, 13-Heiken Ashi Open, 
14-Heiken Ashi Close, 15-Heiken Ashi Open0.) */
//---- ������������ �������
double FAMA[];
double MAMA[];
//+X================================================================X+
//| ���������� ������� PriceSeries                                   |
//| ���������� ������� PriceSeriesAlert                              | 
//+X================================================================X+
#include <PriceSeries.mqh>
//+X================================================================X+
//| MAMAXX initialization function                                   |
//+X================================================================X+
int init()
//----+
  {
//---- ����� ���������� �������
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_LINE);
//---- 2 ������������ ������� ������������ ��� �����
    SetIndexBuffer(0, FAMA);                                     
    SetIndexBuffer(1, MAMA);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
//---- ��� ��� ���� ������ � ����� ��� ��������
    IndicatorShortName("#MAMAXX");
    SetIndexLabel(0, "#FAMAXX");
    SetIndexLabel(1, "#MAMAXX");
//---- ��������� ������ ����, 
                  //������� � �������� ����� �������������� ��������� 
    SetIndexDrawBegin(0, 50);
    SetIndexDrawBegin(1, 50);
//---- ��������� ������� �� ������������ �������� ������� ����������
    PriceSeriesAlert(IPC);
//---- ���������� �������������
    return(0);
  }
//----+
//+X================================================================X+
//|    MAMAXX iteration function                                     |
//+X================================================================X+
int start()
//----+
  {
    int BARS=Bars;    
    //---- �������� ���������� ����� �� ������������� ��� �������
    if(BARS <= 7) 
            return(0);
    //----+ �������� ����� ���������� � ��������� ��� ����������� �����
    int MaxBar, limit, bar, counted_bars=IndicatorCounted();
    //---- �������� �� ��������� ������
    if (counted_bars<0)
                   return(-1);
    //---- ��������� ����������� ��� ������ ���� ����������
    if (counted_bars>0) 
                  counted_bars--;
    //----+ �������� ���������� � ��������� ������
    double  alpha; 
    //---- ����������� ������ ������ ������� ����, 
             //������� � �������� ����� ��������� ������ �������� ���� ����� 
    MaxBar=BARS-1-7;
    //---- ����������� ������ ������ ������� ����, 
             //������� � �������� ����� �������� �������� ������ ����� ����� 
    limit = BARS - 1 - counted_bars;
    //---- ������������� ����
    if(limit>=MaxBar)
     {
       for(bar = BARS - 1; bar > MaxBar; bar--) 
         {
           MAMA[bar] = 0.0;
           FAMA[bar] = 0.0;
           limit = MaxBar;
         }
     }
    //----
    for (bar=limit;bar>=0;bar--)
      {
        alpha = FastLimit;
        if (alpha < SlowLimit)
                      alpha = SlowLimit;
        //---+
        MAMA[bar] = alpha*PriceSeries(IPC, bar) 
                          + (1.0 - alpha)*MAMA[bar+1];
        FAMA[bar] = 0.5*alpha*MAMA[bar] 
                        + (1.0 - 0.5*alpha)*FAMA[bar+1];    
      }
    return(0);
  }
//----+
//+X================================================================X+

