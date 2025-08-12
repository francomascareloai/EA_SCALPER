//+------------------------------------------------------------------+
//|                                              StochWithPoints.mq4 |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright "*"
#property link      "*"

#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    12
#property indicator_color6     clrYellow
#property indicator_width6     1
#property indicator_color7     clrYellow
#property indicator_width7     1
#property indicator_color8     clrYellow
#property indicator_width8     1
#property indicator_color9     clrRed
#property indicator_width9     1
#property indicator_color10    clrLime
#property indicator_width10    1
#property indicator_color11    clrRed
#property indicator_style11    STYLE_DOT
#property indicator_color12    clrLime
#property indicator_style12    STYLE_DOT


extern ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT;    // Time frame
extern int             K                = 14;//5;
extern int             D                = 3;
extern int             S                = 8;//3;
extern ENUM_MA_METHOD  Method           = MODE_SMA;
extern ENUM_STO_PRICE  Price            = STO_CLOSECLOSE;
extern int             MainHP           = 3;
extern int             SignalHP         = 3;
extern double          levOs            = 30;
extern double          levOb            = 70;
extern color           BearColor        = clrOrange;
extern color           BullColor        = clrLimeGreen;
extern color           NeutColor        = clrLightSteelBlue;
extern int             lineWidth        = 3;
input bool             ArrowsOnFirst    = true;
input bool             arrowsVisible    = false;             // Arrows visible true/false?
input bool             arrowsOnNewest   = false;             // Arrows drawn on newest bar of higher time frame bar true/false?
input string           arrowsIdentifier = "sto Arrows1";     // Unique ID for arrows
input double           arrowsUpperGap   = 0.5;               // Upper arrow gap
input double           arrowsLowerGap   = 0.5;               // Lower arrow gap
input color            arrowsUpColor    = clrBlue;           // Up arrow color
input color            arrowsDnColor    = clrCrimson;        // Down arrow color
input int              arrowsUpCode     = 116;               // Up arrow code
input int              arrowsDnCode     = 116;               // Down arrow code
input int              arrowsUpSize     = 2;                 // Up arrow size
input int              arrowsDnSize     = 2;                 // Down arrow size
input bool             Interpolate     = true;              // Interpolate in mtf mode?

//---- buffers
double ExtMapBuffer1[],ExtMapBuffer2[],ExtMapBuffer3[],ExtMapBuffer4[],ExtMapBuffer5[],ExtMapBuffer6[],trend[],stoUpa[],stoUpb[],stoDna[],stoDnb[],upVal[],dnVal[],count[];
string indicatorFileName,indicatorName,labelNames;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,K,D,S,Method,Price,MainHP,SignalHP,levOs,levOb,BearColor,BullColor,NeutColor,lineWidth,arrowsVisible,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,_buff,_ind)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(14);
   SetIndexBuffer(0,ExtMapBuffer1);  SetIndexStyle(0,DRAW_LINE,EMPTY,lineWidth,NeutColor);
   SetIndexBuffer(1,stoUpa);         SetIndexStyle(1,DRAW_LINE,EMPTY,lineWidth,BullColor);
   SetIndexBuffer(2,stoUpb);         SetIndexStyle(2,DRAW_LINE,EMPTY,lineWidth,BullColor);
   SetIndexBuffer(3,stoDna);         SetIndexStyle(3,DRAW_LINE,EMPTY,lineWidth,BearColor);
   SetIndexBuffer(4,stoDnb);         SetIndexStyle(4,DRAW_LINE,EMPTY,lineWidth,BearColor);
   SetIndexBuffer(5,ExtMapBuffer2);  SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(6,ExtMapBuffer3);  SetIndexStyle(6,DRAW_ARROW); SetIndexArrow(6,159);
   SetIndexBuffer(7,ExtMapBuffer4);  SetIndexStyle(7,DRAW_ARROW); SetIndexArrow(7,159);
   SetIndexBuffer(8,ExtMapBuffer5);  SetIndexStyle(8,DRAW_ARROW); SetIndexArrow(8,234);//(4,159);
   SetIndexBuffer(9,ExtMapBuffer6);  SetIndexStyle(9,DRAW_ARROW); SetIndexArrow(9,233);//(5,159);
   SetIndexBuffer(10,upVal);         SetIndexStyle(10,DRAW_LINE);                               
   SetIndexBuffer(11,dnVal);         SetIndexStyle(11,DRAW_LINE);        
   SetIndexBuffer(12,trend);
   SetIndexBuffer(13,count);
   
    indicatorFileName = WindowExpertName();
    TimeFrame         = fmax(TimeFrame,_Period); 
    
    IndicatorShortName(timeFrameToString(TimeFrame)+" S_p");
return(0);
}
void OnDeinit(const int reason)  { ObjectsDeleteAll(0,arrowsIdentifier+":"); }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int i,limit=MathMin(MathMax(Bars-counted_bars,MathMax(MainHP,SignalHP)*2+1),Bars-1); count[0]=limit;
           if (TimeFrame!=_Period)
           {
               if (trend[limit]== 1) CleanPoint(limit,rates_total,stoUpa,stoUpb);
               if (trend[limit]==-1) CleanPoint(limit,rates_total,stoDna,stoDnb); 
               limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(13,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,time[i]);
                  int x = y;
                  if (ArrowsOnFirst)
                        {  if (i<rates_total-1) x = iBarShift(NULL,TimeFrame,time[i+1]);               }
                  else  {  if (i>0)             x = iBarShift(NULL,TimeFrame,time[i-1]); else x = -1;  }
                     ExtMapBuffer1[i] = _mtfCall(0,y);
                     ExtMapBuffer2[i] = _mtfCall(5,y);
                     trend[i]         = _mtfCall(12,y);
                     upVal[i]         = levOb;
                     dnVal[i]         = levOs;
                     stoUpa[i]        = stoUpb[i] = EMPTY_VALUE;
                     stoDna[i]        = stoDnb[i] = EMPTY_VALUE;
                     ExtMapBuffer3[i] = ExtMapBuffer4[i] = EMPTY_VALUE;
                     ExtMapBuffer5[i] = ExtMapBuffer6[i] = EMPTY_VALUE;
                     if (x!=y)
                     {
                       ExtMapBuffer3[i] = _mtfCall(6,y);
                       ExtMapBuffer4[i] = _mtfCall(7,y);
                       ExtMapBuffer5[i] = _mtfCall(8,y);
                       ExtMapBuffer6[i] = _mtfCall(9,y);
                     }
                 
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime itime = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<rates_total && time[i+n] >= itime; n++) continue;	
                           for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++)  
                           {
                              _interpolate(ExtMapBuffer1);
                              _interpolate(ExtMapBuffer2);  
                           }                   
              }
              for(i=limit;i>=0;i--)
              {
                 if (trend[i] == 1) PlotPoint(i,rates_total,stoUpa,stoUpb,ExtMapBuffer1);
                 if (trend[i] ==-1) PlotPoint(i,rates_total,stoDna,stoDnb,ExtMapBuffer1);   
              }        
     return(rates_total);
     }

      //
      //
      //
      //
      //
      
      if (trend[limit]== 1) CleanPoint(limit,rates_total,stoUpa,stoUpb);
      if (trend[limit]==-1) CleanPoint(limit,rates_total,stoDna,stoDnb); 
      for(i=limit;i>=0;i--)
      {
         ExtMapBuffer1[i]=iStochastic(NULL,0,K,D,S,Method,Price,0,i);
         ExtMapBuffer2[i]=iStochastic(NULL,0,K,D,S,Method,Price,1,i);         
         ExtMapBuffer3[i+MainHP]   = EMPTY_VALUE;
         ExtMapBuffer4[i+MainHP]   = EMPTY_VALUE;
         ExtMapBuffer5[i+SignalHP] = EMPTY_VALUE;
         ExtMapBuffer6[i+SignalHP] = EMPTY_VALUE;
         if(ArrayMaximum(ExtMapBuffer1,MainHP*2+1,i)==i+MainHP)
         ExtMapBuffer3[i+MainHP]=ExtMapBuffer1[i+MainHP];
         if(ArrayMinimum(ExtMapBuffer1,MainHP*2+1,i)==i+MainHP)
         ExtMapBuffer4[i+MainHP]=ExtMapBuffer1[i+MainHP];     
         
         if(ArrayMaximum(ExtMapBuffer2,SignalHP*2+1,i)==i+SignalHP)
         ExtMapBuffer5[i+SignalHP]=ExtMapBuffer2[i+SignalHP];
         if(ArrayMinimum(ExtMapBuffer2,SignalHP*2+1,i)==i+SignalHP)
         ExtMapBuffer6[i+SignalHP]=ExtMapBuffer2[i+SignalHP];
         upVal[i]  = levOb;
         dnVal[i]  = levOs;
         stoUpa[i] = stoUpb[i] = EMPTY_VALUE;
         stoDna[i] = stoDnb[i] = EMPTY_VALUE;
         trend[i] = (i<Bars-1) ? (ExtMapBuffer1[i]>upVal[i])                                ? -2 : 
                                 (ExtMapBuffer1[i]<dnVal[i])                                ?  2 : 
                                 (ExtMapBuffer1[i]<upVal[i] && ExtMapBuffer1[i+1]>upVal[i]) ? -1 : 
                                 (ExtMapBuffer1[i]>dnVal[i] && ExtMapBuffer1[i+1]<dnVal[i]) ?  1 : trend[i+1] : 0;  
         
         if (trend[i] == 1) PlotPoint(i,rates_total,stoUpa,stoUpb,ExtMapBuffer1);
         if (trend[i] ==-1) PlotPoint(i,rates_total,stoDna,stoDnb,ExtMapBuffer1);   
                        
         //
         //
         //
      
         if (arrowsVisible)
         {
           string lookFor = arrowsIdentifier+":"+(string)time[i]; if (ObjectFind(0,lookFor)==0) ObjectDelete(0,lookFor);       
           if (i<(rates_total-1) && trend[i] != trend[i+1])
           {
             if (trend[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
             if (trend[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
           }
      }     
   }
return(rates_total);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------

void drawArrow(int i,color theColor,int theCode, int theSize, bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      
      datetime atime = Time[i]; if (arrowsOnNewest) atime += PeriodSeconds(_Period)-1;      
      ObjectCreate(name,OBJ_ARROW,0,atime,0);
         ObjectSetInteger(0,name,OBJPROP_ARROWCODE,theCode);
         ObjectSetInteger(0,name,OBJPROP_WIDTH,    theSize);
         ObjectSetInteger(0,name,OBJPROP_COLOR,    theColor);
         if (up)
               ObjectSetDouble(0,name,OBJPROP_PRICE1,0,High[i] + arrowsUpperGap * gap);
         else  ObjectSetDouble(0,name,OBJPROP_PRICE1,0,Low[i]  - arrowsLowerGap * gap);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------

void CleanPoint(int i,int bars,double& first[],double& second[])
{
   if (i>=bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,int bars,double& first[],double& second[],double& from[])
{
   if (i>=bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}

//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
