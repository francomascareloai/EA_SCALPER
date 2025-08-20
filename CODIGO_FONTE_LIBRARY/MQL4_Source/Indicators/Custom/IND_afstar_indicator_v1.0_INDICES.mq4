//+------------------------------------------------------------------+
//|                                                       AFStar.mq4 |
//|                                  Copyright © 2005, Forex-Experts |
//|                                     http://www.forex-experts.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Magenta
#property indicator_color2 Aqua

//---- input parameters
 
extern double StartFast=3;
extern double EndFast=3.5;
extern double StartSlow=8;
extern double EndSlow=9;
extern double StepPeriod=0.2;
extern double StartRisk=1;
extern double EndRisk=2.8;
extern double StepRisk=0.5; 
extern int    AllBars=500;


int      shift=0,RiskCnt=0, EndScan1=0, EndScan2=0;
double   iMaSlowPrevious=0, iMaSlowCurrent=0, iMaFastPrevious=0, iMaFastCurrent=0;
double   FastCnt=0, SlowCnt=0;
double   Buy1[1000], Sell1[1000];
double   Buy2[1000], Sell2[1000];
double   Buy=0, Sell=0;
//---- buffers

double val1[];
double val2[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,226);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,225);
   SetIndexBuffer(0,val1);
   SetIndexBuffer(1,val2);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if (AllBars>=1000) AllBars=1000;

   SetIndexDrawBegin(0,Bars-AllBars+11+1);
   SetIndexDrawBegin(1,Bars-AllBars+11+1);
   int i,shift,counted_bars=IndicatorCounted();
   int Counter,i1,value10,value11;
   double value1,x1,x2;
   double value2,value3;
   double TrueCount,Range,AvgRange,MRO1,MRO2;
   double Table_value2[1000];
//----
   if(Bars<=11+1) return(0);
//---- initial zero
   if(counted_bars<11+1)
   {
      for(i=1;i<=0;i++) val1[AllBars-i]=0.0;
      for(i=1;i<=0;i++) val2[AllBars-i]=0.0;
   }

//---- TODO: add your code here
//for (shift=(AllBars-11-1); shift<=0; shift--)
//{
   shift=AllBars-11-1;
   while(shift>=0)
{

	Sell1[shift]=0;
	Buy1[shift]=0;
	EndScan1=0;
	SlowCnt=StartSlow;
	while (SlowCnt<=EndSlow)
	{	
	   if (EndScan1==1) break;
		FastCnt=StartFast;
		while (FastCnt<=EndFast)
		{
		 if (EndScan1==1) break;
		 //Scan Parameters		
		 iMaSlowPrevious = iMA(NULL,0,SlowCnt,0,MODE_EMA, PRICE_CLOSE, shift-1);
		 iMaSlowCurrent = iMA(NULL,0,SlowCnt,0,MODE_EMA, PRICE_CLOSE, shift);
		 iMaFastPrevious = iMA(NULL,0,FastCnt,0, MODE_EMA, PRICE_CLOSE, shift-1);
		 iMaFastCurrent = iMA(NULL,0,FastCnt,0, MODE_EMA, PRICE_CLOSE, shift);
		 if (iMaFastPrevious<iMaSlowPrevious && iMaFastCurrent>iMaSlowCurrent) { EndScan1=1; Sell1[shift]=1;}
		 if (iMaFastPrevious>iMaSlowPrevious && iMaFastCurrent<iMaSlowCurrent) { EndScan1=1; Buy1[shift]=1;}
		 FastCnt=FastCnt+StepPeriod;
		}	
	SlowCnt=SlowCnt+StepPeriod;
	}

	EndScan2=0;
	Sell2[shift]=0;
   Buy2[shift]=0;
	RiskCnt=StartRisk;
//	while (RiskCnt<=EndRisk)
	if (RiskCnt<=EndRisk)
	{ 

	if (EndScan2!=1) {
 
   value10=3+RiskCnt*2;
   x1=67+RiskCnt;
   x2=33-RiskCnt;
   value11=value10;

//----
//   shift=AllBars-11-1;
//   while(shift>=0)
//     {
     
   Counter=shift;
	Range=0.0;
	AvgRange=0.0;
	for (Counter=shift; Counter<=shift+9; Counter++) AvgRange=AvgRange+MathAbs(High[Counter]-Low[Counter]);
		
	Range=AvgRange/10;
	Counter=shift;
	TrueCount=0;
	while (Counter<shift+9 && TrueCount<1)
		{if (MathAbs(Open[Counter]-Close[Counter+1])>=Range*2.0) TrueCount=TrueCount+1;
		Counter=Counter+1;
		}
	if (TrueCount>=1) {MRO1=Counter;} else {MRO1=-1;}
	Counter=shift;
	TrueCount=0;
	while (Counter<shift+6 && TrueCount<1)
		{if (MathAbs(Close[Counter+3]-Close[Counter])>=Range*4.6) TrueCount=TrueCount+1;
		Counter=Counter+1;
		}
	if (TrueCount>=1) {MRO2=Counter;} else {MRO2=-1;}
	if (MRO1>-1) {value11=3;} else {value11=value10;}
	if (MRO2>-1) {value11=4;} else {value11=value10;}
	value2=100-MathAbs(iWPR(NULL,0,value11,shift)); // PercentR(value11=9)
	Table_value2[shift]=value2;
	val1[shift]=0;
	val2[shift]=0;
	value3=0;
	if (value2<x2)
		{i1=1;
		while (Table_value2[shift+i1]>=x2 && Table_value2[shift+i1]<=x1){i1++;}
		if (Table_value2[shift+i1]>x1) 
			{
			value3=High[shift]+Range*0.5;
         Sell2[shift]=value3;
//			val1[shift]=value3;
			} 
		}
	if (value2>x1)
		{i1=1;
		while (Table_value2[shift+i1]>=x2 && Table_value2[shift+i1]<=x1){i1++;}
		if (Table_value2[shift+i1]<x2) 
			{
			value3=Low[shift]-Range*0.5;
         Buy2[shift]=value3;
//			val2[shift]=value3;
			}
		}

  }
	if (Buy2[shift]>0 || Sell2[shift]>0) {EndScan2=1;}

	RiskCnt=RiskCnt+StepRisk;      
}

//Main decision module

Buy=0; Sell=0;

if ((Buy1[shift]>0 && Buy2[shift]>0) || (Buy1[shift]>0 && Buy2[shift+1]>0) || (Buy1[shift+1]>0 && Buy2[shift]>0)) Buy=Low[shift]-1*Point;   	
if ((Sell1[shift]>0 && Sell2[shift]>0) || (Sell1[shift]>0 && Sell2[shift+1]>0) || (Sell1[shift+1]>0 && Sell2[shift]>0)) Sell=High[shift]+1*Point;   	


//Ignore if we have two signals
if (Buy!=0 && Sell!=0)
{
	Buy=0; Sell=0;
}


val1[shift]=Sell;
val2[shift]=Buy;

   shift--;
}
  
//----
   return(0);
  }
//+------------------------------------------------------------------+