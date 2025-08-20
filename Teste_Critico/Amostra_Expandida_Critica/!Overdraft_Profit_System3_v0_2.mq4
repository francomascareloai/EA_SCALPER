//+------------------------------------------------------------------+
//|                                          Overdraft_Profit_System |
//|          Copyright © 2014 Сергей Королевский ambrela0071@mail.ru |
//|   programming & support - Сергей Королевский ambrela0071@mail.ru |
//| 15.11.2014                                                       |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014  Сергей Королевский"
#property link      "ambrela0071@mail.ru"
//Эксперт предоставлен для ознакомления работы на форекс рынке, код открытый, что позволит вам модернизировать стратегию, и
//сделать под себя, оптимизировать под рынок и зарабатывать.
//Предлагаю доверительное управление вашими средствами на Forex:

//Минимальный депозит 20k - кредитное плечо лучше всего 1/300 и выше.
//Центовый счёт на InstaForex 1000$ - кредитное плечо 1/300 и выше.
//RoboForex центовые счета Pro.
//Желательно брокеры с пятизначным котированием. 
//Пример котировки: (1.24135) - т.е. пять знаков после точки.
//Можно использовать и на других брокерах:
//Alpari; FXOpen; AdmiralMarkets, Roboforex и другие.....
//Ниже предоставлена информация о счёте брокерской компании RVD.
//Счёт ECN, (плавающий спред).


//________________________________________
 
//Информация о счёте, для просмотра в режиме реального времени:
//Номер счёта: 50767
//Инвесторский пароль: Investor2015
//IP: 5.9.113.233:443
//________________________________________
//Внимание! Такие суммы взяты не с потолка, а с агрессивного графика 2008г. Где были супер тренды. 

//Условия распределения прибыльности:

//________________________________________
//Долларовые счета:
//Для долларовых депозитов приём в доверительное управление от 20k кредитное плечо 1/300 и выше.
//Прибыль делится 50/50
//Если же сумма депозита 40k и более:
//Прибыль делится 35% от заработка трейдеру управляющему, а 65% в пользу инвестора.
//Если же сумма депозита 100k и более:
//Прибыль делится 30% от заработка трейдеру управляющему, а 70% в пользу инвестора.

//________________________________________



//Центовые счета:

//Для всех центовых счетов от 1000$ кредитное плечо 1/300 и выше.
//Прибыль всегда делится 50/50.
//Есть исключение:
//Если у Вас центовых счетов более 5-ти, тогда прибыль делится так:
//40% управляющему трейдеру, а 60% в пользу инвестора.
//Также можно взять в управление и 500$ центового счёта, если Вы при необходимости сможете долиться в депозит.


//________________________________________
//Уведомление о рисках:
//Сколько нужно денег, чтобы начать инвестировать?
//Многих новичков интересует вопрос о том, каковы в доверительном управлении счетом Forex минимальные вложения?
//Прелесть ПАММ-инвестирования в том, что суммы инвестиций могут быть намного меньше, чем в банке или, например, на рынке акций. Разные брокеры предлагают разные условия, но можно найти таких, которые попросят вложить на Forex в доверительное управление от 10 долларов - такая сумма найдется у любого человека.
//Другое дело - если инвестор изначально рассчитывает на постоянную ощутимую прибыль. Естественно, в этом случае ставки должны быть выше. Доход будет пропорционален сумме, вложенной в доверительные ПАММ счета на форекс. И риски тоже.
//Сколько можно заработать?
//При инвестировании и использовании услуги доверительного управления деньгами на рынке Forex доходность за год может составлять 100% и более.
//Основные факторы, от которых будет зависеть уровень доходов:
//1	вложенная сумма;
//2	тактика работы управляющего: консервативная или агрессивная;
//3	успешность торговли в конкретном месяце.
//При понимании основных правил инвестирования доверительное управление на форекс 100% может приносить без проблем.
//Доверительное управление на форекс без рисков: возможно ли?
//Если Вы решили заниматься инвестированием, то Вам стоит знать о том, что инвестиций без рисков в принципе не существует. В сторону доверительного управления на Форекс критика от тех, кто вкладывал и разорился, всегда была, есть и будет. Да, инвестор всегда рискует. Основные риски связаны с тремя моментами:
//1	возможность того, что управляющий уйдет в затяжную сильную просадку, потеряв все деньги, свои и инвестора;
//2	брокерская компания может оказаться хорошо организованным хайпом, который уже очень скоро "лопнет";
//3	брокер может оказаться не совсем добросовестным, либо у него возникнут проблемы, в результате которых он окажется банкротом и лишит денег инвесторов. К сожалению, доверительное управление все еще никак не регулируется российским законодательством.
//Не все отзывы о доверительном управлении на Форекс положительны. Но в целом можно говорить о том, что ПАММ-инвестирование - хороший источник пассивного дохода.
//В то же время, в Форекс при доверительном управлении гарантированный доход Вам, конечно же, никто обещать не станет. Это не регулярная зарплата, которую работодатель исправно выплачивает до 15 числа.
//Поэтому, перед тем как принимать решение "дам денег в доверительное управление Форекс", нужно понимать, готовы ли Вы брать на себя определенные риски.
//Надеемся, что теперь, когда Вам понятно, что такое доверительное управление на Forex, Вы сможете принять для себя осознанное решение, стоит ли этим заниматься.


//Контакты:
//E-mail: Ambrela0071@yandex.ru
//Skype: OverdraftScalpSystem
//QIP: 444048899

#property strict

#include <stdlib.mqh>

#define OP_BALANCE	6
#define OP_MARKET		8
#define OP_ALL			-1

int Magic=1234;/*Magic*/ // магик ордеров данного ЕА
input bool bMarketExec=true;/*bMarketExec*/ // у брокера на символе маркет-исполнение
input int Slip=0;/*Slip*/ // проскальзывание при рыночном исполнении
input string inf1="// ордера";
input bool bRevers=true;/*bRevers*/ // true -Открывать реальные ордера противоположно виртуала / false-в том же направлении
input int OpenMode=1;/*OpenMode*/ // метод входа в рынок. 
											//	=0 то по wlxFractals фракталам, 
											//	=1 то вход по Acceleration. 
											//	=2 то вход по волатильности.
											//	=3 то вход с начало по OpenMode=1 после закрытия, вход по OpenMode=2.
											//	=4 то вход с начало OpenMode =0 после закрытия OpenMode =1 после закрытия OpenMode =2.     

input double Lot=0.1;/*Lot*/ // лот ордера. если =0, то используем ММ
input double MM=2;/*MM*/ //процент от баланса для лота.
input double Acceleration=1.5;/*Acceleration*/ // минимальная скорость цены
input int BarVolatile=24;/*BarVolatile*/ // число баров для расчёта волатильности
input double kVolatile=0.0;/*kVolatile*/ //множитель волатильности 
input double LotKoef=2;/*LotKoef*/ // множитель для следующего лота после убытка, если =0, то отключен
input int LotKoefStart=0;/*LotKoefStart*/ // число убыточных ордеров, после которого начинаем множить лот на LotKoef
input double VDeposit=5000;/*VDeposit*/ // размер пополнения вирт.баланса
input int nDay=14;/*nDay*/ //  число последних дней для расчета среднего хода фракталов.
input int SpreadMode=0;/*SpreadMode*/ // метод компенсации спреда 0/1/2/3
input int FixSpread=5;/*FixSpread*/ // размер фиксированной компенсации спреда для SpreadMode=3
input int AvgSpreadCount=20;/*AvgSpreadCount*/   // количество последних значений спреда для вычисления среднего спреда
input double AvgSpreadKoef=2;/*AvgSpreadKoef*/  //  множитель для спреда компенсации
input int CloseMode=2;/*CloseMode*/ // метод закрытия 
												// =0 то закрытие по расчитанному СЛ/ТП,
												// =1 то закрытие по заданным SL/TP
												// =2 то размер СЛ/ТП = Размер волатильности * SLVolatile (волатильность вычисляется аналогично как для открытия)
												// =3 то рассчитываем по CloseMode=0,1 - но выставляем стопы на тот, который ближайший.
												// =4 то рассчитываем по CloseMode=0,1,2 - но выставляем стопы на тот, который ближайший.
input int TP=60;/*TP*/ // размер тейкпрофита при CloseMode=2. Если =0, то не ставим
input int SL=60;/*SL*/ // размер стоплоса при CloseMode=2. Если =0, то не ставим
input double StopVolatile=2;/*StopVolatile*/ // коэффициент для вычисления стопов по волатильности
input bool bTralSL=true;/*bTralSL*/ // используем трал по SL
input bool bVTralTP=true;/*bVTralTP*/ // =true - включение трала тейкпрофита вирт.ордера по ProcentProfit/CloseProcentProfit
input double ProcentProfit=80;/*ProcentProfit*/ // процент размера тейкпрофита для трала стоплоса в профите, если =0, то трал выключен.
input double CloseProcentProfit=30;/*CloseProcentProfit*/ // процент для размера стоплоса при трале, если =0, то трал выключен.
input string inf2="// индикатор";
input string IndName="wlxFractals";
input int Equals = 20;/*Equals*/ // максимальное число равных вершин слева и справа для проверяемого фрактала
input int nLeftUp = 20;/*nLeftUp*/  // проверяемое число баров слева для фрактала вверх
input int nRightUp = 20;/*nRightUp*/ // проверяемое число баров справа для фрактала вверх
input int nLeftDown = 20;/*nLeftDown*/ // проверяемое число баров слева для фрактала вниз
input int nRightDown = 20;/*nRightDown*/ // // проверяемое число баров справа для фрактала вниз
input string inf3="// инфо";
input bool bVirtInfo=true;/*bVirtInfo*/ // показывать на чарте инфо панель вирт.ордеров.
input bool bRealInfo=true;/*bRealInfo*/ // показывать на чарте инфо панель реал.ордеров.
input bool bSpreadInfo=true;/*bSpreadInfo*/ // показывать на чарте инфо панель про спред
input bool bShowComment=true;/*bShowComment*/ // показывать инфу в коменте на чарте
input bool bShowVOrder=true;/*bShowVOrder*/ // показывать виртуальные ордера на чарте

// сервисные пермененные
string sID; // ID EA для глобальных переменных
bool bTesting; // флаг для первого старта
// инфо про валюту
double FreezLvl, StopLvl, Spread, Pnt, _Pnt, _Bid, _Ask, LotStep, LotSize, MaxLot, MinLot, TickSize, TickVal, ProfitCalcMode; int _Digit;
string g_inf;
double spread[]; int is=0;
double pBid=0; datetime fdtBid=0; int nBid=0; // для Acceleration
double pHi=0, pLo=0; // для Volatile
//------------------------------------------------------------------ init
int OnInit()
{
	ArrayResize(spread, fmax(AvgSpreadCount,1)); is=0; ArrayInitialize(spread, 0);
	bTesting=true;
	pBid=0; fdtBid=0; nBid=0; // для Acceleration
	pHi=0; pLo=0; // для Volatile
	
	return(INIT_SUCCEEDED);
}
//------------------------------------------------------------------ deinit
void OnDeinit(const int reason)
{
	if (IsTesting() || IsOptimization()) GlobalVariablesDeleteAll(sID);
	ObjectsDeleteAll2(0, -1, sID); // удалили объекты
}
//------------------------------------------------------------------ start
void OnTick()
{
	string smb=Symbol();
	int tf=Period();
	sID=smb+ITS(IsDemo())+ITS(IsTesting())+ITS(IsOptimization())+"."+ITS(Magic);
	if (bTesting && (IsTesting() || IsOptimization())) { GlobalVariablesDeleteAll(sID); bTesting=false; }
	
	g_inf="";
	INF(WindowExpertName()+"  "+TTS(TimeCurrent()), true);
	if (!IsConnected()) { INF("- connected ERROR!"); Print("- connected ERROR!"); } else INF("+ connected  OK");
	if (!IsTradeAllowed()) { INF("- trade NOT allowed!"); return; } else INF("+ trade allowed  OK");
	if (IsTradeContextBusy()) INF("- trade context BUSY!"); else INF("+ trade context ready  OK");

	AddSpread(); // суммируем в средний спред
	CheckAcceleration(); // контролируем скорость
	CheckVolatile(); // контролируем волатильность
	
	main(Magic, smb, tf);
	INF("==============================", true);
	
	if (bShowComment) Comment(g_inf);
}
//------------------------------------------------------------------ main
void main(int SysID, string smb, int tf)
{	
	RefreshParam(smb); 
	OpenVPos(SysID, smb, tf); // А. Открытие виртуального ордера
	CloseVPos(SysID, smb, tf); // Б. Закрытие виртуального ордера
	TralVPos(SysID, smb); // Е. Трал тейкпрофита вирт.ордера
	OpenRPos(SysID, smb, tf); // В. Открытие реального ордера
	CloseRPos(SysID, smb, tf); // Г. Закрытие реального ордера
	TralRPos(SysID, smb); // Д. Перемещение стоплоса реального ордера 
	int y=20;
	VirtInfo(SysID, smb, tf, y);
	RealInfo(SysID, smb, y);
	SpreadInfo(SysID, smb, y);
}
//---------------------------------------------------------------   CheckOpenSignal
int CheckOpenSignal(string smb, int tf, int &i)
{
	INF("+Проверяем сигнал открытия виртуального ордера", true); 
	int n=iBars(smb, tf);
	for (i=0; i<n; i++)
	{
		double f=iCustom(smb, tf, IndName, Equals, nLeftUp, nRightUp, nLeftDown, nRightDown, 0, i); if (f>0 && f!=EMPTY_VALUE) return(OP_BUY); // Buy: если последний фрактал wlxFractals  синий
		f=iCustom(smb, tf, IndName, Equals, nLeftUp, nRightUp, nLeftDown, nRightDown, 1, i); if (f>0 && f!=EMPTY_VALUE) return(OP_SELL); // Sell: если последний фрактал wlxFractals  красный 
	}
	return(-1);
}
//---------------------------------------------------------------   CheckOpenSignal
double CountStopSize(int dir, string smb, int tf)
{
	datetime dt=iTime(smb, PERIOD_H1, nDay*24-1); // время окончания поиска
	INF("+Расчет среднего хода цены за "+ITS(nDay)+" дней (до "+TTS(dt)+")", true); 
	int i=0;
	double avg=0; int n=0;
	while (iTime(smb, tf, i)>dt) // ищем в последних nDay
	{
		double f1=GetNextFrac(ADIR(dir), smb, tf, i); if (f1<=0) break; i++;
		double f2=GetNextFrac(dir, smb, tf, i); if (f2<=0) break; i++;
		if (iTime(smb, tf, i)<dt) break;
		avg+=fabs(f1-f2); n++;
	}
	INF("число диапазонов="+ITS(n)+" avg="+DTS(avg));
	if (n<=0) return(0); // если не нашли ни одного промежутка, то ошибка
	return(avg/n); // иначе вернули среднее
}
//------------------------------------------------------------------ GetNextFrac
double GetNextFrac(int dir, string smb, int tf, int &b)
{
	int n=iBars(smb, tf);
	for (int i=b; i<n; i++) { double f=iCustom(smb, tf, IndName, Equals, nLeftUp, nRightUp, nLeftDown, nRightDown, dir, i); if (f>0 && f!=EMPTY_VALUE) { b=i; return(f); } }
	return(-1);
}
//------------------------------------------------------------------ OpenVPos
void OpenVPos(int SysID, string smb, int tf)
{
	INF(""); 
	INF("+А. Открытие виртуального ордера", true); 
	if (SpreadMode==2 && is<AvgSpreadCount-1) { INF("Ждем накопления "+ITS(AvgSpreadCount)+" тиков для спреда"); return; }
	if (CountOrders(-1, SysID, smb)!=0) { INF("Реальные ордера еще открыты. ждем закрытия"); return; }
	
	int nmode=-1, ib=-1;
	int dir=GetOpenModeDir(smb, tf, OpenMode, nmode, ib); if (dir<0) { INF("Направление открытия вирт.ордера не определено"); return; }
	
	// ищем незакрытый ордер
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	bool b=false; string sid=""; int id=0;
	for (int i=0; i<n; i++)
	{
		int vdir=(int)GetGV(name[i]); if (vdir!=OP_BUY && vdir!=OP_SELL) continue;
		sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		id=STI(sid); sid=sID+"VO."+sid;
		if (CheckGV(sid+".cl")) continue;
		if (bShowVOrder) { DrawOrder(sid, id, (int)GetGV(name[i]), GetGV(sid+".op"), 0, 0); DrawDeal(sid, id, (int)GetGV(name[i]), Lot, GetGV(sid+".op"), (datetime)GetGV(sid+".dop"), 0, 0, 0, 0); }
		b=true; break; 
	}	//
	if (b) { INF("Ждем закрытие V ордера #"+ITS(id)); return; }
	Print("Найдено "+ITS(n)+" вирт.ордеров в истории. Открытых нет.");
	if (ib>0) Print("На баре "+TTS(iTime(smb, tf, ib))+" еще не открывали.");
	
	double op=NPR(dir);	
	
	id=int(GetTickCount()+MathRand()); // "тикет" виртуального ордера
	sid=sID+"VO."+ITS(id);
	SetGV(sID+"VOrder."+ITS(id), dir); // тип
	double nlot=Lot; if (Lot<=0) nlot=(AccountBalance()/1000.0)*MM/100.0; nlot=NL(nlot); // определяем и нормализуем лот
	double lot=NL(nlot);
	if (LotKoef!=0) // анализируем предыдущий профит
	{
		double plot=GetGV(sID+"Lot"); int No=(int)GetGV(sID+"N");
		double lpip=0; int lid=VLastOrder(lpip);
		Print("Предыдушие пипсы вирт.ордера="+DTS(lpip/(Pnt*_Pnt),0)+" начальный лот="+DTS(plot,2)+"  длина цепочки="+ITS(No));
		// если профит, то сбросили лот на новый, иначе новый лот увеличили в LotKoef раз и увеличили счетчик убытка
		if (lpip>=0) { SetGV(sID+"Lot", nlot); SetGV(sID+"N", 0); }
		else { if (plot>0) lot=NL(plot*MathPow(LotKoef, fmax(No+1-LotKoefStart,0))); SetGV(sID+"N", No+1); }
		double vbal=CountVBalance();
		if (vbal-(AccountBalance()-AccountFreeMarginCheck(smb, dir, lot))<=0)
		{
			Print("Вирт.баланс="+DTS(vbal,2)+", сбрасываем лот на начальный и пополняем баланс на VDeposit="+DTS(VDeposit,2));
			int did=int(GetTickCount()+MathRand()); // "тикет" нового виртуального пополнения
			SetGV(sID+"VOrder."+ITS(did), OP_BALANCE); SetGV(sID+"VO."+ITS(did)+".prof", VDeposit); // пополнили баланс
			SetGV(sID+"Lot", nlot); SetGV(sID+"N", 0); lot=nlot;
		}
	}
	// открыли вирт.ордер
	MqlDateTime md; datetime dop=TimeCurrent(md); // текущее время
	SetGV(sid+".op", op); SetGV(sid+".dop", dop); SetGV(sid+".lot", lot); DelGV(sid+".cl"); // сохранили параметры ордера
	string txt="Open V "+smb+" "+OTS(dir)+"#"+ITS(id)+" | op="+DTS(op)+" OpenMode="+ITS(OpenMode);
	INF(txt); Print("+"+txt);
	SetGV(sID+"Time", iTime(smb, tf, ib)); Print("Сохранили время фрактала сигнала "+TTS(iTime(smb, tf, ib)));
	SetGV(sID+"VLast", id); // запомнили тикет и метод открытия
	SetGV(sID+"Mode", nmode);
	pLo=0; pHi=0; // сбросили волатильность
	if (bShowVOrder) { DrawOrder(sid, id, dir, op, 0, 0); DrawDeal(sid, id, dir, Lot, op, dop, 0, 0, 0, 0); }
}
//------------------------------------------------------------------ LastOrder
int GetOpenModeDir(string smb, int tf, int mode, int &nmode, int &ib)
{
	INF("+OpenMode="+ITS(OpenMode));
	if (mode==0)
	{
		int dir=CheckOpenSignal(smb, tf, ib); if (dir<0) { INF("-ждем сигнала открытия..."); return(-1); }
		if (CheckGV(sID+"Time")) if (GetGV(sID+"Time")>=iTime(smb, tf, ib)) { INF("на этом сигнале уже открывали ордер"); return(-1); }
		return(dir);
	}
	MqlDateTime md; datetime dop=TimeCurrent(md); // текущее время
	if (mode==1)
	{
		double a=0; if (dop-fdtBid>0) a=(nBid*1.0)/(dop-fdtBid);
		if (fabs(a)>=Acceleration) return(a>0?OP_BUY:OP_SELL);
		else { INF("скорость="+DTS(a)+" < "+DTS(Acceleration,2)+" | tick="+ITS(nBid)+"  pBid="+DTS(pBid)+" Bid="+DTS(_Bid)+" sec="+ITS(dop-fdtBid)); return(-1); }
	}
	if (mode==2)
	{
		double v=CountVolatile(smb, tf)*kVolatile;
		if (_Bid>pLo+v && pLo>0) return(OP_BUY);
		if (_Bid<pHi-v && pHi>0) return(OP_SELL);
		INF("Волатильность*k "+DTS(v/(Pnt*_Pnt),0)+" в диапазоне pHi="+DTS(pHi)+" / pLo="+DTS(pLo)+" / Bid="+DTS(_Bid)); return(-1);
	}
	
	int pmode=CheckGV(sID+"Mode")?(int)GetGV(sID+"Mode"):0;	
	if (mode==3)
	{
		nmode=2; 
		if (pmode!=2) return(GetOpenModeDir(smb, tf, 1, nmode, ib)); else return(GetOpenModeDir(smb, tf, 2, nmode, ib)); 
	}
	if (mode==4)
	{
		nmode=2; 
		if (pmode!=2) { if (pmode!=1) { nmode=1; return(GetOpenModeDir(smb, tf, 0, nmode, ib)); } else { nmode=2; return(GetOpenModeDir(smb, tf, 1, nmode, ib)); } }
		else return(GetOpenModeDir(smb, tf, 2, nmode, ib)); 
	}
	return(-1);
}
//------------------------------------------------------------------ LastOrder
int VLastOrder(double &pip)
{
	if (!CheckGV(sID+"VLast")) return(-1);
	int id=(int)GetGV(sID+"VLast");
	string sid=sID+"VO."+ITS(id);
	int dir=(int)GetGV(sID+"VOrder."+ITS(id));
	double op=GetGV(sid+".op"), cl=GetGV(sid+".cl");
	if (cl>0) pip=(cl-op)*SD(dir);
	return(id);
}
//------------------------------------------------------------------ CloseVPos
void CloseVPos(int SysID, string smb, int tf)
{
	INF(""); 
	INF("+Б. Закрытие виртуального ордера", true);
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	MqlDateTime md; datetime dcl=TimeCurrent(md); // текущее время
	int ticketO[]; int no=GetTickets(-1, SysID, smb, ticketO);
	int ticketH[]; int nh=GetTicketsH(-1, SysID, smb, ticketH);
	for (int i=0; i<n; i++)
	{
		int dir=(int)GetGV(name[i]); if (dir!=OP_BUY && dir!=OP_SELL) continue;
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int id=STI(sid); sid=sID+"VO."+sid;
		if (CheckGV(sid+".cl")) continue; // уже закрыт
		double apr=APR(dir);
		double op=GetGV(sid+".op"); datetime dop=(datetime)GetGV(sid+".dop");
		double sl=CheckGV(sid+".sl")?GetGV(sid+".sl"):0, tp=CheckGV(sid+".tp")?GetGV(sid+".tp"):0;
		if (bShowVOrder) { DrawOrder(sid, id, dir, op, sl, tp); DrawDeal(sid, id, dir, Lot, op, dop, 0, 0, sl, tp); }
		
		bool b=false;
		//1. проверка по стопам
		if (sl>0 && (sl-apr)*SD(dir)>=0) b=true;
		if (tp>0 && (apr-tp)*SD(dir)>=0) b=true;
		if (!b) { if (tp>0) INF("до ТП осталось "+DTS((tp-apr)*SD(dir)/(Pnt*_Pnt),0)+" п."); if (sl>0) INF("до СЛ осталось "+DTS((apr-sl)*SD(dir)/(Pnt*_Pnt),0)+" п."); } // ждем когда цена пересечет ТП или СЛ
		if (!b)
		{
			if (FindComment(ticketO, no, ITS(id)+"|")>0) { INF("ордер для #"+ITS(id)+" еще открыт"); continue; }
			if (FindComment(ticketH, nh, ITS(id)+"|")<=0) { INF("ордер для #"+ITS(id)+" еще не открыт/не закрыт"); continue; }
		}
				
		SetGV(sid+".cl", apr); SetGV(sid+".dcl", dcl); // закрыли ордер
		string txt="Close V "+smb+" "+OTS(dir)+"#"+ITS(id)+" | cl="+DTS(apr);
		INF(txt); Print("+"+txt);
		if (bShowVOrder) { DrawDeal(sid, id, dir, Lot, op, dop, apr, dcl, sl, tp); ObjectsDeleteAll2(0, OBJ_HLINE, sid); }
	}	
}
//------------------------------------------------------------------ TralVPos
void TralVPos(int SysID, string smb)
{
	INF(""); 
	INF("+Е. Трал тейкпрофита вирт. ордера ", true);
	if ((ProcentProfit<=0 || CloseProcentProfit<=0) || !bVTralTP) { INF("-не используем. ProcentProfit или CloseProcentProfit и bVTralSL ==0"); return; }
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	for (int i=0; i<n; i++)
	{
		int dir=(int)GetGV(name[i]); if (dir!=OP_BUY && dir!=OP_SELL) continue;
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int id=STI(sid); sid=sID+"VO."+sid;
		if (CheckGV(sid+".cl")) continue; // уже закрыт
		double apr=APR(dir);
		double cop=GetGV(sid+".op");
		double csl=CheckGV(sid+".sl")?GetGV(sid+".sl"):0, ctp=CheckGV(sid+".tp")?GetGV(sid+".tp"):0;
		double wsl=(cop-csl)*SD(dir)*ProcentProfit/100; if (wsl<=0) { INF("У вирт.ордера #"+ITS(id)+" не установлен стоплос"); continue; }
		if ((cop-apr)*SD(dir)<wsl) INF("ждем достижения "+DTS(wsl/(Pnt*_Pnt),0)+" п. убытка. Осталось "+DTS((wsl-(cop-apr)*SD(dir))/(Pnt*_Pnt),0));
		else
		{
			double tp=cop-wsl*(1-CloseProcentProfit/100)*SD(dir);
			if ((ctp-tp)*SD(dir)>0 || ctp==NP(0))
			{
				string txt="Tral V "+smb+" "+OTS(dir)+" #"+ITS(id)+" ctp="+DTS(ctp)+"->"+DTS(tp)+"  id="+ITS(SysID);
				INF(txt); Print("+"+txt); SetGV(sid+".tp", tp);
			}
		}
	}
}
//------------------------------------------------------------------ OpenRPos
void OpenRPos(int SysID, string smb, int tf)
{
	INF(""); 
	INF("+В. Открытие реального ордера", true); 
	string name[]; int n=SelectGV(sID+"VOrder.", name); if (n<=0) { INF("ждем V ордера"); return; }
	int ticketO[]; int no=GetTickets(-1, SysID, smb, ticketO);
	int ticketH[]; int nh=GetTicketsH(-1, SysID, smb, ticketH);
	for (int i=0; i<n; i++)
	{
		int vdir=(int)GetGV(name[i]); if (vdir!=OP_BUY && vdir!=OP_SELL) continue;
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int id=STI(sid);
		double vop=GetGV(sID+"VO."+sid+".op"); // цена открытия виртуального
		if (CheckGV(sID+"VO."+sid+".cl")) continue; // виртуальный ордер уже закрыт
		if (!CheckGV(sID+"VO."+sid+".lot")) { double lot=Lot; if (Lot<=0) lot=AccountBalance()*MM/100.0; lot=NL(lot); SetGV(sID+"VO."+sid+".lot", lot); }
		double lot=GetGV(sID+"VO."+sid+".lot"); lot=NL(lot);
		int dir=vdir; if (bRevers) dir=ADIR(dir); // перевернули ордер
		if (FindComment(ticketO, no, sid+"|")>0) { INF("ордер для #"+sid+" уже открыт"); continue; }
		if (FindComment(ticketH, nh, sid+"|")>0) { INF("ордер для #"+sid+" был закрыт"); continue; }
		double op=NPR(dir), apr=APR(dir);
		int comp=0;
		if (bRevers)
		{
			comp=GetComp();
			if (comp>0 && (vop-op)*SD(dir)<comp*Pnt*_Pnt) { INF("Открытие через "+DTS((comp-(vop-op)*SD(dir)/(Pnt*_Pnt)),0)+" п."); continue; }
		}
		lot=NL(lot); // нормализуем лот
		comp=int(fabs(vop-op)/(Pnt*_Pnt));

		double d=CountStopSize(dir, smb, tf); string txt=("Расчитанный размер СЛ/ТП="+DTS(d/(Pnt*_Pnt),0)+" п.");
		INF(txt); if (d<=0) { INF("-Неверный размер СЛ/ТП"); continue; }
		Print(txt); // про размер стопа
		double v=CountVolatile(smb, tf);

		double tp=0, sl=0;
		double dtp0=0, dsl0=0; if (CloseMode==0) { dtp0=d; dsl0=d; }
		double dtp1=0, dsl1=0; if (CloseMode==1 || CloseMode==3 || CloseMode==4) { dtp1=TP*Pnt*_Pnt; dsl1=SL*Pnt*_Pnt; }
		double dtp2=0, dsl2=0; if (CloseMode==2 || CloseMode==4) { dtp2=v*StopVolatile; dsl2=v*StopVolatile; }
		if (CloseMode==0) { tp=dtp0; sl=dsl0; }
		if (CloseMode==1) { tp=dtp1; sl=dsl1; }
		if (CloseMode==2) { tp=dtp2; sl=dsl2; }
		if (CloseMode==3) { if (dtp0>0) { if (dtp1>0) tp=fmin(dtp0, dtp1); else tp=dtp0; } else tp=dtp1; }
		if (CloseMode==4)
		{
			if (dtp0>0) { if (dtp1>0) tp=fmin(dtp0, dtp1); else tp=dtp0; } else tp=dtp1;
			if (dtp2>0) { if (tp>0) tp=fmin(dtp2, tp); else tp=dtp2; }
		}
		tp=NTP(dir, op, apr, tp/(Pnt*_Pnt), StopLvl);
		sl=NSL(dir, op, apr, sl/(Pnt*_Pnt), StopLvl);
		
		int ticket=-1;
		if (bMarketExec) ticket=OrderSend(smb, dir, lot, op, Slip, 0, 0, sid+"|"+ITS(comp), SysID, 0, OTC(dir));
		else ticket=OrderSend(smb, dir, lot, op, Slip, sl, tp, sid+"|"+ITS(comp), SysID, 0, OTC(dir));
		txt="Open R "+smb+" "+OTS(dir)+"#"+ITS(ticket)+" op="+DTS(op)+" lot="+DTS(lot, 2)+" к вирт. id="+sid+" компенсац.="+ITS(comp)+" |  magic="+ITS(SysID)+" | CloseMode="+ITS(CloseMode);
		INF(txt);
		if (ticket<=0) ErrorHandle(GetLastError(), -1, SysID, txt);
		else
		{
			Print("+"+txt);
			if (bMarketExec) PlaceStop(ticket, dir, SysID, smb, op, sl, tp);
			// ставим стопы у виртуального
			if (vdir==OP_BUY)
			{
				if (sl>0 && sl<=vop) SetGV(sID+"VO."+sid+".sl", sl); else if (tp>0 && tp<=vop) SetGV(sID+"VO."+sid+".sl", tp);
				if (tp>0 && tp>=vop) SetGV(sID+"VO."+sid+".tp", tp); else if (sl>0 && sl>=vop) SetGV(sID+"VO."+sid+".tp", sl);
			}
			else if (vdir==OP_SELL)
			{
				if (sl>0 && sl>=vop) SetGV(sID+"VO."+sid+".sl", sl); else if (tp>0 && tp>=vop) SetGV(sID+"VO."+sid+".sl", tp);
				if (tp>0 && tp<=vop) SetGV(sID+"VO."+sid+".tp", tp); else if (sl>0 && sl<=vop) SetGV(sID+"VO."+sid+".tp", sl);
			}
		}
	}
}
//------------------------------------------------------------------ CloseRPos
void CloseRPos(int SysID, string smb, int tf)
{
	INF(""); 
	INF("+Г. Закрытие реального ордера", true);
	int ticket[], n=GetTickets(-1, SysID, smb, ticket); if (n<=0) { INF("wait orders"); return; }
	for (int i=0; i<n; i++)
	{
		if (!OrderSelect(ticket[i], SELECT_BY_TICKET)) { INF("Ошибка получения ордера "+ITS(ticket[i])); continue; }
		int dir=OrderType(); double prof=OrderProfit(); double apr=APR(dir);
		int c=StringFind(OrderComment(), "|"); if (c<0) { INF("Ошибка комментария "+OrderComment()); continue; }// нашли символ разделения или вышли при ошибке
		string sid=StringSubstr(OrderComment(), 0, c);
		if (!CheckGV(sID+"VO."+sid+".cl")) { INF("#"+sid+" еще открыт (для #"+ITS(ticket[i])+")"); continue; } // ордер еще не закрыт
		string txt="Close R "+smb+" "+OTS(dir)+" #"+ITS(ticket[i])+"cl="+DTS(apr)+" prof="+DTS(OrderProfit(),2)+" pip="+DTS((OrderClosePrice()-OrderOpenPrice())/(Pnt*_Pnt),0);
		INF(txt);
		if (!OrderClose(ticket[i], OrderLots(), apr, Slip, OTC(dir))) ErrorHandle(GetLastError(), ticket[i], SysID, txt); else Print(txt);
	}
}
//------------------------------------------------------------------ TralRPos
void TralRPos(int SysID, string smb)
{
	INF(""); 
	INF("+Д. Перемещение стоплоса реального ордера", true);
	if ((ProcentProfit<=0 || CloseProcentProfit<=0) && (SL<=0 || !bTralSL)) { INF("-не используем. ProcentProfit или CloseProcentProfit и SL ==0"); return; }
	int ticket[], n=GetTickets(-1, SysID, smb, ticket); if (n<=0) { INF("wait orders"); return; }
	for (int i=0; i<n; i++)
	{
		if (!OrderSelect(ticket[i], SELECT_BY_TICKET)) { INF("Ошибка получения ордера "+ITS(ticket[i])); continue; }
		int dir=OrderType(); RefreshParam(smb); double apr=APR(dir); // обновили параметры
		double csl=ND(OrderStopLoss()); double cop=ND(OrderOpenPrice()); double ctp=ND(OrderTakeProfit());
		if (MathAbs(ctp-apr)<=FreezLvl || MathAbs(csl-apr)<=FreezLvl) { INF(OTS(dir)+"#"+ITS(ticket[i])+" freezed"); continue; }
		if (ProcentProfit>0 && CloseProcentProfit>0)
		{
			double wtp=(ctp-cop)*SD(dir)*ProcentProfit/100;
			if (wtp<=0) { INF("У ордера #"+ITS(ticket[i])+" не установлен тейкпрофит"); }
			else
			{
				if ((apr-cop)*SD(dir)<wtp) INF("ждем достижения "+DTS(wtp/(Pnt*_Pnt),0)+" п. профита. Осталось "+DTS((wtp-(apr-cop)*SD(dir))/(Pnt*_Pnt),0));
				else
				{
					double sl=NSL(dir, apr, apr, cop+wtp*(1-CloseProcentProfit/100)*SD(dir), StopLvl, false);
					if ((sl-cop)*SD(dir)>0 && ((sl-csl)*SD(dir)>0 || csl==NP(0)))
					{
						string txt="Tral R "+smb+" "+OTS(dir)+" #"+ITS(ticket[i])+" csl="+DTS(csl)+"->"+DTS(sl)+"  id="+ITS(SysID);
						INF(txt);
						if (!OrderModify(ticket[i], cop, sl, ctp, 0, OTC(dir))) ErrorHandle(GetLastError(), ticket[i], SysID, txt); else { Print("+"+txt); csl=sl; }
					}
				}
			}
		}
		if (bTralSL && SL>0)
		{
			double sl=NSL(dir, apr, apr, SL, StopLvl);
			if ((sl-csl)*SD(dir)>0 || csl==NP(0))
			{
				string txt="TralSL R (по SL и bTralSL) "+smb+" "+OTS(dir)+" #"+ITS(ticket[i])+" csl="+DTS(csl)+"->"+DTS(sl)+"  id="+ITS(SysID);
				INF(txt);
				if (!OrderModify(ticket[i], cop, sl, ctp, 0, OTC(dir))) ErrorHandle(GetLastError(), ticket[i], SysID, txt); else Print("+"+txt);
			}
		}
	}
}
//------------------------------------------------------------------ PlaceStop
void PlaceStop(int ticket, int dir, int SysID, string smb, double op, double nsl, double ntp)
{
	RefreshParam(smb); double apr=APR(dir);
	double sl=NSL(dir, op, apr, nsl, StopLvl, false);
	double tp=NTP(dir, op, apr, ntp, StopLvl, false);
	string txt="Place stops to "+OTS(dir)+"#"+ITS(ticket)+" op="+DTS(op)+" apr="+DTS(apr)+"| sl="+DTS(sl)+" tp="+DTS(tp)+"  id="+ITS(SysID);
	Print(txt); INF(txt);
	int i=0;
	while (i<5 && (tp>0 || sl>0))
	{
		RefreshParam(smb); apr=APR(dir);
		sl=NSL(dir, op, apr, nsl, StopLvl, false);
		tp=NTP(dir, op, apr, ntp, StopLvl, false);
		txt="Place stops to "+OTS(dir)+"#"+ITS(ticket)+" op="+DTS(op)+" apr="+DTS(apr)+"| sl="+DTS(sl)+" tp="+DTS(tp)+"  id="+ITS(SysID);
		if (OrderModify(ticket, op, sl, tp, 0, OTC(dir))) break;
		INF(txt); ErrorHandle(GetLastError(), -1, SysID, txt); Sleep(100); i++;
	}
}

//---------------------------------------------------------------   VirtInfo
void VirtInfo(int SysID, string smb, int tf, int &y)
{
	if (!bVirtInfo) return;
	string txt[100]; int t=-1; color clr[100]; ArrayInitialize(clr, clrLightGray);
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	int cdir=-1, cticket=0; double cop=0, cprof=0, cpprof=0, apr=0;
	double prof=0, loss=0, depo=0, pprof=0, ploss=0; int nb=0, ns=0;
	t++; txt[t]="======== VIRTUAL ======="; clr[t]=clrGray;
	for (int i=0; i<n; i++)
	{
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int id=STI(sid);
		int dir=(int)GetGV(name[i]); // тип виртуального
		if (dir==OP_BALANCE) { depo+=GetGV(sID+"VO."+sid+".prof"); continue; } // если балансовый ордер
		double op=GetGV(sID+"VO."+sid+".op"); // цена открытия виртуального
		double lot=GetGV(sID+"VO."+sid+".lot");
		if (!CheckGV(sID+"VO."+sid+".cl"))
		{
			cdir=dir; cticket=id; cop=op; apr=APR(dir);
			cpprof=(apr-cop)*SD(cdir); cprof=CalcProf(cdir, op, apr, lot);
			t++; txt[t]=OTS(cdir)+"#"+ITS(cticket)+" | "+DTS(cop)+" | "+DTS(apr)+"  | "+DTS(cpprof/(Pnt*_Pnt),0)+"п. | "+DTS(cprof,2)+"$"; clr[t]=OTC(cdir);
		}
		else
		{
			double cl=GetGV(sID+"VO."+sid+".cl");
			double pip=(cl-op)*SD(dir);
			if (pip>=0) { prof+=CalcProf(dir, op, cl, lot); pprof+=pip; } else { loss+=CalcProf(dir, op, cl, lot); ploss+=pip; }
			if (dir==OP_BUY) nb++; else ns++;
		}
	}
	if (cdir<0) { t++; txt[t]="Открытых ордеров: нет"; }
	t++; txt[t]="………………………";
	t++; txt[t]="Вирт.Баланс: "+DTS(prof+loss+depo,2);
	t++; txt[t]="Закрытых ордеров:  Sell "+ITS(ns)+" | Buy "+ITS(nb);
	t++; txt[t]="Прибыль: "+DTS(pprof/(Pnt*_Pnt),0)+" п./"+DTS(prof,2);
	t++; txt[t]="Убыток: "+DTS(ploss/(Pnt*_Pnt),0)+" п./"+DTS(loss,2);
	t++; txt[t]="Итого: "+DTS((pprof+ploss)/(Pnt*_Pnt),0)+" п./"+DTS(prof+loss,2);
	t++; txt[t]="………………………";
	t++; txt[t]="Волатильность: "+DTS(CountVolatile(smb, tf)/(Pnt*_Pnt),1)+" п.";
	MqlDateTime mdt; datetime dt=TimeCurrent(mdt);
	t++; txt[t]="Скорость: "+((dt-fdtBid)>0?DTS(nBid*1.0/(dt-fdtBid),2):"0");
	
	Comment2(sID+"vi.", t+1, txt, clr, 1, 10, y);
	y+=20;
}
//---------------------------------------------------------------   CountVBalance
double CountVBalance()
{
	string name[]; int n=SelectGV(sID+"VOrder.", name);
	double bal=0;
	for (int i=0; i<n; i++)
	{
		string sid=StringSubstr(name[i], StringLen(sID+"VOrder."));
		int dir=(int)GetGV(name[i]); // тип виртуального
		if (dir==OP_BALANCE) { bal+=GetGV(sID+"VO."+sid+".prof"); continue; } // если балансовый ордер
		if (!CheckGV(sID+"VO."+sid+".cl")) continue;
		bal+=CalcProf(dir, GetGV(sID+"VO."+sid+".op"), GetGV(sID+"VO."+sid+".cl"), GetGV(sID+"VO."+sid+".lot"));
	}
	return(bal);
}
//---------------------------------------------------------------   RealInfo
void RealInfo(int SysID, string smb, int &y)
{
	if (!bRealInfo) return;
	string txt[100]; int t=-1; color clr[100]; ArrayInitialize(clr, clrLightGray);
	t++; txt[t]="========== REAL ========="; clr[t]=clrGray;
	int ticketO[]; int no=GetTickets(-1, SysID, smb, ticketO);
	int ticketH[]; int nh=GetTicketsH(-1, SysID, smb, ticketH);

	int cdir=-1, cticket=0; double cop=0, cprof=0, cpprof=0, apr=0;
	int comp=0; double pcomp=0;
	for (int i=0; i<no; i++)
	{
		if (!OrderSelect(ticketO[i], SELECT_BY_TICKET)) continue;
		cticket=OrderTicket(); cdir=OrderType(); 
		cop=OrderOpenPrice(); cprof=OrderProfit(); cpprof=(OrderClosePrice()-OrderOpenPrice())*SD(cdir);
		apr=APR(cdir);
		int c=StringFind(OrderComment(), "|"); if (c>0) { int p=STI(StringSubstr(OrderComment(), c+1)); comp+=p; pcomp+=CalcProf(0, 0, p*Pnt*_Pnt, OrderLots()); }
		t++; txt[t]=OTS(cdir)+"#"+ITS(cticket)+" | "+DTS(cop)+" | "+DTS(apr)+"  | "+DTS(cpprof/(Pnt*_Pnt),0)+"п. | "+DTS(cprof,2)+"$"; clr[t]=OTC(cdir);
	}
	
	double prof=0, loss=0, pprof=0, ploss=0; int nb=0, ns=0;
	for (int i=0; i<nh; i++)
	{
		if (!OrderSelect(ticketH[i], SELECT_BY_TICKET)) continue;
		int c=StringFind(OrderComment(), "|"); if (c<0) continue;
		int p=STI(StringSubstr(OrderComment(), c+1)); comp+=p; pcomp+=CalcProf(0, 0, p*Pnt*_Pnt, OrderLots()); 
		if (OrderProfit()>=0) { prof+=OrderProfit(); pprof+=(OrderClosePrice()-OrderOpenPrice())*SD(OrderType()); }
		else { loss+=OrderProfit(); ploss+=(OrderClosePrice()-OrderOpenPrice())*SD(OrderType()); }
		if (OrderType()==OP_BUY) nb++; else ns++;
	}
	
	if (cdir<0) { t++; txt[t]="Открытых ордеров: нет"; }
	t++; txt[t]="………………………";
	t++; txt[t]="Закрытых ордеров:  Sell "+ITS(ns)+" | Buy "+ITS(nb);
	t++; txt[t]="Прибыль: "+DTS(pprof/(Pnt*_Pnt),0)+" п./"+DTS(prof,2);
	t++; txt[t]="Убыток: "+DTS(ploss/(Pnt*_Pnt),0)+" п./"+DTS(loss,2);
	t++; txt[t]="Итого: "+DTS((pprof+ploss)/(Pnt*_Pnt),0)+" п./"+DTS(prof+loss,2);
	t++; txt[t]="………………………";
	t++; txt[t]="Сумма компенсаций: "+ITS(comp)+" п./"+DTS(pcomp,2);
	Comment2(sID+"ri.", t+1, txt, clr, 1, 10, y);
	y+=20;
}
//---------------------------------------------------------------   SpreadInfo
void SpreadInfo(int SysID, string smb, int &y)
{
	if (!bSpreadInfo) return;
	string txt[100]; int t=-1; color clr[100]; ArrayInitialize(clr, SpreadMode<=0?clrLightGray:clrYellow);
	t++; txt[t]="========= SPREAD ========"; clr[t]=clrGray;
	t++; txt[t]="Метод компенсации: "+ITS(SpreadMode);
	t++; txt[t]="Текущий спред: "+DTS(Spread/(Pnt*_Pnt),0)+" п.";
	t++; txt[t]="Фикс. спред: "+DTS(FixSpread,0)+" п.";
	t++; txt[t]="Средний спред("+ITS(is)+"): "+DTS(AvgSpread()/(Pnt*_Pnt),0)+" п.";
	t++; txt[t]="Компенсация: "+ITS(GetComp())+" п.";
	Comment2(sID+"si.", t+1, txt, clr, 1, 10, y);
	y+=20;
}
//---------------------------------------------------------------   CalcProf
double CalcProf(int dir, double op, double cl, double lot)
{
	if (ProfitCalcMode==0) return((cl-op)*SD(dir)*lot*TickVal/TickSize); // forex
	if (ProfitCalcMode==1) return((cl-op)*SD(dir)*lot*LotSize); // cfd
	if (ProfitCalcMode==2) return((cl-op)*SD(dir)*lot*TickVal/TickSize); // futures
	return(0);	
}
//---------------------------------------------------------------   FindComment
int FindComment(int &ticket[], int n, string pref)
{
	for (int i=0; i<n; i++)
	{
		if (!OrderSelect(ticket[i], SELECT_BY_TICKET)) continue;
		if (StringFind(OrderComment(), pref, 0)==0) return(ticket[i]);
	}
	return(0);
}
//---------------------------------------------------------------   GetComp
int GetComp()
{
	int comp=0;
	if (SpreadMode==1) comp=int((2*Spread)/(Pnt*_Pnt));
	if (SpreadMode==2) comp=int(AvgSpread()*AvgSpreadKoef/(Pnt*_Pnt));
	if (SpreadMode==3) comp=FixSpread;
	return(comp);
}
//------------------------------------------------------------------ AddSpread
void AddSpread()
{
	if (is>=AvgSpreadCount) { is--; for (int i=0; i<AvgSpreadCount-1; i++) spread[i]=spread[i+1]; }
	spread[is]=Spread; is++;
}
//------------------------------------------------------------------ AvgSpread
double AvgSpread()
{
	if (is<AvgSpreadCount) return(0);
	double avg=0; for (int i=0; i<AvgSpreadCount; i++) avg+=spread[i];
	return(AvgSpreadCount>0?avg/double(AvgSpreadCount):0);
}
//------------------------------------------------------------------ CheckAcceleration
void CheckAcceleration()
{
	MqlDateTime mdt; datetime dt=TimeCurrent(mdt);
	if (pBid<=0) { pBid=_Bid; fdtBid=dt; nBid=0; return; }
	if ((_Bid>pBid && nBid<0) || (_Bid<pBid && nBid>0)) { pBid=_Bid; fdtBid=dt; nBid=0; return; }
	if (_Bid>=pBid && nBid>=0) { pBid=_Bid; nBid++; return; }
	if (_Bid<=pBid && nBid<=0) { pBid=_Bid; nBid--; return; }
}
//------------------------------------------------------------------ CheckVolatile
void CheckVolatile()
{
	if (_Bid<pLo || pLo<=0) pLo=_Bid;
	if (_Bid>pHi || pHi<=0) pHi=_Bid;
}
//------------------------------------------------------------------ CountVolatile
double CountVolatile(string smb, int tf)
{
	double v=0; for (int i=0; i<BarVolatile; i++) v+=iHigh(smb, tf, i)-iLow(smb, tf, i);
	return(BarVolatile>0?v/BarVolatile:0);
}
//---------------------------------------------------------------   IsDir
bool IsDir(int dir, int type)
{
	if (dir==OP_ALL) return(true);
	if (dir>=0 && dir<=7 && type==dir) return(true);
	if (dir==OP_MARKET && (type==OP_BUY || type==OP_SELL)) return(true);
	return(false);
}
//---------------------------------------------------------------   CountOrders
int CountOrders(int dir, int SysID, string smb)
{
	int total=OrdersTotal(), c=0; if (total<=0) return (0);
	for(int i=0; i<total; i++) 
	{ 
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { ErrorHandle(GetLastError(), -1, SysID, "CountOrders - SelectOrder. i="+ITS(i)+"  total="+ITS(total));  return(-1); }		
		if (!IsDir(dir, OrderType()) || OrderMagicNumber()!=SysID || (OrderSymbol()!=smb&&smb!="")) continue;
		c++;
	}
	return(c);
}
//---------------------------------------------------------------   GetTickets
int GetTickets(int dir, int SysID, string smb, int &tickets[])
{
	int total=OrdersTotal(); if (total<=0) return (0);
	int c=0; // orders counter
	ArrayResize(tickets, total); // change array size
	for(int i=0; i<total; i++) // select tickets
	{ 
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { ErrorHandle(GetLastError(), -1, SysID, "GetTickets - SelectOrder. i="+ITS(i)+"  total="+ITS(total));  return(-1); }
		if (!IsDir(dir, OrderType()) || OrderMagicNumber()!=SysID || OrderSymbol()!=smb) continue;
		tickets[c]=OrderTicket(); c++;
	}
	ArrayResize(tickets, c);
	return(c); // orders count
}
//---------------------------------------------------------------   GetTickets
int GetTicketsH(int dir, int SysID, string smb, int &tickets[])
{
	int total=OrdersHistoryTotal(); if (total<=0) return (0);
	int c=0; // orders counter
	ArrayResize(tickets, total); // change array size
	for(int i=0; i<total; i++) // select tickets
	{ 
		if (!OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) { ErrorHandle(GetLastError(), -1, SysID, "GetTicketsH - SelectOrder. i="+ITS(i)+"  total="+ITS(total));  return(-1); }
		if (!IsDir(dir, OrderType()) || OrderMagicNumber()!=SysID || OrderSymbol()!=smb) continue;
		tickets[c]=OrderTicket(); c++;
	}
	ArrayResize(tickets, c);
	return(c); // orders count
}
//---------------------------------------------------------------   CloseOrders
int CloseOrders(int dir, int SysID, string smb)
{
	int i, total = OrdersTotal();	if (total<=0) return(0);
	int ticket[1000]={0}, nt=0; double op=0;

	nt=0;
	for (i=0; i<total; i++)	
	{	
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { ErrorHandle(GetLastError(), ticket[i], SysID, "OrderClose - Select "+ITS(i));  return(-1); }
		if (!IsDir(dir, OrderType()) || OrderMagicNumber()!=SysID || (OrderSymbol()!=smb&&smb!="")) continue;
		ticket[nt]=OrderTicket(); nt++;
	}
	for (i=0; i<nt; i++)
	{	
		if (!OrderSelect(ticket[i], SELECT_BY_TICKET)) { ErrorHandle(GetLastError(), ticket[i], SysID, "OrderClose - Select#"+ITS(ticket[i])+"  nt="+ITS(nt)+"  i="+ITS(i));  return(-1); }
		dir=OrderType(); RefreshParam(OrderSymbol());
		if (dir==OP_BUY) op=_Bid; else if (dir==OP_SELL) op=_Ask;
		if (dir==OP_BUY || dir==OP_SELL) if (!OrderClose(ticket[i], OrderLots(), op, Slip, OTC(dir))) { ErrorHandle(GetLastError(), ticket[i], SysID, "OrderClose#="+ITS(ticket[i])+"  nt="+ITS(nt)+"  i="+ITS(i)); return(-1); }
		if (dir==OP_BUYLIMIT || dir==OP_SELLLIMIT || dir==OP_BUYSTOP || dir==OP_SELLSTOP)
			if (!OrderDelete(ticket[i])) { ErrorHandle(GetLastError(), ticket[i], SysID, "OrderDelete#="+ITS(OrderTicket())); return(-1); }
	}
	return(nt);
}
//---------------------------------------------------------------   RefreshParam
void RefreshParam(string smb)
{
	RefreshRates();
	_Digit=(int)MarketInfo(smb, MODE_DIGITS);
	Pnt=1; //if (_Digit==5 || _Digit==3) Pnt=10;
	_Pnt=MarketInfo(smb, MODE_POINT);
	FreezLvl=MarketInfo(smb, MODE_FREEZELEVEL)*_Pnt;
	StopLvl=MarketInfo(smb, MODE_STOPLEVEL)*_Pnt;
	Spread=MarketInfo(smb, MODE_SPREAD)*_Pnt;
 	LotSize=MarketInfo(smb, MODE_LOTSIZE); 
 	LotStep=MarketInfo(smb, MODE_LOTSTEP);
 	MinLot=MarketInfo(smb, MODE_MINLOT);
 	MaxLot=MarketInfo(smb, MODE_MAXLOT);
 	TickVal=MarketInfo(smb, MODE_TICKVALUE); if (TickVal==0) TickVal=10.0/Pnt;
	TickSize=MarketInfo(smb, MODE_TICKSIZE); if (TickSize==0) TickSize=1;
 	ProfitCalcMode=MarketInfo(smb, MODE_PROFITCALCMODE);
 	if (_Pnt==0 && _Digit!=0) _Pnt=1/_Digit;
	_Bid=NP(MarketInfo(smb, MODE_BID));
	_Ask=NP(MarketInfo(smb, MODE_ASK));
}
//---------------------------------------------------------------   ErrorHandle
void ErrorHandle(int err, int OrderID, int SysID, string str)
{
	Print("("+ITS(err)+"): "+ErrorDescription(err)+"-Magic: "+ITS(SysID)+" #"+ITS(OrderID)+" | -"+str); 
	switch (err)
	{
		case ERR_SERVER_BUSY: //4 
		case ERR_NO_CONNECTION: //6
		case ERR_TOO_FREQUENT_REQUESTS: //8
		case ERR_BROKER_BUSY: //137
		case ERR_TOO_MANY_REQUESTS: //141
		case ERR_TRADE_CONTEXT_BUSY: //146
			Sleep(2000); //
			break;
		
		case ERR_PRICE_CHANGED: //135
		case ERR_REQUOTE: //138
			RefreshRates(); //
			break;
	}
}

//---------------------------------------------------------------   NPR
double NPR(int dir) 
{ 
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) return(_Ask);
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) return(_Bid);
	return(0);
}
//---------------------------------------------------------------   APR
double APR(int dir) 
{ 
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) return(_Bid);
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) return(_Ask);
	return(0);
}
//---------------------------------------------------------------   ND
double ND(double d, int n=-1) {  if (n<0) return(NormalizeDouble(d, _Digit)); return(NormalizeDouble(d, n)); }
//---------------------------------------------------------------   NP
double NP(double d) { return (ND(MathRound(d/TickSize)*TickSize)); }
//---------------------------------------------------------------   NL
double NL(double lot) 
{
	int k=0; // lot digits
	// select lot digits by lotstep
	if (LotStep<=0.001) k=3; else if (LotStep<=0.01) k=2; else if (LotStep<=0.1) k=1;
	lot=ND(MathMin(MaxLot, MathMax(MinLot, lot)), k);
	return(lot);
}
//---------------------------------------------------------------   DIR
int DIR(int dir)
{
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) return(OP_BUY);
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) return(OP_SELL);
	return(dir);
}
//---------------------------------------------------------------   ADIR
int ADIR(int dir)
{
	int p[6]={OP_BUY, OP_SELL, OP_BUYLIMIT, OP_SELLLIMIT, OP_BUYSTOP, OP_SELLSTOP};
	int a[6]={OP_SELL, OP_BUY, OP_SELLLIMIT, OP_BUYLIMIT, OP_SELLSTOP, OP_BUYSTOP};
	for (int i=0; i<6; i++) if (p[i]==dir) return(a[i]);
	return(dir);
}
//---------------------------------------------------------------   INF
void INF(string st, bool ini=false) { if (!bShowComment) return; if (ini) g_inf=g_inf+"\n        "+st; else g_inf=g_inf+"\n            "+st; }

//---------------------------------------------------------------   IIF
double IIF(bool cond, double a1, double a2) { if (cond) return (a1); else return(a2); }
//---------------------------------------------------------------   SD
double SD(int dir) 
{ 
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) return(1);
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) return(-1);
	return(0);
}

//---------------------------------------------------------------   ITS
string ITS(long d) { return(DoubleToStr(d, 0)); }
//---------------------------------------------------------------   DTS
string DTS(double d, int n=-1) { if (d==EMPTY_VALUE) return("<>"); if (n<0) return(DoubleToStr(d, _Digit)); else return(DoubleToStr(d, n)); }
//---------------------------------------------------------------   TTS
string TTS(datetime time) { return (TimeToStr(time, TIME_DATE|TIME_SECONDS)); }
//---------------------------------------------------------------   OTS
string OTS(int n)
{
	int p[15]={OP_BUY, OP_SELL, OP_BUYLIMIT, OP_SELLLIMIT, OP_BUYSTOP, OP_SELLSTOP, 6, 7, 8, 9, 10, 11, 12, 13, -1};
	string sp[15]={"BUY", "SELL", "BUYLIMIT", "SELLLIMIT", "BUYSTOP", "SELLSTOP", "BALANCE", "CREDIT", "MARKET", "PEND", "LIMIT", "STOP", "BUYALL", "SELLALL", "ALL"};
	for (int i=0; i<15; i++) if (p[i]==n) return(sp[i]);
	return("--");
}
//---------------------------------------------------------------   OTC
color OTC(int dir) 
{
	if (dir==OP_BUY || dir==OP_BUYLIMIT || dir==OP_BUYSTOP) return(clrLimeGreen);
	if (dir==OP_SELL || dir==OP_SELLLIMIT || dir==OP_SELLSTOP) return(clrRed);
	return(0);
}
//---------------------------------------------------------------   PTS
string PTS(int n) 
{
	if (n==0) return(PTS(Period()));
	int p[9]={1, 5, 15, 30, 60, 240, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
	string sp[9]={"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"};
	for (int i=0; i<9; i++) if (p[i]==n) return(sp[i]);
	return("--");
}

//------------------------------------------------------------------ SetLabel
void SetLabel(string name, int wnd, string text, color clr, int x, int y, int corn, int fontsize, string font)
{
	ObjectCreate(name, OBJ_LABEL, wnd, 0, 0); ObjectSet(name, OBJPROP_CORNER, corn); 
	ObjectSetText(name, text, fontsize, font, clr); 
	ObjectSet(name, OBJPROP_XDISTANCE, x);	ObjectSet(name, OBJPROP_YDISTANCE, y); 
}
//------------------------------------------------------------------ SetArrow
void SetArrow(string name, datetime dt, double pr, color clr, int arr, int width, string st)
{
	ObjectCreate(name, OBJ_ARROW, 0, dt, pr);
	ObjectSet(name, OBJPROP_TIME1, dt); ObjectSet(name, OBJPROP_PRICE1, pr);
	ObjectSet(name, OBJPROP_ARROWCODE, arr); ObjectSet(name, OBJPROP_COLOR, clr);
	ObjectSetText(name, st); ObjectSet(name, OBJPROP_WIDTH, width);
}
//------------------------------------------------------------------ SetText
void SetText(string name, int wnd, string text, datetime dt, double pr, color clr, int fontsize, string font)
{
	ObjectCreate(name, OBJ_TEXT, wnd, 0, 0); ObjectSet(name, OBJPROP_COLOR, clr);
	ObjectSetText(name, text, fontsize, font, clr); 
	ObjectSet(name, OBJPROP_TIME1, dt);	ObjectSet(name, OBJPROP_PRICE1, pr);
}
//------------------------------------------------------------------ SetLine
void SetLine(string name, datetime dt1, double pr1, datetime dt2, double pr2, color clr, int width, int style, string st)
{
	ObjectCreate(name, OBJ_TREND, 0, 0, 0); ObjectSet(name, OBJPROP_RAY, false);
	ObjectSet(name, OBJPROP_TIME1, dt1); ObjectSet(name, OBJPROP_PRICE1, pr1);
	ObjectSet(name, OBJPROP_TIME2, dt2); ObjectSet(name, OBJPROP_PRICE2, pr2);
	ObjectSet(name, OBJPROP_WIDTH, width); ObjectSet(name, OBJPROP_COLOR, clr);
	ObjectSetText(name, st); ObjectSet(name, OBJPROP_STYLE, style);
}
//------------------------------------------------------------------ SetHLine
void SetHLine(string name, double pr, color clr, int width, int style, string st)
{
	ObjectCreate(name, OBJ_HLINE, 0, 0, 0); ObjectSet(name, OBJPROP_PRICE1, pr);
	ObjectSet(name, OBJPROP_WIDTH, width); ObjectSet(name, OBJPROP_COLOR, clr);
	ObjectSetText(name, st); ObjectSet(name, OBJPROP_STYLE, style);
}
//------------------------------------------------------------------ ObjectsDeleteAll2
void ObjectsDeleteAll2(int wnd=-1, int type=-1, string pref="")
{
	string names[]; int n=ObjectsTotal(); ArrayResize(names, n);
	for (int i=0; i<n; i++) names[i]=ObjectName(i);
	for (int i=0; i<n; i++) 
	{
		if (wnd>=0) if (ObjectFind(names[i])!=wnd) continue;
		if (type>=0) if (ObjectType(names[i])!=type) continue;
		if (pref!="") if (StringSubstr(names[i], 0, StringLen(pref))!=pref) continue;
		ObjectDelete(names[i]);
	}
}
//------------------------------------------------------------------ ObjectSelect
int ObjectSelect(int wnd, int type, string pref, string &name[])
{
	string names[]; int k=0, n=ObjectsTotal(); ArrayResize(names, n);
	for (int i=0; i<n; i++) 
	{
		string st=ObjectName(i);
		if (wnd>=0) if (ObjectFind(st)!=wnd) continue;
		if (type>=0) if (ObjectType(st)!=type) continue;
		if (pref!="") if (StringSubstr(st, 0, StringLen(pref))!=pref) continue;
		names[k]=st; k++;
	}
	ArrayResize(name, k);
	for (int i=0; i<k; i++) name[i]=names[i]; return(k);
}

//------------------------------------------------------------------ Comment2
void Comment2(string pref, int n, string &inf[], color &clr[], int corn, int x0, int &y0, int fontsize=9, string font="Tahoma")
{
	ObjectsDeleteAll2(0, OBJ_LABEL, pref);
	int dy=int(fontsize*1.5);
	for (int i=0; i<n; i++) SetLabel(pref+ITS(i), 0, inf[i], clr[i], x0, y0+dy*i, corn, fontsize, font);
	y0+=dy*n;
}

//------------------------------------------------------------------ SelectGV
int SelectGV(string pref, string &name[])
{
	string st; int i, k=0, n=GlobalVariablesTotal(); ArrayResize(name, n);
	for (i=0; i<n; i++) 
	{
		st=GlobalVariableName(i);
		if (pref!="") if (StringSubstr(st, 0, StringLen(pref))!=pref) continue;
		name[k]=st; k++;
	}
	return(k);
}
//------------------------------------------------------------------ GetGV
double GetGV(string name) { int g_err=GetLastError(); double r=GlobalVariableGet(name); g_err=GetLastError(); if (g_err>0) INF("-err Get="+ITS(g_err)+" GV="+name); return(r); }
//------------------------------------------------------------------ SetGV
datetime SetGV(string name, double r) { datetime dt=GlobalVariableSet(name, r); int g_err=GetLastError(); if (g_err>0 || dt<=0) INF("-err Set="+ITS(g_err)+" GV="+name+"  dt="+ITS(dt)); return(dt); }
//------------------------------------------------------------------ DelGV
bool DelGV(string name) { return(GlobalVariableDel(name)); }
//------------------------------------------------------------------ CheckGV
bool CheckGV(string name) { return(GlobalVariableCheck(name)); }

//---------------------------------------------------------------   DrawDeals
void DrawDeal(string name, int ticket, int dir, double lot, double op, datetime dop, double cl, datetime dcl, double sl, double tp)
{	
	SetArrow(name+".opa", dop, op, OTC(dir), 1, 0, "open #"+ITS(ticket)+" @"+TTS(dop)+" | op="+DTS(op)+"  tp="+DTS(tp)+"  sl="+DTS(sl)+" lot="+DTS(lot));
	if (tp>0) SetArrow(name+".tpa", dop, tp, OTC(dir), 4, 0, "t/p #"+ITS(ticket)+" ="+DTS(tp));
	if (sl>0) SetArrow(name+".sla", dop, sl, OTC(dir), 4, 0, "s/l #"+ITS(ticket)+" ="+DTS(sl));
	if (dcl<=0) return;
	SetArrow(name+".cla", dcl, cl, OTC(dir), 3, 0, "close #"+ITS(ticket)+" @"+TTS(dcl)+" | op="+DTS(op)+"  tp="+DTS(tp)+"  sl="+DTS(sl)+" lot="+DTS(lot));
	SetLine(name+".ln", dop, op, dcl, cl, OTC(dir), 1, STYLE_DOT, "");
}
//---------------------------------------------------------------   DrawOrder
void DrawOrder(string name, int ticket, int dir, double op, double sl, double tp)
{
	SetHLine(name+".opl", op, clrLimeGreen, 1, STYLE_DOT, "                  "+OTS(dir)+" #"+ITS(ticket));
	if (sl>0) SetHLine(name+".sll", sl, clrMagenta, 1, STYLE_DOT, "                  "+"SL #"+ITS(ticket));
	if (tp>0) SetHLine(name+".tpl", tp, clrMagenta, 1, STYLE_DOT, "                  "+"TP #"+ITS(ticket));
}
//---------------------------------------------------------------   STI
int STI(string d) { return(StrToInteger(d)); }
//---------------------------------------------------------------   NTP
double NTP(int dir, double op, double pr, double aTP, double stop, bool rel=true)
{
	if (aTP==0) return(NP(0));
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) { if (rel) aTP=op+aTP*Pnt*_Pnt; return(NP(MathMax(aTP, pr+stop))); }
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) { if (rel) aTP=op-aTP*Pnt*_Pnt; return(NP(MathMin(aTP, pr-stop))); }
	return(0);
}
//---------------------------------------------------------------   NSL
double NSL(int dir, double op, double pr, double aSL, double stop, bool rel=true)
{
	if (aSL==0) return(NP(0));
	if (dir==OP_BUY || dir==OP_BUYSTOP || dir==OP_BUYLIMIT) { if (rel) aSL=op-aSL*Pnt*_Pnt; return(NP(MathMin(aSL, pr-stop))); }
	if (dir==OP_SELL || dir==OP_SELLSTOP || dir==OP_SELLLIMIT) { if (rel) aSL=op+aSL*Pnt*_Pnt; return(NP(MathMax(aSL, pr+stop))); }
	return(0);
}

/*
Overdraft Profit System  (MT4)

Внешние параметры
Magic=1123; // магик ордеров эксперта
bMarketExec=true; // параметр для брокера с маркет-исполнением, если=true, то сначала выставляем ордер, потом ставим стопы. 
Slip=0; // допустимое проскальзывание при открытии/закрытии рыночного ордера
OpenMode=0; // метод входа в рынок. 
	=0 то по wlxFractals фракталам, 
	=1 то вход по Acceleration. 
	=2 то вход по волатильности.
	=3 то вход с начало по OpenMode=1 после закрытия, вход по OpenMode=2.
	=4 то вход с начало OpenMode =0 после закрытия OpenMode =1 после закрытия OpenMode =2.     
Acceleration=1.5; // минимальная скорость цены
BarVolatile=24; // число баров для расчёта волатильности
kVolatile=5.0; //множитель волатильности 
LotKoef=2; // множитель для следующего лота после убытка
LotKoefStart=0; // с какого убыточного ордера начинать увеличение лота по LotKoef
VDeposit=5000; // размер пополнения вирт.баланса
Revers=true; // true -Открывать реальные ордера противоположно виртуала / false-в том же направлении
Lot=0.1; // лот ордера. если =0, то используем ММ
MM=10; //процент от баланса для лота.
LotKoef=2; // множитель для следующего лота после убытка
LotKoefStart=0; // с какого убыточного ордера начинать увеличение лота по LotKoef
nDay=14; //  число последних дней для расчета среднего хода фракталов.
SpreadMode=0; // метод компенсации спреда 0/1/2/3
FixSpread =0; // размер фиксированной компенсации спреда для SpreadMode=3
AvgSpreadCount=20;   // количество последних значений спреда для вычисления среднего спреда
AvgSpreadKoef=2;  //  количество средних спредов для компенсации
CloseMode=0; // метод закрытия 
	0 - закрытие по расчитанному СЛ/ТП,  
	1 - закрытие по заданным SL/TP 
	2 - закрытие по волатильности 
	3 - закрытие по ближайшему - заданным SL/TP или расчитанному СЛ/ТП хода цены
	4 - закрытие по ближайшему - волатильности или заданным SL/TP или расчитанному СЛ/ТП хода цены
TP=20; // размер тейкпрофита реального ордера при CloseMode=1-2. Если =0, то не используем
SL=20; // размер стоплоса для реального ордера при CloseMode=1-2. Если =0, то не используем
StopVolatile=2; // коэффициент для вычисления стопов по волатильности
bTralSL=true; // =true - включение трала по размеру SL
bTralSLVirt=true; // =true - включение трала тейкпрофита по ProcentProfit/ CloseProcentProfit
ProcentProfit=0; // процент размера для трала СЛ/ТП в профите, если =0, то трал выключен.
CloseProcentProfit=0; // процент для размера СЛ/ТП при трале, если =0, то трал выключен.
// Настройки wlxFractals
Equals = 20; // максимальное число равных вершин слева и справа для проверяемого фрактала
nLeftUp = 20;  // проверяемое число баров слева для фрактала вверх
nRightUp = 20; // проверяемое число баров справа для фрактала вверх
nLeftDown = 20; // проверяемое число баров слева для фрактала вниз
nRightDown = 20; // // проверяемое число баров справа для фрактала вниз
// инфо
bVirtInfo=true; // показывать на чарте инфо панель вирт.ордеров.
bRealInfo=true; // показывать на чарте инфо панель реал.ордеров.
bSpreadInfo=true; // показывать на чарте инфо панель про спред


Сигнал открытия виртуального ордера:
Если OpenMode=0, то
Buy: если последний фрактал wlxFractals  синий 
Sell: если последний фрактал wlxFractals  красный 
Если OpenMode=1, то
Buy: если Скорость тиков вверх более Acceleration
Sell: если Скорость тиков вниз более Acceleration
Где Скорость = число тиков в одном направлении / делённое на прошедшее время тиков. 
При тике в противоположную сторону число тиков и время сбрасывается и отсчитывается заново.
Если OpenMode=2 то 
Buy: если Бид больше последнего Лоу+Волатильность*kVolatile
Sell: если Бид меньше последнего Хай-Волатильность* kVolatile
Где Последний Лоу/Хай - это минимум/максимум Бид, достигнутый начиная от запуска эксперта или после открытия ордера.
Волатильность= (Сумма Хай-Лоу на промежутке последних BarVolatile) / делённое на BarVolatile. 
Если OpenMode=3 то 
Buy: вход сначала по OpenMode=1 после закрытия, вход по OpenMode=2.
Sell: вход сначала по OpenMode=1 после закрытия, вход по OpenMode=2.
Если OpenMode=4  то 
Buy:  вход сначала OpenMode =0 после закрытия OpenMode =1 после закрытия OpenMode =2.
Sell: вход сначала OpenMode =0 после закрытия OpenMode =1 после закрытия OpenMode =2

А. Открытие виртуального ордера
Если есть сигнал открытия ордера, И нет ещё открытых вирт.ордеров, то открываем виртуальный ордер в направлении сигнала.
Лот вирт.ордера:
Если предыдущий вирт.ордер закрылся в убыток и это LotKoefStart убыточный ордер, то лот виртордера  = предыдущий лот * LotKoef.
Иначе если предыдущий вирт.ордер закрылся в профит или это еще не LotKoefStart убыточный ордер, то лот виртордера  = Lots. Или если Lots=0, то лот = AccountBalance/1000 * MM/100

Ведение вирт.баланса в памяти:
Эксперт проверяет лот на вирт.средства в памяти.
Если средств не окажется, то эксперт создаёт в памяти вирт.балансовую операцию в размере VDeposit - пополняет вирт.баланс (+запись в журнал про пополнение). И сбрасывает счетчик вирт.ордеров на 0, чтоб открыть с начальным лотом (по Lots или по MM).

Важно! По одному сигналу фрактала можно открыть только один ордер. после закрытия ордера ждём новый фрактал.
Важно! Если SpreadMode = 2, то в памяти эксперта должен быть уже посчитан средний спред (то есть должно пройти не менее AvgSpreadCount тиков перед открытием вирт.ордера)

Каждый виртуальный ордер имеет свой уникальный идентификатор (случайное число), который используем в комментарии реального ордера для их идентификации.

Б. Закрытие виртуального ордера
1. Если отсутствует или закрыт реальный ордер (ищем по идентификатору из комментария реал.ордера), соответствующего виртуального ордера, то эксперт закрывает этот виртуальный ордер.
2. Если цена пересекает цену тейкпрофита или стоплоса вирт.ордера, то закрываем вирт.ордер

В. Открытие реального ордера (при Trade=true)
При открытии виртуального ордера эксперт открывает реальный ордер. 
Если Revers=false, то в таком же направлении, как и виртуальный (то есть торгуем синхронно с виртуальным)
Если Revers=true, то в противоположном направлении от виртуального  и компенсируем спред:
- SpreadMode =0, то спред не компенсируется.
- SpreadMode = 1, то реальный ордер открываем, когда цена уйдёт от его виртуального ордера на расстояние 2*текущий спред в профит.
- SpreadMode = 2, то реальный ордер открываем, когда цена уйдёт от виртуального ордера на расстояние AvgSpreadKoef *средний спред в профит.
- SpreadMode = 3, то реальный ордер открываем, когда цена уйдёт от виртуального ордера на расстояние FixSpread в профит.
Средний спред = Сумма AvgSpreadCount последних значений спреда делённое на AvgSpreadCount

Лот ордера соответствует вирт.ордеру.

В ордере ставим реальный стоплос и тейкпрофит:
- CloseMode=0, то расчитываем тейкпрофит и стоплос для ордера:
- для Бай = Сумма расстояний от красного до синего фрактала за nDay дней делённое на количество этих промежутков
- для Селл = Сумма расстояний от синего до касного фрактала за nDay дней делённое на количество этих промежутков
- CloseMode=1, то используем заданные TP/SL
- CloseMode=2, то размер СЛ/ТП = Размер волатильности * SLVolatile (волатильность вычисляется аналогично как для открытия)
- CloseMode=3, то рассчитываем по CloseMode=0,1 - но выставляем стопы на тот, который ближайший.
- CloseMode=4, то рассчитываем по CloseMode=0,1,2 - но выставляем стопы на тот, который ближайший.

При выставлении стопов у реального - эти стопы дублируются и у виртуального.

Важно! В комментарий реального ордера записываем: <Идентификатор вирт.ордера>|<Спред компенсации>.
Важно! Если виртуальный ордер уже закрыт, то реальный ордер не открываем.

Г. Закрытие реального ордера
Если закрыт виртуальный ордер (см. раздел Б2), то закрываем и реальный.

Д. Перемещение стоплоса реального ордера
1. При bTralSL и заданном SL>0: 
Пока цена идёт в профит, то стоплос следует на расстоянии SL за ценой.

2. При наличии ТП у ордера и заданных ProcentProfit, CloseProcentProfit: 
Если цена уходит в профит на расстояние ProcentProfit/100*ТП реал.ордера, то стоплос переставляем в профит на расстояние от текущей цены = CloseProcentProfit/100* ProcentProfit/100*ТП.

Е. Трал тейкпрофита вирт. ордера (при bVTralSL и заданных ProcentProfit, CloseProcentProfit)
Если цена уходит в убыток вирт.ордера на расстояние ProcentProfit/100*СЛ, то тейкпрофит вирт.ордера на расстояние от текущей цены = CloseProcentProfit/100* ProcentProfit/100*СЛ.
где СЛ - размер стоплоса вирт.ордера

Ж. Инфопанель виртуальных ордеров (при bVirtInfo=true ) Панель выводится в виде объектов справа
Overdraft Profit System VIRTUAL
Текущий ордер: Sell 1.31437 | 1.31568  | 145п. | 65$
……………………….. 
Вирт.баланс: 5000 (= сумме результатов всех вирт.ордеров + вирт.пополнений)
Всего ордеров:  Sell 11 | Buy 14 (в памяти)
Прибыль: 0.00000  (всех ордеров в памяти)
Убыток: 0.00000  (всех ордеров в памяти)
Итого: 0.00000    (прибыль + убыток)

Примечание: Если последний ордер Бай, то надпись "текущий ордер" зелёным (не синим), иначе красным.  

Ж. Инфопанель реальных ордеров (при bRealInfo=true ) Панель выводится в виде объектов справа
Overdraft Profit System REAL
Текущий ордер: Sell 1.31437 | 0.00000 | 145п. | 65$
……………………….. 
Всего ордеров:  Sell 11 | Buy 14 (сканируем всю историю)
Прибыль: 0.00000  (за все время)
Убыток: 0.00000  (за все время)
Итого: 0.00000   (прибыль + убыток)
Сумма компенсаций: 7п/70$ (сумма разниц между ценой открытия виртуального и реального.)

Примечание: Если текущий ордер Бай, то надпись "текущий ордер" зелёным (не синим), иначе красным.  

З. Инфопанель про спред (при bSpreadInfo=true) Панель выводится в виде объектов справа
Метод компенсации: 1
Текущий спред: 2 п.
Фиксированный спред: 5п. (вывод параметра FixSpread)
Средний спред: 17 п.
Компенсация: 2п. (требуемая разница между ценой открытия виртуального и реального ордера)
Важно! Когда какой либо из режимов компенсации работает, то индикация отображалась жёлтым цветом.
Важно! Эксперт суммирует компенсации по всей истории ордеров. То есть сканируются все ордера истории и суммируется их компенсация, указанная в комментарии.

И. Пожелания к коду и журналу
Оформление кода с комментариями, выделять основные блоки кода, описывать значение параметров настроек советника, мусор в коде не оставлять при компиляции не должно быть ошибок и предупреждений. 
Вести историю новых версий в коде и описание того что было сделано, в том числе как он открывает и закрывает ордер, своими профессиональными словами.
Строки в журнал, которые советник должен писать когда он работает:
- Открыл V виртуальный EURUSD Sell с объёмом 0.1 по цене 0.00000 идентификатор ордера ID: 1768570
- Открыл R реальный ордер EURUSD Buy с объёмом 0.1 по цене 0.0000 идентификатор вирт.ордера ID: 79849643 
- Закрыл V виртуальный ордер EURUSD Sell с объёмом 0.1 по цене 0.00000 идентификатор ордера ID: 1768570
- Закрыл R реальный ордер EURUSD Buy с объёмом 0.1  по цене 0.00000 идентификатор вирт.ордера ID: 79849643
Делать попытки открытия/закрытия при реквоте 
Удалять объекты инфопанели при удалении советника с чарта или выключении панели в настройках.
Открытие и закрытие виртуального ордера должно визуально отображаться как ордера в тестере.
Писать в журнал, по какому из методов было открытие ордера
Прокомментировать код который относится к внешним параметрам эксперта. 
*/