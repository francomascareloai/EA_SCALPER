//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
#property copyright "runik"
#property link      "ngb2008@mail.ru"
//
// dec - параметры которые нужно умножать на 10 при работе в ДЦ с 5 знаками (типа альпари)
//

// !!!
// !!! при работе ЕА помните что нужно грузить (держать открытыми в терминале) те графики таймфреймов на которых работает 
// !!! индикатор например 7 - дневной и 3 - 15 минутный (TFSmall=3;TFS = 7;)
// !!! 

// советник можно ставит на любой график от м1 до н1
// для работы нужен индикатор i-Regr

// прежде чем работать с этой модификацией илана попробуйте "обычный" илан версии 1.4 - 1.5 - 1.6

// помните !!! советником нужно управлять с головой ! 
// на полном автомате сольете когда-нибудь ...

// Буду признателен если Вы сообщите об ошибках в работе данного советника или предложения по доработке.
// Вариантов работы очень много, поэтому буду признателен если пришлете приличный сет ngb2008[a]mail.ru
// Если Вы решили модифицировать данный советник, то пожалуйста. Мне близка идея заложенная в лицензии GNU.
// Не закрывайте свободно распространяемый код и не объявляйте его своим.
// Если Вам понравился данный советник и Вы им зарабатываете, 
// то можете сказать спасибо :)  системе вебмани Z182368142593
// указывайте что это за советник (имя файла) и свой эл. адрес (пришлю новую версию, эта надеюсь не последняя будет)
// с ув. руник

extern string с2= "Основные параметры";
// здесь все как в обычном илане, массивы значений нужны для тех кому не хватает функционала и хотел бы использовать разные пипстепы, 
// разные лотэкспоненты, разные тейки на каждом шаге
extern double LotExponent = 1.4;  // умножение лотов в серии по экспоненте для вывода в безубыток. первый лот 0.1, серия: 0.15, 0.26, 0.43 ...
double learr[25]={1.3,1.4,1.5,1.6,1.7,2,2,2,2,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.3,1.6,1.6,1.6,1.6,1.6,1.6,1.6}; // le а каждый шаг если LotExponent=0
extern double TakeProfit = 30;  //dec минимальный тейк профит, если = 0 то используем массив значений тейков при установке колен
int tparr[25]={10,10,10,10,20,30,30,30,30,30,30,30,30,30,30,30,30,10,10,10,10,10,10,10,10,10}; // dec
extern double PipStep = 30;     //dec шаг первого колена
double psarr[25]={70,110,110,110,110,110,110,110,110,110,110,110,90,90,90,90,90,90,170,180,190,200,200,200,200,200}; //dec пипстепы если PipStep=0
                                                                                                
extern string c9 = "MM";
extern double Lots = 0.1;         // теперь можно и микролоты 0.01 при этом если стоит 0.1 то следующий лот в серии будет 0.15
extern double Risk = 0.5;          // первая сделка размером в % от депо, если = 0 то первая сделка открывается размером Lots
// эти параметры нужны в том случае когда хотим на последних лотах не докупаться огромными лотами и у же фиксированными например 0,1 - 0,2 - 0,4 - 0,8 - 1,6 - 1,6 - 1,6 ...
extern double LastTrade=100; // после этого ордера размеры ордеров становяться = последнему открытому а тейк переносится в точку безубытка + lastradeprofit
extern double TakeProfitLast = 10.0;  //dec минимальный тейк профит когда открыто сделок больше чем LastTrade
extern double LasTradeSize=17; // максимальный размер открытой сделки в % от депо, например при депо 10 000 размер последней позиции не больше 1 лота
extern int    MaxTrades = 50;                // максимально количество одновременно открытых ордеров

extern string s11 ="Параметры сделок по тренду";
// эти параметры отвечают за работу советника когда идем докуматься (или пирамидинг) по тренду, общий смысл таков что если  NumTr = 2 то по тренду мы фактически идем удвоенным лотом
// таким образом наиболее выгодныо при реализации данной идеи ставить максимальный первоначальный лот небольшой множитель, минимальный шаг ТрендПС, и максимум NumTr (5-6)
// но если не угадали с выбором направления и начинаем усредняться как в обычном илане, то у нас висит приличный "якорь"
extern double TrendPS = 11;     //dec шаг открытия колен по тренду, если =0 то по тренду не работаем, нельзя делать меньше или равным уровню стопов
extern double ProfitPerc= 5;   //dec если по тренду накоплено прибыли более 10% депозита, то закрываем всю серию с прибылью
extern double MinProfitPips =15; //dec если у нас отрыта серия по тренду и цена пошла против нас, то закрываемся по стоплоссу, который расположен в + на уровне MinProfitPips от точки безубытка
extern double MinProfitPipsOne =2; //dec если у нас отрыта серия по тренду и цена пошла против нас, то закрываемся по стоплоссу, который расположен в + на уровне MinProfitPips от точки безубытка
extern double NumTr=2; // сколько позиций оставлять если цена пошла не в нашу сторону                           
extern int FDir = 2;     // принудительный выбор направления если = 0 то первая сделка всегда и сразу открывается на бай, (=1 селл) не ожидая условия на отркрытие и окончания бара, =2 - то просто немедленно открыться, в зависимости от условий                         

extern string c3= "Вспомогательные параметры";
extern int MagicNumber = 54321;    // магик
extern double slip = 3.0;          //dec проскальзывание
extern double minslip =3;
extern int lotdecimal = 2;         // 2 - микролоты 0.01, 1 - мини лоты 0.1, 0 - нормальные лоты 1.
// бывает нужно ...
extern double PercDown=0; // т.е. если мы "зафиксировали" (т.е. цена уходила далеко не в нашем направлении) просадку на депозите по серии сделок больше 30 % от текущего баланса, то нам надо сматываться с рынка да побыстрее
extern double PercClose=0; // поэтому если мы дошли до 10 % просадки после 30 надо закрываться с таким минусом, дальше соотношение поддерживается, если на 60 % уходили в просадку, то закроемся при 20 %
                           // чтобы не пользоваться данной функцией надо установит эти параметры равными 
extern int ComOn=0; // отключить вывод комментариев при =0                           
extern string c4= "Параметры связанные с временем";
extern int TFIlanX=0;    // таймфрейм на котором илан открывает сделки см. mper при = 5 - H1
// типа период свитчер
extern int nH1=0;       //   =3 после 3 сделки переключаемся на ТФ Н1
extern int nH4=0;       //   =5 после 5 сделки переключаемся на тф Н4

extern string c8= "Параметры лока";
// кому надо и сам поставит лок и разрулит, не очень удачно реализовано, но смысл такой: если открыто уже прилично позиций, то по сигналу индикатора открываем лок, и по сигналу индикатора закрываем лок если в плюсе на 
// MinLP пипсов, затем можем снова закрыться и открыться, таким образом как бы скальпируя (пипсуя) большим лотом, если профит по локу и серии больше 0, то просто все закрываем, попробуйте = 5 или 10, очень показательно
extern double LockS=0; // пытаемся локировать часть позиций и получить дополнительную прибыль, если =0 то не работает, если =0.5, то локируем 50% позиций серии
extern int LMagN=689; // магический номер для локовой позы
extern int NumLockMin=4; // после какого по счету колена открывать локовый ордер если индикатор глобального тренда изменил направление
extern int NumLoc=8; // после какого по счету колена открывать локовый ордер если количество ордеров просто стало большим
//extern int MaxDist=400; //dec максимальное расстояние от первой сделки после которого так же открываем лок
extern int MinLP=10; // минимальное количесвто пунктов профита

extern string _tmp2_ = " --- i-Regr --- с большим периодом опеределяем глобальный тренд";
// по данному индикатору с этими настройками определяем "глобальный тренд" против которого никогда не открываемся (первая сделка)
// вообщем это и определяет сливаемость данного советника, если ошиблись и открылись не туда, то за 2000 пунктов сольемся (если без лока и вошли больше чем 5 % депо, на некотрых тестах и проходит)
// главное чтобы этим индикатором поймать разворот глобального тренда !
// для более гибкой работы можно делать период и таймфрейм меньше, например (параметры попорядку) 3, 1.5, 2, 0, 800, 5, 0
extern int Regr.degree1 = 6; // порядок регрессии 
extern double Regr.kstd1 = 5; // ширина канала, если =0 то рисуется только средняя линия
extern int kanal=2; // вариант работы с границами канал, при =2 не открывааем позиции за границами канала, =1 только за пределами одной границы, = 0 не учитываем границы только измененгие основной линии регресс
int Regr.shift1 = 0; // смещение относительно текущего бара
extern int SPer = 800; // период баров
extern int TFS=7;     // таймфрейм на котором работает индикатор, 
extern int invert=0; // если = 0 то по тренду, если =1 то работаем против глобального тренда, можно использовать с локом
// если лок размером больше суммы открытых позиций в серии, то теоретический при invert=1; мы всегда закроемся в +

extern string _tmp3_ = " --- i-Regr --- с малым периодом";
// по данному индикатору с этими настройками мы докупаемся если цена пошла против нас, этот же индикатор используется при закрытии и открытии локовых позиций
// для более устойчивой работы можно увеличивать период и ТФ, например (параметры попорядку) 1, 3,1.5, 0, 800, 5
extern int IndStep =  3; // шаг с которого начинаем смотреть на индикатор для открытия колен
extern int Regr.degree1mall = 3; // порядок регрессии 
extern double Regr.kstd1mall = 1.5; // ширина канала, если =0 то рисуется только средняя линия
int Regr.shift1mall = 0; // смещение относительно текущего бара
extern int SPermall = 150; // период баров
extern int TFSmall=3;     // таймфрейм на котором работает индикатор


//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
bool UseEquityStop = FALSE;
double TotalEquityRisk = 20.0;

bool UseTimeOut = FALSE;
double MaxTradeOpenHours = 48.0;
extern string t2 = " параметры трейлинга";
// кто пользуется трейлингом, пожалста ...
extern int UseTrailingStop = 0; // 0-не используем трал, 1 - ступенчатый трал, 2 - трал типа есмарт
extern int ProfitTrailDist = 30; //dec расстояние от точки безубытка, после которой включаем трал  //+------------------------------------------------------------------+
extern int TrailDist = 80; //dec расстояние на котором тянется стоплосс                            //| ТРЕЙЛИНГ СТАНДАРТНЫЙ-СТУПЕНЧАСТЫЙ                                |
extern int TrailStep = 10; //dec модифицируем ордера каждые 5 пунктов                              //| Функции передаётся тикет позиции, расстояние от курса открытия,  |
extern int NumIT = 3; // после какого количества сделок включается трал                         //| на котором трейлинг запускается (пунктов) и "шаг", с которым он переносится (пунктов)   |
                                                                                                //| Пример: при +30 стоп на +10, при +40 - стоп на +20 и т.д.        |
extern double xtral=2; // означает что, расстояние от точки безубытка до стоплосса в xtral раз меньше чем от точки бу до цены, например цена ушла на 90 п в +, значит стоп на уровне 30 п в плюс переносим                                                                                              
                                                                                                
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн

int mper[10]={0,1,5,15,30,60,240,1440,10080,43200};
int TFIlan=0;
int ccc=0;
double lota[100]; // лоты
int modea[100];   // тип ордера OP_BUY 0 , OP_SELL 1 , OP_BUYLIMIT 2 , OP_SELLLIMIT 3 , OP_BUYSTOP 4 , OP_SELLSTOP 5 
double opa[100];       // цена открытия
double sla[100];      // стоплосс
double tpa[100];      // профит
string comma[100];     // комментарии
datetime tima[100];    // время открытия сделки 
double profa[100];
int ticka[100]; 
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
double PriceTarget, StartEquity, BuyTarget, SellTarget, AveragePrice, SellLimit, BuyLimit,LastBuyPrice, LastSellPrice, Spread,mac;
bool flag;
string EAName = "Ilan_extr18";
int timeprev = 0, expiration;
int NumOfTrades = 0;
double iLots;
int cnt = 0, total;
double Stopper = 0.0;
bool TradeNow = FALSE, LongTrade = FALSE, ShortTrade = FALSE;
int ticket;
bool NewOrdersPlaced = FALSE;
double AccountEquityHighAmt, PrevEquity;
int TrendRe=1; // при =0 режим обычного илана, при =1 режим тренд, т.е. докупаемся по тренду
double LastDD=0; // здесь запоминамем максимальную просадку для текущей серии сделок
double FirstTr=0; // здесь запоминаем тикет первой сделки в серии
int ClLock=0;

//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
int init() {
   Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   
   return (0);
}

int deinit() {
   return (0);
}
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
int start() {

   total = CountTrades();

   PercCloseDown(); // 
   
    if (TrendPS>0) TrenT();  
   
   
   if (TrendRe==0)
     {
     ProfitMonitor(); // если открыта длинная серия то на всякий случай мониторим закрытие (вообщем страховка если тейкпрофит не выставился)
     }
   int ct=NumT();
   double PrevCl;
   double CurrCl;
      if (UseTrailingStop >0 && ct>=NumIT) TrailingAlls();

   if (UseTimeOut) {
      if (TimeCurrent() >= expiration) {
         CloseThisSymbolAll(MagicNumber);
         PrintF("Closed All due to TimeOut");
      }
   }

     if (LockS>0) {int lm=LockTicket(LMagN); }
     
     if (LockS>0 && lm>0) // локируем серию
     {
     // Проверка на то чтобы закрыть лок если серия закрыта
     if (ct<NumLockMin) { ClLock =1; }
     OrderSelect(lm,SELECT_BY_TICKET,MODE_TRADES);
     if (ClLock==1)
       {        
         if (OrderType()==OP_BUY && OrderProfit()>0 && ((Bid-OrderOpenPrice())/Point>=MinLP)) OrderClose(lm,OrderLots(),Bid,slip,0);
         if (OrderType()==OP_SELL && OrderProfit()>0 && ((OrderOpenPrice()-Ask)/Point>=MinLP)) OrderClose(lm,OrderLots(),Ask,slip,0);
         ClLock=0;
        // return(0);           
       } 
     if (OrderProfit()>0)
       {        
         if (OrderType()==OP_BUY && alerts(-1)==-1 && ((Bid-OrderOpenPrice())/Point>=MinLP)) OrderClose(lm,OrderLots(),Bid,slip,0);
         if (OrderType()==OP_SELL && alerts(1)==1 && ((OrderOpenPrice()-Ask)/Point>=MinLP)) OrderClose(lm,OrderLots(),Ask,slip,0);
          ClLock=0;
       //  return(0);           
       }        
     }
   
   TFIlan=TFIlanX;
   if (nH1!=0 && NumT()>=nH1) TFIlan=5;
   if (nH4!=0 && NumT()>=nH4) TFIlan=6;
   if (FDir<0)
   {
   if (timeprev == iTime(NULL,mper[TFIlan],0)) return (0);   
   }
   if (total>=1 && FDir>=0)
   {
   if (timeprev == iTime(NULL,mper[TFIlan],0)) return (0);   
   }
   timeprev = iTime(NULL,mper[TFIlan],0);

  
    if (LockS>0 && ct>NumLockMin) // локируем серию
     {    
     int ld=Dir(MagicNumber); // определяем направление серии 1(b) или -1(s)

     // проверка есть ли лок ?
     int a=alerts(ld);
     if (lm>0) // 
      { 
      // проверка надо ли закрыть лок сейчас && a<0&& a>0
      if (Balance("buy","Balance",LMagN)+Balance("sell","Balance",MagicNumber)>0) {CloseThisSymbolAll(LMagN);CloseThisSymbolAll(MagicNumber);}
      if (Balance("buy","Balance",MagicNumber)+Balance("sell","Balance",LMagN)>0) {CloseThisSymbolAll(MagicNumber);CloseThisSymbolAll(LMagN);}
      
      }
      else // открываем лок
      {
      double al=CountLots(MagicNumber);          
   
   //  Print ("   ct   ",ct,"  ld   ",ld,"  al  ",al,"   a   ",a ); 
      if ((ld==1 && a==-1) || (ct>=NumLoc && ld==1 ))  //&&      
      {
      ClLock =0; 
      int gi_328 = OpenPendingOrder(1, LotSiz(LockS*al), Bid, slip, Ask, 0, 0, EAName + "-Lock" , LMagN, 0, Red);
                  if (gi_328 < 0) { Print("Error: ", GetLastError());again();return (0);      }
       }
      if ((ld==-1 && a==1) || (ld==-1 && ct>=NumLoc))//&& a>0
      {
      ClLock =0; 
      gi_328 = OpenPendingOrder(0, LotSiz(LockS*al), Ask, slip, Bid, 0, 0, EAName + "-Lock", LMagN, 0, Blue);
            if (gi_328 < 0) { Print("Error: ", GetLastError());again();return (0);}
      }
      
      }
     
     }
  
   double CurrentPairProfit = CalculateProfit();
   if (UseEquityStop) {
      if (CurrentPairProfit < 0.0 && MathAbs(CurrentPairProfit) > TotalEquityRisk / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll(MagicNumber);
         PrintF("Closed All due to Stop Out");
         NewOrdersPlaced = FALSE;
      }
   }

   if (total == 0) flag = FALSE;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY) {
            LongTrade = TRUE;
            ShortTrade = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_SELL) {
            LongTrade = FALSE;
            ShortTrade = TRUE;
            break;
         }
      }
   }
   
//   if (LockOn==1 && total>0) LockPositions();
   
   if (total > 0 && total <= MaxTrades) {
      RefreshRates();
      LastBuyPrice = FindMinBuyPrice();
      LastSellPrice = FindMaxSellPrice();
      if (LongTrade && LastBuyPrice - Ask >= PipStepX(0) * Point && alerts(1)>0 ) TradeNow = TRUE;
      if (ShortTrade && Bid - LastSellPrice >= PipStepX(1) * Point && alerts(-1)<0) TradeNow = TRUE;      
   }
   
   if (total < 1) {
      ShortTrade = FALSE;
      LongTrade = FALSE;
      TradeNow = TRUE;
      StartEquity = AccountEquity();
   }
   if (TradeNow) {
 //     LastBuyPrice = FindLastBuyPrice();
 //     LastSellPrice = FindLastSellPrice();
      double MaxLot1=FindMaxLots();
      TrendRe=0;
      if (ShortTrade) {
         NumOfTrades = total;
         
         if (LotExponent>0) iLots = NormalizeDouble(MaxLot1*LotExponent, lotdecimal);
         if (LotExponent==0) iLots = NormalizeDouble(MaxLot1*learr[NumT()], lotdecimal);
         
         double ltsiz=LasTradeSize/100*AccountBalance()/1000;
         if (NumOfTrades>=LastTrade && LastTrade>0 && iLots>ltsiz) iLots = MaxLot1;
      
         RefreshRates();
         ticket = OpenPendingOrder(1, iLots, Bid, slip, Ask, 0, 0, "" + NumOfTrades, MagicNumber, 0, HotPink);
         if (ticket < 0) {
            PrintF("Error: "+ GetLastError());
            return (0);
         }
 
         TradeNow = FALSE;
         NewOrdersPlaced = TRUE;
      } else {
         if (LongTrade) {
            NumOfTrades = total;
         if (LotExponent>0) iLots = NormalizeDouble(MaxLot1*LotExponent, lotdecimal);
         if (LotExponent==0) iLots = NormalizeDouble(MaxLot1*learr[NumT()], lotdecimal);         
         ltsiz=LasTradeSize/100*AccountBalance()/1000;
         if (NumOfTrades>=LastTrade && LastTrade>0 && iLots>ltsiz) iLots = MaxLot1;
            ticket = OpenPendingOrder(0, iLots, Ask, slip, Bid, 0, 0, "" + NumOfTrades, MagicNumber, 0, Lime);
            if (ticket < 0) {
               PrintF("Error: "+ GetLastError());
               return (0);
            }
  
            TradeNow = FALSE;
            NewOrdersPlaced = TRUE;
         }
      }
   }
   if (TradeNow && total < 1) 
   {
      SellLimit = Bid;
      BuyLimit = Ask;
      TrendRe=1;
      if (!ShortTrade && !LongTrade) 
      {
         NumOfTrades = total;
         
         iLots = NormalizeDouble(GetLots(), lotdecimal);                  
                                 
            if (alert(1)==-1 && FDir!=0) 
              { 
               ticket = OpenPendingOrder(1, iLots, SellLimit, slip, SellLimit, 0, 0, "IER " + NumOfTrades, MagicNumber, 0, HotPink);
               if (ticket < 0) 
               {
                  PrintF("Error: "+ GetLastError()); return (0);
               }
               NewOrdersPlaced = TRUE;
            } //


            if (alert(0)==1 && FDir!=1) 
            { // меньше  <
               ticket = OpenPendingOrder(0, iLots, BuyLimit, slip, BuyLimit, 0, 0, "IER " + NumOfTrades, MagicNumber, 0, Lime);
               if (ticket < 0) 
               {
                  PrintF("Error: "+ GetLastError());  return (0);
               }
               NewOrdersPlaced = TRUE;
            }
           
         
         if (ticket > 0) expiration = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours);
         TradeNow = FALSE;
      }
   }
   
   total = CountTrades();
   AveragePrice = 0;
   double Count = 0;double maxpr=0; double minpr=10000000;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            AveragePrice += OrderOpenPrice() * OrderLots();
            Count += OrderLots();
         }
      }
   }
   if (total > 0) AveragePrice = NormalizeDouble(AveragePrice / Count, Digits);
   if (NewOrdersPlaced) {
      double tp3=0;
      if (TakeProfit==0) tp3=tparr[NumT()];
      if (TakeProfit!=0) tp3=TakeProfit;
      for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
               PriceTarget = AveragePrice + tp3 * Point;
               if (NumOfTrades>LastTrade+1) PriceTarget = AveragePrice + TakeProfitLast * Point;
               flag = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_SELL) {
               PriceTarget = AveragePrice - tp3 * Point;
               if (NumOfTrades>LastTrade+1) PriceTarget = AveragePrice - TakeProfitLast * Point;
               flag = TRUE;
            }
         }
      }
   }
   if (NewOrdersPlaced && TrendRe==0) {
      if (flag == TRUE) {
         for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
            OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
              {
             // OrderModify(OrderTicket(), AveragePrice, OrderStopLoss(), PriceTarget, 0, Yellow);
              if (OrderTakeProfit()!=PriceTarget) ModifyOrder(Symbol(),OrderOpenPrice(),OrderStopLoss(), PriceTarget, Yellow);             
              
              }
            NewOrdersPlaced = FALSE;
         }
      }
   }
   return (0);
}
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн

int CountTrades() {
   int count = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
      OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
   }
   return (count);
}

int LockTicket(int m) {
   int t = 0;
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
      OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != m) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == m)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY)t=OrderTicket();
   }
   return (t);
}
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн

void again() {
   timeprev = Time[1];
   return (0);
}

void CloseThisSymbolAll(int mn) {
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
      OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == mn) {
         while (!IsTradeAllowed()) Sleep(1000);
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid,Digits), slip, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask,Digits), slip, Red);
            PrintF ("close ALL orders Type : order :  Bid  "+OrderType()+" :  "+OrderOpenPrice()+"  :  "+Bid);            
         }
      }
   }
}

//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн

int OpenPendingOrder(int pType, double pLots, double pPrice, int pSlippage, double ad_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int l_ticket_60 = 0;
   int l_error_64 = 0;
   int l_count_68 = 0;
   int li_72 = 3;
   pPrice=NormalizeDouble(pPrice,Digits);
   switch (pType) {
   case 2:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, pLots, RoundToTickSize(pPrice), pSlippage, StopLong(ad_24, ai_32), TakeLong(pPrice, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, pLots, RoundToTickSize(pPrice), pSlippage, StopLong(ad_24, ai_32), TakeLong(pPrice, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, pLots, RoundToTickSize(Ask), pSlippage, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, pLots, RoundToTickSize(pPrice), pSlippage, StopShort(ad_24, ai_32), TakeShort(pPrice, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, pLots, RoundToTickSize(pPrice), pSlippage, StopShort(ad_24, ai_32), TakeShort(pPrice, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, pLots, RoundToTickSize(Bid), pSlippage, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60);
}

double StopLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 - ai_8 * Point);
}

double StopShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 + ai_8 * Point);
}

double TakeLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 + ai_8 * Point);
}

double TakeShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 - ai_8 * Point);
}

double CalculateProfit() {
   double ld_ret_0 = 0;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

void TrailingAlls() 
{     
   int  total2=CountTrades();   
   if (CalculateProfit()<=0 || total2==0) return(0);

  
   double AveragePrice2 = 0;
   double Count2 = 0;
   int dir=-1;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            AveragePrice2 += OrderOpenPrice() * OrderLots();
            Count2 += OrderLots();
            if (OrderType() == OP_BUY) dir=0;
            if (OrderType() == OP_SELL) dir=1;            
         }
      }
   }
   if (total2 > 0) 
    {   
    
    AveragePrice2 = RoundToTickSize(AveragePrice2/Count2);    
    } 
       
     if (dir==0) 
      {
       if (AveragePrice2>Bid-ProfitTrailDist*Point) return(0);
      } 
     if (dir==1) 
      {
       if (AveragePrice2<Bid+ProfitTrailDist*Point) return(0);
      }        
      for (int i = OrdersTotal() - 1; i >= 0; i--) 
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
         {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) 
              {
              if (UseTrailingStop==1) TrailingStairs(OrderTicket(),TrailDist,TrailStep,AveragePrice2);
              if (UseTrailingStop==2) TrailingStairs2(OrderTicket(),TrailDist,TrailStep,AveragePrice2);
              }
            }
            
          }
      }
      
//+------------------------------------------------------------------+
//| ТРЕЙЛИНГ СТАНДАРТНЫЙ-СТУПЕНЧАСТЫЙ                                |
//| Функции передаётся тикет позиции, расстояние от курса открытия,  |
//| на котором трейлинг запускается (пунктов) и "шаг", с которым он  |
//| переносится (пунктов)                                            |
//| Пример: при +30 стоп на +10, при +40 - стоп на +20 и т.д.        |
//+------------------------------------------------------------------+
void TrailingStairs(int ticket,int trldistance,int trlstep,double avg)
   {  
   double nextstair; // ближайшее значение курса, при котором будем менять стоплосс

   // проверяем переданные значения
   if ((trldistance<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trlstep<1) || (trldistance<trlstep) || (ticket==0) || (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)))
      {
      Print("Трейлинг функцией TrailingStairs() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      } 
   
   // если длинная позиция (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // расчитываем, при каком значении курса следует скорректировать стоплосс
      // если стоплосс ниже открытия или равен 0 (не выставлен), то ближайший уровень = курс открытия + trldistance + спрэд
      if ((OrderStopLoss()==0))
      nextstair = avg + trldistance*Point;
         
      // иначе ближайший уровень = текущий стоплосс + trldistance + trlstep + спрэд
      else
      nextstair = OrderStopLoss() + trldistance*Point;

      // если текущий курс (Bid) >= nextstair и новый стоплосс точно лучше текущего, корректируем последний
      if (Bid>=nextstair)
      if ((OrderStopLoss()==0)) 
      OrderModify(ticket,OrderOpenPrice(),avg + trlstep*Point,OrderTakeProfit(),OrderExpiration());
      else
      OrderModify(ticket,OrderOpenPrice(),OrderStopLoss() + trlstep*Point,OrderTakeProfit(),OrderExpiration());
      }
      
   // если короткая позиция (OP_SELL)
   if (OrderType()==OP_SELL)
      { 
      // расчитываем, при каком значении курса следует скорректировать стоплосс
      // если стоплосс ниже открытия или равен 0 (не выставлен), то ближайший уровень = курс открытия + trldistance + спрэд
      if ((OrderStopLoss()==0) )
      nextstair = avg - (trldistance + MarketInfo(Symbol(),MODE_SPREAD))*Point;
      
      // иначе ближайший уровень = текущий стоплосс + trldistance + trlstep + спрэд
      else
      nextstair = OrderStopLoss() - (trldistance + MarketInfo(Symbol(),MODE_SPREAD))*Point;
       
      // если текущий курс (Аск) >= nextstair и новый стоплосс точно лучше текущего, корректируем последний
      if (Ask<=nextstair)
      if ((OrderStopLoss()==0))
      OrderModify(ticket,OrderOpenPrice(),avg - (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      else
      OrderModify(ticket,OrderOpenPrice(),OrderStopLoss()- (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      }      
   }

void TrailingStairs2(int ticket,int trldistance,int trlstep,double avg)
   {  
   double nextstair; // ближайшее значение курса, при котором будем менять стоплосс

   // проверяем переданные значения
   if ((trldistance<MarketInfo(Symbol(),MODE_STOPLEVEL)) || (trlstep<1) || (trldistance<trlstep) || (ticket==0) || (!OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)))
      {
      Print("Трейлинг функцией TrailingStairs() невозможен из-за некорректности значений переданных ей аргументов.");
      return(0);
      } 
   
   // если длинная позиция (OP_BUY)
   if (OrderType()==OP_BUY)
      {
      // расчитываем, при каком значении курса следует скорректировать стоплосс
      // если стоплосс ниже открытия или равен 0 (не выставлен), то ближайший уровень = курс открытия + trldistance + спрэд
      if ((OrderStopLoss()==0))
      nextstair = avg + trldistance*Point;
         
      // иначе ближайший уровень = текущий стоплосс + trldistance + trlstep + спрэд
      else
      {double trl=(OrderStopLoss()-avg)/Point;
      nextstair = OrderStopLoss() + xtral*trl*Point;}

      // если текущий курс (Bid) >= nextstair и новый стоплосс точно лучше текущего, корректируем последний
      if (Bid>=nextstair)
      if ((OrderStopLoss()==0)) 
      OrderModify(ticket,OrderOpenPrice(),avg + trlstep*Point,OrderTakeProfit(),OrderExpiration());
      else
      OrderModify(ticket,OrderOpenPrice(),OrderStopLoss() + trlstep*Point,OrderTakeProfit(),OrderExpiration());
      }
      
   // если короткая позиция (OP_SELL)
   if (OrderType()==OP_SELL)
      { 
      // расчитываем, при каком значении курса следует скорректировать стоплосс
      // если стоплосс ниже открытия или равен 0 (не выставлен), то ближайший уровень = курс открытия + trldistance + спрэд
      if ((OrderStopLoss()==0) )      
      nextstair = avg - (trldistance + MarketInfo(Symbol(),MODE_SPREAD))*Point;
      
      // иначе ближайший уровень = текущий стоплосс + trldistance + trlstep + спрэд
      else
      {trl=(avg-OrderStopLoss())/Point;
      nextstair = OrderStopLoss() - (trl*xtral + MarketInfo(Symbol(),MODE_SPREAD))*Point;
      }
       
      // если текущий курс (Аск) >= nextstair и новый стоплосс точно лучше текущего, корректируем последний
      if (Ask<=nextstair)
      if ((OrderStopLoss()==0))
      OrderModify(ticket,OrderOpenPrice(),avg - (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      else
      OrderModify(ticket,OrderOpenPrice(),OrderStopLoss()- (trlstep + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration());
      }      
   }


double AccountEquityHigh() {
   if (CountTrades() == 0) AccountEquityHighAmt = AccountEquity();
   if (AccountEquityHighAmt < PrevEquity) AccountEquityHighAmt = PrevEquity;
   else AccountEquityHighAmt = AccountEquity();
   PrevEquity = AccountEquity();
   return (AccountEquityHighAmt);
}


double FindMinBuyPrice() {
   double l_ord_open_price_8;
   double l_ticket_24;
   double ld_unused_0 = 0;
   double l_ticket_20 = 1000000000;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
         l_ticket_24 = OrderOpenPrice();
         if (l_ticket_24 < l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();            
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}

double FindMaxSellPrice() {
   double l_ord_open_price_8;
   double l_ticket_24;
   double ld_unused_0 = 0;
   double l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
         l_ticket_24 = OrderOpenPrice();
         if (l_ticket_24 > l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}

double GetLots() 
{
double minlot = MarketInfo(Symbol(), MODE_MINLOT);

if(Risk!=0)
 {
   double lot = NormalizeDouble(AccountBalance() * Risk/100 / 1000.0, lotdecimal);
   if(lot < minlot) lot = minlot;
  }
  else lot=Lots; 
   return(lot);
} 


double PipStepX(int dir)
{
if (PipStep==0) double r=psarr[NumT()];
if (PipStep>0)r=PipStep;
return(r);
}




int TrenT()
{
int t=FillArray(MagicNumber);
// подсчитывем сколько открыто ордеров с одинаковым шагом по тренду и есть ли ордера открытые уже против тренда с большим лотом
double minl1=10000;
if (Risk==0) minl1=Lots;
if (Risk>0)
{
   for (int i=0;i<100;i++)
   {
   if (minl1>lota[i] && lota[i]>0) minl1=lota[i];
   }
} // Risk

if (lota[ArrayMaximum(lota)]>minl1) { TrendRe=0;return(0);}

ModifTrendOrders();
TrendRe=1;

 int ii=-1; int jj=-1; // ищем самы верхний бай и самы нижний селл ордер
 double lastb=0; double lasts=10000000;


 // докупаем позиции по тренду
 
for(int cnt=0;cnt<100;cnt++)
{
if (modea[cnt]==0 && opa[cnt]>lastb && opa[cnt]>0){lastb=opa[cnt];ii=cnt;}
if (modea[cnt]==1 && opa[cnt]<lasts && opa[cnt]>0){lasts=opa[cnt];jj=cnt;} 
} 

if (modea[0]==0)
 {

 if (Ask>=lastb+TrendPS*Point) 
   {

   ticket=OrderSend(Symbol(),OP_BUY,minl1,NormalizeDouble(Ask,Digits),slip,0,0,"trend",MagicNumber,0,Green);
   

   if (ticket>0)
      {   
       ModifTrendOrders(); 
      return(0);
      }
   }
 }
if (modea[0]==1)
 {

 if (Bid<=lasts-TrendPS*Point) 
   {

   ticket=OrderSend(Symbol(),OP_SELL,minl1,NormalizeDouble(Bid,Digits),slip,0,0,"trend",MagicNumber,0,Red);   

      if (ticket>0)
      {

      ModifTrendOrders(); 
      return(0);
      }
   }
 } 

}

int FillArray(int mn1) // процедура подсчета всех ордеров данного эксперта по данному инструменту
{
ArrayInitialize(lota,-1);
ArrayInitialize(modea,-1);
ArrayInitialize(opa,-1);
ArrayInitialize(sla,-1);
ArrayInitialize(tpa,-1);
ArrayInitialize(tima,-1);
ArrayInitialize(ticka,-1);
ArrayInitialize(profa,-0.001);
  int c=0;
  int total  = OrdersTotal();

  for (int cnt = 0 ; cnt < total ; cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if (OrderMagicNumber() == MagicNumber && OrderSymbol()==Symbol())
    {
    lota[c]=OrderLots();
    modea[c]=OrderType();
    opa[c]=OrderOpenPrice();
    sla[c]=OrderStopLoss();
    tpa[c]=OrderTakeProfit();
    comma[c]=OrderComment();
    tima[c]=OrderOpenTime(); 
    ticka[c]=OrderTicket();        
    profa[c]=OrderProfit()+OrderCommission()+OrderSwap();    
    c++;
    }
  }  
  
 //   for (cnt=0;cnt<to;cnt++)  {   PrintF(lota[cnt],"  ", modea[cnt], "  ", opa[cnt], "   ", sla[cnt], "   ", tpa[cnt], "    ", tima[cnt], "   ", ticka[cnt]  );    }
 
  return(c);
}

int ModifTrendOrders()    
{

if (ProfitPerc>0) 
{
   int zk=0;
   for (int i=0;i<OrdersTotal();i++)
   {
   if (profa[i]!=-0.001) zk=zk+profa[i];
   }   
   if (zk>=AccountBalance()*ProfitPerc/100) 
    {   
    CloseThisSymbolAll(MagicNumber);   
    }
}
 
if (MinProfitPips>0)
   {
   double nf=0;   double mpric=0;int k=0;
    nf=nulfunc(MagicNumber);
    double allpro=0;   
 if (modea[0]==0)
    {
    double a1=nf+(MinProfitPips+1)*Point;
     for (i=0;i<100;i++)
         {
         if (opa[i]>mpric) mpric=opa[i]; 
         if (profa[i]!=-0.001) allpro=allpro+profa[i];
         if (profa[i]<=0 && profa[i]!=-0.001) k=k+1;           
          
                 
        if ((opa[i]<=Bid-TrendPS*1.5*Point) && (sla[i]<Bid-TrendPS*Point) && opa[i]>0 && Bid-TrendPS*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && a1>Bid-TrendPS*Point) 
           {
           if (ticka[i]>0) 
               {
       
               OrderSelect(ticka[i],SELECT_BY_TICKET);
               if (OrderStopLoss()!=mpric-TrendPS*Point) {ModifyOrder(Symbol(),OrderOpenPrice(),mpric-TrendPS*Point,OrderTakeProfit(),Green);          }
               }
           }
         }//a1+TrendPS*Point>=Bid &&
      if (mpric>a1+TrendPS*Point && a1+TrendPS*Point>=Bid && Bid>=a1 && CountTrades()>2 && allpro>0) CloseThisSymbolAll2();   
      if (mpric<a1+TrendPS*Point && k>=NumTr  && CountTrades()>NumTr) ClosePlusOrders(k);
     // if (mpric>a1+TrendPS*Point &&  Bid<=a1 && k>=NumTr  && CountTrades()>NumTr && allpro<0) ClosePlusOrders(k);      
   
       
      } // modea==0
      

 if (modea[0]==1)
    {mpric=1000000000;k=0;
    a1=nf-(MinProfitPips+1)*Point;
     for (i=0;i<100;i++)
         {
         if (opa[i]<mpric) mpric=opa[i]; 
         if (profa[i]!=-0.001) allpro=allpro+profa[i];
         if (profa[i]<=0 && profa[i]!=-0.001) k=k+1;      
         
         if ((opa[i]>=Ask+TrendPS*1.5*Point) && (sla[i]>Ask+TrendPS*Point || sla[i]==0) && opa[i]>0 && Ask+TrendPS*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && a1<Ask+TrendPS*Point) 
           {
           if (ticka[i]>0) 
               {
        
               OrderSelect(ticka[i],SELECT_BY_TICKET);
               if (OrderStopLoss()!=mpric+TrendPS*Point) {ModifyOrder(Symbol(),OrderOpenPrice(),mpric+TrendPS*Point,OrderTakeProfit(),Red);     }
               }
           }
         }//a1-TrendPS*Point<=Ask &&
      if (mpric>a1+TrendPS*Point && a1+TrendPS*Point>=Bid && Bid>=a1 && CountTrades()>2 && allpro>0) CloseThisSymbolAll2();   
      if (mpric<a1+TrendPS*Point && k>=NumTr  && CountTrades()>NumTr) ClosePlusOrders(k);
      //if (mpric<a1-TrendPS*Point &&  Ask>=a1 && k>=NumTr && CountTrades()>NumTr && allpro<0) ClosePlusOrders(k);    
   
                  
      } // modea==1
      
   }    
  
  return(0);
}


double FindMaxLots() {
   double l_ord_open_price_8;
   double l_ticket_24;
   double ld_unused_0 = 0;
   double l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         l_ticket_24 = OrderLots();
         if (l_ticket_24 > l_ticket_20) {
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ticket_20);
}

double nulfunc(int mn) // для подсчета точки безубыточности всех открытых ордеров (если все их закрыть по этой цене то получим 0)
  {
    double np=0;double f=0; double p=0;double l=0; int m=0;
    for(int t1=0;t1<OrdersTotal();t1++)    
    {
    OrderSelect(t1, SELECT_BY_POS, MODE_TRADES); 
    m = OrderType();p=OrderOpenPrice();l=OrderLots();if (m==OP_BUY){l=-l;}
    if  ((m==OP_BUY || m==OP_SELL) && OrderMagicNumber() == mn && OrderSymbol()==Symbol()) 
      {
      np=np+l*p;  
      f=f+l;
      }
    }
    if (f!=0) np=NormalizeDouble(MathAbs(np/f), Digits);       
    return (np);
  }



int PercCloseDown()
{
if (PercClose!=0 && PercDown!=0 && total>0)
    {
    double Pr11=0; int oti=2147483647;
      for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) 
      {
        OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        Pr11=Pr11+OrderProfit()+OrderCommission()+OrderSwap();
        if (oti>OrderTicket()) oti=OrderTicket();
      }
     if (FirstTr<oti) {FirstTr=oti;LastDD=0;}
     if (LastDD>Pr11 && Pr11<0) {LastDD=Pr11;}
     
     if (MathAbs(LastDD)>PercDown*AccountBalance()/100 && MathAbs(Pr11)<=PercClose*AccountBalance()/100) {LastDD=0;FirstTr=0;CloseThisSymbolAll(MagicNumber);}
    }
}


int ProfitMonitor()
{
   int total1 = CountTrades();
   double AveragePrice1 = 0;
   double Count1 = 0;
   double Profit1=0;
   double ProfitPoint=0;
   int dir = -1;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) 
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
      {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) 
         {
            AveragePrice1 += OrderOpenPrice() * OrderLots();
            Count1 += OrderLots();
            Profit1+= OrderProfit();
            if (OrderType() == OP_BUY) dir=0;
            if (OrderType() == OP_SELL) dir=1;
         }
      }
   }
   if (total1 > 2) 
     { 
     AveragePrice1 = NormalizeDouble(AveragePrice1 / Count1, Digits);
     int ProfitPips=0;
     if (TakeProfit==0) ProfitPips=tparr[NumT()];
      if (TakeProfit!=0) ProfitPips=TakeProfit;
     if (total1>LastTrade) ProfitPips=TakeProfitLast;
     if (dir==0 && TrendRe==0) {ProfitPoint=AveragePrice1+ProfitPips*Point;if (Bid>=ProfitPoint) CloseThisSymbolAll(MagicNumber); }
     if (dir==1 && TrendRe==0) {ProfitPoint=AveragePrice1-ProfitPips*Point;if (Ask<=ProfitPoint) CloseThisSymbolAll(MagicNumber); }            
     } 
}


//+----------------------------------------------------------------------------+
//|  Модификация ордера                                                        |
//|  Параметры:                                                                |
//|    sy - наименование инструмента  ("" - текущий символ)                    |
//|    pp - цена открытия позиции, установки ордера                            |
//|    sl - ценовой уровень стопа                                              |
//|    tp - ценовой уровень тейка                                              |
//|    cl - цвет                                                               |
//+----------------------------------------------------------------------------+
void ModifyOrder(string sy="", double pp=-1, double sl=0, double tp=0, color cl=CLR_NONE) {
  if (sy=="") sy=Symbol();
  bool   fm;
  int NumberOfTry=1;
  int PauseAfterError=10;
  double pAsk=MarketInfo(sy, MODE_ASK);
  double pBid=MarketInfo(sy, MODE_BID);
  int    dg, err, it;

  if (pp<=0) pp=OrderOpenPrice();
  if (sl<0) sl=OrderStopLoss();
  if (tp<0) tp=OrderTakeProfit();
  
  dg=MarketInfo(sy, MODE_DIGITS);
  pp=RoundToTickSize(pp);
  sl=RoundToTickSize(sl);
  tp=RoundToTickSize(tp);

  if (pp!=OrderOpenPrice() || sl!=OrderStopLoss() || tp!=OrderTakeProfit()) {
    for (it=1; it<=NumberOfTry; it++) {
      if (!IsTesting() && (!IsExpertEnabled() || IsStopped())) break;
      while (!IsTradeAllowed()) Sleep(5000);
      RefreshRates();
      if (NormalizeDouble(tp,Digits)!=OrderTakeProfit()) fm=OrderModify(OrderTicket(), NormalizeDouble(pp,Digits), NormalizeDouble(sl,Digits), NormalizeDouble(tp,Digits), 0, cl);
      if (fm) {
        //if (UseSound) PlaySound(NameFileSound); break;
      } else {
        err=GetLastError();
        PrintF("Error("+err+") modifying order: try "+it);
        PrintF("Ask="+pAsk+"  Bid="+pBid+"  sy="+sy+"  op="+OrderType()+
              "  pp="+pp+"  sl="+sl+"   OrderStopLoss()   "+OrderStopLoss()+"  tp="+tp+"  OrderTakeProfit  "+OrderTakeProfit());
        Sleep(1000*PauseAfterError);
      }
    }
  }
}
//+----------------------------------------------------------------------------+


int ClosePlusOrders(int kk)
{
for (int trade = OrdersTotal() - 1; trade >= 0; trade--) {
         OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol()) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderProfit()+OrderSwap()>0) {
            
              if (OrderType() == OP_BUY && OrderOpenPrice()+MinProfitPipsOne*Point<=Ask && OrderTakeProfit()==0) OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid,Digits), minslip, Blue);
               if (OrderType() == OP_SELL && OrderOpenPrice()-MinProfitPipsOne*Point>=Bid  && OrderTakeProfit()==0) OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask,Digits), minslip, Red);
   
               PrintF ("close plus orders Type : order :  Bid  "+OrderType()+" :  "+OrderOpenPrice()+"  :  "+Bid);               
            }
         while (!IsTradeAllowed()) Sleep(1000);
          RefreshRates();
         }
      }
}

int PrintF (string s)
{
if (ComOn==1) Print(s);
}

double RoundToTickSize(double price){return(NormalizeDouble(MathRound(price/MarketInfo(Symbol(), MODE_TICKSIZE))*MarketInfo(Symbol(), MODE_TICKSIZE), MarketInfo(Symbol(), MODE_DIGITS)));}

int NumT() // определение номера текущей сделки
  {int nmax=0;
for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) 
{ 
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) 
      {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) 
         {
         if (OrderComment()!="trend") nmax=nmax+1;
         }}}
//         Print ("  nmax  ",nmax);
         return(nmax);
  }

//void LockPositions() { }

void CloseThisSymbolAll2() {
   for (int trade = 0; trade <= 99; trade++) {
      OrderSelect(ticka[trade], SELECT_BY_TICKET, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         while (!IsTradeAllowed()) Sleep(1000);
         RefreshRates();
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid,Digits), slip, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask,Digits), slip, Red);
           PrintF ("close ALL orders Type : order :  Bid  "+OrderType()+" :  "+OrderOpenPrice()+"  :  "+Bid);            

         }
      }
   }
}


   int Dir(int mn)
   {
   int r=-1;
   for (int i = OrdersTotal() - 1; i >= 0; i--) 
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != mn) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == mn) {
         if (OrderType() == OP_BUY) 
         {
            r=1;
       
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == mn) {
         if (OrderType() == OP_SELL) {
            r=-1;
   
         }
      }
   }
   return(r);
   }
double Balance(string OrdType, string inf, int mn)
{
   double result=0, FProf = 0;
   int trade;
   for(trade=OrdersTotal()-1;trade>=0;trade--)
   {
      OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=mn) continue;
      if(OrderSymbol()==Symbol()&&OrderMagicNumber()==mn)
      {
         if (OrdType == "buy")
         {
            if(OrderType()==OP_BUY)
            {
               if (inf=="Balance") result=result+OrderProfit()-OrderSwap()-OrderCommission();
               if (inf=="Lot")     result=result+OrderLots();
               //if (inf=="FP") result=result + (OrderLots()*100000*(OrderTakeProfit()-OrderOpenPrice())/AccountLeverage());
               
            }
         }
         
         if (OrdType == "sell")
         {
            if(OrderType()==OP_SELL )
            {
               if (inf=="Balance") result=result+OrderProfit()-OrderSwap()-OrderCommission();
               if (inf=="Lot")     result=result+OrderLots();
               //if (inf=="FP")  result=result + (OrderLots()*100000*(-OrderTakeProfit()+OrderOpenPrice())/AccountLeverage());     
            }
         }
         
         
      }   
   }
  return(result);    
}

double LotSiz(double ltt)
{
double ls=0;
double minlot=MarketInfo(Symbol(), MODE_MINLOT);
double maxlot=MarketInfo(Symbol(), MODE_MAXLOT);
double steplot=MarketInfo(Symbol(), MODE_LOTSTEP);

int LotsDigits = MathCeil(MathAbs(MathLog(steplot)/MathLog(10)));
ls = NormalizeDouble(ltt,LotsDigits);

if (ltt<minlot)    {   ls=minlot;  }
if (ltt>maxlot)    {   ls=maxlot;  }

//int LotsDigits = MathCeil(MathAbs(MathLog( MarketInfo(Symbol(),MODE_MINLOT))/MathLog(10)));
//Количество значащих цифр после запятой в размере позиции. 


return(ls);
}

 double CountLots(int mn) {
   double l_count_0 = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != mn) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == mn)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0=l_count_0+OrderLots();
   }
   return (l_count_0);
}

int alert(int d6)       
{
   int x=0;
   string ind_name = "i-Regr";
   double ma3=0;
   double ma = iCustom(NULL, mper[TFS], ind_name,    Regr.degree1, Regr.kstd1, SPer, Regr.shift1,0, 0);
   double ma1 = iCustom(NULL, mper[TFS], ind_name,    Regr.degree1, Regr.kstd1, SPer, Regr.shift1,0, 1);  
   if (invert==1) {ma3=ma;ma=ma1;ma1=ma3;}
   if (kanal==1)
   {
   double m_up = iCustom(NULL, mper[TFS], ind_name,    Regr.degree1, Regr.kstd1, SPer, Regr.shift1,1, 0);
   double m_d = iCustom(NULL, mper[TFS], ind_name,    Regr.degree1, Regr.kstd1, SPer, Regr.shift1,2, 0);      
   if (ma>ma1 && Bid>m_d) x=1;
   if (ma<ma1  && Ask<m_up) x=-1;
   }
   if (kanal==0)
   {
   if (ma>ma1) x=1;
   if (ma<ma1) x=-1;
   }   
   if (kanal==2)
   {
   m_up = iCustom(NULL, mper[TFS], ind_name,    Regr.degree1, Regr.kstd1, SPer, Regr.shift1,1, 0);
   m_d = iCustom(NULL, mper[TFS], ind_name,    Regr.degree1, Regr.kstd1, SPer, Regr.shift1,2, 0);      
   if (ma>ma1 && Bid>m_d && Ask<m_up ) x=1;
   if (ma<ma1  && Ask<m_up && Bid>m_d ) x=-1;
   }   
return(x);
}

int alerts(int d6) 
{
//if (NumT()<IndStep) return(d6);
int x=0;
   string ind_name = "i-Regr";
   double ma = iCustom(NULL, mper[TFSmall], ind_name,    Regr.degree1mall, Regr.kstd1mall, SPermall, Regr.shift1mall,0, 0);
   double ma1 = iCustom(NULL, mper[TFSmall], ind_name,    Regr.degree1mall, Regr.kstd1mall, SPermall, Regr.shift1mall,0, 1); 
   double m_up = iCustom(NULL, mper[TFSmall], ind_name,    Regr.degree1mall, Regr.kstd1mall, SPermall, Regr.shift1mall,1, 0);
   double m_d = iCustom(NULL, mper[TFSmall], ind_name,    Regr.degree1mall, Regr.kstd1mall, SPermall, Regr.shift1mall,2, 0);      
   if (ma>ma1 && Bid>m_d && Ask<m_up ) x=1;
   if (ma<ma1  && Ask<m_up && Bid>m_d ) x=-1;
return(x);
}


