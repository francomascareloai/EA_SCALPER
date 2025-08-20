//+------------------------------------------------------------------+
//|                                                   ChannelInd.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Red

extern int StartHour=1;
extern int EndHour=10;
extern int FontSize=15;
extern color TextColor=Yellow;

double UpperCh[], LowerCh[];

int init()
  {
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,UpperCh);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,LowerCh);

   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll();
   return(0);
  }
  
int start()
  {
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>0)
     {
      datetime EndTime=StrToTime(TimeToStr(Time[pos],TIME_DATE)+" "+DoubleToStr(EndHour,0)+":00");
      if (Time[pos]>=EndTime && Time[pos+1]<EndTime)
      {
       double MaxPrice=High[pos];
       double MinPrice=Low[pos];
       datetime StartTime=StrToTime(TimeToStr(Time[pos],TIME_DATE)+" "+DoubleToStr(StartHour,0)+":00");
       if (StartHour>EndHour) StartTime=StartTime-86400;
       int pos_=pos;
       while (pos_<Bars && Time[pos_]>=StartTime)
       {
        MinPrice=MathMin(MinPrice, Low[pos_]);
        MaxPrice=MathMax(MaxPrice, High[pos_]);
        pos_++;
       }
       int i;
       for (i=pos_-1;i>=pos;i--)
       {
        UpperCh[i]=MaxPrice;
        LowerCh[i]=MinPrice;
       }
       if (pos!=pos_-1)
       {
        string ObjName="ChannelSizeLabel "+TimeToStr(Time[pos],TIME_DATE);
        string LabelText=""+DoubleToStr((MaxPrice-MinPrice)/Point,0);
        if (ObjectFind(ObjName)==-1)
        {
         ObjectCreate(ObjName, OBJ_TEXT, 0, Time[pos], MinPrice);
        }
        else
        {
         ObjectSet(ObjName,OBJPROP_PRICE1,MinPrice);
        } 
        ObjectSetText(ObjName, LabelText, FontSize, "Times New Roman", TextColor);
       } 
      }
      else
      {
       UpperCh[pos]=EMPTY_VALUE;
       LowerCh[pos]=EMPTY_VALUE;
      }
      pos--;
     }

   return(0);
  }

