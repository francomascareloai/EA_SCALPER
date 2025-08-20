//+------------------------------------------------------------------+
//|                                              TrendLines_Auto.mq4 |
//|                                           Copyright © 2011, dken |
//|                                                   http://dken.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, dken"
#property link      "http://dken.ru"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Black

extern string _s0="Настройки общие";

extern bool Break=true;//рисуем стрелки согласно пробою или отбою
extern bool Expand=true;// рисовать по умолчанию расширяющиеся треугольники

extern bool UseAlert=true;
extern bool alertDebug=true;
extern bool alertSound=true;
extern bool alertMessage=false;
extern string fileSound="alert2.wav";
//цвета линий
extern string TrendUpName="TrendlineUp";
extern string TrendDnName="TrendlineDn";

extern color TrendUp=Blue;
extern color TrendDn=Red;

extern int otstup=0;//отступ стрелки от свечи pips

extern string _s1="Настройки ZZ";
extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
double buy[],sell[],stop[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
// 2 буфера для отображения стрелок
// буфер для хранения стопа
   IndicatorShortName("Trend Lines Signal");
   IndicatorBuffers(3);
   SetIndexBuffer(0,buy);
   SetIndexBuffer(1,sell);
   SetIndexBuffer(2,stop);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexStyle(2,DRAW_NONE);
   
   SetIndexArrow(0,233);//buy
   SetIndexArrow(1,234);//sell
      
   SetIndexLabel(0,"buy");
   SetIndexLabel(1,"sell"); 
   SetIndexLabel(2,"stop"); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   //удалить объекты
   ObjectDelete(TrendUpName);
   ObjectDelete(TrendDnName);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   ArrayInitialize(buy,EMPTY_VALUE);
   ArrayInitialize(sell,EMPTY_VALUE);
   ArrayInitialize(stop,EMPTY_VALUE);
//----
   //ЗЗ определяем 2 последние вершинки и 2 низинки
   // если вершинки идут вниз, то строим трендовую линию, если нет, то удаляем ее
   // если низинки идут вверх то строим линию, если вниз то удаляем (опционально, для определения расширяющихзся треугольников
   //когда определили куда идет тренд, ждем пересечения и сигналим когда закрылись выше а до этого были ниже (low - close)
   //рисуем в этой точке стрелку с отступом от свечки на Н пунктов и сохраняем в память точку для стопа
   //сигнал ловим опционально либо на пробой либо на отбой по умолчанию пробой
      
   double zzUp1=0,zzUp2=0;   
   double zzDn1=0,zzDn2=0;
   int iUp1,iUp2,iDn1,iDn2;
   double zzCurrent=0,zzTmp;
   int j=0,trend=0;
   
   for(int i=0;i<Bars;i++){
         
      zzTmp=iCustom(NULL,0,"ZigZag",ExtDepth,ExtDeviation,ExtBackstep,0,i);//current
      if(zzTmp>0.0 && j==0) {zzCurrent=zzTmp; j=1;}
      
      if(zzTmp>0.0 && j==1 && zzTmp<zzCurrent && zzDn1==0) {zzDn1=zzTmp; j=2; iDn1=i; trend=-1;}
      if(zzTmp>0.0 && j==1 && zzTmp>zzCurrent && zzUp1==0) {zzUp1=zzTmp; j=2; iUp1=i; trend=1; }
      
      if(trend==-1){
         if(zzTmp>0.0 && j==2 && zzTmp>zzDn1 && zzUp1==0) {zzUp1=zzTmp; iUp1=i; j=3;}
         if(zzTmp>0.0 && j==3 && zzTmp<zzUp1 && zzDn2==0) {zzDn2=zzTmp; iDn2=i; j=4;}
         if(zzTmp>0.0 && j==4 && zzTmp>zzDn2 && zzUp2==0) {zzUp2=zzTmp; iUp2=i; j=5; break;}
      }
      if(trend==1){
         if(zzTmp>0.0 && j==2 && zzTmp<zzUp1 && zzDn1==0) {zzDn1=zzTmp; iDn1=i; j=3;}
         if(zzTmp>0.0 && j==3 && zzTmp>zzDn1 && zzUp2==0) {zzUp2=zzTmp; iUp2=i; j=4;}
         if(zzTmp>0.0 && j==4 && zzTmp<zzUp2 && zzDn2==0) {zzDn2=zzTmp; iDn2=i; j=5; break;}
      }
   }
   
   if(zzUp1!=0.0 && zzUp2!=0.0 && zzDn1!=0.0 && zzDn2!=0.0){
      
      if(zzUp2>zzUp1 || Expand){
         if(ObjectFind(TrendDnName)==-1) {

            if(ObjectCreate(TrendDnName,OBJ_TREND,0,iTime(NULL,0,iUp2),zzUp2,iTime(NULL,0,iUp1),zzUp1)){
                 ObjectSet(TrendDnName,OBJPROP_COLOR,TrendDn);                
                 ObjectSet(TrendDnName,OBJPROP_WIDTH,2);
                 ObjectSet(TrendUpName,OBJPROP_RAY,TRUE);
            }
            
         }
         else {
            ObjectSet(TrendDnName,OBJPROP_TIME1,iTime(NULL,0,iUp2));
            ObjectSet(TrendDnName,OBJPROP_PRICE1,zzUp2);
            ObjectSet(TrendDnName,OBJPROP_TIME2,iTime(NULL,0,iUp1));
            ObjectSet(TrendDnName,OBJPROP_PRICE2,zzUp1);
         }
      }
      
      if(zzDn2<zzDn1 || Expand){
         if(ObjectFind(TrendUpName)==-1) {

            if(ObjectCreate(TrendUpName,OBJ_TREND,0,iTime(NULL,0,iDn2),zzDn2,iTime(NULL,0,iDn1),zzDn1)){
                 ObjectSet(TrendUpName,OBJPROP_COLOR,TrendUp);                
                 ObjectSet(TrendUpName,OBJPROP_WIDTH,2);
                 ObjectSet(TrendUpName,OBJPROP_RAY,TRUE);
            }
            
         }
         else {
            ObjectSet(TrendUpName,OBJPROP_TIME1,iTime(NULL,0,iDn2));
            ObjectSet(TrendUpName,OBJPROP_PRICE1,zzDn2);
            ObjectSet(TrendUpName,OBJPROP_TIME2,iTime(NULL,0,iDn1));
            ObjectSet(TrendUpName,OBJPROP_PRICE2,zzDn1);
         }
      }
      
      //check cross
      is_Signal(TrendUpName,iUp1,1,1);
      is_Signal(TrendDnName,iDn1,1,-1);
      
      if(buy[1]!=EMPTY_VALUE) doAlert("BUY",UseAlert,alertDebug,alertSound,alertMessage,false,false);
      if(sell[1]!=EMPTY_VALUE) doAlert("SELL",UseAlert,alertDebug,alertSound,alertMessage,false,false);
   
   }

  }
//+------------------------------------------------------------------+
void is_Signal(string n,int ist,int ien,int trend){
   for(int j=ien;j<=ist;j++){
         double price=ObjectGetValueByShift(n,j);
         if(price==0) break;
         
         if(Break && trend==1 && iHigh(NULL,0,j)>price && iClose(NULL,0,j)<price){ sell[j]=iHigh(NULL,0,j+1)+otstup*Point; stop[j]=iHigh(NULL,0,j+1);} 
         if(Break && trend==-1 && iLow(NULL,0,j)<price && iClose(NULL,0,j)>price){ buy[j]=iLow(NULL,0,j+1)-otstup*Point; stop[j]=iLow(NULL,0,j+1);}
         
         if(!Break && trend==-1 && iOpen(NULL,0,j)>price && iClose(NULL,0,j)<price) {sell[j]=iHigh(NULL,0,j+1)+otstup*Point; stop[j]=iHigh(NULL,0,j+1);}
         if(!Break && trend==1 && iOpen(NULL,0,j)<price && iClose(NULL,0,j)>price){buy[j]=iLow(NULL,0,j+1)-otstup*Point; stop[j]=iLow(NULL,0,j+1);}
         
      }  
}

void doAlert(
string doWhat,
bool UseAlert=false,
bool alertDebug=false,
bool alertSound=false,
bool alertMessage=false,
bool alertMail=false,
bool alertPhone=false)
  {
   if(UseAlert==false) return;
   //int pause=5*60;   
   static string   previousAlert="nothing";
   static datetime previousTime=0;
   string message;
//----
   if(Time[1]==previousTime) return ;
   
   
     if (previousAlert!=doWhat || Time[1]!=previousTime) 
     {
      previousAlert =doWhat;
      previousTime  =Time[1];
//----
      string sPeriod="";
      switch(Period()){
      case PERIOD_M1: sPeriod="M1"; break;
      case PERIOD_M5: sPeriod="M5"; break;
      case PERIOD_M15: sPeriod="M15"; break;
      case PERIOD_M30: sPeriod="M30"; break;
      case PERIOD_H1: sPeriod="H1"; break;
      case PERIOD_H4: sPeriod="H4"; break;
      case PERIOD_D1: sPeriod="D1"; break;
      case PERIOD_W1: sPeriod="W1"; break;
      case PERIOD_MN1: sPeriod="MN1"; break;
      }
      
      //message= StringConcatenate(name," Period: ",sPeriod," signal is ",doWhat);
      if (alertMessage) Alert(doWhat);
      if (alertSound){   PlaySound(fileSound); }//"news.wav" 
      if (alertDebug) Print(doWhat);
      if (alertMail) SendMail("signal",doWhat);
      //if (alertPhone) SendMail("signal","Channel: ss7/89504991199\r\nCallerid: 3452230009\r\nMaxRetries: 100\r\nRetryTime: 120\r\nWaitTime: 50\r\nContext: alpari\r\nExtension: s\r\nPriority: 1\r\nArchive: Yes");
      
     }
  }//+-------------------------------------------------------------

