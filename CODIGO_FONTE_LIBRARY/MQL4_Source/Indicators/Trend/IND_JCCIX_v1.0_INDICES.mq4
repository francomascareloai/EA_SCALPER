/*
���  ������  ����������  �������  �������� ����� 
JJMASeries.mqh
JurSeries.mqh 
PriceSeries.mqh 
� ����� (����������): MetaTrader\experts\include\
Heiken Ashi#.mq4
� ����� (����������): MetaTrader\indicators\
*/
//+------------------------------------------------------------------+ 
//|                                                        JCCIX.mq4 |
//|                              Copyright � 2006,  Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright � 2006, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ �������
#property indicator_buffers  1
//---- ����� ����������
#property indicator_color1  BlueViolet
//---- ��������� �������������� ������� ����������
#property indicator_level1  0.5
#property indicator_level2 -0.5
#property indicator_level3  0.0
#property indicator_levelcolor MediumBlue
#property indicator_levelstyle 4
//---- ������� ��������� ���������� --------------------------------------------------------------------------------------------------+
extern int  JJMA_Length = 8;  // ������� JJMA ����������� ������� ����
extern int  JurX_Length = 8;  // ������� JurX ����������� ����������� ���������� 
extern int  JJMA_Phase = 100; // ��������, ������������ � �������� -100 ... +100, ������ �� �������� ���������x ��������� �����������
extern int Input_Price_Customs = 0;/* ����� ���, �� ������� ������������ ������ ���������� 
(0-CLOSE, 1-OPEN, 2-HIGH, 3-LOW, 4-MEDIAN, 5-TYPICAL, 6-WEIGHTED, 7-Heiken Ashi Close, 8-SIMPL, 9-TRENDFOLLOW, 10-0.5*TRENDFOLLOW,
11-Heiken Ashi Low, 12-Heiken Ashi High,  13-Heiken Ashi Open, 14-Heiken Ashi Close.) */
//---- -------------------------------------------------------------------------------------------------------------------------------+
//---- ������������ ������
double Ind_Buffer1[];
//---- ����� ��������� 
int    w;
//+------------------------------------------------------------------+  
//----+ �������� ������� JJMASeries 
//----+ �������� ������� JJMASeriesResize 
//----+ �������� ������� JJMASeriesAlert  
//----+ �������� ������� JMA_ErrDescr  
#include <JJMASeries.mqh> 
//+------------------------------------------------------------------+ 
//----+ �������� ������� JurXSeries
//----+ �������� ������� JurXSeriesResize
//----+ �������� ������� JurXSeriesAlert 
//----+ �������� ������� JurX_ErrDescr  
#include <JurXSeries.mqh> 
//+------------------------------------------------------------------+  
//----+ �������� ������� PriceSeries
//----+ �������� ������� PriceSeriesAlert 
#include <PriceSeries.mqh>
//+------------------------------------------------------------------+ 
//| JCCIX initialization function                                    |
//+------------------------------------------------------------------+ 
int init()
 {
//---- ����� ����������� ����������
   SetIndexStyle(0,DRAW_LINE);
//---- 1 ������������ ����� ����������� ��� �����. 
   SetIndexBuffer(0,Ind_Buffer1);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   SetIndexEmptyValue(0,0); 
//---- ����� ��� ���� ������ � ����� ��� ��������
   SetIndexLabel(0,"JCCIX");
   IndicatorShortName("JCCIX(JJMA_Length="+JJMA_Length+", JurX_Length"+JurX_Length+")");
//---- ��������� ������� �������� (���������� ������ ����� ���������� �����) ��� ������������ �������� ����������  
   IndicatorDigits(2);
//----+ ��������� �������� �������� ���������� ������� JurXSeries, nJurXnumber=2(��� ��������� � ������� JurXSeries)
   if (JurXSeriesResize(2)!=2)return(-1);
//----+ ��������� �������� �������� ���������� ������� JJMASeries, nJMAnumber=1(���� ��������� � ������� JJMASeries)
   if (JJMASeriesResize(1)!=1)return(-1);
//---- ��������� ������� �� ������������ �������� ������� ����������
   JurXSeriesAlert (0,"JurX_Length",JurX_Length);
   JJMASeriesAlert (0,"JJMA_Length",JJMA_Length);
   JJMASeriesAlert (1,"JJMA_Phase",JJMA_Phase);
   PriceSeriesAlert(Input_Price_Customs);
//---- ��������� ������ ����, ������� � �������� ����� �������������� ���������  
   SetIndexDrawBegin(0,JurX_Length+31);
//---- ������������� ������������� ��� ������� ���������� 
   if (JurX_Length>5) w=JurX_Length-1; else w=5;
//---- ���������� �������������
   return(0);
  }
//+------------------------------------------------------------------+ 
//|  JCommodity Channel IndexX                                       |
//+------------------------------------------------------------------+ 
int start()
  {
//---- �������� ���������� � ��������� ������    
double price,Jprice,JCCIX,UPCCI,DNCCI,JUPCCIX,JDNCCIX; 
//----+ �������� ����� ���������� � ��������� ��� ������������ �����
int reset,MaxBar,MaxBarJ,limit,counted_bars=IndicatorCounted();
//---- �������� �� ��������� ������
if (counted_bars<0)return(-1);
//---- ��������� ������������ ��� ������ ���� ���������� 
//---- (��� ����� ��������� ��� counted_bars ������� JJMASeries � JurXSeries ����� �������� �����������!!!)
if (counted_bars>0) counted_bars--;
//---- ����������� ������ ������ ������� ����, ������� � �������� ����� �������� �������� ����� �����
limit=Bars-counted_bars-1; MaxBar=Bars-1; MaxBarJ=MaxBar-30;
//---- �������� ���������� ��������� ���� � �����
if(limit>=MaxBar)limit=MaxBar;

for(int bar=limit; bar>=0; bar--)
 { 
   //----+ ��������� � ������� PriceSeries ��� ��������� ������� ���� Series
   price=PriceSeries(Input_Price_Customs, bar);
   //+----------------------------------------------------------------------------+ 
   //----+ ���� ��������� � ������� JJMASeries �� ������� 0. 
   //----+ ��������� nJMA.Phase � nJMA.Length �� �������� �� ������ ���� (nJMA.din=0)
   //+----------------------------------------------------------------------------+   
   Jprice=JJMASeries(0,0,MaxBar,limit,JJMA_Phase,JJMA_Length,price,bar,reset);
   //----+ �������� �� ���������� ������ � ���������� ��������
   if(reset!=0)return(-1);
   //+----------------------------------------------------------------------------+    
   UPCCI=price-Jprice;         
   DNCCI=MathAbs(UPCCI);
   //----+ ��� ��������� � ������� JurXSeries �� �������� 0 � 1. �������� nJJurXLength �� ����t��� �� ������ ���� (nJurXdin=0)
   //----+ �������� �� ���������� ������ � ���������� ��������
   JUPCCIX=JurXSeries(0,0,MaxBarJ,limit,JurX_Length,UPCCI,bar,reset); if(reset!=0)return(-1); 
   JDNCCIX=JurXSeries(1,0,MaxBarJ,limit,JurX_Length,DNCCI,bar,reset); if(reset!=0)return(-1); 
   //----+
   if (bar>MaxBarJ-w)JCCIX=0;
   else 
     if (JDNCCIX!=0)
       {
        JCCIX=JUPCCIX/JDNCCIX;
        if(JCCIX>1)JCCIX=1;
        if(JCCIX<-1)JCCIX=-1;
       }
     else JCCIX=0;
   Ind_Buffer1[bar]=JCCIX; 
   //----+
 }
//----
   return(0);
  }
//+---------------------------------------------------------------------------+


