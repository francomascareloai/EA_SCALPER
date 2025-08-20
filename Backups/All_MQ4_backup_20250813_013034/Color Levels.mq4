//+------------------------------------------------------------------+
//|                                                 Color Levels.mq4 |
//|                                        Copyright 2015, omutmoren |
//|                                       https://www.investlabfx.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, omutmoren"
#property link      "https://www.investlabfx.ru"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator Parameters                                      |
//+------------------------------------------------------------------+
extern ENUM_BASE_CORNER InpCorner   =  CORNER_LEFT_UPPER;   // Угол графика для привязки
extern color            panl_0_cl   =  clrGainsboro;        // Цвет панели инструментов
extern bool             panl_0_st   =  true;                // Отображать панель?
extern color            rect_1_cl   =  clrDodgerBlue;       // 1. Цвет границы
extern ENUM_LINE_STYLE  rect_1_st   =  STYLE_SOLID;         // 1. Стиль границы
extern int              rect_1_wd   =  2;                   // 1. Толщина границы
extern color            rect_2_cl   =  clrFireBrick;        // 2. Цвет границы
extern ENUM_LINE_STYLE  rect_2_st   =  STYLE_SOLID;         // 2. Стиль границы
extern int              rect_2_wd   =  2;                   // 2. Толщина границы
extern color            rect_3_cl   =  clrBlue;             // 3. Цвет прямоугольника
extern color            rect_4_cl   =  clrRed;              // 4. Цвет прямоугольника
extern color            rect_5_cl   =  clrDarkGray;         // 5. Цвет прямоугольника
extern color            line_1_cl   =  clrDodgerBlue;       // 6. Цвет линии
extern ENUM_LINE_STYLE  line_1_st   =  STYLE_SOLID;         // 6. Стиль линии
extern int              line_1_wd   =  2;                   // 6. Толщина линии
extern color            line_2_cl   =  clrFireBrick;        // 7. Цвет линии
extern ENUM_LINE_STYLE  line_2_st   =  STYLE_SOLID;         // 7. Стиль линии
extern int              line_2_wd   =  2;                   // 7. Толщина линии

// Для кнопок
bool              InpSelection      =  false;               // Выделить для перемещений
bool              InpHidden         =  true;                // Скрыт в списке объектов
bool              InpHidden_OBJ     =  false;               // Скрыт в списке объектов
bool              InpBackRect       =  false;               // Объект на заднем плане

// Координаты
extern int x_coor = 10;    // Сдвиг по оси X
extern int y_coor = 20;    // Сдвиг по оси Y
int x_size = 155;
int y_size = 30;
int x_step = 5;
int y_panl = 20;
int x_rect = 20;
int y_rect = 20;
int y_line = 6;

string obj_name[8] = {"name_1","name_2","name_3","name_4","name_5","name_6","name_7","name_8"};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment("");
   RectLabelDelete(0,obj_name[0]);
   RectLabelDelete(0,obj_name[1]);
   RectLabelDelete(0,obj_name[2]);
   RectLabelDelete(0,obj_name[3]);
   RectLabelDelete(0,obj_name[4]);
   RectLabelDelete(0,obj_name[5]);
   RectLabelDelete(0,obj_name[6]);
   RectLabelDelete(0,obj_name[7]);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   CreatePanel();
   CreateRect();

   return(rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   datetime dt_1     = 0;
   double   price_1  = 0;
   datetime dt_2     = 0;
   double   price_2  = 0;
   int      window   = 0;
   int      x        = 0;
   int      y        = 0;
   
   // Нажатие на первый прямоугольник
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject = sparam;
      if (clickedChartObject == obj_name[1]) {
         string name = "name_" + IntegerToString(MathRand() + 100,0,' ');
         
         y = y_coor + y_rect + 2*x_step;
         ChartXYToTimePrice(0, x_coor + x_step, y, window, dt_1, price_1);
         
         y = y_coor + 2*y_rect + 3*x_step;
         ChartXYToTimePrice(0, x_coor + x_size, y, window, dt_2, price_2);
         
         RectangleCreate(0,name,0,dt_1,price_1,dt_2,price_2,rect_1_cl,rect_1_st,rect_1_wd,false,false,true,InpHidden_OBJ,0);
      }
   }
   // Нажатие на второй прямоугольник
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject = sparam;
      if (clickedChartObject == obj_name[2]) {
         string name = "name_" + IntegerToString(MathRand() + 100,0,' ');
         
         y = y_coor + 2*y_rect + 3*x_step;
         ChartXYToTimePrice(0, x_coor + x_step, y, window, dt_1, price_1);
         
         y = y_coor + 3*y_rect + 4*x_step;
         ChartXYToTimePrice(0, x_coor + x_size, y, window, dt_2, price_2);         
         
         RectangleCreate(0,name,0,dt_1,price_1,dt_2,price_2,rect_2_cl,rect_2_st,rect_2_wd,false,false,true,InpHidden_OBJ,0);
      }
   }   
   // Нажатие на третий прямоугольник
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject = sparam;
      if (clickedChartObject == obj_name[3]) {
         string name = "name_" + IntegerToString(MathRand() + 100,0,' ');

         y = y_coor + 3*y_rect + 4*x_step;
         ChartXYToTimePrice(0, x_coor + x_step, y, window, dt_1, price_1);
         
         y = y_coor + 4*y_rect + 5*x_step;
         ChartXYToTimePrice(0, x_coor + x_size, y, window, dt_2, price_2);   
         
         RectangleCreate(0,name,0,dt_1,price_1,dt_2,price_2,rect_3_cl,STYLE_SOLID,0,true,false,true,InpHidden_OBJ,0);
      }
   }
   // Нажатие на четвёртый прямоугольник
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject = sparam;
      if (clickedChartObject == obj_name[4]) {
         string name = "name_" + IntegerToString(MathRand() + 100,0,' ');

         y = y_coor + 4*y_rect + 5*x_step;
         ChartXYToTimePrice(0, x_coor + x_step, y, window, dt_1, price_1);
         
         y = y_coor + 5*y_rect + 6*x_step;
         ChartXYToTimePrice(0, x_coor + x_size, y, window, dt_2, price_2);
         
         RectangleCreate(0,name,0,dt_1,price_1,dt_2,price_2,rect_4_cl,STYLE_SOLID,0,true,false,true,InpHidden_OBJ,0);
      }
   }
   // Нажатие на пятый прямоугольник
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject = sparam;
      if (clickedChartObject == obj_name[5]) {
         string name = "name_" + IntegerToString(MathRand() + 100,0,' ');

         y = y_coor + 5*y_rect + 6*x_step;
         ChartXYToTimePrice(0, x_coor + x_step, y, window, dt_1, price_1);
         
         y = y_coor + 6*y_rect + 7*x_step;
         ChartXYToTimePrice(0, x_coor + x_size, y, window, dt_2, price_2);
         
         RectangleCreate(0,name,0,dt_1,price_1,dt_2,price_2,rect_5_cl,STYLE_SOLID,0,true,false,true,InpHidden_OBJ,0);
      }
   }
   // Нажатие на первую линию
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject = sparam;
      if (clickedChartObject == obj_name[6]) {
         string name = "name_" + IntegerToString(MathRand() + 100,0,' ');
         
         y = y_coor + 6*y_rect + 8*x_step;
         ChartXYToTimePrice(0, x_coor + x_step, y, window, dt_1, price_1);
         ChartXYToTimePrice(0, x_coor + x_size, y, window, dt_2, price_2);         
         
         TrendCreate(0,name,0,dt_1,price_1,dt_2,price_2,line_1_cl,line_1_st,line_1_wd,InpBackRect,true,false,false,InpHidden_OBJ,0);
      }
   }
   // Нажатие на вторую линию
   if (id == CHARTEVENT_OBJECT_CLICK) {
      string clickedChartObject = sparam;
      if (clickedChartObject == obj_name[7]) {
         string name = "name_" + IntegerToString(MathRand() + 100,0,' ');
         
         y = y_coor + 6*y_rect + 10*x_step;
         ChartXYToTimePrice(0, x_coor + x_step, y, window, dt_1, price_1);
         ChartXYToTimePrice(0, x_coor + x_size, y, window, dt_2, price_2);         
         
         TrendCreate(0,name,0,dt_1,price_1,dt_2,price_2,line_2_cl,line_2_st,line_2_wd,InpBackRect,true,false,false,InpHidden_OBJ,0);
      }
   }
}

//+------------------------------------------------------------------+
void CreatePanel()
{
   // Панель инструментов
   
   if (panl_0_st) {
   
      int x_pn = x_coor, y_pn = y_coor;
      if (InpCorner == 1)  x_pn = x_coor + x_size + x_step;
      if (InpCorner == 2)  y_pn = y_coor + y_rect + x_step;
      if (InpCorner == 3) {x_pn = x_coor + x_size + x_step; y_pn = y_coor + y_rect + x_step;}
   
      if (!RectLabelCreate(0,obj_name[0],0,x_pn,y_pn,x_size,y_size,panl_0_cl,BORDER_SUNKEN,InpCorner,
           clrBlack,STYLE_SOLID,2,true,InpSelection,true,0)) {
         return;
      }   
   } else {
      panl_0_cl = ChartBackColorGet(0);
   }
}
//+------------------------------------------------------------------+
void CreateRect()
{
   // Первый прямоугольник
   int x_pn = x_coor + x_step, y_pn = y_coor + x_step;
   if (InpCorner == 1)  x_pn = x_coor + x_size;
   if (InpCorner == 2)  y_pn = y_coor + y_rect;
   if (InpCorner == 3) {x_pn = x_coor + x_size; y_pn = y_coor + y_rect;}
   
   if (!RectLabelCreate(0,obj_name[1],0,x_pn,y_pn,x_rect,y_rect,panl_0_cl,BORDER_FLAT,InpCorner,
        rect_1_cl,rect_1_st,rect_1_wd,InpBackRect,InpSelection,InpHidden,0)) {
      return;
   }   

   // Второй прямоугольник
   x_pn = x_coor + x_rect + 2*x_step; y_pn = y_coor + x_step;
   if (InpCorner == 1)  x_pn = x_coor + x_size - x_step - x_rect;
   if (InpCorner == 2)  y_pn = y_coor + y_rect;
   if (InpCorner == 3) {x_pn = x_coor + x_size - x_step - x_rect; y_pn = y_coor + y_rect;}
   
   if (!RectLabelCreate(0,obj_name[2],0,x_pn,y_pn,x_rect,y_rect,panl_0_cl,BORDER_FLAT,InpCorner,
        rect_2_cl,rect_2_st,rect_2_wd,InpBackRect,InpSelection,InpHidden,0)) {
      return;
   }  

   // Третий прямоугольник
   x_pn = x_coor + 2*x_rect + 3*x_step; y_pn = y_coor + x_step;
   if (InpCorner == 1)  x_pn = x_coor + x_size - 2*x_step - 2*x_rect;
   if (InpCorner == 2)  y_pn = y_coor + y_rect;
   if (InpCorner == 3) {x_pn = x_coor + x_size - 2*x_step - 2*x_rect; y_pn = y_coor + y_rect;}
   
   if (!RectLabelCreate(0,obj_name[3],0,x_pn,y_pn,x_rect,y_rect,rect_3_cl,BORDER_FLAT,InpCorner,
        rect_3_cl,STYLE_SOLID,0,InpBackRect,InpSelection,InpHidden,0)) {
      return;
   }  

   // Четвёртый прямоугольник
   x_pn = x_coor + 3*x_rect + 4*x_step; y_pn = y_coor + x_step;
   if (InpCorner == 1)  x_pn = x_coor + x_size - 3*x_step - 3*x_rect;
   if (InpCorner == 2)  y_pn = y_coor + y_rect;
   if (InpCorner == 3) {x_pn = x_coor + x_size - 3*x_step - 3*x_rect; y_pn = y_coor + y_rect;}
   
   if (!RectLabelCreate(0,obj_name[4],0,x_pn,y_pn,x_rect,y_rect,rect_4_cl,BORDER_FLAT,InpCorner,
        rect_4_cl,STYLE_SOLID,0,InpBackRect,InpSelection,InpHidden,0)) {
      return;
   }

   // Пятый прямоугольник
   x_pn = x_coor + 4*x_rect + 5*x_step; y_pn = y_coor + x_step;
   if (InpCorner == 1)  x_pn = x_coor + x_size - 4*x_step - 4*x_rect;
   if (InpCorner == 2)  y_pn = y_coor + y_rect;
   if (InpCorner == 3) {x_pn = x_coor + x_size - 4*x_step - 4*x_rect; y_pn = y_coor + y_rect;}
   
   if (!RectLabelCreate(0,obj_name[5],0,x_pn,y_pn,x_rect,y_rect,rect_5_cl,BORDER_FLAT,InpCorner,
        rect_5_cl,STYLE_SOLID,0,InpBackRect,InpSelection,InpHidden,0)) {
      return;
   }
   
   // Первая линия
   x_pn = x_coor + 5*x_rect + 6*x_step; y_pn = y_coor + x_step;
   if (InpCorner == 1)  x_pn = x_coor + x_size - 5*x_step - 5*x_rect;
   if (InpCorner == 2)  y_pn = y_coor + y_rect;
   if (InpCorner == 3) {x_pn = x_coor + x_size - 5*x_step - 5*x_rect; y_pn = y_coor + y_rect;}
   
   if (!RectLabelCreate(0,obj_name[6],0,x_pn,y_pn,x_rect,y_line,line_1_cl,BORDER_FLAT,InpCorner,
        line_1_cl,STYLE_SOLID,0,InpBackRect,InpSelection,InpHidden,0)) {
      return;
   }

   // Вторая линия
   x_pn = x_coor + 5*x_rect + 6*x_step; y_pn = y_coor + y_rect;
   if (InpCorner == 1)  x_pn = x_coor + x_size - 5*x_step - 5*x_rect;
   if (InpCorner == 2)  y_pn = y_coor + x_step;
   if (InpCorner == 3) {x_pn = x_coor + x_size - 5*x_step - 5*x_rect; y_pn = y_coor + x_step;}
   
   if (!RectLabelCreate(0,obj_name[7],0,x_pn,y_pn,x_rect,y_line,line_2_cl,BORDER_FLAT,InpCorner,
        line_2_cl,STYLE_SOLID,0,InpBackRect,InpSelection,InpHidden,0)) {
      return;
   }
}
//+------------------------------------------------------------------+
//| Создает прямоугольную метку                                      |
//+------------------------------------------------------------------+
bool RectLabelCreate(const long             chart_ID=0,               // ID графика
                     const string           name="RectLabel",         // имя метки
                     const int              sub_window=0,             // номер подокна
                     const int              x=0,                      // координата по оси X
                     const int              y=0,                      // координата по оси Y
                     const int              width=50,                 // ширина
                     const int              height=18,                // высота
                     const color            back_clr=C'236,233,216',  // цвет фона
                     const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // тип границы
                     const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // угол графика для привязки
                     const color            clr=clrRed,               // цвет плоской границы (Flat)
                     const ENUM_LINE_STYLE  style=STYLE_SOLID,        // стиль плоской границы
                     const int              line_width=1,             // толщина плоской границы
                     const bool             back=false,               // на заднем плане
                     const bool             selection=false,          // выделить для перемещений
                     const bool             hidden=true,              // скрыт в списке объектов
                     const long             z_order=0)                // приоритет на нажатие мышью
{
   //--- сбросим значение ошибки
   ResetLastError();
   //--- создадим прямоугольную метку
   if (ObjectFind(name) == -1)
      ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0);

   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);              // установим координаты метки
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);              // установим размеры метки
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);         // установим цвет фона
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);       // установим тип границы
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);            // установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);                // установим цвет плоской рамки (в режиме Flat)
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);              // установим стиль линии плоской рамки
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);         // установим толщину плоской границы
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);                // отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);     // включим (true) или отключим (false) режим перемещения метки мышью
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);            // скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);           // установим приоритет на получение события нажатия мыши на графике
   
   return(true);
}
//+------------------------------------------------------------------+
//| Удаляет прямоугольную метку                                      |
//+------------------------------------------------------------------+
bool RectLabelDelete(const long   chart_ID=0,       // ID графика
                     const string name="RectLabel") // имя метки
{
   //--- сбросим значение ошибки
   ResetLastError();
   //--- удалим метку
   if (ObjectFind(chart_ID,name) >= 0) 
      ObjectDelete(chart_ID,name);
   //--- успешное выполнение
   return(true);
}
//+------------------------------------------------------------------+
//| Функция получает цвет фона графика.                              |
//+------------------------------------------------------------------+
color ChartBackColorGet(const long chart_ID=0)
  {
//--- подготовим переменную для получения цвета
   long result=clrNONE;
//--- сбросим значение ошибки
   ResetLastError();
//--- получим цвет фона графика
   if(!ChartGetInteger(chart_ID,CHART_COLOR_BACKGROUND,0,result))
     {
      //--- выведем сообщение об ошибке в журнал "Эксперты"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- вернем значение свойства графика
   return((color)result);
  }
  
  
//+------------------------------------------------------------------+
//| Cоздает прямоугольник по заданным координатам                    |
//+------------------------------------------------------------------+
bool RectangleCreate(const long            chart_ID=0,        // ID графика
                     const string          name="Rectangle",  // имя прямоугольника
                     const int             sub_window=0,      // номер подокна 
                     datetime              time1=0,           // время первой точки
                     double                price1=0,          // цена первой точки
                     datetime              time2=0,           // время второй точки
                     double                price2=0,          // цена второй точки
                     const color           clr=clrRed,        // цвет прямоугольника
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линий прямоугольника
                     const int             width=1,           // толщина линий прямоугольника
                     const bool            fill=false,        // заливка прямоугольника цветом
                     const bool            back=false,        // на заднем плане
                     const bool            selection=true,    // выделить для перемещений
                     const bool            hidden=true,       // скрыт в списке объектов
                     const long            z_order=0)         // приоритет на нажатие мышью
{
   //--- сбросим значение ошибки
   ResetLastError();
   //--- создадим прямоугольник по заданным координатам
   if (ObjectFind(name) == -1)
      ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2);

   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);             //--- установим цвет прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);           //--- установим стиль линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);           //--- установим толщину линий прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);             //--- включим (true) или отключим (false) режим заливки прямоугольника
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);             //--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);  //--- включим (true) или отключим (false) режим выделения прямоугольника для перемещений
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);    //--- при создании графического объекта функцией ObjectCreate, по умолчанию объект
                                                                  //--- нельзя выделить и перемещать. Внутри же этого метода параметр selection
                                                                  //--- по умолчанию равен true, что позволяет выделять и перемещать этот объект
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);         //--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);        //--- установим приоритет на получение события нажатия мыши на графике

   return(true);
}
//+------------------------------------------------------------------+
//| Удаляет прямоугольник                                            |
//+------------------------------------------------------------------+
bool RectangleDelete(const long   chart_ID=0,       // ID графика
                     const string name="Rectangle") // имя прямоугольника
{
   //--- сбросим значение ошибки
   ResetLastError();
   //--- удалим прямоугольник
   if (ObjectFind(chart_ID,name) >= 0) 
      ObjectDelete(chart_ID,name);

   return(true);
}
//+------------------------------------------------------------------+
//| Создает линию тренда по заданным координатам                     |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // ID графика
                 const string          name="TrendLine",  // имя линии
                 const int             sub_window=0,      // номер подокна
                 datetime              time1=0,           // время первой точки
                 double                price1=0,          // цена первой точки
                 datetime              time2=0,           // время второй точки
                 double                price2=0,          // цена второй точки
                 const color           clr=clrRed,        // цвет линии
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии
                 const int             width=1,           // толщина линии
                 const bool            back=false,        // на заднем плане
                 const bool            selection=true,    // выделить для перемещений
                 const bool            ray_left=false,    // продолжение линии влево
                 const bool            ray_right=false,   // продолжение линии вправо
                 const bool            hidden=true,       // скрыт в списке объектов
                 const long            z_order=0)         // приоритет на нажатие мышью
{
   //--- сбросим значение ошибки
   ResetLastError();
   //--- создадим трендовую линию по заданным координатам
   if (ObjectFind(name) == -1)
      ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2);
   
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);             //--- установим цвет линии
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);           //--- установим стиль отображения линии
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);           //--- установим толщину линии
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);             //--- отобразим на переднем (false) или заднем (true) плане
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);  //--- включим (true) или отключим (false) режим перемещения линии мышью
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);    //--- при создании графического объекта функцией ObjectCreate, по умолчанию объект
                                                                  //--- нельзя выделить и перемещать. Внутри же этого метода параметр selection
                                                                  //--- по умолчанию равен true, что позволяет выделять и перемещать этот объект
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);     //--- включим (true) или отключим (false) режим продолжения отображения линии влево
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);   //--- включим (true) или отключим (false) режим продолжения отображения линии вправо
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);         //--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);        //--- установим приоритет на получение события нажатия мыши на графике

   return(true);
}
//+------------------------------------------------------------------+
//| Функция удаляет линию тренда с графика.                          |
//+------------------------------------------------------------------+
bool TrendDelete(const long   chart_ID=0,       // ID графика
                 const string name="TrendLine") // имя линии
{
   //--- сбросим значение ошибки
   ResetLastError();
   //--- удалим линию тренда
   if (!ObjectDelete(chart_ID,name))
   {
      Print(__FUNCTION__,
            ": не удалось удалить линию тренда! Код ошибки = ",GetLastError());
      return(false);
   }
   //--- успешное выполнение
   return(true);
}