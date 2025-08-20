//////////////////////////////////////////////////////////////////////////////
/////////////////////////// Large TimeFrame TT ///////////////////////////////
//////////////////////////////////////////////////////////////////////////////

#property copyright "Copyright ©  16 november 2015, http://forexsystems.ru/" 
#property link "http://forexsystemsru.com/indikatory-foreks-f41/" 
#property description "Построение на графике свечей старшего таймфрейма" 

#property indicator_chart_window

//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

extern ENUM_TIMEFRAMES TimeFrame  =  PERIOD_H4;
extern int             CountBars  =  10;
extern color           Bear       =  Maroon,         // C'70,7,45' // C'75,5,20'
                       BearWicks  =  Maroon,
                       Bull       =  MidnightBlue,   // C'0,50,50' // C'0,35,60'
                       BullWicks  =  MidnightBlue;
                       
extern string           comment   =  "LargeTF";


//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

   datetime time1;
   datetime time2;
   double open_price,close_price;
   int bar_tf;
   int PeriodName=0;
   int num=0;
   string error="Параметр TimeFrame задан не верно \nПример: для часового графика выберите параметр D1";
//+--------------------------------------------------------------------------+
//+                                                                          +
//+--------------------------------------------------------------------------+

   void ObjDel()
  {
   for(;num>=0;num--)
      ObjectDelete(comment+num);
  }
//+--------------------------------------------------------------------------+
//+           Построение на графике свечей старшего таймфрейма               +
//+--------------------------------------------------------------------------+

int init()
  {
   if (TimeFrame==PERIOD_M1) PeriodName=PERIOD_M1; //в том же порядке, что и кнопки на панели
   else
      if (TimeFrame==PERIOD_M5) PeriodName=PERIOD_M5;
      else
         if (TimeFrame==PERIOD_M15)PeriodName=PERIOD_M15;
         else
            if (TimeFrame==PERIOD_M30)PeriodName=PERIOD_M30;
            else
               if (TimeFrame==PERIOD_H1) PeriodName=PERIOD_H1;
               else
                  if (TimeFrame==PERIOD_H4) PeriodName=PERIOD_H4;
                  else
                     if (TimeFrame==PERIOD_D1) PeriodName=PERIOD_D1;
                     else
                        if (TimeFrame==PERIOD_W1) PeriodName=PERIOD_W1;
                        else
                           if (TimeFrame==PERIOD_MN1) PeriodName=PERIOD_MN1;
                           else
                             {
                              Comment(error);
                              return(0);
                             }
   Comment("Large TimeFrame [",TimeFrame,"]");
   return(0);
  }
//+--------------------------------------------------------------------------+
//+                                                                          +
//+--------------------------------------------------------------------------+

int deinit()
  {
   ObjDel();
   Comment("");
   return(0);
  }
//+--------------------------------------------------------------------------+
//+                                                                          +
//+--------------------------------------------------------------------------+

int start()
  {
   int i;
   ObjDel();
   num=0;
//////////////////////////////////////////////////////////////////////////////

   if (PeriodName<=Period())
     {
      Comment(error);
      return(0);
     }
//////////////////////////////////////////////////////////////////////////////

   for(bar_tf=CountBars;bar_tf>=0;bar_tf--)
     {
      time1=iTime(NULL,PeriodName,bar_tf);
      i=bar_tf-1;
      if (i<0)
         time2=Time[0];
      else
         time2=iTime(NULL,PeriodName,i)-Period()*60;
      open_price=iOpen(NULL,PeriodName,bar_tf);
      close_price=iClose(NULL,PeriodName,bar_tf);
//////////////////////////////////////////////////////////////////////////////

      ObjectCreate(comment+num,OBJ_RECTANGLE,0,time1,open_price,time2,close_price);
      if (time2-time1<PeriodName*60/2)
         time2=Time[0];
      else
         time2=time1+PeriodName*60/2;
      num++;
//////////////////////////////////////////////////////////////////////////////

      ObjectCreate(comment+num,OBJ_TREND,0,time2,iHigh(NULL,PeriodName,bar_tf),time2,iLow(NULL,PeriodName,bar_tf));
      ObjectSet(comment+num, OBJPROP_WIDTH, 2);
      ObjectSet(comment+num, OBJPROP_RAY, false);
      ObjectSet(comment+num, OBJPROP_BACK, true);
//////////////////////////////////////////////////////////////////////////////

      if (close_price>open_price)
        {
         ObjectSet(comment+(num-1),OBJPROP_COLOR, Bull);
         ObjectSet(comment+num,OBJPROP_COLOR, BullWicks);
        }
      else
        {
         ObjectSet(comment+(num-1),OBJPROP_COLOR, Bear);
         ObjectSet(comment+num,OBJPROP_COLOR, BearWicks);
        }
      num++;
     }
   return(0);
  }
  
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//+--------------------------------------------------------------------------+
//+                                                       LargeTimeFrame.mq4 +
//+--------------------------------------------------------------------------+
//+         Построение на графике свечей старшего таймфрейма                 +
//+--------------------------------------------------------------------------+
//#property copyright "Copyright © 2005, Miramaxx."
//#property link "mailto: morrr2001[dog]mail.ru"

