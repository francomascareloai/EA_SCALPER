//+------------------------------------------------------------------+
//|                                                  ZigZag_nen1.mq4 |
//+------------------------------------------------------------------+
#property link      "http://www.onix-trade.net/forum/topic/118-gartley-patterns-%d0%b8-%d0%b8%d1%85-%d0%bc%d0%be%d0%b4%d0%b8%d1%84%d0%b8%d0%ba%d0%b0%d1%86%d0%b8%d0%b8/page__view__findpost__p__434115"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  Aqua
#property indicator_color2  LightSkyBlue
#property indicator_color3  LemonChiffon
#property indicator_width1  0
#property indicator_style1  0
//---- 
extern int  ExtDepth    = 5;
extern int  ExtBackstep = 8;
extern bool noBackstep  = true;
extern int  ExtLabel    = 1;
//---- 
//---- 
double zz[], ha[], la[];
int timeFirstBar=0;
//+------------------------------------------------------------------+
//| ZigZag initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   SetIndexBuffer(0,zz); 
   SetIndexBuffer(1,ha);
   SetIndexBuffer(2,la);
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexArrow(2,159);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(2,0.0);
   IndicatorShortName("ZigZag("+ExtDepth+","+ExtBackstep+")");

   if (ExtLabel<0) ExtLabel=0;
   if (ExtLabel>0) ExtLabel=1;

//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//|  ZigZag iteration function                                       |
//+------------------------------------------------------------------+
int start()
  {
   //----+ проверка количества баров на достаточность для корректного расчёта индикатора
   if (Bars-1<ExtDepth)return(0);
   //----+ Введение целых переменных памяти для пересчёта индикатора только на неподсчитанных барах
   static int time4_extremum,time5_extremum,time6_extremum;  
   //----+ Введение переменных с плавающей точкой для пересчёта индикатора только на неподсчитанных барах
   static  double cena4_extremum,cena5_extremum,cena6_extremum;
   //----+ Введение целых переменных для пересчёта индикатора только на неподсчитанных барах и получение уже подсчитанных баров
   int MaxBar,limit,bar4_extremum,bar5_extremum,bar6_extremum=-1,counted_bars=IndicatorCounted();
   //---- проверка на возможные ошибки
   if (counted_bars<0)return(-1);
   //---- последний подсчитанный бар должен быть пересчитан
   if (counted_bars>0) counted_bars--;
   //----+ Введение переменных    
   int    index, shift, back, lasthighpos, lastlowpos, lastpos, k;
   double val,TempBuffer[1];
   double curlow,curhigh,lasthigh,lastlow;
 
   int    metka=0; // =0 - до первого перелома ZZ. =1 - ищем метки максимумов. =2 - ищем метки минимумов.

   //---- определение номера самого старого бара, начиная с которого будет произведён полый пересчёт всех баров
   MaxBar=Bars-ExtDepth; 
   //---- определение номера стартового  бара в цикле, начиная с которого будет производиться  пересчёт новых баров
   if (counted_bars==0 || Bars-counted_bars>2)
     {
      limit=MaxBar;
      ArrayInitialize(zz,0); ArrayInitialize(TempBuffer,0);
     }
   else 
     {
      //----
      bar4_extremum=iBarShift(NULL,0,time4_extremum,TRUE);
      bar5_extremum=iBarShift(NULL,0,time5_extremum,TRUE);
      bar6_extremum=iBarShift(NULL,0,time6_extremum,TRUE);
      //----
      limit=bar5_extremum;      
      if (bar4_extremum<0 || bar5_extremum<0 || bar6_extremum<0)
         {
          limit=MaxBar;
         }
     }
     
   //---- инициализация нуля
   if (limit>MaxBar || timeFirstBar!=Time[Bars-1]) 
     {
      timeFirstBar=Time[Bars-1];
      limit=MaxBar; 
     } 
   //----  
   //---- изменение размера временного буфера
   if (limit==MaxBar) ArrayResize(TempBuffer,Bars); else  ArrayResize(TempBuffer,limit+ExtBackstep+1);
     
   //----+-------------------------------------------------+ 
   
   //----+ начало первого большого цикла
   for(shift=limit; shift>=0; shift--)
     {
      //--- Low
      k=iLowest(NULL,0,MODE_LOW,ExtDepth,shift);
      if (k==shift)
        {
         val=Low[k];
         if (!noBackstep)
           {
            if(val==lastlow) val=0.0;
            else 
              { 
               lastlow=val; 
               for(back=1; back<=ExtBackstep; back++)
                 {
                  if(val<zz[shift+back]) zz[shift+back]=0.0; 
                 }
              }
           }
         zz[shift]=val; 
         if (ExtLabel==1) la[shift]=val;
        }
      
      //--- High
      k=iHighest(NULL,0,MODE_HIGH,ExtDepth,shift);
      if (k==shift)
        {
         val=High[k];
         if (!noBackstep)
           {
            if(val==lasthigh) val=0.0;
            else 
              {
               lasthigh=val;
               for(back=1; back<=ExtBackstep; back++)
                 {
                  if(val>TempBuffer[shift+back]) TempBuffer[shift+back]=0.0; 
                 }
              }
           }
         TempBuffer[shift]=val; 
         if (ExtLabel==1) ha[shift]=val;
        }
     }
   //----+ конец первого большого цикла 
      
   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow= -1; lastlowpos= -1;
   //----+-------------------------------------------------+
   
   //----+ начало второго большого цикла

   for(shift=limit; shift>=0; shift--)
     {
      curlow=zz[shift];
      curhigh=TempBuffer[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) TempBuffer[lasthighpos]=0;
            else TempBuffer[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) zz[lastlowpos]=0;
            else zz[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           } 
         lasthigh=-1;
        }
     }
   //----+ конец второго большого цикла
     
   //----+-------------------------------------------------+
   
   //----+ начало третьего цикла
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;
   lastpos=-1;
   for(shift=limit; shift>=0; shift--)
     {
      if (!noBackstep)
        {
         if(TempBuffer[shift]!=0.0) zz[shift]=TempBuffer[shift];
        }
      else
        {
         if(TempBuffer[shift]>0.0)
           {
            if (zz[shift]>0)
              {
               if (lasthigh>0 && iLow(NULL,0,shift)<iLow(NULL,0,lastpos) && iHigh(NULL,0,shift)>iHigh(NULL,0,lastpos)) zz[shift]=TempBuffer[shift];
              }
            else zz[shift]=TempBuffer[shift];
           }
        }

      if (zz[shift]>0)
        {
         lastpos=shift;
         if (iLow(NULL,0,shift)==zz[shift]>0)
           {
            curlow=zz[shift];
            lasthigh=-1; curhigh=0; 
            if (noBackstep)
              {
               if(lastlow>0)
                 {
                  if(lastlow>curlow) zz[lastlowpos]=0;
                  else zz[shift]=0;
                 }
               //---
               if(curlow<lastlow || lastlow<0)
                 {
                  lastlow=curlow;
                  lastlowpos=shift;
                 } 
              }
            continue;
           }
         lastlow=-1;
         curhigh=zz[shift];

         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) zz[lasthighpos]=0;
            else zz[shift]=0;
           }

         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
        }
     }
   //----+ конец третьего цикла

   //+--- Восстановление значений индикаторного буффера, которые могли быть утеряны 
   if (limit<MaxBar)
     {
      zz[bar4_extremum]=cena4_extremum; 
      zz[bar5_extremum]=cena5_extremum; 
      zz[bar6_extremum]=cena6_extremum; 
     }
   //+---+============================================+
  
   //+--- запоминание времени трёх перегибов Зигзага и значений индикатора в этих точках 
   int count;
   if (limit==MaxBar) bar6_extremum=MaxBar;
   for(shift=0; shift<=bar6_extremum; shift++)
     {
      if (zz[shift]!=0)
       {
        count++;
        if (count==5) {time4_extremum=Time[shift]; cena4_extremum=zz[shift];}
        if (count==6) {time5_extremum=Time[shift]; cena5_extremum=zz[shift];}
        if (count==7) {time6_extremum=Time[shift]; cena6_extremum=zz[shift]; break;}
       }
     } 

 //---- расставляем метки возникновения лучей зигзага
   if (ExtLabel==1)
     {
      for(shift=Bars-1; shift>=0; shift--)
        {
         if (zz[shift]>0)
           {
            if (ha[shift]>0)
              {
               metka=2; la[shift]=0; shift--;
              }
            else
              {
               metka=1; ha[shift]=0; shift--;
              }
           }

         if (metka==0)
           {
            ha[shift]=0; la[shift]=0;
           }
         else if (metka==1)
           {
            if (ha[shift]>0) metka=0;
            la[shift]=0;
           }
         else if (metka==2)
           {
            if (la[shift]>0) metka=0;
            ha[shift]=0;
           }
        }
     }
   return(0);
  }
 //---+ +---------------------------------------------------------------------+