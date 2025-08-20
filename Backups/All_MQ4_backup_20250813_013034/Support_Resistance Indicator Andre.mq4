//+------------------------------------------------------------------+
//|                           Income-mentor-Box                        |
//|                   Support and Resistance indicator by Andrew A.                   |
//|                     Created and modified by ANDREW A.                   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "vS"
#property indicator_chart_window
#property link "http://www.investing-news.net"

extern string GMTSettings = "GMTSettings";
extern int LocalTimeZone= 0;
extern int DestTimeZone= 0;

extern string LinePlacement_ = "0 - Lines,labels seperately adjustable";
extern string LinePlacement__ = "1 - All lines next to candle";
extern string LinePlacement___ = "2 - All lines horizontal";
extern int LinePlacement = 0;
//
extern int Show_1Daily_2FibonacciPivots= 1;
//
extern color LabelsColor = Gray;
extern int LabelsFontSize = 8;
extern bool ShowLevelPrices = true;
extern bool ShowPricesInMiddle = false;  // Preffered if you have fullscreen lines
extern bool ShowLabelsOnDaily = false;
extern bool LabelsLeft = false;
extern bool YesterdayLabelsRight = false;
extern bool TodayLabelsRight = true;
extern bool SeperateDayLines = true;
extern bool ShowRange = true;
extern string LinePlacement0 = "0 - Lines since start of day";
extern string LinePlacement1 = "1 - Lines next to candle";
extern string LinePlacement2 = "2 - Lines horizontal";
//
extern bool ShowSupportResistance = true;
extern bool ShowPivotPoint = true;
extern int LineStyleSR= 0;
extern int LineThicknessSR= 1;
extern int LineStylePV= 0;
extern int LineThicknessPV= 1;
extern int SNRLinePlacement = 0;
extern int PivotLinePlacement = 0;
extern color SupportColor= DarkGreen;
extern color ResistanceColor= C'139,0,0'; //Exact Dark Red is 139,0,0
extern color PivotColor= C'30,95,205';
//
extern bool ShowInnerFibs= false;  // Shows Fibonacci levels inside yesterday's highs and lows.
extern bool ShowOuterFibs= false;  // Shows Fibonacci levels outside yesterday's highs and lows.
extern int FiboLineThickness= 1;
extern int FiboLineStyle= 2;
extern int FibosLinePlacementI= 1;
extern int FibosLinePlacementO= 1;
extern color FibColor= DarkSlateGray;
//
extern bool ShowHighLow = true;
extern bool ShowOpen = false;
extern int LineStyleY= 0;
extern int LineThicknessY= 1;
extern int LineStyleO= 2;
extern int LineThicknessO= 1;
extern int YesterdayLinePlacement= 0;
extern int OpenLinePlacement= 0;
extern color OpenColor= C'179,66,206';
extern color YesterdayColor= C'1,149,175';
//
extern bool ShowMidPivots = true;
extern int MidLineStyle= 2;
extern int MidLinePlacement= 0;
extern color MidColor= C'85,85,0';
//
extern bool ShowQtrPivots = false;
extern int QtrLineStyle= 2;
extern int QtrLinePlacement= 0;
extern color QtrColor= DarkSlateGray;
//
extern bool ShowCamarilla = false;
extern bool ShowWeakerCamarilla = false;
extern int LineStyleC= 2;
extern int CamarillaLinePlacement= 0;
extern int WeakerCamarillaLinePlacement= 0;
extern color CamColor= C'114,62,22';
//
extern string Comment___ = "SweetSpots keep false if spread < 1";
extern bool ShowSweetSpots = false;
extern int SweetLineStyle= 2;
extern int SweetLinePlacement= 1;
extern color SweetColor= C'130,18,130';
//
extern string Comment_ = "Thickness of Camarilla,Sweetspots";
extern string Comment__ = "MidPivots and QtrPivots";
extern int LineThickness= 1;

extern bool DebugLogger = false;

int TradingHoursFrom= 0;
int TradingHoursTo= 24;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   return(0);
}

int deinit()
{
   int obj_total= ObjectsTotal();
   
   for (int i= obj_total; i>=0; i--) {
      string name= ObjectName(i);
    
      if (StringSubstr(name,0,7)=="[PIVOT]") 
         ObjectDelete(name);
   }
   Comment(" ");   
   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   static datetime timelastupdate= 0;
   static datetime lasttimeframe= 0;
   
   datetime startofday= 0,
            startofyesterday= 0,
            startofyolines= 0,
            startofopen= 0,
            startofsnr= 0,
            startoffibos= 0,
            startoffibos2= 0,
            startofp= 0,
            startofqtr= 0,
            startofmsr= 0,
            startlabel= 0,
	    startlabel2= 0,
            startofcam= 0,
            startofcam2= 0,
            startofsweet= 0;

   double today_high= 0,
            today_low= 0,
            today_open= 0,
            yesterday_high= 0,
            yesterday_open= 0,
            yesterday_low= 0,
            yesterday_close= 0;

   int idxfirstbaroftoday= 0,
       idxfirstbarofyesterday= 0,
       idxlastbarofyesterday= 0;

   
   // update of chart in seconds
   //if (CurTime()-timelastupdate<UpdateChartEveryXseconds && Period()==lasttimeframe)
   //return (0);
      
   lasttimeframe= Period();
   timelastupdate= CurTime();
   
   //---- exit if period is greater than daily charts
   if(Period() > 1440) {
      return(-1);
   }

   if (DebugLogger) {
      Print("Local time current bar:", TimeToStr(iTime(NULL, PERIOD_H1, 0)));
      Print("Dest  time current bar: ", TimeToStr(iTime(NULL, PERIOD_H1, 0)- (LocalTimeZone - DestTimeZone)*3600), ", tzdiff= ", LocalTimeZone - DestTimeZone);
   }


   // let's find out which hour bars make today and yesterday
   ComputeDayIndices(LocalTimeZone, DestTimeZone, idxfirstbaroftoday, idxfirstbarofyesterday, idxlastbarofyesterday);
 
   startofday= Time[1];
   startofyesterday= iTime(NULL, PERIOD_H1, idxfirstbarofyesterday);
   startofyolines= iTime(NULL, PERIOD_H1, idxfirstbarofyesterday);
   startofopen= Time[1];
   startofsnr= Time[1];
   startoffibos= Time[1];
   startoffibos2= Time[1];
   startofp= Time[1];
   startofqtr= Time[1];
   startofmsr= Time[1];
   startofcam= Time[1]; 
   startofcam2= Time[1];
   startofsweet= Time[1];
   startlabel2= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startlabel= Time[0]; 

   if (Time[0] > iTime(NULL, PERIOD_H1, idxfirstbaroftoday)){   //This does not allow for lines to dissapear after a day change.
   startofday= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startofopen= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startofsnr= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startoffibos= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startoffibos2= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startofp= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startofqtr= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startofmsr= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startofcam= iTime(NULL, PERIOD_H1, idxfirstbaroftoday); 
   startofcam2= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   startofsweet= iTime(NULL, PERIOD_H1, idxfirstbaroftoday);
   }

   string space = "                                          ";
   string space2 = "    ";  //MD,QTR,CM,PV
   string space3 = "     "; //RS
   string space4 = "  ";    //Fib
   string space5 = "   ";   //Fib2 
   string space6 = "   ";  
   string space7 = "                   ";
   string space8 = "                   ";

   if (LabelsLeft){space = "                      ";space2 = "";space3 = "";space4 = "";space5 = "";space6 = "";} 
   if (ShowPricesInMiddle){space = "";space2 = "";space3 = "";space4 = "";space5 = "";space6 = "";}

   // 
   // walk forward through yestday's start and collect high/lows within the same day
   //
   yesterday_high= -99999;  // not high enough to remain alltime high
   yesterday_low=  +99999;  // not low enough to remain alltime low
   
   for (int idxbar= idxfirstbarofyesterday; idxbar>=idxlastbarofyesterday; idxbar--) {

      if (yesterday_open==0)  // grab first value for open
         yesterday_open= iOpen(NULL, PERIOD_H1, idxbar);                      
      
      yesterday_high= MathMax(iHigh(NULL, PERIOD_H1, idxbar), yesterday_high);
      yesterday_low= MathMin(iLow(NULL, PERIOD_H1, idxbar), yesterday_low);
      
      // overwrite close in loop until we leave with the last iteration's value
      yesterday_close= iClose(NULL, PERIOD_H1, idxbar);
   }


   // 
   // walk forward through today and collect high/lows within the same day
   //
   today_open= iOpen(NULL, PERIOD_H1, idxfirstbaroftoday);  // should be open of today start trading hour

   today_high= -99999; // not high enough to remain alltime high
   today_low=  +99999; // not low enough to remain alltime low
   for (int j= idxfirstbaroftoday; j>=0; j--) {
      today_high= MathMax(today_high, iHigh(NULL, PERIOD_H1, j));
      today_low= MathMin(today_low, iLow(NULL, PERIOD_H1, j));
   }
      
   
   // draw the vertical bars that marks the time span
   if(Period() < 1440) {

   if (SeperateDayLines==true) {
   double level= (yesterday_high + yesterday_low + yesterday_close) / 3;
   SetTimeLine("YesterdayStart", " ", idxfirstbarofyesterday, Black, level - 4*Point);
   SetTimeLine("YesterdayEnd", " ", idxfirstbaroftoday, Black, level - 4*Point);
   
   if (DebugLogger) 
      Print("Timezoned values: yo= ", yesterday_open, ", yc =", yesterday_close, ", yhigh= ", yesterday_high, ", ylow= ", yesterday_low, ", to= ", today_open);
   }
   }

   //
   //---- Calculate Levels
   //
   double p, q, d, r1,r2,r3,r4,r5, s1,s2,s3,s4,s5;
   
   d = (today_high - today_low);
   q = (yesterday_high - yesterday_low);
   p = (yesterday_high + yesterday_low + yesterday_close) / 3;

   if(Show_1Daily_2FibonacciPivots == 1)
   {   
   
   r1 = (2*p)-yesterday_low;
   r2 = p+(yesterday_high - yesterday_low);              //	r2 = p-s1+r1;
   r3 = (2*p)+(yesterday_high-(2*yesterday_low));

   s1 = (2*p)-yesterday_high;
   s2 = p-(yesterday_high - yesterday_low);              //	s2 = p-r1+s1;
   s3 = (2*p)-((2* yesterday_high)-yesterday_low);

   }

   if(Show_1Daily_2FibonacciPivots == 2)
   {
   r1 = p+ (q * 0.382);   
   r2 = p+ (q * 0.618);  
   r3 = p+q;  
   r4 = p+ (q * 1.618);
   r5 = p+ (q * 2.618);
   s1 = p- (q * 0.382);
   s2 = p- (q * 0.618);   
   s3 = p-q; 
   s4 = p- (q * 1.618);
   s5 = p- (q * 2.618); 
   }

   //---- High/Low, Open
   if (ShowHighLow) {
      if (YesterdayLabelsRight){startofyesterday = Time[0];space7 = "                                               ";}
      if (LabelsLeft){space7 = "                   ";}
      if (YesterdayLinePlacement==1){startofyolines = Time[1];}
      if (YesterdayLinePlacement==2){startofyolines = WindowFirstVisibleBar();}
      if (ShowPricesInMiddle){space7 = "";}

      SetLevel("YH",space7 + "YH", yesterday_high,  YesterdayColor, LineStyleY, LineThicknessY, startofyolines, startofyesterday);
      SetLevel("YL",space7 + "YL", yesterday_low,   YesterdayColor, LineStyleY, LineThicknessY, startofyolines, startofyesterday);
   }

   if (ShowOpen) {
      if (TodayLabelsRight){startofday = Time[0];space8 = "                                               ";}
      if (LabelsLeft){space8 = "                   ";}
      if (OpenLinePlacement==1){startofopen = Time[1];}
      if (OpenLinePlacement==2){startofopen = WindowFirstVisibleBar();}
      if (ShowPricesInMiddle){space8 = "";}  
     
      SetLevel("TO",space8 + "TO", today_open,      OpenColor, LineStyleO, LineThicknessO, startofopen, startofday);
   }

   //---- SweetSpots
   if (ShowSweetSpots) {
      if (SweetLinePlacement==1){startofsweet = Time[1];}
      if (SweetLinePlacement==2){startofsweet = WindowFirstVisibleBar();}

      int ssp1, ssp2;
      double ds1, ds2;
      
      ssp1= Bid / Point;
      ssp1= ssp1 - ssp1%50;
      ssp2= ssp1 + 50;
      
      ds1= ssp1*Point;
      ds2= ssp2*Point;
      
      SetLevel("SweetSpot",space + DoubleToStr(ds1,Digits), ds1,  SweetColor, SweetLineStyle, LineThickness, startofsweet, startlabel);
      SetLevel("SweetSpot",space + DoubleToStr(ds2,Digits), ds2,  SweetColor, SweetLineStyle, LineThickness, startofsweet, startlabel);
   }

   //---- Pivot Lines
   if (ShowSupportResistance==true) {
      if (SNRLinePlacement==1){startofsnr = Time[1];}
      if (SNRLinePlacement==2){startofsnr = WindowFirstVisibleBar();}

      SetLevel("R5",space + space3 + "R5", r5,      ResistanceColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel); 
      SetLevel("R4",space + space3 + "R4", r4,      ResistanceColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel);
      SetLevel("R1",space + space3 + "R1", r1,      ResistanceColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel);
      SetLevel("R2",space + space3 + "R2", r2,      ResistanceColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel);
      SetLevel("R3",space + space3 + "R3", r3,      ResistanceColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel);

      SetLevel("S1",space + space3 + "S1", s1,      SupportColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel);
      SetLevel("S2",space + space3 + "S2", s2,      SupportColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel);
      SetLevel("S3",space + space3 + "S3", s3,      SupportColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel);
      SetLevel("S4",space + space3 + "S4", s4,      SupportColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel);
      SetLevel("S5",space + space3 + "S5", s5,      SupportColor, LineStyleSR, LineThicknessSR, startofsnr, startlabel);

   }
   //---- Show Pivot Point
 
  if (ShowPivotPoint==true && Show_1Daily_2FibonacciPivots==1) {
      if (PivotLinePlacement==1){startofp = Time[1];}
      if (PivotLinePlacement==2){startofp = WindowFirstVisibleBar();}
      SetLevel("DPV",space + space2 + "DPV", p,    PivotColor, LineStylePV, LineThicknessPV, startofp, startlabel);
   }

  if (ShowPivotPoint==true && Show_1Daily_2FibonacciPivots==2) {
      if (PivotLinePlacement==1){startofp = Time[1];}
      if (PivotLinePlacement==2){startofp = WindowFirstVisibleBar();}
      SetLevel("FPV",space + space2 + "FPV", p,    PivotColor, LineStylePV, LineThicknessPV, startofp, startlabel);
   }


   //---- Fibos of yesterday's range
 
  if (ShowOuterFibs) {
      if (FibosLinePlacementO==1){startoffibos2 = Time[1];}
      if (FibosLinePlacementO==2){startoffibos2 = WindowFirstVisibleBar();}
 
      SetLevel("-62",space + space2 + "-62", yesterday_low - q*0.618,      FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);
      SetLevel("-38",space + space2 + "-38", yesterday_low - q*0.382,      FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);

      SetLevel("+38",space + space2 + "+38", yesterday_high + q*0.382,     FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);
      SetLevel("+62",space + space2 + "+62", yesterday_high +  q*0.618,    FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);

      SetLevel("-12",space + space2 + "-12", yesterday_low - q*0.118,      FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);
      SetLevel("-88",space + space2 + "-88", yesterday_low - q*0.882,      FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);

      SetLevel("+12",space + space2 + "+12", yesterday_high + q*0.118,     FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);
      SetLevel("+88",space + space2 + "+88", yesterday_high +  q*0.882,    FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);

      SetLevel("-76",space + space2 + "-76", yesterday_low - q*0.764,      FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);
      SetLevel("-24",space + space2 + "-24", yesterday_low - q*0.236,      FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);

      SetLevel("+24",space + space2 + "+24", yesterday_high + q*0.236,     FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);
      SetLevel("+76",space + space2 + "+76", yesterday_high +  q*0.764,    FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);

      SetLevel("-50",space + space2 + "-50", yesterday_low - q*0.5,          FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);
      SetLevel("+50",space + space2 + "+50", yesterday_high + q*0.5,         FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);

      SetLevel("-100",space + space6 + "-100", yesterday_low - q*1.0,         FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);
      SetLevel("+100",space + space6 + "+100", yesterday_high + q*1.0,        FibColor, FiboLineStyle, FiboLineThickness, startoffibos2, startlabel);

   }

   if (ShowInnerFibs) {
      if (FibosLinePlacementI==1){startoffibos = Time[1];}
      if (FibosLinePlacementI==2){startoffibos = WindowFirstVisibleBar();}
      SetLevel("50",space + space3 + "50", yesterday_low + q*0.5,           FibColor, FiboLineStyle, FiboLineThickness, startoffibos, startlabel);

      SetLevel("38/62",space + space4 + "38/62", yesterday_low + q*0.382,      FibColor, FiboLineStyle, FiboLineThickness, startoffibos, startlabel);
      SetLevel("62/38",space + space4 + "62/38", yesterday_high - q*0.382,     FibColor, FiboLineStyle, FiboLineThickness, startoffibos, startlabel);

      SetLevel("12/88",space + space4 + "12/88", yesterday_low + q*0.118,      FibColor, FiboLineStyle, FiboLineThickness, startoffibos, startlabel);
      SetLevel("88/12",space + space4 + "88/12", yesterday_high - q*0.118,     FibColor, FiboLineStyle, FiboLineThickness, startoffibos, startlabel);

      SetLevel("24/76",space + space4 + "24/76", yesterday_low + q*0.236,      FibColor, FiboLineStyle, FiboLineThickness, startoffibos, startlabel);
      SetLevel("76/24",space + space4 + "76/24", yesterday_high - q*0.236,     FibColor, FiboLineStyle, FiboLineThickness, startoffibos, startlabel);

   }


   //----- Camarilla Weaker SR Lines
   if (ShowWeakerCamarilla==true) {
   if (WeakerCamarillaLinePlacement==1){startofcam2 = Time[1];}
   if (WeakerCamarillaLinePlacement==2){startofcam2 = WindowFirstVisibleBar();}
  
      double h2,h1,l2,l1;
      h1 = (q*1.1/12)+yesterday_close;
      h2 = (q*1.1/6)+yesterday_close;
      l1 = yesterday_close-(q*1.1/12);	
      l2 = yesterday_close-(q*1.1/6);	
	   
      SetLevel("cH1",space + space2 + "cH1", h1,   CamColor, LineStyleC, LineThickness, startofcam2, startlabel);
      SetLevel("cH2",space + space2 + "cH2", h2,   CamColor, LineStyleC, LineThickness, startofcam2, startlabel);
      SetLevel("cL1",space + space2 + "cL1", l1,   CamColor, LineStyleC, LineThickness, startofcam2, startlabel);
      SetLevel("cL2",space + space2 + "cL2", l2,   CamColor, LineStyleC, LineThickness, startofcam2, startlabel);
   }


   //----- Camarilla Lines
   if (ShowCamarilla==true) {
   if (CamarillaLinePlacement==1){startofcam = Time[1];}
   if (CamarillaLinePlacement==2){startofcam = WindowFirstVisibleBar();}
      
      double h4,h3,l4,l3;
      h4 = (q*0.55)+yesterday_close;
      h3 = (q*0.275)+yesterday_close;
      l3 = yesterday_close-(q*0.275);	
      l4 = yesterday_close-(q*0.55);	
	   
      SetLevel("cH3",space + space2 + "cH3", h3,   CamColor, LineStyleC, LineThickness, startofcam, startlabel);
      SetLevel("cH4",space + space2 + "cH4", h4,   CamColor, LineStyleC, LineThickness, startofcam, startlabel);
      SetLevel("cL3",space + space2 + "cL3", l3,   CamColor, LineStyleC, LineThickness, startofcam, startlabel);
      SetLevel("cL4",space + space2 + "cL4", l4,   CamColor, LineStyleC, LineThickness, startofcam, startlabel);
   }


   //------ Midpoint Pivots 
   if (ShowMidPivots==true) {
      // mid levels between pivots
      if (MidLinePlacement==1){startofmsr = Time[1];}
      if (MidLinePlacement==2){startofmsr = WindowFirstVisibleBar();}

      SetLevel("mR5",space + space2 + "mR5", (r4+r5)/2,    MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);
      SetLevel("mR4",space + space2 + "mR4", (r3+r4)/2,    MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);
      SetLevel("mR3",space + space2 + "mR3", (r2+r3)/2,    MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);
      SetLevel("mR2",space + space2 + "mR2", (r1+r2)/2,    MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);
      SetLevel("mR1",space + space2 + "mR1", (p+r1)/2,     MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);
      SetLevel("mS1",space + space2 + "mS1", (p+s1)/2,     MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);
      SetLevel("mS2",space + space2 + "mS2", (s1+s2)/2,    MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);
      SetLevel("mS3",space + space2 + "mS3", (s2+s3)/2,    MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);
      SetLevel("mS4",space + space2 + "mS4", (s3+s4)/2,    MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);
      SetLevel("mS5",space + space2 + "mS5", (s4+s5)/2,    MidColor, MidLineStyle, LineThickness, startofmsr, startlabel);

   }
   //-------Quarterpoint Pivots
   if (ShowQtrPivots==true) {
      if (QtrLinePlacement==1){startofqtr = Time[1];}
      if (QtrLinePlacement==2){startofqtr = WindowFirstVisibleBar();}

      SetLevel("qR0",space + space2 + "qR0", r4+((r5-r4)/4)*3,    QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qR9",space + space2 + "qR9", r4+(r5-r4)/4,        QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qR8",space + space2 + "qR8", r3+((r4-r3)/4)*3,    QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qR7",space + space2 + "qR7", r3+(r4-r3)/4,        QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qR6",space + space2 + "qR6", r2+((r3-r2)/4)*3,    QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qR5",space + space2 + "qR5", r2+(r3-r2)/4,        QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qR4",space + space2 + "qR4", r1+((r2-r1)/4)*3,    QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qR3",space + space2 + "qR3", r1+(r2-r1)/4,        QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qR2",space + space2 + "qR2", p+((r1-p)/4)*3,      QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qR1",space + space2 + "qR1", p+(r1-p)/4,          QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);     
 
      SetLevel("qS1",space + space2 + "qS1", p-(p-s1)/4,          QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qS2",space + space2 + "qS2", p-((p-s1)/4)*3,      QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);     
      SetLevel("qS3",space + space2 + "qS3", s1-(s1-s2)/4,        QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qS4",space + space2 + "qS4", s1-((s1-s2)/4)*3,    QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel); 
      SetLevel("qS5",space + space2 + "qS5", s2-(s2-s3)/4,        QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);
      SetLevel("qS6",space + space2 + "qS6", s2-((s2-s3)/4)*3,    QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);     
      SetLevel("qS7",space + space2 + "qS7", s3-(s3-s4)/4,        QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);   
      SetLevel("qS8",space + space2 + "qS8", s3-((s3-s4)/4)*3,    QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);   
      SetLevel("qS9",space + space2 + "qS9", s4-(s4-s5)/4,        QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);   
      SetLevel("qS0",space + space2 + "qS0", s4-((s4-s5)/4)*3,    QtrColor, QtrLineStyle, LineThickness, startofqtr, startlabel);   
      }

   //------ Comment for upper left corner
   if (ShowRange) {
      string comment; 
      
   // comment= comment + "Pivot Points (C) vS";
      comment= comment + "Range: Yesterday "+DoubleToStr(MathRound(q/Point),0)   +" pips, Today "+DoubleToStr(MathRound(d/Point),0)+" pips" + "\n";
   // comment= comment + "Highs: Yesterday "+DoubleToStr(yesterday_high,Digits)  +", Today "+DoubleToStr(today_high,Digits) +"\n";
   // comment= comment + "Lows:  Yesterday "+DoubleToStr(yesterday_low,Digits)   +", Today "+DoubleToStr(today_low,Digits)  +"\n";
   // comment= comment + "Close: Yesterday "+DoubleToStr(yesterday_close,Digits) + "\n";
   // comment= comment + "Pivot: " + DoubleToStr(p,Digits) + ", S1/2/3: " + DoubleToStr(s1,Digits) + "/" + DoubleToStr(s2,Digits) + "/" + DoubleToStr(s3,Digits) + "\n" ;
      
      Comment(comment); 
   }

   return(0);
}

 
//+------------------------------------------------------------------+
//| Compute index of first/last bar of yesterday and today           |
//+------------------------------------------------------------------+
void ComputeDayIndices(int tzlocal, int tzdest, int &idxfirstbaroftoday, int &idxfirstbarofyesterday, int &idxlastbarofyesterday)
{     
   int tzdiff= tzlocal - tzdest,
       tzdiffsec= tzdiff*3600;
   
   int dayofweektoday= TimeDayOfWeek(iTime(NULL, PERIOD_H1, 0) - tzdiffsec),  // what day is today in the dest timezone?
       dayofweektofind= -1; 

   //
   // due to gaps in the data, and shift of time around weekends (due 
   // to time zone) it is not as easy as to just look back for a bar 
   // with 00:00 time
   //
   
   idxfirstbaroftoday= 0;
   idxfirstbarofyesterday= 0;
   idxlastbarofyesterday= 0;
       
   switch (dayofweektoday) {
      case 6: // sat
      case 0: // sun
      case 1: // mon
            dayofweektofind= 5; // yesterday in terms of trading was previous friday
            break;
            
      default:
            dayofweektofind= dayofweektoday -1; 
            break;
   }
   
   if (DebugLogger) {
      Print("Dayofweektoday= ", dayofweektoday);
      Print("Dayofweekyesterday= ", dayofweektofind);
   }
       
       
   // search  backwards for the last occrrence (backwards) of the day today (today's first bar)
   for (int i=1; i<=25; i++) {
      datetime timet= iTime(NULL, PERIOD_H1, i) - tzdiffsec;
      if (TimeDayOfWeek(timet)!=dayofweektoday) {
         idxfirstbaroftoday= i-1;
         break;
      }
   }
   

   // search  backwards for the first occrrence (backwards) of the weekday we are looking for (yesterday's last bar)
   for (int j= 0; j<=48; j++) {
      datetime timey= iTime(NULL, PERIOD_H1, i+j) - tzdiffsec;
      if (TimeDayOfWeek(timey)==dayofweektofind) {  // ignore saturdays (a Sa may happen due to TZ conversion)
         idxlastbarofyesterday= i+j;
         break;
      }
   }


   // search  backwards for the first occurrence of weekday before yesterday (to determine yesterday's first bar)
   for (j= 1; j<=24; j++) {
      datetime timey2= iTime(NULL, PERIOD_H1, idxlastbarofyesterday+j) - tzdiffsec;
      if (TimeDayOfWeek(timey2)!=dayofweektofind) {  // ignore saturdays (a Sa may happen due to TZ conversion)
         idxfirstbarofyesterday= idxlastbarofyesterday+j-1;
         break;
      }
   }


   if (DebugLogger) {
      Print("Dest time zone\'s current day starts:", TimeToStr(iTime(NULL, PERIOD_H1, idxfirstbaroftoday)), 
                                                      " (local time), idxbar= ", idxfirstbaroftoday);

      Print("Dest time zone\'s previous day starts:", TimeToStr(iTime(NULL, PERIOD_H1, idxfirstbarofyesterday)), 
                                                      " (local time), idxbar= ", idxfirstbarofyesterday);
      Print("Dest time zone\'s previous day ends:", TimeToStr(iTime(NULL, PERIOD_H1, idxlastbarofyesterday)), 
                                                      " (local time), idxbar= ", idxlastbarofyesterday);
   }
}


//+------------------------------------------------------------------+
//| Set labels and lines                                             |
//+------------------------------------------------------------------+
void SetLevel(string text2, string text, double level, color col1, int linestyle, int thickness, datetime startofday, datetime startlabel)
{
   int digits= Digits;
   string labelname= "[PIVOT] " + text + " Label",
          linename= "[PIVOT] " + text2 + " Line",
          pricelabel; 

   // create or move the horizontal line  
   if (LinePlacement==2){startofday=WindowFirstVisibleBar();}
   if (LinePlacement==1){startofday=Time[1];} 
   if (ObjectFind(linename) != 0) {
      ObjectCreate(linename, OBJ_TREND, 0, startofday, level, Time[0],level);
      ObjectSet(linename, OBJPROP_STYLE, linestyle);
      ObjectSet(linename, OBJPROP_COLOR, col1);
      ObjectSet(linename, OBJPROP_WIDTH, thickness);
      ObjectSet(linename, OBJPROP_BACK, true);
   }
   else {
      ObjectMove(linename, 1, Time[0],level);
      ObjectMove(linename, 0, startofday, level);
   }
   

   // put a label on the line   
   
   if(ShowLabelsOnDaily){

   if (LabelsLeft){startlabel=startofday;}
   if (ShowPricesInMiddle){startlabel=Time[WindowFirstVisibleBar()/3];}
   if (ObjectFind(labelname) != 0) {
      ObjectCreate(labelname, OBJ_TEXT, 0, startlabel, level);
   }
   else {
      ObjectMove(labelname, 0, startlabel, level);
   }

   pricelabel= "" + text;
   if (ShowLevelPrices && StrToInteger(text)==0) 
      pricelabel= pricelabel + " "+DoubleToStr(level, Digits);
   
   ObjectSetText(labelname, pricelabel, LabelsFontSize, "Arial Bold", LabelsColor);
   }

else {

   if(Period() < 1440) {
   if (LabelsLeft){startlabel=startofday;}
   if (ShowPricesInMiddle){startlabel=Time[WindowFirstVisibleBar()/3];}
   if (ObjectFind(labelname) != 0) {
      ObjectCreate(labelname, OBJ_TEXT, 0, startlabel, level);
   }
   else {
      ObjectMove(labelname, 0, startlabel, level);
   }

   pricelabel= "" + text;
   if (ShowLevelPrices && StrToInteger(text)==0) 
      pricelabel= pricelabel + " "+DoubleToStr(level, Digits);
   
   ObjectSetText(labelname, pricelabel, LabelsFontSize, "Arial Bold", LabelsColor);
   }
   } 
}

//+------------------------------------------------------------------+
//| Set Vertical Lines                                               |
//+------------------------------------------------------------------+
void SetTimeLine(string objname, string text, int idx, color col1, double vleveltext) 
{
   string name= "[PIVOT] " + objname;
   int x= iTime(NULL, PERIOD_H1, idx);

   if (ObjectFind(name) != 0) 
      ObjectCreate(name, OBJ_TREND, 0, x, 0, x, 100);
   else {
      ObjectMove(name, 0, x, 0);
      ObjectMove(name, 1, x, 100);
   }
   ObjectSet(name, OBJPROP_BACK, true);   
   ObjectSet(name, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(name, OBJPROP_COLOR, C'85,85,0');
   
   if (ObjectFind(name + " Label") != 0) 
      ObjectCreate(name + " Label", OBJ_TEXT, 0, x, vleveltext);
   else
      ObjectMove(name + " Label", 0, x, vleveltext);
            
   ObjectSetText(name + " Label", text, 8, "Arial", col1);
}