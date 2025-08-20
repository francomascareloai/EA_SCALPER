// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict

#property indicator_separate_window

#property indicator_minimum			-1.2
#property indicator_maximum			+1.2
#property indicator_buffers			5

#property indicator_color1			Red
#property indicator_width1			3
#property indicator_style1			STYLE_SOLID

#property indicator_color2			DodgerBlue
#property indicator_width2			3
#property indicator_style2			STYLE_SOLID

#property indicator_color3			DimGray
#property indicator_width3			0

#property indicator_color4			White
#property indicator_width4			1
#property indicator_style4			STYLE_SOLID

#property indicator_color5			White
#property indicator_width5			2
#property indicator_style5			STYLE_SOLID

#define ALERT_TOP		1
#define ALERT_BOTTOM	2
#define ALERT_STABLE	3

#define LINE_MINOR		1
#define LINE_MAJOR		2
#define LINE_SHADOW		3
#define LINE_STABLE		4

#define LINE_VALUE_UP		1.0
#define LINE_VALUE_FLAT		0.0
#define LINE_VALUE_DOWN		-1.0

#define MODE_LOOKING_FOR_BOTTOM	1
#define MODE_LOOKING_FOR_TOP	-1
#define MODE_UNDETERMINED		0

//---- input parameters
extern bool		NoRepaint					= FALSE;
extern double	MinorMinExtremeHeightATRs	= 2.0;
extern double	MajorToMinorHeightRatio		= 2.5;
extern int		MinorMinExtremeWidth		= 2;
extern int		MajorMinExtremeWidth		= 2;
extern bool		AlertMajorBottomEnabled		= FALSE;
extern bool		AlertMajorTopEnabled		= FALSE;
extern bool		AlertMinorTopEnabled		= FALSE;
extern bool		AlertMinorBottomEnabled		= FALSE;
extern bool		AlertStableEnabled			= FALSE;
//Signaler v 1.5
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SendNotifications(const int direction)
   {
      if (direction == 0)
         return;

      datetime currentTime = iTime(_symbol, _timeframe, 0);
      if (_lastDatetime == currentTime)
         return;

      _lastDatetime = currentTime;
      string tf = GetTimeframe();
      string alert_Subject;
      string alert_Body;
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            alert_Subject = "Buy signal on " + _symbol + "/" + tf;
            alert_Body = "Buy signal on " + _symbol + "/" + tf;
            break;
         case ENTER_SELL_SIGNAL:
            alert_Subject = "Sell signal on " + _symbol + "/" + tf;
            alert_Body = "Sell signal on " + _symbol + "/" + tf;
            break;
         case EXIT_BUY_SIGNAL:
            alert_Subject = "Exit buy signal on " + _symbol + "/" + tf;
            alert_Body = "Exit buy signal on " + _symbol + "/" + tf;
            break;
         case EXIT_SELL_SIGNAL:
            alert_Subject = "Exit sell signal on " + _symbol + "/" + tf;
            alert_Body = "Exit sell signal on " + _symbol + "/" + tf;
            break;
      }
      SendNotifications(alert_Subject, alert_Body, _symbol, tf);
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframe();

      if (Popup_Alert)
         Alert(message);
      if (Email_Alert)
         SendMail(subject, message);
      if (Play_Sound)
         PlaySound(Sound_File);
      if (Notification_Alert)
         SendNotification(message);
      if (Advanced_Alert && Advanced_Key != "" && !IsTesting())
         AdvancedAlert(Advanced_Key, message, symbol, timeframe);
   }

private:
   string GetTimeframe()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};

//---- buffers
double line1[];	// lineMajorUp	
double line2[];	// lineMajorDown
double line3[];	// lineShadowUp, lineShadowDown	
double line4[];	// lineStableUp,  lineStableDown	
double line5[];	// lineMinorUp, lineMinorDown	


int		MinorLowExtremeIdx		= 1;
bool	MinorFirstLow			= TRUE;
int		MinorHiExtremeIdx		= 1;
bool	MinorFirstHigh			= TRUE;
int		MinorExtremeMode		= 0;
double	MinorLowExtremePrice;
double	MinorHiExtremePrice;

int		MajorLowExtremeIdx		= 1;
bool	MajorFirstLow			= TRUE;
int		MajorHiExtremeIdx		= 1;
bool	MajorFirstHigh			= TRUE;
int		MajorExtremeMode		= 0;
double	MajorLowExtremePrice;
double	MajorHiExtremePrice;

double	MinorMinExtremeHeight;
double	MajorMinExtremeHeight;

datetime AlertMinorTopIdx;
datetime AlertMinorBottomIdx;
datetime AlertMajorTopIdx;
datetime AlertMajorBottomIdx;
datetime AlertStableIdx;

string	periodName;
int		BarNumber;

#define RANGE_AVERAGING_PERIOD 250

Signaler *signaler;

int init() {
   if (!IsDllsAllowed() && Advanced_Alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
	int line = 0;

	// order of these calls is important - for example the 'spike' line is last - it will be drawn last and therefore will be on top of all other lines
	
	SetIndexStyle	( line, DRAW_HISTOGRAM );
	SetIndexBuffer	( line, line1 );
	line++;
	
	SetIndexStyle	( line, DRAW_HISTOGRAM );
	SetIndexBuffer	( line, line2 );
	line++;

	SetIndexStyle	( line, DRAW_ARROW );
	SetIndexArrow	( line, 108 );
	SetIndexBuffer	( line, line3 );
	line++;

	SetIndexStyle	( line, DRAW_HISTOGRAM );
	SetIndexBuffer	( line, line4 );
	line++;

	SetIndexStyle	( line, DRAW_LINE );
	SetIndexBuffer	( line, line5 );
	line++;

   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);

	return (0);
}

int deinit() {
   delete signaler;
	return(0);
}

int start() {
	BarNumber = IndicatorCounted();

	// 'BarNumber' changes from 1 to 'Bars', so the array index is [Bars-1 .. 0]
	for( ; BarNumber < Bars; ) {
		BarNumber++;
   		processBar();
	}
	return (0);
}

void processBar() {

	switch( BarNumber ) { 
		case 0:
			break;
		case 1:
			periodName				= getPeriodName();
			AlertMinorTopIdx		= Time[Bars-1];
			AlertMinorBottomIdx		= Time[Bars-1];
			AlertMajorTopIdx		= Time[Bars-1];
			AlertMajorBottomIdx		= Time[Bars-1];
			MinorLowExtremePrice	= getLow();
			MinorHiExtremePrice		= getHigh();
			MajorLowExtremePrice	= getLow();
			MajorHiExtremePrice		= getHigh();
			break;
		default:
			MinorMinExtremeHeight	= average() * MinorMinExtremeHeightATRs;
			MajorMinExtremeHeight	= MinorMinExtremeHeight * MajorToMinorHeightRatio;
			checkForExtremes(	MinorLowExtremeIdx,	MinorLowExtremePrice,	MinorFirstLow, 
								MinorHiExtremeIdx,	MinorHiExtremePrice,	MinorFirstHigh, 
								MinorExtremeMode,	MinorMinExtremeHeight,	MinorMinExtremeWidth, LINE_MINOR );
			checkForExtremes(	MajorLowExtremeIdx,	MajorLowExtremePrice,	MajorFirstLow, 
								MajorHiExtremeIdx,	MajorHiExtremePrice,	MajorFirstHigh, 
								MajorExtremeMode,	MajorMinExtremeHeight,	MajorMinExtremeWidth, LINE_MAJOR );
			break;
	}
}


void checkForExtremes(	int& lowExtremeIdx,	double& lowExtremePrice,	bool& firstLow, 
						int& hiExtremeIdx,	double& hiExtremePrice,		bool& firstHigh, 
						int& extremeMode, double MinExtremeHeight, int MinExtremeWidth, int lineType ) {
	// ----------- check for Bottom ----------------
	if( extremeMode > -1 ) {
		if( getLow() < lowExtremePrice ) {
			if( !firstLow )
				eraseExtreme( lineType, lowExtremeIdx, LINE_VALUE_DOWN );	// to repaint (erase) the spike
			lowExtremePrice = getLow();									// set LowestLow to this low (getLow)
			lowExtremeIdx = BarNumber;									// remember the LL bar number
			firstLow = FALSE;											// the was a Bottom
		}
		else
		if( getLow() > lowExtremePrice ) {								// higher low (getLow) - not necesserally higher than the last bar - could be lower than the last bar, but still higher than the bottom
			// there was bottom (lower low then higher low) - final or intermediate
			drawExtreme( lineType, lowExtremeIdx, LINE_VALUE_DOWN );	// update LowestLow bar with the spike DOWN and mark it as unstable

			alert( ALERT_BOTTOM, lineType, lowExtremeIdx );

			firstLow = FALSE;

			if(	((getLow() - lowExtremePrice)	>= MinExtremeHeight) 	// the bottom was distinct enough (difference between it and price is big enough)   
			&&	((BarNumber - lowExtremeIdx)	>= MinExtremeWidth) ) {	// and the bottom was long enough ago in the past (there was no another bottom since)
				extremeMode = -1;										// set flags to start looking for top
				hiExtremePrice = getHigh();
				hiExtremeIdx = BarNumber;
				firstHigh = TRUE;
				firstLow = TRUE;
				
				if( NoRepaint )		// only draw extreme when it is not going to be repainted (WILL in troduce a lag)
					draw( lineType, lowExtremeIdx, LINE_VALUE_DOWN );
				if( drawStableLine( lineType, lowExtremeIdx, LINE_VALUE_FLAT ) )	// this spike will not repaint
					alert( ALERT_STABLE, lineType, lowExtremeIdx );
			}
		}
	}

	// ----------- check for Top ----------------
	if( extremeMode < 1 ) {								// extremeMode could have been MinExtremeHeighted in the code above so can't really put "Else" here; initial goes here as well (0)
		if( getHigh() > hiExtremePrice ) {
			if( !firstHigh )
				eraseExtreme( lineType, hiExtremeIdx, LINE_VALUE_UP );	// to repaint (erase) the spike
			hiExtremePrice = getHigh();
			hiExtremeIdx = BarNumber;
			firstHigh = FALSE;
		}
		else
		if( getHigh() < hiExtremePrice ) {
			drawExtreme( lineType, hiExtremeIdx, LINE_VALUE_UP );
			
			alert( ALERT_TOP, lineType, hiExtremeIdx );

			firstHigh = FALSE;
		
			if(	((hiExtremePrice - getHigh())	>= MinExtremeHeight)
			&&	((BarNumber - hiExtremeIdx)		>= MinExtremeWidth) ) {
				extremeMode = 1;
				lowExtremePrice = getLow();
				lowExtremeIdx = BarNumber;
				firstHigh = TRUE;
				firstLow = TRUE;
				
				if( NoRepaint )		// only draw extreme when it is not going to be repainted (WILL in troduce a lag)
					draw( lineType, hiExtremeIdx, LINE_VALUE_UP );
				if( drawStableLine( lineType, hiExtremeIdx, LINE_VALUE_FLAT ) )	// this spike will not repaint
					alert( ALERT_STABLE, lineType, hiExtremeIdx );
			}
		}
	}

	draw( lineType, BarNumber, LINE_VALUE_FLAT );
}


void eraseExtreme( int lineType, int barIdx, double value ) {
	bool drawShadow = (lineType == LINE_MAJOR) && (
		NoRepaint	// in non-repainting mode always alert of the possible extreme
	||	((value == LINE_VALUE_UP)	&& (line1[Bars-barIdx] != 0))
	||	((value == LINE_VALUE_DOWN)	&& (line2[Bars-barIdx] != 0))
	);
	drawExtreme( lineType, barIdx, LINE_VALUE_FLAT );
	if( drawShadow )
		draw( LINE_SHADOW, barIdx, value );
}

void drawExtreme( int lineType, int barIdx, double value ) {
	if( !NoRepaint ) {	// only draw extreme when it is not going to be repainted (WILL in troduce a lag)
		draw( lineType, barIdx, value );
		drawStableLine( lineType, barIdx, value );
	}
}

bool drawStableLine( int lineType, int barIdx, double value ) {
	if( lineType == LINE_MAJOR )
		return false;
	draw( LINE_STABLE, barIdx, value );
	return true;
}

void draw( int lineType, int barIdx, double value ) {
	switch( lineType ) {
		case LINE_MAJOR:
			updateLine( line1, line2, barIdx, value );
			break;
		case LINE_MINOR:
			updateLine( line5, line5, barIdx, value );
			break;
		case LINE_SHADOW:
			updateLine( line3, line3, barIdx, value );
			break;
		case LINE_STABLE:
			updateLine( line4, line4, barIdx, value );
			break;
	}
}

void updateLine( double& lineUp[], double& lineDown[], int barIdx, double value ) {
	if( (value == LINE_VALUE_FLAT) || (value == LINE_VALUE_UP) )
		lineUp[ Bars-barIdx ] = value;
	if( (value == LINE_VALUE_FLAT) || (value == LINE_VALUE_DOWN) )
		lineDown[ Bars-barIdx ] = value;
}

double average() {
	// original code uses 250-bar SMA of the simple range (high-low)
	return (iATR( NULL, 0, RANGE_AVERAGING_PERIOD, 0 ));
}

double getLow() {
	return (Close[ Bars-BarNumber ]);
}

double getHigh() {
	return (Close[ Bars-BarNumber ]);
}

void alert( int alertType, int lineType, int barIdx ) {
	if (barIdx != Bars)
		return;
	datetime barTime = Time[Bars-barIdx];
	
	switch( alertType ) {
		case ALERT_TOP:
			switch( lineType ) {
				case LINE_MAJOR:
					if( AlertMajorTopEnabled && (barTime != AlertMajorTopIdx) ) {
                  signaler.SendNotifications(Symbol() + " " + periodName + ": Major Top Detected");
						AlertMajorTopIdx = barTime;
					}
					break;
				case LINE_MINOR:
					if( AlertMinorTopEnabled && (barTime != AlertMinorTopIdx) ) {
                  signaler.SendNotifications(Symbol() + " " + periodName + ": Minor Top Detected");
						AlertMinorTopIdx = barTime;
					}
					break;
			}
			break;
		case ALERT_BOTTOM:
			switch( lineType ) {
				case LINE_MAJOR:
					if( AlertMajorBottomEnabled && (barTime != AlertMajorBottomIdx) ) {
                  signaler.SendNotifications(Symbol() + " " + periodName + ": Major Bottom Detected");
						AlertMajorBottomIdx = barTime;
					}
					break;
				case LINE_MINOR:
					if( AlertMinorBottomEnabled && (barTime != AlertMinorBottomIdx) ) {
                  signaler.SendNotifications(Symbol() + " " + periodName + ": Minor Bottom Detected");
						AlertMinorBottomIdx = barTime;
					}
					break;
			}
			break;
		case ALERT_STABLE:
			if( AlertStableEnabled && (barTime != AlertStableIdx) ) {
            signaler.SendNotifications(Symbol() + " " + periodName + ": Latest extreme will not repaint anymore");
				AlertStableIdx = barTime;
			}
			break;
	}
}

string getPeriodName() {
	switch( Period() ) {
		case PERIOD_M1:
			return ("M1");
		case PERIOD_M5:
			return ("M5");
		case PERIOD_M15:
			return ("M15");
		case PERIOD_M30:
			return ("M30");
		case PERIOD_H1:
			return ("H1");
		case PERIOD_H4:
			return ("H4");
		case PERIOD_D1:
			return ("D1");
		case PERIOD_W1:
			return ("W1");
		case PERIOD_MN1:
			return ("MN1");
	}
	return "";
}