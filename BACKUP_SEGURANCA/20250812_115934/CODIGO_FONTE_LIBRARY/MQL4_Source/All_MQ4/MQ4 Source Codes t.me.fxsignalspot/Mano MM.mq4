//+------------------------------------------------------------------+
//|                                            Murrey_Math_MT_VG.mq4 |
//|                       Copyright © 2004, Vladislav Goshkov (VG).  |
//|                                           4vg@mail.ru            |
//+------------------------------------------------------------------+
#property copyright "Vladislav Goshkov (VG)."
#property link      "4vg@mail.ru"

#property indicator_chart_window

// ============================================================================================
// * Линии 8/8 и 0/8 (Окончательное сопротивление).
// * Эти линии самые сильные и оказывают сильнейшие сопротивления и поддержку.
// ============================================================================================
//* Линия 7/8  (Слабая, место для остановки и разворота). Weak, Stall and Reverse
//* Эта линия слаба. Если цена зашла слишком далеко и слишком быстро и если она остановилась около этой линии, 
//* значит она развернется быстро вниз. Если цена не остановилась около этой линии, она продолжит движение вверх к 8/8.
// ============================================================================================
//* Линия 1/8  (Слабая, место для остановки и разворота). Weak, Stall and Reverse
//* Эта линия слаба. Если цена зашла слишком далеко и слишком быстро и если она остановилась около этой линии, 
//* значит она развернется быстро вверх. Если цена не остановилась около этой линии, она продолжит движение вниз к 0/8.
// ============================================================================================
//* Линии 6/8 и 2/8 (Вращение, разворот). Pivot, Reverse
//* Эти две линии уступают в своей силе только 4/8 в своей способности полностью развернуть ценовое движение.
// ============================================================================================
//* Линия 5/8 (Верх торгового диапазона). Top of Trading Range
//* Цены всех рынков тратят 40% времени, на движение между 5/8 и 3/8 линиями. 
//* Если цена двигается около линии 5/8 и остается около нее в течении 10-12 дней, рынок сказал что следует 
//* продавать в этой «премиальной зоне», что и делают некоторые люди, но если цена сохраняет тенденцию оставаться 
//* выше 5/8, то она и останется выше нее. Если, однако, цена падает ниже 5/8, то она скорее всего продолжит 
//* падать далее до следующего уровня сопротивления.
// ============================================================================================
//* Линия 3/8 (Дно торгового диапазона). Bottom of Trading Range
//* Если цены ниже этой лини и двигаются вверх, то цене будет сложно пробить этот уровень. 
//* Если пробивают вверх эту линию и остаются выше нее в течении 10-12 дней, значит цены останутся выше этой линии 
//* и потратят 40% времени двигаясь между этой линией и 5/8 линией.
// ============================================================================================
//* Линия 4/8 (Главная линия сопротивления/поддержки). Major Support/Resistance
//* Эта линия обеспечивает наибольшее сопротивление/поддержку. Этот уровень является лучшим для новой покупки или продажи. 
//* Если цена находится выше 4/8, то это сильный уровень поддержки. Если цена находится ниже 4/8, то это прекрасный уровень 
//* сопротивления.
// ============================================================================================
extern int    P                      = 64;
extern int    MMPeriod               = 1440;
extern int    StepBack               = 0;
extern int    ShowDays               = 10;
extern bool   babylines              = true;
extern int    babyLinesStyle         = STYLE_SOLID;
extern bool   fiftyPercentLine       = true;
extern int    fiftyPercentLineStyle  = STYLE_DASH;
extern bool   alertsOn               = false;
extern double alertsTolerance        = 1.0;
extern bool   touchChanell           = false;
extern bool   alertsOnCurrent        = false;
extern bool   alertsMessage          = true;
extern bool   alertsSound            = false;
extern bool   alertsEmail            = false;
extern bool   alertsShowTouched      = true;
extern int    barsToShowCandles      = 1000;
extern color  BarUpColor             = Green; 
extern color  BarDownColor           = Red; 
extern color  BabyBarUpColor         = Lime; 
extern color  BabyBarDownColor       = Pink; 
extern color  WickColor              = Gray;
extern int    CandleWidth            = 3;

extern color  mml_clr_m_2_8 = White;       // [-2]/8
extern color  mml_clr_m_1_8 = White;       // [-1]/8
extern color  mml_clr_0_8   = Aqua;        //  [0]/8
extern color  mml_clr_1_8   = Yellow;      //  [1]/8
extern color  mml_clr_2_8   = Red;         //  [2]/8
extern color  mml_clr_3_8   = Green;       //  [3]/8
extern color  mml_clr_4_8   = Blue;        //  [4]/8
extern color  mml_clr_5_8   = Green;       //  [5]/8
extern color  mml_clr_6_8   = Red;         //  [6]/8
extern color  mml_clr_7_8   = Yellow;      //  [7]/8
extern color  mml_clr_8_8   = Aqua;        //  [8]/8
extern color  mml_clr_p_1_8 = White;       // [+1]/8
extern color  mml_clr_p_2_8 = White;       // [+2]/8

extern int    mml_wdth_m_2_8 = 2;     // [-2]/8
extern int    mml_wdth_m_1_8 = 1;     // [-1]/8
extern int    mml_wdth_0_8   = 1;     //  [0]/8
extern int    mml_wdth_1_8   = 1;     //  [1]/8
extern int    mml_wdth_2_8   = 1;     //  [2]/8
extern int    mml_wdth_3_8   = 1;     //  [3]/8
extern int    mml_wdth_4_8   = 1;     //  [4]/8
extern int    mml_wdth_5_8   = 1;     //  [5]/8
extern int    mml_wdth_6_8   = 1;     //  [6]/8
extern int    mml_wdth_7_8   = 1;     //  [7]/8
extern int    mml_wdth_8_8   = 1;     //  [8]/8
extern int    mml_wdth_p_1_8 = 1;     // [+1]/8
extern int    mml_wdth_p_2_8 = 2;     // [+2]/8

extern color  MarkColor   = Blue;
extern int    MarkNumber  = 217;


double  dmml = 0,
        dvtl = 0,
        sum  = 0,
        v1 = 0,
        v2 = 0,
        mn = 0,
        mx = 0,
        x1 = 0,
        x2 = 0,
        x3 = 0,
        x4 = 0,
        x5 = 0,
        x6 = 0,
        y1 = 0,
        y2 = 0,
        y3 = 0,
        y4 = 0,
        y5 = 0,
        y6 = 0,
        octave = 0,
        fractal = 0,
        range   = 0,
        finalH  = 0,
        finalL  = 0,
        mml[13];

string  ln_txt[13],        
        buff_str = "";
        
int     
        bn_v1   = 0,
        bn_v2   = 0,
        OctLinesCnt = 13,
        mml_thk = 8,
        mml_clr[13],
        mml_wdth[13],
        mml_shft = 0,
        nTime = 0,
        CurPeriod = 0,
        nDigits = 0,
        i = 0;
int    NewPeriod=0;
int    ShowPeriod;
double values[49];
int    totalCandles;
string windowID;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


int init() {
   windowID  = "Mano MM"+MMPeriod;
   if(MMPeriod>0) NewPeriod   = P*MathCeil(MMPeriod/Period());
   else           NewPeriod = P;
   
   ln_txt[0]  = "[-2/8]P";// "extremely overshoot [-2/8]";// [-2/8]
   ln_txt[1]  = "[-1/8]P";// "overshoot [-1/8]";// [-1/8]
   ln_txt[2]  = "[0/8]P";// "Ultimate Support - extremely oversold [0/8]";// [0/8]
   ln_txt[3]  = "[1/8]P";// "Weak, Stall and Reverse - [1/8]";// [1/8]
   ln_txt[4]  = "[2/8]P";// "Pivot, Reverse - major [2/8]";// [2/8]
   ln_txt[5]  = "[3/8]P";// "Bottom of Trading Range - [3/8], if 10-12 bars then 40% Time. BUY Premium Zone";//[3/8]
   ln_txt[6]  = "[4/8]P";// "Major Support/Resistance Pivotal Point [4/8]- Best New BUY or SELL level";// [4/8]
   ln_txt[7]  = "[5/8]P";// "Top of Trading Range - [5/8], if 10-12 bars then 40% Time. SELL Premium Zone";//[5/8]
   ln_txt[8]  = "[6/8]P";// "Pivot, Reverse - major [6/8]";// [6/8]
   ln_txt[9]  = "[7/8]P";// "Weak, Stall and Reverse - [7/8]";// [7/8]
   ln_txt[10] = "[8/8]P";// "Ultimate Resistance - extremely overbought [8/8]";// [8/8]
   ln_txt[11] = "[+1/8]P";// "overshoot [+1/8]";// [+1/8]
   ln_txt[12] = "[+2/8]P";// "extremely overshoot [+2/8]";// [+2/8]

   mml_thk  = 3;
   mml_clr[0]  = mml_clr_m_2_8;   mml_wdth[0] = mml_wdth_m_2_8; // [-2]/8
   mml_clr[1]  = mml_clr_m_1_8;   mml_wdth[1] = mml_wdth_m_1_8; // [-1]/8
   mml_clr[2]  = mml_clr_0_8;     mml_wdth[2] = mml_wdth_0_8;   //  [0]/8
   mml_clr[3]  = mml_clr_1_8;     mml_wdth[3] = mml_wdth_1_8;   //  [1]/8
   mml_clr[4]  = mml_clr_2_8;     mml_wdth[4] = mml_wdth_2_8;   //  [2]/8
   mml_clr[5]  = mml_clr_3_8;     mml_wdth[5] = mml_wdth_3_8;   //  [3]/8
   mml_clr[6]  = mml_clr_4_8;     mml_wdth[6] = mml_wdth_4_8;   //  [4]/8
   mml_clr[7]  = mml_clr_5_8;     mml_wdth[7] = mml_wdth_5_8;   //  [5]/8
   mml_clr[8]  = mml_clr_6_8;     mml_wdth[8] = mml_wdth_6_8;   //  [6]/8
   mml_clr[9]  = mml_clr_7_8;     mml_wdth[9] = mml_wdth_7_8;   //  [7]/8
   mml_clr[10] = mml_clr_8_8;     mml_wdth[10]= mml_wdth_8_8;   //  [8]/8
   mml_clr[11] = mml_clr_p_1_8;   mml_wdth[11]= mml_wdth_p_1_8; // [+1]/8
   mml_clr[12] = mml_clr_p_2_8;   mml_wdth[12]= mml_wdth_p_2_8; // [+2]/8
   
   switch(Period())
   {
      case PERIOD_MN1:
      case PERIOD_W1:  ShowPeriod = PERIOD_MN1; break;
      case PERIOD_D1:  ShowPeriod = PERIOD_W1;  break;
      default:         ShowPeriod = PERIOD_D1;
   }
   return(0);
}
int deinit()
{
   for(i=0;i<OctLinesCnt;i++) ObjectDelete("mml_txt"+i);
   for(i=0;i<50;i++)          ObjectDelete("MMline"+i);
                              ObjectDelete("LR_LatestCulcBar");
   deleteCandles();                              
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start() {

   
   //
   //
   //
   //
   //
   
   if( (nTime != Time[0]) || (CurPeriod != Period()) )
   {
      ArrayInitialize(values,0.00);
      bn_v1 = iLowest( NULL,0,MODE_LOW, NewPeriod+StepBack,StepBack);
      bn_v2 = iHighest(NULL,0,MODE_HIGH,NewPeriod+StepBack,StepBack);
      v1    = Low[bn_v1];
      v2    = High[bn_v2];
      while (true)
      {
         if( v2 > 25000 )    { fractal=100000;    break; }
         if( v2 > 2500 )     { fractal=10000;     break; }
         if( v2 > 250 )      { fractal=1000;      break; }
         if( v2 > 25 )       { fractal=100;       break; }
         if( v2 > 6.25 )     { fractal=12.5;      break; }
         if( v2 > 3.125 )    { fractal=6.25;      break; }
         if( v2 > 1.5625 )   { fractal=3.125;     break; }
         if( v2 > 0.390625 ) { fractal=1.5625;    break; }
         if( v2 > 0 )        { fractal=0.1953125; break; }
                                                  break;
      }                                            
      
      range  = (v2-v1);
      sum    = MathFloor(MathLog(fractal/range)/MathLog(2));
      octave = fractal*(MathPow(0.5,sum));
      mn     = MathFloor(v1/octave)*octave;

      if( (mn+octave)>v2 )
            mx=mn+octave; 
      else  mx=mn+(2*octave);


      //x2 
            if( (v1>=(3*(mx-mn)/16+mn)) && (v2<=(9*(mx-mn)/16+mn)) )
                 x2=mn+(mx-mn)/2; 
            else x2=0;
      //x1
            if( (v1>=(mn-(mx-mn)/8))&& (v2<=(5*(mx-mn)/8+mn)) && (x2==0) )
                 x1=mn+(mx-mn)/2; 
            else x1=0;
      //x4
            if( (v1>=(mn+7*(mx-mn)/16))&& (v2<=(13*(mx-mn)/16+mn)) )
                 x4=mn+3*(mx-mn)/4; 
            else x4=0;
      //x5
            if( (v1>=(mn+3*(mx-mn)/8))&& (v2<=(9*(mx-mn)/8+mn))&& (x4==0) )
                 x5=mx; 
            else x5=0;
      //x3
            if( (v1>=(mn+(mx-mn)/8))&& (v2<=(7*(mx-mn)/8+mn))&& (x1==0) && (x2==0) && (x4==0) && (x5==0) )
                 x3=mn+3*(mx-mn)/4; 
            else x3=0;
      //x6
            if( (x1+x2+x3+x4+x5) ==0 )
                 x6=mx; 
            else x6=0;

      //
      //
      //
      //
      //
      
      finalH = x1+x2+x3+x4+x5+x6;

      //y1
         if( x1>0 )
              y1=mn; 
         else y1=0;
      //y2
         if( x2>0 )
              y2=mn+(mx-mn)/4; 
         else y2=0;
      //y3
         if( x3>0 )
              y3=mn+(mx-mn)/4; 
         else y3=0;
      //y4
         if( x4>0 )
              y4=mn+(mx-mn)/2; 
         else y4=0;
      //y5
         if( x5>0 )
              y5=mn+(mx-mn)/2; 
         else y5=0;
      //y6
         if( (finalH>0) && ((y1+y2+y3+y4+y5)==0) )
              y6=mn; 
         else y6=0;

      //
      //
      //
      //
      //
    
      finalL = y1+y2+y3+y4+y5+y6;

      ArrayInitialize(mml,0); //  for( i=0; i<OctLinesCnt; i++) {  mml[i] = 0; }
      dmml   = (finalH-finalL)/8;
      mml[0] = (finalL-dmml*2); //-2/8
      for( i=1; i<OctLinesCnt; i++)
      {
        mml[i] = mml[i-1] + dmml;
      }
        
      //
      //
      //
      //
      //
           
      for( i=0; i<OctLinesCnt; i++ )
      {
         CreateBaby(i,mml[i],STYLE_SOLID,mml_clr[i],mml_wdth[i]);
         buff_str = "mml_txt"+i;
            if(ObjectFind(buff_str) == -1)
               ObjectCreate(buff_str, OBJ_TEXT, 0, Time[mml_shft], mml_shft);
               ObjectSetText(buff_str, "                              "+ln_txt[i]+" @ "+DoubleToStr(mml[i],Digits), 8, "Arial", mml_clr[i]);
               ObjectMove(buff_str, 0, Time[mml_shft],  mml[i]);
      }

      //Babylines
      double b222,b224,b226;
      double b112,b114,b116;
      double b02,b04,b06;
      double b12,b14,b16;
      double b22,b24,b26;
      double b32,b34,b36;
      double b42,b44,b46;
      double b52,b54,b56;
      double b62,b64,b66;
      double b72,b74,b76;
      double b82,b84,b86;
      double b92,b94,b96;

      double x0 = mml[0];
      double x1 = mml[1];
      double x2 = mml[2];
      double x3 = mml[3];
      double x4 = mml[4];
      double x5 = mml[5];
      double x6 = mml[6];
      double x7 = mml[7];
      double x8 = mml[8];
      double x9 = mml[9];
      double x10 = mml[10];
      double x11 = mml[11];
      double x12 = mml[12];

      b222 = ((x1-x0)/4)+x0;
      b224 = ((x1-x0)/2)+x0;
      b226 = ((x1-x0)/4)*3+x0;

      b112 = ((x2-x1)/4)+x1;
      b114 = ((x2-x1)/2)+x1;
      b116 = ((x2-x1)/4)*3+x1;

      b02 = ((x3-x2)/4)+x2;
      b04 = ((x3-x2)/2)+x2;
      b06 = ((x3-x2)/4)*3+x2;

      b12 = ((x4-x3)/4)+x3;
      b14 = ((x4-x3)/2)+x3;
      b16 = ((x4-x3)/4)*3+x3;

      b22 = ((x5-x4)/4)+x4;
      b24 = ((x5-x4)/2)+x4;
      b26 = ((x5-x4)/4)*3+x4;

      b32 = ((x6-x5)/4)+x5;
      b34 = ((x6-x5)/2)+x5;
      b36 = ((x6-x5)/4)*3+x5;

      b42 = ((x7-x6)/4)+x6;
      b44 = ((x7-x6)/2)+x6;
      b46 = ((x7-x6)/4)*3+x6;

      b52 = ((x8-x7)/4)+x7;
      b54 = ((x8-x7)/2)+x7;
      b56 = ((x8-x7)/4)*3+x7;

      b62 = ((x9-x8)/4)+x8;
      b64 = ((x9-x8)/2)+x8;
      b66 = ((x9-x8)/4)*3+x8;

      b72 = ((x10-x9)/4)+x9;
      b74 = ((x10-x9)/2)+x9;
      b76 = ((x10-x9)/4)*3+x9;

      b82 = ((x11-x10)/4)+x10;
      b84 = ((x11-x10)/2)+x10;
      b86 = ((x11-x10)/4)*3+x10;

      b92 = ((x12-x11)/4)+x11;
      b94 = ((x12-x11)/2)+x11;
      b96 = ((x12-x11)/4)*3+x11;
      //---------------------------------------------------------
      if (babylines)
      {
      CreateBaby(14,b222,babyLinesStyle);
      CreateBaby(15,b226,babyLinesStyle);
      CreateBaby(16,b112,babyLinesStyle);
      CreateBaby(17,b116,babyLinesStyle);
      CreateBaby(18,b02,babyLinesStyle);
      CreateBaby(19,b06,babyLinesStyle);
      CreateBaby(20,b12,babyLinesStyle);
      CreateBaby(21,b16,babyLinesStyle);
      CreateBaby(22,b22,babyLinesStyle);
      CreateBaby(23,b26,babyLinesStyle);
      CreateBaby(24,b32,babyLinesStyle);
      CreateBaby(25,b36,babyLinesStyle);
      CreateBaby(26,b42,babyLinesStyle);
      CreateBaby(27,b46,babyLinesStyle);
      CreateBaby(28,b52,babyLinesStyle);
      CreateBaby(29,b56,babyLinesStyle);
      CreateBaby(30,b62,babyLinesStyle);
      CreateBaby(31,b66,babyLinesStyle);
      CreateBaby(32,b72,babyLinesStyle);
      CreateBaby(33,b76,babyLinesStyle);
      CreateBaby(34,b82,babyLinesStyle);
      CreateBaby(35,b86,babyLinesStyle);
      CreateBaby(36,b92,babyLinesStyle);
      CreateBaby(37,b96,babyLinesStyle);
      }
      if (fiftyPercentLine)
      {
      CreateBaby(38,b224,fiftyPercentLineStyle);
      CreateBaby(39,b114,fiftyPercentLineStyle);
      CreateBaby(40,b04 ,fiftyPercentLineStyle);
      CreateBaby(41,b14 ,fiftyPercentLineStyle);
      CreateBaby(42,b24 ,fiftyPercentLineStyle);
      CreateBaby(43,b34 ,fiftyPercentLineStyle);
      CreateBaby(44,b44 ,fiftyPercentLineStyle);
      CreateBaby(45,b54 ,fiftyPercentLineStyle);
      CreateBaby(46,b64 ,fiftyPercentLineStyle);
      CreateBaby(47,b74 ,fiftyPercentLineStyle);
      CreateBaby(48,b84 ,fiftyPercentLineStyle);
      CreateBaby(49,b94 ,fiftyPercentLineStyle);
      }

      nTime    = Time[0];
      CurPeriod= Period();
   
      string buff_str = "LR_LatestCulcBar";
      if(ObjectFind(buff_str) == -1) {
         ObjectCreate(buff_str, OBJ_ARROW,0, Time[StepBack], Low[StepBack]-2*Point );
         ObjectSet(buff_str, OBJPROP_ARROWCODE, MarkNumber);
         ObjectSet(buff_str, OBJPROP_COLOR, MarkColor);
      }
      else {
      ObjectMove(buff_str, 0, Time[StepBack], Low[StepBack]-2*Point );
      }
   }

   //
   //
   //
   //
   //
    
   if (alertsOn)          CheckTouches();
   if (alertsShowTouched) ShowCandles();
   return(0);
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//
  
void CreateBaby(string ID, double value,int style=STYLE_SOLID,color clr=DarkSlateGray,int width=0)
{
   string name = "MMline"+ID;

   if (ObjectFind(name) == -1)
      ObjectCreate(name,OBJ_TREND,0,0,0,0,0);
         ObjectSet(name,OBJPROP_COLOR,clr);
         ObjectSet(name,OBJPROP_STYLE,style);
         ObjectSet(name,OBJPROP_WIDTH,width);
         ObjectSet(name,OBJPROP_RAY,false);
         ObjectMove(name,0,Time[0],value);
         ObjectMove(name,1,iTime(NULL,ShowPeriod,ShowDays),value);

   //
   //
   //
   //
   //

   values[StrToInteger(ID)] = value;         
}

//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

void CheckTouches()
{
   for (i=0;i<50;i++) { if (CheckIfTouched(values[i])!=0) break; }         
}
int CheckIfTouched(double compareTo,bool checking=false,int forBar=0)
{
   int    answer = 0;
   double diff   = NormalizeDouble(alertsTolerance*Point,Digits);
   double correction;
   double highDiff;
   double lowDiff;
   
   if (touchChanell)
      {
         correction = NormalizeDouble(alertsTolerance*Point,  Digits);
         diff       = NormalizeDouble(alertsTolerance*Point*2,Digits);
      }         
   else  correction = 0.00;    
   //
   //
   //
   //
   //
      
   int add;
      if (alertsOnCurrent) add = 0;
      else                 add = 1;      
      double value = NormalizeDouble(compareTo,Digits);
          highDiff = NormalizeDouble((value+correction)-High[add+forBar],Digits);
          lowDiff  = NormalizeDouble(Low[add+forBar]-(value-correction),Digits);
          
   //
   //
   //
   //
   //
   
   if (checking)
      {
         if ((highDiff >= 0) && (highDiff <= diff)) answer = -1;
         if ((lowDiff  >= 0) && (lowDiff  <= diff)) answer =  1;
      }
   else
      {
         while (true)
         {
            if ((highDiff >= 0) && (highDiff <= diff)) { answer = -1; doAlert("MM line touched from down"); break; }
            if ((lowDiff  >= 0) && (lowDiff  <= diff)) { answer =  1; doAlert("MM line touched from up");   break; }
                                                                                               break;
         }            
      }
   return(answer);
}

//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;

      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Murrey math ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Murrey math line crossing"),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

void deleteCandles()
{
   while(totalCandles>0) { ObjectDelete(StringConcatenate(windowID,"c-",totalCandles)); totalCandles -= 1; }
}

//
//
//
//
//

void ShowCandles()
{
   deleteCandles();
   for (int i = 0;i<barsToShowCandles;i++)
   {
      if (iTime(NULL,ShowPeriod,ShowDays)<Time[i])
         for (int k=0; k<50; k++) if(CheckSingle(values[k],i,k)) break;
   }
      
}

//
//
//
//
//

bool CheckSingle(double array,int shift,int k)
{
   int result = CheckIfTouched(array,true,shift);
   if (result != 0)
      {
         if (alertsOnCurrent) DrawCandle(shift  ,result,k);
         else                 DrawCandle(shift+1,result,k);
         return(true);
      }
   else
      {
         return(false);
      }         
}

//
//
//
//
//

void DrawCandle(int shift,int upDown,int index)
{
   datetime time  = Time[shift];
   double   high  = iHigh (NULL,0,shift);
   double   low   = iLow  (NULL,0,shift);
   double   open  = iOpen (NULL,0,shift);
   double   close = iClose(NULL,0,shift);
   string name;


   
   totalCandles += 1;
   name    = windowID+"c-"+totalCandles;
      ObjectCreate(name,OBJ_TREND,0,time,high,time,low);
         ObjectSet(name,OBJPROP_COLOR,WickColor);
         ObjectSet(name,OBJPROP_RAY  ,false);
      
   //
   //
   //
   //
   //
         
   totalCandles += 1;
   name    = windowID+"c-"+totalCandles;
      ObjectCreate(name,OBJ_TREND,0,time,open,time,close);
         ObjectSet(name,OBJPROP_WIDTH,CandleWidth);
         ObjectSet(name,OBJPROP_RAY  ,false);
         if (index > 12)
            {
               if (upDown>0)
                     ObjectSet(name,OBJPROP_COLOR,BabyBarUpColor);
               else  ObjectSet(name,OBJPROP_COLOR,BabyBarDownColor);
            }               
         else
            {
               if (upDown>0)
                     ObjectSet(name,OBJPROP_COLOR,BarUpColor);
               else  ObjectSet(name,OBJPROP_COLOR,BarDownColor);
            }               
                     
}