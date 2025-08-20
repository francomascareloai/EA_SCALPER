//+------------------------------------------------------------------+
//|                                                       Madlen.mq4 |
//|                                           Copyright © 2007, DKeN |
//|                                                  http://dken.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, DKeN"
#property link      "http://dken.biz"
//----
#property indicator_chart_window
#property indicator_buffers 2
//----
#property indicator_color1 Red
#property indicator_color2 Blue
/*
Update 5.0
- цвета линий изменены, исправлена отрисовка линий 45 и 315 
- сигнал в зависимости от положения цены между уровнями
- добавлена информация по среднедневному и средненедельному
- убран Мюррей, Ишимоку
Update 4.4
- добавлены настройки рисков 
по умолчанию 0.1 лот, 1% от депо
Update 4.31
- исправлены надписи:-)
Ipdate 4.3
- по умолчанию трендовые, фибо и уровни фракталов
Update 4.2
- добавлены уровни разворота по Мюррею
- удален Пивот
Update 4.1
- изменены уровни Фиббоначи
- добавлены флаги для отрисовки пивот уровней и сессий
- добавлена отрисовка Сессий Европейской и Американской на часовых графиках
- добавлен Pivot
Update 4.0
- добавлен индикатор Ишимоку (настройки по умолчанию для D1, W1, H4) 
- Используются только сигналы золотой и мертвый крест и отбой от Кеджун сен, остальные линии и облака убраны
Update 3.1
- добавлена отрисовка фиббоначи уроней
Update 3.0
- добавлены уровни по фракталам
- удалены функции сопровождения ордеров
Update 2.9
- подобраны коэф. для масштабов
Update 2.8
- убрано использование dll
- исправлены мелкие глюки
Update 2.7
- подправлен алгоритм рисования
- добавлена опция для принудительного рисования линий на предпоследней свече
Update 2.6
- линии отрисовываются при любой трансформации графика правильно! всегда 45 для 1:1
- улучшены правила для сигналов
Update 2.5.
- исправлен анализ свечей
- добавлен трейлинг
Update 2.4.
- убрана отрисовка по новому фракталу т.к. долго отрисовка длится
- Добавлена возможность рисовать либо по ЗигЗагу, либо по Фракталу, и в зависимости от этого берется за анализ.
- исправлена ошибка изменения угла при масштабировании, теперь он всегда 45.
Update 2.3.
- Добавлена отрисовка по модифицированному фракталу.
- изменен способ анализа сигналов
Update 2.2.
- Добавлена возможность открывать позиции по сигналу
*/
#include <stdlib.mqh>
string str="Madlen v5";
extern string __="Выдача сигнала";
extern bool cfg_Signal=false;
extern string _="Параметры отрисовки";
extern int cfg_Period=0; //D1
extern int cfg_MaxBars=5; //количество свечей которые отрисовываются
extern bool cfg_Ray=true; //отрисовка лучами или нет
extern bool cfg_DrawLast=true; //отрисовка предпоследней свечки.
extern bool cfg_DrawFibo=true; //отрисовка Fibo
extern string _Session="Настройки отрисовки сессий";
extern bool cfg_DrawSession=true;
extern color cfg_SessionColor1=MediumTurquoise; //Европейская
extern color cfg_SessionColor2=Gainsboro; //Американская
extern string _Risks="Риски";
double cfg_RiskLots=0.1;
extern  double cfg_Risk=0.01;
extern  int    cfg_RiskLevelPoint=25;
/*
М5 72-144-288
М10 36-72-144
Н1 12-24-120 или 120-240-480
H4 30-60-120
D1 5-10-20 или 9-26-52
W1 9-26-52
*/
//local
double up,low,dUp,dLow; //fractals
double width=0; //kanal
int g_Zoom=36; //шаг между барами для  1:1 32,16,8,4,1 степени 2-ки
int g_typeSignal=-1; //signal
double Pivot; //pivot
double haOpen, haHigh, haLow, haClose; //heiken ashi
int ExtCountedBars=0;
double dFibo38,dFibo50,dFibo62,dFibo100,dFibo162,dFibo200,dFibo262;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   DeleteAll();
     if(Symbol()=="XAUUSD")
     {
        switch(Period())
        {
            case PERIOD_W1: g_Zoom=32*5; break;
            case PERIOD_D1: g_Zoom=32*5; break;
            case PERIOD_H4: g_Zoom=9*5; break;
            case PERIOD_H1: g_Zoom=32; break;
            default: g_Zoom=1;
           }
         }
         else
         {
                 switch(Period())
                 {
                     case PERIOD_W1: g_Zoom=48; break;
                     case PERIOD_D1: g_Zoom=32; break;
                     case PERIOD_H4: g_Zoom=16; break;
                     case PERIOD_H1: g_Zoom=8; break;
                     default: g_Zoom=1;
                    }
                 }
                     //предварительная отрисовка
                     int last_pos=-1;
                     int k=0;
                     int f1=0,f2=0;
                     int it1,it2;
                       for(int i=1;i<=Bars;i++)
                       {
                        up=iFractals(Symbol(),cfg_Period,MODE_UPPER,i);
                        low=iFractals(Symbol(),cfg_Period,MODE_LOWER,i);
//----
                          if(k<cfg_MaxBars && (low>0 || up>0)) 
                          {
                           DrawLine45(i,0);
                           if(last_pos==-1) last_pos=i; k++;
                          }
                        if(f1==0 && up>0){ DrawLevel(up,low); f1++; it1=i;}
                        if(f2==0 && low>0){ DrawLevel(up,low); f2++; it2=i;}
                       }
                     if(cfg_DrawLast) DrawLine45(1,1);
                     if(cfg_DrawFibo) DrawFibo(it1,it2);
//----
                       if(Period()<=PERIOD_H4 && cfg_DrawSession==true)
                       {
                        DrawRect("Europe_session",10,dUp,20,dLow,cfg_SessionColor1);
                        DrawRect("USA_session",15,dUp,23,dLow,cfg_SessionColor2);
                       }
                     //double price=PriceTriagl(last_pos); //получим точку пересечения
                     //double line45[2];
                     //GetCurrentLine(line45,last_pos,0);//получим координаты линий
                     //AnalizSignal(price,line45,true);
                  //----
                     return(0);
                    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                        int deinit()
                          {
                           //удаление всех линий
                           DeleteAll();
                        //----
                           return(0);
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          void DeleteAll()
                          {
                           ObjectsDeleteAll(0,OBJ_TREND);
                           ObjectsDeleteAll(0,OBJ_HLINE);
                           ObjectsDeleteAll(0,OBJ_FIBO);
                           ObjectsDeleteAll(0,OBJ_RECTANGLE);
                           ObjectsDeleteAll(0,OBJ_TEXT);
                           //ArrayInitialize(fibo,0);
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                        int start()
                          {
                           // if(IsDllsAllowed()==FALSE){Alert("Разрешите использование функций из DLL!"); return (0);}
                             if(IsTradeContextBusy())
                             {
                              Print("Торговый поток занят. Подождите");
                              return(0);
                             }
                             if(Bars<=10) 
                             {
                              Print("Нет истории баров!");
                              return(0);
                             }
                        //----
                           DeleteAll();
                           //получение данных от фракталов и зигзага
                           int last_pos=-1;
                           int k=0;
                           int f1=0,f2=0;
                           int it1,it2;
                             for(int i=1;i<=Bars;i++)
                             {
                              up=iFractals(Symbol(),cfg_Period,MODE_UPPER,i);
                              low=iFractals(Symbol(),cfg_Period,MODE_LOWER,i);
//----
                                if(k<cfg_MaxBars && (low>0 || up>0)) 
                                {
                                 DrawLine45(i,0);
                                 if(last_pos==-1) last_pos=i; k++;
                                }
                              if(f1==0 && up>0){ DrawLevel(up,low); f1++; it1=i; dUp=up;}
                              if(f2==0 && low>0){ DrawLevel(up,low); f2++; it2=i; dLow=low;}
                             }
                           width=MathAbs(dUp-dLow)/Point;
                           if(cfg_DrawLast) DrawLine45(1,1);
                           if(cfg_DrawFibo) DrawFibo(it1,it2);
//----
                             if(Period()<=PERIOD_H4 && cfg_DrawSession==true)
                             {
                              DrawRect("Europe_session",10,dUp,20,dLow,cfg_SessionColor1);
                              DrawRect("USA_session",15,dUp,23,dLow,cfg_SessionColor2);
                             }
                           //(string rname,int h1,double v1,int h2,double v2,color c)
                           double price=PriceTriagl(last_pos); //получим точку пересечения
                           double line45[2];
                           GetCurrentLine(line45,last_pos,0);//получим координаты линий
                           AnalizSignal(price,line45,false);
                        //----
                           return(0);
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          void AnalizSignal(double price,double line45[2],bool isInit)
                          {
                           double l=MarketInfo(Symbol(),MODE_SWAPLONG);
                           double s=MarketInfo(Symbol(),MODE_SWAPSHORT);
                           double swap=0;
                           string sSwap="";
                           double sl_b=0,sl_s=0;
                           double osl_b=0,osl_s=0;
                           double lot_b=0,lot_s=0;
                           int iFiboSignal=-1;
                           double dUp=ObjectGet("level_up",OBJPROP_PRICE1);
                           double dDown=ObjectGet("level_down",OBJPROP_PRICE1);
//----                           
                             if(Bid>dDown && Ask<dUp)
                             {
                              sl_s=dUp+Point*cfg_RiskLevelPoint;
                              sl_b=dDown-Point*cfg_RiskLevelPoint;
                              osl_b=dDown+Point*10;
                              osl_s=dUp-Point*10;
                              lot_s=GetLotOfRisk(cfg_Risk,sl_s,0);
                              lot_b=GetLotOfRisk(cfg_Risk,sl_b,1);
                             }
                             else
                                if(Bid>dUp && Bid>dDown)
                                {
                                 sl_s=0;lot_s=0;
                                 sl_b=dUp-Point*cfg_RiskLevelPoint;
                                 osl_b=dUp+Point*10;
                                 osl_s=0;
                                 lot_b=GetLotOfRisk(cfg_Risk,sl_b,1);
                                }
                                else
                                if(Ask<dUp && Ask<dDown)
                                {
                                 sl_b=0;lot_b=0;
                                 sl_s=dDown+Point*cfg_RiskLevelPoint;
                                 osl_s=dDown-Point*10;
                                 lot_s=GetLotOfRisk(cfg_Risk,sl_s,0);
                                }
                           InitFibo();
                           iFiboSignal=AnalizeFibo();
                           string sFiboSignal="NOT";
                           if(iFiboSignal==OP_BUY) sFiboSignal="BUY";
                           else if(iFiboSignal==OP_SELL) sFiboSignal="SELL";
//----
                           if(l>0 && s<0){sSwap="BUY"; swap=l;}
                           else if(l<0 && s>0){sSwap="SELL"; swap=s;}
                              else if(l>0 && s>0){sSwap="BUY,SELL"; swap=MathMin(l,s);}
                                 else {sSwap=""; swap=l;}
                           //line45[0] = 315
                           //line45[1] = 45
                             if(iClose(Symbol(),cfg_Period,0)>price && iClose(Symbol(),cfg_Period,0)>line45[1] && iClose(Symbol(),cfg_Period,0)>line45[0]  && line45[1]!=0 && iFiboSignal==OP_BUY)
                             {
                              Comment("Signal: BUY,Close: ",iClose(Symbol(),cfg_Period,1),", line45: ",line45[1],"\nWidthCanal: ",width," pips"," SwapType: ",sSwap," = ",swap,
                              "\n","Risk: ",cfg_Risk*100,"% RiskLots for buy(",lot_b,"), sell(",lot_s,")","\nNormal open for buy(",osl_b,"), sel(",osl_s,")",
                              "\nStop for buy(",sl_b,"), sell(",sl_s,")\n",GetMidleDay(20),"\nFibo signal: ",sFiboSignal);
//----
                                if((g_typeSignal==OP_SELL || isInit==true)&& cfg_Signal==true )
                                {
                                 Alert(Hour(),":",Minute()," (",Symbol(),") Signal: BUY ,Close: ",iClose(Symbol(),cfg_Period,1),", line45: ",line45[1],
                          "\n","Risk: ",cfg_Risk*100,"% RiskLots for buy(",lot_b,"), sell(",lot_s,")","\nNormal open for buy(",osl_b,"), sel(",osl_s,")",
                          "\nStop for buy(",sl_b,"), sell(",sl_s,")\n",GetMidleDay(20));
                                }
                              g_typeSignal=OP_BUY;
                             }
                             else if(iClose(Symbol(),cfg_Period,0)<price && iClose(Symbol(),cfg_Period,0)<line45[0] && iClose(Symbol(),cfg_Period,0)<line45[1] && line45[0]!=0 && iFiboSignal==OP_SELL)
                             {
                                 Comment("Signal: SELL ,Close: ",iClose(Symbol(),cfg_Period,1),", line45: ",line45[1],"\nWidthCanal: ",width," pips"," SwapType: ",sSwap," = ",swap,
                                 "\n","Risk: ",cfg_Risk*100,"% RiskLots for buy(",lot_b,"), sell(",lot_s,")","\nNormal open for buy(",osl_b,"), sel(",osl_s,")",
                                 "\nStop for buy(",sl_b,"), sell(",sl_s,")\n",GetMidleDay(20),"\nFibo signal: ",sFiboSignal);
//----
                                   if((g_typeSignal==OP_BUY || isInit==true)&& cfg_Signal==true)
                                   {
                                    Alert(Hour(),":",Minute()," (",Symbol(),") Signal: SELL ,Close: ",iClose(Symbol(),cfg_Period,1),",line315: ",line45[0],
                              "\n","Risk: ",cfg_Risk*100,"% RiskLots for buy(",lot_b,"), sell(",lot_s,")","\nNormal open for buy(",osl_b,"), sel(",osl_s,")",
                              "\nStop for buy(",sl_b,"), sell(",sl_s,")\n",GetMidleDay(20));
                                   }
                                 g_typeSignal=OP_SELL;
                                }
                                else 
                                {
                                 Comment("Signal: NOT ,Close: ",iClose(Symbol(),cfg_Period,1),", line45: ",line45[1],"\nWidthCanal: ",width," pips"," SwapType: ",sSwap," = ",swap,
                              "\n","Risk: ",cfg_Risk*100,"% RiskLots for buy(",lot_b,"), sell(",lot_s,")","\nNormal open for buy(",osl_b,"), sel(",osl_s,")",
                              "\nStop for buy(",sl_b,"), sell(",sl_s,")\n",GetMidleDay(20),"\nFibo signal: ",sFiboSignal);
                                 g_typeSignal=-1;
                                }
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          void InitFibo()
                          {
                           string sFibo="fibo_level";
                           double dUp=ObjectGet("level_up",OBJPROP_PRICE1);
                           double dDown=ObjectGet("level_down",OBJPROP_PRICE1);
//----
                             if(ObjectFind(sFibo)!=-1) 
                             {
                                if(Ask<dDown)
                                {
                                 dFibo38=NormalizeDouble(dUp-(dUp-dDown)*0.382,Digits); //0
                                 dFibo50=NormalizeDouble(dUp-(dUp-dDown)*0.5,Digits); //0
                                 dFibo62=NormalizeDouble(dUp-(dUp-dDown)*0.618,Digits); //0
                                 dFibo100=NormalizeDouble(dUp-(dUp-dDown)*1,Digits); //0
                                 dFibo162=NormalizeDouble(dUp-(dUp-dDown)*1.618,Digits); //0
                                 dFibo200=NormalizeDouble(dUp-(dUp-dDown)*2,Digits); //0
                                 dFibo262=NormalizeDouble(dUp-(dUp-dDown)*2.618,Digits); //0
                                 }
                                 else
                                 {
                                 dFibo38=NormalizeDouble(dDown+(dUp-dDown)*0.382,Digits); //0
                                 dFibo50=NormalizeDouble(dDown+(dUp-dDown)*0.5,Digits); //0
                                 dFibo62=NormalizeDouble(dDown+(dUp-dDown)*0.618,Digits); //0
                                 dFibo100=NormalizeDouble(dDown+(dUp-dDown)*1,Digits); //0
                                 dFibo162=NormalizeDouble(dDown+(dUp-dDown)*1.618,Digits); //0
                                 dFibo200=NormalizeDouble(dDown+(dUp-dDown)*2,Digits); //0
                                 dFibo262=NormalizeDouble(dDown+(dUp-dDown)*2.618,Digits); //0
                                }
                             }
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          int AnalizeFibo()
                          {
                           double dUp=ObjectGet("level_up",OBJPROP_PRICE1);
                           double dDown=ObjectGet("level_down",OBJPROP_PRICE1);
                           double price=Ask;
                           int iSignal=-1;
                             if(price<dUp && price>dDown)
                             {
                              if(price>dFibo38 && price<dFibo50) iSignal=OP_SELL;
                              else
                                 if(price>dFibo50 && price<dFibo62) iSignal=OP_BUY;
                             }
                           else if(price>dUp && price>dFibo100 && price<dFibo162) iSignal=OP_BUY;
                              else if(price<dDown && price<dFibo100 && price>dFibo162) iSignal=OP_SELL;
                                 else if(price<dDown && price<dFibo200 && price>dFibo262) iSignal=OP_BUY;
                                    else if(price>dUp && price>dFibo200 && price<dFibo262) iSignal=OP_SELL;
                                       else iSignal=-1;
                           // Print(iSignal,"Price: ",price," dUp: ",dUp," dDown: ",dDown," 100: ",dFibo100," 162: ",dFibo162);
                           return(iSignal);
                          }
                        //точка пересечения прямых для конкретного бара
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          double PriceTriagl(int i)
                          {
                           if(i==-1) return(0);
                           return((iHigh(Symbol(),cfg_Period,i)-iLow(Symbol(),cfg_Period,i))/2+iLow(Symbol(),cfg_Period,i));
                          }
                        //координата прямых для конкретного бара, от определенной свечки
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetCurrentLine(double &price[]/*buf size 2*/,int i,int bar)
{
                           price[0]=0;
                           price[1]=0;
                           if(i==-1) return(0);
                           string ss=TimeToStr(iTime(Symbol(),cfg_Period,i));
                             for(int j=0;j<StringLen(ss);j++)
                             {
                              if(StringGetChar(ss,j)=='.' || StringGetChar(ss,j)==':' || StringGetChar(ss,j)==' ')
                                 ss=StringSetChar(ss,j,'_');
                             }
                           string n315h="kanal315h_"+ss;
                           string n45l="kanal45l_"+ss;
                           double t=0;
                           //t=g_Zoom/c*Point; //коэф. трансформации
                           t=g_Zoom*Point;
                           double y2,y1;
                           double pi=3.1415926535;
                             if(ObjectFind(n315h)==0)
                             {
                              y1=iHigh(Symbol(),cfg_Period,i);
                              price[0]=y1+(i-bar)*MathTan(pi*315/180)*t;
                              // Print("y1=",y1," pp1=",price[0]," i315=",i," bar=",bar);
                             }
                             if(ObjectFind(n45l)==0)
                             {
                              y1=iLow(Symbol(),cfg_Period,i);
                              price[1]=y1+(i-bar)*MathTan(pi*45/180)*t;
                              //Print("y1=",y1," pp2=",price[1]," i45=",i," bar=",bar);
                             }
                          }
                        //отрисовка линий
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          void DrawLine45(int i,int type)
                          { //0-now draw low
                           string ss=TimeToStr(iTime(Symbol(),cfg_Period,i));
                             for(int j=0;j<StringLen(ss);j++)
                             {
                              if(StringGetChar(ss,j)=='.' || StringGetChar(ss,j)==':' || StringGetChar(ss,j)==' ')
                                 ss=StringSetChar(ss,j,'_');
                             }
                           string n315h="kanal315h_"+ss;
                           string n45l="kanal45l_"+ss;
                           double t=0.0;
//----
                           t=g_Zoom*Point; //коэф. трансформации
                           //Print("pix=",b," height=",c," t=",t);
                           double y2,y1;
                           double pi=3.1415926535;
                           color cCanal,cLevel;
                             if(type==1)
                             {
                              cCanal=Lime;
                              cLevel=Orange;
                              }
                              else
                              {
                              cCanal=White;
                              cLevel=Red;
                             }
                           DrawElem(n315h,iHigh(Symbol(),cfg_Period,i),i,t,315,indicator_color2);
                           DrawElem(n45l,iLow(Symbol(),cfg_Period,i),i,t,45,indicator_color1);
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          void DrawElem(string name,double y1,int i,double t,int angle,color icolor,int bar=1)
                          {
                           double y2;
                           double pi=3.1415926535;
                             if(ObjectFind(name)==-1 )
                             {
                              //y1=iOpen(Symbol(),cfg_Period,i);
                              y2=y1+MathTan(pi*angle/180)*t*i;
                              ObjectCreate(name,OBJ_TREND,0,iTime(Symbol(),cfg_Period,i),y1,iTime(Symbol(),cfg_Period,0),y2);
                              ObjectSet (name,OBJPROP_RAY,cfg_Ray);
                              ObjectSet (name,OBJPROP_COLOR,icolor);
                              }
                              else
                              {
                              // y1=iOpen(Symbol(),cfg_Period,i);
                              ObjectDelete(name);
                              y2=y1+MathTan(pi*angle/180)*t*i;
                              ObjectCreate(name,OBJ_TREND,0,iTime(Symbol(),cfg_Period,i),y1,iTime(Symbol(),cfg_Period,0),y2);
                              ObjectSet (name,OBJPROP_RAY,cfg_Ray);
                              ObjectSet (name,OBJPROP_COLOR,icolor);
                             }
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          void DrawLevel(double up, double low)
                          {
                           color icolor=Blue;
                           string sUP="level_up";
                           string sDOWN="level_down";
                           string sUP_Text="level_up_text";
                           string sDOWN_Text="level_down_text";
//----
                             if(up>0){ icolor=Blue;
                              if(ObjectFind(sUP)==0)  ObjectMove(sUP,0,iTime(Symbol(),cfg_Period,0),up);
                              else ObjectCreate(sUP,OBJ_HLINE,0,0,up);
                              //  Print("up=",up);  
                              ObjectSet(sUP,OBJPROP_COLOR,icolor);
                              ObjectSet(sUP,OBJPROP_WIDTH,3);
                                if(ObjectFind(sUP_Text)==-1)
                                {
                                 ObjectCreate(sUP_Text, OBJ_TEXT, 0, Time[1], up);
                                 ObjectSetText(sUP_Text,"HIGH-Level", 10, "Times New Roman", icolor);
                                 }
                                 else
                                 {
                                 ObjectMove(sUP_Text,0,Time[1],up);
                                }
                             }
                             if(low>0)
                             { 
                             icolor=Red;
                              if(ObjectFind(sDOWN)==0)  ObjectMove(sDOWN,0,iTime(Symbol(),cfg_Period,0),low);
                              else ObjectCreate(sDOWN,OBJ_HLINE,0,0,low);
                              // Print("down=",low);
                              ObjectSet(sDOWN,OBJPROP_COLOR,icolor);
                              ObjectSet(sDOWN,OBJPROP_WIDTH,3);
                                if(ObjectFind(sDOWN_Text)==-1)
                                {
                                 ObjectCreate(sDOWN_Text, OBJ_TEXT, 0, Time[1], low);
                                 ObjectSetText(sDOWN_Text,"LOW-Level", 10, "Times New Roman", icolor);
                                 }else{
                                 ObjectMove(sDOWN_Text,0,Time[1],low);
                                }
                             }
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          void DrawFibo(int it1, int it2)
                          {
                           string sUP="level_up";
                           string sDOWN="level_down";
                           string sFibo="fibo_level";
                           double p1,p2;
                           datetime t1,t2;
                             if(ObjectFind(sUP)==0)
                             {
                              p1=ObjectGet(sUP,OBJPROP_PRICE1);
                              t1=iTime(Symbol(),cfg_Period,it1);
                             }
                             if(ObjectFind(sDOWN)==0)
                             {
                              p2=ObjectGet(sDOWN,OBJPROP_PRICE1);
                              t2=iTime(Symbol(),cfg_Period,it2);
                             }
                           // Print(t1," ",t2);
                           //string s0,s100,s162,s262,s23,s50,s38,s62;
                             if(p1>0 && p2>0)
                             {
                              ObjectDelete(sFibo);
                                if(ObjectFind(sFibo)==-1) 
                                {
                                   if(Ask<p1 && Ask>p2)
                                   {
                                    if(it1<it2)
                                       ObjectCreate(sFibo,OBJ_FIBO,0,t1,p1,t2,p2);
                                    else
                                       ObjectCreate(sFibo,OBJ_FIBO,0,t2,p2,t1,p1);
                                   }
                                 if(Bid<p1 && Bid<p2)  ObjectCreate(sFibo,OBJ_FIBO,0,t2,p2,t1,p1);
                                 else
                                    if(Ask>p2 && Ask>p1)  ObjectCreate(sFibo,OBJ_FIBO,0,t1,p1,t2,p2);
                                }
                             }
                           ObjectSet(sFibo,OBJPROP_FIBOLEVELS,9);
                           ObjectSet(sFibo,OBJPROP_LEVELCOLOR,Yellow);
                           ObjectSet(sFibo,OBJPROP_FIRSTLEVEL+0,0);
                           ObjectSet(sFibo,OBJPROP_FIRSTLEVEL+1,0.236);
                           ObjectSet(sFibo,OBJPROP_FIRSTLEVEL+2,0.382);
                           ObjectSet(sFibo,OBJPROP_FIRSTLEVEL+3,0.5);
                           ObjectSet(sFibo,OBJPROP_FIRSTLEVEL+4,0.618);
                           ObjectSet(sFibo,OBJPROP_FIRSTLEVEL+5,1);
                           ObjectSet(sFibo,OBJPROP_FIRSTLEVEL+6,1.618);
                           ObjectSet(sFibo,OBJPROP_FIRSTLEVEL+7,2);
                           ObjectSet(sFibo,OBJPROP_FIRSTLEVEL+8,2.618);
//----
                           ObjectSetFiboDescription(sFibo,0,"0%% (%$)");
                           ObjectSetFiboDescription(sFibo,1,"23%% (%$)");
                           ObjectSetFiboDescription(sFibo,2,"38%% (%$)");
                           ObjectSetFiboDescription(sFibo,3,"50%% (%$)");
                           ObjectSetFiboDescription(sFibo,4,"62%% (%$)");
                           ObjectSetFiboDescription(sFibo,5,"100%% (%$)");
                           ObjectSetFiboDescription(sFibo,6,"162%% (%$)");
                           ObjectSetFiboDescription(sFibo,7,"200%% (%$)");
                           ObjectSetFiboDescription(sFibo,8,"262%% (%$)");
                           //    Print(MathMin(p1,p2)+MathAbs(p1-p2)*0.5);
                           // InitFibo(p1,p2);
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                        void DrawRect(string rname,int h1,double v1,int h2,double v2,color c)
                          {
                           datetime dx,dx2;
                           dx=StrToTime(Year()+"."+Month()+"."+Day()+" "+h1+":00");
                           dx2=StrToTime(Year()+"."+Month()+"."+Day()+" "+h2+":59");
                           if(ObjectFind(rname)!=-1)
                              ObjectDelete(rname);
                           ObjectCreate(rname,OBJ_RECTANGLE,0,dx,v1,dx2,v2);
                           ObjectSet(rname,OBJPROP_COLOR,c);
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          double GetLotOfRisk(double risk,double stop,int type)
                          {
                           RefreshRates();
                           double b=AccountBalance();
                           double point=MarketInfo(Symbol(),MODE_TICKVALUE);
                           double procent=b*risk;
                           double cena=MarketInfo(Symbol(),MODE_ASK);
                           if(type==0) cena=MarketInfo(Symbol(),MODE_BID);
                             if(cena>0 && point >0){
                              double lot=NormalizeDouble((procent/point)/(MathAbs(cena-stop)/MarketInfo(Symbol(),MODE_POINT)),2);
                              return(lot);
                             }
                           return(0);
                          }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
                          string GetMidleDay(int iDaysNumber)
                          {
                           double avg,avg2;
                           int x;
                           string comm="";
                           avg=0; avg2=0;
//----
                             for(x=1;x<=iDaysNumber;x++)
                             {
                              avg=avg+(iHigh(NULL,PERIOD_D1,x)-iLow(NULL,PERIOD_D1,x))/iDaysNumber;
                              avg2=avg2+(iHigh(NULL,PERIOD_W1,x)-iLow(NULL,PERIOD_W1,x))/iDaysNumber;
                             }
                           double last_day=iHigh(NULL,PERIOD_D1,0)-iLow(NULL,PERIOD_D1,0);
                           double last_week=iHigh(NULL,PERIOD_W1,0)-iLow(NULL,PERIOD_W1,0);
                           comm="VariantDay: "+DoubleToStr(avg/Point,2)
                           +", Current VarDay: "+DoubleToStr(last_day/Point,2)
                           +"\nVariantWeek: "+DoubleToStr(avg2/Point,2)
                           +", Current VarWeek: "+DoubleToStr(last_week/Point,2);
                           return(comm);
                          }
                        //work
//+------------------------------------------------------------------+