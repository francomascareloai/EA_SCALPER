#property copyright "TPO: Time Price Opportunity, v2.5.7491. © 2009-2010 Plus."
#property link      "http://fxcoder.ru, plusfx@ya.ru, skype:plusfx"

#property indicator_chart_window

// Параметры расчетов
extern int RangePeriod = PERIOD_D1;				// ТФ диапазона, должен быть одним из стандартных
extern int RangeCount = 20;						// количество диапазонов/гистограмм

//tf#extern string TimeFrom = "00:00";			// начала диапазона (внутри суток)
//tf#extern string TimeTo = "00:00";			// конец диапазона (внутри суток) + 1 минута

extern int ModeStep = 10;						// шаг поиска мод, фактически в 2 раза больше + 1
int Smooth = 0;									// глубина сглаживания, применяется алгоритм последовательного усреднения триад указанное число раз
extern int PriceStep = 0;						// шаг цены, 0 - авто (см. #1)
extern int DataPeriod = 1;						// период для данных, минутки - самые точные
bool ShowHorizon = true;						// показать горизонт данных

// Гистограмма
extern color HGColor = C'160,192,224';			// цвет гистограммы
extern int HGStyle = 1;							// стиль гистограммы: 0 - линии, 1 - пустые прямоугольники, 2 - заполненные прямоугольники
extern color ModeColor = Blue;					// цвет мод
extern color MaxModeColor = CLR_NONE;			// выделить максимум

int HGLineWidth = 1;							// ширина линий гистограммы
double Zoom = 0;								// масштаб гистограммы, 0 - автомасштаб

int ModeWidth = 1;								// толщина мод
int ModeStyle = STYLE_SOLID;					// стиль мод

// Служебные
extern string Id = "+tpo";						// префикс имен линий

int WaitSeconds = 1;							// минимальное время, в секундах, между обновлениями
int TickMethod = 1;								// метод имитации тиков: 0 - Low >> High, 1 - Open > Low(High) > High(Low) > Close, 2 - HLC, 3 - HL, 4 - Среднетиковый псевдо-объём
												// +4 - без учета объёма, +8 - с учетом объёма и длины бара.

string onp;

datetime drawHistory[];		// история рисования
datetime lastTime = 0;		// последнее времся запуска
bool lastOK = false;

double hgPoint;				// минимальное изменение цены
int modeStep = 0;
int smooth = 0;

bool showHG, showModes, showMaxMode;
bool hgBack = true;
bool hgUseRectangles = false;

// интерпретация пользовательских данных по времени
//tf#string timeFrom = "00:00";
//tf#string timeTo = "23:59";
//tf#bool filterTime = false;


#define ERR_HISTORY_WILL_UPDATED 4066


int init()
{
	onp = Id + " " + RangePeriod + " ";

	hgPoint = Point;
	
	bool is5digits = ((Digits == 3) || (Digits == 5)) && (MarketInfo(Symbol(), MODE_PROFITCALCMODE) == 0);
	
	//#1
	if (PriceStep == 0)
	{
		if (is5digits)
			hgPoint = Point * 10.0;
	}
	else
	{
		hgPoint = Point * PriceStep;
	}


	modeStep = ModeStep * Point / hgPoint;
	smooth = Smooth;
	if (is5digits)
	{
		 modeStep *= 10;
	}
	

	ArrayResize(drawHistory, 0);
	
	// настройки отображения	
	showHG = (HGColor != CLR_NONE) && (HGColor != -16777216);
	showModes = (ModeColor != CLR_NONE) && (ModeColor != -16777216);
	showMaxMode = (MaxModeColor != CLR_NONE) && (MaxModeColor != -16777216);
	
	// корректируем параметры стиля
	if (HGStyle == 1)
	{
		hgBack = false;
		hgUseRectangles = true;
	}
	else if (HGStyle == 2)
	{
		hgBack = true;
		hgUseRectangles = true;
	}
	
	// проверяем входные данные по времени
	//tf#datetime tf = StrToTime("2000.01.01 " + TimeFrom);
	//tf#datetime tt = StrToTime("2000.01.01 " + TimeTo) - 1; // не включаем правую границу (1 минута, т.к. мин. ТФ М1)

	//tf#filterTime = tt >= tf;
	
	//tf#if (filterTime)
	//tf#{
	//tf#	timeFrom = TimeToStr(tf, TIME_MINUTES);
	//tf#	timeTo = TimeToStr(tt, TIME_MINUTES);	
	//tf#}
	
	//tf#Comment("Filter time: " + filterTime + "\n" +
	//tf#	"From: " + timeFrom + "\n" +
	//tf#	"To: " + timeTo + "\n");
}

int start()
{
	datetime currentTime = TimeLocal();

	// всегда обновляемся на новом баре...
	if ((Volume[0] > 1) && lastOK)
	{
		// ...и не чаще, чем раз в несколько секунд
		if (currentTime - lastTime < WaitSeconds)
			return(0);
	}

	lastTime = currentTime;

	if (ShowHorizon)
	{
		datetime hz = iTime(NULL, DataPeriod, iBars(NULL, DataPeriod) - 1);
		drawVLine(onp + "hz", hz, Red, 1, STYLE_DOT, false);
	}

	double vh[], hLow;
	
	lastOK = true;
	for (int i = 0; i < RangeCount; i++)//1 - ShowLast
	{
		int barFrom, barTo, m1BarFrom, m1BarTo;

		datetime timeFrom = iTime(NULL, RangePeriod, i);

		datetime timeTo = Time[0];
		if (i != 0)
			timeTo = iTime(NULL, RangePeriod, i - 1);


		if (getRange(timeFrom, timeTo, barFrom, barTo, m1BarFrom, m1BarTo, DataPeriod))
		{
			if (!checkDrawHistory(timeFrom) || (i == 0))
			{
				int count = getHGByRates(m1BarFrom, m1BarTo, TickMethod, vh, hLow, hgPoint, DataPeriod);
				
				if (count > 0)
				{
					if (smooth > 0)
					{
						count = smoothHG(vh, smooth);
						//hLow -= smooth * hgPoint;
					}

					if (i != 0)
						addDrawHistory(timeFrom);

					// определение масштаба
					double zoom = Zoom*0.000001;
					if (zoom <= 0)
					{
						double maxVolume = vh[ArrayMaximum(vh)];
						zoom = (barFrom - barTo) / maxVolume;
					}

					// рисуем
					if (showHG)
					{
						string prefix = onp + "hg " + TimeToStr(timeFrom) + " ";
						drawHG(prefix, vh, hLow, barFrom, HGColor, HGColor, zoom, HGLineWidth, hgPoint);
					}
					
					if (showModes || showMaxMode)
						drawModes(vh, hLow, barFrom, zoom, hgPoint);
				}
			}
		}
		else
		{
			lastOK = false;
		}
	}

	return(0);
}

int deinit()
{
	clearChart(onp);
	return(0);
}

// проверяет, рисовались ли для данной даты уровни
bool checkDrawHistory(datetime time)
{
	int count = ArraySize(drawHistory);
	bool r = false;
	for (int i = 0; i < count; i++)
	{
		if (drawHistory[i] == time)
		{
			r = true;
			break;
		}
	}
	return(r);
}

// добавить отрисованный участок в историю
void addDrawHistory(datetime time)
{
	if (!checkDrawHistory(time))
	{
		int count = ArraySize(drawHistory);
		ArrayResize(drawHistory, count + 1);
		drawHistory[count] = time;
	}
}

// нарисовать моды гистограммы
void drawModes(double& vh[], double hLow, int barFrom, double zoom, double point)
{
	int modes[], modeCount, j;
	double price;

	// поиск мод
	modeCount = getModesIndexes(vh, modeStep, modes);

	// макс. мода
	double max = 0;
	if (showMaxMode)
	{
		for (j = 0; j < modeCount; j++)
			if (vh[modes[j]] > max)
				max = vh[modes[j]];
	}

	datetime timeFrom = getBarTime(barFrom);

	clearChart(onp + "mode " + TimeToStr(timeFrom) + " ");

	// всегда ужирняем моды в режимах рисования прямоугольниками
	bool back = false;
	if (hgUseRectangles)
		back = true;
	
	string on;
	
	for (j = 0; j < modeCount; j++)
	{
		double v = zoom * vh[modes[j]];

		// не рисовать коротких линий (меньше бара ТФ), глючит при выделении границ
		if (MathAbs(v) > 0)
		{
			price = hLow + modes[j]*point;
			datetime timeTo = getBarTime(barFrom - v);

			on = onp + "mode " + TimeToStr(timeFrom) + " " + DoubleToStr(price, Digits);
			if (showMaxMode && (MathAbs(vh[modes[j]] - max) < point))	// максимальная мода
			{
				drawTrend(on, timeFrom, price, timeTo, price, MaxModeColor, ModeWidth, ModeStyle, back, false, 0, hgUseRectangles);

				// в режиме рисования прямоугольниками моды рисуем линиями, иначе они скрываются
				if (hgUseRectangles && back)
					drawTrend(on + "+", timeFrom, price, timeTo, price, MaxModeColor, ModeWidth, ModeStyle, false, false, 0, false);
			}
			else if (showModes)	// обычная мода
			{
				drawTrend(on, timeFrom, price, timeTo, price, ModeColor, ModeWidth, ModeStyle, back, false, 0, hgUseRectangles);
				
				// в режиме рисования прямоугольниками моды рисуем линиями, иначе они скрываются
				if (hgUseRectangles && back)
					drawTrend(on + "+", timeFrom, price, timeTo, price, ModeColor, ModeWidth, ModeStyle, false, false, 0, false);
			}
		}
	}
}

datetime getBarTime(int shift, int period = 0)
{
	if (period == 0)
		period = Period();

	if (shift >= 0)
		return(iTime(Symbol(), period, shift));
	else
		return(iTime(Symbol(), period, 0) - shift*period*60);
}

/// Очистить график от своих объектов
int clearChart(string prefix)
{
	int obj_total = ObjectsTotal();
	string name;
	
	int count = 0;
	for (int i = obj_total - 1; i >= 0; i--)
	{
		name = ObjectName(i);
		if (StringFind(name, prefix) == 0)
		{
			ObjectDelete(name);
			count++;
		}			
	}
	return(count);
}

void drawVLine(string name, datetime time1, color lineColor = Gray, int width = 1, int style = STYLE_SOLID, bool back = true)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);
		
	ObjectCreate(name, OBJ_VLINE, 0, time1, 0);
	ObjectSet(name, OBJPROP_COLOR, lineColor);
	ObjectSet(name, OBJPROP_BACK, back);
	ObjectSet(name, OBJPROP_STYLE, style);
	ObjectSet(name, OBJPROP_WIDTH, width);
}

void drawTrend(string name, datetime time1, double price1, datetime timeTo, double price2, 
	color lineColor, int width, int style, bool back, bool ray, int window, bool useRectangle)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);

	if (useRectangle)
		ObjectCreate(name, OBJ_RECTANGLE, window, time1, price1 - hgPoint / 2.0, timeTo, price2 + hgPoint / 2.0);
	else
		ObjectCreate(name, OBJ_TREND, window, time1, price1, timeTo, price2);
		
	ObjectSet(name, OBJPROP_BACK, back);
	ObjectSet(name, OBJPROP_COLOR, lineColor);
	ObjectSet(name, OBJPROP_STYLE, style);
	ObjectSet(name, OBJPROP_WIDTH, width);
	ObjectSet(name, OBJPROP_RAY, ray);
}

// нарисовать гистограмму (+цвет +point)
void drawHG(string prefix, double& h[], double low, int barFrom, color bgColor, color lineColor, double zoom, int width, double point)
{
	double max = h[ArrayMaximum(h)];
	if (max == 0)
		return(0);

	int bgR = (bgColor & 0xFF0000) >> 16;
	int bgG = (bgColor & 0x00FF00) >> 8;
	int bgB = (bgColor & 0x0000FF);

	int lineR = (lineColor & 0xFF0000) >> 16;
	int lineG = (lineColor & 0x00FF00) >> 8;
	int lineB = (lineColor & 0x0000FF);
	
	int dR = lineR - bgR;
	int dG = lineG - bgG;
	int dB = lineB - bgB;

	int hc = ArraySize(h);
	for (int i = 0; i < hc; i++)
	{
		double price = NormalizeDouble(low + i*point, Digits);
		
		int barTo = barFrom - h[i]*zoom;
		
		// раскраска градиентом
		double fade = h[i] / max;
		int r = MathMax(MathMin(bgR + fade * dR, 255), 0);
		int g = MathMax(MathMin(bgG + fade * dG, 255), 0);
		int b = MathMax(MathMin(bgB + fade * dB, 255), 0);
		color cl = (r << 16) + (g << 8) + b;
		
		datetime timeFrom = getBarTime(barFrom);
		datetime timeTo = getBarTime(barTo);

		if (barFrom != barTo)
			drawTrend(prefix + DoubleToStr(price, Digits), timeFrom, price, timeTo, price, cl, width, STYLE_SOLID, hgBack, false, 0, hgUseRectangles);
	}
}

// получить параметры диапазона
bool getRange(datetime timeFrom, datetime timeTo, int& barFrom, int& barTo, 
	int& p1BarFrom, int& p1BarTo, int period)
{
	// диапазон баров в текущем ТФ (для рисования)

	barFrom = iBarShift(NULL, 0, timeFrom);
	datetime time = Time[barFrom];
	int bar = iBarShift(NULL, 0, time);
	time = Time[bar];
	if (time != timeFrom)
		barFrom--;
											
	barTo = iBarShift(NULL, 0, timeTo);
	time = Time[barTo];
	bar = iBarShift(NULL, 0, time);
	time = Time[bar];
	if (time == timeFrom)
		barTo++;

	if (barFrom < barTo)
		return(false);


	// диапазон баров ТФ period (для получения данных)

	p1BarFrom = iBarShift(NULL, period, timeFrom);
	time = iTime(NULL, period, p1BarFrom);
	if (time != timeFrom)
		p1BarFrom--;
		
	p1BarTo = iBarShift(NULL, period, timeTo);
	time = iTime(NULL, period, p1BarTo);
	if (timeTo == time)
		p1BarTo++;
		
	if (p1BarFrom < p1BarTo)
		return(false);

	return(true);
}

/// Получить гистограмму распределения цен
///		m1BarFrom, m1BarTo - границы диапазона, заданные номерами баров минуток
/// Возвращает:
///		результат - количество цен в гистограмме, 0 - ошибка
///		vh - гистограмма
///		hLow - нижняя граница гистограммы
///		point - шаг цены
///		dataPeriod - таймфрейм данныхint
int getHGByRates(int m1BarFrom, int m1BarTo, int tickMethod, double& vh[], double& hLow, double point, int dataPeriod)
{
	double rates[][6];
	double hHigh;

	// предположительное (и максимальное) количество минуток
	int rCount = getRates(m1BarFrom, m1BarTo, rates, hLow, hHigh, dataPeriod);
	//Print("rCount: " + rCount);
	
	if (rCount != 0)
	{
		hLow = NormalizeDouble(MathRound(hLow / point) * point, Digits);
		hHigh = NormalizeDouble(MathRound(hHigh / point) * point, Digits);
		
		//Print("hLow: " + hLow);
		//Print("hHigh: " + hHigh);

		// инициализируем массив гистограммы
		int hCount = hHigh/point - hLow/point + 1;
		//Print("hCount: " + hCount);
		ArrayResize(vh, hCount);
		ArrayInitialize(vh, 0);

		int iCount = m1BarFrom - m1BarTo + 1;
		int hc = mql_GetHGByRates(rates, rCount, iCount, m1BarTo, tickMethod, point, hLow, hCount, vh);
		//Print("hc: " + hc);

		if (hc == hCount)
			return(hc);
		else
			return(0);
	}
	else
	{
		//Print("Error: no rates");
		return(0);
	}
}

/// Получить гистограмму распределения цен средствами MQL (аналог vlib_GetHGByRates
int mql_GetHGByRates(double& rates[][6], int rcount, int icount, int ishift, int tickMethod, double point, 
	double hLow, int hCount, double& vh[])
{
	int pri;	// индекс цены
	double dv;	// объем на тик

	int hLowI = MathRound(hLow / point);
	//Print(rcount);

	for (int j = 0; j < icount; j++)
	{
		// фильтр по времени
		
	
		//int i = rcount - 1 - j - ishift;
		int i = j + ishift;

		double o = rates[i][1];
		int oi = MathRound(o/point);

		double h = rates[i][3];
		int hi = MathRound(h/point);

		double l = rates[i][2];
		int li = MathRound(l/point);

		double c = rates[i][4];
		int ci = MathRound(c/point);

		double v = rates[i][5];

		//Print("oi: " + oi);
		//Print("hLowI: " + hLowI);
		//Print("oi-hLowI: " + (oi-hLowI));
		//Print("rate: " + v);

		int rangeMin = hLowI;
		int rangeMax = hLowI + hCount - 1;

		if (tickMethod == 0)						// равная вероятность всех цен бара
		{
			dv = v / (hi - li + 1.0);
			for (pri = li; pri <= hi; pri++)
				vh[pri - hLowI] += dv;
		}
		else if (tickMethod == 1)					// имитация тиков
		{
			if (c >= o)		// бычья свеча
			{
				dv = v / (oi - li + hi - li + hi - ci + 1.0);

				for (pri = oi; pri >= li; pri--)		// open --> low
					vh[pri - hLowI] += dv;

				for (pri = li + 1; pri <= hi; pri++)	// low+1 ++> high
					vh[pri - hLowI] += dv;
				
				for (pri = hi - 1; pri >= ci; pri--)	// high-1 --> close
					vh[pri - hLowI] += dv;
			}
			else			// медвежья свеча
			{
				dv = v / (hi - oi + hi - li + ci - li + 1.0);

				for (pri = oi; pri <= hi; pri++)		// open ++> high
					vh[pri - hLowI] += dv;
				
				for (pri = hi - 1; pri >= li; pri--)	// high-1 --> low
					vh[pri - hLowI] += dv;
				
				for (pri = li + 1; pri <= ci; pri++)	// low+1 ++> close
					vh[pri - hLowI] += dv;
			}
		}
		else if (tickMethod == 2)					// только цены бара
		{
			dv = v / 4.0;
			vh[oi - hLowI] += dv;
			vh[hi - hLowI] += dv;
			vh[li - hLowI] += dv;
			vh[ci - hLowI] += dv;
		}
		else if (tickMethod == 3)					// только хай и лоу
		{
			dv = v / 2.0;
			vh[hi - hLowI] += dv;
			vh[li - hLowI] += dv;
		}
		else if (tickMethod == 4)					// СТПО
		{
			dv = 1.0 / v;
			if (c >= o)		// бычья свеча
			{

				for (pri = oi; pri >= li; pri--)		// open --> low
					vh[pri - hLowI] += dv;

				for (pri = li + 1; pri <= hi; pri++)	// low+1 ++> high
					vh[pri - hLowI] += dv;
				
				for (pri = hi - 1; pri >= ci; pri--)	// high-1 --> close
					vh[pri - hLowI] += dv;
			}
			else			// медвежья свеча
			{
				for (pri = oi; pri <= hi; pri++)		// open ++> high
					vh[pri - hLowI] += dv;
				
				for (pri = hi - 1; pri >= li; pri--)	// high-1 --> low
					vh[pri - hLowI] += dv;
				
				for (pri = li + 1; pri <= ci; pri++)	// low+1 ++> close
					vh[pri - hLowI] += dv;
			}
		}		
		
	}
	
	return(hCount);
}

/// Получить моды на основе гистограммы и сглаженной гистограммы (быстрый метод, без сглаживания)
int getModesIndexes(double& vh[], int modeStep, int& modes[]) //, int& maxModeIndex
{
	int modeCount = 0;
	ArrayResize(modes, modeCount);

	int count = ArraySize(vh);
	
	// ищем максимумы по участкам
	for (int i = modeStep; i < count - modeStep; i++)
	{
		int maxFrom = i-modeStep;
		int maxRange = 2*modeStep + 1;
		int maxTo = maxFrom + maxRange - 1;

		int k = ArrayMaximum(vh, maxRange, maxFrom);
		
		if (k == i)
		{
			for (int j = i - modeStep; j <= i + modeStep; j++)
			{
				if (vh[j] == vh[k])
				{
					modeCount++;
					ArrayResize(modes, modeCount);
					modes[modeCount-1] = j;
				}
			}
		}
		
	}

	return(modeCount);
}


/// Получить минутки для заданного диапазона (указывается в номерах баров минуток)
int getRates(int barFrom, int barTo, double& rates[][6], double& ilowest, double& ihighest, int period)
{
	// предположительное (и максимальное) количество минуток
	int iCount = barFrom - barTo + 1;
	
	int count = ArrayCopyRates(rates, NULL, period);
	if (GetLastError() == ERR_HISTORY_WILL_UPDATED)
	{
		return(0);
	}
	else
	{
		if (count >= barFrom - 1)
		{
			ilowest = iLow(NULL, period, iLowest(NULL, period, MODE_LOW, iCount, barTo));
			ihighest = iHigh(NULL, period, iHighest(NULL, period, MODE_HIGH, iCount, barTo));
			//Print("ilowest:" + ilowest);
			//Print("ihighest:" + ihighest);
			return(count);
		}
		else
		{
			return(0);
		}
	}
}


int smoothHG(double& vh[], int depth)
{
	// расширяем массив (необходимо для корректных расчетов)
	
	int vCount = ArraySize(vh);

	if (depth == 0)
		return(vCount);

	int newCount = vCount + 2 * depth;
	
	// сдвигаем значения и зануляем хвосты
	double th[];
	ArrayResize(th, newCount);
	ArrayInitialize(th, 0);

	ArrayCopy(th, vh, depth, 0);

	ArrayResize(vh, newCount);
	ArrayInitialize(vh, 0);

	// последовательное усреднение
	for (int d = 0; d < depth; d++)
	{
		for (int i = -d; i < vCount + d; i++)
		{
			vh[i+depth] = (th[i+depth-1] + th[i+depth] + th[i+depth+1]) / 3.0;
		}
		
		ArrayCopy(th, vh);
	}

	ArrayResize(vh, vCount);
	ArrayCopy(vh, th, 0, depth, vCount);


	return(newCount);
}