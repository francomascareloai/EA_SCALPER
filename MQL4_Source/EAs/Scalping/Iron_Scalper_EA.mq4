//+------------------------------------------------------------------+
//|                                              Iron Scalper EA.mq4 |
//|                                                       MFOREX.PRO |
//|                                           https://www.mforex.pro |
//+------------------------------------------------------------------+
#property copyright "MFOREX.PRO"
#property link      "https://www.mforex.pro"
#property version   "1.00"
//+------------------------------------------------------------------+
//|========================= Параметры ==============================|                                                    
//+------------------------------------------------------------------+   
extern double    Risk             =0.1;   //Риск в процентах 
extern double    StopLossProcent  =20;
extern double    Tral             =20;   //Трал в пунктах, если =0 то не работает
extern double    TralStart        =3;   //Шаг трала в пунктах
extern double    TimeStart        =1;   //Время начала работы
extern double    TimeEnd          =23;   //Время завершения работы
extern double    PipsStep         =4;   //Величина бара входа
extern double    Magic            =2021; //Маркер ордеров
extern bool      Info             =true;   //Вкл/выкл вывод информации на график
extern color     TextColor        =White;    // Цвет текста
extern color     InfoDataColor    =DodgerBlue; // Цвет данных в таблице Info
extern color     FonColor         =Black;    // Цвет фона блоков
extern int       FontSizeInfo     =7;       // размер шрифта
//+------------------------------------------------------------------+
//|====================== Доп. Переменные ===========================|
//+------------------------------------------------------------------+
string           Commemt          ="www.mforex.pro";
int              D,o;
double           Lot              =0;
double           Slb,Sls;
double           spread;
datetime         NewBar           =0;
//+------------------------------------------------------------------+
//|====================== Инициализация =============================|
//+------------------------------------------------------------------+
int OnInit()
{
EventSetMillisecondTimer(100);
D=1;
if (Digits==5 || Digits==3)
{D=10;}
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|===================== ДеИнициализация ============================|
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
EventKillTimer();
ObjectsDeleteAll(0,OBJ_LABEL);
ObjectsDeleteAll(0,OBJ_RECTANGLE_LABEL);
}
//+------------------------------------------------------------------+
//|======================== Старт ===================================|
//+------------------------------------------------------------------+
void OnTick()
{
//======= Находим лот 
Lot=NormalizeDouble(AccountBalance()/10*Risk/(MarketInfo(Symbol(),MODE_TICKVALUE)*100*D),2);
if(Lot<MarketInfo(Symbol(),MODE_MINLOT)) {Lot=MarketInfo(Symbol(),MODE_MINLOT);} 
if(Lot>=MarketInfo(Symbol(),MODE_MAXLOT)) {Lot=MarketInfo(Symbol(),MODE_MAXLOT);}
//======= Точка входа
bool GoBuy =false;
bool GoSell =false;

bool buy =false;
bool sell =false;

if(iOpen(Symbol(),0,0)>iClose(Symbol(),0,0) && AverageBar(1000)*PipsStep<(iOpen(Symbol(),0,0)-iClose(Symbol(),0,0))/Point)
{
sell=true;
}

if(iOpen(Symbol(),0,0)<iClose(Symbol(),0,0) && AverageBar(1000)*PipsStep<(iClose(Symbol(),0,0)-iOpen(Symbol(),0,0))/Point)
{
buy=true; 
}
  
if(TimeHour(TimeCurrent())>=TimeStart && TimeHour(TimeCurrent())<TimeEnd)
{    
if(buy) {GoBuy=true;}
if(sell) {GoSell=true;}    
} 
//======= Вычисляем спред
spread=(Ask-Bid)/Point;
//======= Находим стоп лосс
//--- Стоп в процентах
double LossProc=(AccountBalance()/100)*StopLossProcent*(-1);
if(ProfitAll(-1)<LossProc && LossProc!=0)
{
ClosePos(Magic);
ObjectsDeleteAll(0,OBJ_ARROW);
ObjectsDeleteAll(0,OBJ_TREND);
}
//======= Открываем ордера
if(Count(OP_BUY)==0 && CountHistBar(-1)==0 && CountBar(-1)==0 && GoSell && AccountFreeMarginCheck(Symbol(),OP_SELL,Lot)>0)
{o=OrderSend(Symbol(),OP_SELL,Lot,Bid,5,0,0,Commemt,Magic,0,Red);}

if(Count(OP_SELL)==0 && CountHistBar(-1)==0 && CountBar(-1)==0 && GoBuy && AccountFreeMarginCheck(Symbol(),OP_BUY,Lot)>0)
{o=OrderSend(Symbol(),OP_BUY,Lot,Ask,5,0,0,Commemt,Magic,0,Blue);}

//======= Трал
if(Tral>0)
{
for(int i=0;i<OrdersTotal();i++)
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
{
if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
{
if(OrderType()==OP_BUY)
{
Slb=OrderStopLoss();
if(Bid-OrderOpenPrice()>=TralStart*Point*D)
{
if(Slb<Bid-Tral*Point*D || Slb==0)
{
OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Tral*Point*D,OrderTakeProfit(),0,Blue);
}
}
}
if(OrderType()==OP_SELL)
{
Sls=OrderStopLoss();
if(OrderOpenPrice()-Ask>=TralStart*Point*D)
{
if(Sls>Ask+Tral*Point*D || Sls==0)
{
OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Tral*Point*D,OrderTakeProfit(),0,Red);
}
}
}
}
}
}
}

//======= Информация
if(Info)
{
InfoPanel();
}
}
//+------------------------------------------------------------------+
//|===================== Функции ====================================|
//+------------------------------------------------------------------+
//--- Подсчет ордеров
int Count(int type)
{
int count=0;
for(int i=0;i<OrdersTotal();i++)
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
{
if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()==type)
{
count++;
}
}
}
return(count);
}
//--- Подсчет баров
int CountBar(int type)
{
int count=0;
for(int i=0;i<OrdersTotal();i++)
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
{
if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()==type && OrderOpenTime()>=NewBar)
{
count++;
}
}
}
return(count);
}
//--- Подсчет исторических баров
int CountHistBar(int type)
{
int count=0;
for(int i=0;i<OrdersHistoryTotal();i++)
{
if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
{
if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()==type && OrderOpenTime()>=NewBar)
{
count++;
}
}
}
return(count);
}
//--- Прибыль всех ордеров
double ProfitAll(int type)
{
double profit=0;
for(int i=0;i<OrdersTotal();i++)
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
{
if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
{
if(type==-1 || OrderType()==type)
{
profit+=OrderProfit()+OrderSwap()+OrderCommission();
}
}
}
}
return(profit);
}
//--- Закрытие позиций
void ClosePos(int magic)
{
for(int i=OrdersTotal()-1;i>=0;i--)
{
if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
{
if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
{
if(OrderType()==OP_BUY)
{
OrderClose(OrderTicket(),OrderLots(),Bid,5,Blue);
}
if(OrderType()==OP_SELL)
{
OrderClose(OrderTicket(),OrderLots(),Ask,5,Red);
}
}
}
}
}
//--- Средний размер бара
double AverageBar(int bars)
{
double sum=0;
for(int i=1;i<=bars;i++)
{
sum+=MathAbs(iOpen(Symbol(),0,i)-iClose(Symbol(),0,i));
}
return(sum/bars/Point);
}
//--- Информационная панель
void InfoPanel()
{
string text="";
int x=10, y=20;
int width=200, height=150;

// Фон панели
ObjectCreate(0,"InfoBackground",OBJ_RECTANGLE_LABEL,0,0,0);
ObjectSetInteger(0,"InfoBackground",OBJPROP_XDISTANCE,x-5);
ObjectSetInteger(0,"InfoBackground",OBJPROP_YDISTANCE,y-5);
ObjectSetInteger(0,"InfoBackground",OBJPROP_XSIZE,width);
ObjectSetInteger(0,"InfoBackground",OBJPROP_YSIZE,height);
ObjectSetInteger(0,"InfoBackground",OBJPROP_BGCOLOR,FonColor);
ObjectSetInteger(0,"InfoBackground",OBJPROP_BORDER_TYPE,BORDER_FLAT);
ObjectSetInteger(0,"InfoBackground",OBJPROP_CORNER,CORNER_LEFT_UPPER);
ObjectSetInteger(0,"InfoBackground",OBJPROP_COLOR,clrWhite);
ObjectSetInteger(0,"InfoBackground",OBJPROP_STYLE,STYLE_SOLID);
ObjectSetInteger(0,"InfoBackground",OBJPROP_WIDTH,1);
ObjectSetInteger(0,"InfoBackground",OBJPROP_BACK,false);
ObjectSetInteger(0,"InfoBackground",OBJPROP_SELECTABLE,false);
ObjectSetInteger(0,"InfoBackground",OBJPROP_SELECTED,false);
ObjectSetInteger(0,"InfoBackground",OBJPROP_HIDDEN,true);

// Заголовок
text="Iron Scalper EA";
CreateLabel("InfoTitle",text,x,y,TextColor,FontSizeInfo+2);
y+=20;

// Информация о счете
text="Balance: "+DoubleToStr(AccountBalance(),2)+" "+AccountCurrency();
CreateLabel("InfoBalance",text,x,y,InfoDataColor,FontSizeInfo);
y+=15;

text="Equity: "+DoubleToStr(AccountEquity(),2)+" "+AccountCurrency();
CreateLabel("InfoEquity",text,x,y,InfoDataColor,FontSizeInfo);
y+=15;

text="Free Margin: "+DoubleToStr(AccountFreeMargin(),2)+" "+AccountCurrency();
CreateLabel("InfoFreeMargin",text,x,y,InfoDataColor,FontSizeInfo);
y+=15;

// Информация о торговле
text="Spread: "+DoubleToStr(spread,1)+" pips";
CreateLabel("InfoSpread",text,x,y,InfoDataColor,FontSizeInfo);
y+=15;

text="Lot Size: "+DoubleToStr(Lot,2);
CreateLabel("InfoLot",text,x,y,InfoDataColor,FontSizeInfo);
y+=15;

text="Buy Orders: "+IntegerToString(Count(OP_BUY));
CreateLabel("InfoBuyOrders",text,x,y,InfoDataColor,FontSizeInfo);
y+=15;

text="Sell Orders: "+IntegerToString(Count(OP_SELL));
CreateLabel("InfoSellOrders",text,x,y,InfoDataColor,FontSizeInfo);
y+=15;

text="Total Profit: "+DoubleToStr(ProfitAll(-1),2)+" "+AccountCurrency();
CreateLabel("InfoProfit",text,x,y,InfoDataColor,FontSizeInfo);
}

//--- Создание текстовой метки
void CreateLabel(string name, string text, int x, int y, color clr, int size)
{
ObjectCreate(0,name,OBJ_LABEL,0,0,0);
ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
ObjectSetString(0,name,OBJPROP_TEXT,text);
ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
ObjectSetInteger(0,name,OBJPROP_FONTSIZE,size);
ObjectSetString(0,name,OBJPROP_FONT,"Arial");
ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
ObjectSetInteger(0,name,OBJPROP_BACK,false);
ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}
//+------------------------------------------------------------------+