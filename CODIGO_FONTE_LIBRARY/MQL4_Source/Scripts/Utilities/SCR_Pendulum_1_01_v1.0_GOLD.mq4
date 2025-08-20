//+------------------------------------------------------------------+
//|                                                Pendulum 1_01.mq4 |
//|                                              Copyright © BFE2006 |
//|                                         http://BFE2006@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © BFE2006"
#property link      "http://BFE2006@yandex.ru"

//+------------------------------------------------------------------+
//|                       Параметры работы                           |
//| - Выставляет два стартовых отложенных ордера на покупку и продажу|
//|   (размер лот расчитывается автоматически исходя из размеров     |
//|   депозита и максимального увелечения "плеча"от 0.01 до 0.07лота)|
//|   с учетом размера 2-х предидущих дневных баров (расстояние от   |
//|   текущей цены, величина тралла и пипсовки)                      |
//|                                                                  |
//| - Траллит отложенные ордера вслед за ценой до срабатываия        |
//|   одного из них                                                  |
//|                                                                  |
//| - Пипсует сработавший ордер, изменив противоположный ордер на    |
//|   уровень "плеча". Отлючает тралл, таким образом обазначив       |
//|   границы торговли                                               |
//|                                                                  |
//| - При развороте цены и открытии ордера с "плечом", в             |
//|   противоположную сторону ставит отложенный ордер с большим      |
//|   плечом в обратную сторону по цене первого открытого ордера и   |
//|   т.д.. (максимальный лот увеличивается на 2*128).               |
//|   Создавая маятник. Пипсовка отключается.                        |
//|                                                                  |
//| - Контролирует общую прибыль и убыток (автоматически             |
//|   расчитывается процент прибыли от 2% до 0.2%). При наличии      |
//|   прибыли закрывает все ордера.                                  |
//+------------------------------------------------------------------+

// ============== Параметры, настраиваимые пользователем =============
// ---------------- Параметры, общие для всех ордеров ----------------
extern string   t110="------ У открытых вручную MAGIC = 0 ------";
extern int      MAGIC=0;          //У ордеров открытых вручную MAGIC=0. 
double   Lot;                     //Лот для установки ордера.
double   ruka;                    //Рука изменнения лота при отрицательном развитии событий.
bool     Auto=true;               //Если вкл., автоматически рассчитывается размер лота, руки и 
                                  //глобальных стопов.
bool     Ustan_BuyStop=true;      //Можно ли ставиь Бай-Cтоп если в рынке такого у нас нет.
bool     Ustan_SellStop=true;     //Можно ли ставиь Cелл-Cстоп если в рынке такого у нас нет.
int      st_Step;                 //Расстояние в пунктах от уровня текущей цены
                                  //до уорвня установки стопового ордера.
int      st_TrStop;               //Трейлинг-Стоп стоповых ордеров. 
                                  //Если = 0 то тарла нет и st_TrStep не важен.
int      st_TrStep;               //Шаг трала стоповых ордеров.
int      PipsProfit;              //Профит при пипсовке можно ставить 1, 2, 3, ...
int      Proskalz;                //Проскальзывание в пунктах (нужно только когда PipsProfit>0).
double   pipsruka;                //Пипсовка для ордеров с рукой.
bool     UseGlobalLevels=true;    //Вкл./Выкл. отслежиания глобальных уровней прибыли/убытка
                                  //если UseGlobalLevels=false, то значенит 
                                  //Global_TakeProfit и Global_StopLoss не важно.
double   Global_TakeProfit;       //Глобальный Тейк-Профит (задаётся в процентах).
double   Global_StopLoss;         //Глобальный Стоп-Лосс (задаётся в процентах).
// ---------- Прочие переменные --------------------------------------- 
 
double lot,sts,PNT,NewPrice,Price,Balans,Free,pips,glp,klv,prb,sred_profit;
double s_buy,s_sell,s_buystop,s_sellstop,s_buy_lot,s_buystop_lot,s_sell_lot,s_sellstop_lot;   //открытые и отложенные ордера
string SMB,com1,com2,com3,com4,com5;
int    MinLevel;
bool   fm,b,s;
double prc2,prc1,prc08,prc06,prc04,prc02,l1,l2,raznost,t_raznost,L,H,sr;
double min_lot,lot_ruka,MRG,T,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,balanc1,balanc2,balanc3,balanc4,balanc5,balanc6,balanc7,balanc8,balanc9,balanc10;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//------------ Проверяем вкл. советника ------------------------------
  if(!IsExpertEnabled())//если ложь 
   {Alert("Ошибка! Не нажата кнопка *Советники*");}
   else 
   {Comment("Как только цена изменится, Советник начнёт работу.");}
   
//------------- Запоминаем начальные значения ------------------------ 
  SMB=Symbol();                           //Символ валютной пары
  PNT=MarketInfo(SMB,MODE_POINT);         //Размер пункта в валюте котировки. 
                                          //Для текущего инструмента хранится в предопределенной
                                          //переменной Point.
  MinLevel=MarketInfo(SMB,MODE_STOPLEVEL);//Минимально допустимый уровень
                                          //стоп-лосса/тейк-профита в пунктах
 
//--------------------------------------------------------------------
    return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {

  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   ObjectCreate("label_object1", OBJ_LABEL, 0, 0, 0); 
   ObjectSet("label_object1", OBJPROP_XDISTANCE, 600);  
   ObjectSet("label_object1", OBJPROP_YDISTANCE, 17);
   ObjectSetText("label_object1", "Pendulum™  version 1_01",9, "Verdana", Red);
   
   ObjectCreate("label_object2", OBJ_LABEL, 0, 0, 0); 
   ObjectSet("label_object2", OBJPROP_XDISTANCE, 600);  
   ObjectSet("label_object2", OBJPROP_YDISTANCE, 47);
   ObjectSetText("label_object2", StringConcatenate("0.01 Лота:  ",(NormalizeDouble((balanc1),2))," ",AccountCurrency()),8, "Verdana", Orange);
   
   ObjectCreate("label_object3", OBJ_LABEL, 0, 0, 0); 
   ObjectSet("label_object3", OBJPROP_XDISTANCE, 600);  
   ObjectSet("label_object3", OBJPROP_YDISTANCE, 57);
   ObjectSetText("label_object3", StringConcatenate("0.02 Лота:  ",(NormalizeDouble((balanc1*3),2))," ",AccountCurrency()),8, "Verdana", Orange);
   
   ObjectCreate("label_object4", OBJ_LABEL, 0, 0, 0); 
   ObjectSet("label_object4", OBJPROP_XDISTANCE, 600);  
   ObjectSet("label_object4", OBJPROP_YDISTANCE, 67);
   ObjectSetText("label_object4", StringConcatenate("0.03 Лота:  ",(NormalizeDouble((balanc1*6),2))," ",AccountCurrency()),8, "Verdana", Orange);
   
   ObjectCreate("label_object5", OBJ_LABEL, 0, 0, 0); 
   ObjectSet("label_object5", OBJPROP_XDISTANCE, 600);  
   ObjectSet("label_object5", OBJPROP_YDISTANCE, 77);
   ObjectSetText("label_object5", StringConcatenate("0.04 Лота:  ",(NormalizeDouble((balanc1*9),2))," ",AccountCurrency()),8, "Verdana", Orange);
   
   ObjectCreate("label_object6", OBJ_LABEL, 0, 0, 0); 
   ObjectSet("label_object6", OBJPROP_XDISTANCE, 600);  
   ObjectSet("label_object6", OBJPROP_YDISTANCE, 87);
   ObjectSetText("label_object6", StringConcatenate("0.05 Лота:  ",(NormalizeDouble((balanc1*12),2))," ",AccountCurrency()),8, "Verdana", Orange);
   
   ObjectCreate("label_object7", OBJ_LABEL, 0, 0, 0); 
   ObjectSet("label_object7", OBJPROP_XDISTANCE, 600);  
   ObjectSet("label_object7", OBJPROP_YDISTANCE, 97);
   ObjectSetText("label_object7", StringConcatenate("0.06 Лота:  ",(NormalizeDouble((balanc1*15),2))," ",AccountCurrency()),8, "Verdana", Orange);
   
   ObjectCreate("label_object8", OBJ_LABEL, 0, 0, 0); 
   ObjectSet("label_object8", OBJPROP_XDISTANCE, 600);  
   ObjectSet("label_object8", OBJPROP_YDISTANCE, 107);
   ObjectSetText("label_object8", StringConcatenate("0.07 Лота:  ",(NormalizeDouble((balanc1*18),2))," ",AccountCurrency()),8, "Verdana", Orange);
   
   ObjectCreate("label_object11", OBJ_LABEL, 0, 0, 0); 
   ObjectSet("label_object11", OBJPROP_XDISTANCE, 600);  
   ObjectSet("label_object11", OBJPROP_YDISTANCE, 37);
   ObjectSetText("label_object11", StringConcatenate("Размер руки:  ",(ruka)),8, "Verdana", Orange);
   
   
//---- Проверка работы в автоматическом режиме
if (Auto==true){Auto();}
//---- Определяем процент для глобального профита
l1=lot;l2=Lot*ruka;
raznost=l2-l1;//находим разность между стартовым лотом и лотом с рукой
t_raznost=MarketInfo(SMB,MODE_TICKVALUE)*raznost;
prc2=(AccountBalance()/100)*2;     //2%
prc1=(AccountBalance()/100)*1;     //1%
prc08=(AccountBalance()/100)*0.8;  //0.8%
prc06=(AccountBalance()/100)*0.6;  //0.6%
prc04=(AccountBalance()/100)*0.4;  //0.4%
prc02=(AccountBalance()/100)*0.2;  //0.2%
if(t_raznost*10>=prc2)                            {Global_TakeProfit=2;}
if(t_raznost*10>=prc1 && t_raznost*10<prc2)       {Global_TakeProfit=1;}
if(t_raznost*10>=prc08 && t_raznost*10<prc1)      {Global_TakeProfit=0.8;}
if(t_raznost*10>=prc06 && t_raznost*10<prc08)     {Global_TakeProfit=0.6;}
if(t_raznost*10>=prc04 && t_raznost*10<prc06)     {Global_TakeProfit=0.4;}
if(t_raznost*10>=prc02 && t_raznost*10<prc04)     {Global_TakeProfit=0.2;}
if(t_raznost*10<=prc02)                           {Global_TakeProfit=0.2;}

for(int i=1;i<=2;i++)
  {
  L=L+iLow(Symbol(),PERIOD_D1,1);
  H=H+iHigh(Symbol(),PERIOD_D1,1);
  }
//----
sr=((H-L)/i)*10000;
sr=(NormalizeDouble((sr),0));
PipsProfit=sr/10;
PipsProfit=(NormalizeDouble((PipsProfit),0)); if(PipsProfit<1){PipsProfit=1;}
st_Step=(sr-PipsProfit-Proskalz);           if(st_Step<15){return(0);}
st_TrStop=(sr-PipsProfit-Proskalz);         if(st_TrStop<15){return(0);}
L=0;H=0;

//---- Запоминаем начальные значения:
  lot=Lot;           //Лота
  sts=st_TrStop;     //Тралла стоповых ордеров
  Balans=AccountBalance();
  Free=AccountEquity();
  pips=PipsProfit;
  glp=Balans+(Balans/100*Global_TakeProfit);
  glp=(NormalizeDouble((glp),2));
  
  if(OrdersHistoryTotal()>0){chet();}
//--------------------------------------------------------------------
//----------------- Считаем открытые и отложенные ордера -------------
for (int q=OrdersTotal(); q>=0; q--)
  {
  if (OrderSelect(q,SELECT_BY_POS,MODE_TRADES)==true)
    {
    if(OrderSymbol()!=SMB || OrderMagicNumber()!=MAGIC)continue;
      {          
      if(OrderType()==OP_BUY)      {s_buy++; s_buy_lot=s_buy_lot+OrderLots();}
      if(OrderType()==OP_BUYSTOP)  {s_buystop++; s_buystop_lot=s_buystop_lot+OrderLots();}
      if(OrderType()==OP_SELL)     {s_sell++; s_sell_lot=s_sell_lot+OrderLots();}
      if(OrderType()==OP_SELLSTOP) {s_sellstop++;s_sellstop_lot=s_sellstop_lot+OrderLots();}
      }
    }
  }
 
//------- Проверяем необходимость выставления стартовых ордеров ------
if (s_buy+s_sell==0) {ustorder();}

//------- Проверяем необходимость тралла стартовых ордеров -----------
if (s_buy+s_sell>0){st_TrStop=0;com1="Тралл стоповых ордеров  - выкл. (";} //Если есть открытый ордер выкл. тралл стоповых
if(st_TrStop>0){tr_stop();com1="Тралл стоповых ордеров  - вкл. (";}//Переходим к траллу

//------------ Проверяем необходимость увелечения плеча --------------
//- 1
if (s_buy+s_sell==1){plecho1();}
//- 2
if (s_buy+s_sell==2){plecho2();}
//- 3
if (s_buy+s_sell==3){plecho3();}
//- 4
if (s_buy+s_sell==4){plecho4();}
//- 5
if (s_buy+s_sell==5){plecho5();}
//- 6
if (s_buy+s_sell==6){plecho6();}
//- 7
if (s_buy+s_sell==7){plecho7();}
//- 8
if (s_buy+s_sell==8){plecho8();}
//- 9
//if (s_buy+s_sell==9){plecho9();}
//- 10
//if (s_buy+s_sell==10){plecho10();}

//--- Если есть необходимость, кол-во колебаний маятника можно увеличить

//--------------- Проверяем вкл/выкл пипсовки ------------------------
if (s_buy+s_sell>1 && UseGlobalLevels==true){PipsProfit=0;com2="Пипсовка  - выкл. (";}
if (s_buy+s_sell>1 && UseGlobalLevels==false){pips();com2="Пипсовка  - вкл. (";}
if (s_buy+s_sell==1){pips();com2="Пипсовка  - вкл. (";}
if (s_buy+s_sell==0){com2="Пипсовка  - вкл. (";}
if (PipsProfit==0 || PipsProfit>4)com3=" пунктов";
if (PipsProfit==1)com3=" пункт";
if (PipsProfit>2 && PipsProfit<5)com3=" пунктa";

//--------------- Проверяем глобальные уровни ------------------------
if (s_buy+s_sell>1 && s_buy+s_sell<11   && UseGlobalLevels==true && (Free-Balans)>=(Balans/100*Global_TakeProfit)){glob_profit();}
if (s_buy+s_sell==11){glob_stop();}

//----------------- Выводим информацию -------------------------------
if(Lot>0)
{  
Comment("Открытых ордеров для ",SMB,":","\n",
        "buy  - ",s_buy," (",s_buy_lot,")","   sell  - ",s_sell," (",s_sell_lot,")","\n",
        "buystop  - ",s_buystop," (",s_buystop_lot,")","  sellstop  - ",s_sellstop," (",s_sellstop_lot,")","\n",
        com1,st_TrStop,")","\n",com2,PipsProfit,com3,")","\n",
        "--- Глобальный профит ---","\n",glp," ",AccountCurrency()," (",Global_TakeProfit," %)","\n",
        "Кол-во сделок - ",klv,"\n","Прибыль - ",prb," ",AccountCurrency(),"\n",
        "Средняя прибыль - ",sred_profit," ",AccountCurrency());
}
if(Lot==0)
{
balanc1=(NormalizeDouble((balanc1),2));
Comment(com4,"\n",com5,"\n","Минимум - ",balanc1," ",AccountCurrency());
}
        
//----------------- Обнуляем счетчики --------------------------------

s_buy=0;s_buystop=0;s_sell=0;s_sellstop=0;s_buy_lot=0;s_buystop_lot=0;s_sell_lot=0;s_sellstop_lot=0;
st_TrStop=sts;Lot=lot;PipsProfit=pips;sred_profit=0;
sred_profit=prb/klv;
sred_profit=(NormalizeDouble((sred_profit),2));
klv=0;prb=0;       
   return(0);
   
  }
//====================================================================
//----------------- Ставим стартовые отложенные ордера ---------------
void ustorder()
{
  if(s_sellstop==0 && st_Step>=MinLevel)
   {
   NewPrice=Bid-st_Step*Point;
   fm=OrderSend(SMB,OP_SELLSTOP,Lot,NewPrice,3,0,0,NULL,MAGIC,0,CLR_NONE);
   }
  if(s_buystop==0 && st_Step>=MinLevel)
   {
   NewPrice=Ask+st_Step*Point;
   fm=OrderSend(SMB,OP_BUYSTOP,Lot,NewPrice,3,0,0,NULL,MAGIC,0,CLR_NONE);
   }
}
//----------------- Траллим стоповый ордер ---------------------------
void tr_stop()
{
  for(int w=OrdersTotal();w>=0;w--)
    {
    if (OrderSelect(w,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if(OrderType()==OP_BUYSTOP && OrderOpenPrice()>Ask+(st_TrStop+st_TrStep)*Point)
        {NewPrice=Ask+st_TrStop*Point;fm=OrderModify(OrderTicket(),NewPrice,0,0,0,CLR_NONE);}
      if(OrderType()==OP_SELLSTOP && OrderOpenPrice()<Bid-(st_TrStop+st_TrStep)*Point)
        {NewPrice=Bid-st_TrStop*Point;fm=OrderModify(OrderTicket(),NewPrice,0,0,0,CLR_NONE);}
      }
    }
}
//---------------------------- Пипсуем -------------------------------
void pips()
{
for(int e=OrdersTotal();e>=0;e--)
  {
  if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
    {
    if(OrderType()==OP_BUY && OrderOpenPrice()<Bid-(PipsProfit+Proskalz)*Point)
      {OrderClose(OrderTicket(),OrderLots(),Bid,3);zachistka();}
    if(OrderType()==OP_SELL && OrderOpenPrice()>Ask+(PipsProfit+Proskalz)*Point)
      {OrderClose(OrderTicket(),OrderLots(),Bid,3);zachistka();}
    }
  }
}
//------------------------ Убираем лишьние ордера --------------------
void zachistka()
{
for(int e=OrdersTotal();e>=0;e--)
  {
  if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
    {
    if (OrderLots()>lot){OrderDelete(OrderTicket());}
    }
  }
}
//------------------ Работа с глобальными уровнями -------------------
//====================================================================
void glob_profit()
  {
  for (int i=OrdersTotal();i>=0; i--)
    {
    if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if(OrderType()==OP_BUY){OrderClose(OrderTicket(),OrderLots(),Bid,3);}
      if(OrderType()==OP_SELL){OrderClose(OrderTicket(),OrderLots(),Ask,3);}
      }
    }
    zachistka();
  }
//====================================================================
void glob_stop()
  {
  for (int i=OrdersTotal();i>=0; i--)
    {
    if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
     {
      if(OrderType()==OP_BUY) {OrderClose(OrderTicket(),OrderLots(),Bid,3);}
      if(OrderType()==OP_SELL){OrderClose(OrderTicket(),OrderLots(),Ask,3);}
     }
      
    }
    zachistka();
  }

//-------------------------- Плечо х1 --------------------------------
void plecho1()
{//Определяем в какую сторону увеличивать
  for (int e=OrdersTotal();e>=0;e--)
    {
    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if (OrderType()==OP_BUYSTOP && OrderLots()<lot*ruka)//Определяем направление и цену плеча
        {Price=OrderOpenPrice();OrderDelete(OrderTicket());Lot=lot*ruka;
        fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      }
      if (OrderType()==OP_SELLSTOP && OrderLots()<lot*ruka)//Определяем направление и цену плеча
        {Price=OrderOpenPrice();OrderDelete(OrderTicket());Lot=lot*ruka;
        fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
    }
}
//-------------------------- Плечо х2 --------------------------------
void plecho2()
{
    for (int e=OrdersTotal();e>=0;e--)
    {
    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if(OrderLots()==lot*ruka*2 && OrderType()==OP_BUYSTOP){return(0);}
      if(OrderLots()==lot*ruka*2 && OrderType()==OP_SELLSTOP){return(0);}
      if(OrderLots()==lot && OrderType()==OP_BUY){Price=OrderOpenPrice();Lot=lot*ruka*2;
      fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      if(OrderLots()==lot && OrderType()==OP_SELL){Price=OrderOpenPrice();Lot=lot*ruka*2;
      fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      }
    }
}
//-------------------------- Плечо х3 --------------------------------
void plecho3()
{
    for (int e=OrdersTotal();e>=0;e--)
    {
    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if(OrderLots()==lot*ruka*4 && OrderType()==OP_BUYSTOP){return(0);}
      if(OrderLots()==lot*ruka*4 && OrderType()==OP_SELLSTOP){return(0);}
      if(OrderLots()==lot*ruka && OrderType()==OP_BUY){Price=OrderOpenPrice();Lot=lot*ruka*4;
      fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      if(OrderLots()==lot*ruka && OrderType()==OP_SELL){Price=OrderOpenPrice();Lot=lot*ruka*4;
      fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      }
    }
}
//-------------------------- Плечо х4 --------------------------------
void plecho4()
{
    for (int e=OrdersTotal();e>=0;e--)
    {
    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if(OrderLots()==lot*ruka*8 && OrderType()==OP_BUYSTOP){return(0);}
      if(OrderLots()==lot*ruka*8 && OrderType()==OP_SELLSTOP){return(0);}
      if(OrderLots()==lot*ruka*2 && OrderType()==OP_BUY){Price=OrderOpenPrice();Lot=lot*ruka*8;
      fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      if(OrderLots()==lot*ruka*2 && OrderType()==OP_SELL){Price=OrderOpenPrice();Lot=lot*ruka*8;
      fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      }
    }
}
//-------------------------- Плечо х5 --------------------------------
void plecho5()
{
    for (int e=OrdersTotal();e>=0;e--)
    {
    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if(OrderLots()==lot*ruka*16 && OrderType()==OP_BUYSTOP){return(0);}
      if(OrderLots()==lot*ruka*16 && OrderType()==OP_SELLSTOP){return(0);}
      if(OrderLots()==lot*ruka*4 && OrderType()==OP_BUY){Price=OrderOpenPrice();Lot=lot*ruka*16;
      fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      if(OrderLots()==lot*ruka*4 && OrderType()==OP_SELL){Price=OrderOpenPrice();Lot=lot*ruka*16;
      fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      }
    }
}
//-------------------------- Плечо х6 --------------------------------
void plecho6()
{
    for (int e=OrdersTotal();e>=0;e--)
    {
    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if(OrderLots()==lot*ruka*32 && OrderType()==OP_BUYSTOP){return(0);}
      if(OrderLots()==lot*ruka*32 && OrderType()==OP_SELLSTOP){return(0);}
      if(OrderLots()==lot*ruka*8 && OrderType()==OP_BUY){Price=OrderOpenPrice();Lot=lot*ruka*32;
      fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      if(OrderLots()==lot*ruka*8 && OrderType()==OP_SELL){Price=OrderOpenPrice();Lot=lot*ruka*32;
      fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      }
    }
}
//-------------------------- Плечо х7 --------------------------------
void plecho7()
{
    for (int e=OrdersTotal();e>=0;e--)
    {
    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if(OrderLots()==lot*ruka*64 && OrderType()==OP_BUYSTOP){return(0);}
      if(OrderLots()==lot*ruka*64 && OrderType()==OP_SELLSTOP){return(0);}
      if(OrderLots()==lot*ruka*16 && OrderType()==OP_BUY){Price=OrderOpenPrice();Lot=lot*ruka*64;
      fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      if(OrderLots()==lot*ruka*16 && OrderType()==OP_SELL){Price=OrderOpenPrice();Lot=lot*ruka*64;
      fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      }
    }
}
//-------------------------- Плечо х8 --------------------------------
void plecho8()
{
    for (int e=OrdersTotal();e>=0;e--)
    {
    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
      {
      if(OrderLots()==lot*ruka*128 && OrderType()==OP_BUYSTOP){return(0);}
      if(OrderLots()==lot*ruka*128 && OrderType()==OP_SELLSTOP){return(0);}
      if(OrderLots()==lot*ruka*32 && OrderType()==OP_BUY){Price=OrderOpenPrice();Lot=lot*ruka*128;
      fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      if(OrderLots()==lot*ruka*32 && OrderType()==OP_SELL){Price=OrderOpenPrice();Lot=lot*ruka*128;
      fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
      }
    }
}
//-------------------------- Плечо х9 --------------------------------
//void plecho9()
//{
//    for (int e=OrdersTotal();e>=0;e--)
//    {
//    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
//      {
//      if(OrderLots()==lot*ruka*512 && OrderType()==OP_BUYSTOP){return(0);}
//      if(OrderLots()==lot*ruka*512 && OrderType()==OP_SELLSTOP){return(0);}
//      if(OrderLots()==lot*ruka*64 && OrderType()==OP_BUY){Price=OrderOpenPrice();Lot=lot*ruka*512;
//      fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
//      if(OrderLots()==lot*ruka*64 && OrderType()==OP_SELL){Price=OrderOpenPrice();Lot=lot*ruka*512;
//      fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
//      }
//    }
//}
//-------------------------- Плечо х10 -------------------------------
//void plecho10()
//{
//    for (int e=OrdersTotal();e>=0;e--)
//    {
//    if (OrderSelect(e,SELECT_BY_POS,MODE_TRADES)==true)
//      {
//      if(OrderLots()==lot*ruka*1024 && OrderType()==OP_BUYSTOP){return(0);}
//      if(OrderLots()==lot*ruka*1024 && OrderType()==OP_SELLSTOP){return(0);}
//      if(OrderLots()==lot*ruka*128 && OrderType()==OP_BUY){Price=OrderOpenPrice();Lot=lot*ruka*1024;
//      fm=OrderSend(SMB,OP_BUYSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
//      if(OrderLots()==lot*ruka*128 && OrderType()==OP_SELL){Price=OrderOpenPrice();Lot=lot*ruka*1024;
//      fm=OrderSend(SMB,OP_SELLSTOP,Lot,Price,3,0,0,NULL,MAGIC,0,CLR_NONE);}
//      }
//    }
//}
//-------------------------- Счетчик ---------------------------------
void chet()
{
for (int r=0; r<=OrdersHistoryTotal(); r++)
   {
   if(OrderSelect(r,SELECT_BY_POS,MODE_HISTORY)==true) 
    if(OrderClosePrice()>0)
     prb=prb+OrderProfit()+OrderSwap();
    if(OrderClosePrice()>0 && (OrderProfit()+OrderSwap())>0)klv=klv+1;
    if(OrderClosePrice()>0 && (OrderProfit()+OrderSwap())<0)klv=klv+1;
   } 
prb=(NormalizeDouble((prb),2));
}
//------------------- Расчет лота и руки -----------------------------
//--------------------------------------------------------------------
void Auto()
{
 min_lot=MarketInfo(SMB,MODE_MINLOT);
 //----- 
 ruka=2;
 lot_ruka=min_lot*ruka*128;
 MRG=MarketInfo(SMB,MODE_MARGINREQUIRED)*lot_ruka;
 t1=MarketInfo(SMB,MODE_TICKVALUE)*min_lot;
 t2=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka;
 t3=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka*2;
 t4=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka*4;
 t5=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka*8;
 t6=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka*16;
 t7=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka*32;
 t8=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka*64;
 t9=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka*128;
// t10=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka*512;
// t11=MarketInfo(SMB,MODE_TICKVALUE)*min_lot*ruka*1024;
 T=t1-t2+t3-t4+t5-t6+t7-t8+t9-t10+t11;
 balanc1=(MRG+T*70)/3;
 if(AccountBalance()<balanc1){com4="ТОРГОВАТЬ НЕ РЕКОМЕНДУЕТСЯ";com5="(мало денег на депозите для безопасной торговли)";Lot=0;}
 if(AccountBalance()>balanc1)    {Lot=min_lot;}
 if(AccountBalance()>balanc1*3)  {Lot=min_lot*2;}
 if(AccountBalance()>balanc1*6)  {Lot=min_lot*3;}
 if(AccountBalance()>balanc1*9)  {Lot=min_lot*4;}
 if(AccountBalance()>balanc1*12) {Lot=min_lot*5;}
 if(AccountBalance()>balanc1*15) {Lot=min_lot*6;}
 if(AccountBalance()>balanc1*18) {Lot=min_lot*7;}
}
//+------------------------------------------------------------------+