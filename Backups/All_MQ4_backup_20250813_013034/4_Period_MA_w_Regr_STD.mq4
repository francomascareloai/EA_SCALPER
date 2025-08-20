//+------------------------------------------------------------------+
//|                                                   4 Period MA.mq4 |
//|                 Copyright © 2006, tageiger aka fxid10t@yahoo.com |
//|                                        http://www.metatrader.org |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, tageiger aka fxid10t@yahoo.com"
#property link      "mailto:fxid10t@yahoo.com"
#property indicator_chart_window
//----
extern int p1_ma=5;//Period() in minutes
extern int p2_ma=15;//Period() in minutes
extern int p3_ma=60;//Period() in minutes
extern int p4_ma=240;//Period() in minutes
extern int STD_Rgres_length=56;
extern double STD_width=0.809;
extern int ma_applied_price=1;
/*
Applied price constants. It can be any of the following values:
Constant       Value Description 
PRICE_CLOSE    0     Close price. 
PRICE_OPEN     1     Open price. 
PRICE_HIGH     2     High price. 
PRICE_LOW      3     Low price. 
PRICE_MEDIAN   4     Median price, (high+low)/2. 
PRICE_TYPICAL  5     Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6     Weighted close price, (high+low+close+close)/4.
*/
extern int ma_Method=0;
/*
Moving Average Method
Constant    Value Description 
MODE_SMA    0     Simple moving average, 
MODE_EMA    1     Exponential moving average, 
MODE_SMMA   2     Smoothed moving average, 
MODE_LWMA   3     Linear weighted moving average.   
*/
extern int ma1_Length=13;
extern int ma2_Length=21;
extern int ma3_Length=34;
extern int ma4_Length=55;
extern int ma5_Length=89;
extern int ma6_Length=144;
extern int ma7_Length=233;
//----
extern int fib_SR_shadow_1=13;
extern int fib_SR_shadow_2=21;
extern int fib_SR_shadow_3=34;
extern int fib_SR_shadow_4=55;
extern int fib_SR_shadow_5=89;
extern int fib_SR_shadow_6=144;
extern int fib_SR_shadow_7=233;
//----
extern color fib_SR_shadow_1_c=AliceBlue;
extern color fib_SR_shadow_2_c=LightBlue;
extern color fib_SR_shadow_3_c=DodgerBlue;
extern color fib_SR_shadow_4_c=RoyalBlue;
extern color fib_SR_shadow_5_c=Blue;
extern color fib_SR_shadow_6_c=MediumBlue;
extern color fib_SR_shadow_7_c=DarkBlue;
//----
double ma1_p1, ma2_p1, ma3_p1, ma4_p1, ma5_p1, ma6_p1, ma7_p1;
double ma1_p2, ma2_p2, ma3_p2, ma4_p2, ma5_p2, ma6_p2, ma7_p2;
double ma1_p3, ma2_p3, ma3_p3, ma4_p3, ma5_p3, ma6_p3, ma7_p3;
double ma1_p4, ma2_p4, ma3_p4, ma4_p4, ma5_p4, ma6_p4, ma7_p4;
//----
datetime t1_p1, t2_p1, t1_p2, t2_p2, t1_p3, t2_p3, t1_p4, t2_p4;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {  return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int deinit()
  {
   ObjectsDeleteAll(0,OBJ_TEXT);ObjectsDeleteAll(0,OBJ_RECTANGLE);
   ObjectsDeleteAll(0,OBJ_ARROW);ObjectsDeleteAll(0,OBJ_TREND);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int start()
  {
   ObjectsDeleteAll();
   ObjectCreate("regression channel",OBJ_REGRESSION,0,Time[STD_Rgres_length],Bid,Time[0],Ask);
   ObjectSet("regression channel",OBJPROP_RAY,true);
   ObjectCreate("std channel",OBJ_STDDEVCHANNEL,0,Time[STD_Rgres_length],Bid,Time[0],Ask);
   ObjectSet("std channel",OBJPROP_DEVIATION,STD_width);
   ObjectSet("std channel",OBJPROP_COLOR,Olive);
   ObjectSet("std channel",OBJPROP_RAY,true);
   //p1 ma settings
   ma1_p1=iMA(Symbol(),p1_ma,ma1_Length,0,ma_Method,ma_applied_price,0);
   ma2_p1=iMA(Symbol(),p1_ma,ma2_Length,0,ma_Method,ma_applied_price,0);
   ma3_p1=iMA(Symbol(),p1_ma,ma3_Length,0,ma_Method,ma_applied_price,0);
   ma4_p1=iMA(Symbol(),p1_ma,ma4_Length,0,ma_Method,ma_applied_price,0);
   ma5_p1=iMA(Symbol(),p1_ma,ma5_Length,0,ma_Method,ma_applied_price,0);
   ma6_p1=iMA(Symbol(),p1_ma,ma6_Length,0,ma_Method,ma_applied_price,0);
   ma7_p1=iMA(Symbol(),p1_ma,ma7_Length,0,ma_Method,ma_applied_price,0);
//--------------
   //p2 ma settings
   ma1_p2=iMA(Symbol(),p2_ma,ma1_Length,0,ma_Method,ma_applied_price,0);
   ma2_p2=iMA(Symbol(),p2_ma,ma2_Length,0,ma_Method,ma_applied_price,0);
   ma3_p2=iMA(Symbol(),p2_ma,ma3_Length,0,ma_Method,ma_applied_price,0);
   ma4_p2=iMA(Symbol(),p2_ma,ma4_Length,0,ma_Method,ma_applied_price,0);
   ma5_p2=iMA(Symbol(),p2_ma,ma5_Length,0,ma_Method,ma_applied_price,0);
   ma6_p2=iMA(Symbol(),p2_ma,ma6_Length,0,ma_Method,ma_applied_price,0);
   ma7_p2=iMA(Symbol(),p2_ma,ma7_Length,0,ma_Method,ma_applied_price,0);
//--------------
   //p3 ma settings
   ma1_p3=iMA(Symbol(),p3_ma,ma1_Length,0,ma_Method,ma_applied_price,0);
   ma2_p3=iMA(Symbol(),p3_ma,ma2_Length,0,ma_Method,ma_applied_price,0);
   ma3_p3=iMA(Symbol(),p3_ma,ma3_Length,0,ma_Method,ma_applied_price,0);
   ma4_p3=iMA(Symbol(),p3_ma,ma4_Length,0,ma_Method,ma_applied_price,0);
   ma5_p3=iMA(Symbol(),p3_ma,ma5_Length,0,ma_Method,ma_applied_price,0);
   ma6_p3=iMA(Symbol(),p3_ma,ma6_Length,0,ma_Method,ma_applied_price,0);
   ma7_p3=iMA(Symbol(),p3_ma,ma7_Length,0,ma_Method,ma_applied_price,0);
//--------------
   //p4 ma settings
   ma1_p4=iMA(Symbol(),p4_ma,ma1_Length,0,ma_Method,ma_applied_price,0);
   ma2_p4=iMA(Symbol(),p4_ma,ma2_Length,0,ma_Method,ma_applied_price,0);
   ma3_p4=iMA(Symbol(),p4_ma,ma3_Length,0,ma_Method,ma_applied_price,0);
   ma4_p4=iMA(Symbol(),p4_ma,ma4_Length,0,ma_Method,ma_applied_price,0);
   ma5_p4=iMA(Symbol(),p4_ma,ma5_Length,0,ma_Method,ma_applied_price,0);
   ma6_p4=iMA(Symbol(),p4_ma,ma6_Length,0,ma_Method,ma_applied_price,0);
   ma7_p4=iMA(Symbol(),p4_ma,ma7_Length,0,ma_Method,ma_applied_price,0);
//--------------
   Time_Coordinate_Set();
   p1_Fib_Plot();
   p2_Fib_Plot();
   p3_Fib_Plot();
   p4_Fib_Plot();
   column();
//--------------
  return(0);}
//+------------------------------------------------------------------+
  void Time_Coordinate_Set()
  {
   //....Variable Settings for Object Spatial Placement.....
   double zoom_multiplier;int bpw=BarsPerWindow();
   if(bpw<25)              {zoom_multiplier=0.05;}
   if(bpw>25 && bpw<50)    {zoom_multiplier=0.07;}
   if(bpw>50 && bpw<175)   {zoom_multiplier=0.12;}
   if(bpw>175 && bpw<375)  {zoom_multiplier=0.25;}
   if(bpw>375 && bpw<750)  {zoom_multiplier=0.5;}
   if(bpw>750)             {zoom_multiplier=1;}
   double time_frame_multiplier;
   if(Period()==1)      {time_frame_multiplier=0.65;}
   if(Period()==5)      {time_frame_multiplier=3.25;}
   if(Period()==15)     {time_frame_multiplier=9.75;}
   if(Period()==30)     {time_frame_multiplier=19.5;}
   if(Period()==60)     {time_frame_multiplier=39;}
   if(Period()==240)    {time_frame_multiplier=156;}
   if(Period()==1440)   {time_frame_multiplier=936;}
   if(Period()==10080)  {time_frame_multiplier=6552;}
   if(Period()==43200)  {time_frame_multiplier=28043;}
//----
   t1_p1=Time[0]+(1000*time_frame_multiplier*zoom_multiplier);
   t2_p1=Time[0]+(3000*time_frame_multiplier*zoom_multiplier);
//----
   t1_p2=Time[0]+(5000*time_frame_multiplier*zoom_multiplier);
   t2_p2=Time[0]+(7000*time_frame_multiplier*zoom_multiplier);
//----
   t1_p3=Time[0]+(9000*time_frame_multiplier*zoom_multiplier);
   t2_p3=Time[0]+(11000*time_frame_multiplier*zoom_multiplier);
//----
   t1_p4=Time[0]+(13000*time_frame_multiplier*zoom_multiplier);
  t2_p4=Time[0]+(16000*time_frame_multiplier*zoom_multiplier);}//end Time_Coordinate_Set()
//----
  void p1_Fib_Plot()
  {
   //p1 dynamic fibo levels
   double lo_ma_p1,hi_ma_p1;
   lo_ma_p1=ma1_p1;
   if(ma2_p1<lo_ma_p1)  {lo_ma_p1=ma2_p1;}
   if(ma3_p1<lo_ma_p1)  {lo_ma_p1=ma3_p1;}
   if(ma4_p1<lo_ma_p1)  {lo_ma_p1=ma4_p1;}
   if(ma5_p1<lo_ma_p1)  {lo_ma_p1=ma5_p1;}
   if(ma6_p1<lo_ma_p1)  {lo_ma_p1=ma6_p1;}
   if(ma7_p1<lo_ma_p1)  {lo_ma_p1=ma7_p1;}
   lo_ma_p1=NormalizeDouble(lo_ma_p1+(fib_SR_shadow_1*Point),Digits);
//----
   hi_ma_p1=ma7_p1;
   if(ma6_p1>hi_ma_p1)  {hi_ma_p1=ma6_p1;}
   if(ma5_p1>hi_ma_p1)  {hi_ma_p1=ma5_p1;}
   if(ma4_p1>hi_ma_p1)  {hi_ma_p1=ma4_p1;}
   if(ma3_p1>hi_ma_p1)  {hi_ma_p1=ma3_p1;}
   if(ma2_p1>hi_ma_p1)  {hi_ma_p1=ma2_p1;}
   if(ma1_p1>hi_ma_p1)  {hi_ma_p1=ma1_p1;}
   hi_ma_p1=NormalizeDouble(hi_ma_p1-(fib_SR_shadow_1*Point),Digits);
   //p1 center dynamic fib placement      
   if(lo_ma_p1-hi_ma_p1>Ask-Bid)
     {
      ObjectCreate("lcf_p1",OBJ_TREND,0,t1_p1, lo_ma_p1, t2_p1, lo_ma_p1);
      ObjectSet("lcf_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lcf_p1",OBJPROP_WIDTH,2);
      ObjectSet("lcf_p1",OBJPROP_RAY,false);
      ObjectSet("lcf_p1",OBJPROP_COLOR,fib_SR_shadow_1_c);
      ObjectSetText("lcf_p1",DoubleToStr(lo_ma_p1,Digits),7,"Arial",fib_SR_shadow_1_c);
      //----
      ObjectCreate("hcf_p1",OBJ_TREND,0,t1_p1, hi_ma_p1, t2_p1, hi_ma_p1);
      ObjectSet("hcf_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hcf_p1",OBJPROP_WIDTH,2);
      ObjectSet("hcf_p1",OBJPROP_RAY,false);
      ObjectSet("hcf_p1",OBJPROP_COLOR,fib_SR_shadow_1_c);
      ObjectSetText("hcf_p1",DoubleToStr(hi_ma_p1,Digits),7,"Arial",fib_SR_shadow_1_c);
     }
//----
   double lo_ma_p1_1, lo_ma_p1_2, lo_ma_p1_3, lo_ma_p1_4, lo_ma_p1_5, lo_ma_p1_6;
   lo_ma_p1_1=lo_ma_p1+(fib_SR_shadow_2*Point);
   lo_ma_p1_2=lo_ma_p1_1+(fib_SR_shadow_3*Point);
   lo_ma_p1_3=lo_ma_p1_2+(fib_SR_shadow_4*Point);
   lo_ma_p1_4=lo_ma_p1_3+(fib_SR_shadow_5*Point);
   lo_ma_p1_5=lo_ma_p1_4+(fib_SR_shadow_6*Point);
   lo_ma_p1_6=lo_ma_p1_5+(fib_SR_shadow_7*Point);
//----
   double hi_ma_p1_1, hi_ma_p1_2, hi_ma_p1_3, hi_ma_p1_4, hi_ma_p1_5, hi_ma_p1_6;
   hi_ma_p1_1=hi_ma_p1-(fib_SR_shadow_2*Point);
   hi_ma_p1_2=hi_ma_p1_1-(fib_SR_shadow_3*Point);
   hi_ma_p1_3=hi_ma_p1_2-(fib_SR_shadow_4*Point);
   hi_ma_p1_4=hi_ma_p1_3-(fib_SR_shadow_5*Point);
   hi_ma_p1_5=hi_ma_p1_4-(fib_SR_shadow_6*Point);
   hi_ma_p1_6=hi_ma_p1_5-(fib_SR_shadow_7*Point);
   //p1 1st level (hi_1_p1, lo_1_p1)
   if(lo_ma_p1_1-hi_ma_p1_1>Ask-Bid)
     {
      ObjectCreate("lo_1_p1",OBJ_TREND,0,t1_p1, lo_ma_p1_1, t2_p1, lo_ma_p1_1);
      ObjectSet("lo_1_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_1_p1",OBJPROP_WIDTH,2);
      ObjectSet("lo_1_p1",OBJPROP_RAY,false);
      ObjectSet("lo_1_p1",OBJPROP_COLOR,fib_SR_shadow_2_c);
      ObjectSetText("lo_1_p1",DoubleToStr(lo_ma_p1_1,Digits),7,"Arial",fib_SR_shadow_2_c);
      //----
      ObjectCreate("hi_1_p1",OBJ_TREND,0,t1_p1, hi_ma_p1_1, t2_p1, hi_ma_p1_1);
      ObjectSet("hi_1_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_1_p1",OBJPROP_WIDTH,2);
      ObjectSet("hi_1_p1",OBJPROP_RAY,false);
      ObjectSet("hi_1_p1",OBJPROP_COLOR,fib_SR_shadow_2_c);
      ObjectSetText("hi_1_p1",DoubleToStr(hi_ma_p1_1,Digits),7,"Arial",fib_SR_shadow_2_c);
     }
   // 2st level (hi_2_p1, lo_2_p1)
   if(lo_ma_p1_2-hi_ma_p1_2>Ask-Bid)
     {
      ObjectCreate("lo_2_p1",OBJ_TREND,0,t1_p1, lo_ma_p1_2, t2_p1, lo_ma_p1_2);
      ObjectSet("lo_2_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_2_p1",OBJPROP_WIDTH,2);
      ObjectSet("lo_2_p1",OBJPROP_RAY,false);
      ObjectSet("lo_2_p1",OBJPROP_COLOR,fib_SR_shadow_3_c);
      ObjectSetText("lo_2_p1",DoubleToStr(lo_ma_p1_2,Digits),7,"Arial",fib_SR_shadow_3_c);
      //----
      ObjectCreate("hi_2_p1",OBJ_TREND,0,t1_p1, hi_ma_p1_2, t2_p1, hi_ma_p1_2);
      ObjectSet("hi_2_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_2_p1",OBJPROP_WIDTH,2);
      ObjectSet("hi_2_p1",OBJPROP_RAY,false);
      ObjectSet("hi_2_p1",OBJPROP_COLOR,fib_SR_shadow_3_c);
      ObjectSetText("hi_2_p1",DoubleToStr(hi_ma_p1_2,Digits),7,"Arial",fib_SR_shadow_3_c);
     }
   // 3rd level (hi_3_p1, lo_3_p1)
   if(lo_ma_p1_3-hi_ma_p1_3>Ask-Bid)
     {
      ObjectCreate("lo_3_p1",OBJ_TREND,0,t1_p1, lo_ma_p1_3, t2_p1, lo_ma_p1_3);
      ObjectSet("lo_3_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_3_p1",OBJPROP_WIDTH,2);
      ObjectSet("lo_3_p1",OBJPROP_RAY,false);
      ObjectSet("lo_3_p1",OBJPROP_COLOR,fib_SR_shadow_4_c);
      ObjectSetText("lo_3_p1",DoubleToStr(lo_ma_p1_3,Digits),7,"Arial",fib_SR_shadow_4_c);
      //----
      ObjectCreate("hi_3_p1",OBJ_TREND,0,t1_p1, hi_ma_p1_3, t2_p1, hi_ma_p1_3);
      ObjectSet("hi_3_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_3_p1",OBJPROP_WIDTH,2);
      ObjectSet("hi_3_p1",OBJPROP_RAY,false);
      ObjectSet("hi_3_p1",OBJPROP_COLOR,fib_SR_shadow_4_c);
      ObjectSetText("hi_3_p1",DoubleToStr(hi_ma_p1_3,Digits),7,"Arial",fib_SR_shadow_4_c);
     }
   // 4th level (hi_4_p1, lo_4_p1)
   if(lo_ma_p1_4-hi_ma_p1_4>Ask-Bid)
     {
      ObjectCreate("lo_4_p1",OBJ_TREND,0,t1_p1, lo_ma_p1_4, t2_p1, lo_ma_p1_4);
      ObjectSet("lo_4_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_4_p1",OBJPROP_WIDTH,2);
      ObjectSet("lo_4_p1",OBJPROP_RAY,false);
      ObjectSet("lo_4_p1",OBJPROP_COLOR,fib_SR_shadow_5_c);
      ObjectSetText("lo_4_p1",DoubleToStr(lo_ma_p1_4,Digits),7,"Arial",fib_SR_shadow_5_c);
      //----
      ObjectCreate("hi_4_p1",OBJ_TREND,0,t1_p1, hi_ma_p1_4, t2_p1, hi_ma_p1_4);
      ObjectSet("hi_4_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_4_p1",OBJPROP_WIDTH,2);
      ObjectSet("hi_4_p1",OBJPROP_RAY,false);
      ObjectSet("hi_4_p1",OBJPROP_COLOR,fib_SR_shadow_5_c);
      ObjectSetText("hi_4_p1",DoubleToStr(hi_ma_p1_4,Digits),7,"Arial",fib_SR_shadow_5_c);
     }
   // 5th level (hi_5_p1, lo_5_p1)
   if(lo_ma_p1_5-hi_ma_p1_5>Ask-Bid)
     {
      ObjectCreate("lo_5_p1",OBJ_TREND,0,t1_p1, lo_ma_p1_5, t2_p1, lo_ma_p1_5);
      ObjectSet("lo_5_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_5_p1",OBJPROP_WIDTH,2);
      ObjectSet("lo_5_p1",OBJPROP_RAY,false);
      ObjectSet("lo_5_p1",OBJPROP_COLOR,fib_SR_shadow_6_c);
      ObjectSetText("lo_5_p1",DoubleToStr(lo_ma_p1_5,Digits),7,"Arial",fib_SR_shadow_6_c);
      //----
      ObjectCreate("hi_5_p1",OBJ_TREND,0,t1_p1, hi_ma_p1_5, t2_p1, hi_ma_p1_5);
      ObjectSet("hi_5_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_5_p1",OBJPROP_WIDTH,2);
      ObjectSet("hi_5_p1",OBJPROP_RAY,false);
      ObjectSet("hi_5_p1",OBJPROP_COLOR,fib_SR_shadow_6_c);
      ObjectSetText("hi_5_p1",DoubleToStr(hi_ma_p1_5,Digits),7,"Arial",fib_SR_shadow_6_c);
     }
   // 6th level (hi_6_p1, lo_6_p1)
   if(lo_ma_p1_6-hi_ma_p1_6>Ask-Bid)
     {
      ObjectCreate("lo_6_p1",OBJ_TREND,0,t1_p1, lo_ma_p1_6, t2_p1, lo_ma_p1_6);
      ObjectSet("lo_6_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_6_p1",OBJPROP_WIDTH,2);
      ObjectSet("lo_6_p1",OBJPROP_RAY,false);
      ObjectSet("lo_6_p1",OBJPROP_COLOR,fib_SR_shadow_7_c);
      ObjectSetText("lo_6_p1",DoubleToStr(lo_ma_p1_6,Digits),7,"Arial",fib_SR_shadow_7_c);
      //----
      ObjectCreate("hi_6_p1",OBJ_TREND,0,t1_p1, hi_ma_p1_6, t2_p1, hi_ma_p1_6);
      ObjectSet("hi_6_p1",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_6_p1",OBJPROP_WIDTH,2);
      ObjectSet("hi_6_p1",OBJPROP_RAY,false);
      ObjectSet("hi_6_p1",OBJPROP_COLOR,fib_SR_shadow_7_c);
      ObjectSetText("hi_6_p1",DoubleToStr(hi_ma_p1_6,Digits),7,"Arial",fib_SR_shadow_7_c);
     }
   //_______________Moving Average Support & Resistance Levels______________________________
   string space="             ";
   ObjectCreate("ma1_p1",OBJ_TEXT,0,t1_p1,ma1_p1);//13 ma
   ObjectSetText("ma1_p1",space+DoubleToStr(ma1_p1,Digits),8,"Arial",White);
   ObjectCreate("ma2_p1",OBJ_TEXT,0,t1_p1,ma2_p1);//21 ma
   ObjectSetText("ma2_p1",space+DoubleToStr(ma2_p1,Digits),8,"Arial",White);
   ObjectCreate("ma3_p1",OBJ_TEXT,0,t1_p1,ma3_p1);//34 ma
   //----
   if(Bid>ma3_p1) {ObjectSetText("ma3_p1",space+DoubleToStr(ma3_p1,Digits),8,"Arial",LightGreen);}
   if(Ask<ma3_p1) {ObjectSetText("ma3_p1",space+DoubleToStr(ma3_p1,Digits),8,"Arial",Pink);}
   if(Bid<=ma3_p1 && Ask>=ma3_p1)
     {
     ObjectSetText("ma3_p1",space+DoubleToStr(ma3_p1,Digits),8,"Arial",Yellow);}
   ObjectCreate("ma4_p1",OBJ_TEXT,0,t1_p1,ma4_p1);//55 ma
   if(Bid>ma4_p1) {ObjectSetText("ma4_p1",space+DoubleToStr(ma4_p1,Digits),8,"Arial",LightGreen);}
   if(Ask<ma4_p1) {ObjectSetText("ma4_p1",space+DoubleToStr(ma4_p1,Digits),8,"Arial",Pink);}
   if(Bid<=ma4_p1 && Ask>=ma4_p1)
     {
     ObjectSetText("ma4_p1",space+DoubleToStr(ma4_p1,Digits),8,"Arial",Yellow);}
   ObjectCreate("ma5_p1",OBJ_TEXT,0,t1_p1,ma5_p1);//89 ma
   if(Bid>ma5_p1) {ObjectSetText("ma5_p1",space+DoubleToStr(ma5_p1,Digits),8,"Arial",Green);}
   if(Ask<ma5_p1) {ObjectSetText("ma5_p1",space+DoubleToStr(ma5_p1,Digits),8,"Arial",Red);}
   if(Bid<=ma5_p1 && Ask>=ma5_p1)
     {
      ObjectSetText("ma5_p1",space+DoubleToStr(ma5_p1,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma6_p1",OBJ_TEXT,0,t1_p1,NormalizeDouble(ma6_p1,Digits));//144 ma
   if(Bid>ma6_p1) {ObjectSetText("ma6_p1",space+DoubleToStr(ma6_p1,Digits),8,"Arial",Green);}
   if(Ask<ma6_p1) {ObjectSetText("ma6_p1",space+DoubleToStr(ma6_p1,Digits),8,"Arial",Red);}
   if(Bid<=ma6_p1 && Ask>=ma6_p1)
     {
     ObjectSetText("ma6_p1",space+DoubleToStr(ma6_p1,Digits),8,"Arial",Yellow);}
   ObjectCreate("ma7_p1",OBJ_TEXT,0,t1_p1,NormalizeDouble(ma7_p1,Digits));//233 ma
   if(Bid>ma7_p1) {ObjectSetText("ma7_p1",space+DoubleToStr(ma7_p1,Digits),8,"Arial",Green);}
   if(Ask<ma7_p1) {ObjectSetText("ma7_p1",space+DoubleToStr(ma7_p1,Digits),8,"Arial",Red);}
   if(Bid<=ma7_p1 && Ask>=ma7_p1)
     {
     ObjectSetText("ma7_p1",space+DoubleToStr(ma7_p1,Digits),8,"Arial",Yellow);}
  }
  //end p1_Fib_Plot()
  void p2_Fib_Plot()
  {
   //p2 dynamic fibo levels
   double lo_ma_p2,hi_ma_p2;
   lo_ma_p2=ma1_p2;
   if(ma2_p2<lo_ma_p2)  {lo_ma_p2=ma2_p2;}
   if(ma3_p2<lo_ma_p2)  {lo_ma_p2=ma3_p2;}
   if(ma4_p2<lo_ma_p2)  {lo_ma_p2=ma4_p2;}
   if(ma5_p2<lo_ma_p2)  {lo_ma_p2=ma5_p2;}
   if(ma6_p2<lo_ma_p2)  {lo_ma_p2=ma6_p2;}
   if(ma7_p2<lo_ma_p2)  {lo_ma_p2=ma7_p2;}
   lo_ma_p2=NormalizeDouble(lo_ma_p2+(fib_SR_shadow_1*Point),Digits);
//----
   hi_ma_p2=ma7_p2;
   if(ma6_p2>hi_ma_p2)  {hi_ma_p2=ma6_p2;}
   if(ma5_p2>hi_ma_p2)  {hi_ma_p2=ma5_p2;}
   if(ma4_p2>hi_ma_p2)  {hi_ma_p2=ma4_p2;}
   if(ma3_p2>hi_ma_p2)  {hi_ma_p2=ma3_p2;}
   if(ma2_p2>hi_ma_p2)  {hi_ma_p2=ma2_p2;}
   if(ma1_p2>hi_ma_p2)  {hi_ma_p2=ma1_p2;}
   hi_ma_p2=NormalizeDouble(hi_ma_p2-(fib_SR_shadow_1*Point),Digits);
   //p2 center dynamic fib placement      
   if(lo_ma_p2-hi_ma_p2>Ask-Bid)
     {
      ObjectCreate("lcf_p2",OBJ_TREND,0,t1_p2, lo_ma_p2, t2_p2, lo_ma_p2);
      ObjectSet("lcf_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lcf_p2",OBJPROP_WIDTH,2);
      ObjectSet("lcf_p2",OBJPROP_RAY,false);
      ObjectSet("lcf_p2",OBJPROP_COLOR,fib_SR_shadow_1_c);
      ObjectSetText("lcf_p2",DoubleToStr(lo_ma_p2,Digits),7,"Arial",fib_SR_shadow_1_c);
      //----
      ObjectCreate("hcf_p2",OBJ_TREND,0,t1_p2, hi_ma_p2, t2_p2, hi_ma_p2);
      ObjectSet("hcf_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hcf_p2",OBJPROP_WIDTH,2);
      ObjectSet("hcf_p2",OBJPROP_RAY,false);
      ObjectSet("hcf_p2",OBJPROP_COLOR,fib_SR_shadow_1_c);
      ObjectSetText("hcf_p2",DoubleToStr(hi_ma_p2,Digits),7,"Arial",fib_SR_shadow_1_c);
     }
//----
   double lo_ma_p2_1, lo_ma_p2_2, lo_ma_p2_3, lo_ma_p2_4, lo_ma_p2_5, lo_ma_p2_6;
   lo_ma_p2_1=lo_ma_p2+(fib_SR_shadow_2*Point);
   lo_ma_p2_2=lo_ma_p2_1+(fib_SR_shadow_3*Point);
   lo_ma_p2_3=lo_ma_p2_2+(fib_SR_shadow_4*Point);
   lo_ma_p2_4=lo_ma_p2_3+(fib_SR_shadow_5*Point);
   lo_ma_p2_5=lo_ma_p2_4+(fib_SR_shadow_6*Point);
   lo_ma_p2_6=lo_ma_p2_5+(fib_SR_shadow_7*Point);
//----
   double hi_ma_p2_1, hi_ma_p2_2, hi_ma_p2_3, hi_ma_p2_4, hi_ma_p2_5, hi_ma_p2_6;
   hi_ma_p2_1=hi_ma_p2-(fib_SR_shadow_2*Point);
   hi_ma_p2_2=hi_ma_p2_1-(fib_SR_shadow_3*Point);
   hi_ma_p2_3=hi_ma_p2_2-(fib_SR_shadow_4*Point);
   hi_ma_p2_4=hi_ma_p2_3-(fib_SR_shadow_5*Point);
   hi_ma_p2_5=hi_ma_p2_4-(fib_SR_shadow_6*Point);
   hi_ma_p2_6=hi_ma_p2_5-(fib_SR_shadow_7*Point);
   //p2 1st level (hi_1_p2, lo_1_p2)
   if(lo_ma_p2_1-hi_ma_p2_1>Ask-Bid)
     {
      ObjectCreate("lo_1_p2",OBJ_TREND,0,t1_p2, lo_ma_p2_1, t2_p2, lo_ma_p2_1);
      ObjectSet("lo_1_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_1_p2",OBJPROP_WIDTH,2);
      ObjectSet("lo_1_p2",OBJPROP_RAY,false);
      ObjectSet("lo_1_p2",OBJPROP_COLOR,fib_SR_shadow_2_c);
      ObjectSetText("lo_1_p2",DoubleToStr(lo_ma_p2_1,Digits),7,"Arial",fib_SR_shadow_2_c);
      //----
      ObjectCreate("hi_1_p2",OBJ_TREND,0,t1_p2, hi_ma_p2_1, t2_p2, hi_ma_p2_1);
      ObjectSet("hi_1_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_1_p2",OBJPROP_WIDTH,2);
      ObjectSet("hi_1_p2",OBJPROP_RAY,false);
      ObjectSet("hi_1_p2",OBJPROP_COLOR,fib_SR_shadow_2_c);
      ObjectSetText("hi_1_p2",DoubleToStr(hi_ma_p2_1,Digits),7,"Arial",fib_SR_shadow_2_c);
     }
   // 2st level (hi_2_p2, lo_2_p2)
   if(lo_ma_p2_2-hi_ma_p2_2>Ask-Bid)
     {
      ObjectCreate("lo_2_p2",OBJ_TREND,0,t1_p2, lo_ma_p2_2, t2_p2, lo_ma_p2_2);
      ObjectSet("lo_2_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_2_p2",OBJPROP_WIDTH,2);
      ObjectSet("lo_2_p2",OBJPROP_RAY,false);
      ObjectSet("lo_2_p2",OBJPROP_COLOR,fib_SR_shadow_3_c);
      ObjectSetText("lo_2_p2",DoubleToStr(lo_ma_p2_2,Digits),7,"Arial",fib_SR_shadow_3_c);
      //----
      ObjectCreate("hi_2_p2",OBJ_TREND,0,t1_p2, hi_ma_p2_2, t2_p2, hi_ma_p2_2);
      ObjectSet("hi_2_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_2_p2",OBJPROP_WIDTH,2);
      ObjectSet("hi_2_p2",OBJPROP_RAY,false);
      ObjectSet("hi_2_p2",OBJPROP_COLOR,fib_SR_shadow_3_c);
      ObjectSetText("hi_2_p2",DoubleToStr(hi_ma_p2_2,Digits),7,"Arial",fib_SR_shadow_3_c);
     }
   // 3rd level (hi_3_p2, lo_3_p2)
   if(lo_ma_p2_3-hi_ma_p2_3>Ask-Bid)
     {
      ObjectCreate("lo_3_p2",OBJ_TREND,0,t1_p2, lo_ma_p2_3, t2_p2, lo_ma_p2_3);
      ObjectSet("lo_3_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_3_p2",OBJPROP_WIDTH,2);
      ObjectSet("lo_3_p2",OBJPROP_RAY,false);
      ObjectSet("lo_3_p2",OBJPROP_COLOR,fib_SR_shadow_4_c);
      ObjectSetText("lo_3_p2",DoubleToStr(lo_ma_p2_3,Digits),7,"Arial",fib_SR_shadow_4_c);
      //----
      ObjectCreate("hi_3_p2",OBJ_TREND,0,t1_p2, hi_ma_p2_3, t2_p2, hi_ma_p2_3);
      ObjectSet("hi_3_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_3_p2",OBJPROP_WIDTH,2);
      ObjectSet("hi_3_p2",OBJPROP_RAY,false);
      ObjectSet("hi_3_p2",OBJPROP_COLOR,fib_SR_shadow_4_c);
      ObjectSetText("hi_3_p2",DoubleToStr(hi_ma_p2_3,Digits),7,"Arial",fib_SR_shadow_4_c);
     }
   // 4th level (hi_4_p2, lo_4_p2)
   if(lo_ma_p2_4-hi_ma_p2_4>Ask-Bid)
     {
      ObjectCreate("lo_4_p2",OBJ_TREND,0,t1_p2, lo_ma_p2_4, t2_p2, lo_ma_p2_4);
      ObjectSet("lo_4_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_4_p2",OBJPROP_WIDTH,2);
      ObjectSet("lo_4_p2",OBJPROP_RAY,false);
      ObjectSet("lo_4_p2",OBJPROP_COLOR,fib_SR_shadow_5_c);
      ObjectSetText("lo_4_p2",DoubleToStr(lo_ma_p2_4,Digits),7,"Arial",fib_SR_shadow_5_c);
      //----
      ObjectCreate("hi_4_p2",OBJ_TREND,0,t1_p2, hi_ma_p2_4, t2_p2, hi_ma_p2_4);
      ObjectSet("hi_4_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_4_p2",OBJPROP_WIDTH,2);
      ObjectSet("hi_4_p2",OBJPROP_RAY,false);
      ObjectSet("hi_4_p2",OBJPROP_COLOR,fib_SR_shadow_5_c);
      ObjectSetText("hi_4_p2",DoubleToStr(hi_ma_p2_4,Digits),7,"Arial",fib_SR_shadow_5_c);
     }
   // 5th level (hi_5_p2, lo_5_p2)
   if(lo_ma_p2_5-hi_ma_p2_5>Ask-Bid)
     {
      ObjectCreate("lo_5_p2",OBJ_TREND,0,t1_p2, lo_ma_p2_5, t2_p2, lo_ma_p2_5);
      ObjectSet("lo_5_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_5_p2",OBJPROP_WIDTH,2);
      ObjectSet("lo_5_p2",OBJPROP_RAY,false);
      ObjectSet("lo_5_p2",OBJPROP_COLOR,fib_SR_shadow_6_c);
      ObjectSetText("lo_5_p2",DoubleToStr(lo_ma_p2_5,Digits),7,"Arial",fib_SR_shadow_6_c);
      //----
      ObjectCreate("hi_5_p2",OBJ_TREND,0,t1_p2, hi_ma_p2_5, t2_p2, hi_ma_p2_5);
      ObjectSet("hi_5_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_5_p2",OBJPROP_WIDTH,2);
      ObjectSet("hi_5_p2",OBJPROP_RAY,false);
      ObjectSet("hi_5_p2",OBJPROP_COLOR,fib_SR_shadow_6_c);
      ObjectSetText("hi_5_p2",DoubleToStr(hi_ma_p2_5,Digits),7,"Arial",fib_SR_shadow_6_c);
     }
   // 6th level (hi_6_p2, lo_6_p2)
   if(lo_ma_p2_6-hi_ma_p2_6>Ask-Bid)
     {
      ObjectCreate("lo_6_p2",OBJ_TREND,0,t1_p2, lo_ma_p2_6, t2_p2, lo_ma_p2_6);
      ObjectSet("lo_6_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_6_p2",OBJPROP_WIDTH,2);
      ObjectSet("lo_6_p2",OBJPROP_RAY,false);
      ObjectSet("lo_6_p2",OBJPROP_COLOR,fib_SR_shadow_7_c);
      ObjectSetText("lo_6_p2",DoubleToStr(lo_ma_p2_6,Digits),7,"Arial",fib_SR_shadow_7_c);
      //----
      ObjectCreate("hi_6_p2",OBJ_TREND,0,t1_p2, hi_ma_p2_6, t2_p2, hi_ma_p2_6);
      ObjectSet("hi_6_p2",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_6_p2",OBJPROP_WIDTH,2);
      ObjectSet("hi_6_p2",OBJPROP_RAY,false);
      ObjectSet("hi_6_p2",OBJPROP_COLOR,fib_SR_shadow_7_c);
      ObjectSetText("hi_6_p2",DoubleToStr(hi_ma_p2_6,Digits),7,"Arial",fib_SR_shadow_7_c);
     }
   //_______________Moving Average Support & Resistance Levels______________________________
   string space="             ";
   ObjectCreate("ma1_p2",OBJ_TEXT,0,t1_p2,ma1_p2);//13 ma
   ObjectSetText("ma1_p2",space+DoubleToStr(ma1_p2,Digits),8,"Arial",White);
   ObjectCreate("ma2_p2",OBJ_TEXT,0,t1_p2,ma2_p2);//21 ma
   ObjectSetText("ma2_p2",space+DoubleToStr(ma2_p2,Digits),8,"Arial",White);
   ObjectCreate("ma3_p2",OBJ_TEXT,0,t1_p2,ma3_p2);//34 ma
//----
   if(Bid>ma3_p2) {ObjectSetText("ma3_p2",space+DoubleToStr(ma3_p2,Digits),8,"Arial",LightGreen);}
   if(Ask<ma3_p2) {ObjectSetText("ma3_p2",space+DoubleToStr(ma3_p2,Digits),8,"Arial",Pink);}
   if(Bid<=ma3_p2 && Ask>=ma3_p2)
     {
      ObjectSetText("ma3_p2",space+DoubleToStr(ma3_p2,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma4_p2",OBJ_TEXT,0,t1_p2,ma4_p2);//55 ma
   if(Bid>ma4_p2) {ObjectSetText("ma4_p2",space+DoubleToStr(ma4_p2,Digits),8,"Arial",LightGreen);}
   if(Ask<ma4_p2) {ObjectSetText("ma4_p2",space+DoubleToStr(ma4_p2,Digits),8,"Arial",Pink);}
   if(Bid<=ma4_p2 && Ask>=ma4_p2)
     {
      ObjectSetText("ma4_p2",space+DoubleToStr(ma4_p2,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma5_p2",OBJ_TEXT,0,t1_p2,ma5_p2);//89 ma
   if(Bid>ma5_p2) {ObjectSetText("ma5_p2",space+DoubleToStr(ma5_p2,Digits),8,"Arial",Green);}
   if(Ask<ma5_p2) {ObjectSetText("ma5_p2",space+DoubleToStr(ma5_p2,Digits),8,"Arial",Red);}
   if(Bid<=ma5_p2 && Ask>=ma5_p2)
     {
      ObjectSetText("ma5_p2",space+DoubleToStr(ma5_p2,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma6_p2",OBJ_TEXT,0,t1_p2,NormalizeDouble(ma6_p2,Digits));//144 ma
   if(Bid>ma6_p2) {ObjectSetText("ma6_p2",space+DoubleToStr(ma6_p2,Digits),8,"Arial",Green);}
   if(Ask<ma6_p2) {ObjectSetText("ma6_p2",space+DoubleToStr(ma6_p2,Digits),8,"Arial",Red);}
   if(Bid<=ma6_p2 && Ask>=ma6_p2)
     {
      ObjectSetText("ma6_p2",space+DoubleToStr(ma6_p2,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma7_p2",OBJ_TEXT,0,t1_p2,NormalizeDouble(ma7_p2,Digits));//233 ma
   if(Bid>ma7_p2) {ObjectSetText("ma7_p2",space+DoubleToStr(ma7_p2,Digits),8,"Arial",Green);}
   if(Ask<ma7_p2) {ObjectSetText("ma7_p2",space+DoubleToStr(ma7_p2,Digits),8,"Arial",Red);}
   if(Bid<=ma7_p2 && Ask>=ma7_p2)
     {
      ObjectSetText("ma7_p2",space+DoubleToStr(ma7_p2,Digits),8,"Arial",Yellow);
     }
  }
  //end p2_Fib_Plot()
  void p3_Fib_Plot()
  {
   //p3 dynamic fibo levels
   double lo_ma_p3,hi_ma_p3;
   lo_ma_p3=ma1_p3;
   if(ma2_p3<lo_ma_p3)  {lo_ma_p3=ma2_p3;}
   if(ma3_p3<lo_ma_p3)  {lo_ma_p3=ma3_p3;}
   if(ma4_p3<lo_ma_p3)  {lo_ma_p3=ma4_p3;}
   if(ma5_p3<lo_ma_p3)  {lo_ma_p3=ma5_p3;}
   if(ma6_p3<lo_ma_p3)  {lo_ma_p3=ma6_p3;}
   if(ma7_p3<lo_ma_p3)  {lo_ma_p3=ma7_p3;}
   lo_ma_p3=NormalizeDouble(lo_ma_p3+(fib_SR_shadow_1*Point),Digits);
   hi_ma_p3=ma7_p3;
   if(ma6_p3>hi_ma_p3)  {hi_ma_p3=ma6_p3;}
   if(ma5_p3>hi_ma_p3)  {hi_ma_p3=ma5_p3;}
   if(ma4_p3>hi_ma_p3)  {hi_ma_p3=ma4_p3;}
   if(ma3_p3>hi_ma_p3)  {hi_ma_p3=ma3_p3;}
   if(ma2_p3>hi_ma_p3)  {hi_ma_p3=ma2_p3;}
   if(ma1_p3>hi_ma_p3)  {hi_ma_p3=ma1_p3;}
   hi_ma_p3=NormalizeDouble(hi_ma_p3-(fib_SR_shadow_1*Point),Digits);
   //p3 center dynamic fib placement      
   if(lo_ma_p3-hi_ma_p3>Ask-Bid)
     {
      ObjectCreate("lcf_p3",OBJ_TREND,0,t1_p3, lo_ma_p3, t2_p3, lo_ma_p3);
      ObjectSet("lcf_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lcf_p3",OBJPROP_WIDTH,2);
      ObjectSet("lcf_p3",OBJPROP_RAY,false);
      ObjectSet("lcf_p3",OBJPROP_COLOR,fib_SR_shadow_1_c);
      ObjectSetText("lcf_p3",DoubleToStr(lo_ma_p3,Digits),7,"Arial",fib_SR_shadow_1_c);
      //----
      ObjectCreate("hcf_p3",OBJ_TREND,0,t1_p3, hi_ma_p3, t2_p3, hi_ma_p3);
      ObjectSet("hcf_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hcf_p3",OBJPROP_WIDTH,2);
      ObjectSet("hcf_p3",OBJPROP_RAY,false);
      ObjectSet("hcf_p3",OBJPROP_COLOR,fib_SR_shadow_1_c);
      ObjectSetText("hcf_p3",DoubleToStr(hi_ma_p3,Digits),7,"Arial",fib_SR_shadow_1_c);
     }
//----
   double lo_ma_p3_1, lo_ma_p3_2, lo_ma_p3_3, lo_ma_p3_4, lo_ma_p3_5, lo_ma_p3_6;
   lo_ma_p3_1=lo_ma_p3+(fib_SR_shadow_2*Point);
   lo_ma_p3_2=lo_ma_p3_1+(fib_SR_shadow_3*Point);
   lo_ma_p3_3=lo_ma_p3_2+(fib_SR_shadow_4*Point);
   lo_ma_p3_4=lo_ma_p3_3+(fib_SR_shadow_5*Point);
   lo_ma_p3_5=lo_ma_p3_4+(fib_SR_shadow_6*Point);
   lo_ma_p3_6=lo_ma_p3_5+(fib_SR_shadow_7*Point);
//----
   double hi_ma_p3_1, hi_ma_p3_2, hi_ma_p3_3, hi_ma_p3_4, hi_ma_p3_5, hi_ma_p3_6;
   hi_ma_p3_1=hi_ma_p3-(fib_SR_shadow_2*Point);
   hi_ma_p3_2=hi_ma_p3_1-(fib_SR_shadow_3*Point);
   hi_ma_p3_3=hi_ma_p3_2-(fib_SR_shadow_4*Point);
   hi_ma_p3_4=hi_ma_p3_3-(fib_SR_shadow_5*Point);
   hi_ma_p3_5=hi_ma_p3_4-(fib_SR_shadow_6*Point);
   hi_ma_p3_6=hi_ma_p3_5-(fib_SR_shadow_7*Point);
   //p3 1st level (hi_1_p3, lo_1_p3)
   if(lo_ma_p3_1-hi_ma_p3_1>Ask-Bid)
     {
      ObjectCreate("lo_1_p3",OBJ_TREND,0,t1_p3, lo_ma_p3_1, t2_p3, lo_ma_p3_1);
      ObjectSet("lo_1_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_1_p3",OBJPROP_WIDTH,2);
      ObjectSet("lo_1_p3",OBJPROP_RAY,false);
      ObjectSet("lo_1_p3",OBJPROP_COLOR,fib_SR_shadow_2_c);
      ObjectSetText("lo_1_p3",DoubleToStr(lo_ma_p3_1,Digits),7,"Arial",fib_SR_shadow_2_c);
      //----
      ObjectCreate("hi_1_p3",OBJ_TREND,0,t1_p3, hi_ma_p3_1, t2_p3, hi_ma_p3_1);
      ObjectSet("hi_1_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_1_p3",OBJPROP_WIDTH,2);
      ObjectSet("hi_1_p3",OBJPROP_RAY,false);
      ObjectSet("hi_1_p3",OBJPROP_COLOR,fib_SR_shadow_2_c);
      ObjectSetText("hi_1_p3",DoubleToStr(hi_ma_p3_1,Digits),7,"Arial",fib_SR_shadow_2_c);
     }
   // 2st level (hi_2_p3, lo_2_p3)
   if(lo_ma_p3_2-hi_ma_p3_2>Ask-Bid)
     {
      ObjectCreate("lo_2_p3",OBJ_TREND,0,t1_p3, lo_ma_p3_2, t2_p3, lo_ma_p3_2);
      ObjectSet("lo_2_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_2_p3",OBJPROP_WIDTH,2);
      ObjectSet("lo_2_p3",OBJPROP_RAY,false);
      ObjectSet("lo_2_p3",OBJPROP_COLOR,fib_SR_shadow_3_c);
      ObjectSetText("lo_2_p3",DoubleToStr(lo_ma_p3_2,Digits),7,"Arial",fib_SR_shadow_3_c);
      //----
      ObjectCreate("hi_2_p3",OBJ_TREND,0,t1_p3, hi_ma_p3_2, t2_p3, hi_ma_p3_2);
      ObjectSet("hi_2_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_2_p3",OBJPROP_WIDTH,2);
      ObjectSet("hi_2_p3",OBJPROP_RAY,false);
      ObjectSet("hi_2_p3",OBJPROP_COLOR,fib_SR_shadow_3_c);
      ObjectSetText("hi_2_p3",DoubleToStr(hi_ma_p3_2,Digits),7,"Arial",fib_SR_shadow_3_c);
     }
   // 3rd level (hi_3_p3, lo_3_p3)
   if(lo_ma_p3_3-hi_ma_p3_3>Ask-Bid)
     {
      ObjectCreate("lo_3_p3",OBJ_TREND,0,t1_p3, lo_ma_p3_3, t2_p3, lo_ma_p3_3);
      ObjectSet("lo_3_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_3_p3",OBJPROP_WIDTH,2);
      ObjectSet("lo_3_p3",OBJPROP_RAY,false);
      ObjectSet("lo_3_p3",OBJPROP_COLOR,fib_SR_shadow_4_c);
      ObjectSetText("lo_3_p3",DoubleToStr(lo_ma_p3_3,Digits),7,"Arial",fib_SR_shadow_4_c);
      //----
      ObjectCreate("hi_3_p3",OBJ_TREND,0,t1_p3, hi_ma_p3_3, t2_p3, hi_ma_p3_3);
      ObjectSet("hi_3_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_3_p3",OBJPROP_WIDTH,2);
      ObjectSet("hi_3_p3",OBJPROP_RAY,false);
      ObjectSet("hi_3_p3",OBJPROP_COLOR,fib_SR_shadow_4_c);
      ObjectSetText("hi_3_p3",DoubleToStr(hi_ma_p3_3,Digits),7,"Arial",fib_SR_shadow_4_c);
     }
   // 4th level (hi_4_p3, lo_4_p3)
   if(lo_ma_p3_4-hi_ma_p3_4>Ask-Bid)
     {
      ObjectCreate("lo_4_p3",OBJ_TREND,0,t1_p3, lo_ma_p3_4, t2_p3, lo_ma_p3_4);
      ObjectSet("lo_4_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_4_p3",OBJPROP_WIDTH,2);
      ObjectSet("lo_4_p3",OBJPROP_RAY,false);
      ObjectSet("lo_4_p3",OBJPROP_COLOR,fib_SR_shadow_5_c);
      ObjectSetText("lo_4_p3",DoubleToStr(lo_ma_p3_4,Digits),7,"Arial",fib_SR_shadow_5_c);
      //----
      ObjectCreate("hi_4_p3",OBJ_TREND,0,t1_p3, hi_ma_p3_4, t2_p3, hi_ma_p3_4);
      ObjectSet("hi_4_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_4_p3",OBJPROP_WIDTH,2);
      ObjectSet("hi_4_p3",OBJPROP_RAY,false);
      ObjectSet("hi_4_p3",OBJPROP_COLOR,fib_SR_shadow_5_c);
      ObjectSetText("hi_4_p3",DoubleToStr(hi_ma_p3_4,Digits),7,"Arial",fib_SR_shadow_5_c);
     }
   // 5th level (hi_5_p3, lo_5_p3)
   if(lo_ma_p3_5-hi_ma_p3_5>Ask-Bid)
     {
      ObjectCreate("lo_5_p3",OBJ_TREND,0,t1_p3, lo_ma_p3_5, t2_p3, lo_ma_p3_5);
      ObjectSet("lo_5_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_5_p3",OBJPROP_WIDTH,2);
      ObjectSet("lo_5_p3",OBJPROP_RAY,false);
      ObjectSet("lo_5_p3",OBJPROP_COLOR,fib_SR_shadow_6_c);
      ObjectSetText("lo_5_p3",DoubleToStr(lo_ma_p3_5,Digits),7,"Arial",fib_SR_shadow_6_c);
      //----
      ObjectCreate("hi_5_p3",OBJ_TREND,0,t1_p3, hi_ma_p3_5, t2_p3, hi_ma_p3_5);
      ObjectSet("hi_5_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_5_p3",OBJPROP_WIDTH,2);
      ObjectSet("hi_5_p3",OBJPROP_RAY,false);
      ObjectSet("hi_5_p3",OBJPROP_COLOR,fib_SR_shadow_6_c);
      ObjectSetText("hi_5_p3",DoubleToStr(hi_ma_p3_5,Digits),7,"Arial",fib_SR_shadow_6_c);
     }
   // 6th level (hi_6_p3, lo_6_p3)
   if(lo_ma_p3_6-hi_ma_p3_6>Ask-Bid)
     {
      ObjectCreate("lo_6_p3",OBJ_TREND,0,t1_p3, lo_ma_p3_6, t2_p3, lo_ma_p3_6);
      ObjectSet("lo_6_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_6_p3",OBJPROP_WIDTH,2);
      ObjectSet("lo_6_p3",OBJPROP_RAY,false);
      ObjectSet("lo_6_p3",OBJPROP_COLOR,fib_SR_shadow_7_c);
      ObjectSetText("lo_6_p3",DoubleToStr(lo_ma_p3_6,Digits),7,"Arial",fib_SR_shadow_7_c);
      //----
      ObjectCreate("hi_6_p3",OBJ_TREND,0,t1_p3, hi_ma_p3_6, t2_p3, hi_ma_p3_6);
      ObjectSet("hi_6_p3",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_6_p3",OBJPROP_WIDTH,2);
      ObjectSet("hi_6_p3",OBJPROP_RAY,false);
      ObjectSet("hi_6_p3",OBJPROP_COLOR,fib_SR_shadow_7_c);
      ObjectSetText("hi_6_p3",DoubleToStr(hi_ma_p3_6,Digits),7,"Arial",fib_SR_shadow_7_c);
     }
   //_______________Moving Average Support & Resistance Levels______________________________
   string space="             ";
   ObjectCreate("ma1_p3",OBJ_TEXT,0,t1_p3,ma1_p3);//13 ma
   ObjectSetText("ma1_p3",space+DoubleToStr(ma1_p3,Digits),8,"Arial",White);
   ObjectCreate("ma2_p3",OBJ_TEXT,0,t1_p3,ma2_p3);//21 ma
   ObjectSetText("ma2_p3",space+DoubleToStr(ma2_p3,Digits),8,"Arial",White);
   ObjectCreate("ma3_p3",OBJ_TEXT,0,t1_p3,ma3_p3);//34 ma
     if(Bid>ma3_p3) {ObjectSetText("ma3_p3",space+DoubleToStr(ma3_p3,Digits),8,"Arial",LightGreen);
     }
     if(Ask<ma3_p3) {ObjectSetText("ma3_p3",space+DoubleToStr(ma3_p3,Digits),8,"Arial",Pink);
     }
   if(Bid<=ma3_p3 && Ask>=ma3_p3)
     {
      ObjectSetText("ma3_p3",space+DoubleToStr(ma3_p3,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma4_p3",OBJ_TEXT,0,t1_p3,ma4_p3);//55 ma
     if(Bid>ma4_p3) {ObjectSetText("ma4_p3",space+DoubleToStr(ma4_p3,Digits),8,"Arial",LightGreen);
     }
     if(Ask<ma4_p3) {ObjectSetText("ma4_p3",space+DoubleToStr(ma4_p3,Digits),8,"Arial",Pink);
     }
   if(Bid<=ma4_p3 && Ask>=ma4_p3)
     {
      ObjectSetText("ma4_p3",space+DoubleToStr(ma4_p3,Digits),8,"Arial",Yellow);
     }
//----
   ObjectCreate("ma5_p3",OBJ_TEXT,0,t1_p3,ma5_p3);//89 ma
     if(Bid>ma5_p3) {ObjectSetText("ma5_p3",space+DoubleToStr(ma5_p3,Digits),8,"Arial",Green);
     }
     if(Ask<ma5_p3) {ObjectSetText("ma5_p3",space+DoubleToStr(ma5_p3,Digits),8,"Arial",Red);
     }
   if(Bid<=ma5_p3 && Ask>=ma5_p3)
     {
      ObjectSetText("ma5_p3",space+DoubleToStr(ma5_p3,Digits),8,"Arial",Yellow);
     }
//----
   ObjectCreate("ma6_p3",OBJ_TEXT,0,t1_p3,NormalizeDouble(ma6_p3,Digits));//144 ma
     if(Bid>ma6_p3) {ObjectSetText("ma6_p3",space+DoubleToStr(ma6_p3,Digits),8,"Arial",Green);
     }
     if(Ask<ma6_p3) {ObjectSetText("ma6_p3",space+DoubleToStr(ma6_p3,Digits),8,"Arial",Red);
     }
   if(Bid<=ma6_p3 && Ask>=ma6_p3)
     {
      ObjectSetText("ma6_p3",space+DoubleToStr(ma6_p3,Digits),8,"Arial",Yellow);
     }
//----     
   ObjectCreate("ma7_p3",OBJ_TEXT,0,t1_p3,NormalizeDouble(ma7_p3,Digits));//233 ma
     if(Bid>ma7_p3) {ObjectSetText("ma7_p3",space+DoubleToStr(ma7_p3,Digits),8,"Arial",Green);
     }
     if(Ask<ma7_p3) {ObjectSetText("ma7_p3",space+DoubleToStr(ma7_p3,Digits),8,"Arial",Red);
     }
   if(Bid<=ma7_p3 && Ask>=ma7_p3)
     {
      ObjectSetText("ma7_p3",space+DoubleToStr(ma7_p3,Digits),8,"Arial",Yellow);
     }
  }
  //end p3_Fib_Plot()
  void p4_Fib_Plot()
  {
   //p4 dynamic fibo levels
   double lo_ma_p4,hi_ma_p4;
   lo_ma_p4=ma1_p4;
   if(ma2_p4<lo_ma_p4)  {lo_ma_p4=ma2_p4;}
   if(ma3_p4<lo_ma_p4)  {lo_ma_p4=ma3_p4;}
   if(ma4_p4<lo_ma_p4)  {lo_ma_p4=ma4_p4;}
   if(ma5_p4<lo_ma_p4)  {lo_ma_p4=ma5_p4;}
   if(ma6_p4<lo_ma_p4)  {lo_ma_p4=ma6_p4;}
   if(ma7_p4<lo_ma_p4)  {lo_ma_p4=ma7_p4;}
   lo_ma_p4=NormalizeDouble(lo_ma_p4+(fib_SR_shadow_1*Point),Digits);
//----
   hi_ma_p4=ma7_p4;
   if(ma6_p4>hi_ma_p4)  {hi_ma_p4=ma6_p4;}
   if(ma5_p4>hi_ma_p4)  {hi_ma_p4=ma5_p4;}
   if(ma4_p4>hi_ma_p4)  {hi_ma_p4=ma4_p4;}
   if(ma3_p4>hi_ma_p4)  {hi_ma_p4=ma3_p4;}
   if(ma2_p4>hi_ma_p4)  {hi_ma_p4=ma2_p4;}
   if(ma1_p4>hi_ma_p4)  {hi_ma_p4=ma1_p4;}
   hi_ma_p4=NormalizeDouble(hi_ma_p4-(fib_SR_shadow_1*Point),Digits);
   //p4 center dynamic fib placement      
   if(lo_ma_p4-hi_ma_p4>Ask-Bid)
     {
      ObjectCreate("lcf_p4",OBJ_TREND,0,t1_p4, lo_ma_p4, t2_p4, lo_ma_p4);
      ObjectSet("lcf_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lcf_p4",OBJPROP_WIDTH,2);
      ObjectSet("lcf_p4",OBJPROP_RAY,false);
      ObjectSet("lcf_p4",OBJPROP_COLOR,fib_SR_shadow_1_c);
      ObjectSetText("lcf_p4",DoubleToStr(lo_ma_p4,Digits),7,"Arial",fib_SR_shadow_1_c);
      //----
      ObjectCreate("hcf_p4",OBJ_TREND,0,t1_p4, hi_ma_p4, t2_p4, hi_ma_p4);
      ObjectSet("hcf_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hcf_p4",OBJPROP_WIDTH,2);
      ObjectSet("hcf_p4",OBJPROP_RAY,false);
      ObjectSet("hcf_p4",OBJPROP_COLOR,fib_SR_shadow_1_c);
      ObjectSetText("hcf_p4",DoubleToStr(hi_ma_p4,Digits),7,"Arial",fib_SR_shadow_1_c);
     }
//----     
   double lo_ma_p4_1, lo_ma_p4_2, lo_ma_p4_3, lo_ma_p4_4, lo_ma_p4_5, lo_ma_p4_6;
   lo_ma_p4_1=lo_ma_p4+(fib_SR_shadow_2*Point);
   lo_ma_p4_2=lo_ma_p4_1+(fib_SR_shadow_3*Point);
   lo_ma_p4_3=lo_ma_p4_2+(fib_SR_shadow_4*Point);
   lo_ma_p4_4=lo_ma_p4_3+(fib_SR_shadow_5*Point);
   lo_ma_p4_5=lo_ma_p4_4+(fib_SR_shadow_6*Point);
   lo_ma_p4_6=lo_ma_p4_5+(fib_SR_shadow_7*Point);
//-----
   double hi_ma_p4_1, hi_ma_p4_2, hi_ma_p4_3, hi_ma_p4_4, hi_ma_p4_5, hi_ma_p4_6;
   hi_ma_p4_1=hi_ma_p4-(fib_SR_shadow_2*Point);
   hi_ma_p4_2=hi_ma_p4_1-(fib_SR_shadow_3*Point);
   hi_ma_p4_3=hi_ma_p4_2-(fib_SR_shadow_4*Point);
   hi_ma_p4_4=hi_ma_p4_3-(fib_SR_shadow_5*Point);
   hi_ma_p4_5=hi_ma_p4_4-(fib_SR_shadow_6*Point);
   hi_ma_p4_6=hi_ma_p4_5-(fib_SR_shadow_7*Point);
   //p4 1st level (hi_1_p4, lo_1_p4)
   if(lo_ma_p4_1-hi_ma_p4_1>Ask-Bid)
     {
      ObjectCreate("lo_1_p4",OBJ_TREND,0,t1_p4, lo_ma_p4_1, t2_p4, lo_ma_p4_1);
      ObjectSet("lo_1_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_1_p4",OBJPROP_WIDTH,2);
      ObjectSet("lo_1_p4",OBJPROP_RAY,false);
      ObjectSet("lo_1_p4",OBJPROP_COLOR,fib_SR_shadow_2_c);
      ObjectSetText("lo_1_p4",DoubleToStr(lo_ma_p4_1,Digits),7,"Arial",fib_SR_shadow_2_c);
      //----
      ObjectCreate("hi_1_p4",OBJ_TREND,0,t1_p4, hi_ma_p4_1, t2_p4, hi_ma_p4_1);
      ObjectSet("hi_1_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_1_p4",OBJPROP_WIDTH,2);
      ObjectSet("hi_1_p4",OBJPROP_RAY,false);
      ObjectSet("hi_1_p4",OBJPROP_COLOR,fib_SR_shadow_2_c);
      ObjectSetText("hi_1_p4",DoubleToStr(hi_ma_p4_1,Digits),7,"Arial",fib_SR_shadow_2_c);
     }
   // 2st level (hi_2_p4, lo_2_p4)
   if(lo_ma_p4_2-hi_ma_p4_2>Ask-Bid)
     {
      ObjectCreate("lo_2_p4",OBJ_TREND,0,t1_p4, lo_ma_p4_2, t2_p4, lo_ma_p4_2);
      ObjectSet("lo_2_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_2_p4",OBJPROP_WIDTH,2);
      ObjectSet("lo_2_p4",OBJPROP_RAY,false);
      ObjectSet("lo_2_p4",OBJPROP_COLOR,fib_SR_shadow_3_c);
      ObjectSetText("lo_2_p4",DoubleToStr(lo_ma_p4_2,Digits),7,"Arial",fib_SR_shadow_3_c);
      //----
      ObjectCreate("hi_2_p4",OBJ_TREND,0,t1_p4, hi_ma_p4_2, t2_p4, hi_ma_p4_2);
      ObjectSet("hi_2_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_2_p4",OBJPROP_WIDTH,2);
      ObjectSet("hi_2_p4",OBJPROP_RAY,false);
      ObjectSet("hi_2_p4",OBJPROP_COLOR,fib_SR_shadow_3_c);
      ObjectSetText("hi_2_p4",DoubleToStr(hi_ma_p4_2,Digits),7,"Arial",fib_SR_shadow_3_c);
     }
   // 3rd level (hi_3_p4, lo_3_p4)
   if(lo_ma_p4_3-hi_ma_p4_3>Ask-Bid)
     {
      ObjectCreate("lo_3_p4",OBJ_TREND,0,t1_p4, lo_ma_p4_3, t2_p4, lo_ma_p4_3);
      ObjectSet("lo_3_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_3_p4",OBJPROP_WIDTH,2);
      ObjectSet("lo_3_p4",OBJPROP_RAY,false);
      ObjectSet("lo_3_p4",OBJPROP_COLOR,fib_SR_shadow_4_c);
      ObjectSetText("lo_3_p4",DoubleToStr(lo_ma_p4_3,Digits),7,"Arial",fib_SR_shadow_4_c);
      //-----
      ObjectCreate("hi_3_p4",OBJ_TREND,0,t1_p4, hi_ma_p4_3, t2_p4, hi_ma_p4_3);
      ObjectSet("hi_3_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_3_p4",OBJPROP_WIDTH,2);
      ObjectSet("hi_3_p4",OBJPROP_RAY,false);
      ObjectSet("hi_3_p4",OBJPROP_COLOR,fib_SR_shadow_4_c);
      ObjectSetText("hi_3_p4",DoubleToStr(hi_ma_p4_3,Digits),7,"Arial",fib_SR_shadow_4_c);
     }
   // 4th level (hi_4_p4, lo_4_p4)
   if(lo_ma_p4_4-hi_ma_p4_4>Ask-Bid)
     {
      ObjectCreate("lo_4_p4",OBJ_TREND,0,t1_p4, lo_ma_p4_4, t2_p4, lo_ma_p4_4);
      ObjectSet("lo_4_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_4_p4",OBJPROP_WIDTH,2);
      ObjectSet("lo_4_p4",OBJPROP_RAY,false);
      ObjectSet("lo_4_p4",OBJPROP_COLOR,fib_SR_shadow_5_c);
      ObjectSetText("lo_4_p4",DoubleToStr(lo_ma_p4_4,Digits),7,"Arial",fib_SR_shadow_5_c);
      //----
      ObjectCreate("hi_4_p4",OBJ_TREND,0,t1_p4, hi_ma_p4_4, t2_p4, hi_ma_p4_4);
      ObjectSet("hi_4_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_4_p4",OBJPROP_WIDTH,2);
      ObjectSet("hi_4_p4",OBJPROP_RAY,false);
      ObjectSet("hi_4_p4",OBJPROP_COLOR,fib_SR_shadow_5_c);
      ObjectSetText("hi_4_p4",DoubleToStr(hi_ma_p4_4,Digits),7,"Arial",fib_SR_shadow_5_c);
     }
   // 5th level (hi_5_p4, lo_5_p4)
   if(lo_ma_p4_5-hi_ma_p4_5>Ask-Bid)
     {
      ObjectCreate("lo_5_p4",OBJ_TREND,0,t1_p4, lo_ma_p4_5, t2_p4, lo_ma_p4_5);
      ObjectSet("lo_5_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_5_p4",OBJPROP_WIDTH,2);
      ObjectSet("lo_5_p4",OBJPROP_RAY,false);
      ObjectSet("lo_5_p4",OBJPROP_COLOR,fib_SR_shadow_6_c);
      ObjectSetText("lo_5_p4",DoubleToStr(lo_ma_p4_5,Digits),7,"Arial",fib_SR_shadow_6_c);
      //----
      ObjectCreate("hi_5_p4",OBJ_TREND,0,t1_p4, hi_ma_p4_5, t2_p4, hi_ma_p4_5);
      ObjectSet("hi_5_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_5_p4",OBJPROP_WIDTH,2);
      ObjectSet("hi_5_p4",OBJPROP_RAY,false);
      ObjectSet("hi_5_p4",OBJPROP_COLOR,fib_SR_shadow_6_c);
      ObjectSetText("hi_5_p4",DoubleToStr(hi_ma_p4_5,Digits),7,"Arial",fib_SR_shadow_6_c);
     }
   // 6th level (hi_6_p4, lo_6_p4)
   if(lo_ma_p4_6-hi_ma_p4_6>Ask-Bid)
     {
      ObjectCreate("lo_6_p4",OBJ_TREND,0,t1_p4, lo_ma_p4_6, t2_p4, lo_ma_p4_6);
      ObjectSet("lo_6_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("lo_6_p4",OBJPROP_WIDTH,2);
      ObjectSet("lo_6_p4",OBJPROP_RAY,false);
      ObjectSet("lo_6_p4",OBJPROP_COLOR,fib_SR_shadow_7_c);
      ObjectSetText("lo_6_p4",DoubleToStr(lo_ma_p4_6,Digits),7,"Arial",fib_SR_shadow_7_c);
      //----
      ObjectCreate("hi_6_p4",OBJ_TREND,0,t1_p4, hi_ma_p4_6, t2_p4, hi_ma_p4_6);
      ObjectSet("hi_6_p4",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("hi_6_p4",OBJPROP_WIDTH,2);
      ObjectSet("hi_6_p4",OBJPROP_RAY,false);
      ObjectSet("hi_6_p4",OBJPROP_COLOR,fib_SR_shadow_7_c);
      ObjectSetText("hi_6_p4",DoubleToStr(hi_ma_p4_6,Digits),7,"Arial",fib_SR_shadow_7_c);
     }
   //_______________Moving Average Support & Resistance Levels______________________________
   string space="             ";
   ObjectCreate("ma1_p4",OBJ_TEXT,0,t1_p4,ma1_p4);//13 ma
   ObjectSetText("ma1_p4",space+DoubleToStr(ma1_p4,Digits),8,"Arial",White);
   ObjectCreate("ma2_p4",OBJ_TEXT,0,t1_p4,ma2_p4);//21 ma
   ObjectSetText("ma2_p4",space+DoubleToStr(ma2_p4,Digits),8,"Arial",White);
   ObjectCreate("ma3_p4",OBJ_TEXT,0,t1_p4,ma3_p4);//34 ma
//----
     if(Bid>ma3_p4) {ObjectSetText("ma3_p4",space+DoubleToStr(ma3_p4,Digits),8,"Arial",LightGreen);
     }
     if(Ask<ma3_p4) {ObjectSetText("ma3_p4",space+DoubleToStr(ma3_p4,Digits),8,"Arial",Pink);
     }
   if(Bid<=ma3_p4 && Ask>=ma3_p4)
     {
      ObjectSetText("ma3_p4",space+DoubleToStr(ma3_p4,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma4_p4",OBJ_TEXT,0,t1_p4,ma4_p4);//55 ma
     if(Bid>ma4_p4) {ObjectSetText("ma4_p4",space+DoubleToStr(ma4_p4,Digits),8,"Arial",LightGreen);
     }
     if(Ask<ma4_p4) {ObjectSetText("ma4_p4",space+DoubleToStr(ma4_p4,Digits),8,"Arial",Pink);
     }
   if(Bid<=ma4_p4 && Ask>=ma4_p4)
     {
      ObjectSetText("ma4_p4",space+DoubleToStr(ma4_p4,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma5_p4",OBJ_TEXT,0,t1_p4,ma5_p4);//89 ma
     if(Bid>ma5_p4) {ObjectSetText("ma5_p4",space+DoubleToStr(ma5_p4,Digits),8,"Arial",Green);
     }
     if(Ask<ma5_p4) {ObjectSetText("ma5_p4",space+DoubleToStr(ma5_p4,Digits),8,"Arial",Red);
     }
   if(Bid<=ma5_p4 && Ask>=ma5_p4)
     {
      ObjectSetText("ma5_p4",space+DoubleToStr(ma5_p4,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma6_p4",OBJ_TEXT,0,t1_p4,NormalizeDouble(ma6_p4,Digits));//144 ma
     if(Bid>ma6_p4) {ObjectSetText("ma6_p4",space+DoubleToStr(ma6_p4,Digits),8,"Arial",Green);
     }
     if(Ask<ma6_p4) {ObjectSetText("ma6_p4",space+DoubleToStr(ma6_p4,Digits),8,"Arial",Red);
     }
   if(Bid<=ma6_p4 && Ask>=ma6_p4)
     {
      ObjectSetText("ma6_p4",space+DoubleToStr(ma6_p4,Digits),8,"Arial",Yellow);
     }
   ObjectCreate("ma7_p4",OBJ_TEXT,0,t1_p4,NormalizeDouble(ma7_p4,Digits));//233 ma
     if(Bid>ma7_p4) {ObjectSetText("ma7_p4",space+DoubleToStr(ma7_p4,Digits),8,"Arial",Green);
     }
     if(Ask<ma7_p4) {ObjectSetText("ma7_p4",space+DoubleToStr(ma7_p4,Digits),8,"Arial",Red);
     }
   if(Bid<=ma7_p4 && Ask>=ma7_p4)
     {
      ObjectSetText("ma7_p4",space+DoubleToStr(ma7_p4,Digits),8,"Arial",Yellow);
     }
  }
  //end p4_Fib.Plot()
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void column()
  {
   //..................Time Frame Columns.................................................     
   string down, up;down=(string)Bid; up=(string)Ask;
//----
   ObjectCreate((string)p1_ma+"m "+down,OBJ_RECTANGLE,0,t1_p1,Bid,t2_p1,0);
   ObjectSet((string)p1_ma+"m "+down,OBJPROP_COLOR,Red);
   ObjectCreate((string)p1_ma+"m "+up,OBJ_RECTANGLE,0,t1_p1,Ask,t2_p1,Ask*1.5);
   ObjectSet((string)p1_ma+"m "+up,OBJPROP_COLOR,Green);
//----
   ObjectCreate((string)p2_ma+"m "+down,OBJ_RECTANGLE,0,t1_p2,0,t2_p2,Bid);
   ObjectSet((string)p2_ma+"m "+down,OBJPROP_COLOR,Red);
   ObjectCreate((string)p2_ma+"m "+up,OBJ_RECTANGLE,0,t1_p2,Ask,t2_p2,Ask*1.5);
   ObjectSet((string)p2_ma+"m "+up,OBJPROP_COLOR,Green);
//----
   ObjectCreate((string)p3_ma+"m "+down,OBJ_RECTANGLE,0,t1_p3,Bid,t2_p3,0);
   ObjectSet((string)p3_ma+"m "+down,OBJPROP_COLOR,Red);
   ObjectCreate((string)p3_ma+"m "+up,OBJ_RECTANGLE,0,t1_p3,Ask,t2_p3,Ask*1.5);
   ObjectSet((string)p3_ma+"m "+up,OBJPROP_COLOR,Green);
//----
   ObjectCreate((string)p4_ma+"m "+down,OBJ_RECTANGLE,0,t1_p4,Bid,t2_p4,0);
   ObjectSet((string)p4_ma+"m "+down,OBJPROP_COLOR,Red);
   ObjectCreate((string)p4_ma+"m "+up,OBJ_RECTANGLE,0,t1_p4,Ask,t2_p4,Ask*1.5);
  ObjectSet((string)p4_ma+"m "+up,OBJPROP_COLOR,Green);}//end column();
//---- done
//+------------------------------------------------------------------+