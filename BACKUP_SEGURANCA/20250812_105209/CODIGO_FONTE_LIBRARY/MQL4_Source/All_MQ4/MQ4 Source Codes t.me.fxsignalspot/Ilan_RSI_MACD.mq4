//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
#property copyright ""
#property link      ""
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
double Stoploss = 5000.0;          // Эти три параметра не работают
double TrailStart = 100.0;
double TrailStop = 100.0;
//extern double MATrendPeriod=26;
extern int UrovenNedokup = 30;
extern int UrovenPerekupl = 70;

//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
extern double LotExponent = 3.37;  // умножение лотов в серии по експоненте для вывода в безубыток. первый лот 0.1, серия: 0.15, 0.26, 0.43 ...
extern double Lots = 0.1;         // теперь можно и микролоты 0.01 при этом если стоит 0.1 то следующий лот в серии будет 0.16
extern int lotdecimal = 1;         // 2 - микролоты 0.01, 1 - мини лоты 0.1, 0 - нормальные лоты 1.0
extern double TakeProfit = 10.0;  // тейк профит
extern double PipStep = 30.0;     // шаг колена
extern int MagicNumber = 54321;    // магик
extern double slip = 30.0;          // проскальзывание
int MaxTrades = 10;                // максимально количество одновременно открытых ордеров
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
bool UseEquityStop = FALSE;// использовать ограничение по эквити
double TotalEquityRisk = 20.0; // сколько процентов от пероначального депо может просесть
bool UseTrailingStop = FALSE; // использовать трал
bool UseTimeOut = FALSE; // вышибать если ордера на рынке дольше чем
double MaxTradeOpenHours = 48.0; // 48 часов
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
double PriceTarget, StartEquity, BuyTarget, SellTarget ;
double AveragePrice, SellLimit, BuyLimit ;
double LastBuyPrice, LastSellPrice, Spread;
bool flag;
string EAName = "Ilan_RSI"; // в комент ордера лепим данный меседж
int timeprev = 0, expiration; 
int NumOfTrades = 0;
double iLots; // переменная для расчета лота 
int cnt = 0, total;
double Stopper = 0.0;
bool TradeNow = FALSE, LongTrade = FALSE, ShortTrade = FALSE;
int ticket;
bool NewOrdersPlaced = FALSE;
double AccountEquityHighAmt, PrevEquity;
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
int init() {
   Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point; // размер спреда в еденицах 
   return (0);
}

int deinit() {
   return (0);
}
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн
// 
// не знаю живеть этот зверь или нет но что не ломало расписать расписал. 
// програмирование на таком уровне это просто немного здравого смысла и начинаешь видеть 
//ху из почему и что это за мерзкогадские переменные.
// посвещается всем страждущим особливо Нигхт сподвигнувшего мну на этот не человечный 
// безсмысленный и беспощядный флуд.
// анютко читать не будет, а зря может чей-то и понял в простеших алгоритмах и что на глазок 
// только соль сыпать в суп ито хреново получится.
// сорь за граматику, лексику и синтаксис. 
//  тралл не расписывал абы в лом и им редко у иланов пользуют. 
// еще раз спасибо создателю советника абы на его потрохах я осваивал метаквотерское програмление. 


int start() {

   double MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   double MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   double SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   //double MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   //double MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);
   
       
   
   
   double PrevCl;
   double CurrCl;
   if (UseTrailingStop) TrailingAlls(TrailStart, TrailStop, AveragePrice); // Ежели включен трейлинг стоп то переход на функцию трейлить все 
    // передаем функции (стартТрейлинга, стопТрейла, текущаяЦена)
    
   if (UseTimeOut) { //если включена вышибалка по таймеру 
      if (TimeCurrent() >= expiration) { // текущее время больше ожидаемого
         CloseThisSymbolAll(); // процедуру рубить все на рабочей паре
         Print("Closed All due to TimeOut"); // расчепятать все удушенно по таймауту.
      }
   }
   
   if (timeprev == Time[0]) return (0); // если это не начало нового бара не работаем.
   timeprev = Time[0];                  // запомнили начало новый бар пришол
   
   double CurrentPairProfit = CalculateProfit(); // текущий профит по паре равен Функция ПодсчитатьПрофит
   if (UseEquityStop) {  // использовать стоп по Эквити 
   
      if (CurrentPairProfit < 0.0 && MathAbs(CurrentPairProfit) > TotalEquityRisk / 100.0 * AccountEquityHigh()) {
    // текущий профит по паре меньше нуля, пара в убытках и модуль профита больше общего рисковогоэквити /100*на максимальное акаунт эквити     
         CloseThisSymbolAll(); // пристрелить всех
         Print("Closed All due to Stop Out"); // отрапортовать все пристрелены по эквити
         NewOrdersPlaced = FALSE;  // нет установленных ордеров
      }
   }
   total = CountTrades(); // подсчитали сколько всего у нас ордеров
   if (total == 0) flag = FALSE; // если ордеров нет флажок ложь.
   
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) { // перебираем все ордера
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); // выбираем ордер
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue; // не наша пара или не наш магик вернулись к перебору
       if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {  //наша пара наш магикр
         if (OrderType() == OP_BUY) {  // наш ордер бай
            if(OrderTakeProfit()==0)NewOrdersPlaced = true;
            LongTrade = TRUE;           // нашли бай 
            ShortTrade = FALSE;          //селов нет
            break;                       //
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) { //наша пара наш магик
         if (OrderType() == OP_SELL) { //наш ордер селл
            if(OrderTakeProfit()==0)NewOrdersPlaced = true;
            LongTrade = FALSE; // нет баев
            ShortTrade = TRUE; // есть селл
            break;
         }
      }
   }
   if (total > 0 && total <= MaxTrades) { // есть ордера но их меньше или равно максимальному колству ордеров
      RefreshRates(); // обновить данные
      
      LastBuyPrice = FindLastBuyPrice(); //последняя покупная цена = функция НайтиПоследнююПлокупнуюЦену 
      LastSellPrice = FindLastSellPrice();// последняяПродажнаяЦена = функ. НайтиПоследнююПродажнуюЦену
      if (LongTrade && LastBuyPrice - Ask >= PipStep * Point) TradeNow = TRUE;
 // если разрешена покупка и цена последней покупки - текущая цена >= Пипстеп*поинт. 
 // если разрешено торговать и с момента последней сделки по баю удалились на пипстеп  то можно торговать    
      
      if (ShortTrade && Bid - LastSellPrice >= PipStep * Point) TradeNow = TRUE;
 
// если разрешено торговать и с момента последней сделки по селл удалились на пипстеп  то можно торговать        
   }
   
   if (total < 1) { // если нет рабочих ордеров то 
      ShortTrade = FALSE; //нет торговли по селл
      LongTrade = FALSE; // нет торговли по бай
      TradeNow = TRUE; // можем торговать
      StartEquity = AccountEquity(); 
 // запоминаем стартовое эквити так как ордеров нет максимально
   }
   
   if (TradeNow) { // разрешенно торговать 
   
      LastBuyPrice = FindLastBuyPrice(); //последняя покупная цена 
      LastSellPrice = FindLastSellPrice(); // последняя продажная цена 
      if (ShortTrade) { // если торгуем продажи 
         NumOfTrades = total; // количествоТорговли = тоталу
         iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);
        // иЛот= (стартовый лот * лотэкспонента в степени количествоТорговли)
         RefreshRates();
         ticket = OpenPendingOrder(1, iLots, Bid, slip, Ask, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, HotPink);
       // открываем новую торговлю
        if (ticket < 0) { // ежели неоткрылись то
            Print("Error: ", GetLastError()); // ошибка и перезапустить советника
            return (0);
         }
         LastSellPrice = FindLastSellPrice(); // ПоследняяПродажнаяЦена= функция (Найти последнюю продажную цену)
         TradeNow = FALSE; // торговать запрещено
         NewOrdersPlaced = TRUE; // новый ордер открыт = Правда
      } else {
         if (LongTrade) { // разрешены баи
            NumOfTrades = total; // количество ордеров = тоталу
            iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);
            // расчет лота для нового ордера мотри выше как расчитывается лот для селов 
            ticket = OpenPendingOrder(0, iLots, Ask, slip, Bid, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, Lime);
            // попробовали открыться
            if (ticket < 0) { // ежели не открылись 
               Print("Error: ", GetLastError()); // ошибка
               return (0); // перейти на старт 
            }
            LastBuyPrice = FindLastBuyPrice();// Последняя покупная цена = Функция (найти последнюю баевую цену)
            TradeNow = FALSE; // запрет торговли
            NewOrdersPlaced = TRUE; // новый ордер установлен 
         }
      }
   }
   if (TradeNow && total < 1) { // можно торговать и ордеров нет 
      PrevCl = iClose(Symbol(), 0, 2); // взяли пред пред последнее закрытие бара
      CurrCl = iClose(Symbol(), 0, 1); // взяли пред последнее закрытие бара 
      SellLimit = Bid;                  // селллимит = текущей продажной цене 
      BuyLimit = Ask;                      //байлимит = текущей покупной цене
      if (!ShortTrade && !LongTrade) {      // если нет ордеров баев и селов начинаем новую серию. (одновременно)
         NumOfTrades = total;                // количество торговли = тоталу
         
         iLots = NormalizeDouble(Lots * MathPow(LotExponent, NumOfTrades), lotdecimal);
         // расчитали лот 
         
   // если пред пред последне закрытие выше(больше) пред последнего закрытия
            if (MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious&& /*MaCurrent<MaPrevious&&*/iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > UrovenNedokup) { //больше  >
             // и рси часовой больше 30
               ticket = OpenPendingOrder(1, iLots, SellLimit, slip, SellLimit, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, HotPink);
               // открываем селл 
               if (ticket < 0) { // не открылись 
               
                  Print("Error: ", GetLastError()); // поматерились 
                  return (0); //перезапустили советник
               }
               LastBuyPrice = FindLastBuyPrice(); //последняя цена бая=функция(найт последнюю баевую цену)
               NewOrdersPlaced = TRUE; // новый ордер установлен
            }
        // иначе
            if (MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious && /*MaCurrent>MaPrevious&& */iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < UrovenPerekupl) { // меньше  <
              // проверить рси меньше 70
               ticket = OpenPendingOrder(0, iLots, BuyLimit, slip, BuyLimit, 0, 0, EAName + "-" + NumOfTrades, MagicNumber, 0, Lime);
               // открыться бай
               if (ticket < 0) {  // не открылись 
                  Print("Error: ", GetLastError()); // поматерились 
                  return (0); // перезапустили советник
               }
               LastSellPrice = FindLastSellPrice(); // последняя селовая  цена = функция (найти последнюю селовую цену)
               NewOrdersPlaced = TRUE; // новый ордер установлен 
            
         }
         if (ticket > 0) expiration = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours); //если ордер установлен 
         // то время жизни ордера = (сколько в часах ждать * 60(перевели в минуты) * 60 (перевели в часы) 
         TradeNow = FALSE; // запретили торговать
      }
   }
   total = CountTrades(); // тотал = функция (Сколько всего ордеров )
   AveragePrice = 0; // ожидаемая цена =0ж
   double Count = 0;  // Конт объявили и прировняли к нулю 
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) { // перебираем все ордера
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);  //смотрим что у нас за ордер  
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue; 
      // если не совпал символ ордера и не совпал магик вернулись на фор
       
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
       // совпал символ ордера и магик 
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
         // если ордер баевый или селовый 
            AveragePrice += OrderOpenPrice() * OrderLots();
           // сумируем аверейджцена = цена открытия ордера * лот ордера 
            Count += OrderLots();
            // в коунт сумируем сумму ордеров.
         }
      }
   }
   if (total > 0) AveragePrice = NormalizeDouble(AveragePrice / Count, Digits);
   // если есть наши ордера аверейдж цена = аверейдж цена / лотность. и того получили движение цены для всей серии 
   if (NewOrdersPlaced) { // если открыли новый ордер 
   
      for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) { // перебираем все ордера
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); // смотрим на ордер 
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue; // ордер не наш вернуться на перебор 
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) { // ордер наш 
            if (OrderType() == OP_BUY) { // ордер бай
               PriceTarget = AveragePrice + TakeProfit * Point; // вычислили куда ставить новый тейк профит 
               BuyTarget = PriceTarget; // запомнили где мы его купили 
               Stopper = AveragePrice - Stoploss * Point; // подсчитали стоп лось
               flag = TRUE; //флажок правдв 
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) { // аналогично для села находим куда ставить 
            if (OrderType() == OP_SELL) { // стоп лось и тейк профит.
               PriceTarget = AveragePrice - TakeProfit * Point;
               SellTarget = PriceTarget;
               Stopper = AveragePrice + Stoploss * Point;
               flag = TRUE;
            }
         }
      }
   }
   if (NewOrdersPlaced) { // был новый ордер 
      if (flag == TRUE) {//флажок надо менять ТП и СЛ
         for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) { // ищем свои ордера
            OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) OrderModify(OrderTicket(), AveragePrice, OrderStopLoss(), PriceTarget, 0, Yellow);
            // правим свои ордера  
            NewOrdersPlaced = FALSE; // сбросили флажок установка нового ордера 
         }
      }
   }
   return (0);
// перезапустили советник 
}
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн

int CountTrades() { // функция сколько наших ордеров торгуется
   int count = 0; // количество ордеров =0ж
   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) { // перебираем ордера 
      OrderSelect(trade, SELECT_BY_POS, MODE_TRADES); // смотрим ордер 
      
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      // не наш  ордер вернулись перебирать 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         // ордер наш 
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count++;
   // ордер баевый или селовый значит конт=конт+1          это потому что ордера могут быть и отложенные а нам надо только ордера серии
   }
   return (count);
}// вернули в тело советника количество торгуемых ордеров в сериии
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн

void CloseThisSymbolAll() { // прибить все свои  ордера

   for (int trade = OrdersTotal() - 1; trade >= 0; trade--) { // перебираем все ордера  
      OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);// смотрим что за ордер 
      if (OrderSymbol() == Symbol()) {// наша пара 
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) { // пара наша и магик наш 
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip, Blue); // пристрелить если ордер бай
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip, Red); // пристрелить если ордер селл
         }
         Sleep(1000); // поспать 1000 милисекунд 
      }
   }
}
// тут он вернется в основное тело советника 
//нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн

int OpenPendingOrder(int pType, double pLots, double pPrice, int pSlippage, double ad_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
// открытие нового ордера.  pType-какой ордер открыть  pLots- каким лотом, pSlippage-проскальзывание, ai_32 - стоп лось 
// ai_36 - профит. (чую что это декомпила  кто -то востанавливал именна переменных, а тут прозевал, a_comment_40 - комент к ордеру
// a_magic_48- магик для нашего ордера, a_datetime_52-дата для отложеника когда помрет, a_color_56-цвет стрелочки открытия ордера
   int l_ticket_60 = 0; 
   int l_error_64 = 0;
   int l_count_68 = 0;
   int li_72 = 100;
   switch (pType) { //смотрим тип ордеа 
   case 2: //ежели 2 открываем байлимитник 
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) { // пробуем 100 раз 
         l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, pLots, pPrice, pSlippage, StopLong(ad_24, ai_32), TakeLong(pPrice, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         // открываем
         l_error_64 = GetLastError();
         // смотрим ошибки 
         if (l_error_64 == 0/* NO_ERROR */) break;
         // ошибок нет вывались на конец функции открытия 
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         // если ошибка естьи она не ( сервер занят, брокер занят, поток занят,не правильные котировки) . тоже вывались на конец 
         Sleep(1000);
         //вздремнули и пошли открывать по новой ошибка не по поводу перегружености 
      }
      break;
   case 4: // открываем байстоп
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, pLots, pPrice, pSlippage, StopLong(ad_24, ai_32), TakeLong(pPrice, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0: // открываем бай
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, pLots, Ask, pSlippage, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3: // селллимитник
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, pLots, pPrice, pSlippage, StopShort(ad_24, ai_32), TakeShort(pPrice, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5: // селлстоп
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, pLots, pPrice, pSlippage, StopShort(ad_24, ai_32), TakeShort(pPrice, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1: //селл
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, pLots, Bid, pSlippage, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60);
// вернули номер тикета в основное тело советника.
// ошибка не возвращает нифига. 
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

double CalculateProfit() {//счет профита
   double ld_ret_0 = 0;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) { // перебор всех ордеров 
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES); // смотрим че за ордер 
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue; //у ордера не наша пара или не наш магик вернуться на перебор всех ордеров  
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) // пара наша И наш магик  
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit(); // если ордер баевый или селовый то сумируем профит
   }

   return (ld_ret_0); // вернули профит взад.
}

void TrailingAlls(int pType, int ai_4, double a_price_8) {
   int l_ticket_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
               if (OrderType() == OP_BUY) {
                  l_ticket_16 = NormalizeDouble((Bid - a_price_8) / Point, 0);
                  if (l_ticket_16 < pType) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Bid - ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 > l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  l_ticket_16 = NormalizeDouble((a_price_8 - Ask) / Point, 0);
                  if (l_ticket_16 < pType) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Ask + ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 < l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh() { // максимальное эквити акаунта
   if (CountTrades() == 0) AccountEquityHighAmt = AccountEquity(); // ежели торговли нет  то максэквитиакаунта = AccountEquity(); 
   if (AccountEquityHighAmt < PrevEquity) AccountEquityHighAmt = PrevEquity; // если максаквунтэквити меньше преведущее эквити то максакаунтэквити = преведущему
   else AccountEquityHighAmt = AccountEquity();
// иначе максакаунтэквити = эквити акаунта 

   PrevEquity = AccountEquity(); // преведущее эквити = AccountEquity(); 
   return (AccountEquityHighAmt); // вернуть максимальное эквити акаунта 
}

double FindLastBuyPrice() {// найти последнюю цену покупки
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {// перебираем все ордера 
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);//смотрим шо за ордер 
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;// не наш ордер возврат на перебор 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {// ордер наш и он байный
         l_ticket_24 = OrderTicket();// запомнили тикет ордера
         if (l_ticket_24 > l_ticket_20) {// если новый тикет ордера больше старого номера тикета ордера то
            l_ord_open_price_8 = OrderOpenPrice(); // запомнили цену ордера
            ld_unused_0 = l_ord_open_price_8;// нафига не понятно ? :(
            l_ticket_20 = l_ticket_24;// старый номер = новому ордеру 
             // если найдется еще новее то еще раз то запомним новую цену открытия и новый тикет
         }
      }
   }
   return (l_ord_open_price_8);// вернули взад последнюю цену открытия 
}

double FindLastSellPrice() { // найти последнюю цену продажи
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) { // перебираем все ордера 
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES); //смотрим шо за ордер 
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue; // не наш ордер возврат на перебор 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) { // ордер наш и он продажный
         l_ticket_24 = OrderTicket(); // запомнили тикет ордера
         if (l_ticket_24 > l_ticket_20) { // если новый тикет ордера больше старого номера тикета ордера то
            l_ord_open_price_8 = OrderOpenPrice(); // запомнили цену ордера
            ld_unused_0 = l_ord_open_price_8; // нафига не понятно ? :(
            l_ticket_20 = l_ticket_24;// старый номер = новому ордеру 
            // если найдется еще новее то еще раз то запомним новую цену открытия и новый тикет
         }
      }
   }
   return (l_ord_open_price_8); // вернули взад последнюю цену открытия 
}