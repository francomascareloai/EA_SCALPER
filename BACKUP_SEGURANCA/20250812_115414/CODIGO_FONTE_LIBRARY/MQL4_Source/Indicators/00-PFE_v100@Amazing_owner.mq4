//
// "00-PFE_v100.mq4" -- Polarized Fractal Efficiency
//                              refer to http://www.geocities.jp/fx_scientist/program.html
//
//    Ver. 1.00  2008/10/26(Sun)  initial version
//
//
#property  copyright "00 - 00mql4@gmail.com"
#property  link      "http://www.mql4.com/"

//---- indicator settings
#property  indicator_separate_window

#property  indicator_buffers  4

#property  indicator_color1  Aqua
#property  indicator_color2  -1
#property  indicator_color3  DodgerBlue
#property  indicator_color4  Crimson

#property  indicator_width1  1
#property  indicator_width2  1
#property  indicator_width3  1
#property  indicator_width4  1

#property  indicator_style1  STYLE_SOLID
#property  indicator_style2  STYLE_SOLID

//---- defines

//---- indicator parameters
extern int  timeFrame   = 0;     // time frame
extern int  nPeriod     = 10;    // PFE period
extern int  nSmooth     = 5;     // smoothing period
extern int  PFEchange   = 10;    // signal condition, abs(pfe[2] - pfe[1]) > PFEchange
extern int  PFEwidth    = 10;    // signal condition, abs(pfe[2]) >= PFEwidth
extern bool bSmoothAll  = true;  // smooth other time frame
extern int  nMaxBars    = 0;     // number of bars, 0: no limit

//---- indicator buffers
double BufferPFEValue[];  // 0: PFE
double BufferPFERaw[];    // 1: raw PFE
double BufferLong[];      // 2: long signal
double BufferShort[];     // 3: short signal

//---- vars
string sIndicatorName;
string sIndPFE = "00-PFE_v100";
int    markLong   = 233;
int    markShort  = 234;

//----------------------------------------------------------------------
string TimeFrameToStr(int timeFrame)
{
    switch (timeFrame) {
    case 1:     return("M1");
    case 5:     return("M5");
    case 15:    return("M15");
    case 30:    return("M30");
    case 60:    return("H1");
    case 240:   return("H4");
    case 1440:  return("D1");
    case 10080: return("W1");
    case 43200: return("MN");
    }
    
    return("??");
}

//----------------------------------------------------------------------
void init()
{
    if (timeFrame == 0) {
	timeFrame = Period();
    }
    
    sIndicatorName = sIndPFE + "(" + TimeFrameToStr(timeFrame) + "," + nPeriod + "," + nSmooth + ")";
    
    IndicatorShortName(sIndicatorName);
    
    SetIndexBuffer(0, BufferPFEValue);
    SetIndexBuffer(1, BufferPFERaw);
    SetIndexBuffer(2, BufferLong);
    SetIndexBuffer(3, BufferShort);
    
    SetIndexLabel(0, "PFE smooth");
    SetIndexLabel(1, "PFE raw");
    SetIndexLabel(2, "Long signal");
    SetIndexLabel(3, "Short signal");
    
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(1, DRAW_LINE);
    SetIndexStyle(2, DRAW_ARROW);
    SetIndexStyle(3, DRAW_ARROW);

    SetIndexArrow(2, markLong);
    SetIndexArrow(3, markShort);

    SetIndexDrawBegin(0, nPeriod);
    SetIndexDrawBegin(1, nPeriod);
    SetIndexDrawBegin(2, nPeriod);
    SetIndexDrawBegin(3, nPeriod);
    
    SetLevelValue(0, 0.0);
    SetLevelValue(1, 80.0);
    SetLevelValue(2, -80.0);
}

//----------------------------------------------------------------------
void start()
{
    int limit;
    int counted_bars = IndicatorCounted();
    
    if (counted_bars > 0) {
	counted_bars--;
    }
    
    limit = Bars - counted_bars;
    if (nMaxBars > 0) {
	limit = MathMin(limit, nMaxBars);
    }
    limit = MathMax(limit, 3);
    
    for (int i = limit - 1; i >= 0; i--) {
	if (timeFrame != Period()) {
	    datetime t = Time[i];
	    int x = iBarShift(NULL, timeFrame, t);
	    BufferPFEValue[i] = iCustom(NULL, timeFrame, sIndPFE, timeFrame, nPeriod, nSmooth,
					PFEchange, PFEwidth, false, nMaxBars, 0, x);
	    BufferPFERaw[i]   = iCustom(NULL, timeFrame, sIndPFE, timeFrame, nPeriod, nSmooth,
					PFEchange, PFEwidth, false, nMaxBars, 1, x);
	    continue;
	}
	
	BufferPFEValue[i] = EMPTY_VALUE;
	BufferPFERaw[i]   = EMPTY_VALUE;
	BufferLong[i]     = EMPTY_VALUE;
	BufferShort[i]    = EMPTY_VALUE;
	
	double denom = 0;
	for (int j = 0; j < nPeriod; j++) {
	    double d = Close[i + j] - Close[i + j + 1];
	    denom = denom + MathSqrt(d * d + 1);
	}
	
	double pfe = 0;
	if (denom != 0) {
	    int sign = 1;
	    if (Close[i] < Close[i + nPeriod]) {
		sign = -1;
	    }
	    d = Close[i] - Close[i + nPeriod];
	    pfe = 100 * sign * MathSqrt(d * d + nPeriod * nPeriod) / denom;
	}
	BufferPFERaw[i] = pfe;
    }
    
    if (timeFrame == Period() || bSmoothAll) {
	for (i = limit - 1; i >= 0; i--) {
	    BufferPFEValue[i] = iMAOnArray(BufferPFERaw, 0, nSmooth, 0, MODE_EMA, i);
	}
    }
    
    // signal check
    for (i = limit - 1; i >= 0; i--) {
	double pfe2 = BufferPFEValue[i + 2];
	double pfe1 = BufferPFEValue[i + 1];
	if (pfe2 - pfe1 < -PFEchange && pfe2 <= -PFEwidth) {
	    BufferLong[i] = -80;
	}
	if (pfe2 - pfe1 > PFEchange && pfe2 >= PFEwidth) {
	    BufferShort[i] = 80;
	}
    }
}
