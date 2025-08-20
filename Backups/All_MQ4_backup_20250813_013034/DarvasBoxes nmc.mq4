//+------------------------------------------------------------------+
//|                                               DarvasBoxes_v3.mq4 |
//|                                Copyright © 2013, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#include <stdlib.mqh>

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 RoyalBlue
#property indicator_color2 Tomato
#property indicator_color3 RoyalBlue
#property indicator_color4 Tomato
#property indicator_color5 RoyalBlue
#property indicator_color6 Tomato

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2

//Darvas Modes;
//0-Classic (by Upper Pivot)
//1-Modern (by Upper Pivot)
//2-Bi-directional Classic (UpTrend by Upper Pivot, DownTrend by Lower Pivot)
//3-Bi-directional Modern (UpTrend by Upper Pivot, DownTrend by Lower Pivot)
//4-Classic by 1st Pivot (Upper or Lower)
//5-Modern by 1st Pivot (Upper or Lower) 

//---- input parameters
extern string  UniqueName           =     "D_Box";
extern int     DarvasMode           =           3;    //Darvas Modes (See table above) 
extern int     PivotStrength        =           3;    //Pivot Strength in bars
extern int     RollingPeriod        =           1;    //Rolling period of evaluation(Classic-12 months,Modern-6 months or less) 
extern color   NeutralColor         =      Silver;
extern color   UpTrendColor         =  DodgerBlue;
extern color   DnTrendColor         =       Coral;
extern int     BoxWidth             =           2; 
extern int     BoxesMode            =           1;    //0-off,1-on
extern int     ChannelMode          =           0;    //0-off,1-on
extern int     PivotsMode           =           1;    //0-off,1-on
extern int     GhostBoxesMode       =           0;    //0-off,1-on
extern int     SignalMode           =           1;    //0-off,1-on

//---- buffers
double topBox[];
double botBox[];
double pivotHi[];
double pivotLo[];
double upSignal[];
double dnSignal[];
double trend[];

double HiArray[],LoArray[], boxTop[2], boxBottom[2], ghostHeight[2], ghostTop[2], ghostBottom[2], hiPrice[2], loPrice[2];
int    Length, startState[2], confirmState[2], prevState;
string short_name, IndicatorName, name;
datetime prevtime, startTime[2], endTime[2], ghostTime[2], prevTime, confTime, prevGhostTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(Digits); 
//---- indicator line
   IndicatorBuffers(7);
   SetIndexBuffer(0,  topBox); SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(1,  botBox); SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(2, pivotHi); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,159);
   SetIndexBuffer(3, pivotLo); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,159);
   SetIndexBuffer(4,upSignal); SetIndexStyle(4,DRAW_ARROW); SetIndexArrow(4,233);
   SetIndexBuffer(5,dnSignal); SetIndexStyle(5,DRAW_ARROW); SetIndexArrow(5,234);
   SetIndexBuffer(6,   trend);
//---- name for DataWindow and indicator subwindow label
   IndicatorName = WindowExpertName();   
   short_name = IndicatorName+"("+DarvasMode+","+PivotStrength+","+RollingPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Top of Darvas Box");
   SetIndexLabel(1,"Bottom of Darvas Box");
   SetIndexLabel(2,"Pivot High");
   SetIndexLabel(3,"Pivot Low");
//----
   Length = PivotStrength+2;
   int begin = MathMax(2,Length); 
   SetIndexDrawBegin(0,begin);
   SetIndexDrawBegin(1,begin);
   SetIndexDrawBegin(2,begin);
   SetIndexDrawBegin(3,begin);
   
//----
   ArrayResize(HiArray,Length);
   ArrayResize(LoArray,Length);

   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   deleteObj(UniqueName);
 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| DarvasBoxes_v3                                                   |
//+------------------------------------------------------------------+
int start()
{
   int  counted_bars=IndicatorCounted();
   
			
   if ( counted_bars > 0 )  int limit = Bars-counted_bars-1;
   if ( counted_bars < 0 )  return(0);
   if ( counted_bars ==0 )  limit = Bars-Length; 
     
	if ( counted_bars < 1 )
	{
      for(int i=0;i<Bars;i++)
      { 
      topBox[i]  = EMPTY_VALUE;    
      botBox[i]  = EMPTY_VALUE;
      pivotHi[i] = EMPTY_VALUE;    
      pivotLo[i] = EMPTY_VALUE;
      }
   }
	
	_DarvasBoxes(limit,counted_bars);
   
   WindowRedraw(); 
   
return(0);
}

void _DarvasBoxes(int limit,int counted_bars)
{
   
   
   for(int shift=limit;shift>=0;shift--) 
   {	
      if(prevtime != Time[shift]) 
      {
      startState[1]   = startState[0]; 
      confirmState[1] = confirmState[0]; 
      boxTop[1]       = boxTop[0];
      boxBottom[1]    = boxBottom[0];
      startTime[1]    = startTime[0];
      endTime[1]      = endTime[0];
      ghostHeight[1]  = ghostHeight[0];
      ghostTime[1]    = ghostTime[0];  
      ghostTop[1]     = ghostTop[0];
      ghostBottom[1]  = ghostBottom[0];
      hiPrice[1]      = hiPrice[0];
      loPrice[1]      = loPrice[0];
      prevtime        = Time[shift];
      } 
    
      for(int j = 0; j < Length; j++)
	   { 
      HiArray[j] = iMA(NULL,0,1,0,0,PRICE_HIGH,shift+j);
      LoArray[j] = iMA(NULL,0,1,0,0,PRICE_LOW,shift+j);
      } 
	
	double hiBoxPrice = High[shift];       
	double loBoxPrice = Low [shift];
	      
	if(DarvasMode == 0 || DarvasMode == 2 || DarvasMode == 4) {hiPrice[0] = High[shift]; loPrice[0] = Low[shift];}
	else {hiPrice[0] = Close[shift]; loPrice[0] = Close[shift];}   
	
	trend[shift]  = trend[shift+1];
	botBox[shift] = botBox[shift+1];			
	topBox[shift] = topBox[shift+1];
	   
	double upPivot = DarvasPivot(HiArray,0,PivotStrength);
	double loPivot = DarvasPivot(LoArray,1,PivotStrength);
	
      if(PivotsMode > 0)
	   {
	   pivotHi[shift+PivotStrength] = EMPTY_VALUE;
	   pivotLo[shift+PivotStrength] = EMPTY_VALUE;
	
      if(upPivot > 0) pivotHi[shift+PivotStrength] = upPivot;  
	   if(loPivot > 0) pivotLo[shift+PivotStrength] = loPivot;    
      }
	
	startState[0]   = startState[1]; 
   confirmState[0] = confirmState[1];
	boxTop[0]       = boxTop[1];
	boxBottom[0]    = boxBottom[1];
	startTime[0]    = startTime[1];
   endTime[0]      = endTime[1]; 
   ghostHeight[0]  = ghostHeight[1];
   ghostTime[0]    = ghostTime[1];  
   ghostTop[0]     = ghostTop[1];
   ghostBottom[0]  = ghostBottom[1];
  	 
   
      if(startState[0] == 0) 
      {
      bool allPivotVerify = false; 
     
      bool upPivotVerify = upPivot > 0 && shift+PivotStrength == iHighest(NULL,0,MODE_HIGH,RollingPeriod,shift+PivotStrength);    
      bool loPivotVerify = loPivot > 0 && shift+PivotStrength == iLowest (NULL,0,MODE_LOW ,RollingPeriod,shift+PivotStrength); 
   
      if(DarvasMode < 2) allPivotVerify = upPivotVerify;
      else
      if(DarvasMode < 4) {if(trend[shift] > 0) allPivotVerify = upPivotVerify; else allPivotVerify = loPivotVerify;}
      else allPivotVerify = upPivotVerify || loPivotVerify;
              
         if(allPivotVerify)
         {
         startTime[0] = Time[shift+PivotStrength];   
            if(startTime[0] >= endTime[0])
            {
               if(DarvasMode < 2) {boxTop[0] = upPivot; startState[0] = 1;}
               else
               if(DarvasMode < 4) 
               {
               startState[0] = 1; 
               if(trend[shift] > 0) boxTop[0] = upPivot; else boxBottom[0] = loPivot;
               }
               else
               {  
               if(upPivotVerify ||(upPivotVerify && loPivotVerify)) {boxTop[0] = upPivot; startState[0] = 1;}
               else {boxBottom[0] = loPivot; startState[0] =-1;}
	            }  
	      
            prevTime      = startTime[0];
            prevState     = startState[0];
            }
         } 
      }
      
      if(startState[0] != 0 && confirmState[0] == 0)
      {      
         if(DarvasMode < 2)
         {
            if(upPivot > boxTop[0] || hiBoxPrice > boxTop[0]) {startState[0] = 0; startTime[0] = 0;} 
            else
            if(loPivot > 0 && Time[shift] > startTime[0]) {confirmState[0] = 1; boxBottom[0] = loPivot; confTime = Time[shift];}
         }
         else
         if(DarvasMode < 4)
         {
            
            if(trend[shift] > 0 && (upPivot > boxTop[0] || hiBoxPrice > boxTop[0])) {startState[0] = 0; startTime[0] = 0;} 
            else 
            if(trend[shift] < 0 && ((loPivot > 0 && loPivot < boxBottom[0]) || loBoxPrice < boxBottom[0])) {startState[0] = 0; startTime[0] = 0; } 
            else
            if(Time[shift] > startTime[0])
            {
               if(trend[shift] > 0 && loPivot > 0){confirmState[0] = 1; boxBottom[0] = loPivot; confTime = Time[shift];}
               else
               if(trend[shift] < 0 && upPivot > 0){confirmState[0] = 1; boxTop[0]    = upPivot; confTime = Time[shift];}
            }
         }
         else
         {
            if(startState[0] > 0 && (upPivot > boxTop[0] || hiBoxPrice > boxTop[0])) {startState[0] = 0; startTime[0] = 0;} 
            else 
            if(startState[0] < 0 && ((loPivot > 0 && loPivot < boxBottom[0]) || loBoxPrice < boxBottom[0])) {startState[0] = 0; startTime[0] = 0;} 
            else
            if(Time[shift] > startTime[0])
            {
               if(startState[0] > 0 && loPivot > 0 && confirmState[0] == 0){confirmState[0] = 1; boxBottom[0] = loPivot; confTime = Time[shift];}
               else
               if(startState[0] < 0 && upPivot > 0 && confirmState[0] == 0){confirmState[0] = 1; boxTop[0]    = upPivot; confTime = Time[shift];}
            }
         }
      }
      else 
      if(startState[0] != 0 && confirmState[0] != 0)
	   {  
         if(BoxesMode > 0) 
         {
         name = UniqueName + " " + TimeToStr(startTime[0]);
         DeleteBox(name);
         
            if(DarvasMode < 2) PlotBox(name,startTime[0],boxTop[0],Time[shift],boxBottom[0],STYLE_SOLID,NeutralColor,BoxWidth,0);
            else
            if(DarvasMode < 4)
            {
               if(trend[shift] > 0) PlotBox(name,startTime[0],boxTop[0],Time[shift],boxBottom[0],STYLE_SOLID,NeutralColor,BoxWidth,0);
               else
               if(trend[shift] < 0) PlotBox(name,startTime[0],boxBottom[0],Time[shift],boxTop[0],STYLE_SOLID,NeutralColor,BoxWidth,0);
            }
            else
            {
               if(startState[0] > 0) PlotBox(name,startTime[0],boxTop[0],Time[shift],boxBottom[0],STYLE_SOLID,NeutralColor,BoxWidth,0);
               else
               if(startState[0] < 0) PlotBox(name,startTime[0],boxBottom[0],Time[shift],boxTop[0],STYLE_SOLID,NeutralColor,BoxWidth,0);
            }
         }
  
      upSignal[shift] = EMPTY_VALUE;
      dnSignal[shift] = EMPTY_VALUE;      
      
      double gap = 0.5*MathCeil(iATR(NULL,0,14,shift)/Point);
         
         if(hiPrice[0] > boxTop[0]) 
         {
         trend[shift]    = 1; 
         startState[0]   = 0; 
         confirmState[0] = 0; 
         endTime[0]      = Time[shift]; 
         startTime[0]    = 0;
         if(SignalMode > 0) upSignal[shift] = Low [shift] - gap*Point;
         }
	   
         if(loPrice[0] < boxBottom[0]) 
         {
         trend[shift]    =-1; 
         startState[0]   = 0; 
         confirmState[0] = 0; 
         endTime[0]      = Time[shift]; 
         startTime[0]    = 0;
         if(SignalMode > 0) dnSignal[shift] = High[shift] + gap*Point; 
         }

	   if(ChannelMode > 0) {botBox[shift] = boxBottom[0]; topBox[shift] = boxTop[0];}  

         if(endTime[0] != endTime[1]) 
         {
            if(BoxesMode > 0) 
            {
            DeleteBox(name);
               if(trend[shift] > 0) 
               {
               PlotBox(name,prevTime,boxTop[0],endTime[0],boxBottom[0],STYLE_SOLID,UpTrendColor,BoxWidth,0);   
               PlotBox(name,prevTime,boxTop[0],endTime[0],boxBottom[0],STYLE_SOLID,UpTrendColor,BoxWidth,1);
               }
               else
               if(trend[shift] < 0)
               {
                  if(DarvasMode < 2)
                  {
                  PlotBox(name,prevTime,boxTop[0],endTime[0],boxBottom[0],STYLE_SOLID,DnTrendColor,BoxWidth,0);
                  PlotBox(name,prevTime,boxTop[0],endTime[0],boxBottom[0],STYLE_SOLID,DnTrendColor,BoxWidth,1);
                  }
                  else
                  {
                  PlotBox(name,prevTime,boxBottom[0],endTime[0],boxTop[0],STYLE_SOLID,DnTrendColor,BoxWidth,0);
                  PlotBox(name,prevTime,boxBottom[0],endTime[0],boxTop[0],STYLE_SOLID,DnTrendColor,BoxWidth,1);  
                  }
               }
            }
            
            if(GhostBoxesMode > 0)
            {
            ghostTime[0]   = endTime[0];
            ghostHeight[0] = boxTop[0] - boxBottom[0];
            prevGhostTime  = ghostTime[0];
            
               if(trend[shift] > 0)
               { 
               ghostBottom[0] = boxTop[0];
               ghostTop[0]    = ghostBottom[0] + ghostHeight[0];
               }
               else
               {
               ghostTop[0]    = boxBottom[0];
               ghostBottom[0] = ghostTop[0] - ghostHeight[0];    
               }
            } 
         }
      }
      else if(prevState > 0 && prevTime > 0 && confTime == Time[shift]) DeleteBox(UniqueName+" "+TimeToStr(prevTime));

           
      if(GhostBoxesMode > 0)
      {
         if(trend[shift] > 0)
         {
         string gname = UniqueName+" Ghost "+TimeToStr(ghostTime[0]);
            
            if(confirmState[0] == 0 || (confirmState[0] > 0 && confirmState[1] == 0)) 
            {
            DeleteBox(gname);
            PlotBox(gname,ghostTime[0],ghostTop[0],Time[shift],ghostBottom[0],STYLE_DOT,UpTrendColor,1,0);
            
            if(hiPrice[0] <= ghostTop[0] && ghostTime[0] == Time[shift]) DeleteBox(UniqueName+" Ghost "+TimeToStr(prevGhostTime)); 
               
               if(hiPrice[0] > ghostTop[0] && hiPrice[1] <= ghostTop[1]) 
               {
               PlotBox(gname,ghostTime[0],ghostTop[0],Time[shift],ghostBottom[0],STYLE_DOT,UpTrendColor,1,1);
               
               ghostTime[0]   = Time[shift];
               ghostBottom[0] = ghostTop[0]; 
               ghostTop[0]    = ghostBottom[0] + ghostHeight[0];
               prevGhostTime  = ghostTime[0];
               }
            }
      
            if(confirmState[0] > 0) 
            {
            
            PlotBox(gname,ghostTime[0],ghostTop[0],Time[shift],ghostBottom[0],STYLE_DOT,UpTrendColor,1,1);  
            }
         }
         else
         {
         gname = UniqueName+" Ghost "+TimeToStr(ghostTime[0]);
            
            if(confirmState[0] == 0 || (confirmState[0] > 0 && confirmState[1] == 0)) 
            {
            DeleteBox(gname);
            PlotBox(gname,ghostTime[0],ghostTop[0],Time[shift],ghostBottom[0],STYLE_DOT,DnTrendColor,1,0);
            
            if(loPrice[0] >= ghostBottom[0] && ghostTime[0] == Time[shift]) DeleteBox(UniqueName+" Ghost "+TimeToStr(prevGhostTime)); 
               
               if(loPrice[0] < ghostBottom[0] && loPrice[1] >= ghostBottom[1]) 
               {
               PlotBox(gname,ghostTime[0],ghostTop[0],Time[shift],ghostBottom[0],STYLE_DOT,DnTrendColor,1,1);
               
               ghostTime[0]   = Time[shift];
               ghostTop[0]    = ghostBottom[0]; 
               ghostBottom[0] = ghostTop[0] - ghostHeight[0];
               prevGhostTime  = ghostTime[0];
               }
            }
      
            if(confirmState[0] > 0) 
            {
            
            PlotBox(gname,ghostTime[0],ghostTop[0],Time[shift],ghostBottom[0],STYLE_DOT,DnTrendColor,1,1);  
            }
         }
      }
	}
}


double DarvasPivot(double& price[],int type,int size)
{
  
	double upPivot;
	
	if (type==0) bool condition = ArrayMaximum(price,0,0) == size;
   else condition = ArrayMinimum(price,0,0) == size;
      
   if(condition) upPivot = price[size]; else upPivot=0; 
	
return(upPivot);	
}  

//+------------------------------------------------------------------+


void PlotBox(string tname,datetime time1,double value1, datetime time2,double value2,int style,color clr,double width,int mode)
{   
   
   if(mode == 0)
   {
   ObjectCreate(tname+" 1H",OBJ_TREND,0,time1,value1,time2,value1);
   ObjectSet(tname+" 1H",OBJPROP_COLOR,clr);
   ObjectSet(tname+" 1H",OBJPROP_STYLE,style);
   ObjectSet(tname+" 1H",OBJPROP_RAY,false);
   ObjectSet(tname+" 1H",OBJPROP_BACK,true);
   ObjectSet(tname+" 1H",OBJPROP_WIDTH,width);
 
   ObjectCreate(tname+" 1V",OBJ_TREND,0,time1,value1,time1,value2);
   ObjectSet(tname+" 1V",OBJPROP_COLOR,clr);
   ObjectSet(tname+" 1V",OBJPROP_STYLE,style);
   ObjectSet(tname+" 1V",OBJPROP_RAY,false);
   ObjectSet(tname+" 1V",OBJPROP_BACK,true);
   ObjectSet(tname+" 1V",OBJPROP_WIDTH,width);
  
   ObjectCreate(tname+" 2H",OBJ_TREND,0,time1,value2,time2,value2);
   ObjectSet(tname+" 2H",OBJPROP_COLOR,clr);
   ObjectSet(tname+" 2H",OBJPROP_STYLE,style);
   ObjectSet(tname+" 2H",OBJPROP_RAY,false);
   ObjectSet(tname+" 2H",OBJPROP_BACK,true);
   ObjectSet(tname+" 2H",OBJPROP_WIDTH,width);
   }
  
   if(mode == 1)
   {
   ObjectCreate(tname+" 2V",OBJ_TREND,0,time2,value1,time2,value2);
   ObjectSet(tname+" 2V",OBJPROP_COLOR,clr);
   ObjectSet(tname+" 2V",OBJPROP_STYLE,style);
   ObjectSet(tname+" 2V",OBJPROP_RAY,false);
   ObjectSet(tname+" 2V",OBJPROP_BACK,true);
   ObjectSet(tname+" 2V",OBJPROP_WIDTH,width);
   }
}	

void DeleteBox(string tname)
{
   ObjectDelete(tname+" 1H"); 
   ObjectDelete(tname+" 2H");
   ObjectDelete(tname+" 1V"); 
   ObjectDelete(tname+" 2V");
}

bool deleteObj(string tname)
{
   bool result = false;
   
   int length = StringLen(tname);
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
   string objName = ObjectName(i); 
   if(StringSubstr(objName,0,length) == tname) {ObjectDelete(objName); result = true;}
   }
   
   return(result);
}

