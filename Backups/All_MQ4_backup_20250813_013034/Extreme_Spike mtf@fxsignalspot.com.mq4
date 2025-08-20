//+-------------------------------------------------------------------+
//|	Extreme_Spike.mq4
//| Based on Symphonie_Extreme_Cycle_Indikator
//| !!! this file is created with Tab size 4 and no space indentation
//+-------------------------------------------------------------------+
#property copyright ""
#property link      ""

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
extern int     timeFrame = 0;
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
extern bool    WaitForClose = true;

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



string	periodName,indicatorFileName;
int		BarNumber;

#define RANGE_AVERAGING_PERIOD 250

int init() {
   indicatorFileName = WindowExpertName();
   timeFrame = MathMax(timeFrame,Period());
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

	return (0);
}

int deinit() {
	return(0);
}

int start() {
   if(WaitForClose && (!BarChanged()) ) return(0);

	BarNumber = IndicatorCounted();

	// 'BarNumber' changes from 1 to 'Bars', so the array index is [Bars-1 .. 0]
	if (timeFrame != Period())
	{
	   for (int i=Bars-1; i>= 0; i--)
	   {
	      int y = iBarShift(NULL,timeFrame,Time[i]);
	      line1[i] = iCustom(NULL,timeFrame,indicatorFileName,0,NoRepaint,MinorMinExtremeHeightATRs,MajorToMinorHeightRatio,MinorMinExtremeWidth,MajorMinExtremeWidth,AlertMajorBottomEnabled,AlertMajorTopEnabled,AlertMinorTopEnabled,AlertMinorBottomEnabled,AlertStableEnabled,0,y);
	      line2[i] = iCustom(NULL,timeFrame,indicatorFileName,0,NoRepaint,MinorMinExtremeHeightATRs,MajorToMinorHeightRatio,MinorMinExtremeWidth,MajorMinExtremeWidth,AlertMajorBottomEnabled,AlertMajorTopEnabled,AlertMinorTopEnabled,AlertMinorBottomEnabled,AlertStableEnabled,1,y);
	      line3[i] = iCustom(NULL,timeFrame,indicatorFileName,0,NoRepaint,MinorMinExtremeHeightATRs,MajorToMinorHeightRatio,MinorMinExtremeWidth,MajorMinExtremeWidth,AlertMajorBottomEnabled,AlertMajorTopEnabled,AlertMinorTopEnabled,AlertMinorBottomEnabled,AlertStableEnabled,2,y);
	      line4[i] = iCustom(NULL,timeFrame,indicatorFileName,0,NoRepaint,MinorMinExtremeHeightATRs,MajorToMinorHeightRatio,MinorMinExtremeWidth,MajorMinExtremeWidth,AlertMajorBottomEnabled,AlertMajorTopEnabled,AlertMinorTopEnabled,AlertMinorBottomEnabled,AlertStableEnabled,3,y);
	      line5[i] = iCustom(NULL,timeFrame,indicatorFileName,0,NoRepaint,MinorMinExtremeHeightATRs,MajorToMinorHeightRatio,MinorMinExtremeWidth,MajorMinExtremeWidth,AlertMajorBottomEnabled,AlertMajorTopEnabled,AlertMinorTopEnabled,AlertMinorBottomEnabled,AlertStableEnabled,4,y);
	   }
	   return(0);
	}
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

	return;
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
		return (FALSE);
	draw( LINE_STABLE, barIdx, value );
	return (TRUE);
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
	datetime barTime = Time[Bars-barIdx];
	
	switch( alertType ) {
		case ALERT_TOP:
			switch( lineType ) {
				case LINE_MAJOR:
					if( AlertMajorTopEnabled && (barTime != AlertMajorTopIdx) ) {
						Alert( Symbol(), " ", periodName, ": Major Top Detected" );
						AlertMajorTopIdx = barTime;
					}
					break;
				case LINE_MINOR:
					if( AlertMinorTopEnabled && (barTime != AlertMinorTopIdx) ) {
						Alert( Symbol(), " ", periodName, ": Minor Top Detected" );
						AlertMinorTopIdx = barTime;
					}
					break;
			}
			break;
		case ALERT_BOTTOM:
			switch( lineType ) {
				case LINE_MAJOR:
					if( AlertMajorBottomEnabled && (barTime != AlertMajorBottomIdx) ) {
						Alert( Symbol(), " ", periodName, ": Major Bottom Detected" );
						AlertMajorBottomIdx = barTime;
					}
					break;
				case LINE_MINOR:
					if( AlertMinorBottomEnabled && (barTime != AlertMinorBottomIdx) ) {
						Alert( Symbol(), " ", periodName, ": Minor Bottom Detected" );
						AlertMinorBottomIdx = barTime;
					}
					break;
			}
			break;
		case ALERT_STABLE:
			if( AlertStableEnabled && (barTime != AlertStableIdx) ) {
				Alert( Symbol(), " ", periodName, ": Latest extreme will not repaint anymore" );
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
	return("");
}

bool BarChanged()
{
 static datetime dt = 0;

  if (dt != Time[0])
  {
   dt = Time[0];
   return(true);
  }
   return(false);
}