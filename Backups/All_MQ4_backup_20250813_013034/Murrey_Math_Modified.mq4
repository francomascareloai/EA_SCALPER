//+------------------------------------------------------------------+
//|                                         Murrey_Math_Modified.mq4 |
//|                                          rewritten by CrazyChart |
//|                         The last indicator, written for free!!!  |
//+------------------------------------------------------------------+
#property copyright "Murrey_Math_Modified. rewritten by CrazyChart"
#property link      "mailto:newcomer2003@yandex.ru"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 MediumBlue
#property indicator_color2 Red
//---- input parameters
extern int       beginer=200;
extern int       periodtotake=200;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted(),CountBars;
//---- TODO: add your code here
int shift,i2;
 if (CountBars>=Bars) CountBars=Bars;
  SetIndexDrawBegin(0,Bars-CountBars);
  SetIndexDrawBegin(1,Bars-CountBars);
double sum,v1,v2,fractal;
double v45,mml00,mml0,mml1,mml2,mml3,mml4,mml5,mml6,mml7,mml8,mml9,mml98,mml99;
double range,octave,mn,mx,price;
double finalH,finalL;
double x1,x2,x3,x4,x5,x6,y1,y2,y3,y4,y5,y6;

//for (shift=1;shift<=0;shift--) {

//price
v1=(Low[Lowest(NULL,0,MODE_LOW,periodtotake,0)]);
v2=(High[Highest(NULL,0,MODE_HIGH,periodtotake,0)]);

//determine fractal.....
if(v2<=250000 && v2>25000) {
fractal=100000;
}else if(v2<=25000 && v2>2500){
 fractal=10000;
 }else if(v2<=2500 && v2>250){
 fractal=1000;
 }else if (v2<=250 && v2>25) {
 fractal=100;
 }else if (v2<=25 && v2>12.5) {
 fractal=12.5;
 }else if(v2<=12.5 && v2>6.25) {
 fractal=12.5;
 }else if(v2<=6.25 && v2>3.125) {
 fractal=6.25;
 }else if(v2<=3.125 && v2>1.5625) {
 fractal=3.125;
 }else if(v2<=1.5625 && v2>0.390625) {
 fractal=1.5625;
 }else if(v2<=0.390625 && v2>0) {
 fractal=0.1953125;
 }
//debugging((((
//v2=1.5625; 
//v2=0.391625;

range=(v2-v1);
//debugging((((
//fractal=1.5625;

//debugging))))
//Alert("Сейчас матом начну ругаться громко очень 1 фрактал "+fractal);
//Alert("Range, ик... range = "+ range);
sum=MathFloor(MathLog(fractal/range)/MathLog(2));

octave=fractal*(MathPow(0.5,sum));
//Alert("Пьяный индюк говорит, ик... октав = "+ octave);
mn=MathFloor(v1/octave)*octave;

if((mn+octave)>v2) {
mx=mn+octave; 
}else{
mx=mn+(2*octave);
}
// calculating xx
//x2
if((v1>=3/16*(mx-mn)+mn)&& (v2<=9/16*(mx-mn)+mn)) {
x2=mn+(mx-mn)/2; 
}else{
x2=0;
}

//x1
if((v1>=mn-(mx-mn)/8)&& (v2<=5/8*(mx-mn)+mn) && x2==0) {
x1=mn+(mx-mn)/2; 
}else{
x1=0;
}


//x4
if((v1>=mn+7*(mx-mn)/16)&& (v2<=13/16*(mx-mn)+mn)) {
x4=mn+3*(mx-mn)/4; 
}else{
x4=0;
}

//x5
if((v1>=mn+3*(mx-mn)/8)&& (v2<=9/8*(mx-mn)+mn)&& x4==0) {
x5=mx; 
}else{
x5=0;
}

//x3
if((v1>=mn+(mx-mn)/8)&& (v2<=7/8*(mx-mn)+mn)&& x1==0 && x2==0 && x4==0 && x5==0) {
x3=mn+3*(mx-mn)/4; }else{
x3=0;
}

//x6
if((x1+x2+x3+x4+x5)==0) {
x6=mx; }else{
x6=0;
}

finalH=x1+x2+x3+x4+x5+x6;
// calculating yy
//y1
if(x1>0) {
y1=mn; }else{
y1=0;
}

//y2
if(x2>0) {
y2=mn+(mx-mn)/4; }else{
y2=0;
}

//y3
if(x3>0) {
y3=mn+(mx-mn)/4; 
}else{
y3=0;
}

//y4
if(x4>0) {
y4=mn+(mx-mn)/2;
}else{
y4=0;
}

//y5
if(x5>0) {
y5=mn+(mx-mn)/2; 
}else{
y5=0;
}

//y6
if((finalH>0) && (y1+y2+y3+y4+y5==0)) {
y6=mn; 
}else{
y6=0;
}

finalL=y1+y2+y3+y4+y5+y6;



v45=(finalH-finalL)/8;


mml00=(finalL-v45*2);  //-2/8
mml0=(finalL-v45);  //-1/8
mml1=(finalL);// 0/8
mml2=(finalL+v45);// 1/8
mml3=(finalL+2*v45); // 2/8
mml4=(finalL+3*v45); //  3/8
mml5=(finalL+4*v45); //  4/8
mml6=(finalL+5*v45); //  5/8
mml7=(finalL+6*v45); //  6/8 
mml8=(finalL+7*v45);// 7/8
mml9=(finalL+8*v45);// 8/8
mml99=(finalL+9*v45);// +1/8
mml98=(finalL+10*v45);// +2/8
//comment("\n","finalh = ",finalh,"\n","finalL = ",finalL,"\n","v45 = ",v45,
//"\n","octave = ",octave,"\n","mn = ",mn,"\n","mx = ",mx,"\n","Fractal = ",fractal,
//"\n","range = ",range,"\n","sum = ",sum,"\n","high =",v2,"\n","Low = ",v1);
//name: named object name
//text: named object text to set
//font: font name
//size: font size
//color: text color
ObjectsRedraw( ) ;
   //Comment("f,shdfkr "+ mml00);
   	//mml00=Close[5];
   ObjectCreate("mm11_txt",OBJ_TEXT,0,Time[30],mml00,Time[30],mml00); //тайм 30-2/8 блин
   ObjectSetText("mm11_txt","_финал л"+finalH+"mml7 "+mml7,10,"Arial",Magenta);
    		
	ObjectCreate("mm12_txt",OBJ_TEXT,0,Time[30],mml0,Time[30],mml0);
	ObjectSetText("mm12_txt","-1/8 ",10,"Arial",Pink);
	
	ObjectCreate("mm1_txt",OBJ_TEXT,0,Time[30],mml1,Time[30],mml1);
	ObjectSetText("mm1_txt","0/8 ",10,"Arial",Blue);
	
	ObjectCreate("mm2_txt",OBJ_TEXT,0,Time[30],mml2,Time[30],mml2);
	ObjectSetText("mm2_txt","1/8 ",10,"Arial",Orange);

   ObjectCreate("mm3_txt",OBJ_TEXT,0,Time[30],mml3,Time[30],mml3);
	ObjectSetText("mm3_txt","2/8 ",10,"Arial",Red);

   ObjectCreate("mm4_txt",OBJ_TEXT,0,Time[30],mml4,Time[30],mml4);
	ObjectSetText("mm4_txt","3/8 ",10,"Arial",Green);	
	
	ObjectCreate("mm5_txt",OBJ_TEXT,0,Time[30],mml5,Time[30],mml5);
	ObjectSetText("mm5_txt","4/8 ",10,"Arial",Blue);
	
	ObjectCreate("mm6_txt",OBJ_TEXT,0,Time[30],mml6,Time[30],mml6);
	ObjectSetText("mm6_txt","5/8 ",10,"Arial",Green);
	
	ObjectCreate("mm7_txt",OBJ_TEXT,0,Time[30],mml7,Time[30],mml7);
	ObjectSetText("mm7_txt","6/8 ",10,"Arial",Red);
	
	ObjectCreate("mm8_txt",OBJ_TEXT,0,Time[30],mml8,Time[30],mml8);
	ObjectSetText("mm8_txt","7/8 ",10,"Arial",Orange);
	
	ObjectCreate("mm9_txt",OBJ_TEXT,0,Time[30],mml9,Time[30],mml9);
	ObjectSetText("mm9_txt","8/8 ",10,"Arial",Blue);
	
	ObjectCreate("mm-1_txt",OBJ_TEXT,0,Time[30],mml99,Time[30],mml99);
	ObjectSetText("mm-1_txt","+1/8 ",10,"Arial",Pink);
	
	ObjectCreate("mm-2_txt",OBJ_TEXT,0,Time[30],mml98,Time[30],mml98);
	ObjectSetText("mm-2_txt","+2/8 ",10,"Arial",Magenta);

ObjectCreate("mm11",OBJ_HLINE,0,Time[0],mml00,Time[0],mml00);
ObjectMove("MyTrend", 1, Time[0], mml00);
ObjectSet("mm11",OBJPROP_COLOR,Magenta);
ObjectSet("mm11",OBJPROP_WIDTH,2);ObjectSet("mm11",OBJPROP_STYLE,STYLE_SOLID);
// -2/8
ObjectCreate("mm12" ,OBJ_HLINE,0,Time[0],mml0,Time[0],mml0); 
ObjectSet("mm12",OBJPROP_COLOR,Pink);ObjectSet("mm12",OBJPROP_WIDTH,1);ObjectSet("mm12",OBJPROP_STYLE,STYLE_SOLID);
// -1/8
ObjectCreate("mm1" ,OBJ_HLINE,0,Time[0],mml1,Time[0],mml1);
ObjectSet("mm1",OBJPROP_COLOR,Blue);ObjectSet("mm1",OBJPROP_WIDTH,2);ObjectSet("mm1",OBJPROP_STYLE, STYLE_SOLID);
// 0/8
ObjectCreate("mm2" ,OBJ_HLINE,0,Time[0],mml2,Time[0],mml2); 
ObjectSet("mm2",OBJPROP_COLOR,Orange);ObjectSet("mm2",OBJPROP_WIDTH,1);ObjectSet("mm2",OBJPROP_STYLE, STYLE_SOLID);
// 1/8
ObjectCreate("mm3" ,OBJ_HLINE,0,Time[0],mml3,Time[0],mml3); 
ObjectSet("mm3",OBJPROP_COLOR,Red);ObjectSet("mm3",OBJPROP_WIDTH,1);ObjectSet("mm3",OBJPROP_STYLE, STYLE_SOLID);
// 2/8
ObjectCreate("mm4" ,OBJ_HLINE,0,Time[0],mml4,Time[0],mml4); 
ObjectSet("mm4",OBJPROP_COLOR,Green);ObjectSet("mm4",OBJPROP_WIDTH,1);ObjectSet("mm4",OBJPROP_STYLE, STYLE_SOLID);
// 3/8
ObjectCreate("mm5" ,OBJ_HLINE,0,Time[0],mml5,Time[0],mml5); 
ObjectSet("mm5",OBJPROP_COLOR,Blue);ObjectSet("mm5",OBJPROP_WIDTH,1);ObjectSet("mm5",OBJPROP_STYLE, STYLE_SOLID);
// 4/8
ObjectCreate("mm6" ,OBJ_HLINE,0,Time[0],mml6,Time[0],mml6); 
ObjectSet("mm6",OBJPROP_COLOR,Green);ObjectSet("mm6",OBJPROP_WIDTH,1);ObjectSet("mm6",OBJPROP_STYLE, STYLE_SOLID);
// 5/8
ObjectCreate("mm7" ,OBJ_HLINE,0,Time[0],mml7,Time[0],mml7);
ObjectSet("mm7",OBJPROP_COLOR,Red);ObjectSet("mm7",OBJPROP_WIDTH,1);ObjectSet("mm7",OBJPROP_STYLE, STYLE_SOLID);
// 6/8
ObjectCreate("mm8" ,OBJ_HLINE,0,Time[0],mml8,Time[0],mml8); 
ObjectSet("mm8",OBJPROP_COLOR,Orange);ObjectSet("mm8",OBJPROP_WIDTH,1);ObjectSet("mm8",OBJPROP_STYLE, STYLE_SOLID);
// 7/8
ObjectCreate("mm9" ,OBJ_HLINE,0,Time[0],mml9,Time[0],mml9); 
ObjectSet("mm9",OBJPROP_COLOR,Red);ObjectSet("mm9",OBJPROP_WIDTH,2);ObjectSet("mm9",OBJPROP_STYLE, STYLE_SOLID);
// 0/8
ObjectCreate("mm-1" ,OBJ_HLINE,0,Time[0],mml99,Time[0],mml99);
ObjectSet("mm-1",OBJPROP_COLOR,Pink);ObjectSet("mm-1",OBJPROP_WIDTH,1);ObjectSet("mm-1",OBJPROP_STYLE, STYLE_SOLID);
// +2/8
ObjectCreate("mm-2" ,OBJ_HLINE,0,Time[0],mml98,Time[0],mml98);
ObjectSet("mm-2",OBJPROP_COLOR,Magenta);ObjectSet("mm-2",OBJPROP_WIDTH,2);ObjectSet("mm-2",OBJPROP_STYLE, STYLE_SOLID);
// +1/8

//ObjectCreate("12121" ,OBJ_HLINE,0,Time[0],1.2000,Time[0],1.2000);
//ObjectSet("12121",OBJPROP_COLOR,Magenta);ObjectSet("12121",OBJPROP_WIDTH,4);ObjectSet("12121",OBJPROP_STYLE, STYLE_SOLID);
//ExtMapBuffer1[shift]=0.0;
//ExtMapBuffer2[shift]=0.0;
 if(GetLastError()!=0) Alert("Some error message");
  
//}


   
   
   
//----
   return(0);
 }

