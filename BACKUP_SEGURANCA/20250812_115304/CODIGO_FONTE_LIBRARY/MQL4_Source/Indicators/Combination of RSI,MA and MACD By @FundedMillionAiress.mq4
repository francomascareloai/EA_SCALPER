//+------------------------------------------------------------------+
//|                  4 Period 7 MA Fibo Relational S.R Indicator.mq4 |
//|                 Copyright © 2006, tageiger aka fxid10t@yahoo.com |
//|                                        http://www.metatrader.org |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, tageiger aka fxid10t@yahoo.com"
#property link      "mailto:fxid10t@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Yellow
#property indicator_color2 Gold
#property indicator_color3 Orange
#property indicator_color4 DarkOrange
#property indicator_color5 Goldenrod
#property indicator_color6 DarkGoldenrod
#property indicator_color7 Sienna
//---- input parameters
extern int  Time.Frame=1;
extern bool Show.Ma?=false; 
extern int ma.applied.price=1;
extern int L1.Length=13;
extern int L1.Method=0;
extern int L2.Length=21;
extern int L2.Method=0;
extern int L3.Length=34;
extern int L3.Method=0;
extern int L4.Length=55;
extern int L4.Method=0;
extern int L5.Length=89;
extern int L5.Method=0;
extern int L6.Length=144;
extern int L6.Method=0;
extern int L7.Length=233;
extern int L7.Method=0;
//---- indicator buffers
double L1.Buffer[];
double L2.Buffer[];
double L3.Buffer[];
double L4.Buffer[];
double L5.Buffer[];
double L6.Buffer[];
double L7.Buffer[];
string L1,L2,L3,L4,L5,L6,L7;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
/*---- line shifts when drawing
   SetIndexShift(0,0);
   SetIndexShift(0,0);
   SetIndexShift(0,0);
   SetIndexShift(0,0);
   SetIndexShift(0,0);
   SetIndexShift(0,0);
   SetIndexShift(0,0); */
//---- first positions skipped when drawing
   SetIndexDrawBegin(0,L1.Length);
   SetIndexDrawBegin(1,L2.Length);
   SetIndexDrawBegin(2,L3.Length);
   SetIndexDrawBegin(3,L4.Length);
   SetIndexDrawBegin(4,L5.Length);
   SetIndexDrawBegin(5,L6.Length);
   SetIndexDrawBegin(6,L7.Length);
//---- 7 indicator buffers mapping
   SetIndexBuffer(0,L1.Buffer);
   SetIndexBuffer(1,L2.Buffer);
   SetIndexBuffer(2,L3.Buffer);
   SetIndexBuffer(3,L4.Buffer);
   SetIndexBuffer(4,L5.Buffer);
   SetIndexBuffer(5,L6.Buffer);
   SetIndexBuffer(6,L7.Buffer);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexStyle(6,DRAW_LINE);
//---- index labels
   SetIndexLabel(0,"L1");
   SetIndexLabel(1,"L2");
   SetIndexLabel(2,"L3");
   SetIndexLabel(3,"L4");
   SetIndexLabel(4,"L5");
   SetIndexLabel(5,"L6");
   SetIndexLabel(6,"L7");
//---- initialization done
return(0);  }//end init
int deinit()   {
   ObjectsDeleteAll(0,OBJ_TEXT);ObjectsDeleteAll(0,OBJ_RECTANGLE);
   ObjectsDeleteAll(0,OBJ_ARROW);ObjectsDeleteAll(0,OBJ_TREND);   }//end deinit
int start() {
   if(Time.Frame==Period())   {ObjectsDeleteAll();}
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- main loop
   if(Time.Frame==Period() && Show.Ma?==true)   {
   for(int i=0; i<limit; i++) {
      //---- ma_shift set to 0 because SetIndexShift called abowe
      L1.Buffer[i]=iMA(Symbol(),Time.Frame,L1.Length,0,L1.Method,ma.applied.price,i);
      L2.Buffer[i]=iMA(Symbol(),Time.Frame,L2.Length,0,L2.Method,ma.applied.price,i);
      L3.Buffer[i]=iMA(Symbol(),Time.Frame,L3.Length,0,L3.Method,ma.applied.price,i);
      L4.Buffer[i]=iMA(Symbol(),Time.Frame,L4.Length,0,L4.Method,ma.applied.price,i);
      L5.Buffer[i]=iMA(Symbol(),Time.Frame,L5.Length,0,L5.Method,ma.applied.price,i);
      L6.Buffer[i]=iMA(Symbol(),Time.Frame,L6.Length,0,L6.Method,ma.applied.price,i);
      L7.Buffer[i]=iMA(Symbol(),Time.Frame,L7.Length,0,L7.Method,ma.applied.price,i);  }}

   if(Time.Frame!=Period() || Show.Ma?==false)   {
      L1.Buffer[0]=iMA(Symbol(),Time.Frame,L1.Length,0,L1.Method,ma.applied.price,0);
      L2.Buffer[0]=iMA(Symbol(),Time.Frame,L2.Length,0,L2.Method,ma.applied.price,0);
      L3.Buffer[0]=iMA(Symbol(),Time.Frame,L3.Length,0,L3.Method,ma.applied.price,0);
      L4.Buffer[0]=iMA(Symbol(),Time.Frame,L4.Length,0,L4.Method,ma.applied.price,0);
      L5.Buffer[0]=iMA(Symbol(),Time.Frame,L5.Length,0,L5.Method,ma.applied.price,0);
      L6.Buffer[0]=iMA(Symbol(),Time.Frame,L6.Length,0,L6.Method,ma.applied.price,0);
      L7.Buffer[0]=iMA(Symbol(),Time.Frame,L7.Length,0,L7.Method,ma.applied.price,0);}

//.....Object Names.....
   L1="L1"+" "+Time.Frame+"m";
   L2="L2"+" "+Time.Frame+"m";
   L3="L3"+" "+Time.Frame+"m";
   L4="L4"+" "+Time.Frame+"m";
   L5="L5"+" "+Time.Frame+"m";
   L6="L6"+" "+Time.Frame+"m";
   L7="L7"+" "+Time.Frame+"m";

//....Object Spatial Placement.....
   double zoom.multiplier;int bpw=BarsPerWindow();
   if(bpw<25)              {zoom.multiplier=0.05;}
   if(bpw>25 && bpw<50)    {zoom.multiplier=0.07;}
   if(bpw>50 && bpw<175)   {zoom.multiplier=0.12;}   
   if(bpw>175 && bpw<375)  {zoom.multiplier=0.25;}
   if(bpw>375 && bpw<750)  {zoom.multiplier=0.5;}
   if(bpw>750)   {zoom.multiplier=1;}
   double time.frame.multiplier;
   if(Period()==1)   {time.frame.multiplier=0.65;}
   if(Period()==5)   {time.frame.multiplier=3.25;}
   if(Period()==15)  {time.frame.multiplier=9.75;}
   if(Period()==60)  {time.frame.multiplier=39;}
   if(Time.Frame==1)   {
      datetime m1.1=Time[0]+(1000*time.frame.multiplier*zoom.multiplier);
      datetime m1.2=Time[0]+(3000*time.frame.multiplier*zoom.multiplier);}
   if(Time.Frame==5)   {
      m1.1=Time[0]+(5000*time.frame.multiplier*zoom.multiplier);
      m1.2=Time[0]+(7000*time.frame.multiplier*zoom.multiplier);}
   if(Time.Frame==15)  {
      m1.1=Time[0]+(9000*time.frame.multiplier*zoom.multiplier);
      m1.2=Time[0]+(11000*time.frame.multiplier*zoom.multiplier);}
   if(Time.Frame==60)   {
      m1.1=Time[0]+(13000*time.frame.multiplier*zoom.multiplier);
      m1.2=Time[0]+(16000*time.frame.multiplier*zoom.multiplier);}
//dynamic fibo levels....      
   double lo.ma,hi.ma; i=0;
   lo.ma=L1.Buffer[i];
   if(L2.Buffer[i]<lo.ma)  {lo.ma=L2.Buffer[i];}
   if(L3.Buffer[i]<lo.ma)  {lo.ma=L3.Buffer[i];}
   if(L4.Buffer[i]<lo.ma)  {lo.ma=L4.Buffer[i];}
   if(L5.Buffer[i]<lo.ma)  {lo.ma=L5.Buffer[i];}
   if(L6.Buffer[i]<lo.ma)  {lo.ma=L6.Buffer[i];}
   if(L7.Buffer[i]<lo.ma)  {lo.ma=L7.Buffer[i];}
   lo.ma=NormalizeDouble(lo.ma+(8*Point),Digits);//AliceBlue
      
   hi.ma=L7.Buffer[i];
   if(L6.Buffer[i]>hi.ma)  {hi.ma=L6.Buffer[i];}
   if(L5.Buffer[i]>hi.ma)  {hi.ma=L5.Buffer[i];}
   if(L4.Buffer[i]>hi.ma)  {hi.ma=L4.Buffer[i];}
   if(L3.Buffer[i]>hi.ma)  {hi.ma=L3.Buffer[i];}
   if(L2.Buffer[i]>hi.ma)  {hi.ma=L2.Buffer[i];}
   if(L1.Buffer[i]>hi.ma)  {hi.ma=L1.Buffer[i];}
   hi.ma=NormalizeDouble(hi.ma-(8*Point),Digits);//AliceBlue
      
   double lo.ma.1,lo.ma.2,lo.ma.3,lo.ma.4,lo.ma.5,lo.ma.6;
   lo.ma.1=lo.ma+(8*Point);
   lo.ma.2=lo.ma.1+(11*Point);
   lo.ma.3=lo.ma.2+(16*Point);
   lo.ma.4=lo.ma.3+(27*Point);
   lo.ma.5=lo.ma.4+(43*Point);
   lo.ma.6=lo.ma.5+(90*Point);
     
   double hi.ma.1,hi.ma.2,hi.ma.3,hi.ma.4,hi.ma.5,hi.ma.6;
   hi.ma.1=hi.ma-(8*Point);//LightBlue
   hi.ma.2=hi.ma.1-(11*Point);//DodgerBlue
   hi.ma.3=hi.ma.2-(16*Point);//RoyalBlue
   hi.ma.4=hi.ma.3-(27*Point);//MediumBlue
   hi.ma.5=hi.ma.4-(43*Point);//Blue
   hi.ma.6=hi.ma.5-(90*Point);//DarkBlue

// Dynamic fib Plotting...Current Period Chart
// center fib space      
   if(Time.Frame==Period())   {
      if(lo.ma-hi.ma>Ask-Bid)   {
      ObjectCreate("lo.ma",OBJ_ARROW,0,Time[i],lo.ma);
      ObjectSet("lo.ma",14,4);
      ObjectSet("lo.ma",OBJPROP_COLOR,AliceBlue);
      ObjectCreate("hi.ma",OBJ_ARROW,0,Time[i],hi.ma);
      ObjectSet("hi.ma",14,4);
      ObjectSet("hi.ma",OBJPROP_COLOR,AliceBlue);}
// 1st fib levels      
      if(lo.ma.1-hi.ma.1>Ask-Bid)   {
      ObjectCreate("lo.1",OBJ_ARROW,0,Time[i],lo.ma.1);
      ObjectSet("lo.1",14,4);
      ObjectSet("lo.1",OBJPROP_COLOR,LightBlue);
      ObjectCreate("hi.1",OBJ_ARROW,0,Time[i],hi.ma.1);
      ObjectSet("hi.1",14,4);
      ObjectSet("hi.1",OBJPROP_COLOR,LightBlue);}      
// 2nd fib levels
      if(lo.ma.2-hi.ma.2>Ask-Bid)   {
      ObjectCreate("lo.2",OBJ_ARROW,0,Time[i],lo.ma.2);
      ObjectSet("lo.2",14,4);
      ObjectSet("lo.2",OBJPROP_COLOR,DodgerBlue);
      ObjectCreate("hi.2",OBJ_ARROW,0,Time[i],hi.ma.2);
      ObjectSet("hi.2",14,4);
      ObjectSet("hi.2",OBJPROP_COLOR,DodgerBlue);}
// 3rd fib level
      if(lo.ma.3-hi.ma.3>Ask-Bid)   {
      ObjectCreate("lo.3",OBJ_ARROW,0,Time[i],lo.ma.3);
      ObjectSet("lo.3",14,4);
      ObjectSet("lo.3",OBJPROP_COLOR,RoyalBlue);
      ObjectCreate("hi.3",OBJ_ARROW,0,Time[i],hi.ma.3);
      ObjectSet("hi.3",14,4);
      ObjectSet("hi.3",OBJPROP_COLOR,RoyalBlue);}
// 4th fib level
      if(lo.ma.4-hi.ma.4>1*Point)   {
      ObjectCreate("lo.4",OBJ_ARROW,0,Time[i],lo.ma.4);
      ObjectSet("lo.4",14,4);
      ObjectSet("lo.4",OBJPROP_COLOR,MediumBlue);
      ObjectCreate("hi.4",OBJ_ARROW,0,Time[i],hi.ma.4);
      ObjectSet("hi.4",14,4);
      ObjectSet("hi.4",OBJPROP_COLOR,MediumBlue);}
// 5th fib level
      if(lo.ma.5-hi.ma.5>Ask-Bid)   {
      ObjectCreate("lo.5",OBJ_ARROW,0,Time[i],lo.ma.5);
      ObjectSet("lo.5",14,4);
      ObjectSet("lo.5",OBJPROP_COLOR,Blue);
      ObjectCreate("hi.5",OBJ_ARROW,0,Time[i],hi.ma.5);
      ObjectSet("hi.5",14,4);
      ObjectSet("hi.5",OBJPROP_COLOR,Blue);}
// 6th fib level
      if(lo.ma.6-hi.ma.6>Ask-Bid)   {
      ObjectCreate("lo.6",OBJ_ARROW,0,Time[i],lo.ma.6);
      ObjectSet("lo.6",14,4);
      ObjectSet("lo.6",OBJPROP_COLOR,DarkBlue);
      ObjectCreate("hi.6",OBJ_ARROW,0,Time[i],hi.ma.6);
      ObjectSet("hi.6",14,4);
      ObjectSet("hi.6",OBJPROP_COLOR,DarkBlue);}   }

// Dynamic fib Plotting...Multi Period Lane Support / Resistance 
// center fib space      
   if(lo.ma-hi.ma>Ask-Bid)   {
      ObjectCreate(Time.Frame+"lo.ma",OBJ_TREND,0,m1.1, lo.ma, m1.2, lo.ma);
      ObjectSet(Time.Frame+"lo.ma",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"lo.ma",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"lo.ma",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"lo.ma",OBJPROP_COLOR,AliceBlue);
      ObjectSetText(Time.Frame+"lo.ma",DoubleToStr(lo.ma,Digits),7,"Arial",AliceBlue);
      ObjectCreate(Time.Frame+"hi.ma",OBJ_TREND,0,m1.1, hi.ma, m1.2, hi.ma);
      ObjectSet(Time.Frame+"hi.ma",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"hi.ma",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"hi.ma",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"hi.ma",OBJPROP_COLOR,AliceBlue);
      ObjectSetText(Time.Frame+"hi.ma",DoubleToStr(hi.ma,Digits),7,"Arial",AliceBlue);   }
// 1st level
   if(lo.ma.1-hi.ma.1>Ask-Bid)   {
      ObjectCreate(Time.Frame+"lo.ma.1",OBJ_TREND,0,m1.1, lo.ma.1, m1.2, lo.ma.1);
      ObjectSet(Time.Frame+"lo.ma.1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"lo.ma.1",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"lo.ma.1",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"lo.ma.1",OBJPROP_COLOR,LightBlue);
      ObjectSetText(Time.Frame+"lo.ma.1",DoubleToStr(lo.ma.1,Digits),7,"Arial",LightBlue);

      ObjectCreate(Time.Frame+"hi.ma.1",OBJ_TREND,0,m1.1, hi.ma.1, m1.2, hi.ma.1);
      ObjectSet(Time.Frame+"hi.ma.1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"hi.ma.1",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"hi.ma.1",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"hi.ma.1",OBJPROP_COLOR,LightBlue);
      ObjectSetText(Time.Frame+"hi.ma.1",DoubleToStr(hi.ma.1,Digits),7,"Arial",LightBlue);   }

// 2st level
   if(lo.ma.2-hi.ma.2>Ask-Bid)   {
      ObjectCreate(Time.Frame+"lo.ma.2",OBJ_TREND,0,m1.1, lo.ma.2, m1.2, lo.ma.2);
      ObjectSet(Time.Frame+"lo.ma.2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"lo.ma.2",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"lo.ma.2",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"lo.ma.2",OBJPROP_COLOR,DodgerBlue);
      ObjectSetText(Time.Frame+"lo.ma.2",DoubleToStr(lo.ma.2,Digits),7,"Arial",DodgerBlue);

      ObjectCreate(Time.Frame+"hi.ma.2",OBJ_TREND,0,m1.1, hi.ma.2, m1.2, hi.ma.2);
      ObjectSet(Time.Frame+"hi.ma.2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"hi.ma.2",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"hi.ma.2",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"hi.ma.2",OBJPROP_COLOR,DodgerBlue);
      ObjectSetText(Time.Frame+"hi.ma.2",DoubleToStr(hi.ma.2,Digits),7,"Arial",DodgerBlue);   }     

// 3rd level
   if(lo.ma.3-hi.ma.3>Ask-Bid)   {
      ObjectCreate(Time.Frame+"lo.ma.3",OBJ_TREND,0,m1.1, lo.ma.3, m1.2, lo.ma.3);
      ObjectSet(Time.Frame+"lo.ma.3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"lo.ma.3",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"lo.ma.3",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"lo.ma.3",OBJPROP_COLOR,RoyalBlue);
      ObjectSetText(Time.Frame+"lo.ma.3",DoubleToStr(lo.ma.3,Digits),7,"Arial",RoyalBlue);

      ObjectCreate(Time.Frame+"hi.ma.3",OBJ_TREND,0,m1.1, hi.ma.3, m1.2, hi.ma.3);
      ObjectSet(Time.Frame+"hi.ma.3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"hi.ma.3",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"hi.ma.3",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"hi.ma.3",OBJPROP_COLOR,DodgerBlue);
      ObjectSetText(Time.Frame+"hi.ma.3",DoubleToStr(hi.ma.3,Digits),7,"Arial",RoyalBlue);   }

// 4th level
   if(lo.ma.4-hi.ma.4>Ask-Bid)   {
      ObjectCreate(Time.Frame+"lo.ma.4",OBJ_TREND,0,m1.1, lo.ma.4, m1.2, lo.ma.4);
      ObjectSet(Time.Frame+"lo.ma.4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"lo.ma.4",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"lo.ma.4",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"lo.ma.4",OBJPROP_COLOR,MediumBlue);
      ObjectSetText(Time.Frame+"lo.ma.4",DoubleToStr(lo.ma.4,Digits),7,"Arial",MediumBlue);

      ObjectCreate(Time.Frame+"hi.ma.4",OBJ_TREND,0,m1.1, hi.ma.4, m1.2, hi.ma.4);
      ObjectSet(Time.Frame+"hi.ma.4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"hi.ma.4",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"hi.ma.4",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"hi.ma.4",OBJPROP_COLOR,MediumBlue);
      ObjectSetText(Time.Frame+"hi.ma.4",DoubleToStr(hi.ma.4,Digits),7,"Arial",MediumBlue);   }

// 5th level
   if(lo.ma.5-hi.ma.5>Ask-Bid)   {
      ObjectCreate(Time.Frame+"lo.ma.5",OBJ_TREND,0,m1.1, lo.ma.5, m1.2, lo.ma.5);
      ObjectSet(Time.Frame+"lo.ma.5",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"lo.ma.5",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"lo.ma.5",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"lo.ma.5",OBJPROP_COLOR,Blue);
      ObjectSetText(Time.Frame+"lo.ma.5",DoubleToStr(lo.ma.5,Digits),7,"Arial",Blue);

      ObjectCreate(Time.Frame+"hi.ma.5",OBJ_TREND,0,m1.1, hi.ma.5, m1.2, hi.ma.5);
      ObjectSet(Time.Frame+"hi.ma.5",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"hi.ma.5",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"hi.ma.5",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"hi.ma.5",OBJPROP_COLOR,Blue);
      ObjectSetText(Time.Frame+"hi.ma.5",DoubleToStr(hi.ma.5,Digits),7,"Arial",Blue);   }

// 6th level
   if(lo.ma.6-hi.ma.6>Ask-Bid)   {
      ObjectCreate(Time.Frame+"lo.ma.6",OBJ_TREND,0,m1.1, lo.ma.6, m1.2, lo.ma.6);
      ObjectSet(Time.Frame+"lo.ma.6",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"lo.ma.6",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"lo.ma.6",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"lo.ma.6",OBJPROP_COLOR,DarkBlue);
      ObjectSetText(Time.Frame+"lo.ma.6",DoubleToStr(lo.ma.6,Digits),7,"Arial",DarkBlue);

      ObjectCreate(Time.Frame+"hi.ma.6",OBJ_TREND,0,m1.1, hi.ma.6, m1.2, hi.ma.6);
      ObjectSet(Time.Frame+"hi.ma.6",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(Time.Frame+"hi.ma.6",OBJPROP_WIDTH,2);
      ObjectSet(Time.Frame+"hi.ma.6",OBJPROP_RAY,false);
      ObjectSet(Time.Frame+"hi.ma.6",OBJPROP_COLOR,DarkBlue);
      ObjectSetText(Time.Frame+"hi.ma.6",DoubleToStr(hi.ma.6,Digits),7,"Arial",DarkBlue);   }

//...............Moving Average Support & Resistance Levels..............................
      if(ObjectsTotal(OBJ_TEXT)>28) {ObjectsDeleteAll(0,OBJ_TEXT);}
      string space="             ";
      ObjectCreate(L1,OBJ_TEXT,0,m1.1,NormalizeDouble(L1.Buffer[0],Digits));//13 ma
      ObjectSetText(L1,space+DoubleToStr(L1.Buffer[0],Digits),8,"Arial",White);
      ObjectCreate(L2,OBJ_TEXT,0,m1.1,NormalizeDouble(L2.Buffer[0],Digits));//21 ma
      ObjectSetText(L2,space+DoubleToStr(L2.Buffer[0],Digits),8,"Arial",White);      
      ObjectCreate(L3,OBJ_TEXT,0,m1.1,NormalizeDouble(L3.Buffer[0],Digits));//34 ma
      if(Bid>L3.Buffer[0]) {ObjectSetText(L3,space+DoubleToStr(L3.Buffer[0],Digits),8,"Arial",LightGreen);}
      if(Ask<L3.Buffer[0]) {ObjectSetText(L3,space+DoubleToStr(L3.Buffer[0],Digits),8,"Arial",Pink);}
      if(Bid<=L3.Buffer[0] && Ask>=L3.Buffer[0])  {
         ObjectSetText(L3,space+DoubleToStr(L3.Buffer[0],Digits),8,"Arial",Yellow);}
      ObjectCreate(L4,OBJ_TEXT,0,m1.1,NormalizeDouble(L4.Buffer[0],Digits));//55 ma
      if(Bid>L4.Buffer[0]) {ObjectSetText(L4,space+DoubleToStr(L4.Buffer[0],Digits),8,"Arial",LightGreen);}
      if(Ask<L4.Buffer[0]) {ObjectSetText(L4,space+DoubleToStr(L4.Buffer[0],Digits),8,"Arial",Pink);}
      if(Bid<=L4.Buffer[0] && Ask>=L4.Buffer[0])  {
         ObjectSetText(L4,space+DoubleToStr(L4.Buffer[0],Digits),8,"Arial",Yellow);}
      ObjectCreate(L5,OBJ_TEXT,0,m1.1,NormalizeDouble(L5.Buffer[0],Digits));//89 ma
      if(Bid>L5.Buffer[0]) {ObjectSetText(L5,space+DoubleToStr(L5.Buffer[0],Digits),8,"Arial",Green);}
      if(Ask<L5.Buffer[0]) {ObjectSetText(L5,space+DoubleToStr(L5.Buffer[0],Digits),8,"Arial",Red);}
      if(Bid<=L5.Buffer[0] && Ask>=L5.Buffer[0])  {
         ObjectSetText(L5,space+DoubleToStr(L5.Buffer[0],Digits),8,"Arial",Yellow);}
      ObjectCreate(L6,OBJ_TEXT,0,m1.1,NormalizeDouble(L6.Buffer[0],Digits));//144 ma
      if(Bid>L6.Buffer[0]) {ObjectSetText(L6,space+DoubleToStr(L6.Buffer[0],Digits),8,"Arial",Green);}
      if(Ask<L6.Buffer[0]) {ObjectSetText(L6,space+DoubleToStr(L6.Buffer[0],Digits),8,"Arial",Red);}
      if(Bid<=L6.Buffer[0] && Ask>=L6.Buffer[0])  {
         ObjectSetText(L6,space+DoubleToStr(L6.Buffer[0],Digits),8,"Arial",Yellow);}
      ObjectCreate(L7,OBJ_TEXT,0,m1.1,NormalizeDouble(L7.Buffer[0],Digits));//233 ma
      if(Bid>L7.Buffer[0]) {ObjectSetText(L7,space+DoubleToStr(L7.Buffer[0],Digits),8,"Arial",Green);}
      if(Ask<L7.Buffer[0]) {ObjectSetText(L7,space+DoubleToStr(L7.Buffer[0],Digits),8,"Arial",Red);}
      if(Bid<=L7.Buffer[0] && Ask>=L7.Buffer[0])  {
         ObjectSetText(L7,space+DoubleToStr(L7.Buffer[0],Digits),8,"Arial",Yellow);}
//..................Time Frame "Lanes".................................................     
      string lane.down, lane.up;
      if(ObjectsTotal(OBJ_RECTANGLE)>8) {ObjectsDeleteAll(0,OBJ_RECTANGLE);ObjectsRedraw();}
      lane.down=Bid+" "+Time.Frame; lane.up=Ask+" "+Time.Frame;
      if(Time.Frame==1)   {
         ObjectCreate(lane.down,OBJ_RECTANGLE,0,m1.1,Bid,m1.2,0);
         ObjectSet(lane.down,OBJPROP_COLOR,Red);
         ObjectCreate(lane.up,OBJ_RECTANGLE,0,m1.1,Ask,m1.2,Ask*1.5);
         ObjectSet(lane.up,OBJPROP_COLOR,Green);}
      if(Time.Frame==5)   {
         ObjectCreate(lane.down,OBJ_RECTANGLE,0,m1.1,0,m1.2,Bid);
         ObjectSet(lane.down,OBJPROP_COLOR,Red);
         ObjectCreate(lane.up,OBJ_RECTANGLE,0,m1.1,Ask,m1.2,Ask*1.5);
         ObjectSet(lane.up,OBJPROP_COLOR,Green);}
      if(Time.Frame==15)  {
         ObjectCreate(lane.down,OBJ_RECTANGLE,0,m1.1,Bid,m1.2,0);
         ObjectSet(lane.down,OBJPROP_COLOR,Red);
         ObjectCreate(lane.up,OBJ_RECTANGLE,0,m1.1,Ask,m1.2,Ask*1.5);
         ObjectSet(lane.up,OBJPROP_COLOR,Green);}
      if(Time.Frame==60)   {
         ObjectCreate(lane.down,OBJ_RECTANGLE,0,m1.1,Bid,m1.2,0);
         ObjectSet(lane.down,OBJPROP_COLOR,Red);
         ObjectCreate(lane.up,OBJ_RECTANGLE,0,m1.1,Ask,m1.2,Ask*1.5);
         ObjectSet(lane.up,OBJPROP_COLOR,Green);}
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

