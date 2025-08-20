//+------------------------------------------------------------------+
//|                                           Send_Pending_Order.mq4 |
//|                                                        komposter |
//|                                      mailto:komposterius@mail.ru |
//+------------------------------------------------------------------+
#property copyright "komposter"
#property link      "mailto:komposterius@mail.ru"
/*
-----------------------------В-Н-И-М-А-Н-И-Е---------------------------------
Перед запуском скрипта настоятельно рекомендую изучить следующее руководство:

Скрипт предназначен для установки отложенного ордера.
Для этого необходимо:
 1) Ознакомиться с данным руководством =), !установить значения по умолчанию! (находятся под описанием,
 	 начинаются и заканчиваются строкой //+----------------------------------------------+ ),
 	 разрешить импорт внешних экспертов через меню
 	 "Сервис" -> "Настройки" -> "Советники" -> "Разрешить импортирование внешних экспертов"
 	 (необходимо для описания ошибки, которая может возникнуть при установке ордера)
 2) Перетащить скрипт на график. При этом учитывать, что место прикрепления - это будущая
 	 цена открытия (OpenPrice). В процессе установки её можно будет менять, но для упрощения
 	 работы рекомендую перетаскивать скрипт сразу на нужный уровень.
 3) Переместить все линии на необходимые уровни:
		- Open_Price_Line (по умолчанию - белая) - цена открытия  (ОБЯЗАТЕЛЬНАЯ линия)
		- Stop_Loss_Line (красная) - уровень Стоп Лосс (ОБЯЗАТЕЛЬНАЯ)
		- Take_Profit_Line (зелёная) - уровень Тейк Профит (необязательная)
		- Expiration_Line (жёлтая) - время истечения (необязательная)
		(необязательные линии можно удалять)
		- "````" - размер позиции. Необходимо установить напротив нужного значения (от 0,1 до 10 лотов)
	В зависимости от расположения линий Open_Price и Stop_Loss выбирается тип ордера:
	Open_Price  >  Bid и Open_Price  >  Stop_Loss  -  BUYSTOP-ордер,
	Open_Price  >  Bid и Open_Price  <  Stop_Loss  -  SELLLIMIT-ордер,
	Open_Price  <  Ask и Open_Price  >  Stop_Loss  -  BUYLIMIT-ордер,
	Open_Price  <  Ask и Open_Price  <  Stop_Loss  -  SELLSTOP-ордер.
 4) Когда всё будет готово, в появившемся окне нажать кнопку "ОК".
 
 
 Для прекращения работы скрипта в любой момент можно воспользоваться кнопкой "Отмена".
 Если Вами будет найдена ошибка в коде, или в логике работы скрипта, просьба сообщить на komposterius@mail.ru
*/
//+------------------------------------------------------------------+
// Все нижеописанные переменные можно будет изменить в окне свойств скрипта,
// которое откроется при прикреплении. Это полезно, например, при необходимости выбрать
// непредставленный в списке "Lots" размер позиции. Для этого, написав нужную цифру в окне свойств (например, 1.5),
// НЕ ДВИГАЙТЕ указатель размера лота ( "````" ).
// Если окно свойств не нужно, надо закомментировать следующую строку (поставить в начало //)
#property show_inputs


// Тип ордера по умолчанию (влияет на начальное расположение линий стоп-лосс и тейк-профит)
extern int _OrderType = 1; //( "1" - BUYSTOP или BUYLIMIT, "-1" - SELLSTOP или SELLLIMIT )

// Обьём сделки по умолчанию (можно менять в процессе работы)
// от 0.1 до 1.0 с шагом 0.1, от 1 до 10 с шагом 1
extern double Lots = 0.1;

// Расстояние между линией Take_Profit/Stop_Loss и линией Open_Price в пунктах по умолчанию.
// Если Take_Profit использоваться не будет, установите 0
extern int Stop_Loss = 50;
extern int Take_Profit = 50;

// Максимальное отклонение от запрошенной цены
extern int Slippage = 5;

// Комментарий к ордеру
extern string _Comment = "Opened by script";

// Order ID
extern int MagicNumber = 0;

// Время истечения ордера, выраженное в свечах
// Для периода графика H4 и Expiration_Shift = 3 время истечения наступит через 12 часов после установки
// Если необходимо стандартное время истечения для всех периодов графика, укажите "0" (без кавычек), и переходите к следующей настройке
// Если время истечения ордера использоваться не будет, установите 0
extern int Expiration_Shift = 0;
// Время истечения ордера, выраженное в часах
// Для того, чтоб использовать эту настройку, необходимо установить Expiration_Shift (см. выше на 2 строки) "0" (без кавычек)
// Если время истечения ордера использоваться не будет, установите 0
extern int Expiration_Shift_H = 0;

extern string Order_Color = "----------------------------------------------------------------------------------------";
// Цвета отображения ордеров на графике
extern color Buy_Color = Lime; //( для ордеров BUYSTOP и BUYLIMIT )
extern color Sell_Color = Red; //( для ордеров SELLLIMIT и SELLSTOP )

extern string Line_Color = "----------------------------------------------------------------------------------------";
// Цвета линий:
extern color Open_Price_Line_Color = White;
extern color Stop_Loss_Line_Color = Red;
extern color Take_Profit_Line_Color = Lime;
extern color Expiration_Line_Color = Yellow;

//+------------------------------------------------------------------+

#include <stdlib.mqh>
int first = 1;
int start()
{
// Установка начальных значений:
double Open_Price_Level, Stop_Loss_Level, Take_Profit_Level;
datetime Expiration_Time;
// ---Open_Price_Level
	Open_Price_Level = PriceOnDropped();
	if ( Open_Price_Level <= 0 )
		{ Open_Price_Level = Bid + MarketInfo( Symbol(), MODE_STOPLEVEL )*Point; }
// ---Stop_Loss_Level
	Stop_Loss_Level = Open_Price_Level - Stop_Loss * Point;
// ---Take_Profit_Level
	if ( Take_Profit > 0 )
	{ Take_Profit_Level = Open_Price_Level + Take_Profit * Point; }

if ( _OrderType == -1 )
{
// ---Open_Price_Level
	Open_Price_Level = PriceOnDropped();
	if ( Open_Price_Level <= 0 )
		{ Open_Price_Level = Ask - MarketInfo( Symbol(), MODE_STOPLEVEL )*Point; }
// ---Stop_Loss_Level
	Stop_Loss_Level = Open_Price_Level + Stop_Loss * Point;
// ---Take_Profit_Level
	if ( Take_Profit > 0 )
	{ Take_Profit_Level = Open_Price_Level - Take_Profit * Point; }
}

// ---Expiration_Time
	if ( Expiration_Shift > 0 )
	{ Expiration_Time = CurTime() + Period()*60*Expiration_Shift; }
	else
	{
		if ( Expiration_Shift_H > 0 )
			{ Expiration_Time = CurTime() + 3600*Expiration_Shift_H; }
	}
// Создание линий:
if ( first == 1 )
{
	ObjectCreate( "Open_Price_Line", OBJ_HLINE, 0, 0, Open_Price_Level, 0, 0, 0, 0 );
	ObjectSet( "Open_Price_Line", OBJPROP_COLOR, Open_Price_Line_Color );
	ObjectSetText( "Open_Price_Line", "Open_Price_Line", 6, "Arial", Open_Price_Line_Color );

	ObjectCreate( "Stop_Loss_Line", OBJ_HLINE, 0, 0, Stop_Loss_Level, 0, 0, 0, 0 );
	ObjectSet( "Stop_Loss_Line", OBJPROP_COLOR, Stop_Loss_Line_Color );
	ObjectSetText( "Stop_Loss_Line", "Stop_Loss_Line", 6, "Arial", Stop_Loss_Line_Color );

	if ( Take_Profit_Level > 0 )
	{
		ObjectCreate( "Take_Profit_Line", OBJ_HLINE, 0, 0, Take_Profit_Level, 0, 0, 0, 0 );
		ObjectSet( "Take_Profit_Line", OBJPROP_COLOR, Take_Profit_Line_Color );
		ObjectSetText( "Take_Profit_Line", "Take_Profit_Line", 6, "Arial", Take_Profit_Line_Color );
	}

	if ( Expiration_Time > 0 )
	{
		ObjectCreate( "Expiration_Line", OBJ_VLINE, 0, Expiration_Time, 0, 0, 0, 0, 0 );
		ObjectSet( "Expiration_Line", OBJPROP_COLOR, Expiration_Line_Color );
		ObjectSetText( "Expiration_Line", "Expiration_Line", 6, "Arial", Expiration_Line_Color );
	}
// создание "Шкалы размера лота" и установка на значение по умолчанию
	int Lots_value_y = 30;
	switch ( Lots )
	{
		case 0.2: Lots_value_y = 45; break;
		case 0.3: Lots_value_y = 60; break;
		case 0.4: Lots_value_y = 75; break;
		case 0.5: Lots_value_y = 90; break;
		case 0.6: Lots_value_y = 105; break;
		case 0.7: Lots_value_y = 120; break;
		case 0.8: Lots_value_y = 135; break;
		case 0.9: Lots_value_y = 150; break;
		case 1.0: Lots_value_y = 165; break;
		case 2.0: Lots_value_y = 180; break;
		case 3.0: Lots_value_y = 195; break;
		case 4.0: Lots_value_y = 210; break;
		case 5.0: Lots_value_y = 225; break;
		case 6.0: Lots_value_y = 240; break;
		case 7.0: Lots_value_y = 255; break;
		case 8.0: Lots_value_y = 270; break;
		case 9.0: Lots_value_y = 285; break;
		case 10.0: Lots_value_y = 300; break;
	}
	if ( Lots > 10.0 ) Lots_value_y = 315;
	int Lots_value_y_start_position = Lots_value_y;
	
	ObjectCreate( "Lots", OBJ_LABEL, 0,0,0,0,0,0,0);
	ObjectSet( "Lots", OBJPROP_CORNER, 1);
	ObjectSet( "Lots", OBJPROP_XDISTANCE, 1);
	ObjectSet( "Lots", OBJPROP_YDISTANCE, 10);
	ObjectSetText(  "Lots", "Lots", 10, "Arial", Open_Price_Line_Color);

	ObjectCreate( "Lots_value", OBJ_LABEL, 0,0,0,0,0,0,0);
	ObjectSet( "Lots_value", OBJPROP_CORNER, 1);
	ObjectSet( "Lots_value", OBJPROP_XDISTANCE, 25);
	ObjectSet( "Lots_value", OBJPROP_YDISTANCE, Lots_value_y);
	ObjectSetText(  "Lots_value", "`````", 10, "Arial", Open_Price_Line_Color);

	int y = 25;
	for ( double z = 0.1; z <= 1; z += 0.1 )
	{
		ObjectCreate( DoubleToStr( z, 1 ), OBJ_LABEL, 0,0,0,0,0,0,0);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_CORNER, 1);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_XDISTANCE, 1);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_YDISTANCE, y);
		ObjectSetText(  DoubleToStr( z, 1 ), DoubleToStr( z, 1 ), 10, "Arial", Open_Price_Line_Color);
		y += 15;
	}
	y = 160;
	for ( z = 1; z <= 10; z ++ )
	{
		ObjectCreate( DoubleToStr( z, 1 ), OBJ_LABEL, 0,0,0,0,0,0,0);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_CORNER, 1);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_XDISTANCE, 1);
		ObjectSet( DoubleToStr( z, 1 ), OBJPROP_YDISTANCE, y);
		ObjectSetText(  DoubleToStr( z, 1 ), DoubleToStr( z, 1 ), 10, "Arial", Open_Price_Line_Color);
		y += 15;
	}
	ObjectCreate( ">", OBJ_LABEL, 0,0,0,0,0,0,0);
	ObjectSet( ">", OBJPROP_CORNER, 1);
	ObjectSet( ">", OBJPROP_XDISTANCE, 1);
	ObjectSet( ">", OBJPROP_YDISTANCE, 310);
	ObjectSetText(  ">", ">10", 10, "Arial", Open_Price_Line_Color);

// вывод месседжбокса
	string Question = "Для установки ордера переместите линии на необходимые уровни и нажмите \"ОК\".\n" + 
							"Чтоб отказаться от установки, нажмите \"Отмена\".";
	int  Answer = MessageBox( Question, "Установка отложенного ордера", 0x00000001 | 0x00000040 | 0x00040000 );
	first = 0;
	// если нажата любая кроме "ОК" кнопка - выходим
	if ( Answer != 1 ) { deinit(); return(0); }
}

// считываем значения с объектов и нормализуем:

// размер лота
	Lots_value_y = ObjectGet( "Lots_value", OBJPROP_YDISTANCE );
	if ( Lots_value_y_start_position != Lots_value_y )
	{
		Lots = 0.1;
		if ( Lots_value_y >= 35  && Lots_value_y < 50  ) Lots = 0.2;
		if ( Lots_value_y >= 50  && Lots_value_y < 65  ) Lots = 0.3;
		if ( Lots_value_y >= 65  && Lots_value_y < 80  ) Lots = 0.4;
		if ( Lots_value_y >= 80  && Lots_value_y < 95  ) Lots = 0.5;
		if ( Lots_value_y >= 95  && Lots_value_y < 110 ) Lots = 0.6;
		if ( Lots_value_y >= 110 && Lots_value_y < 125 ) Lots = 0.7;
		if ( Lots_value_y >= 125 && Lots_value_y < 140 ) Lots = 0.8;
		if ( Lots_value_y >= 140 && Lots_value_y < 155 ) Lots = 0.9;
		if ( Lots_value_y >= 155 && Lots_value_y < 170 ) Lots = 1.0;
		if ( Lots_value_y >= 170 && Lots_value_y < 185 ) Lots = 2.0;
		if ( Lots_value_y >= 185 && Lots_value_y < 200 ) Lots = 3.0;
		if ( Lots_value_y >= 200 && Lots_value_y < 215 ) Lots = 4.0;
		if ( Lots_value_y >= 215 && Lots_value_y < 230 ) Lots = 5.0;
		if ( Lots_value_y >= 230 && Lots_value_y < 245 ) Lots = 6.0;
		if ( Lots_value_y >= 245 && Lots_value_y < 260 ) Lots = 7.0;
		if ( Lots_value_y >= 260 && Lots_value_y < 275 ) Lots = 8.0;
		if ( Lots_value_y >= 275 && Lots_value_y < 290 ) Lots = 9.0;
		if ( Lots_value_y >= 290 							  ) Lots = 10.0;
	}
	Lots = NormalizeDouble( Lots, 1 );
// Open_Price
	Open_Price_Level = NormalizeDouble( ObjectGet( "Open_Price_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
// Stop_Loss
	Stop_Loss_Level = NormalizeDouble( ObjectGet( "Stop_Loss_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
// Take_Profit
	Take_Profit_Level = NormalizeDouble( ObjectGet( "Take_Profit_Line", OBJPROP_PRICE1 ), MarketInfo( Symbol(), MODE_DIGITS ) );
// Expiration_Time
	Expiration_Time = ObjectGet( "Expiration_Line", OBJPROP_TIME1 );
	
// определяем тип ордера
	if ( Open_Price_Level - Bid >= 0 )
	{
		if ( Open_Price_Level - Stop_Loss_Level > 0 )
		{ _OrderType = OP_BUYSTOP; }
		else
		{ _OrderType = OP_SELLLIMIT; }
	}
	else
	{
		if ( Open_Price_Level - Stop_Loss_Level > 0 )
		{ _OrderType = OP_BUYLIMIT; }
		else
		{ _OrderType = OP_SELLSTOP; }
	}

color _Color;
// проверяем все значения
	if ( _OrderType == OP_BUYLIMIT || _OrderType == OP_BUYSTOP )
	{
		_Color = Buy_Color;
		if ( Open_Price_Level - Stop_Loss_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
		{
			Answer = MessageBox(  "Неправильно установлена Stop_Loss_Line (красная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для BuyLimit и BuyStop - ордеров она должна быть НИЖЕ линии Open_Price_Line.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать установку с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от установки, нажмите \"Отмена\".", "Установка отложенного ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
		}
		if ( Take_Profit_Level - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level > 0 )
		{
			Answer = MessageBox(  "Неправильно установлена Take_Profit_Line (зелёная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для BuyLimit и BuyStop - ордеров она должна быть ВЫШЕ линии Open_Price_Line.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать установку с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от установки, нажмите \"Отмена\".", "Установка отложенного ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
		}
		if ( _OrderType == OP_BUYSTOP )
		{
			if ( Open_Price_Level - Bid < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Неправильно установлена Open_Price_Line (белая линия)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Для BuyStop - ордера она должна быть ВЫШЕ текущей цены.	\n" + 
					 		 			 	"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы начать установку с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от установки, нажмите \"Отмена\".", "Установка отложенного ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { ObjectsRedraw(); start(); }
				deinit();
				return(-1);
			}
		}
		else
		{
			if ( Bid - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Неправильно установлена Open_Price_Line (белая линия)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Для BuyLimit - ордера она должна быть НИЖЕ текущей цены.	\n" + 
					 		 			 	"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы начать установку с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от установки, нажмите \"Отмена\".", "Установка отложенного ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { ObjectsRedraw(); start(); }
				deinit();
				return(-1);
			}
		}
	}
	if ( _OrderType == OP_SELLLIMIT || _OrderType == OP_SELLSTOP )
	{
		_Color = Sell_Color;
		if ( Stop_Loss_Level - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
		{
			Answer = MessageBox(  "Неправильно установлена Stop_Loss_Line (красная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для SellLimit и SellStop - ордеров она должна быть ВЫШЕ линии Open_Price_Line.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать установку с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от установки, нажмите \"Отмена\".", "Установка отложенного ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
		}
		if ( Open_Price_Level - Take_Profit_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point && Take_Profit_Level > 0 )
		{
			Answer = MessageBox(  "Неправильно установлена Take_Profit_Line (зелёная линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Для SellLimit и SellStop - ордеров она должна быть НИЖЕ линии Open_Price_Line.	\n" + 
					 		 			 "Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать установку с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от установки, нажмите \"Отмена\".", "Установка отложенного ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
		}
		if ( _OrderType == OP_SELLLIMIT )
		{
			if ( Open_Price_Level - Ask < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Неправильно установлена Open_Price_Line (белая линия)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Для SellLimit - ордера она должна быть НИЖЕ текущей цены.	\n" + 
					 		 			 	"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы начать установку с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от установки, нажмите \"Отмена\".", "Установка отложенного ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { ObjectsRedraw(); start(); }
				deinit();
				return(-1);
			}
		}
		else
		{
			if ( Ask - Open_Price_Level < MarketInfo( Symbol(), MODE_STOPLEVEL )*Point )
			{
				Answer = MessageBox( "Неправильно установлена Open_Price_Line (белая линия)!\n" + 
					 		 			 	"\n" +
					 		 			 	"Для SellStop - ордера она должна быть ВЫШЕ текущей цены.	\n" + 
					 		 			 	"Минимальный отступ (" + Symbol() + ") - " + DoubleToStr( MarketInfo( Symbol(), MODE_STOPLEVEL ), 0 ) + " пунктов.\n" + 
					 		 			 	"\n\n" +
					 		 			 	"Чтобы начать установку с начала, нажмите \"Повтор\".\n" +
					 		 			 	"Чтоб отказаться от установки, нажмите \"Отмена\".", "Установка отложенного ордера", 0x00000005 | 0x00000030 | 0x00040000 );
				if ( Answer == 4 ) { ObjectsRedraw(); start(); }
				deinit();
				return(-1);
			}
		}
	}

	if ( Expiration_Time <= CurTime() && Expiration_Time > 0 )
	{
			Answer = MessageBox(  "Неправильно установлена Expiration_Line (жёлтая линия)!\n" + 
					 		 			 "\n" +
					 		 			 "Срок истечения ордера не может быть в прошедшем времени!		\n" + 
					 		 			 "\n\n" +
					 		 			 "Чтобы начать установку с начала, нажмите \"Повтор\".\n" +
					 		 			 "Чтоб отказаться от установки, нажмите \"Отмена\".", "Установка отложенного ордера", 0x00000005 | 0x00000030 | 0x00040000 );
			if ( Answer == 4 ) { ObjectsRedraw(); start(); }
			deinit();
			return(-1);
	}
	
// выводим инфу о запросе и пытаемся установить ордер
	Print( "Symbol=",Symbol(), ",_OrderType=",_OrderType, ",Lots=",Lots, ",Open_Price_Level=",Open_Price_Level, ",Slippage=", Slippage, ",Stop_Loss_Level=", Stop_Loss_Level, ",Take_Profit_Level=", Take_Profit_Level, ",_Comment=", _Comment, ",MagicNumber=", MagicNumber, ",Expiration_Time=", Expiration_Time, ",_Color=", _Color );
	int ordersend = OrderSend( Symbol(), _OrderType, Lots, Open_Price_Level, Slippage, Stop_Loss_Level, Take_Profit_Level, _Comment, MagicNumber, Expiration_Time, _Color );
	if ( ordersend > 0 )
	{
// если всё ок, выводим лог и выходим
		OrderPrint();
		Print( "Ордер №", ordersend, " установлен успешно!");
		return(0);
	}
// если ошибка - выводим сообщение и выходим
	int error = GetLastError();
	Print("Alignment Error! GetLastError = ", error, ", ErrorDescription =  \"", ErrorDescription( error ), "\"" );
	MessageBox( "Ошибка при установке! GetLastError = " + error + ", ErrorDescription = \"" + ErrorDescription( error ) + "\"", 
             	 	"Ошибка установки ордера", 0x00000000 | 0x00000010 | 0x00040000 ); 
return(-1);
}

int deinit()
{
// удаление всех объектов, созданных скриптом
	ObjectDelete( "Open_Price_Line" );
	ObjectDelete( "Stop_Loss_Line" );
	ObjectDelete( "Take_Profit_Line" );
	ObjectDelete( "Expiration_Line" );

	for ( double z = 0.1; z <= 1; z += 0.1 )
	{ ObjectDelete( DoubleToStr( z, 1 )); }
	for ( z = 1; z <= 10; z ++ )
	{ ObjectDelete( DoubleToStr( z, 1 )); }
	ObjectDelete( "Lots" );
	ObjectDelete( "Lots_value" );
	ObjectDelete( ">" );
return(0);
}



