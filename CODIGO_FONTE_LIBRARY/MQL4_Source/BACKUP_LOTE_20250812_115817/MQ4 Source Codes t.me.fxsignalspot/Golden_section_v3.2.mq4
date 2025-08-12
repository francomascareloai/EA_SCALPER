//+------------------------------------------------------------------+
//|                                            Golden_section_v3.mq4 |
//|                                                            Talex |
//|                                                 tan@gazinter.net |
//+------------------------------------------------------------------+

#property copyright "Talex"
#property link      "tan@gazinter.net"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Lime
#import "user32.dll"
int GetClientRect(int hWnd,int lpRect[]);
#import

#define pi 3.14159265
#define phi 1.61803399

extern string Var1="General Options/Общие параметры";
extern int ExtDepth=12; /* параметр для ZZ */
/*extern*/ int ExtIndicator=0; /* определяет индиктор, который будет искать точки для построения паттерна, пока только 0 */
extern int ExtPoint=6; /* число считаемых точек перелома, если сделать больше 3, то возможно строить от любой точки перелома */
extern string ExtComplect="0"; /* это для того,чтобы выводить несколько индикаторов на графике */
extern bool ExtPitchfork=false; /* используется построение с помощью вил */
extern bool ExtPitchforkRevers=false; /* переворачивает веник, зачем? спросите Vadimcha */
extern bool ExtBack=true; /* если true, то объекты будут показаны в фоновом режиме */
extern bool ExtSpiral=true; /* если true, то спираль будет выведена на график */
extern bool ExtFan=true; /* если true, то фибовеник будет выведен на график */
extern bool ExtRec=true; /* если true, то прямоугольник будет выведен на график */
extern bool ExtArc=true; /* если true, то фибоарка будет выведена на график */
extern bool ExtFiboLevel=false; /* если true, то фибоуровни будут выведены на график */
extern bool ExtLeftChannel=false; /* если true, то линии канала будут выведены на график */
extern bool ExtRightChannel=false; /* если true, то линии канала будут выведены на график */
extern bool ExtSave=false; /* если true, то построения будут сохранены на графике */
extern int  MetodAutoScale=1; /* 1- выводятся идеальные фигуры, т.е. круг будет кругом, а не эллипсом, 2 - расчет предложил Vadimcha */
extern double ExtScale=0; /* устанавливает масштаб дуги */
/* Ниже координаты точек можно вводить ручками */
extern datetime TimePointX=0; /* время точки X в формате '1980.07.19 12:30' */
extern datetime TimePointA=0; /* время точки A в формате '1980.07.19 12:30' */
extern datetime TimePointB=0; /* время точки B в формате '1980.07.19 12:30' */
extern string Var2="Golden Spiral/Золотая Спираль";
extern int    radius = 5;
extern double goldenSpiralCycle = 1;
extern double accurity = 0.2;
extern bool   clockWiseSpiral = true;
extern color  spiralColor1 = Blue;
extern color  spiralColor2 = Red;
extern int ExtSpiralWidth=2; /* устанавливает ширину линий фибовеника */
extern string Var3="FiboFan/Фибовеер";
extern double FiboFanMediana1=0.382;
extern double FiboFanMediana2=1.272;
extern int ExtFanStyle=0; /* устанавливает стиль линий фибовеника */
extern int ExtFanWidth=1; /* устанавливает ширину линий фибовеника */
extern color ExtFanColor=DeepPink; /* цвет фибовеников */
extern string Var4="FiboArc/Фибоарка";
extern int ExtArcStyle=0; /* устанавливает стиль линий фибоарки */ 
extern int ExtArcWidth=1; /* устанавливает ширину линий фибоарки */
extern color ExtArcColor=Red; /* цвет дуги */
extern string Var5="Rectangle/Прямоугольник";
extern int ExtRecStyle=4; /* устанавливает стиль линий прямоугольника */
extern int ExtRecWidth=1; /* устанавливает ширину линий прямоугольника */
extern color ExtRecColor=Yellow; /* цвет прямоугольника */
extern string Var6="Channel/Каналы";
extern double ExtFiboLeftChannel=1.618; /* устанавливает фибо точку построения левых линий */
extern double ExtFiboRightChannel=1.618; /* устанавливает фибо точку построения правых линий */
extern int ExtChannelStyle=0; /* устанавливает стиль линий канала */ 
extern int ExtChannelWidth=1; /* устанавливает ширину линий канала */ 
extern color ExtChannelColor=Blue; /* цвет линий канала */
extern string Var7="Pitchfork/Вилы";
extern int ExtPitchforkStyle=0; /* устанавливает стиль линий вил */
extern int ExtPitchforkWidth=1; /* устанавливает ширину линий вил */
extern color ExtPitchforkColor=Lime; /* цвет вил */
extern string Var8="Fibo Level/Фибоуровни";
extern int ExtFiboLevelStyle=0; /* устанавливает стиль линий фибоуровней */ 
extern int ExtFiboLevelWidth=1; /* устанавливает ширину линий фибоуровней */
extern color ExtFiboLevelColor=Red; /* цвет фибоуровней */
extern string Var9="Used Fibs/Используемые Фибы";
extern double Fibo1=0.0;
extern double Fibo2=0.382;
extern double Fibo3=0.5;
extern double Fibo4=0.618;
extern double Fibo5=0.786;
extern double Fibo6=0.886;
extern double Fibo7=1.0;
extern double Fibo8=1.272;
extern double Fibo9=1.618;
extern double Fibo10=2.0;
extern double Fibo11=2.618;

/* Совет - настройте для себя цвет, стиль, ширину линий объектов, фибо-уровни и уберите перед соответствующими параметрами extern */

static int GPixels,VPixels;
int rect[4],hwnd;
double zz[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(1);
   SetIndexBuffer(0,zz);
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexEmptyValue(0,0.0);
   
   hwnd=WindowHandle(Symbol(),Period());
   if(hwnd>0)
   {
     GetClientRect(hwnd,rect);
     GPixels=rect[2]; // здесь функция возвращает кол-во пикселов по горизонтали
     VPixels=rect[3]; // здесь функция возвращает кол-во пикселов по вертикали
   }
   if(ExtScale==0)
   {
     if(MetodAutoScale<1 && MetodAutoScale>2)MetodAutoScale=1;
   }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   int i;
   
    GetClientRect(hwnd,rect);
    for(i=0;i<=ExtDepth;i++)
    {
      ObjectDelete("FiboFan1"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("FiboFan2"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("FiboArc"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("Rectangle"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("LeftChannel"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("RightChannel"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("LeftLine"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("RightLine"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("Pitchfork"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("Mediana"+"_"+i+"_"+ExtComplect+"_");
      ObjectDelete("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_");
    }
    for(i=0;i<=500;i++)
    {
      ObjectDelete("FX5_Spiral:#"+"_"+ExtComplect+"_"+i);
    }
    Comment("");
   //----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int PP[];
   int i,j,X,A,B;
   double AutoScale;
   double p1,p2,p3,p4,p5,p6,p7,p8;
   datetime t1,t2,t3,t4,t5,t6,t7,t8;
   string save="";
   double tang;
   
   if(ExtSave==true)
   {
    save=TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS);
   }
   
   ArrayResize(PP,ExtPoint); 
   
   if(TimePointX!=0 && TimePointA!=0 && TimePointB!=0)
   {
    ExtPoint=3;
    PP[0]=iBarShift(NULL,0,TimePointB); 
    PP[1]=iBarShift(NULL,0,TimePointA);
    PP[2]=iBarShift(NULL,0,TimePointX);
    if((High[PP[0]]>High[PP[1]] && High[PP[2]]>High[PP[1]]) || (Low[PP[0]]>Low[PP[1]] && Low[PP[2]]>Low[PP[1]]))
    {
     zz[PP[0]]=High[PP[0]];
     zz[PP[1]]=Low[PP[1]];
     zz[PP[2]]=High[PP[2]];
    }else 
     {
      zz[PP[0]]=Low[PP[0]];
      zz[PP[1]]=High[PP[1]];
      zz[PP[2]]=Low[PP[2]];
     }
   } else
   {
   switch (ExtIndicator)
     {
      case 0: {ZZTalex();   break;}
      /* здесь можно добавлять функции по расчету точек паттернов */
      default:{ZZTalex();   break;}
     }
     if(ExtIndicator==0)
     { 
      j=0;
      for(i=0;i<Bars-1 && j<=ExtPoint;i++)
      {
       if(zz[i]!=0)
       {
        PP[j]=i;
        j++;
       }
      }
     }
    }
    
    if(ExtPitchfork==false)
    {
     
       t1=Time[PP[ExtPoint-1]];p1=zz[PP[ExtPoint-1]];
       t2=Time[PP[ExtPoint-3]];p2=zz[PP[ExtPoint-3]];
       if(2*PP[ExtPoint-3]-PP[ExtPoint-1]<=0)
       {
        t3=Time[0]-(2*PP[ExtPoint-3]-PP[ExtPoint-1])*Period()*60;p3=zz[PP[ExtPoint-3]]-(zz[PP[ExtPoint-1]]-zz[PP[ExtPoint-3]]);
       } else {t3=Time[2*PP[ExtPoint-3]-PP[ExtPoint-1]];p3=zz[PP[ExtPoint-3]]-(zz[PP[ExtPoint-1]]-zz[PP[ExtPoint-3]]);}
       t4=Time[PP[ExtPoint-2]];p4=zz[PP[ExtPoint-2]];
     if(ExtScale==0)
     {
      if(MetodAutoScale==1)
      {
        AutoScale=Scale();
      }
      if(MetodAutoScale==2)
      {/* расчет этого AutoScale предложил Vadimcha к нему все вопросы */
        AutoScale=MathAbs((p1-p3)*MathPow(10,Digits)/(2*(PP[ExtPoint-1]-PP[ExtPoint-3])));
      }
     }else AutoScale=ExtScale;
     
     CreateObject(p1,p2,p3,p4,t1,t2,t3,t4,save,AutoScale);
     
    }
    if(ExtFiboLevel)
    {
     t2=Time[PP[ExtPoint-2]];p2=zz[PP[ExtPoint-2]];
     t3=Time[PP[ExtPoint-3]];p3=zz[PP[ExtPoint-3]];
     int R=ExtPoint-2;
     ObjectCreate("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_FIBO,0,t2,p2,t3,p3);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELCOLOR,ExtFiboLevelColor);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELSTYLE,ExtFiboLevelStyle);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_RAY,false);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELWIDTH,ExtFiboLevelWidth);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIBOLEVELS,11);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+0,Fibo1);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+1,Fibo2);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+2,Fibo3);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+3,Fibo4);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+4,Fibo5);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+5,Fibo6);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+6,Fibo7);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+7,Fibo8);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+8,Fibo9);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+9,Fibo10);
     ObjectSet("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+10,Fibo11);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,0,DoubleToStr(Fibo1*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo1,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,1,DoubleToStr(Fibo2*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo2,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,2,DoubleToStr(Fibo3*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo3,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,3,DoubleToStr(Fibo4*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo4,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,4,DoubleToStr(Fibo5*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo5,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,5,DoubleToStr(Fibo6*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo6,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,6,DoubleToStr(Fibo7*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo7,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,7,DoubleToStr(Fibo8*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo8,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,8,DoubleToStr(Fibo9*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo9,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,9,DoubleToStr(Fibo10*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo10,Digits)+" "+TimeFrame()+" "+"R"+R);
     ObjectSetFiboDescription("FiboTarget"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,10,DoubleToStr(Fibo11*100,1)+"%"+" "+DoubleToStr(p3-(p3-p2)*Fibo11,Digits)+" "+TimeFrame()+" "+"R"+R);
    }
    if(ExtPitchfork)
   {
    t1=Time[PP[ExtPoint-1]];p1=zz[PP[ExtPoint-1]];
    t2=Time[PP[ExtPoint-2]];p2=zz[PP[ExtPoint-2]];
    t3=Time[PP[ExtPoint-3]];p3=zz[PP[ExtPoint-3]];
    p4=(zz[PP[ExtPoint-2]]+zz[PP[ExtPoint-3]])/2;
    ObjectCreate("Pitchfork"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_PITCHFORK,0,t1,p1,t2,p2,t3,p3);
    ObjectSet("Pitchfork"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_BACK,ExtBack);
    ObjectSet("Pitchfork"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_COLOR,ExtPitchforkColor);
    ObjectSet("Pitchfork"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_STYLE,ExtPitchforkStyle);
    ObjectSet("Pitchfork"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_WIDTH,ExtPitchforkWidth);
       
    tang=(p1-p4)/(PP[ExtPoint-1]-(PP[ExtPoint-2]-(PP[ExtPoint-2]-PP[ExtPoint-3])/2.0));
    t5=t3;
    p5=p1-tang*(PP[ExtPoint-1]-PP[ExtPoint-3]);
    ObjectCreate("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_TREND,0,t1,p1,t5,p5);
    ObjectSet("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_BACK,ExtBack);
    ObjectSet("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_COLOR,ExtPitchforkColor);
    
    if((p1<p2 && p1<p4) || (p1>p2 && p1>p4))
     {
      /* в этом случае совпадут уровни менее 100% */
      
       p6=(p5-p3)/FiboFanMediana1+p3;//-tang;
       if(ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)<-100)
        {
         Alert("Точка для построения веера находиться слишком далеко, попробуйте использовать большее значение для FiboFanMediana1");
        }
      
       if(ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)>0)
       {
        t6=Time[ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)];
       } else t6=Time[0]-ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)*Period()*60;
     }
     if((p1<p2 && p1>p4) || (p1>p2 && p1<p4))
     {
      /* в этом случае совпадут уровни более 100% */
      
       p6=(p5-p3)/FiboFanMediana2+p3;//-tang;
       if(ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)<-100)
        {
         Alert("Точка для построения веера находиться слишком далеко, попробуйте использовать меньшее значение для FiboFanMediana2");
        }
     
       if(ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)>=0)
       {
        t6=Time[ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)];
       } else t6=Time[0]-ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)*Period()*60;
     }
     /* коррекция цены p6 */
     p6=ObjectGetValueByShift("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6));
     p7=2*p6-p3;
     if(2*ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)-PP[ExtPoint-3]<=0)
     {
      t7=Time[0]-(2*ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)-PP[ExtPoint-3])*Period()*60;
     }
      else t7=Time[2*ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6)-PP[ExtPoint-3]];
     //Print("t6=",TimeToStr(t6,TIME_DATE),"; p6=",p6,"; NbarMediana=",ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6));
     //Print("t3=",TimeToStr(t3,TIME_DATE),"; p3=",p3,"; t7=",TimeToStr(t7,TIME_DATE),"; p7=",p7);
     if(p1==p4)
     {
      Alert("Веер построить нельзя.");
      p3=0;p6=0;p7=0;t3=0;t6=0;t7=0;
     }
     
     if(ExtScale==0)
     {
      if(MetodAutoScale==1)
      {
        AutoScale=Scale();
      }
      if(MetodAutoScale==2)
      {/* расчет этого AutoScale предложил Vadimcha к нему все вопросы */
        AutoScale=MathAbs((p7-p3)*MathPow(10,Digits)/(2*(PP[ExtPoint-3]-ObjectGetShiftByValue("Mediana"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,p6))));
      }
     }else AutoScale=ExtScale;
     
     CreateObject(p3,p6,p7,p8,t3,t6,t7,t8,save,AutoScale);
     
   }
   
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

/*------------------------------------------------------------------+
|  ZigZag_Talex, ищет точки перелома на графике. Количество точек   |
|  задается внешним параметром ExtPoint.                            |
+------------------------------------------------------------------*/
void ZZTalex()
{
/*переменные*/
   int    i,j,k,zzbarlow,zzbarhigh,curbar,curbar1,curbar2,EP,Mbar[];
   double curpr,Mprice[];
   bool flag,fd;
   static int endbar;
   static double endpr;
   
   
   /*начало*/
   
   for(i=0;i<=Bars-1;i++)
   {zz[i]=0.0;}
   
   EP=ExtPoint;
   zzbarlow=iLowest(NULL,0,MODE_LOW,ExtDepth,0);        
   zzbarhigh=iHighest(NULL,0,MODE_HIGH,ExtDepth,0);     
   
   if(zzbarlow<zzbarhigh) {curbar=zzbarlow; curpr=Low[zzbarlow];}
   if(zzbarlow>zzbarhigh) {curbar=zzbarhigh; curpr=High[zzbarhigh];}
   if(zzbarlow==zzbarhigh){curbar=zzbarlow;curpr=funk1(zzbarlow, ExtDepth);}
   
   ArrayResize(Mbar,ExtPoint);
   ArrayResize(Mprice,ExtPoint);
   j=0;
   endpr=curpr;
   endbar=curbar;
   Mbar[j]=curbar;
   Mprice[j]=curpr;
   
   EP--;
   if(curpr==Low[curbar]) flag=true;
   else flag=false;
    
   i=curbar+1;
   while(EP>0)
   {
    if(flag)
    {
     while(i<=Bars-1)
     {
     curbar1=iHighest(NULL,0,MODE_HIGH,ExtDepth,i); 
     curbar2=iHighest(NULL,0,MODE_HIGH,ExtDepth,curbar1); 
     if(curbar1==curbar2){curbar=curbar1;curpr=High[curbar];flag=false;i=curbar+1;j++;break;}
     else i=curbar2;
     }
     
     Mbar[j]=curbar;
     Mprice[j]=curpr;
     EP--;
     
    }
    
    if(EP==0) break;
    
    if(!flag) 
    {
     while(i<=Bars-1)
     {
     curbar1=iLowest(NULL,0,MODE_LOW,ExtDepth,i); 
     curbar2=iLowest(NULL,0,MODE_LOW,ExtDepth,curbar1); 
     if(curbar1==curbar2){curbar=curbar1;curpr=Low[curbar];flag=true;i=curbar+1;j++;break;}
     else i=curbar2;
     }
     
     Mbar[j]=curbar;
     Mprice[j]=curpr;
     EP--;
    }
   }
   /* исправление вершин */
   if(Mprice[0]==Low[Mbar[0]])fd=true; else fd=false;
   for(k=0;k<=ExtPoint-1;k++)
   {
    if(k==0)
    {
     if(fd==true)
      {
       Mbar[k]=iLowest(NULL,0,MODE_LOW,Mbar[k+1]-Mbar[k],Mbar[k]);Mprice[k]=Low[Mbar[k]];endbar=ExtDepth;
      }
     if(fd==false)
      {
       Mbar[k]=iHighest(NULL,0,MODE_HIGH,Mbar[k+1]-Mbar[k],Mbar[k]);Mprice[k]=High[Mbar[k]];endbar=ExtDepth;
      }
    }
    if(k<ExtPoint-2)
    {
     if(fd==true)
      {
       Mbar[k+1]=iHighest(NULL,0,MODE_HIGH,Mbar[k+2]-Mbar[k]-1,Mbar[k]+1);Mprice[k+1]=High[Mbar[k+1]];
      }
     if(fd==false)
      {
       Mbar[k+1]=iLowest(NULL,0,MODE_LOW,Mbar[k+2]-Mbar[k]-1,Mbar[k]+1);Mprice[k+1]=Low[Mbar[k+1]];
      }
    }
    if(fd==true)fd=false;else fd=true;
    
    /* постройка ZigZag'a */
    zz[Mbar[k]]=Mprice[k];
    //Print("zz_"+k,"=",zz[Mbar[k]]);
   }
  
 } 
/*-------------------------------------------------------------------+
/  ZigZag_Talex конец                                                |
/-------------------------------------------------------------------*/

/*-------------------------------------------------------------------+
/ Фунция для поиска у первого бара (если он внешний) какой экстремум |
/ будем использовать в качестве вершины.                             |
/-------------------------------------------------------------------*/
double funk1(int zzbarlow, int ExtDepth)
{
 double pr;
 int fbarlow,fbarhigh;
 
 fbarlow=iLowest(NULL,0,MODE_LOW,ExtDepth,zzbarlow);  
 fbarhigh=iHighest(NULL,0,MODE_HIGH,ExtDepth,zzbarlow);
 
 if(fbarlow>fbarhigh) {/*if((Low[zzbarlow]<Low[fbarhigh]) && (High[zzbarlow]<High[fbarhigh]))*/ pr=High[zzbarlow];}
 if(fbarlow<fbarhigh) {/*if((Low[zzbarlow]>Low[fbarlow]) && (High[zzbarlow]>High[fbarlow]))*/ pr=Low[zzbarlow];}
 if(fbarlow==fbarhigh)
 {
  fbarlow=iLowest(NULL,0,MODE_LOW,2*ExtDepth,zzbarlow);  
  fbarhigh=iHighest(NULL,0,MODE_HIGH,2*ExtDepth,zzbarlow);
  if(fbarlow>fbarhigh) {/*if((Low[zzbarlow]<Low[fbarhigh]) && (High[zzbarlow]<High[fbarhigh]))*/ pr=High[zzbarlow];}
  if(fbarlow<fbarhigh) {/*if((Low[zzbarlow]>Low[fbarlow]) && (High[zzbarlow]>High[fbarlow]))*/ pr=Low[zzbarlow];}
  if(fbarlow==fbarhigh)
  {
   fbarlow=iLowest(NULL,0,MODE_LOW,3*ExtDepth,zzbarlow);  
   fbarhigh=iHighest(NULL,0,MODE_HIGH,3*ExtDepth,zzbarlow);
   if(fbarlow>fbarhigh) {/*if((Low[zzbarlow]<Low[fbarhigh]) && (High[zzbarlow]<High[fbarhigh]))*/ pr=High[zzbarlow];}
   if(fbarlow<fbarhigh) {/*if((Low[zzbarlow]>Low[fbarlow]) && (High[zzbarlow]>High[fbarlow]))*/ pr=Low[zzbarlow];}
  }
 }
 return(pr);
}
/*----------------------------------------------------------------------------*/

/*------------------------------------------------------------------+
|                 Функция создания объектов                         |
+------------------------------------------------------------------*/
void CreateObject(double p1,double p2,double p3,double p4,datetime t1,datetime t2,datetime t3,datetime t4,string save,double AutoScale)
{
 if(ExtFan)
     { 
       ObjectCreate("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_FIBOFAN,0,t2,p2,t1,p1);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_BACK,ExtBack);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIBOLEVELS,11);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELCOLOR,ExtFanColor);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELSTYLE,ExtFanStyle);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELWIDTH,ExtFanWidth);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+0,Fibo1);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+1,Fibo2);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+2,Fibo3);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+3,Fibo4);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+4,Fibo5);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+5,Fibo6);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+6,Fibo7);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+7,Fibo8);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+8,Fibo9);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+9,Fibo10);
       ObjectSet("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+10,Fibo11);
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,0,DoubleToStr(Fibo1*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,1,DoubleToStr(Fibo2*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,2,DoubleToStr(Fibo3*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,3,DoubleToStr(Fibo4*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,4,DoubleToStr(Fibo5*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,5,DoubleToStr(Fibo6*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,6,DoubleToStr(Fibo7*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,7,DoubleToStr(Fibo8*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,8,DoubleToStr(Fibo9*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,9,DoubleToStr(Fibo10*100,1));
       ObjectSetFiboDescription("FiboFan1"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,10,DoubleToStr(Fibo11*100,1));
       if(ExtPitchforkRevers==false)
       ObjectCreate("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_FIBOFAN,0,t2,p2,t3,p3);
       else ObjectCreate("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_FIBOFAN,0,t2,p2,t3,2*p2-p3);
      
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_BACK,ExtBack);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIBOLEVELS,11);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELCOLOR,ExtFanColor);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELSTYLE,ExtFanStyle);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELWIDTH,ExtFanWidth);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+0,Fibo1);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+1,Fibo2);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+2,Fibo3);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+3,Fibo4);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+4,Fibo5);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+5,Fibo6);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+6,Fibo7);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+7,Fibo8);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+8,Fibo9);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+9,Fibo10);
       ObjectSet("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+10,Fibo11);
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,0,DoubleToStr(Fibo1*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,1,DoubleToStr(Fibo2*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,2,DoubleToStr(Fibo3*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,3,DoubleToStr(Fibo4*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,4,DoubleToStr(Fibo5*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,5,DoubleToStr(Fibo6*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,6,DoubleToStr(Fibo7*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,7,DoubleToStr(Fibo8*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,8,DoubleToStr(Fibo9*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,9,DoubleToStr(Fibo10*100,1));
       ObjectSetFiboDescription("FiboFan2"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,10,DoubleToStr(Fibo11*100,1));
       }
       if(ExtRec)
       {
       ObjectCreate("Rectangle"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_RECTANGLE,0,t1,p1,t3,p3);
       ObjectSet("Rectangle"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_BACK,ExtBack);
       ObjectSet("Rectangle"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_COLOR,ExtRecColor);
       ObjectSet("Rectangle"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_STYLE,ExtRecStyle);
       ObjectSet("Rectangle"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_WIDTH,ExtRecWidth);
       ObjectSet("Rectangle"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_BACK,false);
       }
       if(ExtArc)
       {
       ObjectCreate("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_FIBOARC,0,t2,p1,t2,p2);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_BACK,ExtBack);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_ELLIPSE,true);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_SCALE,AutoScale);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIBOLEVELS,11);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELCOLOR,ExtArcColor);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELSTYLE,ExtArcStyle);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELWIDTH,ExtArcWidth);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+0,Fibo1);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+1,Fibo2);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+2,Fibo3);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+3,Fibo4);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+4,Fibo5);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+5,Fibo6);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+6,Fibo7);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+7,Fibo8);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+8,Fibo9);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+9,Fibo10);
       ObjectSet("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+10,Fibo11);
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,0,DoubleToStr(Fibo1*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,1,DoubleToStr(Fibo2*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,2,DoubleToStr(Fibo3*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,3,DoubleToStr(Fibo4*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,4,DoubleToStr(Fibo5*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,5,DoubleToStr(Fibo6*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,6,DoubleToStr(Fibo7*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,7,DoubleToStr(Fibo8*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,8,DoubleToStr(Fibo9*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,9,DoubleToStr(Fibo10*100,1));
       ObjectSetFiboDescription("FiboArc"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,10,DoubleToStr(Fibo11*100,1));
       }
       if(ExtLeftChannel)
       {
        ObjectCreate("LeftLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_TREND,0,t2,p2,t3,p1+(p2-p1)*(2-ExtFiboLeftChannel));
        ObjectSet("LeftLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_BACK,ExtBack);
        ObjectSet("LeftLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_COLOR,ExtChannelColor);
        ObjectSet("LeftLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_STYLE,ExtChannelStyle);
        ObjectSet("LeftLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_WIDTH,ExtChannelWidth);
        ObjectCreate("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_FIBOCHANNEL,0,t2,p2,t1,p1+(p2-p1)*ExtFiboLeftChannel,t2,p1);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_COLOR,ExtChannelColor);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_STYLE,ExtChannelStyle);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_WIDTH,ExtChannelWidth);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIBOLEVELS,21);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELCOLOR,ExtChannelColor);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELSTYLE,ExtChannelStyle);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELWIDTH,ExtChannelWidth);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+0,Fibo1);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+1,Fibo2);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+2,Fibo3);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+3,Fibo4);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+4,Fibo5);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+5,Fibo6);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+6,Fibo7);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+7,Fibo8);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+8,Fibo9);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+9,Fibo10);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+10,Fibo11);
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,0,DoubleToStr(Fibo1*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,1,DoubleToStr(Fibo2*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,2,DoubleToStr(Fibo3*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,3,DoubleToStr(Fibo4*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,4,DoubleToStr(Fibo5*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,5,DoubleToStr(Fibo6*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,6,DoubleToStr(Fibo7*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,7,DoubleToStr(Fibo8*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,8,DoubleToStr(Fibo9*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,9,DoubleToStr(Fibo10*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,10,DoubleToStr(Fibo11*100,1));
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+11,-Fibo2);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+12,-Fibo3);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+13,-Fibo4);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+14,-Fibo5);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+15,-Fibo6);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+16,-Fibo7);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+17,-Fibo8);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+18,-Fibo9);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+19,-Fibo10);
        ObjectSet("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+20,-Fibo11);
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,11,"-"+DoubleToStr(Fibo2*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,12,"-"+DoubleToStr(Fibo3*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,13,"-"+DoubleToStr(Fibo4*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,14,"-"+DoubleToStr(Fibo5*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,15,"-"+DoubleToStr(Fibo6*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,16,"-"+DoubleToStr(Fibo7*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,17,"-"+DoubleToStr(Fibo8*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,18,"-"+DoubleToStr(Fibo9*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,19,"-"+DoubleToStr(Fibo10*100,1));
        ObjectSetFiboDescription("LeftChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,20,"-"+DoubleToStr(Fibo11*100,1));
       }
       if(ExtRightChannel)
       {
        ObjectCreate("RightLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_TREND,0,t2,p2,t1,p1+(p2-p1)*(2-ExtFiboRightChannel));
        ObjectSet("RightLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_BACK,ExtBack);
        ObjectSet("RightLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_COLOR,ExtChannelColor);
        ObjectSet("RightLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_STYLE,ExtChannelStyle);
        ObjectSet("RightLine"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_WIDTH,ExtChannelWidth);
        ObjectCreate("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJ_FIBOCHANNEL,0,t2,p2,t3,p1+(p2-p1)*ExtFiboRightChannel,t2,p1);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_COLOR,ExtChannelColor);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_STYLE,ExtChannelStyle);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_WIDTH,ExtChannelWidth);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIBOLEVELS,21);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELCOLOR,ExtChannelColor);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELSTYLE,ExtChannelStyle);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_LEVELWIDTH,ExtChannelWidth);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+0,Fibo1);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+1,Fibo2);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+2,Fibo3);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+3,Fibo4);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+4,Fibo5);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+5,Fibo6);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+6,Fibo7);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+7,Fibo8);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+8,Fibo9);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+9,Fibo10);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+10,Fibo11);
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,0,DoubleToStr(Fibo1*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,1,DoubleToStr(Fibo2*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,2,DoubleToStr(Fibo3*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,3,DoubleToStr(Fibo4*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,4,DoubleToStr(Fibo5*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,5,DoubleToStr(Fibo6*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,6,DoubleToStr(Fibo7*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,7,DoubleToStr(Fibo8*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,8,DoubleToStr(Fibo9*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,9,DoubleToStr(Fibo10*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,10,DoubleToStr(Fibo11*100,1));
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+11,-Fibo2);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+12,-Fibo3);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+13,-Fibo4);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+14,-Fibo5);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+15,-Fibo6);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+16,-Fibo7);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+17,-Fibo8);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+18,-Fibo9);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+19,-Fibo10);
        ObjectSet("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,OBJPROP_FIRSTLEVEL+20,-Fibo11);
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,11,"-"+DoubleToStr(Fibo2*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,12,"-"+DoubleToStr(Fibo3*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,13,"-"+DoubleToStr(Fibo4*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,14,"-"+DoubleToStr(Fibo5*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,15,"-"+DoubleToStr(Fibo6*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,16,"-"+DoubleToStr(Fibo7*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,17,"-"+DoubleToStr(Fibo8*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,18,"-"+DoubleToStr(Fibo9*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,19,"-"+DoubleToStr(Fibo10*100,1));
        ObjectSetFiboDescription("RightChannel"+"_"+ExtDepth+"_"+ExtComplect+"_"+save,20,"-"+DoubleToStr(Fibo11*100,1));
       }
       if(ExtSpiral && ExtPitchfork==false)
      {
        GoldenSpiral(t2,p2,t4,p4,save);
      }
}

/*---------------------------------------------------------------+
|  Функция корректного отображения Таймфрейма.Начало.            |
+---------------------------------------------------------------*/
string TimeFrame()
{
 switch(Period())
 {
  case 1: return("M1");
  case 5: return("M5");
  case 15: return("M15");
  case 30: return("M30");
  case 60: return("H1");
  case 240: return("H4");
  case 1440: return("D1");
  case 10080: return("W1");
  case 43200: return("MN1");
 }
}
/*---------------------------------------------------------------+
|  Функция корректного отображения Таймфрейма.Конец.             |
+---------------------------------------------------------------*/

/*---------------------------------------------------------------+
|   Функция для рисования золотой спирали.                       |
+---------------------------------------------------------------*/
void GoldenSpiral(datetime t2,double p2,datetime t4,double p4,string save) 
{
/* Проверка входных данных и, если требуется, их корректировка */
 if(radius <= 0)
     {
       radius = 5;
       Alert("Incorrect radius value! radius=5");
     }
   if(goldenSpiralCycle <= 0)
     {
       goldenSpiralCycle = 1;
       Alert("Incorrect goldenSpiralCycle value! goldenSpiralCycle=1");
     }
   if(accurity <= 0)
     {
       accurity = 0.2;
       Alert("Incorrect accurity value! accurity=0.2");
     }
/* Построение спирали */ 
  
// In polar coordinates the basic spiral equation is:
// r = a * e ^ (Theta * cot Alpah)
// for golden spiral: cot Alpha = 2/pi * ln(phi)
   
   double startAngle; // угол в радианах(in radians)
   
   startAngle=MathArctan(((p4-p2)/Point)/((iBarShift(NULL,0,t4,false)-iBarShift(NULL,0,t2,false))*Scale()));
   
//----  
   double cotAlpha = (1/(2 * goldenSpiralCycle *pi)) * MathLog(phi);
   double r0 = (iBarShift(NULL,0,t4,false)-iBarShift(NULL,0,t2,false))/MathCos(startAngle);
   double r1=1.0/MathExp(startAngle * cotAlpha);
   double a = 0;
   double x1 = 0;
   double y1 = 0;
//----   
   for(int i = 0; i < 200; i++)
     {
       double Theta =startAngle + a * pi / 4;
       double r = r0*r1 * MathExp(Theta * cotAlpha);
       //----
       if (clockWiseSpiral == false){Theta = startAngle - a * pi / 4;}
       //----      
       double x2 = r * MathCos(Theta);
       double y2 = r * MathSin(Theta);
       a += accurity;
       //----     
       string label = "FX5_Spiral:#"+"_"+ExtComplect+"_"+save+i;
       DrawLine(x1, y1, x2, y2,t2,p2,t4,p4,label);
       //----              
       x1 = x2;
       y1 = y2;
     }
}

   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(double x1, double y1, double x2, double y2,datetime t2,double p2,datetime t4,double p4, string label)
  {
   int Shift_1 = iBarShift(NULL, 0, t4, false);
   int Shift_2 = iBarShift(NULL, 0, t2, false);

   /*double scale = ((p2 - p4) / Point) / 
                   (squareShift_2 - squareShift_1);
   scale = MathAbs(scale);*/
//----   
   int timeShift1 = Shift_2 + MathRound(x1);
   int timeShift2 = Shift_2 + MathRound(x2);
//----   
   double price1 = p2 + NormalizeDouble(y1* Scale() * Point, 
                   Digits);
   double price2 = p2 + NormalizeDouble(y2* Scale() * Point, 
                   Digits);
//----   
   if((x2 >= 0 && y2 >= 0) || (x2 <= 0 && y2 <= 0))
       color lineColor = spiralColor1;
   else
       lineColor = spiralColor2;
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, GetTime(timeShift1), price1, 
                GetTime(timeShift2), price2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_WIDTH, ExtSpiralWidth);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetTime(int timeShift)
  {
   if(timeShift >= 0)
      return(Time[timeShift]);
   datetime timeFrame = Time[0] - Time[1];
   datetime time = Time[0] - timeFrame * timeShift;
   return(time);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Scale()
{
   double priceRange = WindowPriceMax(0) - WindowPriceMin(0);
   double barsCount = WindowBarsPerChart();
   double chartScale = (priceRange / Point) / barsCount;
   return(chartScale*GPixels/VPixels);
}