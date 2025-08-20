//+------------------------------------------------------------------+
//|                                                DailyResearch.mq4 |
//|                                          Copyright © 2007, DRKNN |
//|                                                    drknn@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, DRKNN"
#property link      "drknn@mail.ru"
#property show_inputs
extern int TakeProfit=10;
extern int TaimFame=1440;
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start(){
  
  string SMB;
  double SPR;
  int Bar=iBars(SMB,TaimFame);
  double Dlina=0,Dodzh=0,Bych=0,Medv=0,MezhduTenjami=0;
  double TenUp=0,TenDown=0;
  double Up=0,Down=0;
  double O,C,H,L,O1,C1,H1,L1;
  double TwooBych=0,TwooMedw=0,TwooDodzh=0;
  double Nesovpadenie=0;
  double Profit=0;
 
  // ---- Подготовка данных -----------
  SMB=Symbol();
  SPR=MarketInfo(SMB,MODE_SPREAD);
  
  for(int i=Bar;i>0;i--){
    
    O=iOpen(SMB,TaimFame,i); 
    C=iClose(SMB,TaimFame,i);
    H=iHigh(SMB,TaimFame,i);
    L=iLow(SMB,TaimFame,i);
    
     
     
    //------ встречи свеч одного цвета --------
    if(i<Bar){
      
      O1=iOpen(SMB,TaimFame,i+1); 
      C1=iClose(SMB,TaimFame,i+1);
      H1=iHigh(SMB,TaimFame,i+1);
      L1=iLow(SMB,TaimFame,i+1);
      
      if((O1-C1)>0 && (O-C)>0){// две медвежьих вподряд
        TwooMedw++;
         
      }
      if((C1-O1)>0 && (C-O)>0){// две бычьих вподряд
        TwooBych++;
      }
      if((C1==O1)&&(C==O)){ // два доджа вподряд
        TwooDodzh++;
      }
      if ( 
          ((O1-C1)>0 && (O-C)<0) || ((C1-O1)>0 && (C-O)<0) || ((C1==O1)&&(C<O)) || ((C1==O1)&&(C>O)) || ((C1<O1)&&(C==O))
          || ((C1>O1)&&(C==O))
         ){//несовпадение цвета двух соседних свеч
           Nesovpadenie++;
           if((O1-C1)>0 && (O-C)<0){ // Комбинация "черная-белая"
             if((O-L)>=(TakeProfit+SPR)*Point){//берём нижнюю тень, так как открываем шорт
              Profit++;
             }
           }
           
           if((O1-C1)<0 && (O-C)>0){// Комбинация "белая-чёрная"
             if((H-O)>=(TakeProfit+SPR)*Point){// измеряем верхнюю тень, так как открываем лонг
               Profit++;
             }
           }
           if((O1-C1)>0 && O==C){ // Комбинация "черная-додж"
             if((O-L)>=(TakeProfit+SPR)*Point){//берём нижнюю тень, так как открываем шорт
              Profit++;
             }
           }
           
           if((O1-C1)<0 && O==C){// Комбинация "белая-Додж"
             if((H-O)>=(10+SPR)*Point){// измеряем верхнюю тень, так как открываем лонг
               Profit++;
             }
           }
           
           
      }    
          
    }
    
   
    //----- тела свеч ---------
    if(O>C){
      Dlina=Dlina+(O-C)/Point;
      Medv++;
      TenUp=TenUp+(H-O)/Point;
      Up++;
      TenDown=TenDown+(C-L)/Point;
      Down++;
    }
    if(O<C){
      Dlina=Dlina+(C-O)/Point;
      Bych++;
      TenUp=TenUp+(H-C)/Point;
      Up++;
      TenDown=TenDown+(O-L)/Point;
      Down++;
      
    }
    if(O==C){
      Dodzh++;
      TenUp=TenUp+(H-C)/Point;
      Up++;
      TenDown=TenDown+(O-L)/Point;
      Down++;
       
    }  
    // ------ тени свеч -------
    MezhduTenjami=MezhduTenjami+(H-L)/Point;
  
  }
  // --------- Манипулирование данными ---------
  Dlina=Dlina/(Bar);//средняя длина свечи
  MezhduTenjami=MezhduTenjami/(Bar);//среднее расстояние между хай и лоу свечи
  TenUp=TenUp/Up;
  TenDown=TenDown/Down;
  
  Alert("Данным анализом проигнорирована постановка стоп-лосса!!!!!");
  Alert("Если предыдущая свеча - Додж, то не торгуем!");
  Alert("При несовпадении цвета вероятность взятия ",TakeProfit," pt профита = ",Profit/Nesovpadenie*100," %  (с учётом спреда)"); 
  Alert("Несовпадение цвета двух соседних свеч выпало ",Nesovpadenie," раз. Вероятность появления = ",Nesovpadenie/Bar*100," %");
  Alert("Комбинация *Два Доджа* выпала ",TwooDodzh," раз. Вероятность появления = ",TwooDodzh/Bar*100," %");
  Alert("Комбинация *Две медвежьи* выпала ",TwooMedw," раз. Вероятность появления = ",TwooMedw/Bar*100," %");
  Alert("Комбинация *Две бычьи* выпала ",TwooBych," раз. Вероятность появления = ",TwooBych/Bar*100," %");
  Alert("Средняя нижняя тень = ",TenDown," pt");
  Alert("Средняя верхняя тень = ",TenUp," pt"); 
  Alert("Среднее расстояние между xай и лоу свечи = ",MezhduTenjami," pt");
  Alert("Средняя длина тела свечи = ",Dlina," pt"); 
  Alert("Доджей = ",Dodzh,". Вероятность появления = ",Dodzh/Bar*100," %");
  Alert("Медвежьих свеч = ",Medv,". Вероятность появления = ",Medv/Bar*100," %");
  Alert("Бычьих свеч = ",Bych,". Вероятность появления = ",Bych/Bar*100," %");
  Alert("На интервале ",TaimFame," минут проанализировано ",Bar," свеч. Из них :"); 
  Alert("============  ",SMB,"  ============");
  return(0);
}
//+------------------------------------------------------------------+