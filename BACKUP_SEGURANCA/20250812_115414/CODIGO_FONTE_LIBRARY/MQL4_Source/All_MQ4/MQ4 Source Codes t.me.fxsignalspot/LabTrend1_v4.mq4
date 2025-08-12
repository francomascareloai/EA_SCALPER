//+------------------------------------------------------------------+
//|                                                 LabTrend1_v4.mq4 |
//|                           Copyright © 2008, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, TrendLaboratory Ltd."
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 2
#property indicator_width4 2

//---- input parameters

extern double  Risk           = 3;       //Price Channel narrowing factor (1..10)  
extern int     TimeFrame      = 0;       //TimeFrame in min
extern int     Signal         = 1;       //Display signals mode
extern int     ColorBar       = 1;       //Display color bars mode: 0-no,1-yes 
extern int     SoundAlertMode = 0;       //Sound Alert switch 

//---- indicator buffers
double UpTrendSignal[];
double DownTrendSignal[];
double UpTrendBar[];
double DownTrendBar[];
double bsmax[];
double bsmin[];
double time[];
double trend[];

int    Length;
bool   UpTrendAlert=false, DownTrendAlert=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   string short_name;
//---- indicator line
   IndicatorBuffers(8); 
   SetIndexBuffer(0,UpTrendSignal);
   SetIndexBuffer(1,DownTrendSignal);
   SetIndexBuffer(2,UpTrendBar);
   SetIndexBuffer(3,DownTrendBar);
   SetIndexBuffer(4,bsmax);
   SetIndexBuffer(5,bsmin);
   SetIndexBuffer(6,time);
   SetIndexBuffer(7,trend);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexArrow(0,108);
   SetIndexArrow(1,108);
   
//---- name for DataWindow and indicator subwindow label
   short_name="LabTrend1("+DoubleToStr(Risk,2)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"UpTrend Signal");
   SetIndexLabel(1,"DownTrend Signal");
   SetIndexLabel(2,"UpTrend Bar");
   SetIndexLabel(3,"DownTrend Bar");
//----
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   SetIndexEmptyValue(3,0.0);
   SetIndexEmptyValue(6,0.0);
   Length = 3 + 2*Risk;  
   SetIndexDrawBegin(0,Length);
   SetIndexDrawBegin(1,Length);
   SetIndexDrawBegin(2,Length);
   SetIndexDrawBegin(3,Length);
//----
   return(0);
}
//+------------------------------------------------------------------+
//| LabTrend1_v4                                                     |
//+------------------------------------------------------------------+
int start()
{
   
   //datetime TimeArray[];
   int    i,shift,y=0,MaxBar,limit,counted_bars=IndicatorCounted();
   double high, low, sum, UpBar,DnBar;
   
   //double bsmax[1],bsmin[1];
   //double LowArray[],HighArray[];
   if (TimeFrame == 0) TimeFrame = Period();
   
   int Line=0;            //Display line mode: 0-no,1-yes  
    
   if (Bars-1<Length+1)return(0);
   if (counted_bars<0)return(-1);
 
   if (counted_bars>0) counted_bars--;
 
   MaxBar=Bars-1-Length-1;
   //limit=Bars-counted_bars-1; 
   limit=Bars-counted_bars+TimeFrame/Period();
   
   if (limit>MaxBar)
   {
      for (shift=limit;shift>=MaxBar;shift--) 
      { 
      bsmax[Bars-shift]=0.0;
      bsmin[Bars-shift]=0.0;
      UpTrendSignal[Bars-shift]=0.0;
      DownTrendSignal[Bars-shift]=0.0;
      UpTrendBar[Bars-shift]=0.0;
	   DownTrendBar[Bars-shift]=0.0;
      } 
   limit=MaxBar;
   }
   
   for(shift=0,y=0;shift<limit;shift++)
   {
   if (Time[shift]<iTime(NULL,TimeFrame,y)) y++; 
  
   double smin = iLow(NULL,TimeFrame,iLowest(NULL,TimeFrame,MODE_LOW,Length,y));         
   double smax = iHigh(NULL,TimeFrame,iHighest(NULL,TimeFrame,MODE_HIGH,Length,y)); 

// Calculation channel stop values 
   time[shift] = (iTime(NULL,TimeFrame,y)+TimeFrame*60);            
   bsmax[shift]=smax-(smax-smin)*(33.0-Risk)/100.0;	
   bsmin[shift]=smin+(smax-smin)*(33.0-Risk)/100.0;
   UpTrendSignal[shift] = iLow(NULL,TimeFrame,y) - 0.5*iATR(NULL,TimeFrame,10,y);
   DownTrendSignal[shift] = iHigh(NULL,TimeFrame,y) + 0.5*iATR(NULL,TimeFrame,10,y);
   }

   for(shift=limit;shift>=0;shift--)
   {

// Signal area : any conditions to trend determination:     
// 1. Price Channel breakout 
   
   trend[shift] = trend[shift+1];  
   if(trend[shift+1]<=0 && Close[shift]>bsmax[shift] && time[shift]==(Time[shift]+Period()*60))  trend[shift]=1; 
   if(trend[shift+1]>=0 && Close[shift]<bsmin[shift] && time[shift]==(Time[shift]+Period()*60))  trend[shift]=-1;
   //if (shift < 100 ) Print("i=",shift," trend=",trend[shift]," ptrend=",trend[shift+1]," p=",price[shift]);
// Drawing area	  
   UpBar=bsmax[shift];
	DnBar=bsmin[shift];
	
   UpTrendBar[shift]=EMPTY_VALUE;
	DownTrendBar[shift]=EMPTY_VALUE;  	 
      
      if (trend[shift]>0) 
      {
         if (Signal>0)
         {
            if(trend[shift+1]<0)
            {
	         if (SoundAlertMode>0 && shift==0) PlaySound("alert2.wav");      	        
	         }
	         else
	         UpTrendSignal[shift]=EMPTY_VALUE;
	      }
	      	  
	      if(ColorBar>0)
	      {
            if(Close[shift]>UpBar)
	         {
	         UpTrendBar[shift]=High[shift];
	         DownTrendBar[shift]=Low[shift];
	         }
	         else
	         {
	         UpTrendBar[shift]=EMPTY_VALUE;
	         DownTrendBar[shift]=EMPTY_VALUE;
	         }
         }   
	   }
      else
      UpTrendSignal[shift]=EMPTY_VALUE;
      	  
      if (trend[shift]<0) 
	   {
         if (Signal > 0) 
         {   
            if(trend[shift+1]>0)
	         {
	         if (SoundAlertMode>0 && shift==0) PlaySound("alert2.wav");
	         }
	         else
	         DownTrendSignal[shift]=EMPTY_VALUE;
	      }
	              
         if(ColorBar>0)
	      {
            if(Close[shift]<DnBar)
	         {
	         UpTrendBar[shift]=Low[shift];
	         DownTrendBar[shift]=High[shift];
	         }
	         else
	         {
	         UpTrendBar[shift]=EMPTY_VALUE;
	         DownTrendBar[shift]=EMPTY_VALUE;
	         }      
         }   
	   }
	   else
      DownTrendSignal[shift]=EMPTY_VALUE;
   }

//----------   
   string Message;
   
   if ( trend[2]<0 && trend[1]>0 && Volume[0]>1 && !UpTrendAlert)
	{
	Message = " "+Symbol()+" M"+Period()+": Signal for BUY";
	if ( SoundAlertMode>0 ) Alert (Message); 
	UpTrendAlert=true; DownTrendAlert=false;
	} 
	 	  
	if ( trend[2]>0 && trend[1]<0 && Volume[0]>1 && !DownTrendAlert)
	{
	Message = " "+Symbol()+" M"+Period()+": Signal for SELL";
	if ( SoundAlertMode>0 ) Alert (Message); 
	DownTrendAlert=true; UpTrendAlert=false;
	} 	         
//----
   return(0);
}
//+------------------------------------------------------------------+