//+------------------------------------------------------------------+
//|                                            Murrey_Math_MT_VG.mq4 |
//|                       Copyright © 2004, Vladislav Goshkov (VG).  |
//|                                           4vg@mail.ru            |
//+------------------------------------------------------------------+
#property copyright "Vladislav Goshkov (VG)."
#property link      "4vg@mail.ru"

#property indicator_chart_window
#property indicator_buffers 13
#property indicator_color1 LightBlue
#property indicator_color2 Blue
#property indicator_color3 DarkGreen
#property indicator_color4 Red
#property indicator_color5 Magenta
#property indicator_color6 LightBlue
#property indicator_color7 Blue
#property indicator_color8 DarkGreen


double buffer[];

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
extern int P = 64;
extern int MMPeriod = 0;
extern int  NumBars = 500;


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


extern int    mml_wdth_m_2_8 = 1;        // [-2]/8
extern int    mml_wdth_m_1_8 = 1;       // [-1]/8
extern int    mml_wdth_0_8   = 1;        //  [0]/8
extern int    mml_wdth_1_8   = 1;      //  [1]/8
extern int    mml_wdth_2_8   = 1;         //  [2]/8
extern int    mml_wdth_3_8   = 1;       //  [3]/8
extern int    mml_wdth_4_8   = 1;        //  [4]/8
extern int    mml_wdth_5_8   = 1;       //  [5]/8
extern int    mml_wdth_6_8   = 1;         //  [6]/8
extern int    mml_wdth_7_8   = 1;      //  [7]/8
extern int    mml_wdth_8_8   = 1;        //  [8]/8
extern int    mml_wdth_p_1_8 = 1;       // [+1]/8
extern int    mml_wdth_p_2_8 = 1;       // [+2]/8

extern color  MarkColor   = Blue;
extern int    MarkNumber  = 158;


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
        mml[13],
        aa;
string  ln_txt[13],        
        buff_str = "",
        buff_str2 = "";
int     
        bn_v1   = 0,
        bn_v2   = 0,
        OctLinesCnt = 13,
        mml_thk = 8,
        mml_clr[13],
        mml_wdth[13],
        mml_shft = 35,
        nTime = 0,
        CurPeriod = 0,
        nDigits = 0,
        i = 0;
int NewPeriod=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
for(int i=0;i<WindowsTotal();i++){
   ObjectsDeleteAll(i); 
      }

 SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,160); 
   SetIndexBuffer(0,buffer);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,"0");
//---- indicators
   if(MMPeriod>0 )
   {
      NewPeriod   = P*MathCeil(MMPeriod/Period());
      Comment("MMPeriod= ",MMPeriod); 
      }  
   else 
   { 
   NewPeriod = P;
   Comment("MMPeriod= ",Period());  
   }

   ln_txt[0]  = "               [-2/8]P";// "extremely overshoot [-2/8]";// [-2/8]
   ln_txt[1]  = "               [-1/8]P";// "overshoot [-1/8]";// [-1/8]
   ln_txt[2]  = "               [0/8]P";// "Ultimate Support - extremely oversold [0/8]";// [0/8]
   ln_txt[3]  = "               [1/8]P";// "Weak, Stall and Reverse - [1/8]";// [1/8]
   ln_txt[4]  = "               [2/8]P";// "Pivot, Reverse - major [2/8]";// [2/8]
   ln_txt[5]  = "               [3/8]P";// "Bottom of Trading Range - [3/8], if 10-12 bars then 40% Time. BUY Premium Zone";//[3/8]
   ln_txt[6]  = "               [4/8]P";// "Major Support/Resistance Pivotal Point [4/8]- Best New BUY or SELL level";// [4/8]
   ln_txt[7]  = "               [5/8]P";// "Top of Trading Range - [5/8], if 10-12 bars then 40% Time. SELL Premium Zone";//[5/8]
   ln_txt[8]  = "               [6/8]P";// "Pivot, Reverse - major [6/8]";// [6/8]
   ln_txt[9]  = "               [7/8]P";// "Weak, Stall and Reverse - [7/8]";// [7/8]
   ln_txt[10] = "               [8/8]P";// "Ultimate Resistance - extremely overbought [8/8]";// [8/8]
   ln_txt[11] = "               [+1/8]P";// "overshoot [+1/8]";// [+1/8]
   ln_txt[12] = "               [+2/8]P";// "extremely overshoot [+2/8]";// [+2/8]
   
   //mml_shft = 3;
   mml_thk  = 3;

   // Начальная установка цветов уровней октав и толщины линий
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
   
   
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
//---- TODO: add your code here
Comment(" ");   
 for(int i=0;i<WindowsTotal();i++){
   ObjectsDeleteAll(i); 
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {

//---- TODO: add your code here

  double ExtCountedBars=IndicatorCounted();
     int   pos=NumBars-ExtCountedBars-1;

   while(pos>=0)
     {

if( (nTime != Time[pos]) || (CurPeriod != Period()) ) {
   
  //price
   bn_v1 = Lowest(NULL,0,MODE_LOW,NewPeriod+pos,pos);
   bn_v2 = Highest(NULL,0,MODE_HIGH,NewPeriod+pos,pos);

   v1 = Low[bn_v1];
   v2 = High[bn_v2];

//determine fractal.....
   if( v2<=250000 && v2>25000 )
   fractal=100000;
   else
     if( v2<=25000 && v2>2500 )
     fractal=10000;
     else
       if( v2<=2500 && v2>250 )
       fractal=1000;
       else
         if( v2<=250 && v2>25 )
         fractal=100;
         else
           if( v2<=25 && v2>12.5 )
           fractal=12.5;
           else
             if( v2<=12.5 && v2>6.25)
             fractal=12.5;
             else
               if( v2<=6.25 && v2>3.125 )
               fractal=6.25;
               else
                 if( v2<=3.125 && v2>1.5625 )
                 fractal=3.125;
                 else
                   if( v2<=1.5625 && v2>0.390625 )
                   fractal=1.5625;
                   else
                     if( v2<=0.390625 && v2>0)
                     fractal=0.1953125;
      
   range=(v2-v1);
   sum=MathFloor(MathLog(fractal/range)/MathLog(2));
   octave=fractal*(MathPow(0.5,sum));
   mn=MathFloor(v1/octave)*octave;
   if( (mn+octave)>v2 )
   mx=mn+octave; 
   else
     mx=mn+(2*octave);


// calculating xx
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
    else  x5=0;

//x3
    if( (v1>=(mn+(mx-mn)/8))&& (v2<=(7*(mx-mn)/8+mn))&& (x1==0) && (x2==0) && (x4==0) && (x5==0) )
    x3=mn+3*(mx-mn)/4; 
    else x3=0;

//x6
    if( (x1+x2+x3+x4+x5) ==0 )
    x6=mx; 
    else x6=0;

     finalH = x1+x2+x3+x4+x5+x6;
// calculating yy
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

    finalL = y1+y2+y3+y4+y5+y6;

    for( i=0; i<OctLinesCnt; i++) {
         mml[i] = 0;
         }
         
   dmml = (finalH-finalL)/8;

   mml[0] =(finalL-dmml*2); //-2/8
   for( i=1; i<OctLinesCnt; i++) {
        mml[i] = mml[i-1] + dmml;
        }
        
     

  
  
 // if( ObjectFind(buff_str2)  
 
  if( 1==1 ) 
  {
   for( i=0; i<1; i++ ){
   
   buff_str2 = "k";  
  
  
   ObjectCreate(buff_str2, OBJ_VLINE , 0,Time[pos], mml[i]);
   
   ObjectSet(buff_str2, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(buff_str2, OBJPROP_COLOR, mml_clr[i]);
   ObjectSet(buff_str2, OBJPROP_WIDTH, mml_wdth[i]);
   
  }
   }
   
   
   
   for( i=0; i<OctLinesCnt; i++ ){
      
     buff_str = "mml"+i+Time[pos];

    


  
  
      ObjectCreate(buff_str, OBJ_ARROW ,0,Time[pos],mml[i]+3*Point);
       ObjectSet(buff_str, OBJPROP_ARROWCODE, MarkNumber);
       
        ObjectSet(buff_str, OBJPROP_COLOR, mml_clr[i]);
        ObjectSet(buff_str, OBJPROP_WIDTH, mml_wdth[i]);
    
         
       buff_str = "mml_txt"+i;
      if(ObjectFind(buff_str) == -1) {
         ObjectCreate(buff_str, OBJ_TEXT, 0, Time[0], mml_shft);
       ObjectSetText(buff_str, ln_txt[i], 8, "Arial", mml_clr[i]);
        ObjectMove(buff_str, 0, Time[0],  mml[i]);
          }
       else {
         ObjectMove(buff_str, 0, Time[0],  mml[i]);
           }
     
    } // for( i=1; i<=OctLinesCnt; i++ ){

  
  
  
  
  
  
  
  
   nTime    = Time[pos];
   CurPeriod= Period();
   





pos--;


}

}
 
//---- End Of Program
  return(0);
  }
//+------------------------------------------------------------------+