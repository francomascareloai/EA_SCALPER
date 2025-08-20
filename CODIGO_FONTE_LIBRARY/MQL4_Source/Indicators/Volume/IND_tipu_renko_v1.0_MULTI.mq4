//+------------------------------------------------------------------+
//|                                                   Tipu Renko.mq4 |
//|                                    Copyright 2016, Kaleem Haider |
//|                      https://www.mql5.com/en/users/kaleem.haider |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Kaleem Haider"
#property link      "https://www.mql5.com/en/users/kaleem.haider"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define PipsPoint Get_PipsPoint()
//Enumerations for Renko Mode
enum ENUM_RenkoMode
  {
   rClose = 0,       //Close
   rHighLow = 1,     //High/Low
  };
//Enumeration for type of marks
enum ENUM_RenkoMark
  {
   None=0,
   Brick=1,
   Arrows=2,
  };

input ENUM_RenkoMode eRenkoMode        =  0;              //Box Mode
input ENUM_RenkoMark eRenkoMark        =  1;              //Renko Mark
input int            iRenkoSize        =  20;             //Reko Size
input ENUM_LINE_STYLE eRenkoStyle      =  0;              //Line Style
input int            iRenkoWidth       =  1;              //Line Width
input color          cUpCandle         =  C'31,159,192';  //Up Color
input color          cDwnCandle        =  C'230,77,69';   //Down Color
input bool           bFill             =  true;           //Fill Candles
input bool           bAlertM           =  false;          //Alert Mobile
input bool           bAlertS           =  true;           //Alert Onscreen
input bool           bAlertE           =  false;          //Alert Email

string short_name="tp_Renko";
string indicator_name="Tipu Renko";
int iLastTrend;
double dLowR=0,dHighR=0,dOpenR=0,dCloseR=0;
datetime dtPrevTime=0;
static datetime prevTime;
double dBuyCounter=0.0,dSellCounter=0.0;

double dTrendBuffer[],dSignalBuffer[],dBuyCountBuffer[],dSellCountBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   int n=0;
//--- indicator buffers mapping
   IndicatorSetString(INDICATOR_SHORTNAME,indicator_name);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorBuffers(4);

//Holder for the signals, and trend
   SetIndexBuffer(n,dSignalBuffer,INDICATOR_CALCULATIONS); n++;
   SetIndexBuffer(n,dTrendBuffer,INDICATOR_CALCULATIONS);  n++;
   SetIndexBuffer(n,dBuyCountBuffer,INDICATOR_CALCULATIONS); n++;
   SetIndexBuffer(n,dSellCountBuffer,INDICATOR_CALCULATIONS); n++;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//Delete the Bricks
   DeleteBricks();
  }
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
//---
   int limit;
   string sMsg,sSubject;
   bool bBuy=false,bSell=false;

   ArraySetAsSeries(dTrendBuffer,true);
   ArraySetAsSeries(dSignalBuffer,true);
   ArraySetAsSeries(dBuyCountBuffer,true);
   ArraySetAsSeries(dSellCountBuffer,true);

   if(prev_calculated < 0)  return(0);

   if(prev_calculated>0) limit=rates_total-prev_calculated+1; //non-repainting should give -2 if prev_cal is 0, meaning two candles ahead
   else
     {
      limit=rates_total-1;
      dLowR  = low[limit];
      dOpenR = open[limit];
      dtPrevTime=time[limit];
     }

   for(int i=limit-1; i>=0; i--)
     {
      double dcheck=iRenkoSize*PipsPoint;
      switch(eRenkoMode)
        {
         case 0:
            bBuy=close[i]>=dOpenR+dcheck;
            bSell=close[i]<=dOpenR-dcheck;
            break;

         case 1:
            bBuy=high[i]>=dOpenR+dcheck;
            bSell=low[i]<=dOpenR-dcheck;
            break;
        }

      if(bBuy)
        {
         dCloseR=NormalizeDouble(dOpenR,_Digits)+dcheck;
         if(ObjectFind(0,short_name+(string)time[i])<0 && eRenkoMark==1)
            RectangleCreate(0,short_name+(string)time[i],0,dtPrevTime,dOpenR,time[i],dCloseR,cUpCandle,eRenkoStyle,iRenkoWidth,bFill,false,false,false,0);
         dOpenR=dCloseR;
         dtPrevTime=time[i];
         dSellCounter=0; dSellCountBuffer[i]=dSellCounter;
         if(dTrendBuffer[i+1]!=OP_BUY)
           {
            dSignalBuffer[i]=OP_BUY;
            dTrendBuffer[i]=dSignalBuffer[i];
            dBuyCounter=1;  dBuyCountBuffer[i]=dBuyCounter;
            if(ObjectFind(0,short_name+(string)time[i])<0 && eRenkoMark==2)
               ArrowCreate(0,short_name+(string)time[i],0,time[i],low[i],233,ANCHOR_TOP,cUpCandle,eRenkoStyle,iRenkoWidth,false,false,false);
           }
         else
           {dBuyCounter++;     dBuyCountBuffer[i]=dBuyCounter;}
        }
      if(bSell)
        {
         dCloseR=NormalizeDouble(dOpenR,_Digits)-dcheck;
         if(ObjectFind(0,short_name+(string)time[i])<0 && eRenkoMark==1)
            RectangleCreate(0,short_name+(string)time[i],0,dtPrevTime,dOpenR,time[i],dCloseR,cDwnCandle,eRenkoStyle,iRenkoWidth,bFill,false,false,false,0);
         dOpenR=dCloseR;
         dtPrevTime=time[i];
         dBuyCounter=0;  dBuyCountBuffer[i]=dBuyCounter;
         if(dTrendBuffer[i+1]!=OP_SELL)
           {
            dSignalBuffer[i]=OP_SELL;
            dTrendBuffer[i]=dSignalBuffer[i];
            dSellCounter=1; dSellCountBuffer[i]=dSellCounter;
            if(ObjectFind(0,short_name+(string)time[i])<0 && eRenkoMark==2)
               ArrowCreate(0,short_name+(string)time[i],0,time[i],high[i],234,ANCHOR_BOTTOM,cDwnCandle,eRenkoStyle,iRenkoWidth,false,false,false);
           }
         else
           {dSellCounter++;   dSellCountBuffer[i]=dSellCounter;}
        }

      if(dTrendBuffer[i]!=OP_BUY && dTrendBuffer[i]!=OP_SELL)
         dTrendBuffer[i]=dTrendBuffer[i+1];
      if(dBuyCountBuffer[i] == EMPTY_VALUE)
         dBuyCountBuffer[i] = dBuyCountBuffer[i+1];
      if(dSellCountBuffer[i] == EMPTY_VALUE)
         dSellCountBuffer[i] = dSellCountBuffer[i+1];
     }
//Alerts
   if(dSignalBuffer[0]==OP_BUY)
     {
      sMsg=indicator_name+" "+_Symbol+"\n "+"Buy Alert: "+
           "\n "+"Time: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
      sSubject=indicator_name+" "+_Symbol+" "+"Buy Alert";
      SendAlert(bAlertM,bAlertS,bAlertE,sMsg,sSubject);
      dTrendBuffer[0]=OP_BUY;
     }
   if(dSignalBuffer[0]==OP_SELL)
     {
      sMsg=indicator_name+" "+_Symbol+"\n "+"Sell Alert: "
           +"\n "+"Time: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
      sSubject=indicator_name+" "+_Symbol+" "+"Sell Alert";
      SendAlert(bAlertM,bAlertS,bAlertE,sMsg,sSubject);
      dTrendBuffer[0]=OP_SELL;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double Get_PipsPoint()
  {
   double PP=(_Digits==5 || _Digits==3)?_Point*10:_Point;
   return (PP);
  }
//+------------------------------------------------------------------------------+
//| The following code is taken from:                                            |
//| https://docs.mql4.com/constants/objectconstants/enum_object/obj_rectangle    |
//+------------------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="Rectangle",  // rectangle name
                     const int             sub_window=0,      // subwindow index 
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price
                     const color           clr=clrRed,        // rectangle color
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            back=false,        // in the background
                     const bool            selection=true,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0,         // priority for mouse click
                     const string          tooltip="Rectangle",// tooltip
                     const int             timeframes=OBJ_ALL_PERIODS) //show on timeframes)
  {

   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Name: "+name+" Error code = ",GetLastError());
      return(false);
     }

   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(chart_ID,name,OBJPROP_TIMEFRAMES,timeframes);

//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------------------+
//| The following code is taken from:                                            |
//| https://docs.mql4.com/constants/objectconstants/enum_object/obj_arrow        |
//+------------------------------------------------------------------------------+
bool ArrowCreate(const long              chart_ID=0,           // chart's ID
                 const string            name="Arrow",         // arrow name
                 const int               sub_window=0,         // subwindow index
                 datetime                time=0,               // anchor point time
                 double                  price=0,              // anchor point price
                 const uchar             arrow_code=252,       // arrow code
                 const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor point position
                 const color             clr=clrRed,           // arrow color
                 const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                 const int               width=3,              // arrow size
                 const bool              back=false,           // in the background
                 const bool              selection=true,       // highlight to move
                 const bool              hidden=true,          // hidden in the object list
                 const long              z_order=0,            // priority for mouse click
                 const string            tooltip="Rectangle",// tooltip
                 const int                timeframes=OBJ_ALL_PERIODS) //show on timeframes)                 
  {

//--- reset the error value
   ResetLastError();
//--- create an arrow
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,arrow_code);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(chart_ID,name,OBJPROP_TIMEFRAMES,timeframes);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|Delete Bricks                                                     |
//+------------------------------------------------------------------+
void DeleteBricks()
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string name=ObjectName(i);
      if(StringFind(name,short_name,0)>=0) ObjectDelete(0,name);
     }

   return;
  }
//+------------------------------------------------------------------+
//| Send Alerts                                                      |
//+------------------------------------------------------------------+
void SendAlert(bool bMobile,bool bScreen,bool bEmail,string sMsg,string sSub)
  {
   if(bMobile || bScreen || bEmail)
     {
      if(sMsg!="")
        {
         if(prevTime<iTime(_Symbol,_Period,0))
           {
            prevTime=iTime(_Symbol,_Period,0);
            if(bMobile) SendNotification(sSub);
            if(bScreen) Alert(sSub);
            if(bEmail) SendMail(sSub,sMsg);
           }
        }
     }
  }
//+------------------------------------------------------------------+
