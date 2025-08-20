//+---------------------------------------------------------------------------+
//|                                                        mv-i lease pitchfork on all TF.mq4 |
//|                                                Максим Василенко В. MaxV42 |
//|                                                http://                    |
//| Индикатор работает по стратегии "ТААЧ".                                   |
//| Версия 1.0 от 20.12.2009:                                                 |
//|                                                                           |
//+---------------------------------------------------------------------------+
#property copyright "Максим Василенко В. MaxV42"
#property link      "http://"
//+---------------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 CornflowerBlue
#property indicator_color2 Tomato
#property indicator_width1 1
#property indicator_width2 1
#property indicator_color3 CornflowerBlue
#property indicator_color4 Tomato
#property indicator_width3 1
#property indicator_width4 1
//+---------------------------------------------------------------------------+
extern string Ind_Coment1= "--- Параметры младшего таймфрейма ---";
extern bool  ShowFractals.LowerTF      = false;    // Вкл/выкл значков фракталов
extern bool  OnAlert.Pitchfork.LowerTF = false;    // Вкл/выкл сигнала при выявлении нового канала
extern int   nPitchfork.Upper.LowerTF  =     1;    // Количество выводимых восходящих "Вил Эндрюса"
extern int   nPitchfork.Lower.LowerTF  =     1;    // Количество выводимых нисходящих "Вил Эндрюса"
extern bool  ShowPitchfork.LowerTF     =  true;    // Вкл/выкл "Вил Эндрюса" младшего таймфрейма
extern string Ind_Coment2= "--- Параметры старшего таймфрейма ---";
extern int   TF.Upper                  =  1440;    // Старший таймфрейм
extern bool  ShowFractals.UpperTF      = false;    // Вкл/выкл значков фракталов
extern bool  OnAlert.Pitchfork.UpperTF = false;    // Вкл/выкл сигнала при выявлении нового канала
extern int   nPitchfork.Upper.UpperTF  =     1;    // Количество выводимых восходящих "Вил Эндрюса"
extern int   nPitchfork.Lower.UpperTF  =     1;    // Количество выводимых нисходящих "Вил Эндрюса"
extern bool  ShowPitchfork.UpperTF     =  true;    // Вкл/выкл "Вил Эндрюса" старшего таймфрейма
//+---------------------------------------------------------------------------+
// глобальные переменные
int          nBars.LowerTF             =     0,    // кол-во баров младшего тафмфрейма
             nBars.UpperTF             =     0;    // кол-во баров старшего тафмфрейма
int          QntPitchfork.Upper.LowerTF=     0;    // Количество уже отрисованных восходящих "Вил Эндрюса"
int          QntPitchfork.Lower.LowerTF=     0;    // Количество уже отрисованных нисходящих "Вил Эндрюса"
int          QntPitchfork.Upper.UpperTF=     0;    // Количество уже отрисованных восходящих "Вил Эндрюса"
int          QntPitchfork.Lower.UpperTF=     0;    // Количество уже отрисованных нисходящих "Вил Эндрюса"
 
//----- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+---------------------------------------------------------------------------+
void init()  {        // Custom indicator initialization function
int    Qnt=ObjectsTotal();
  // ----- Indicators Properties
  SetIndexStyle(0,DRAW_ARROW);
  SetIndexArrow(0,119);
  SetIndexBuffer(0,ExtMapBuffer1);
  SetIndexEmptyValue(0,0.0);
  SetIndexStyle(1,DRAW_ARROW);
  SetIndexArrow(1,119);
  SetIndexBuffer(1,ExtMapBuffer2);
  SetIndexEmptyValue(1,0.0);
  SetIndexStyle(2,DRAW_ARROW);
  SetIndexArrow(2,117);
  SetIndexBuffer(2,ExtMapBuffer3);
  SetIndexEmptyValue(2,0.0);
  SetIndexStyle(3,DRAW_ARROW);
  SetIndexArrow(3,117);
  SetIndexBuffer(3,ExtMapBuffer4);
  SetIndexEmptyValue(3,0.0);
 
 
  // ----- Name for DataWindow and indicator subwindow label
  IndicatorShortName("mv-i-TAACH_1_0");
  SetIndexLabel(0,"FractalsUp.LowerTF");
  SetIndexLabel(1,"FractalsDown.LowerTF");
  SetIndexLabel(2,"FractalsUp.UpperTF");
  SetIndexLabel(3,"FractalsDown.UpperTF");
 
  return;
}
 

//+---------------------------------------------------------------------------+
void start() {        // Custom indicator iteration function
int    counted_bars=IndicatorCounted();
int    limit;
int    Spred=MarketInfo(Symbol(),MODE_SPREAD);
double Fractals.Upper=0,Fractals.Lower=0;
  // ----- Проверка внешних параметров индикатора

  // ----- новый бар не появился
  if(!isNewBar.LowerTF()) return;
  // ----- Последний посчитанный бар будет пересчитан
  if (counted_bars>0) counted_bars--;
  limit=Bars-counted_bars; if(limit>500) limit=500;
  // ----- Основной цикл
  for (int i=limit; i>=0; i--)   {
    //--------------------------------------------------------- 1 --
    Fractals.Upper=iFractals(NULL,0,MODE_UPPER,i);
    Fractals.Lower=iFractals(NULL,0,MODE_LOWER,i);
    if(Fractals.Upper>0)  {
      // ----- здесь нужно запустить функцию отрисовки нисходящих "Вил Эндрюса"
      if(ShowPitchfork.LowerTF)  {
        if(DrawLowerPitchfork(i, 0))  {
          // ----- здесь алерт
          if(OnAlert.Pitchfork.LowerTF && i==0)  {
            Alert(Symbol(),Period()," Нисходящие Вилы Эндрюса! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
          }
        }
      }
      // ----- отображаем вракталы младшего таймфрейма
      if(ShowFractals.LowerTF)  {
        ExtMapBuffer1[i]=Fractals.Upper+Spred*Point;
      }
    }
    if(Fractals.Lower>0)  {
      // ----- здесь нужно запустить функцию отрисовки восходящих "Вил Эндрюса"
      if(ShowPitchfork.LowerTF)  {
        if(DrawUpperPitchfork(i, 0))  {
          // ----- здесь алерт
          if(OnAlert.Pitchfork.LowerTF && i==0)  {
            Alert(Symbol(),Period()," Восходящие Вилы Эндрюса! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
          }
        }
      }
      // ----- отображаем вракталы младшего таймфрейма
      if(ShowFractals.LowerTF)  {
        ExtMapBuffer2[i]=Fractals.Lower-Spred*Point;
      }
    }
    //--------------------------------------------------------- 2 --
    Fractals.Upper=0;Fractals.Lower=0;
    //--------------------------------------------------------- 3 --
    // ----- появился новый бар старшего таймфрейма
    if(isNewBar.UpperTF(Time[i]))  {
      Fractals.Upper=iFractals(NULL,TF.Upper,MODE_UPPER,nBars.UpperTF);
      Fractals.Lower=iFractals(NULL,TF.Upper,MODE_LOWER,nBars.UpperTF);
      if(Fractals.Upper>0)  {
        // ----- здесь нужно запустить функцию отрисовки нисходящих "Вил Эндрюса"
        if(ShowPitchfork.UpperTF)  {
          if(DrawLowerPitchfork(nBars.UpperTF, TF.Upper))  {
            // ----- здесь алерт
            if(OnAlert.Pitchfork.UpperTF && nBars.UpperTF==0)  {
              Alert(Symbol(),Period()," Нисходящие Вилы Эндрюса! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
            }
          }
        }
        // ----- отображаем вракталы старшего таймфрейма
        if(ShowFractals.UpperTF)  {
          ExtMapBuffer3[iBarShift(NULL,0,iTime(NULL,TF.Upper,nBars.UpperTF),false)]=Fractals.Upper+Spred*Point;
        }
      }
      if(Fractals.Lower>0)  {
        // ----- здесь нужно запустить функцию отрисовки восходящих "Вил Эндрюса"
        if(ShowPitchfork.UpperTF)  {
          if(DrawUpperPitchfork(nBars.UpperTF, TF.Upper))  {
            // ----- здесь алерт
            if(OnAlert.Pitchfork.UpperTF && nBars.UpperTF==0)  {
              Alert(Symbol(),Period()," Восходящие Вилы Эндрюса! ",TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
            }
          }
        }
        // ----- отображаем вракталы старшего таймфрейма
        if(ShowFractals.UpperTF)  {
          ExtMapBuffer4[iBarShift(NULL,0,iTime(NULL,TF.Upper,nBars.UpperTF),false)]=Fractals.Lower-Spred*Point;
        }
      }
    }
 
 
  }
 
  return;
}
 
//+---------------------------------------------------------------------------+
bool isNewBar.LowerTF() {  // Функция возвращает true, если появиться новый бар на младшем тйамфрейме
  if(nBars.LowerTF!=Bars) {
    nBars.LowerTF=Bars; return(true);
  }
  return(false);
}
 
//+---------------------------------------------------------------------------+
bool isNewBar.UpperTF(datetime DateTime_) {  // Функция возвращает true, если появиться новый бар на старшем тйамфрейме
  if(nBars.UpperTF!=iBarShift(NULL, TF.Upper, DateTime_, false)) {
    nBars.UpperTF=iBarShift(NULL, TF.Upper, DateTime_, false); return(true);
  }
  return(false);
}
 
//+---------------------------------------------------------------------------+
bool DrawUpperPitchfork(int nBar, int TF=0)  {  // Функция определяет и рисует восходящие "Вилы Эндрюса"
double Fractals.Upper=0,Fractals.Lower=0;
string mFractals[3][3];
int i,j=0;
  //--------------------------------------------------------- 1 --
  // ----- определяем опорные точки
  for (i=nBar; i<Bars; i++)   {  // Цикл по барам
    Fractals.Upper=iFractals(NULL,TF,MODE_UPPER,i);
    Fractals.Lower=iFractals(NULL,TF,MODE_LOWER,i);
    // ----- ВАЖНО! начинаем проверку с нижнего фрактала 
    if(Fractals.Lower>0)  {
      mFractals[j][0]=TimeToStr(iTime(NULL,TF,i),TIME_DATE|TIME_MINUTES);
      mFractals[j][1]=DoubleToStr(Fractals.Lower,Digits);
      mFractals[j][2]=-1;
      j++;
    }
    if(Fractals.Upper>0)  {
      mFractals[j][0]=TimeToStr(iTime(NULL,TF,i),TIME_DATE|TIME_MINUTES);
      mFractals[j][1]=DoubleToStr(Fractals.Upper,Digits);
      mFractals[j][2]=1;
      j++;
    }
    if(j>3) break;
  }
  //--------------------------------------------------------- 2 --
  // ------ проверяем последовтельность опорных точек: MODE_LOWER->MODE_UPPER->MODE_LOWER
  if(StrToDouble(mFractals[0][2])==-1 && StrToDouble(mFractals[1][2])==1 && StrToDouble(mFractals[2][2])==-1)  {
    //--------------------------------------------------------- 1 --
    // ----- младший таймфрейм
    if(TF==0)  {
      if(QntPitchfork.Upper.LowerTF<nPitchfork.Upper.LowerTF)   {  // кол-во вил не превышено, рисуем новые вилы
        ObjectCreate("Pitchfork.Upper.LowerTF"+QntPitchfork.Upper.LowerTF, OBJ_PITCHFORK, 0,
        StrToTime(mFractals[2][0]), StrToDouble(mFractals[2][1]),
        StrToTime(mFractals[1][0]), StrToDouble(mFractals[1][1]),
        StrToTime(mFractals[0][0]), StrToDouble(mFractals[0][1]));
        ObjectSet("Pitchfork.Upper.LowerTF"+QntPitchfork.Upper.LowerTF,OBJPROP_COLOR,Tomato); 
        ObjectSet("Pitchfork.Upper.LowerTF"+QntPitchfork.Upper.LowerTF,OBJPROP_STYLE,STYLE_DASH); 
        QntPitchfork.Upper.LowerTF++;
      }
      if(QntPitchfork.Upper.LowerTF>=nPitchfork.Upper.LowerTF)  {  // кол-во вил превышено, изменяем параметры первых вил
        for (i=0; i<=QntPitchfork.Upper.LowerTF-2; i++)   {
          ObjectSet("Pitchfork.Upper.LowerTF"+i,OBJPROP_TIME1,ObjectGet("Pitchfork.Upper.LowerTF"+(i+1),OBJPROP_TIME1));
          ObjectSet("Pitchfork.Upper.LowerTF"+i,OBJPROP_PRICE1,ObjectGet("Pitchfork.Upper.LowerTF"+(i+1),OBJPROP_PRICE1));
          ObjectSet("Pitchfork.Upper.LowerTF"+i,OBJPROP_TIME2,ObjectGet("Pitchfork.Upper.LowerTF"+(i+1),OBJPROP_TIME2));
          ObjectSet("Pitchfork.Upper.LowerTF"+i,OBJPROP_PRICE2,ObjectGet("Pitchfork.Upper.LowerTF"+(i+1),OBJPROP_PRICE2));
          ObjectSet("Pitchfork.Upper.LowerTF"+i,OBJPROP_TIME3,ObjectGet("Pitchfork.Upper.LowerTF"+(i+1),OBJPROP_TIME3));
          ObjectSet("Pitchfork.Upper.LowerTF"+i,OBJPROP_PRICE3,ObjectGet("Pitchfork.Upper.LowerTF"+(i+1),OBJPROP_PRICE3));
        }
        ObjectSet("Pitchfork.Upper.LowerTF"+(QntPitchfork.Upper.LowerTF-1),OBJPROP_TIME1,StrToTime(mFractals[2][0]));
        ObjectSet("Pitchfork.Upper.LowerTF"+(QntPitchfork.Upper.LowerTF-1),OBJPROP_PRICE1,StrToDouble(mFractals[2][1]));
        ObjectSet("Pitchfork.Upper.LowerTF"+(QntPitchfork.Upper.LowerTF-1),OBJPROP_TIME2,StrToTime(mFractals[1][0]));
        ObjectSet("Pitchfork.Upper.LowerTF"+(QntPitchfork.Upper.LowerTF-1),OBJPROP_PRICE2,StrToDouble(mFractals[1][1]));
        ObjectSet("Pitchfork.Upper.LowerTF"+(QntPitchfork.Upper.LowerTF-1),OBJPROP_TIME3,StrToTime(mFractals[0][0]));
        ObjectSet("Pitchfork.Upper.LowerTF"+(QntPitchfork.Upper.LowerTF-1),OBJPROP_PRICE3,StrToDouble(mFractals[0][1]));
        ObjectSet("Pitchfork.Upper.LowerTF"+(QntPitchfork.Upper.LowerTF-1),OBJPROP_STYLE,STYLE_SOLID); 
      }
    }
    //--------------------------------------------------------- 2 --
    // ----- старший таймфрейм
    if(TF!=0)  {
      if(QntPitchfork.Upper.UpperTF<nPitchfork.Upper.UpperTF)   {  // кол-во вил не превышено, рисуем новые вилы
        ObjectCreate("Pitchfork.Upper.UpperTF"+QntPitchfork.Upper.UpperTF, OBJ_PITCHFORK, 0,
        StrToTime(mFractals[2][0]), StrToDouble(mFractals[2][1]),
        StrToTime(mFractals[1][0]), StrToDouble(mFractals[1][1]),
        StrToTime(mFractals[0][0]), StrToDouble(mFractals[0][1]));
        ObjectSet("Pitchfork.Upper.UpperTF"+QntPitchfork.Upper.UpperTF,OBJPROP_COLOR,Tomato); 
        ObjectSet("Pitchfork.Upper.UpperTF"+QntPitchfork.Upper.UpperTF,OBJPROP_STYLE,STYLE_DASH); 
        ObjectSet("Pitchfork.Upper.UpperTF"+QntPitchfork.Upper.UpperTF,OBJPROP_WIDTH,2); 
        QntPitchfork.Upper.UpperTF++;
      }
      if(QntPitchfork.Upper.UpperTF>=nPitchfork.Upper.UpperTF)  {  // кол-во вил превышено, изменяем параметры первых вил
        for (i=0; i<=QntPitchfork.Upper.UpperTF-2; i++)   {
          ObjectSet("Pitchfork.Upper.UpperTF"+i,OBJPROP_TIME1,ObjectGet("Pitchfork.Upper.UpperTF"+(i+1),OBJPROP_TIME1));
          ObjectSet("Pitchfork.Upper.UpperTF"+i,OBJPROP_PRICE1,ObjectGet("Pitchfork.Upper.UpperTF"+(i+1),OBJPROP_PRICE1));
          ObjectSet("Pitchfork.Upper.UpperTF"+i,OBJPROP_TIME2,ObjectGet("Pitchfork.Upper.UpperTF"+(i+1),OBJPROP_TIME2));
          ObjectSet("Pitchfork.Upper.UpperTF"+i,OBJPROP_PRICE2,ObjectGet("Pitchfork.Upper.UpperTF"+(i+1),OBJPROP_PRICE2));
          ObjectSet("Pitchfork.Upper.UpperTF"+i,OBJPROP_TIME3,ObjectGet("Pitchfork.Upper.UpperTF"+(i+1),OBJPROP_TIME3));
          ObjectSet("Pitchfork.Upper.UpperTF"+i,OBJPROP_PRICE3,ObjectGet("Pitchfork.Upper.UpperTF"+(i+1),OBJPROP_PRICE3));
        }
        ObjectSet("Pitchfork.Upper.UpperTF"+(QntPitchfork.Upper.UpperTF-1),OBJPROP_TIME1,StrToTime(mFractals[2][0]));
        ObjectSet("Pitchfork.Upper.UpperTF"+(QntPitchfork.Upper.UpperTF-1),OBJPROP_PRICE1,StrToDouble(mFractals[2][1]));
        ObjectSet("Pitchfork.Upper.UpperTF"+(QntPitchfork.Upper.UpperTF-1),OBJPROP_TIME2,StrToTime(mFractals[1][0]));
        ObjectSet("Pitchfork.Upper.UpperTF"+(QntPitchfork.Upper.UpperTF-1),OBJPROP_PRICE2,StrToDouble(mFractals[1][1]));
        ObjectSet("Pitchfork.Upper.UpperTF"+(QntPitchfork.Upper.UpperTF-1),OBJPROP_TIME3,StrToTime(mFractals[0][0]));
        ObjectSet("Pitchfork.Upper.UpperTF"+(QntPitchfork.Upper.UpperTF-1),OBJPROP_PRICE3,StrToDouble(mFractals[0][1]));
        ObjectSet("Pitchfork.Upper.UpperTF"+(QntPitchfork.Upper.UpperTF-1),OBJPROP_STYLE,STYLE_SOLID); 
      }
    }
  return(true);
  }
  return(false);
}
 
//+---------------------------------------------------------------------------+
bool DrawLowerPitchfork(int nBar, int TF=0)  {  // Функция определяет и рисует нисходящие "Вилы Эндрюса"
double Fractals.Upper=0,Fractals.Lower=0;
string mFractals[3][3];
int i,j=0;
  //--------------------------------------------------------- 1 --
  // ----- определяем опорные точки
  for (i=nBar; i<Bars; i++)   {  // Цикл по барам
    Fractals.Upper=iFractals(NULL,TF,MODE_UPPER,i);
    Fractals.Lower=iFractals(NULL,TF,MODE_LOWER,i);
    // ----- ВАЖНО! начинаем проверку с верхнего фрактала 
    if(Fractals.Upper>0)  {
      mFractals[j][0]=TimeToStr(iTime(NULL,TF,i),TIME_DATE|TIME_MINUTES);
      mFractals[j][1]=DoubleToStr(Fractals.Upper,Digits);
      mFractals[j][2]=1;
      j++;
    }
    if(Fractals.Lower>0)  {
      mFractals[j][0]=TimeToStr(iTime(NULL,TF,i),TIME_DATE|TIME_MINUTES);
      mFractals[j][1]=DoubleToStr(Fractals.Lower,Digits);
      mFractals[j][2]=-1;
      j++;
    }
    if(j>3) break;
  }
  //--------------------------------------------------------- 2 --
  // ------ проверяем последовтельность опорных точек: MODE_UPPER->MODE_LOWER->MODE_UPPER
  if(StrToDouble(mFractals[0][2])==1 && StrToDouble(mFractals[1][2])==-1 && StrToDouble(mFractals[2][2])==1)  {
    //--------------------------------------------------------- 1 --
    // ----- младший таймфрейм
    if(TF==0)  {
      if(QntPitchfork.Lower.LowerTF<nPitchfork.Lower.LowerTF)   {  // кол-во вил не превышено, рисуем новые вилы
        ObjectCreate("Pitchfork.Lower.LowerTF"+QntPitchfork.Lower.LowerTF, OBJ_PITCHFORK, 0,
        StrToTime(mFractals[2][0]), StrToDouble(mFractals[2][1]),
        StrToTime(mFractals[1][0]), StrToDouble(mFractals[1][1]),
        StrToTime(mFractals[0][0]), StrToDouble(mFractals[0][1]));
        ObjectSet("Pitchfork.Lower.LowerTF"+QntPitchfork.Lower.LowerTF,OBJPROP_COLOR,CornflowerBlue); 
        ObjectSet("Pitchfork.Lower.LowerTF"+QntPitchfork.Lower.LowerTF,OBJPROP_STYLE,STYLE_DASH); 
        QntPitchfork.Lower.LowerTF++;
      }
      if(QntPitchfork.Lower.LowerTF>=nPitchfork.Lower.LowerTF)  {  // кол-во вил превышено, изменяем параметры первых вил
        for (i=0; i<=QntPitchfork.Lower.LowerTF-2; i++)   {
          ObjectSet("Pitchfork.Lower.LowerTF"+i,OBJPROP_TIME1,ObjectGet("Pitchfork.Lower.LowerTF"+(i+1),OBJPROP_TIME1));
          ObjectSet("Pitchfork.Lower.LowerTF"+i,OBJPROP_PRICE1,ObjectGet("Pitchfork.Lower.LowerTF"+(i+1),OBJPROP_PRICE1));
          ObjectSet("Pitchfork.Lower.LowerTF"+i,OBJPROP_TIME2,ObjectGet("Pitchfork.Lower.LowerTF"+(i+1),OBJPROP_TIME2));
          ObjectSet("Pitchfork.Lower.LowerTF"+i,OBJPROP_PRICE2,ObjectGet("Pitchfork.Lower.LowerTF"+(i+1),OBJPROP_PRICE2));
          ObjectSet("Pitchfork.Lower.LowerTF"+i,OBJPROP_TIME3,ObjectGet("Pitchfork.Lower.LowerTF"+(i+1),OBJPROP_TIME3));
          ObjectSet("Pitchfork.Lower.LowerTF"+i,OBJPROP_PRICE3,ObjectGet("Pitchfork.Lower.LowerTF"+(i+1),OBJPROP_PRICE3));
        }
        ObjectSet("Pitchfork.Lower.LowerTF"+(QntPitchfork.Lower.LowerTF-1),OBJPROP_TIME1,StrToTime(mFractals[2][0]));
        ObjectSet("Pitchfork.Lower.LowerTF"+(QntPitchfork.Lower.LowerTF-1),OBJPROP_PRICE1,StrToDouble(mFractals[2][1]));
        ObjectSet("Pitchfork.Lower.LowerTF"+(QntPitchfork.Lower.LowerTF-1),OBJPROP_TIME2,StrToTime(mFractals[1][0]));
        ObjectSet("Pitchfork.Lower.LowerTF"+(QntPitchfork.Lower.LowerTF-1),OBJPROP_PRICE2,StrToDouble(mFractals[1][1]));
        ObjectSet("Pitchfork.Lower.LowerTF"+(QntPitchfork.Lower.LowerTF-1),OBJPROP_TIME3,StrToTime(mFractals[0][0]));
        ObjectSet("Pitchfork.Lower.LowerTF"+(QntPitchfork.Lower.LowerTF-1),OBJPROP_PRICE3,StrToDouble(mFractals[0][1]));
        ObjectSet("Pitchfork.Lower.LowerTF"+(QntPitchfork.Lower.LowerTF-1),OBJPROP_STYLE,STYLE_SOLID); 
      }
    }
    //--------------------------------------------------------- 2 --
    // ----- старший таймфрейм
    if(TF!=0)  {
      if(QntPitchfork.Lower.UpperTF<nPitchfork.Lower.UpperTF)   {  // кол-во вил не превышено, рисуем новые вилы
        ObjectCreate("Pitchfork.Lower.UpperTF"+QntPitchfork.Lower.UpperTF, OBJ_PITCHFORK, 0,
        StrToTime(mFractals[2][0]), StrToDouble(mFractals[2][1]),
        StrToTime(mFractals[1][0]), StrToDouble(mFractals[1][1]),
        StrToTime(mFractals[0][0]), StrToDouble(mFractals[0][1]));
        ObjectSet("Pitchfork.Lower.UpperTF"+QntPitchfork.Lower.UpperTF,OBJPROP_COLOR,CornflowerBlue); 
        ObjectSet("Pitchfork.Lower.UpperTF"+QntPitchfork.Lower.UpperTF,OBJPROP_STYLE,STYLE_DASH); 
        ObjectSet("Pitchfork.Lower.UpperTF"+QntPitchfork.Lower.UpperTF,OBJPROP_WIDTH,2); 
        QntPitchfork.Lower.UpperTF++;
      }
      if(QntPitchfork.Lower.UpperTF>=nPitchfork.Lower.UpperTF)  {  // кол-во вил превышено, изменяем параметры первых вил
        for (i=0; i<=QntPitchfork.Lower.UpperTF-2; i++)   {
          ObjectSet("Pitchfork.Lower.UpperTF"+i,OBJPROP_TIME1,ObjectGet("Pitchfork.Lower.UpperTF"+(i+1),OBJPROP_TIME1));
          ObjectSet("Pitchfork.Lower.UpperTF"+i,OBJPROP_PRICE1,ObjectGet("Pitchfork.Lower.UpperTF"+(i+1),OBJPROP_PRICE1));
          ObjectSet("Pitchfork.Lower.UpperTF"+i,OBJPROP_TIME2,ObjectGet("Pitchfork.Lower.UpperTF"+(i+1),OBJPROP_TIME2));
          ObjectSet("Pitchfork.Lower.UpperTF"+i,OBJPROP_PRICE2,ObjectGet("Pitchfork.Lower.UpperTF"+(i+1),OBJPROP_PRICE2));
          ObjectSet("Pitchfork.Lower.UpperTF"+i,OBJPROP_TIME3,ObjectGet("Pitchfork.Lower.UpperTF"+(i+1),OBJPROP_TIME3));
          ObjectSet("Pitchfork.Lower.UpperTF"+i,OBJPROP_PRICE3,ObjectGet("Pitchfork.Lower.UpperTF"+(i+1),OBJPROP_PRICE3));
        }
        ObjectSet("Pitchfork.Lower.UpperTF"+(QntPitchfork.Lower.UpperTF-1),OBJPROP_TIME1,StrToTime(mFractals[2][0]));
        ObjectSet("Pitchfork.Lower.UpperTF"+(QntPitchfork.Lower.UpperTF-1),OBJPROP_PRICE1,StrToDouble(mFractals[2][1]));
        ObjectSet("Pitchfork.Lower.UpperTF"+(QntPitchfork.Lower.UpperTF-1),OBJPROP_TIME2,StrToTime(mFractals[1][0]));
        ObjectSet("Pitchfork.Lower.UpperTF"+(QntPitchfork.Lower.UpperTF-1),OBJPROP_PRICE2,StrToDouble(mFractals[1][1]));
        ObjectSet("Pitchfork.Lower.UpperTF"+(QntPitchfork.Lower.UpperTF-1),OBJPROP_TIME3,StrToTime(mFractals[0][0]));
        ObjectSet("Pitchfork.Lower.UpperTF"+(QntPitchfork.Lower.UpperTF-1),OBJPROP_PRICE3,StrToDouble(mFractals[0][1]));
        ObjectSet("Pitchfork.Lower.UpperTF"+(QntPitchfork.Lower.UpperTF-1),OBJPROP_STYLE,STYLE_SOLID); 
      }
    }
  return(true);
  }
  return(false);
}
 
