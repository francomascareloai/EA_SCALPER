//+------------------------------------------------------------------+
//|                                     MaksiGen_KaHaJI_CkaJIneP.mq4 |
//|                                                         MaksiGen |
//|                                                          http:// |
//+------------------------------------------------------------------+
#property copyright "MaksiGen"
#property link      "http://"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_color2 Violet
#property indicator_color3 DarkTurquoise
#property indicator_color4 Magenta
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
extern string Time_Start_1="08.15";
extern string Time_End_1="11.30";
extern string Time_Start_2="14.00";
extern string Time_End_2="17.30";
extern int MuH_IIIuPuHa_KaHaJIa=25;
double val_1[],val_2[],val_3[],val_4[],HighKaHaJI,LowKaHaJI;
string TextHour_Start_1,TextMinute_Start_1,TextHour_End_1,TextMinute_End_1;
string TextHour_Start_2,TextMinute_Start_2,TextHour_End_2,TextMinute_End_2;
string BbIBog;
int Hour_Start_1,Minute_Start_1,Hour_End_1,Minute_End_1;
int Hour_Start_2,Minute_Start_2,Hour_End_2,Minute_End_2;
int IIIuPuHa_KaHaJIa;
bool on_off_trade;
//datetime DateTime_Start_1,DateTime_Start_2,DateTime_End_1,DateTime_End_2;

int init()
{
//---- indicators
IndicatorBuffers(4);
SetIndexStyle(0,DRAW_LINE,1,3);
SetIndexStyle(1,DRAW_LINE,1,3);
SetIndexStyle(2,DRAW_LINE);
SetIndexStyle(3,DRAW_LINE);
SetIndexBuffer(0,val_1);
SetIndexBuffer(1,val_2);
SetIndexBuffer(2,val_3);
SetIndexBuffer(3,val_4);
//---- Time
TextHour_Start_1=StringSubstr(Time_Start_1,0,2);Hour_Start_1=StrToInteger(TextHour_Start_1);
TextMinute_Start_1=StringSubstr(Time_Start_1,3,2);Minute_Start_1=StrToInteger(TextMinute_Start_1);

TextHour_End_1=StringSubstr(Time_End_1,0,2);Hour_End_1=StrToInteger(TextHour_End_1);
TextMinute_End_1=StringSubstr(Time_End_1,3,2);Minute_End_1=StrToInteger(TextMinute_End_1);

TextHour_Start_2=StringSubstr(Time_Start_2,0,2);Hour_Start_2=StrToInteger(TextHour_Start_2);
TextMinute_Start_2=StringSubstr(Time_Start_2,3,2);Minute_Start_2=StrToInteger(TextMinute_Start_2);

TextHour_End_2=StringSubstr(Time_End_2,0,2);Hour_End_2=StrToInteger(TextHour_End_2);
TextMinute_End_2=StringSubstr(Time_End_2,3,2);Minute_End_2=StrToInteger(TextMinute_End_2);

// подгон времени "MSK" под время сервера Альпари
//Hour_Start_1=Hour_Start_1-2;Hour_End_1=Hour_End_1-2;
//Hour_Start_2=Hour_Start_2-2;Hour_End_1=Hour_End_2-2;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
int shift,i,ii;
int Counted_Bars=IndicatorCounted();

if (Period()>30)
{
if (Minute_Start_1!=0) {Minute_Start_1=0;}
if (Minute_End_1!=0) {Hour_End_1++;Minute_End_1=0;}
if (Minute_Start_2!=0) {Minute_Start_2=0;}
if (Minute_End_2!=0) {Hour_End_2++;Minute_End_2=0;}
}

//----
if (Counted_Bars>=Bars) Counted_Bars=Bars;
if(Counted_Bars<0) return(-1);//---- проверка на возможные ошибки

for (shift=Counted_Bars+10;shift>0;shift--)
  {
  on_off_trade=false;//-находим время торговли
  if (TimeHour(Time[shift])>Hour_Start_1 && TimeHour(Time[shift])<Hour_End_1) on_off_trade=true;
  if (TimeHour(Time[shift])==Hour_Start_1 && TimeMinute(Time[shift])>=Minute_Start_1) on_off_trade=true;
  if (TimeHour(Time[shift])==Hour_End_1 && TimeMinute(Time[shift])<=Minute_End_1) on_off_trade=true;

  if (TimeHour(Time[shift])>Hour_Start_2 && TimeHour(Time[shift])<Hour_End_2) on_off_trade=true;
  if (TimeHour(Time[shift])==Hour_Start_2 && TimeMinute(Time[shift])>=Minute_Start_2) on_off_trade=true;
  if (TimeHour(Time[shift])==Hour_End_2 && TimeMinute(Time[shift])<=Minute_End_2) on_off_trade=true;

  //---
  if (TimeHour(Time[shift])==Hour_Start_1 && TimeMinute(Time[shift])==Minute_Start_1)
   {
   HighKaHaJI=0;
   LowKaHaJI=10000;

   for (i=shift+MathRound((Hour_Start_1*60+Minute_Start_1)/Period());i>shift;i--)
     {
     if (High[i]>HighKaHaJI) HighKaHaJI=High[i];
     if (Low[i]<LowKaHaJI) LowKaHaJI=Low[i];
     }
   }
  //---


  if (on_off_trade)
    {
    val_1[shift]=HighKaHaJI;
    val_3[shift]=HighKaHaJI+10*Point;
    val_2[shift]=LowKaHaJI;
    val_4[shift]=LowKaHaJI-10*Point;
    }
  IIIuPuHa_KaHaJIa=(HighKaHaJI-LowKaHaJI)/Point;
}
if (IIIuPuHa_KaHaJIa>MuH_IIIuPuHa_KaHaJIa)
     {BbIBog=", Bay от "+DoubleToStr(HighKaHaJI,4)+", Sell от "+DoubleToStr(LowKaHaJI,4);}
else {BbIBog=", нет торговли";}
Comment("\n","\n","Рабочее время сервера: с ",TextHour_Start_1,":",TextMinute_Start_1," до ",TextHour_End_1,":",TextMinute_End_1,
" и с ",TextHour_Start_2,":",TextMinute_Start_2," до ",TextHour_End_2,":",TextMinute_End_2,
"\n","Ширина канала: ",IIIuPuHa_KaHaJIa,BbIBog);
//----
   return(0);
}
//+------------------------------------------------------------------+

