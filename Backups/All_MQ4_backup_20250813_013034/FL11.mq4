//+---------------------------------------------------------------------------------+
//+ MA2_Signal                                                                      +
//+ Индикатор сигналов при пересечении основной и сигнальной линий стоха            +
//+                                                                                 +
//+ Внешние параметры:                                                              +
//+  KPeriod - период сигнальной линии стоха                                        +
//+  DPeriod - период основной линии стоха                                          +
//+  Slowing - замедление                                                           +
//+---------------------------------------------------------------------------------+
#property copyright "Copyright © 2007, Karakurt"
#property link      ""

//---- Определение индикаторов
#property indicator_separate_window
#property indicator_buffers 4
//---- Цвета
#property indicator_color1 Magenta // 5
#property indicator_color2 Blue        // 7
#property indicator_color3 MediumBlue
#property indicator_color4 Tomato

//---- Параметры
extern int       KPeriod=8;
extern int       DPeriod=3;
extern int       Slowing=3;
extern int       method=0; //0-MODE_SMA; 1-MODE_EMA; 2-MODE_SMMA; 3-MODE_LWMA
extern int       price_field=0;//0-Low/High; 1-Close/Close
extern string ExtSoundFileName = "";
extern bool ActiveSignal=true;
extern double NormalizeAccuracy = 0.0000;


//---- Буферы
double Main[];
double Signal[];
double CrossUp[];
double CrossDown[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
  //---- Установка параметров прорисовки
  //     Средние
  SetIndexStyle( 0, DRAW_LINE );
  SetIndexStyle( 1, DRAW_LINE );
  //     Сигналы
  SetIndexStyle( 2, DRAW_ARROW, EMPTY );
  SetIndexArrow( 2, 217 );
  SetIndexStyle( 3, DRAW_ARROW, EMPTY );
  SetIndexArrow( 3, 218 );
  //---- Задание буферов
  SetIndexBuffer( 0, Main      );
  SetIndexBuffer( 1, Signal    );
  SetIndexBuffer( 2, CrossUp   );
  SetIndexBuffer( 3, CrossDown );
  
  IndicatorDigits( MarketInfo( Symbol(), MODE_DIGITS ) );
  
  //---- Название и метки
  IndicatorShortName( "Stoch_cross(" + KPeriod + "," + DPeriod + "," + Slowing + ")" );
  SetIndexLabel( 0, "Stoch_cross(" + KPeriod + "," + DPeriod + "," + Slowing + ")" );
  SetIndexLabel( 1, "Signal");
  SetIndexLabel( 2, "Buy"  );
  SetIndexLabel( 3, "Sell" );
  
  return ( 0 );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
  static bool bBuy  = False;
  static bool bSell = False;
    
  bool   bConditionUp;
  bool   bConditionDown;
  double Range;
  double AvgRange;
  int    iLimit;
  int    i;
  int    counter;
  int    counted_bars = IndicatorCounted();
  
  
  //---- check for possible errors
  if ( counted_bars < 0 ) 
    return ( -1 );
  
  //---- last counted bar will be recounted
  if ( counted_bars > 0 ) counted_bars--;
  
  iLimit = Bars - counted_bars;
  
 if (method==0) method=MODE_SMA;
 else if (method==1) method=MODE_EMA;
 else if (method==2) method=MODE_SMMA;
 else if (method==3) method=MODE_LWMA;
  
  for ( i = 0; i <= iLimit; i++ ) {
    Main[i] = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, method, price_field, MODE_MAIN, i);
    Signal[i] = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, method, price_field, MODE_SIGNAL, i);
  } 
  
  for ( i = 1; i <= iLimit; i++ ) {
    AvgRange = 0;
    for ( counter = i; counter <= i + 9; counter++ ) {
      AvgRange += MathAbs( High[ counter ] - Low[ counter ] );
    }
    Range = AvgRange/10;
   
      bConditionUp   = ( Main[i] >= Signal[i] ) &&
                       ( Main[i+1] <= Signal[i+1] ) &&
                       ( Main[i-1] >= Signal[i-1] )&& // пересечение вверх
                       ( NormalizeDouble(Main[i-1]- Main[i+1],4)>=NormalizeAccuracy);
      bConditionDown = ( Main[i] <= Signal[i] ) &&
                       ( Main[i+1] >= Signal[i+1] ) &&
                       ( Main[i-1] <= Signal[i-1] ) && // пересечение вниз
                       ( NormalizeDouble(Main[i+1]- Main[i-1],4)>=NormalizeAccuracy);
   
    
    
    if ( bConditionUp )
    CrossUp[i] = Signal[i];
    else if ( bConditionDown )
    CrossDown[i] = Signal[i];
    
    if ( !bBuy && bConditionUp ) {
      // Флаги
      bBuy  = True;  // установка флага покупки
      bSell = False; // сброс флага продажи
      
      
      if ( i < 2 && ActiveSignal == True ) {
          Alert (Symbol()," ",Period(),"M  STOCH_CROSS_BUY "); // звуковой сигнал
        if ( ExtSoundFileName != "" )
          PlaySound( ExtSoundFileName );
      } 
      
    }
    else if ( !bSell && bConditionDown ) {
      // Флаги
      bSell = True;  // установка флага продажи
      bBuy  = False; // сброс флага покупки
      
 
     if ( i < 2 && ActiveSignal == True) {
        CrossDown[i] = Signal[i];
        Alert (Symbol()," ",Period(),"M   STOCH_CROSS_SELL "); // звуковой сигнал
        if ( ExtSoundFileName != "" )
          PlaySound( ExtSoundFileName );
      } 
    } 
  } 
 return ( 0 );
}