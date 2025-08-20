//+------------------------------------------------------------------+
//|                                              CTG-Modify Date.mq4 |
//|                                                CompanyName "CTG" |
//|                                     http://chaostradinggroup.com |
//+------------------------------------------------------------------+

//Скрипт создан для терминала MetaTrader 4, он исправляет график, удлиняя его, 
//с учетом выходных дней и праздников.
//
//Запустите терминал MetaTrader 4. В верхнем меню выберите значок Навигатор,в разделе Скрипты 
//найдите CTG Modify Date, затем перекиньте его на график, который вы хотите исправить.
//
//У индикатора есть опция ExtPeriodMultiplier, она нужна, если вы хотите получить нестандартный
//период графика, например из периода H1  сделать период H2 или любой другой. Для изменения
//периода вам нужно исправить это значение (Например: - если вам нужен период графика H8, 
//установите ExtPeriodMultiplier=8). Если же вы не хотите менять период тогда оставляйте 1.
//Следующая опция скрипта  Nullbars - эта опция служит для наглядности полученного графика, 
//она обнуляет high и low у баров, которые приходятся на выходные. По умолчанию эта опция включена. 
//
//Далее вам необходимо зайти в главное меню терминала и выбрать опцию открыть автономно.
//В списке графиков выберите график с припиской M_D и откройте его.
//У вас появится исправленный график в новом окне. Этот график будет обновляться каждые 2 секунды,
//(пока на первом графике включен скрипт).

#property copyright "Copyright © 2007, ChaosTradingGroup.com"
#property link      "http://ChaosTradingGroup.com"
#property show_inputs
#include <WinUser32.mqh>

extern int ExtPeriodMultiplier=1; // new period multiplier factor
extern bool Nullbars=true;
int        ExtHandle=-1;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
   int    i, start_pos, i_time, time0, last_fpos, periodseconds,sk;
   double d_open, d_low, d_high, d_close, d_volume, last_volume;
   int    hwnd=0,cnt=0;
//---- History header
   int    version=400;
   string c_copyright;
   string c_symbol=Symbol()+"-M_D";
   int    i_period=Period()*ExtPeriodMultiplier;
   int    i_digits=Digits;
   int    i_unused[13];


switch ( Period() )
        {
         case 1:     sk=60;  break;
         case 5:     sk=300;  break;
         case 15:    sk=900;  break;
         case 30:    sk=1800;  break;
         case 60:    sk=3600;  break;
         case 240:   sk=14400;  break;
         case 1440:  sk=86400;  break;         
         case 10080: sk=604800;  break;
         case 43200: sk=2592000;  break;          
         
         default: break;
         }





//----  
   ExtHandle=FileOpenHistory(c_symbol+i_period+".hst", FILE_BIN|FILE_WRITE);
   if(ExtHandle < 0) return(-1);
//---- write history file header
   c_copyright="Copyright © 2007, ChaosTradingGroup.com";
   FileWriteInteger(ExtHandle, version, LONG_VALUE);
   FileWriteString(ExtHandle, c_copyright, 64);
   FileWriteString(ExtHandle, c_symbol, 12);
   FileWriteInteger(ExtHandle, i_period, LONG_VALUE);
   FileWriteInteger(ExtHandle, i_digits, LONG_VALUE);
   FileWriteInteger(ExtHandle, 0, LONG_VALUE);       //timesign
   FileWriteInteger(ExtHandle, 0, LONG_VALUE);       //last_sync
   FileWriteArray(ExtHandle, i_unused, 0, 13);
//---- write history file
   periodseconds=i_period*60;
   start_pos=Bars-1;
   d_open=Open[start_pos];
   d_low=Low[start_pos];
   d_high=High[start_pos];
   d_volume=Volume[start_pos];
   //---- normalize open time
   i_time=Time[start_pos]/periodseconds;
   i_time*=periodseconds;
   

   for(i=Time[start_pos-1];i<=Time[0]; i+=sk)
     {
      time0=i;
      if(time0>=i_time+periodseconds || i==Time[0])
        {
         if(i==Time[0] && time0<i_time+periodseconds)
           {
            d_volume+=Volume[0];
            if (Low[0]<d_low)   d_low=Low[0];
            if (High[0]>d_high) d_high=High[0];
            d_close=Close[0];
           }
         last_fpos=FileTell(ExtHandle);
         last_volume=Volume[iBarShift(Symbol(),Period(),i)];
         if ((Nullbars==true && i_period<=1440 && TimeDayOfWeek(i)==0) || (Nullbars==true && i_period<=1440 && TimeDayOfWeek(i)==6))
         {
         d_close=d_open;
         d_low=d_open;
         d_high=d_open;                  
         }
         
         
         FileWriteInteger(ExtHandle, i_time, LONG_VALUE);
         FileWriteDouble(ExtHandle, d_open, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_low, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_high, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_close, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_volume, DOUBLE_VALUE);
         FileFlush(ExtHandle);
         cnt++;
         if(time0>=i_time+periodseconds)
           {
            i_time=time0/periodseconds;
            i_time*=periodseconds;
            d_open=Open[iBarShift(Symbol(),Period(),i)];
            d_low=Low[iBarShift(Symbol(),Period(),i)];
            d_high=High[iBarShift(Symbol(),Period(),i)];
            d_close=Close[iBarShift(Symbol(),Period(),i)];
            d_volume=last_volume;
           }
        }
       else
        {
         d_volume+=Volume[i];
         if (Low[iBarShift(Symbol(),Period(),i)]<d_low)   d_low=Low[iBarShift(Symbol(),Period(),i)];
         if (High[iBarShift(Symbol(),Period(),i)]>d_high) d_high=High[iBarShift(Symbol(),Period(),i)];
         d_close=Close[iBarShift(Symbol(),Period(),i)];
        }
     } 
   FileFlush(ExtHandle);
   Print(cnt," record(s) written");
//---- collect incoming ticks

   int last_time=LocalTime()-5;
   while(IsStopped()==false)
     {
      int cur_time=LocalTime();
      //---- check for new rates
      if(RefreshRates())
        {
         time0=Time[0];
         FileSeek(ExtHandle,last_fpos,SEEK_SET);
         //---- is there current bar?
         if(time0<i_time+periodseconds)
           {
            d_volume+=Volume[0]-last_volume;
            last_volume=Volume[0]; 
            if (Low[0]<d_low) d_low=Low[0];
            if (High[0]>d_high) d_high=High[0];
            d_close=Close[0];
           }
         else
           {
            //---- no, there is new bar
            d_volume+=Volume[1]-last_volume;
            if (Low[1]<d_low) d_low=Low[1];
            if (High[1]>d_high) d_high=High[1];
            //---- write previous bar remains
            FileWriteInteger(ExtHandle, i_time, LONG_VALUE);
            FileWriteDouble(ExtHandle, d_open, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_low, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_high, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_close, DOUBLE_VALUE);
            FileWriteDouble(ExtHandle, d_volume, DOUBLE_VALUE);
            last_fpos=FileTell(ExtHandle);
            //----
            i_time=time0/periodseconds;
            i_time*=periodseconds;
            d_open=Open[0];
            d_low=Low[0];
            d_high=High[0];
            d_close=Close[0];
            d_volume=Volume[0];
            last_volume=d_volume;
           }
         //----
         FileWriteInteger(ExtHandle, i_time, LONG_VALUE);
         FileWriteDouble(ExtHandle, d_open, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_low, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_high, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_close, DOUBLE_VALUE);
         FileWriteDouble(ExtHandle, d_volume, DOUBLE_VALUE);
         FileFlush(ExtHandle);
         //----
         if(hwnd==0)
           {
            hwnd=WindowHandle(c_symbol,i_period);
            if(hwnd!=0) Print("Chart window detected");
           }
         //---- refresh window not frequently than 1 time in 2 seconds
         if(hwnd!=0 && cur_time-last_time>=2)
           {
            PostMessageA(hwnd,WM_COMMAND,33324,0);
            last_time=cur_time;
           }
        } 
     }     
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   if(ExtHandle>=0) { FileClose(ExtHandle); ExtHandle=-1; }
  }
//+------------------------------------------------------------------+