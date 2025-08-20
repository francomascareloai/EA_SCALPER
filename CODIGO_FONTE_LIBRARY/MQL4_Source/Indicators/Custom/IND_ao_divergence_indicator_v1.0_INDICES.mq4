//..#define MAGICMA  071007
#include <stdlib.mqh>
#include <WinUser32.mqh>
//int Lots,MM,RiskPercent;
//#include <common.mqh>
//+------------------------------------------------------------------+
//|                                                       common.mq4 |
//|                                         Copyright © 2015, Sergan |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#define LOW 0
#define HIGH 1
#define OP_NONE -1  //тип ордера - нет ордера OP_BUY, OP_SELL и т.п. используются из мт
#define OP_CLOSEORDER -2 //тип сигнала - закрыть ордер
#define UP 1
#define DOWN -1
#define REVERSESTRING "reverseorder "
#define ZIGZAGTRADERSTRING "zt "


//#import "common.ex4"


int orderDirection() { 
  int res = 1 - 2 * ( OrderType() % 2 );
  //Print("in order direction for order ticket ", OrderTicket(), " type ", OrderType(), " ret value is ", res   );    
  return( res ); 
}


void delobjectsbyprefiks(string prefiks ){
  for(int i = ObjectsTotal() - 1; i >= 0; i--){
    string name = ObjectName(i);
    if(StringSubstr(name, 0, StringLen(prefiks)  ) != prefiks) return(0);
    ObjectDelete(name);   
  }
  return(0); 
  
}




//+------------------------------------------------------------------+
//|                                                 aodivergence.mq4 |
//|                                         Copyright © 2015, Sergan |
//|                                                                  |
//+------------------------------------------------------------------+
// Версия 1. 07.10.07 Выводит ао
// 1.1 11.10.07 Стрелки - сигналы открытия позиций
#property copyright ""
#property link      ""

#property indicator_separate_window
#property  indicator_buffers 6
#property  indicator_color1  Black
#property  indicator_color2  Green
#property  indicator_color3  Red

#property indicator_color4 Black   //buy  signal
#property indicator_color5 Black   //sell signal
#property indicator_color6 Red
#property indicator_color7 Red
#property indicator_color8 Black

#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 4
//---- input parameters


//double Buffer1[];       // буфер младший зигзаг
//double Buffer2[];       // буфер старший зигзаг
//double BufferPoints1[]; //буфер опорных точек малого зигазга
//double BufferPoints2[]; //буфер опорных точек старшего зигазга

//---- indicator settings

//---- indicator buffers
double     ExtBuffer0[]; // ао или ао нормализованный 
double     ExtBuffer1[]; // ао 
double     ExtBuffer2[];

extern int fastma = 5;
extern int slowma = 34; 
extern int isshowsignaltype1 = 1; // 1 - показывать сигнал, если дивергенция 0 - нет фильтра
extern int isshowsignaltype2 = 1; // 1 - сигнал два пика - пока не учитывается 

extern int divergencebars = 4; // // число баров в пределах которых обпределяется дивергенция
extern int mode = 0; // 0 - ао, 1- аоnormalized 2 - rsi slowma - используется как период 2
int normalizeperiod = 200;
string indicatorname;
double BuyBuffer[];     //буфер сигналы бай
double SellBuffer[];    //буяер сигналы селл
double BufferSignalType[]; // буфер типов сигналов, необходимо для передачи в советник
int flagdivergence;
int foundpik; //последний найденный пик слева
double pikprice1, pikprice2; int foundpikprice1,foundpikprice2; // последние найденные координаты пиков цены
int lastipikprice = 0;


#define LINEAO       "linebetweenpik"
#define LINEPRICE    "linebetweenpprice"

double getpikprice( int howbars, int shift, double dir, int flaglastbar=0 ){
  // howbars - в пределах какого числа баров ищется экстремума
  // shift - число баров сдвиг в iBars
  // dir - если >0 значит по наям, если < 0 то по ловам
  // пиком считается, если есть лов( i+1 ) > лов( i ) > лов( i-1 )
  // для полож dir то           най( i+1 ) < най( i ) < най( i-1 )
  
  

  
  
  
  int i = -howbars;
  if( flaglastbar == 1 )i=0; //если это последний бар, то вперед заглядывать нельзя
  if( i+shift < 0 )i=0;
  //Print("try to found pik for shift = ", shift, " dir is ", dir  );
  double lastminmax = 0;
  lastipikprice = 0;
  for( ; i < howbars; i ++ ){
    // здесь ошибка - просматриваются бары только влево
    bool condition;
    int nexti =  i+iif(shift==0 || flaglastbar == 1, 0, -1)+shift;
    
    if( dir > 0 ){ 
      //condition = High[i+1+shift]<=High[i+shift] && High[i+shift]  >= High[ nexti  ];
      condition = High[i+shift] > lastminmax;
    }else{
      //condition = Low[i+1+shift]>=Low[i+shift] && Low[i+shift]<= Low[  nexti  ];
      condition = ((Low[i+shift] < lastminmax) || (lastminmax == 0));
    }
    // для бара shift = 0 - бар справа не проверятеся 
    if( condition ){
      double ret  = iif(dir>0, High[i+shift], Low[i+shift] );
      //Print("ret val is ", ret, " bar is ", i+shift );
      //Print(" High[i+1+shift] ", High[i+1+shift], " High[i+shift] ", High[i+shift], " High[ nexti  ] ", High[ nexti  ]);
      lastipikprice = i+shift;
      lastminmax = ret;
      //return(  ret  );
    }
  }
  return(lastminmax);
}

int init()
  {
   //---- drawing settings
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   IndicatorDigits(Digits+1);
   SetIndexDrawBegin(0,slowma);
   SetIndexDrawBegin(1,slowma);
   SetIndexDrawBegin(2,slowma);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer0);
   SetIndexBuffer(1,ExtBuffer1);
   SetIndexBuffer(2,ExtBuffer2);
//---- name for DataWindow and indicator subwindow label
   if( mode == 0 )indicatorname = "AODivergence";
   if( mode == 1 )indicatorname = "AODivergenceNormilized";
   if( mode == 2 )indicatorname = "RSIDivergence";
 
   IndicatorShortName(indicatorname);
   
   SetIndexLabel(1,NULL);
   SetIndexLabel(2,NULL);
//---- initialization done


   SetIndexStyle( 3, DRAW_ARROW, EMPTY );
   SetIndexArrow( 3, 233 );
   SetIndexStyle( 4, DRAW_ARROW, EMPTY );
   SetIndexArrow( 4, 234 );

   //ArrayResize( BuyBuffer, 1 );
   //ArrayResize( SellBuffer, 1 );
 
 
   SetIndexBuffer( 3, BuyBuffer   );
   SetIndexEmptyValue(3,0);
   SetIndexBuffer( 4, SellBuffer   );
   SetIndexEmptyValue(4,0);
   //ArrayInitialize(BuyBuffer, 0 ); 
   //ArrayInitialize(SellBuffer, 0 );
 
   int drawtype = DRAW_ARROW ;
   SetIndexBuffer(5,BufferSignalType );
   SetIndexStyle( 5, DRAW_NONE);
   SetIndexEmptyValue(5,0);
   
 


   return(0);
  }



int delline( string prefiks, string name ){

       if(StringSubstr(name, 0, StringLen(prefiks)  ) != prefiks) return(0);
           
       ObjectDelete(name);   

}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit(){   

for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       delline(LINEAO, label); 
       delline(LINEPRICE, label); 
     }
   return(0);


return(0);  }
 


double CalcAO( int limit ){
    for(int i=limit; i>=1; i--){
      if( mode == 0) ExtBuffer0[i]=iMA(NULL,0,fastma,0,MODE_SMA,PRICE_MEDIAN,i)-iMA(NULL,0,slowma,0,MODE_SMA,PRICE_MEDIAN,i);
      if( mode == 1){
        ExtBuffer0[i]=iMA(NULL,0,fastma,0,MODE_SMA,PRICE_MEDIAN,i)-iMA(NULL,0,slowma,0,MODE_SMA,PRICE_MEDIAN,i);
        ExtBuffer1[i]= ExtBuffer0[i];
        double fndmax = ExtBuffer1[i+1]; double fndmin = fndmax;
        for(int j = i+1; j<i+1+normalizeperiod; j++ ){
          fndmax= MathMax(fndmax, ExtBuffer1[j]);
          fndmin = MathMin(fndmin, ExtBuffer1[j]);
        }
       double diff = fndmax-fndmin;
        if(diff == 0 )diff = 1;
        //if( limit > normalizeperiod ){
         // Print("for i = ", i,  " fnd min is ", fndmin, "fndmax is ", fndmax );
       
          ExtBuffer0[i] = (ExtBuffer1[i]-fndmin)/diff-0.5 ;  ///(fndmax - fndmin);
        //}
      } 
      
      if( mode == 2) ExtBuffer0[i]=iRSI(NULL,0,slowma,PRICE_CLOSE,i)-50;
     
    }
 //---- dispatch values between 2 buffers
   bool up=true;  double current, prev;
   for(i=limit-1; i>=0; i--){
      current=ExtBuffer0[i];
      prev=ExtBuffer0[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up){
         ExtBuffer2[i]=current;
         ExtBuffer1[i]=0.0;
      }else{
         ExtBuffer1[i]=current;
         ExtBuffer2[i]=0.0;
      }
     
   }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

bool isitpik( int i ){
  if( ExtBuffer0[i]>0 && ExtBuffer0[i]>ExtBuffer0[i+1] && ExtBuffer0[i]>ExtBuffer0[i-1])return(true);
  if( ExtBuffer0[i]<0 && ExtBuffer0[i]<ExtBuffer0[i+1] && ExtBuffer0[i]<ExtBuffer0[i-1])return(true);
}

bool findpik(int curaoi ){
  //есть ли значение ао больше ао(2) по модулю до тех пор, пока ао не пересечет ноль
  double curao = ExtBuffer0[curaoi+1]; //!!!!
  //double prevao = ExtBuffer0[curaoi+1];
  //double prevprevao = ExtBuffer0[curaoi+2];
  bool flag = false; 
  //if( curao > 0 && curao < prevao && prevao > prevprevao )flag = true;
  //if( curao < 0 && curao > prevao && prevao < prevprevao )flag = true;
  //if( !flag )return(false);
  if( !isitpik(curaoi+1))return(false);   
  foundpik = 0; 
  // если меньше 4 - то ошибка - сам себе пик получается 
     
  for( int i = 2+curaoi; i < Bars; i++ ){
    
    if(  sign ( ExtBuffer0[ i ] ) != sign( ExtBuffer0[ i-1 ] ))return( false ); //пересекли 0
    double cur =  ExtBuffer0[ i ]; 
    double prevcur = ExtBuffer0[ i+1 ];
    pikprice1 = 0; pikprice2 = 0; foundpikprice1 = 0; foundpikprice2 = 0;
    if( cur*prevcur < 0){//Знаки разные
      prevcur = 0;
    }
    if( cur < 0 )cur=-cur;
    if( prevcur < 0 )prevcur=-prevcur;
      
    
    double comp=curao;
    if(comp < 0) comp = -comp;
    if( isitpik(i) && cur>comp ){ //cur > comp && cur>prevcur
      //Print("есть пик, cur ", cur, "comp ", comp, " prev cur is ", prevcur, " curao ", curao, "bar number ", i," time is ", TimeToStr(iTime(NULL,0, i))  );
      // curao соответвует бару 1, для определения дивергенции определяем пик1, близкий к бару 1
      
      // также определяем пик2, близкий к бару i
      // если пик 2 по модулю больше пик 1 то это дивергенция
      // дополнительное условие - все бары между пиками 1 и 2 по модулю долджны быть меньше пика1 и меньше пика 2
      flagdivergence = 0;foundpikprice1 = 0; foundpikprice2 = 0;
      pikprice1 = getpikprice(divergencebars, curaoi, curao, 1 )*sign(curao); 
      foundpikprice1 = lastipikprice; //curaoi;
      // правый пик
      pikprice2 = getpikprice(divergencebars, i, curao )*sign(curao);
      // левый пик
      foundpikprice2 = lastipikprice; //foundpikprice2 = i ;
      if( pikprice2 < pikprice1 ){
        //Print("found diver val1", pikprice1, " val2 ", pikprice2, " ao is ", curao );
        flagdivergence = 1; 
        //Print("йесььь дивегенция " );
      }else{
      //  Print("нет дивегенции " );
      }
      foundpik = i;
      return (true );
    }
  } 
 
  return (false );
  
}

int drawline(){

 
  
}
bool ShowSignals(int i, bool itispik, bool flagdivergence  ){
  BuyBuffer[i] = 0; SellBuffer[i] = 0; BufferSignalType[i]=OP_NONE;
  
  int cmd = OP_BUY;

  if(!itispik)return( false );
  if(!flagdivergence && isshowsignaltype1 == 1 )return(false);
  if(i>Bars-100+slowma)return(false);
  if(ExtBuffer0[i]>0){
    cmd = OP_SELL;
  }
  if(cmd==OP_BUY){
    BuyBuffer[i]= ExtBuffer0[i];  
  
  }else{
    SellBuffer[i]= ExtBuffer0[i];  
  }
  BufferSignalType[i]=cmd;
  
}
int start(){
  int    counted_bars=IndicatorCounted();
  if(counted_bars<0) return(-1);
  // пересчитаем последний
  if(counted_bars>0) counted_bars--;
  int limit=Bars-counted_bars-1;
  SetIndexDrawBegin(5, Bars );  // буфер типов сигналов
  
  //limit = 500;
  CalcAO(limit);
  int numwindow = WindowFind(indicatorname); 
  if( numwindow == -1 )numwindow = 0;
  for( int i = limit; i>0; i -- ){
     
     string addname = "_ao_";
     if( mode == 1 )addname = "_aonorm_";
     if( mode == 2 )addname =  "_rsi_" ;
     string objname = LINEAO+addname+Time[i];
     ObjectDelete(objname  );
     string objnameprice = LINEPRICE+Time[i];
     ObjectDelete(objnameprice  );
     bool isfoundpik = findpik(i); 
     if(  isfoundpik  ){
     // если есть пик для этого то его отразить
       // нарисовать линию от и до
       //Print("есь пик, бар номер ", i );  
       ObjectCreate(objname, OBJ_TREND, numwindow, Time[foundpik], ExtBuffer0[foundpik], Time[i+1], ExtBuffer0[i+1]   );
       color linc = Blue;
       ObjectSet(objname   , OBJPROP_RAY, 0);
       ObjectSet(objname   , OBJPROP_WIDTH, 2);
       ObjectSet(objname   , OBJPROP_COLOR, linc);
       if( flagdivergence == 1 ){
         double drp2 = pikprice2*sign(pikprice2);
         double drp1 = pikprice1*sign(pikprice1);
         //Print("draw line on chart ", pikprice2, pikprice1 );
         ObjectCreate(objnameprice, OBJ_TREND, 0, Time[foundpikprice2], drp2, Time[foundpikprice1], drp1   );
         ObjectSet(objnameprice   , OBJPROP_RAY, 0);
         ObjectSet(objnameprice   , OBJPROP_WIDTH, 2);
         ObjectSet(objnameprice   , OBJPROP_COLOR, linc);
       
       }
 
       //риссуем линию
     }else{
       //Print("нету пика ");
     }
     ShowSignals(i, isfoundpik, iif( flagdivergence==1, true, false ) );
     //Print(ExtBuffer0[i],ExtBuffer1[i],ExtBuffer2[i],BuyBuffer );
  }
  
  return(0);
}
//+------------------------------------------------------------------+
int sShowSignals(int i ){
  BuyBuffer[i] = 0; SellBuffer[i] = 0; BufferSignalType[i]=OP_NONE;
  //string objname = "linestoporder"+Time[i];
  //ObjectDelete(objname  );
  //if( BufferSignalType[i] != OP_NONE )return (0); // сигнал сгенерирован
 
  //if ( flagshow !=0 ){
  //  if( direction == UP ) BuyBuffer[i] = High[i+1]+Point;else SellBuffer[i] = Low[i+1]-Point; // нарисовали стрелку 
  //  BufferSignalType[i] = iif(direction == UP, OP_BUYSTOP, OP_SELLSTOP); 
  //  double stoppos = iif(direction == UP, BuyBuffer[i], SellBuffer[i] );
  //  // сдесь же нужно отразить линию бай/селл стоп
  //  
  //  //int curtime = Time[0];
  //  //i nt curbar = curtime;
  //  ObjectCreate(objname, OBJ_TREND, 0, Time[i+3], stoppos, Time[i], stoppos   );
  //  ObjectSet(objname   , OBJPROP_RAY, 0);
  
  return( 0 );


  
  }

int sign( double v ) {if( v < 0 ) return( -1 );  return( 1 ); }
double iif( bool condition, double ifTrue, double ifFalse ){  if( condition ) return( ifTrue ); return( ifFalse );}
string iifStr( bool condition, string ifTrue, string ifFalse ) {  if( condition ) return( ifTrue );  return( ifFalse ); }
string SignalToStr(int sig ){
  if( sig == OP_BUYLIMIT ) return ("OP_BUYLIMIT" );
  if( sig == OP_SELLLIMIT ) return ("OP_SELLLIMIT" );
  if( sig == OP_BUY ) return ("OP_BUY" ); 
  if( sig == OP_BUYSTOP ) return ("OP_BUYSTOP" );
  if( sig == OP_SELL ) return ("OP_SELL" );
  if( sig == OP_SELLSTOP ) return ("OP_SELLSTOP" );
  if( sig == OP_NONE ) return ("OP_NONE" );
  if( sig == OP_CLOSEORDER ) return ("OP_CLOSEORDER" );

  return ( "undefined type if signal "+ sig  );

} 


  




int getoldertimeframe(int passedframe=0){
  int curper = Period();
  if(passedframe!=0)curper=passedframe;
  
  if( curper == PERIOD_M1 )return (PERIOD_M5);
  if( curper == PERIOD_M5)return (PERIOD_M15);
  if( curper == PERIOD_M15)return (PERIOD_M30);
  if( curper == PERIOD_M30)return (PERIOD_H1);
  if( curper == PERIOD_H1)return (PERIOD_H4);
  if( curper == PERIOD_H4)return (PERIOD_D1);
  if( curper == PERIOD_D1)return (PERIOD_W1);
  if( curper == PERIOD_W1)return (PERIOD_MN1);
  if( curper == PERIOD_MN1)return (0);
  return (0);
}

// ---- Money Management








double LotSize(double StopLossInPips, double RiskPercent, int desigion=1, double addsumtodepo = 0 ){ 
 int Leverage =  AccountLeverage(); 
 double PipValue = MarketInfo(Symbol(), MODE_TICKVALUE);
 double lotMM, FreeMargin;
 //Print("addsumtodepo is ", addsumtodepo );
 FreeMargin = AccountBalance( )+addsumtodepo  ; //AccountFreeMargin();
 lotMM = NormalizeDouble((FreeMargin*RiskPercent/100)/(StopLossInPips*PipValue),desigion);
 double minlot = 0.1;
 Print("Цена пункта=", PipValue, " Свободные средства=", FreeMargin, " Риск=", RiskPercent, " Число лотов=", lotMM);
 if(desigion == 2) minlot = 0.01;
 
   if (lotMM < minlot ) lotMM = minlot ;//Lots;
   if  (lotMM > 100) lotMM = 100;
   return (lotMM);
} 
 

string PeriodToStr( int curper ){
  if( curper == PERIOD_M1 )return ("M1");
  if( curper == PERIOD_M5)return ("M5");
  if( curper == PERIOD_M15)return ("M15");
  if( curper == PERIOD_M30)return ("M30");
  if( curper == PERIOD_H1)return ("H1");
  if( curper == PERIOD_H4)return ("H4");
  if( curper == PERIOD_D1)return ("D1");
  if( curper == PERIOD_W1)return ("W1");
  if( curper == PERIOD_MN1)return ("MN1");
  return ("период не определен");

}





