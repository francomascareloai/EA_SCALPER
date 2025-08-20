#property copyright "Стандартная оценка. StdScore v4.2. © FXcoder"
#property link      "http://fxcoder.blogspot.com"
#property strict

#property indicator_separate_window
#property indicator_buffers 11            // The first buffer is for the value, other 10 are for candle drawing
#property indicator_color1  clrRoyalBlue  // Value
#property indicator_color2  clrLimeGreen  // BullBody
#property indicator_color3  clrLimeGreen  // BullBody2
#property indicator_color4  clrRed        // BearBody
#property indicator_color5  clrRed        // BearBody2
#property indicator_color6  clrNONE       // BodyMask
#property indicator_color7  clrLimeGreen  // BullShadow
#property indicator_color8  clrLimeGreen  // BullShadow2
#property indicator_color9  clrRed        // BearShadow
#property indicator_color10 clrRed        // BearShadow2
#property indicator_color11 clrNONE       // ShadowMask

#property indicator_width1 1

#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DOT

#property indicator_level1 2
#property indicator_level2 0
#property indicator_level3 -2

#property indicator_minimum -4
#property indicator_maximum 4

#define COLOR_IS_NONE(C) (((C) >> 24) != 0)

enum ENUM_CHART_TYPE
{
	CHART_TYPE_LINE = 0,                            // Line
	CHART_TYPE_BAR = 1,                             // Bar
	CHART_TYPE_CANDLESTICK = 2                      // Candlestick
};

input int N = 20;                                          // Period
input string Sym = "";                                     // Symbol
input bool Reverse = false;                                // Reverse
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_MEDIAN;      // Applied price
input ENUM_APPLIED_PRICE ValuePrice = PRICE_CLOSE;         // Value and line applied price

input ENUM_CHART_TYPE ChartType = CHART_TYPE_CANDLESTICK;  // Chart type
input color BullColor = clrRoyalBlue;                      // Bull color
input color BearColor = clrCrimson;                        // Bear color
input color BackColor = clrNONE;                           // Background color (None=auto)
input int BodyWidth = 0;                                   // Body width (0=auto)

input int MaxBars = 0;                                     // Maximum bars
input int Shift = 0;                                       // Shift

double Value[], BullBody[], BullBody2[], BearBody[], BearBody2[], BodyMask[], BullShadow[], BullShadow2[], BearShadow[], BearShadow2[], ShadowMask[];

datetime _lastTickTime = 0;
int _bodyWidth = 2;
color _bgColor = clrNONE;
string _sym;
int _n;

int start()
{
	UpdateBodyWidth();
	UpdateMaskColor();

	int countedBars = IndicatorCounted();

	if (countedBars > 0)
		countedBars--;

	int barsCount = Bars - countedBars;

	if (MaxBars > 0)
	{
		if (Bars - countedBars > 2)
		{
			barsCount = MaxBars;
			ClearData();
		}
		else
		{
			ClearData(MaxBars);
			barsCount = MathMin(barsCount, MaxBars);
		}
	}

	// в мультивалютном пересчитываем несколько последних баров, а не один
	if (_lastTickTime != 0 && _sym != Symbol())
		barsCount = MathMax(barsCount, iBarShift(Symbol(), Period(), _lastTickTime, false) + 1);

	double o, h, l, c, value, ma, sd;

	for (int i = barsCount - 1; i >= 0; i--)
	{
		ClearData(i);

		o = EMPTY_VALUE;
		h = EMPTY_VALUE;
		l = EMPTY_VALUE;
		c = EMPTY_VALUE;
		value = EMPTY_VALUE;
		ma = EMPTY_VALUE;
		sd = 0;
		int si = i;

		if (_sym == Symbol())
		{
			o = Open[i];
			h = High[i];
			l = Low[i];
			c = Close[i];
		}
		else
		{
			// определить бар для другого символа
			datetime dt = iTime(Symbol(), Period(), i);
			si = iBarShift(_sym, Period(), dt, true);

			if (si != -1)
			{
				// бар тот же
				o = iOpen(_sym, Period(), si);
				h = iHigh(_sym, Period(), si);
				l = iLow(_sym, Period(), si);
				c = iClose(_sym, Period(), si);

				_lastTickTime = dt; // запоминаем время последнего тика
			}
			else
			{
				// в случае отсутствия данных по символу брать прошлый бар и его цену закрытия
				si = iBarShift(_sym, Period(), dt, false);

				if (si != -1)
				{
					// защита от подглядывания в будущее
					datetime sdt = iTime(_sym, Period(), si);

					if (sdt > dt)
						si++;

					o = iClose(_sym, Period(), si);
					h = o;
					l = o;
					c = o;
				}
			}
		}

		if (c != EMPTY_VALUE)
		{
			// Вычитание средней
			ma = iMA(_sym, Period(), _n, 0, MODE_SMA, AppliedPrice, si);

			if (ma > 0)
			{
				o = o - ma;
				h = h - ma;
				l = l - ma;
				c = c - ma;

				value = GetPrice(ValuePrice, o, h, l, c);

				// Деление на стандартное отклонение

				sd = iStdDev(_sym, Period(), _n, 0, MODE_SMA, AppliedPrice, si);

				if (sd > 0)
				{
					o = o / sd;
					h = h / sd;
					l = l / sd;
					c = c / sd;

					value = GetPrice(ValuePrice, o, h, l, c);

					if (Reverse)
					{
						o = -o;
						h = -h;
						l = -l;
						c = -c;

						// меняем местами верх и низ для корректной отрисовки
						Swap(h, l);

						value = GetPrice(ValuePrice, o, h, l, c);
					}
				} // sd > 0
			} // ma > 0
		} // c != EMPTY_VALUE

		Value[i] = value;

		if (ChartType != CHART_TYPE_LINE)
			DrawBar(o, h, l, c, i);
	} // for: bars loop

	return(0);
}

int init()
{
	_n = N >= 2 ? N : 2;
	_sym = Sym == "" ? Symbol() : UpperString(Sym);

	_bodyWidth = BodyWidth;

	if (ChartType == CHART_TYPE_LINE)
	{
		SetIndexStyle(0, DRAW_LINE, EMPTY, EMPTY, BullColor);
		SetIndexStyle(1, DRAW_NONE);
		SetIndexStyle(2, DRAW_NONE);
		SetIndexStyle(3, DRAW_NONE);
		SetIndexStyle(4, DRAW_NONE);
		SetIndexStyle(5, DRAW_NONE);
		SetIndexStyle(6, DRAW_NONE);
		SetIndexStyle(7, DRAW_NONE);
		SetIndexStyle(8, DRAW_NONE);
		SetIndexStyle(9, DRAW_NONE);
		SetIndexStyle(10, DRAW_NONE);
	}
	else
	{
		SetIndexStyle(0, DRAW_NONE, EMPTY, EMPTY, clrNONE);
		SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, _bodyWidth, BullColor);
		SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, _bodyWidth, BullColor);
		SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, _bodyWidth, BearColor);
		SetIndexStyle(4, DRAW_HISTOGRAM, EMPTY, _bodyWidth, BearColor);
		SetIndexStyle(5, DRAW_HISTOGRAM, EMPTY, _bodyWidth, _bgColor);
		SetIndexStyle(6, DRAW_HISTOGRAM, EMPTY, 1, BullColor);
		SetIndexStyle(7, DRAW_HISTOGRAM, EMPTY, 1, BullColor);
		SetIndexStyle(8, DRAW_HISTOGRAM, EMPTY, 1, BearColor);
		SetIndexStyle(9, DRAW_HISTOGRAM, EMPTY, 1, BearColor);
		SetIndexStyle(10, DRAW_HISTOGRAM, EMPTY, 1, _bgColor);
	}

	SetIndexBuffer(0, Value);
	SetIndexBuffer(1, BullBody);
	SetIndexBuffer(2, BullBody2);
	SetIndexBuffer(3, BearBody);
	SetIndexBuffer(4, BearBody2);
	SetIndexBuffer(5, BodyMask);
	SetIndexBuffer(6, BullShadow);
	SetIndexBuffer(7, BullShadow2);
	SetIndexBuffer(8, BearShadow);
	SetIndexBuffer(9, BearShadow2);
	SetIndexBuffer(10, ShadowMask);

	for (int i = 0; i <= 10; i++)
		SetIndexShift(i, Shift);

	SetIndexLabel(0, "Value");
	SetIndexLabel(1, "Bull Body");
	SetIndexLabel(2, "Bull Body 2");
	SetIndexLabel(3, "Bear Body");
	SetIndexLabel(4, "Bear Body 2");
	SetIndexLabel(5, "Body Mask");
	SetIndexLabel(6, "Bull Shadow");
	SetIndexLabel(7, "Bull Shadow 2");
	SetIndexLabel(8, "Bear Shadow");
	SetIndexLabel(9, "Bear Shadow 2");
	SetIndexLabel(10, "Shadow Mask");

	string name =
		"StdScore(" +
		(Reverse || _sym != Symbol()
			? (Reverse ? "1/" : "") + _sym + ","
			: "")
		 + IntegerToString(_n) + ")";

	IndicatorShortName(name);

	return(0);
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
	if (id == CHARTEVENT_CHART_CHANGE)
	{
		if (UpdateBodyWidth() || UpdateMaskColor())
			ChartRedraw();
	}
}

bool UpdateMaskColor()
{
	if (!ColorIsNone(BackColor))
		return(false);

	// Определить цвета фона
	color newBgColor = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);

	if (newBgColor == _bgColor)
		return(false);

	_bgColor = newBgColor;

	SetIndexStyle(5, DRAW_HISTOGRAM, EMPTY, EMPTY, _bgColor);
	SetIndexStyle(10, DRAW_HISTOGRAM, EMPTY, EMPTY, _bgColor);

	return(true);
}

bool UpdateBodyWidth()
{
	if (BodyWidth > 0)
		return(false);

	// Определить толщину тела бара
	int newBodyWidth = GetBarBodyWidth();

	if (newBodyWidth == 0)
		return(false);

	if (newBodyWidth == _bodyWidth)
		return(false);

	_bodyWidth = newBodyWidth;

	if (ChartType == CHART_TYPE_BAR)
	{
		for (int i = 6; i <= 10; i++)
			SetIndexStyle(i, DRAW_HISTOGRAM, EMPTY, _bodyWidth);
	}
	else
	{
		for (int i = 1; i <= 5; i++)
			SetIndexStyle(i, DRAW_HISTOGRAM, EMPTY, _bodyWidth);
	}

	return(true);
}

void ClearData(int bar = -1)
{
	if (bar == -1)
	{
		ArrayInitialize(Value, EMPTY_VALUE);
		ArrayInitialize(BullBody, EMPTY_VALUE);
		ArrayInitialize(BullBody2, EMPTY_VALUE);
		ArrayInitialize(BearBody, EMPTY_VALUE);
		ArrayInitialize(BearBody2, EMPTY_VALUE);
		ArrayInitialize(BodyMask, EMPTY_VALUE);
		ArrayInitialize(BullShadow, EMPTY_VALUE);
		ArrayInitialize(BullShadow2, EMPTY_VALUE);
		ArrayInitialize(BearShadow, EMPTY_VALUE);
		ArrayInitialize(BearShadow2, EMPTY_VALUE);
		ArrayInitialize(ShadowMask, EMPTY_VALUE);
	}
	else
	{
		Value[bar] = EMPTY_VALUE;
		BullBody[bar] = EMPTY_VALUE;
		BullBody2[bar] = EMPTY_VALUE;
		BearBody[bar] = EMPTY_VALUE;
		BearBody2[bar] = EMPTY_VALUE;
		BodyMask[bar] = EMPTY_VALUE;
		BullShadow[bar] = EMPTY_VALUE;
		BullShadow2[bar] = EMPTY_VALUE;
		BearShadow[bar] = EMPTY_VALUE;
		BearShadow2[bar] = EMPTY_VALUE;
		ShadowMask[bar] = EMPTY_VALUE;
	}
}

double GetPrice(int ap, double o, double h, double l, double c)
{
	switch(ap)
	{
		case PRICE_CLOSE: return(c);
		case PRICE_OPEN: return(o);
		case PRICE_HIGH: return(h);
		case PRICE_LOW: return(l);
		case PRICE_MEDIAN: return((h + l) / 2.0);
		case PRICE_TYPICAL: return((h + l + c) / 3.0);
		case PRICE_WEIGHTED: return((h + l + 2.0 * c) / 4.0);
	}

	return(0);
}

// Нарисовать бар
void DrawBar(double open, double high, double low, double close, int bar)
{
	bool isBull = close >= open;
	bool isBear = !isBull;

	double bodyMax = open > close ? open : close;
	double bodyMin = open < close ? open : close;

	if (ChartType == CHART_TYPE_CANDLESTICK)
	{
		BullBody[bar] = isBull && (close >= 0) ? close : EMPTY_VALUE;
		BullBody2[bar] = isBull && (open < 0) ? open : EMPTY_VALUE;

		BearBody[bar] = isBear && (open >= 0) ? open : EMPTY_VALUE;
		BearBody2[bar] = isBear && (close < 0) ? close : EMPTY_VALUE;

		BodyMask[bar] = (bodyMin > 0) ? bodyMin : (bodyMax < 0 ? bodyMax : EMPTY_VALUE);
	}

	BullShadow[bar] = isBull && (high >= 0) ? high : EMPTY_VALUE;
	BullShadow2[bar] = isBull && (low < 0) ? low : EMPTY_VALUE;

	BearShadow[bar] = isBear && (high >= 0) ? high : EMPTY_VALUE;
	BearShadow2[bar] = isBear && (low < 0) ? low : EMPTY_VALUE;

	ShadowMask[bar] = low >= 0 ? low : (high < 0 ? high : EMPTY_VALUE);
}

int GetBarBodyWidth(const long chartId = 0)
{
	long chartScale;

	if (!ChartGetInteger(chartId, CHART_SCALE, 0, chartScale))
		return(0);

	if (chartScale == 0)
		return(1);

	if (chartScale == 1)
		return(1);

	if (chartScale == 2)
		return(2);

	if (chartScale == 3)
		return(3);

	if (chartScale == 4)
		return(6);

	if (chartScale == 5)
		return(12);

	return(0);
}

template <typename T>
void Swap(T &value1, T &value2)
{
	T tmp = value1;
	value1 = value2;
	value2 = tmp;
}

bool ColorIsNone(const color c)
{
	return(COLOR_IS_NONE(c));
}

string UpperString(string s)
{
	StringToUpper(s);
	return(s);
}

/*
Список изменений

4.2
	* изменены ссылки на сайт
	* список изменений в коде
	* рефакторинг

4.1
	* удалены устаревшие функции
	* более оперативное обновление ширины тела свечи
	* более оперативное реагирование на изменение цвета фона

4.0
	* убрано принудительное вертикальное смещение на 100
	* добавлен режим отображения с помощью баров
	* переименованы некоторые параметры

3.1
	* совместимость с MetaTrader версии 4.00 Build 600 и новее

Лицензия:

Разрешается повторное распространение и использование как в виде исходного кода, так и в двоичной форме, с изменениями
или без, при соблюдении следующих условий:

При повторном распространении исходного кода должно оставаться указанное выше уведомление об авторском праве, этот
список условий и последующий отказ от гарантий.

При повторном распространении двоичного кода должна сохраняться указанная выше информация об авторском праве, этот
список условий и последующий отказ от гарантий в документации и/или в других материалах, поставляемых при распространении.

Ни название FXcoder, ни имена ее сотрудников не могут быть использованы в качестве поддержки или продвижения продуктов,
основанных на этом ПО без предварительного письменного разрешения.

ЭТА ПРОГРАММА ПРЕДОСТАВЛЕНА ВЛАДЕЛЬЦАМИ АВТОРСКИХ ПРАВ И/ИЛИ ДРУГИМИ СТОРОНАМИ «КАК ОНА ЕСТЬ» БЕЗ КАКОГО-ЛИБО ВИДА
ГАРАНТИЙ, ВЫРАЖЕННЫХ ЯВНО ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ ИМИ, ПОДРАЗУМЕВАЕМЫЕ ГАРАНТИИ КОММЕРЧЕСКОЙ
ЦЕННОСТИ И ПРИГОДНОСТИ ДЛЯ КОНКРЕТНОЙ ЦЕЛИ. НИ В КОЕМ СЛУЧАЕ, ЕСЛИ НЕ ТРЕБУЕТСЯ СООТВЕТСТВУЮЩИМ ЗАКОНОМ, ИЛИ НЕ
УСТАНОВЛЕНО В УСТНОЙ ФОРМЕ, НИ ОДИН ВЛАДЕЛЕЦ АВТОРСКИХ ПРАВ И НИ ОДНО ДРУГОЕ ЛИЦО, КОТОРОЕ МОЖЕТ ИЗМЕНЯТЬ И/ИЛИ
ПОВТОРНО РАСПРОСТРАНЯТЬ ПРОГРАММУ, КАК БЫЛО СКАЗАНО ВЫШЕ, НЕ НЕСЁТ ОТВЕТСТВЕННОСТИ, ВКЛЮЧАЯ ЛЮБЫЕ ОБЩИЕ, СЛУЧАЙНЫЕ,
СПЕЦИАЛЬНЫЕ ИЛИ ПОСЛЕДОВАВШИЕ УБЫТКИ, ВСЛЕДСТВИЕ ИСПОЛЬЗОВАНИЯ ИЛИ НЕВОЗМОЖНОСТИ ИСПОЛЬЗОВАНИЯ ПРОГРАММЫ (ВКЛЮЧАЯ, НО
НЕ ОГРАНИЧИВАЯСЬ ПОТЕРЕЙ ДАННЫХ, ИЛИ ДАННЫМИ, СТАВШИМИ НЕПРАВИЛЬНЫМИ, ИЛИ ПОТЕРЯМИ ПРИНЕСЕННЫМИ ИЗ-ЗА ВАС ИЛИ ТРЕТЬИХ
ЛИЦ, ИЛИ ОТКАЗОМ ПРОГРАММЫ РАБОТАТЬ СОВМЕСТНО С ДРУГИМИ ПРОГРАММАМИ), ДАЖЕ ЕСЛИ ТАКОЙ ВЛАДЕЛЕЦ ИЛИ ДРУГОЕ ЛИЦО БЫЛИ
ИЗВЕЩЕНЫ О ВОЗМОЖНОСТИ ТАКИХ УБЫТКОВ.

License:

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following
disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
disclaimer in the documentation and/or other materials provided with the distribution.

Neither the name of the FXcoder nor the names of its contributors may be used to endorse or promote products derived
from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

// 2016-02-04 06:43:58 UTC. MQLMake 1.37. © FXcoder