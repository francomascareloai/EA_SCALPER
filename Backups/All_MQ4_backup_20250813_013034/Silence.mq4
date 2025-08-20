//+---------------------------------------------------------------------+
//|                                                      Silence.mq4    |
//|                                         Copyright © Trofimov 2009   |
//+---------------------------------------------------------------------+
//| Тишина                                                              |
//|                                                                     |
//| Описание: Показывает на сколько процентов активен рынок             |
//| Синяя - процент агрессивности (скорости изменения цены)             |
//| Красная - процент волатильности (величина коридора)                 |
//| Авторское право принадлежит Трофимову Евгению Витальевичу, 2009     |
//+---------------------------------------------------------------------+


#property copyright "Copyright © Trofimov Evgeniy Vitalyevich, 2009"
#property link      "http://TrofimovVBA.narod.ru/"

//---- Свойства индикатора
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 MidnightBlue
#property indicator_width1 1
#property indicator_color2 Maroon
#property indicator_width2 1
#property indicator_maximum 100
#property indicator_minimum 0
#property indicator_level1 50

//---- Входящие параметры
extern int MyPeriod=12;
extern int BuffSize=96;
bool ReDraw=true; //-если включен, то перерисовывает нулевой бар при каждом новом тике
// если выключен, то нулевой бар содержит фиксированное значение, вычисленное по предыдущим (готовым) барам
double Buff_line1[]; // - агрессивность 
double Buff_line2[]; // - волатильность
double Aggress[], Volatility[];
//+------------------------------------------------------------------+
//|                Функция инициализации индикатора                  |
//+------------------------------------------------------------------+
int init()
  {
//---- x дополнительных буфера, используемых для расчета
   IndicatorBuffers(2);
   IndicatorDigits(2); 
//---- параметры рисования (установка начального бара)
   SetIndexDrawBegin(0,BuffSize+MyPeriod);
   SetIndexDrawBegin(1,BuffSize+MyPeriod);
//---- x распределенных буфера индикатора
   SetIndexBuffer(0,Buff_line1);
   SetIndexBuffer(1,Buff_line2);
//---- имя индикатора и подсказки для линий
   IndicatorShortName("Silence("+MyPeriod+","+BuffSize+") = ");
   SetIndexLabel(0,"Aggressiveness");
   SetIndexLabel(1,"Volatility");
   ArrayResize(Aggress,BuffSize);
   ArrayResize(Volatility,BuffSize);
   return(0);
  }
//+------------------------------------------------------------------+
//|                Функция индикатора                                |
//+------------------------------------------------------------------+
int start() {
   static datetime LastTime;
   int limit, RD;
   double MAX,MIN;
   double upPrice,downPrice;
   if(ReDraw) RD=1;
   // Пропущенные бары
   int counted_bars=IndicatorCounted();
//---- обходим возможные ошибки
   if(counted_bars<0) return(-1);
//---- новые бары не появились и поэтому ничего рисовать не нужно
   limit=Bars-counted_bars-1+RD;
   
//---- out of range fix
   if(counted_bars==0) limit-=RD+MyPeriod;
   
//---- основные переменные
   double B;
//---- основной цикл
   for(int t=limit-RD; t>-RD; t--) {
      
      //Вычисление агрессивности бара t
      B=0;
      for(int x=t+MyPeriod-1; x>=t; x--) { 
         if(Close[x]>Open[x]) {
            //белая свеча
            B=B+(Close[x]-Close[x+1]);
         }else{
            //чёрная свеча
            B=B+(Close[x+1]-Close[x]);
         }
      }//Next x
      
      //Вычисление волатильности бара t
      upPrice=High[iHighest(Symbol(),0,MODE_HIGH,MyPeriod,t)];//максимум за N баров 
      downPrice=Low[iLowest(Symbol(),0,MODE_LOW,MyPeriod,t)]; //минимум за N баров 
      
      //Если образовался новый бар, то производится сдвижка массива
      if(LastTime!=Time[t+1]){
         for(x=BuffSize-1; x>0; x--) {
            Aggress[x]=Aggress[x-1];
            Volatility[x]=Volatility[x-1];
         }//Next x
         LastTime=Time[t+1];
      }
      //Конец сдвижки массива
      
      //Перерисовка агрессивности
      Aggress[0]=B/Point/MyPeriod;
      MAX=Aggress[ArrayMaximum(Aggress)];
      MIN=Aggress[ArrayMinimum(Aggress)];
      Buff_line1[t]=Интерполяция(MAX,MIN,100,0,Aggress[0]);
      if(!ReDraw && t==1) Buff_line1[0]=Buff_line1[1];
      //Конец перерисовка агрессивности
      
      //Перерисовка волатильности
      Volatility[0]=(upPrice-downPrice)/Point/MyPeriod;
      MAX=Volatility[ArrayMaximum(Volatility)];
      MIN=Volatility[ArrayMinimum(Volatility)];
      Buff_line2[t]=Интерполяция(MAX,MIN,100,0,Volatility[0]);
      if(!ReDraw && t==1) Buff_line2[0]=Buff_line2[1];
      //Конец перерисовка волатильности
      
   }//Next t
   return(0);
}
//+------------------------------------------------------------------+
double Интерполяция(double a,double b,double c,double d,double X) {
//a; X; b - столбец изветных чисел, c; d; - столбец со стороны неизвестной.
    if(b - a == 0)
        return(10000000); //бесконечность
    else
        return(d - (b - X) * (d - c) / (b - a));
}//Интерполяция
//+------------------------------------------------------------------+

