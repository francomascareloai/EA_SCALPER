//+------------------------------------------------------------------+
//|                                                Overdraft_Spazm   |
//|          Copyright © 2014 —ергей  оролевский ambrela0071@mail.ru |
//|   programming & support - —ергей  оролевский ambrela0071@mail.ru |
//| 01.12.2014                                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014  —ергей  оролевский"
#property link      "ambrela0071@mail.ru"
//Ёксперт предоставлен дл€ ознакомлени€ работы на форекс рынке, код открытый, что позволит вам модернизировать стратегию, и
//сделать под себ€, оптимизировать под рынок и зарабатывать.
//ѕредлагаю доверительное управление вашими средствами на Forex:

//ћинимальный депозит 20k - кредитное плечо лучше всего 1/300 и выше.
//÷ентовый счЄт на InstaForex 1000$ - кредитное плечо 1/300 и выше.
//RoboForex центовые счета Pro.
//∆елательно брокеры с п€тизначным котированием. 
//ѕример котировки: (1.24135) - т.е. п€ть знаков после точки.
//ћожно использовать и на других брокерах:
//Alpari; FXOpen; AdmiralMarkets, Roboforex и другие.....
//Ќиже предоставлена информаци€ о счЄте брокерской компании RVD.
//—чЄт ECN, (плавающий спред).


//________________________________________
 
//»нформаци€ о счЄте, дл€ просмотра в режиме реального времени:
//Ќомер счЄта: 50767
//»нвесторский пароль: Investor2015
//IP: 5.9.113.233:443
//________________________________________
//¬нимание! “акие суммы вз€ты не с потолка, а с агрессивного графика 2008г. √де были супер тренды. 

//”слови€ распределени€ прибыльности:

//________________________________________
//ƒолларовые счета:
//ƒл€ долларовых депозитов приЄм в доверительное управление от 20k кредитное плечо 1/300 и выше.
//ѕрибыль делитс€ 50/50
//≈сли же сумма депозита 40k и более:
//ѕрибыль делитс€ 35% от заработка трейдеру управл€ющему, а 65% в пользу инвестора.
//≈сли же сумма депозита 100k и более:
//ѕрибыль делитс€ 30% от заработка трейдеру управл€ющему, а 70% в пользу инвестора.

//________________________________________



//÷ентовые счета:

//ƒл€ всех центовых счетов от 1000$ кредитное плечо 1/300 и выше.
//ѕрибыль всегда делитс€ 50/50.
//≈сть исключение:
//≈сли у ¬ас центовых счетов более 5-ти, тогда прибыль делитс€ так:
//40% управл€ющему трейдеру, а 60% в пользу инвестора.
//“акже можно вз€ть в управление и 500$ центового счЄта, если ¬ы при необходимости сможете долитьс€ в депозит.


//________________________________________
//”ведомление о рисках:
//—колько нужно денег, чтобы начать инвестировать?
//ћногих новичков интересует вопрос о том, каковы в доверительном управлении счетом Forex минимальные вложени€?
//ѕрелесть ѕјћћ-инвестировани€ в том, что суммы инвестиций могут быть намного меньше, чем в банке или, например, на рынке акций. –азные брокеры предлагают разные услови€, но можно найти таких, которые попрос€т вложить на Forex в доверительное управление от 10 долларов - така€ сумма найдетс€ у любого человека.
//ƒругое дело - если инвестор изначально рассчитывает на посто€нную ощутимую прибыль. ≈стественно, в этом случае ставки должны быть выше. ƒоход будет пропорционален сумме, вложенной в доверительные ѕјћћ счета на форекс. » риски тоже.
//—колько можно заработать?
//ѕри инвестировании и использовании услуги доверительного управлени€ деньгами на рынке Forex доходность за год может составл€ть 100% и более.
//ќсновные факторы, от которых будет зависеть уровень доходов:
//1	вложенна€ сумма;
//2	тактика работы управл€ющего: консервативна€ или агрессивна€;
//3	успешность торговли в конкретном мес€це.
//ѕри понимании основных правил инвестировани€ доверительное управление на форекс 100% может приносить без проблем.
//ƒоверительное управление на форекс без рисков: возможно ли?
//≈сли ¬ы решили заниматьс€ инвестированием, то ¬ам стоит знать о том, что инвестиций без рисков в принципе не существует. ¬ сторону доверительного управлени€ на ‘орекс критика от тех, кто вкладывал и разорилс€, всегда была, есть и будет. ƒа, инвестор всегда рискует. ќсновные риски св€заны с трем€ моментами:
//1	возможность того, что управл€ющий уйдет в зат€жную сильную просадку, потер€в все деньги, свои и инвестора;
//2	брокерска€ компани€ может оказатьс€ хорошо организованным хайпом, который уже очень скоро "лопнет";
//3	брокер может оказатьс€ не совсем добросовестным, либо у него возникнут проблемы, в результате которых он окажетс€ банкротом и лишит денег инвесторов.   сожалению, доверительное управление все еще никак не регулируетс€ российским законодательством.
//Ќе все отзывы о доверительном управлении на ‘орекс положительны. Ќо в целом можно говорить о том, что ѕјћћ-инвестирование - хороший источник пассивного дохода.
//¬ то же врем€, в ‘орекс при доверительном управлении гарантированный доход ¬ам, конечно же, никто обещать не станет. Ёто не регул€рна€ зарплата, которую работодатель исправно выплачивает до 15 числа.
//ѕоэтому, перед тем как принимать решение "дам денег в доверительное управление ‘орекс", нужно понимать, готовы ли ¬ы брать на себ€ определенные риски.
//Ќадеемс€, что теперь, когда ¬ам пон€тно, что такое доверительное управление на Forex, ¬ы сможете прин€ть дл€ себ€ осознанное решение, стоит ли этим заниматьс€.


// онтакты:
//E-mail: Ambrela0071@yandex.ru
//Skype: OverdraftScalpSystem
//QIP: 444048899
// ==========================================================================================================================================================================================================
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// 
//                             ¬ Ќ ≈ Ў Ќ » ≈    ѕ ≈ – ≈ ћ ≈ Ќ Ќ џ ≈
// 
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// ==========================================================================================================================================================================================================
extern bool VirtualReverse=true; // ¬иртуальный реверс
extern string OldStrategySet_=" Ќастройки старого советника";
extern double k=5.0;//множитель дл€ открыти€ сделки относит. текущей волатильности т.е. движение_дл€_открыти€=волатильность_за_период*k 
extern int period=24;//период дл€ расчЄта волатильности в барах
extern int exp=0;//режим сглаживани€ волатильности 0-простое скольз€щее 1-линейно-взвешенное 
extern int open_close=0;//режим расчЄта волатильности по 1-open/close, 0-High/Low
extern bool visualize=true; //отрисовка движений

extern string In_=" Ќастройки входа";
extern int SpreadMinimumToCloseLOSS=1; // ћинимальный убыток в спреде при которых поза закроетс€ при среднем спреде ≈сли 0 - то опци€ не работает
extern int SpreadMinimumToClosePROF=1; // ћинимальный прибыль в спреде при которых поза закроетс€ при среднем спреде ≈сли 0 - то опци€ не работает
extern bool ReverseSignal=false; // true - ѕереворачивать сигнал стратегии. 
extern string trade_="Ќастройки торговли";
extern int Magic=777;                     // ћагический номер
extern int StopLoss=0;                    // —топлосс, 0 - не используетс€
extern int TakeProfit=0;                  // “ейкпрофит , 0 - не используетс€
extern int Slippage=0;                    // ѕроскальзывание
extern bool MarketWatch=false;            // –ежим торговли по MarketWatch true  = сначала выставл€ютс€ позиции/ордера без стопов, потом происходит модификаци€ - дл€ некоторых брокеров
extern bool ClosePosifChange=true;        // «акрывать позиции при обратном сигнале
extern bool ONlyOnePosbySignal=true;      // »грать только или бай и / или селл 1 позицией
extern int MaxPosifMoreThenOne=5;// ћаксимальное количество позиций если ONlyOnePosbySignal=false
extern string autolot_="Ќастройки автолота";
extern double Lots=0.1;                   // ‘иксирвоанный лот 
extern bool DynamicLot=false;             // ƒинамический лот
extern double LotBalancePcnt=20;          // % от депозита
extern double MaxLot=999;                 // ћаксимальный лот при расчете
extern double Martin=1; // ≈сли 1 то не используетс€,  оэффициент мартина на следующую сделку после убытончой

extern string timetrade_="Ќастройки времени торговли";
extern int OpenHour=0;                    // „ас открыти€ торгов
extern int OpenMinute=0;                  // ћинута открыти€ торгов
extern int CloseHour=23;                  // „ас закрыти€ торгов
extern int CloseMinute=59;                // ћинута закрыти€ торгов
extern string Trailing_="Ќастройки трейлингстопа";
extern bool TrailingStopUSE=false;        // »спользовать трейлингстоп 
extern bool IfProfTrail=false;            // »спользовать только д€л профитных позиций - режим безубытка
extern int TrailingStop=0;                // ƒистанци€ трейлинга = 0 - минимально допустимый
extern int TrailingStep=1;                // Ўаг дистанции
extern string Trailing_SAR="Ќастройки трейлингстопа SAR";
extern bool TrailingStopSAR=false;        // »спользовать трейлингстоп 
extern double step=0.02;//-   ѕриращение уровн€ стопа, обычно 0.02. 
extern double maximum=0.2;//   -   ћаксимальный уровень стопа, обычно 0.2. 
extern string TrailingLOSS_="Ќастройки виртуального трейлингстопа убытка";
extern int TrailingStopLOSS=10;// - пунктов дл€ тралла ј “»¬ј÷»я 0 - отключен
extern int TrailingstepLOSS=10;// - пунктов дл€ тралла Ўј√ “–јЋј 
extern bool LOSSOrderOnly=true;// “олько убыточные позиции
extern string CloseProfitLoss=" Ќастройки закрыти€ по общему профиту";
extern string  сlose="= 1 - ƒоллар, 2 -ѕункты ,3 -%Ёквити ,4 -%Ѕаланс";
extern int     TypeofClose=1; // “ип закрыти€ по прибыли 
extern bool CloseProfit=false;// «акрывать если +
extern double prifitessss=10; //  оличество юнитов(в зависимости от выбора TypeofClose) дл€ закрыти€ профита
extern bool CloseLoss=false;// закрывать если -
extern double lossss=-10;//  оличество юнитов(в зависимости от выбора TypeofClose) дл€ закрыти€ убытка
extern bool OFFAllEaAfterClosePROF=false;// ¬ыключать все советники и скрипты после закрыти€ прибыли.
extern bool OFFAllEaAfterCloseLOSS=false;// ¬ыключать все советники и скрипты после закрыти€ убытка.
extern string BU_="Ќастройки безубытка";
extern bool MovingInWLUSE=false;   // ѕеренос позиции в безубыток
extern int LevelWLoss=0; // ѕереносим стоплосс в +LevelWLoss пунктов
extern int LevelProfit=0;//  огда сделка вышла в плюс LevelProfit пунктов
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// ==========================================================================================================================================================================================================
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// 
//                             ‘ ” Ќ   ÷ » »      — ќ ¬ ≈ “ Ќ »   ј   
// 
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// ==========================================================================================================================================================================================================

int NumberOfPositions(string sy="", int op=-1, int mn=-1) {
  int i, k=OrdersTotal(), kp=0;

  if (sy=="0") sy=Symbol();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==sy || sy=="") {
        if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
          if (op<0 || OrderType()==op) {
            if (mn<0 || OrderMagicNumber()==mn) kp++;
          }
        }
      }
    }
  }
  return(kp);
}

int TF;

double Prof,Loss;
bool printtime=false;

double timeCheckSignal; // ¬рем€ открыти€ позиции
double sl,tp; // ƒл€ вычислени€ стопов 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int sprea[];
double AverSpread=1;
double Spread()
  {
  if(ArraySize(sprea)>999)ArrayResize(sprea,1);
  ArrayResize(sprea,ArraySize(sprea)+1);
  sprea[ArraySize(sprea)-1]=(Ask-Bid)/Point;
  double aver;
  for(int i=0;i<ArraySize(sprea);i++)aver=aver+sprea[i];
   AverSpread=aver/ArraySize(sprea);
   if(AverSpread<1)AverSpread=1;
   ObjectCreate("Original2",OBJ_LABEL,0,0,0);
   ObjectSetText("Original2"," “екущий средний спред по валюте = "+DoubleToStr(AverSpread,8),12,"Arial Bold",Chartreuse);
   ObjectSet("Original2",OBJPROP_CORNER,0);
   ObjectSet("Original2",OBJPROP_XDISTANCE,0);
   ObjectSet("Original2",OBJPROP_YDISTANCE,30);

  }

// ==========================================================================================================================================================================================================
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// 
//                             ‘ ” Ќ   ÷ » я      S T A R T ( )   
// 
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// ==========================================================================================================================================================================================================

int start()
  {
if (!EPs(Symbol(),-1,Magic))TF=Period();
   Stamp();
   Spread();
   int Signal; // —игнал к открытию
//+------------------------------------------------------------------+
//ѕровер€ем наличие торгового времени(разрешени€ на торговлю)
//+------------------------------------------------------------------+
   bool Traiding=TDt(DoubleToStr(CloseHour,0),DoubleToStr(CloseMinute,0),DoubleToStr(OpenHour,0),DoubleToStr(OpenMinute,0));
//+------------------------------------------------------------------+
// ¬ключение трейлингстопа:
//+------------------------------------------------------------------+
   if(TrailingStopUSE)SimpleTrailing(Symbol(),-1,Magic);
   if(TrailingStopSAR)SimpleTrailingSAR(Symbol(),-1,Magic);


//+------------------------------------------------------------------+
// ¬ключение виртуального трейлингстопа с тралом убытка:
//+------------------------------------------------------------------+

   if(TrailingStopLOSS!=0)startVTSLOSS();
//+------------------------------------------------------------------+
// ¬ключение трейлингстопа:
//+------------------------------------------------------------------+
   if(MovingInWLUSE)MovingInWL(Symbol(),-1,Magic);

//+------------------------------------------------------------------+
// «акрытие по прибыли и убытку
//+------------------------------------------------------------------+

   if(CloseProfit || CloseLoss)startCloseBlock3();

// ==========================================================================================================================================================================================================
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// 
//                             —“ј–“ --- √ Ћ ј ¬ Ќ џ …   Ѕ Ћ ќ     » — ѕ ќ Ћ № « ќ ¬ ј Ќ » я    Ў ј Ѕ Ћ ќ Ќ ј  
// 
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// ==========================================================================================================================================================================================================

   Signal=IndicatorSignal();


//+------------------------------------------------------------------+
// ≈сли врем€ торговли не истекло и мы не открывали позицию на этом баре: 
//+------------------------------------------------------------------+

   if(!Traiding && !printtime)
     {
      Print("Traiding time ending Close="
            +TimeToStr(StrToTime(CloseHour+":"+CloseMinute),TIME_DATE|TIME_SECONDS)
            +" Open= "
            +TimeToStr(StrToTime(OpenHour+":"+OpenMinute),TIME_DATE|TIME_SECONDS)
            +" Curent= "+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)

            );printtime=true;
     }
   if(Traiding && timeCheckSignal!=Time[0])

     {
      printtime=false;
      //+------------------------------------------------------------------+
      // ≈сли сигнал на бай:
      //+------------------------------------------------------------------+
      if(Signal==1)// buy
        {
        
            //¬ычисл€ем стоплосс
            if(StopLoss!=0)sl=Ask-StopLoss*Point; else sl=0;
            // ¬џчисл€ем тейкпрофит
            if(TakeProfit!=0)tp=Ask+TakeProfit*Point; else tp=0;
            //+------------------------------------------------------------------+
            //«акрываем противоположную позицию
            //+------------------------------------------------------------------+
            if(ClosePosifChange)CPD(Symbol(),OP_SELL,Magic);
            //+------------------------------------------------------------------+
            //ќткрываем позицию
            //+------------------------------------------------------------------+
            if((ONlyOnePosbySignal && !EPs(Symbol(),-1,Magic)) || (!ONlyOnePosbySignal&& NumberOfPositions(Symbol(),-1,Magic)<MaxPosifMoreThenOne))
              {
               OPs(Symbol(),OP_BUY,GetSizeLot(),sl,tp,Magic,"Templates Ambrela0071@mail.ru");
               timeCheckSignal=Time[0];
              }
         

        }

      //+------------------------------------------------------------------+
      // ≈сли сигнал на селл:
      //+------------------------------------------------------------------+
      if(Signal==2)// селл
        {
         

            //¬ычисл€ем стоплосс
            if(StopLoss!=0)sl=Bid+StopLoss*Point; else sl=0;
            // ¬џчисл€ем тейкпрофит
            if(TakeProfit!=0)tp=Bid-TakeProfit*Point; else tp=0;
            //«акрываем противоположную позицию
            if(ClosePosifChange)CPD(Symbol(),OP_BUY,Magic);
            //+------------------------------------------------------------------+
            //ќткрываем позицию
            //+------------------------------------------------------------------+
            if((ONlyOnePosbySignal && !EPs(Symbol(),-1,Magic)) || (!ONlyOnePosbySignal&& NumberOfPositions(Symbol(),-1,Magic)<MaxPosifMoreThenOne))
              {
               OPs(Symbol(),OP_SELL,GetSizeLot(),sl,tp,Magic,"Templates Ambrela0071@mail.ru");
               timeCheckSignal=Time[0];
              }
          
        }

      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+

     }

   return(0);
  }
// ==========================================================================================================================================================================================================
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// 
//                             ‘ ” Ќ   ÷ » »    Ё   — ѕ ≈ – “ ј  
// 
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// ==========================================================================================================================================================================================================
void MovingInWL(string sy="",int op=-1,int mn=-1)
  {
   double po,pp;
   int    i,k=OrdersTotal();

   for(i=0; i<k; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && (OrderMagicNumber()==mn || mn<0) && (OrderSymbol()==sy || sy==""))
        {
         po=MarketInfo(OrderSymbol(),MODE_POINT);
         if(OrderType()==OP_BUY)
           {
            if(OrderStopLoss()-OrderOpenPrice()<LevelWLoss*po)
              {
               pp=MarketInfo(OrderSymbol(),MODE_BID);
               if(pp-OrderOpenPrice()>LevelProfit*po)
                 {
                  ModifyOrder(-1,OrderOpenPrice()+LevelWLoss*po,-1);
                 }
              }
           }
         if(OrderType()==OP_SELL)
           {
            if(OrderStopLoss()==0 || OrderOpenPrice()-OrderStopLoss()<LevelWLoss*po)
              {
               pp=MarketInfo(OrderSymbol(),MODE_ASK);
               if(OrderOpenPrice()-pp>LevelProfit*po)
                 {
                  ModifyOrder(-1,OrderOpenPrice()-LevelWLoss*po,-1);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                          –абота по времени                       |
//+------------------------------------------------------------------+
bool TDt(string CloseHour,string CloseMinute,string OpenHour,string OpenMinute) //   ‘ункци€ провер€ет со скольки до скольки можно
  {
   if(CloseHour=="23" && CloseMinute=="59" && OpenHour=="0" && OpenMinute=="0")return(true);

   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";
//   торговать. ≈сли удовлетвор€ет услови€м
   int TradingTime=false;                                    //   ¬озвращает ""можно""
   if(StrToTime(CloseHour+":"+CloseMinute)>StrToTime(OpenHour+":"+OpenMinute))
     {
      if(TimeCurrent()<StrToTime(CloseHour+":"+CloseMinute) && TimeCurrent()>=StrToTime(OpenHour+":"+OpenMinute)) //
         TradingTime=true;
     }
   if(StrToTime(CloseHour+":"+CloseMinute)<StrToTime(OpenHour+":"+OpenMinute))
     {
      if(TimeCurrent()<StrToTime(CloseHour+":"+CloseMinute) || TimeCurrent()>=StrToTime(OpenHour+":"+OpenMinute)) //
         TradingTime=true;
     }                                     //
   return(TradingTime);                                  //
  }
//+------------------------------------------------------------------+
//|                           ”даление отложенных ордеров            |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//|  ѕараметры:                                                                |
//|    sy - наименование инструмента   ( ""  - любой символ,                   |
//|                                     NULL - текущий символ)                 |
//|    op - операци€                   ( -1  - люба€ позици€)                  |
//|    mn - MagicNumber                ( -1  - любой магик)                    |
//+----------------------------------------------------------------------------+

bool DxO(string sy="",int op=-1,int mn=-1,datetime ot=0)
  {
   int i,k=OrdersTotal(),ty;
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   if(sy=="0") sy=Symbol();
   for(i=k-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         ty=OrderType();
         if(ty>1 && ty<6)
           {
            if((OrderSymbol()==sy || sy=="") && (op<0 || ty==op))
              {
               if(mn<0 || OrderMagicNumber()==mn)
                 {
                  if(ot<=OrderOpenTime()) {OrderDelete(OrderTicket(),0);}
                 }
              }
           }
        }
     }
   return(False);
  }
//+------------------------------------------------------------------+
//|                              ћодификаци€ позиций/ордеров         |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//|  ѕараметры:                                                                
//|    pp - ÷ена модификаци€ (дл€ отложенных ордеров)  
//|                                                    
//|    sl - —топлосс - или 0                                     
//|    tp - “ейкпрофит - или 0               
//|    ex - ƒата истечени€ отложенного ордера или 0
//+----------------------------------------------------------------------------+

void ModifyOrder(double pp=-1,double sl=0,double tp=0,datetime ex=0)
  {
   bool   fm;
   double op,pa,pb,os,ot;
   int    dg=MarketInfo(OrderSymbol(),MODE_DIGITS),er,it;
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   if(pp<=0) pp=OrderOpenPrice();
   if(sl<0 ) sl=OrderStopLoss();
   if(tp<0 ) tp=OrderTakeProfit();

   pp=NormalizeDouble(pp, dg);
   sl=NormalizeDouble(sl, dg);
   tp=NormalizeDouble(tp, dg);
   op=NormalizeDouble(OrderOpenPrice() , dg);
   os=NormalizeDouble(OrderStopLoss()  , dg);
   ot=NormalizeDouble(OrderTakeProfit(), dg);

   if(pp!=op || sl!=os || tp!=ot)
     {
      for(it=1; it<=3; it++)
        {
         if(!IsTesting() && (!IsExpertEnabled() || IsStopped())) break;
         RefreshRates();
         fm=OrderModify(OrderTicket(),pp,sl,tp,ex);
         if(fm)
           {
            break;
              } else {
            er=GetLastError();
            pa=MarketInfo(OrderSymbol(), MODE_ASK);
            pb=MarketInfo(OrderSymbol(), MODE_BID);
            //Alert("Error(",er,") modifying order: ",ErrorDescription(er),", try ",it);
            //Alert("Ask=",pa,"  Bid=",pb,"  sy=",OrderSymbol(),
            //       "  op="+OrderType(),"  pp=",pp,"  sl=",sl,"  tp=",tp);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                         Ќаличие отложенных ордеров               |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//|  ѕараметры:                                                                |
//|    sy - наименование инструмента   ( ""  - любой символ,                   |
//|                                     NULL - текущий символ)                 |
//|    op - операци€                   ( -1  - люба€ позици€)                  |
//|    mn - MagicNumber                ( -1  - любой магик)                    |
//+----------------------------------------------------------------------------+

bool ExO(string sy="",int op=-1,int mn=-1,datetime ot=0)
  {
   int i,k=OrdersTotal(),ty;
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   if(sy=="0") sy=Symbol();
   for(i=0;i<k;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         ty=OrderType();
         if(ty>1 && ty<6)
           {
            if((OrderSymbol()==sy || sy=="") && (op<0 || ty==op))
              {
               if(mn<0 || OrderMagicNumber()==mn)
                 {
                  if(ot<=OrderOpenTime()) return(True);
                 }
              }
           }
        }
     }
   return(False);
  }
//+------------------------------------------------------------------+
//|              ”становка отложенного ордера                        |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//|  ѕараметры:                                                                |
//|    sy - наименование инструмента   (NULL или "" - текущий символ)          |
//|    op - операци€                                                           |
//|    ll - лот                                                                |
//|    pp - цена                                                               |
//|    sl - уровень стоп                                                       |
//|    tp - уровень тейк                                                       |
//|    mn - Magic Number                                                       |
//|    ex - —рок истечени€                                                     |
//+----------------------------------------------------------------------------+
int SetOrder(string sy,int op,double ll,double pp,
             double sl=0,double tp=0,int mn=0,string lsComm="",datetime ex=0)
  {
   color    clOpen;
   datetime ot;
   double   pa,pb,mp;
   int      err,it,ticket,msl;
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   if(sy=="" || sy=="0") sy=Symbol();
   msl=MarketInfo(sy,MODE_STOPLEVEL);
   if(ex>0 && ex<TimeCurrent()) ex=0;
   for(it=1; it<=5; it++)
     {
      if(!IsTesting() && (!IsExpertEnabled() || IsStopped()))
        {
         Print("SetOrder(): ќстановка работы функции");
         break;
        }
      while(!IsTradeAllowed())if(!IsTesting() && !IsOptimization()) Sleep(5000);
      RefreshRates();
      ot=TimeCurrent();
      if(!MarketWatch)ticket=OrderSend(sy,op,ll,NormalizeDouble(pp,MarketInfo(sy,MODE_DIGITS)),Slippage,NormalizeDouble(sl,MarketInfo(sy,MODE_DIGITS)),NormalizeDouble(tp,MarketInfo(sy,MODE_DIGITS)),lsComm,mn,ex,clOpen);
      if(MarketWatch)

        {
         ticket=OrderSend(sy,op,ll,NormalizeDouble(pp,MarketInfo(sy,MODE_DIGITS)),Slippage,0,0,lsComm,mn,ex,clOpen);
         if(SBT(ticket)) ModifyOrder(-1,sl,tp);
        }

      if(ticket>0)
        {
         if(!IsTesting()) WindowScreenShot(WindowExpertName()+"\\"+op+WindowExpertName()+Symbol()+Period()+TimeCurrent()+"_.gif",1024,768);

         return(ticket);
         break;
           } else {
         err=GetLastError();
         // ¬ывод сообщени€ об ошибке
         Print("Error(",err,") opening position: ",ErrorDescription(err),", try ",it);
         Print("Ask=",pa," Bid=",pb," sy=",sy," ll=",ll," op=",op,
               " pp=",pp," sl=",sl," tp=",tp," mn=",mn);
         if(pa==0 && pb==0) Print("ѕроверьте в ќбзоре рынка наличие символа "+sy);
         mp=MarketInfo(sy,MODE_POINT);
         pa=MarketInfo(sy, MODE_ASK);
         pb=MarketInfo(sy, MODE_BID);
         if(pa==0 && pb==0) Alert("SetOrder(): ѕроверьте в обзоре рынка наличие символа "+sy);
         // Ќеправильные стопы
         if(err==130)
           {
            switch(op)
              {
               case OP_BUYLIMIT:
                  if(pp>pa-msl*mp) pp=pa-msl*mp;
                  if(sl>pp-(msl+1)*mp) sl=pp-(msl+1)*mp;
                  if(tp>0 && tp<pp+(msl+1)*mp) tp=pp+(msl+1)*mp;
                  break;
               case OP_BUYSTOP:
                  if(pp<pa+(msl+1)*mp) pp=pa+(msl+1)*mp;
                  if(sl>pp-(msl+1)*mp) sl=pp-(msl+1)*mp;
                  if(tp>0 && tp<pp+(msl+1)*mp) tp=pp+(msl+1)*mp;
                  break;
               case OP_SELLLIMIT:
                  if(pp<pb+msl*mp) pp=pb+msl*mp;
                  if(sl>0 && sl<pp+(msl+1)*mp) sl=pp+(msl+1)*mp;
                  if(tp>pp-(msl+1)*mp) tp=pp-(msl+1)*mp;
                  break;
               case OP_SELLSTOP:
                  if(pp>pb-msl*mp) pp=pb-msl*mp;
                  if(sl>0 && sl<pp+(msl+1)*mp) sl=pp+(msl+1)*mp;
                  if(tp>pp-(msl+1)*mp) tp=pp-(msl+1)*mp;
                  break;
              }
            Alert("SetOrder(): —корректированы ценовые уровни"+sy+"--op-"+op+"--ll-"+ll+"--pp-"+pp+"---"+Slippage+"--sl-"+sl+"--tp-"+tp+"---"+lsComm+"---"+mn+"---"+ex+"---"+clOpen);
           }
         // Ѕлокировка работы советника
         Print("ќшибка "+err+" ќписание "+ErrorDescription(err));

         // Ѕлокировка работы советника
         if(err==2 || err==64 || err==65 || err==133)
           {
            break;
           }
         if(err==128 || err==142 || err==143)
           {
            Sleep(1000*66.666);
           }
         // ¬ывод сообщени€ об ошибке
         Alert("Error(",err,") opening position: ",ErrorDescription(err),", try ",it);
         Alert("Ask=",pa," Bid=",pb," sy=",sy," ll=",ll," op=",op,
               " pp=",pp," sl=",sl," tp=",tp," mn=",mn);
         if(pa==0 && pb==0) Alert("ѕроверьте в ќбзоре рынка наличие символа "+sy);
         // Ѕлокировка работы советника
         if(err==2 || err==64 || err==65 || err==133)
           {
            break;
           }
         // ƒлительна€ пауза
         if(err==4 || err==131 || err==132)
           {
            Sleep(1000*30); break;
           }
         if(err==140 || err==148 || err==4110 || err==4111) break;
         if(err==141) Sleep(1000*100);
         if(err==145) Sleep(1000*17);
         if(err==146) while(IsTradeContextBusy()) Sleep(1000*11);
         if(err!=135) Sleep(1000*7.7);
        }
     }
  }
//+------------------------------------------------------------------+
//|               ¬озвращает флаг удачного выбора позиции по тикету  |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//|  ѕараметры:                                                                |
//|    ti - наименование тикета                                                |
//|    sy - наименование инструмента   ( ""  - любой символ,                   |
//|                                     NULL - текущий символ)                 |
//|    op - операци€                   ( -1  - люба€ позици€)                  |
//|    mn - MagicNumber                ( -1  - любой магик)                    |
//+----------------------------------------------------------------------------+


bool SBT(int ti,string sy="",int op=-1,int mn=-1)
  {
   int i,k=OrdersTotal();
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   if(sy=="0") sy=Symbol();
   for(i=0;i<k;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderSymbol()==sy || sy=="") && (op<0 || OrderType()==op))
           {
            if((mn<0 || OrderMagicNumber()==mn) && OrderTicket()==ti) return(True);
           }
        }
     }
   return(False);
  }
//+------------------------------------------------------------------+
//|               ќткрытие позиции по рынку                          |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//|  ѕараметры:                                                                |
//|    sy - наименование инструмента   ("" или NULL - текущий символ)          |
//|    op - операци€                                                           |
//|    ll - лот                                                                |
//|    sl - уровень стоп                                                       |
//|    tp - уровень тейк                                                       |
//|    mn - MagicNumber                                                        |
//+----------------------------------------------------------------------------+
int OPs(string sy,int op,double ll,double sl=0,double tp=0,int mn=0,string coomment="")
  {
   color    clOpen;
   datetime ot;
   double   pp,pa,pb;
   int      dg,err,it,ticket=0;
   string   lsComm="";
   if(sy=="" || sy=="0") sy=Symbol();
   if(op==OP_BUY) clOpen=Green; else clOpen=Red;
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   for(it=1;it<=3;it++)
     {
      if(!IsTesting() && (!IsExpertEnabled() || IsStopped())) break;
      while(!IsTradeAllowed()) if(!IsTesting() && !IsOptimization())Sleep(5000);
      RefreshRates();
      dg=MarketInfo(sy, MODE_DIGITS);
      pa=MarketInfo(sy, MODE_ASK);
      pb=MarketInfo(sy, MODE_BID);
      if(op==OP_BUY) pp=pa; else pp=pb;
      pp=NormalizeDouble(pp, dg);
      ot=TimeCurrent();
      if(!MarketWatch) ticket=OrderSend(sy,op,ll,pp,Slippage,sl,tp,coomment,mn,0,clOpen);
      if(MarketWatch)

        {
         ticket=OrderSend(sy,op,ll,pp,Slippage,0,0,coomment,mn,0,clOpen);
         if(SBT(ticket)) ModifyOrder(-1,sl,tp);
        }

      if(ticket>0)
        {
         if(!IsTesting()) WindowScreenShot(WindowExpertName()+"\\"+op+WindowExpertName()+Symbol()+Period()+TimeCurrent()+"_.gif",1024,768);

         break;
           } else {
         err=GetLastError();

         // ¬ывод сообщени€ об ошибке
         Print("Error(",err,") opening position: ",ErrorDescription(err),", try ",it);
         Print("Ask=",pa," Bid=",pb," sy=",sy," ll=",ll," op=",op,
               " pp=",pp," sl=",sl," tp=",tp," mn=",mn);
         if(pa==0 && pb==0) Print("ѕроверьте в ќбзоре рынка наличие символа "+sy);
         Print("ќшибка "+err+" ќписание "+ErrorDescription(err));

         // Ѕлокировка работы советника
         if(err==2 || err==64 || err==65 || err==133)
           {
            break;
           }
         if(err==128 || err==142 || err==143)
           {
            Sleep(1000*66.666);
           }
         // ¬ывод сообщени€ об ошибке
         Alert("Error(",err,") opening position: ",ErrorDescription(err),", try ",it);
         Alert("Ask=",pa," Bid=",pb," sy=",sy," ll=",ll," op=",op,
               " pp=",pp," sl=",sl," tp=",tp," mn=",mn);
         if(pa==0 && pb==0) Alert("ѕроверьте в ќбзоре рынка наличие символа "+sy);
         // Ѕлокировка работы советника
         if(err==2 || err==64 || err==65 || err==133)
           {
            break;
           }
         // ƒлительна€ пауза
         if(err==4 || err==131 || err==132)
           {
            Sleep(1000*30); break;
           }
         if(err==140 || err==148 || err==4110 || err==4111) break;
         if(err==141) Sleep(1000*100);
         if(err==145) Sleep(1000*17);
         if(err==146) while(IsTradeContextBusy()) Sleep(1000*11);
         if(err!=135) Sleep(1000*7.7);

        }
     }
   return(ticket);
  }
//+------------------------------------------------------------------+
//|                Ќаличие позиций по рынку                          |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//|  ѕараметры:                                                                |
//|    sy - наименование инструмента   ( ""  - любой символ,                   |
//|                                     NULL - текущий символ)                 |
//|    op - операци€                   ( -1  - люба€ позици€)                  |
//|    mn - MagicNumber                ( -1  - любой магик)                    |
//+----------------------------------------------------------------------------+

bool EPs(string sy="",int op=-1,int mn=-1,int ticket=0)
  {
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   int i,k=OrdersTotal();

   if(sy=="0") sy=Symbol();
   for(i=0;i<k;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==sy || sy=="")
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
              {
               if(op<0 || OrderType()==op)
                 {
                  if(mn<0 || OrderMagicNumber()==mn)
                    {
                     if(ticket==OrderTicket() || ticket==0) return(True);
                    }
                 }
              }
           }
        }
     }
   return(False);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                 јвтолот                                          |
//+------------------------------------------------------------------+
double lastlot;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSizeLot(double ll=1) //‘ункци€ возвращает значение лотов, 
  {
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";
   string lotcalc;

   string Valdepo=AccountCurrency();
//если включен ћћ то значение лотов, 
   double Lot2,MinLots,MaxLots;
   int lotdig;
   if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01)lotdig=2; else lotdig=1;
   if(Valdepo=="USD")
     {
      if(StringSubstr(Symbol(),0,3)=="USD")Lot2=NormalizeDouble(AccountFreeMargin()*LotBalancePcnt*AccountLeverage()/100/MarketInfo(Symbol(),MODE_LOTSIZE),lotdig);
      else if(StringSubstr(Symbol(),3,3)=="USD")Lot2=NormalizeDouble(AccountFreeMargin()*LotBalancePcnt*AccountLeverage()/Ask/100/MarketInfo(Symbol(),MODE_LOTSIZE),lotdig);
      else
        {
         double pr=MarketInfo(StringSubstr(Symbol(),0,3)+"USD",MODE_ASK);
         if(pr!=0)Lot2=NormalizeDouble(AccountFreeMargin()*LotBalancePcnt*AccountLeverage()/pr/100/MarketInfo(Symbol(),MODE_LOTSIZE),lotdig);
         else Lot2=NormalizeDouble(AccountFreeMargin()*LotBalancePcnt*AccountLeverage()/100/MarketInfo(Symbol(),MODE_LOTSIZE),lotdig);
        }
     }
   if(Valdepo=="EUR")
     {
      if(StringSubstr(Symbol(),0,3)=="EUR")Lot2=NormalizeDouble(AccountFreeMargin()*LotBalancePcnt*AccountLeverage()/100/MarketInfo(Symbol(),MODE_LOTSIZE),lotdig);
      else
        {
         pr=MarketInfo("EUR"+StringSubstr(Symbol(),0,3),MODE_BID);
         if(pr!=0)Lot2=NormalizeDouble(AccountFreeMargin()*LotBalancePcnt*AccountLeverage()*pr/100/MarketInfo(Symbol(),MODE_LOTSIZE),lotdig);
         else Lot2=NormalizeDouble(AccountFreeMargin()*LotBalancePcnt*AccountLeverage()/100/MarketInfo(Symbol(),MODE_LOTSIZE),lotdig);
        }
     }
   MinLots=MarketInfo(Symbol(),MODE_MINLOT);
   MaxLots=MaxLot;
   lotcalc=" Autolot="+Lot2;
   if(!DynamicLot)Lot2=Lots;
   if(Martin!=1)
     {
      if(isCloseLastPosByStop(Symbol(),-1,Magic)==1)lastlot=OrderLots()*Martin;
      if(isCloseLastPosByStop(Symbol(),-1,Magic)==2)lastlot=OrderLots();
      if(isCloseLastPosByStop(Symbol(),-1,Magic)==0)lastlot=Lot2;
      lotcalc=lotcalc+" Martinlot="+lastlot;
      Lot2=lastlot;
     }
   if(Lot2 < MinLots) Lot2 = MinLots;
   if(Lot2 > MaxLots) Lot2 = MaxLots;
   lotcalc=lotcalc+" MinLots="+MinLots+" LOT="+NormalizeDouble(Lot2,lotdig);
   Print(lotcalc);
   return(NormalizeDouble(Lot2,lotdig));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                    ”даление 1 предварительно выбранной позиции   |
//+------------------------------------------------------------------+

void CPBS()
  {
   bool   fc;
   color  clClose;
   double ll,pa,pb,pp;
   int    err,it;
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   if(OrderType()==OP_BUY || OrderType()==OP_SELL)
     {
      for(it=1; it<=5; it++)
        {
         RefreshRates();
         pa=MarketInfo(OrderSymbol(), MODE_ASK);
         pb=MarketInfo(OrderSymbol(), MODE_BID);
         if(OrderType()==OP_BUY)
           {
            pp=pb;
              } else {
            pp=pa;
           }
         ll=OrderLots();
         fc=OrderClose(OrderTicket(), ll, pp, 1, clClose);
         if(fc)
           {
            break;
              } else {
            err=GetLastError();
            // ¬ывод сообщени€ об ошибке
            Print("Error(",err,") opening position: ",ErrorDescription(err),", try ",it);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|              ”даление позиций по рынку                           |
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//|  ѕараметры:                                                                |
//|    sy - наименование инструмента   ( ""  - любой символ,                   |
//|                                     NULL - текущий символ)                 |
//|    op - операци€                   ( -1  - люба€ позици€)                  |
//|    mn - MagicNumber                ( -1  - любой магик)                    |
//+----------------------------------------------------------------------------+

void CPD(string sy="",int op=-1,int mn=-1)
  {
   int i,k=OrdersTotal();
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   if(sy=="0") sy=Symbol();
   for(i=k-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderSymbol()==sy || sy=="") && (op<0 || OrderType()==op))
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
              {
               if(mn<0 || OrderMagicNumber()==mn) 
               if(SpreadMinimumToCloseLOSS==0||GetProfitOpenPosInPoint(sy,op,mn)<=0-SpreadMinimumToCloseLOSS*AverSpread){Print(" Tiket="+OrderTicket()+" Profit="+OrderProfit()+" AverSpread="+AverSpread);OrderSelect(i,SELECT_BY_POS,MODE_TRADES);CPBS();}
               if(SpreadMinimumToClosePROF==0||GetProfitOpenPosInPoint(sy,op,mn)>=SpreadMinimumToClosePROF*AverSpread){Print(" Tiket="+OrderTicket()+" Profit="+OrderProfit()+" AverSpread="+AverSpread);OrderSelect(i,SELECT_BY_POS,MODE_TRADES);CPBS();}
              }
           }
        }
     }
  }

  int GetProfitOpenPosInPoint(string sy="", int op=-1, int mn=-1) {
  double p;
  int    i, k=OrdersTotal(), pr=0;

  if (sy=="0") sy=Symbol();
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if ((OrderSymbol()==sy || sy=="") && (op<0 || OrderType()==op)) {
        if (mn<0 || OrderMagicNumber()==mn) {
          p=MarketInfo(OrderSymbol(), MODE_POINT);
          if (p==0) if (StringFind(OrderSymbol(), "JPY")<0) p=0.0001; else p=0.01;
          if (OrderType()==OP_BUY) {
            pr+=(MarketInfo(OrderSymbol(), MODE_BID)-OrderOpenPrice())/p;
          }
          if (OrderType()==OP_SELL) {
            pr+=(OrderOpenPrice()-MarketInfo(OrderSymbol(), MODE_ASK))/p;
          }
        }
      }
    }
  }
  return(pr);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SimpleTrailingSAR(string sy="",int op=-1,int mn=-1)
  {
   double po,pp;
   double SAR=iSAR(sy,0,step,maximum,0);
   int    i,k=OrdersTotal();
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   if(sy=="0") sy=Symbol();
   if(TrailingStop==0)TrailingStop=MarketInfo(Symbol(),MODE_STOPLEVEL);
   for(i=0;i<k;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderSymbol()==sy || sy=="") && (op<0 || OrderType()==op))
           {
            po=MarketInfo(OrderSymbol(),MODE_POINT);
            if(mn<0 || OrderMagicNumber()==mn)
              {
               if(OrderType()==OP_BUY)
                 {
                  pp=MarketInfo(OrderSymbol(),MODE_BID);
                  if(OrderStopLoss()<SAR)
                    {
                     ModifyOrder(-1,SAR,-1);
                    }
                 }
               if(OrderType()==OP_SELL)
                 {
                  pp=MarketInfo(OrderSymbol(),MODE_ASK);
                  if(OrderStopLoss()>SAR || OrderStopLoss()==0)
                    {
                     ModifyOrder(-1,SAR,-1);
                    }
                 }
              }
           }
        }
     }
  }
//+----------------------------------------------------------------------------+
//|  ќписание : —опровождение позиций простым тралом                           |
//+----------------------------------------------------------------------------+
//|  ѕараметры:                                                                |
//|    sy - наименование инструмента   ( ""  - любой символ,                   |
//|                                     NULL - текущий символ)                 |
//|    op - операци€                   ( -1  - люба€ позици€)                  |
//|    mn - MagicNumber                ( -1  - любой магик)                    |
//+----------------------------------------------------------------------------+
void SimpleTrailing(string sy="",int op=-1,int mn=-1)
  {
   double po,pp;
   int    i,k=OrdersTotal();
   string Autor=" јвтор функции дл€ шаблона : Ambrela0071@mail.ru";

   if(sy=="0") sy=Symbol();
   if(TrailingStop==0)TrailingStop=MarketInfo(Symbol(),MODE_STOPLEVEL);
   for(i=0;i<k;i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if((OrderSymbol()==sy || sy=="") && (op<0 || OrderType()==op))
           {
            po=MarketInfo(OrderSymbol(),MODE_POINT);
            if(mn<0 || OrderMagicNumber()==mn)
              {
               if(OrderType()==OP_BUY)
                 {
                  pp=MarketInfo(OrderSymbol(),MODE_BID);
                  if((!IfProfTrail && OrderProfit()>0) || pp-OrderOpenPrice()>TrailingStop*po)
                    {
                     if(OrderStopLoss()<pp-(TrailingStop+TrailingStep-1)*po)
                       {
                        ModifyOrder(-1,pp-TrailingStop*po,-1);
                       }
                    }
                 }
               if(OrderType()==OP_SELL)
                 {
                  pp=MarketInfo(OrderSymbol(),MODE_ASK);
                  if((!IfProfTrail && OrderProfit()>0) || OrderOpenPrice()-pp>TrailingStop*po)
                    {
                     if(OrderStopLoss()>pp+(TrailingStop+TrailingStep-1)*po || OrderStopLoss()==0)
                       {
                        ModifyOrder(-1,pp+TrailingStop*po,-1);
                       }
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Stamp()
  {
   ObjectCreate("Original",OBJ_LABEL,0,0,0);
   ObjectSetText("Original"," —делано при помощи шаблона : Ambrela0071@mail.ru ѕериод ="+DoubleToStr(TF,0),12,"Arial Bold",Chartreuse);
   ObjectSet("Original",OBJPROP_CORNER,0);
   ObjectSet("Original",OBJPROP_XDISTANCE,0);
   ObjectSet("Original",OBJPROP_YDISTANCE,10);

  }
//+------------------------------------------------------------------+

int isCloseLastPosByStop(string sy="",int op=-1,int mn=-1)
  {
   datetime t;
   double   ocp,osl;
   int      dg,i,j=-1,k=OrdersHistoryTotal();

   if(sy=="0") sy=Symbol();
   for(i=0; i<k; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderSymbol()==sy || sy=="")
           {
            if(OrderType()==OP_BUY || OrderType()==OP_SELL)
              {
               if(op<0 || OrderType()==op)
                 {
                  if(mn<0 || OrderMagicNumber()==mn)
                    {
                     if(t<OrderCloseTime())
                       {
                        t=OrderCloseTime();
                        j=i;
                       }
                    }
                 }
              }
           }
        }
     }
   if(OrderSelect(j,SELECT_BY_POS,MODE_HISTORY))
     {
      dg=MarketInfo(OrderSymbol(),MODE_DIGITS);
      if(dg==0) if(StringFind(OrderSymbol(),"JPY")<0) dg=4; else dg=2;
      ocp=NormalizeDouble(OrderClosePrice(), dg);
      osl=NormalizeDouble(OrderStopLoss(), dg);
      if(OrderProfit()<0) return(1);
      if(OrderProfit()==0) return(2);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string;
//----
   switch(error_code)
     {
      //---- codes returned from trade server
      case 0:
      case 1:   error_string="no error";                                                  break;
      case 2:   error_string="common error";                                              break;
      case 3:   error_string="invalid trade parameters";                                  break;
      case 4:   error_string="trade server is busy";                                      break;
      case 5:   error_string="old version of the client terminal";                        break;
      case 6:   error_string="no connection with trade server";                           break;
      case 7:   error_string="not enough rights";                                         break;
      case 8:   error_string="too frequent requests";                                     break;
      case 9:   error_string="malfunctional trade operation (never returned error)";      break;
      case 64:  error_string="account disabled";                                          break;
      case 65:  error_string="invalid account";                                           break;
      case 128: error_string="trade timeout";                                             break;
      case 129: error_string="invalid price";                                             break;
      case 130: error_string="invalid stops";                                             break;
      case 131: error_string="invalid trade volume";                                      break;
      case 132: error_string="market is closed";                                          break;
      case 133: error_string="trade is disabled";                                         break;
      case 134: error_string="not enough money";                                          break;
      case 135: error_string="price changed";                                             break;
      case 136: error_string="off quotes";                                                break;
      case 137: error_string="broker is busy (never returned error)";                     break;
      case 138: error_string="requote";                                                   break;
      case 139: error_string="order is locked";                                           break;
      case 140: error_string="long positions only allowed";                               break;
      case 141: error_string="too many requests";                                         break;
      case 145: error_string="modification denied because order too close to market";     break;
      case 146: error_string="trade context is busy";                                     break;
      case 147: error_string="expirations are denied by broker";                          break;
      case 148: error_string="amount of open and pending orders has reached the limit";   break;
      case 149: error_string="hedging is prohibited";                                     break;
      case 150: error_string="prohibited by FIFO rules";                                  break;
      //---- mql4 errors
      case 4000: error_string="no error (never generated code)";                          break;
      case 4001: error_string="wrong function pointer";                                   break;
      case 4002: error_string="array index is out of range";                              break;
      case 4003: error_string="no memory for function call stack";                        break;
      case 4004: error_string="recursive stack overflow";                                 break;
      case 4005: error_string="not enough stack for parameter";                           break;
      case 4006: error_string="no memory for parameter string";                           break;
      case 4007: error_string="no memory for temp string";                                break;
      case 4008: error_string="not initialized string";                                   break;
      case 4009: error_string="not initialized string in array";                          break;
      case 4010: error_string="no memory for array\' string";                             break;
      case 4011: error_string="too long string";                                          break;
      case 4012: error_string="remainder from zero divide";                               break;
      case 4013: error_string="zero divide";                                              break;
      case 4014: error_string="unknown command";                                          break;
      case 4015: error_string="wrong jump (never generated error)";                       break;
      case 4016: error_string="not initialized array";                                    break;
      case 4017: error_string="dll calls are not allowed";                                break;
      case 4018: error_string="cannot load library";                                      break;
      case 4019: error_string="cannot call function";                                     break;
      case 4020: error_string="expert function calls are not allowed";                    break;
      case 4021: error_string="not enough memory for temp string returned from function"; break;
      case 4022: error_string="system is busy (never generated error)";                   break;
      case 4050: error_string="invalid function parameters count";                        break;
      case 4051: error_string="invalid function parameter value";                         break;
      case 4052: error_string="string function internal error";                           break;
      case 4053: error_string="some array error";                                         break;
      case 4054: error_string="incorrect series array using";                             break;
      case 4055: error_string="custom indicator error";                                   break;
      case 4056: error_string="arrays are incompatible";                                  break;
      case 4057: error_string="global variables processing error";                        break;
      case 4058: error_string="global variable not found";                                break;
      case 4059: error_string="function is not allowed in testing mode";                  break;
      case 4060: error_string="function is not confirmed";                                break;
      case 4061: error_string="send mail error";                                          break;
      case 4062: error_string="string parameter expected";                                break;
      case 4063: error_string="integer parameter expected";                               break;
      case 4064: error_string="double parameter expected";                                break;
      case 4065: error_string="array as parameter expected";                              break;
      case 4066: error_string="requested history data in update state";                   break;
      case 4099: error_string="end of file";                                              break;
      case 4100: error_string="some file error";                                          break;
      case 4101: error_string="wrong file name";                                          break;
      case 4102: error_string="too many opened files";                                    break;
      case 4103: error_string="cannot open file";                                         break;
      case 4104: error_string="incompatible access to a file";                            break;
      case 4105: error_string="no order selected";                                        break;
      case 4106: error_string="unknown symbol";                                           break;
      case 4107: error_string="invalid price parameter for trade function";               break;
      case 4108: error_string="invalid ticket";                                           break;
      case 4109: error_string="trade is not allowed in the expert properties";            break;
      case 4110: error_string="longs are not allowed in the expert properties";           break;
      case 4111: error_string="shorts are not allowed in the expert properties";          break;
      case 4200: error_string="object is already exist";                                  break;
      case 4201: error_string="unknown object property";                                  break;
      case 4202: error_string="object is not exist";                                      break;
      case 4203: error_string="unknown object type";                                      break;
      case 4204: error_string="no object name";                                           break;
      case 4205: error_string="object coordinates error";                                 break;
      case 4206: error_string="no specified subwindow";                                   break;
      default:   error_string="unknown error";
     }
//----
   return(error_string);
  }

//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж
//жжжжжжжжжжжжжжжжжжж      ‘ункции закрыти€ по прибыли   жжжжжжжжжжжжжжжжжжжжжжжж
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж

double price;
int    ordertype;
bool   result,first;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void IMFO(string text="")
  {

   ObjectCreate("IMFO!!!",OBJ_LABEL,0,0,0);
   ObjectSetText("IMFO!!!",text,14,"Arial Bold",Red);
   ObjectSet("IMFO!!!",OBJPROP_CORNER,0);
   ObjectSet("IMFO!!!",OBJPROP_XDISTANCE,200);
   ObjectSet("IMFO!!!",OBJPROP_YDISTANCE,20);

  }

#include <WinUser32.mqh>


#import "user32.dll"
int GetAncestor(int hWnd,int gaFlags);
#import

#define  PUSKSTOP 33020
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void startdestroy(bool fals=true)
  {
   int hChart=WindowHandle(Symbol(),Period());
   int hMetaTrader=GetAncestor(hChart,2);
   if(fals==true)
     {
      if(!IsExpertEnabled())PostMessageA(hMetaTrader,WM_COMMAND,PUSKSTOP,0);  // пуск или остановка советника

     }
   if(fals==false)
     {
      if(IsExpertEnabled())PostMessageA(hMetaTrader,WM_COMMAND,PUSKSTOP,0);  // пуск или остановка советника

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int startCloseBlock3()
  {

   int OrderToClose=-1;
   int MagikToClose=Magic;
   string SymbolToClose=Symbol();

   double ask,bid,open,Prc,Prc2,point,buy_e,sell_e,Equity,_close;
   int Pips,buy_p,sell_p,flag=0;
   string com,mg;
   bool    magic=true;//если True то по магику,если False то все открытые
   string  sy;
//-------------------------------смотрим открытые----------------------------------------------------------

   for(int Q=0;Q<OrdersTotal();Q++)
     {
      if(OrderSelect(Q,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==SymbolToClose)
           {
            if(OrderMagicNumber()==Magic)
              {
               if(OrderType()==OP_SELL && (OrderToClose==-1 || OrderToClose==1))
                 {
                  point=MarketInfo(OrderSymbol(),MODE_POINT);
                  ask=MathRound(MarketInfo(OrderSymbol(),MODE_ASK)/point);
                  open=MathRound(OrderOpenPrice()/point);
                  sell_e+=OrderProfit()+OrderSwap();
                  sell_p+=(open-ask);
                 }
               if(OrderType()==OP_BUY && (OrderToClose==-1 || OrderToClose==0))
                 {
                  point=MarketInfo(OrderSymbol(),MODE_POINT);
                  bid=MathRound(MarketInfo(OrderSymbol(),MODE_BID)/point);
                  open=MathRound(OrderOpenPrice()/point);
                  buy_e+=OrderProfit()+OrderSwap();
                  buy_p+=(bid-open);
                 }
              }
            //-----------------------------------считаем--------------------------------------------------------------- 
            Pips=(buy_p+sell_p);
            Equity=(buy_e+sell_e);
            Prc=NormalizeDouble((Equity*100)/AccountEquity(),2);
            Prc2=NormalizeDouble((Equity*100)/AccountBalance(),2);
            //----------------------------------выбираем---------------------------------------------------------------
            switch(TypeofClose)
              {
               case 1: _close=Equity; com = "балансу"; break;
               case 2: _close=Pips; com = "пунктам"; break;
               case 3: _close=Prc; com = "%эквити"; break;
               case 4: _close=Prc2; com = "%баланс"; break;
               default: com="Ќ≈ ” ј«јЌќ"; break;
              }
            //-------------------- омментарии--------------------------------------------------------------------------- 

           }
     }
//---------------------------услови€ дл€ закрыти€--------------------------------------------------------------------- 
   if(_close>=prifitessss && CloseProfit){  flag=1; }
   if(TypeofClose==1||TypeofClose==2)if(_close<=lossss &&CloseLoss){  flag=2; }
   if(TypeofClose==3||TypeofClose==4)if(_close<=lossss &&CloseLoss){  flag=2; }
   IMFO("“екущее положение по закрытию"+DoubleToStr(_close,0));
//-----------------------------все позиции закрываем------------------------------------------------------------------
   if(flag==1)
     {
      CPD(SymbolToClose,OrderToClose,MagikToClose);

      //---------------------------все ордера удал€ем-----------------------------------------------------------------------
      DxO(SymbolToClose,OrderToClose,MagikToClose);
      if(!OFFAllEaAfterClosePROF)IMFO(" «акрытие произошло на уровне="+DoubleToStr(_close,2));
      if(OFFAllEaAfterClosePROF)IMFO(" «акрытие произошло на уровне="+DoubleToStr(_close,2)+" —оветники остановлены");
      if(OFFAllEaAfterClosePROF)startdestroy(false);
     }

   if(flag==2)
     {
      CPD(SymbolToClose,OrderToClose,MagikToClose);

      //---------------------------все ордера удал€ем-----------------------------------------------------------------------
      DxO(SymbolToClose,OrderToClose,MagikToClose);
      if(!OFFAllEaAfterCloseLOSS)IMFO(" «акрытие произошло на уровне="+DoubleToStr(_close,2));
      if(OFFAllEaAfterCloseLOSS)IMFO(" «акрытие произошло на уровне="+DoubleToStr(_close,2)+" —оветники остановлены");
      if(OFFAllEaAfterCloseLOSS)startdestroy(false);
     }

   return(0);
  }
//+------------------------------------------------------------------+
 // ==========================================================================================================================================================================================================
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// 
//                             ‘ ” Ќ   ÷ » я      ќпределени€ сигналов   
// 
// ∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆
// ==========================================================================================================================================================================================================
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int spread,stoplevel,freeze;
int tf=4;

double lh=0,ll=0;
bool trend;
double udat[100000][2];
int ucnt=0;
double ddat[100000][2];
int dcnt=0;
int tc,tl=0,th=0;
double koef[];
int plech=0;
int ttf;
bool work=true;
int tmp;
double vol=0;
double positive=0,negative=0,per,prsi=0;
int objs=0;
double nakl=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int deinit()

{

if(UninitializeReason()==2||UninitializeReason()==3 || UninitializeReason()==5)
GlobalVariableSet(DoubleToStr(IsTesting(),0)+Symbol()+DoubleToStr(Magic,0)+"TF",TF);
else 
GlobalVariableSet(DoubleToStr(IsTesting(),0)+Symbol()+DoubleToStr(Magic,0)+"TF",-1);
if(IsTesting())GlobalVariableDel(DoubleToStr(IsTesting(),0)+Symbol()+DoubleToStr(Magic,0)+"TF");

}
int init()
  {
//----
   if(!IsTesting()) WindowScreenShot(WindowExpertName()+"\\"+"START"+WindowExpertName()+Symbol()+Period()+TimeCurrent()+"_.gif",1024,768);


//----

//----
if(GlobalVariableGet(DoubleToStr(IsTesting(),0)+Symbol()+DoubleToStr(Magic,0)+"TF")==-1)TF=Period();
else TF=GlobalVariableGet(DoubleToStr(IsTesting(),0)+Symbol()+DoubleToStr(Magic,0)+"TF");
if(TF==0)TF=Period();
GlobalVariableSet(DoubleToStr(IsTesting(),0)+Symbol()+DoubleToStr(Magic,0)+"TF",TF);

   int highest=iHighest(NULL,TF,MODE_HIGH,period*3,0);
   int lowest=iLowest(NULL,TF,MODE_LOW,period*3,0);
   if(highest<lowest) {trend=false;}
   else {trend=true;}

   lh=iHigh(Symbol(),TF,highest); th=iTime(Symbol(),TF,highest); udat[ucnt][0]=iHigh(Symbol(),TF,highest);
   udat[ucnt][1]=iTime(Symbol(),TF,highest); udat[ucnt][2]=1; ucnt++;
   ll=iLow(Symbol(),TF,highest); tl=iTime(Symbol(),TF,highest); ddat[dcnt][0]=iLow(Symbol(),TF,lowest);
   ddat[dcnt][1]=iTime(Symbol(),TF,lowest); ddat[dcnt][2]=1; dcnt++;

//**************
   plech=calc_vol()*k;
//**************
   if(period<1) period=1;
   ArrayResize(koef,period);
   double val=2.0/period;
   double inc=2.0;
   for(int j=0;j<period;j++)
     {
      koef[j]=inc;
      inc-=val;
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_vol()
  {
   double res=0;
   for(int j=0;j<period;j++)
     {
      if(open_close)
        {
         if(!exp)
            res+=(iHigh(Symbol(),TF,j+1)-iLow(Symbol(),TF,j+1))/Point;
         else res+=((iHigh(Symbol(),TF,j+1)-iLow(Symbol(),TF,j+1))/Point)*koef[j];
        }
      else
        {
         if(!exp)
            res+=MathAbs(iOpen(Symbol(),TF,j+1)-iClose(Symbol(),TF,j+1))/Point;
         else res+=(MathAbs(iOpen(Symbol(),TF,j+1)-iClose(Symbol(),TF,j+1))/Point)*koef[j];
        }
     }
   res/=period;
   if(res==0) res=(iHigh(Symbol(),TF,2)-iLow(Symbol(),TF,2))/Point;
   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IndicatorSignal()
  {
   int Sig=0;

//----
   tc=TimeCurrent();
//***********************
   int tfbars=Bars;
   if(tmp!=tfbars)
     {
      plech=calc_vol()*k;
     }
   tmp=tfbars;
//************************
   if(Bid>lh) {lh=Bid;th=tc;}
   if(Bid<ll) {ll=Bid;tl=tc;}
//************************
   if(trend && Bid<lh-plech*Point)
     {
      trend=false;
      if(ucnt>99999) ucnt=0;
      udat[ucnt][0]=lh;
      udat[ucnt][1]=th;
      ucnt++;

      ll=Bid; tl=tc;
      Sig=2;
     }
   if(!trend && Bid>ll+plech*Point)
     {
      trend=true;
      if(dcnt>99999) dcnt=0;
      ddat[dcnt][0]=ll;
      ddat[dcnt][1]=tl;
      dcnt++;

      lh=Bid; th=tc;
      Sig=1;
     }
//*************************** 


// 1 - бай  2 - селл, 3 - закрытие бай, 4 - закрытие селл
   return(Sig);
  }
  
  
void vis()
{
string nnn=TimeToStr(tc)+" "+DoubleToStr(objs,0);
ObjectCreate(nnn,OBJ_TREND,0,ddat[dcnt-1][1],ddat[dcnt-1][0],udat[ucnt-1][1],udat[ucnt-1][0]);
ObjectSet(nnn,OBJPROP_RAY,false);
objs++;
}






bool   UseSound      = True;         // »спользовать звуковой сигнал
string NameFileSound = "expert.wav"; // Ќаименование звукового файла
bool «акрытиепоприбыли=false;
extern bool InfoVTSS=true;
bool «акрытиепоубытку=false;
string a="”быток должен быть с знаком минус";
int ArrayTicket[100];
double ArrayStopLoss[100];   
string ArrayType[100];
double ArraypriceOpen[100];
string ArraySymbol[100];
double ArrayProfit[100];
double ComaTicket;
string SymbolToClose2;
string commennte[100];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

  
 void SetHLineVirtual(color cl, string nm="", double p1=0, int st=0, int wd=1) {

  if (nm=="") nm=DoubleToStr(Time[0], 0);
  if (p1<=0) p1=Bid;
  if (ObjectFind(nm)<0) ObjectCreate(nm, OBJ_HLINE, 0, 0,0);
  ObjectSet(nm, OBJPROP_PRICE1, p1);
  ObjectSet(nm, OBJPROP_COLOR , cl);
  ObjectSet(nm, OBJPROP_STYLE , st);
  ObjectSet(nm, OBJPROP_WIDTH , wd);
}


int startVTSLOSS()
  {

//+------------------------------------------------------------------+
//|              ќчищаем массив от неиспользованных тикетов          |
//+------------------------------------------------------------------+
    for(int array4=0;array4<=100;array4++)
     {
       if (ArrayTicket[array4]!=0&&OrderSelect(ArrayTicket[array4],SELECT_BY_TICKET,MODE_HISTORY) && OrderCloseTime( ) !=0){
       ObjectDelete("BUY_"+DoubleToStr(ArrayTicket[array4],0)+"_TS");ObjectDelete("SELL_"+DoubleToStr(ArrayTicket[array4],0)+"_TS");ArrayTicket[array4]=0;ArrayStopLoss[array4]=0; } 

     }


//+------------------------------------------------------------------+
//|              «аполн€ем массив тикетами                           |
//+------------------------------------------------------------------+
 
  for(int array=0;array<=OrdersTotal();array++)
     {
     if(OrderSelect(array,SELECT_BY_POS,MODE_TRADES) && (OrderMagicNumber()==Magic) && (OrderSymbol()==Symbol())  )
     
       {
 
       if (ArrayTicket[array]==0)ArrayTicket[array]=OrderTicket();else for (int array2=0;array2<100;array2++)if (ArrayTicket[array]==0){ArrayTicket[array2]=OrderTicket();break;} 

       }
     }

//+------------------------------------------------------------------+
//|              ѕрисваиваем стоплосс тикетам                        |
//+------------------------------------------------------------------+

  for(int array3=0;array3<=OrdersTotal();array3++)
     {
     if(OrderSelect(ArrayTicket[array3],SELECT_BY_TICKET,MODE_TRADES))
     
       {
        if (
         ( (LOSSOrderOnly&&MarketInfo(OrderSymbol(),MODE_BID)<(OrderOpenPrice()-TrailingStopLOSS*MarketInfo(OrderSymbol(),MODE_POINT)))||!LOSSOrderOnly  ) && 
        OrderType()==OP_BUY&&ArrayTicket[array3]!=0 && (ArrayStopLoss[array3]>MarketInfo(OrderSymbol(),MODE_BID)+TrailingStopLOSS*MarketInfo(OrderSymbol(),MODE_POINT)+TrailingstepLOSS*MarketInfo(OrderSymbol(),MODE_POINT) ||ArrayStopLoss[array3]==0)  )
        {ArrayStopLoss[array3]=MarketInfo(OrderSymbol(),MODE_BID)+TrailingStopLOSS*MarketInfo(OrderSymbol(),MODE_POINT); 
         SetHLineVirtual(Blue,"BUY_"+DoubleToStr(OrderTicket(),0)+"_TS",ArrayStopLoss[array3],1);}



        if (
        ((LOSSOrderOnly&&(MarketInfo(OrderSymbol(),MODE_ASK)>OrderOpenPrice()+TrailingStopLOSS*MarketInfo(OrderSymbol(),MODE_POINT)))||!LOSSOrderOnly)&&
        OrderType()==OP_SELL&&ArrayTicket[array3]!=0 && (ArrayStopLoss[array3]<MarketInfo(OrderSymbol(),MODE_ASK)-TrailingStopLOSS*MarketInfo(OrderSymbol(),MODE_POINT)-TrailingstepLOSS*MarketInfo(OrderSymbol(),MODE_POINT) ||ArrayStopLoss[array3]==0)  )
        {ArrayStopLoss[array3]=MarketInfo(OrderSymbol(),MODE_ASK)-TrailingStopLOSS*MarketInfo(OrderSymbol(),MODE_POINT);  
         SetHLineVirtual(Red,"SELL_"+DoubleToStr(OrderTicket(),0)+"_TS",ArrayStopLoss[array3],1);}
       }
    
     }


      for(int cnt=0;cnt<=100;cnt++)
        {
           
           
           int tickk;
           
           
            if(OrderSelect(ArrayTicket[cnt],SELECT_BY_TICKET,MODE_TRADES) &&OrderType()==OP_BUY)
              {

              // Print("“икет"+OrderTicket() + " —топлосс:"+ArrayStopLoss[cnt ]+" ÷ена закрыти€:"+OrderClosePrice()+"  “икет" +ArrayTicket[cnt ] );
               if(MarketInfo(OrderSymbol(),MODE_BID)>=ArrayStopLoss[cnt ]&&ArrayStopLoss[cnt]!=0 && ArrayTicket[cnt]== OrderTicket()   )
               {
               tickk=OrderTicket();
               Print("«акрываем “икет:"+tickk+" ∆дите");
               ObjectDelete("BUY_"+DoubleToStr(tickk,0)+"_TS");
               CPBSTRAL(tickk);
               GetLastError();
               Print("“икет"+tickk+"buy stoploss="+((OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_BID))/MarketInfo(OrderSymbol(),MODE_POINT)) + " —топлосс:"+ArrayStopLoss[cnt]+" ÷ена закрыти€:"+OrderClosePrice());
              }
             }








            if(OrderSelect(ArrayTicket[cnt],SELECT_BY_TICKET,MODE_TRADES) &&OrderType()==OP_SELL)
              {
              // Print("“икет"+OrderTicket() + " —топлосс:"+ArrayStopLoss[cnt]+" ÷ена закрыти€:"+OrderClosePrice()+"  “икет" +ArrayTicket[cnt ] );
               if(       MarketInfo(OrderSymbol(),MODE_ASK)<=ArrayStopLoss[cnt]&&ArrayStopLoss[cnt]!=0    && ArrayTicket[cnt]== OrderTicket() )
               {
                              tickk=OrderTicket();

               Print("«акрываем “икет:"+tickk+" ∆дите");
               ObjectDelete("SELL_"+DoubleToStr(tickk,0)+"_TS");
               CPBSTRAL(tickk);

               GetLastError();
               Print("“икет"+tickk+"sell stoploss="+((MarketInfo(OrderSymbol(),MODE_ASK)-OrderOpenPrice())/MarketInfo(OrderSymbol(),MODE_POINT))+ " —топлосс:"+ArrayStopLoss[cnt ]+" ÷ена закрыти€:"+OrderClosePrice());
               }
              }

        }
    





   return(0);
  }
//+------------------------------------------------------------------+


  
  void CPBSTRAL(int ticket=0) 
  {
   bool   fc;
   color  clClose=Red;
   double ll,pa,pb,pp;
   int    err,it;

   if(OrderType()==OP_BUY || OrderType()==OP_SELL) 
     {
      for(it=1;it<=3;it++) 
        {
         if(!IsTesting() && (!IsExpertEnabled() || IsStopped())) break;
         while(!IsTradeAllowed()) Sleep(5000);
         RefreshRates();
         pa=MarketInfo(OrderSymbol(), MODE_ASK);
         pb=MarketInfo(OrderSymbol(), MODE_BID);
         if(OrderType()==OP_BUY) 
           {
            pp=pb;
              } else {
            pp=pa;
           }
         ll=OrderLots();
         fc=OrderClose(ticket, ll, pp, 1, clClose);
         if(fc) 
           {
             break;
              } else {
            err=GetLastError();
            if(err==146) while(IsTradeContextBusy()) Sleep(1000*11);
            Sleep(1000*5);
           }
        }
     }
  }



void infoVTS( )

  {
  //int ArrayType[100];
//double ArraypriceOpen[100];

string Com;
for (int i=0;i<100;i++)

  {
  OrderSelect(ArrayTicket[i],SELECT_BY_TICKET,MODE_TRADES);
  if (OrderType()==OP_BUY)ArrayType[i]="BUY";
  if (OrderType()==OP_SELL)ArrayType[i]="SELL";
  ArraypriceOpen[i]=OrderOpenPrice();
  ArraySymbol[i]=OrderSymbol();  
  ArrayProfit[i]=OrderProfit();
  }

for (int re=0;re<100;re++)
  {
commennte[re]=" “икет: "+ArrayTicket[re]+" —имвол:"+ArraySymbol[re]+" “ип:"+ArrayType[re]+" ÷ена открыти€:"+ArraypriceOpen[re]+" —топлосс: "+ArrayStopLoss[re]+" ѕрибыль: "+NormalizeDouble(ArrayProfit[re],2) +"\n";
  }

for (int y=0;y<=100;y++)

 {
 if (ArrayTicket[y]!=0)Com=Com+commennte[y];
 }
 Comment(Com);

//for (int z=0;z<=100;z++)  {Print("#"+z+" “икет: "+ArrayTicket[z]+" —имвол:"+ArraySymbol[z]+" “ип:"+ArrayType[z]+" ÷ена открыти€:"+ArraypriceOpen[z]+" —топлосс: "+ArrayStopLoss[z]+" ѕрибыль: "+NormalizeDouble(ArrayProfit[z],2) );}


  }