//+------------------------------------------------------------------+
//|                                                TREND_alexcud.mq4 |
//|                             Copyright © 2007, Aleksander Kudimov |
//|                                               alexcud@rambler.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Aleksander Kudimov"
#property link      "alexcud@rambler.ru"

#property indicator_separate_window

#property indicator_minimum 0
#property indicator_maximum 1

#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

//---- buffers
double UPBuffer[];
double DOWNBuffer[];

extern int maTrendPeriod_1 = 5;
extern int maTrendPeriod_2 = 8;
extern int maTrendPeriod_3 = 13;
extern int maTrendPeriod_4 = 21;
extern int maTrendPeriod_5 = 34;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
double MaH11,MaH41,MaD11,MaH1pr1,MaH4pr1,MaD1pr1;
double MaH12,MaH42,MaD12,MaH1pr2,MaH4pr2,MaD1pr2;
double MaH13,MaH43,MaD13,MaH1pr3,MaH4pr3,MaD1pr3;
double MaH14,MaH44,MaD14,MaH1pr4,MaH4pr4,MaD1pr4;
double MaH15,MaH45,MaD15,MaH1pr5,MaH4pr5,MaD1pr5;
string H11,H41,D11;
string H12,H42,D12;
string H13,H43,D13;
string H14,H44,D14;
string H15,H45,D15;
color co11,co41,co61;
color co12,co42,co62;
color co13,co43,co63;
color co14,co44,co64;
color co15,co45,co65;

double u1x5,u1x8,u1x13,u1x21,u1x34;
double u2x5,u2x8,u2x13,u2x21,u2x34;
double u3x5,u3x8,u3x13,u3x21,u3x34;
double u1ac,u2ac,u3ac;

double d1x5,d1x8,d1x13,d1x21,d1x34;
double d2x5,d2x8,d2x13,d2x21,d2x34;
double d3x5,d3x8,d3x13,d3x21,d3x34;
double d1ac,d2ac,d3ac;

string short_name;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {

//---- name for indicator window

   short_name="TREND_alexcud";
   IndicatorShortName(short_name);

   SetIndexBuffer(0,UPBuffer);
   SetIndexBuffer(1,DOWNBuffer);


//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   ObjectCreate("MA",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("MA","Moving Average",9,"Verdana",Lime);
   ObjectSet("MA",OBJPROP_XDISTANCE,75);
   ObjectSet("MA",OBJPROP_YDISTANCE,0);

   ObjectCreate("label_object1",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("label_object1",OBJPROP_XDISTANCE,11);
   ObjectSet("label_object1",OBJPROP_YDISTANCE,15);

   ObjectCreate("label_object2",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("label_object2",OBJPROP_XDISTANCE,11);
   ObjectSet("label_object2",OBJPROP_YDISTANCE,35);

   ObjectCreate("label_object3",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("label_object3",OBJPROP_XDISTANCE,11);
   ObjectSet("label_object3",OBJPROP_YDISTANCE,55);
// ----------------------------------------------------------------------------
   ObjectCreate("H11",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H11",OBJPROP_XDISTANCE,40);
   ObjectSet("H11",OBJPROP_YDISTANCE,15);

   ObjectCreate("H12",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H12",OBJPROP_XDISTANCE,70);
   ObjectSet("H12",OBJPROP_YDISTANCE,15);

   ObjectCreate("H13",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H13",OBJPROP_XDISTANCE,100);
   ObjectSet("H13",OBJPROP_YDISTANCE,15);

   ObjectCreate("H14",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H14",OBJPROP_XDISTANCE,130);
   ObjectSet("H14",OBJPROP_YDISTANCE,15);

   ObjectCreate("H15",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H15",OBJPROP_XDISTANCE,160);
   ObjectSet("H15",OBJPROP_YDISTANCE,15);
//--------------------------------------------------------------------------- 
   ObjectCreate("H41",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H41",OBJPROP_XDISTANCE,40);
   ObjectSet("H41",OBJPROP_YDISTANCE,35);

   ObjectCreate("H42",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H42",OBJPROP_XDISTANCE,70);
   ObjectSet("H42",OBJPROP_YDISTANCE,35);

   ObjectCreate("H43",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H43",OBJPROP_XDISTANCE,100);
   ObjectSet("H43",OBJPROP_YDISTANCE,35);

   ObjectCreate("H44",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H44",OBJPROP_XDISTANCE,130);
   ObjectSet("H44",OBJPROP_YDISTANCE,35);

   ObjectCreate("H45",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("H45",OBJPROP_XDISTANCE,160);
   ObjectSet("H45",OBJPROP_YDISTANCE,35);
//--------------------------------------------------------------------------- 
   ObjectCreate("D11",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("D11",OBJPROP_XDISTANCE,40);
   ObjectSet("D11",OBJPROP_YDISTANCE,55);

   ObjectCreate("D12",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("D12",OBJPROP_XDISTANCE,70);
   ObjectSet("D12",OBJPROP_YDISTANCE,55);

   ObjectCreate("D13",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("D13",OBJPROP_XDISTANCE,100);
   ObjectSet("D13",OBJPROP_YDISTANCE,55);

   ObjectCreate("D14",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("D14",OBJPROP_XDISTANCE,130);
   ObjectSet("D14",OBJPROP_YDISTANCE,55);

   ObjectCreate("D15",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSet("D15",OBJPROP_XDISTANCE,160);
   ObjectSet("D15",OBJPROP_YDISTANCE,55);

   MaH11=iMA(NULL,PERIOD_H1,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,0);    MaH1pr1=iMA(NULL,PERIOD_H1,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,1);
   MaH12=iMA(NULL,PERIOD_H1,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,0);    MaH1pr2=iMA(NULL,PERIOD_H1,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,1);
   MaH13=iMA(NULL,PERIOD_H1,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr3=iMA(NULL,PERIOD_H1,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,1);
   MaH14=iMA(NULL,PERIOD_H1,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr4=iMA(NULL,PERIOD_H1,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,1);
   MaH15=iMA(NULL,PERIOD_H1,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr5=iMA(NULL,PERIOD_H1,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,1);

   MaH41=iMA(NULL,PERIOD_H4,maTrendPeriod_1 ,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr1=iMA(NULL,PERIOD_H4,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,1);
   MaH42=iMA(NULL,PERIOD_H4,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,0);    MaH4pr2=iMA(NULL,PERIOD_H4,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,1);
   MaH43=iMA(NULL,PERIOD_H4,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr3=iMA(NULL,PERIOD_H4,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,1);
   MaH44=iMA(NULL,PERIOD_H4,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr4=iMA(NULL,PERIOD_H4,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,1);
   MaH45=iMA(NULL,PERIOD_H4,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr5=iMA(NULL,PERIOD_H4,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,1);

   MaD11=iMA(NULL,PERIOD_D1,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,0);    MaD1pr1=iMA(NULL,PERIOD_D1,maTrendPeriod_1,0,MODE_SMA,PRICE_CLOSE,1);
   MaD12=iMA(NULL,PERIOD_D1,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,0);    MaD1pr2=iMA(NULL,PERIOD_D1,maTrendPeriod_2,0,MODE_SMA,PRICE_CLOSE,1);
   MaD13=iMA(NULL,PERIOD_D1,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr3=iMA(NULL,PERIOD_D1,maTrendPeriod_3,0,MODE_SMA,PRICE_CLOSE,1);
   MaD14=iMA(NULL,PERIOD_D1,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr4=iMA(NULL,PERIOD_D1,maTrendPeriod_4,0,MODE_SMA,PRICE_CLOSE,1);
   MaD15=iMA(NULL,PERIOD_D1,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr5=iMA(NULL,PERIOD_D1,maTrendPeriod_5,0,MODE_SMA,PRICE_CLOSE,1);

//  MaH4=iMA(NULL,PERIOD_M30,34,0,MODE_SMA,PRICE_CLOSE,0);
   if(MaH11 < MaH1pr1){H11 = " V ";   co11 = Red;   u1x5 = 0; d1x5 = 1;}
   if(MaH11 > MaH1pr1){H11 = " /\\ "; co11 = Blue;  u1x5 = 1; d1x5 = 0;}
   if(MaH11== MaH1pr1){H11 = " 0 "; co11 = Green;  u1x5 = 0; d1x5 = 0;}
   if(MaH41 < MaH4pr1){H41 = " V "; co41 = Red;     u2x5 = 0; d2x5 = 1;}
   if(MaH41 > MaH4pr1){H41 = " /\\ "; co41 = Blue;  u2x5 = 1; d2x5 = 0;}
   if(MaH41== MaH4pr1){H41 = " 0 "; co41 = Green;  u2x5 = 0; d2x5 = 0;}
   if(MaD11 < MaD1pr1){D11 = " V "; co61 = Red;     u3x5 = 0; d3x5 = 1;}
   if(MaD11 > MaD1pr1){D11 = " /\\ "; co61 = Blue;  u3x5 = 1; d3x5 = 0;}
   if(MaD11== MaD1pr1){D11 = " 0 "; co61 = Green;  u3x5 = 0; d3x5 = 0;}

   if(MaH12 < MaH1pr2){H12 = " V "; co12 = Red;     u1x8 = 0; d1x8 = 1;}
   if(MaH12 > MaH1pr2){H12 = " /\\ "; co12 = Blue;  u1x8 = 1; d1x8 = 0;}
   if(MaH12== MaH1pr2){H12 = " 0 "; co12 = Green;  u1x8 = 0; d1x8 = 0;}
   if(MaH42 < MaH4pr2){H42 = " V "; co42 = Red;     u2x8 = 0; d2x8 = 1;}
   if(MaH42 > MaH4pr2){H42 = " /\\ "; co42 = Blue;   u2x8 = 1; d2x8 = 0;}
   if(MaH42== MaH4pr2){H42 = " 0 "; co42 = Green;   u2x8 = 0; d2x8 = 0;}
   if(MaD12 < MaD1pr2){D12 = " V "; co62 = Red;      u3x8 = 0; d3x8 = 1;}
   if(MaD12 > MaD1pr2){D12 = " /\\ "; co62 = Blue;   u3x8 = 1; d3x8 = 0;}
   if(MaD12== MaD1pr2){D12 = " 0 "; co62 = Green;   u3x8 = 0; d3x8 = 0;}

   if(MaH13 < MaH1pr3){H13 = " V "; co13 = Red;    u1x13 = 0; d1x13 = 1;}
   if(MaH13 > MaH1pr3){H13 = " /\\ "; co13 = Blue; u1x13 = 1; d1x13 = 0;}
   if(MaH13 ==MaH1pr3){H13 = " 0 "; co13 = Green;  u1x13 = 0; d1x13 = 0;}
   if(MaH43 < MaH4pr3){H43 = " V "; co43 = Red; u2x13 = 0; d2x13 = 1;}
   if(MaH43 > MaH4pr3){H43 = " /\\ "; co43 = Blue; u2x13 = 1; d2x13 = 0;}
   if(MaH43 ==MaH4pr3){H43 = " 0 "; co43 = Green;  u2x13 = 0; d2x13 = 0;}
   if(MaD13 < MaD1pr3){D13 = " V "; co63 = Red; u3x13 = 0; d3x13 = 1;}
   if(MaD13 > MaD1pr3){D13 = " /\\ "; co63 = Blue; u3x13 = 1; d3x13 = 0;}
   if(MaD13 ==MaD1pr3){D13 = " 0 "; co63 = Green;  u3x13 = 0; d3x13 = 0;}

   if(MaH14 < MaH1pr4){H14 = " V "; co14 = Red;    u1x21 = 0; d1x21 = 1;}
   if(MaH14 > MaH1pr4){H14 = " /\\ "; co14 = Blue; u1x21 = 1; d1x21 = 0;}
   if(MaH14== MaH1pr4){H14 = " 0 "; co14 = Green; u1x21 = 0; d1x21 = 0;}
   if(MaH44 < MaH4pr4){H44 = " V "; co44 = Red; u2x21 = 0; d2x21 = 1;}
   if(MaH44 > MaH4pr4){H44 = " /\\ "; co44 = Blue; u2x21 = 1; d2x21 = 0;}
   if(MaH44== MaH4pr4){H44 = " 0 "; co44 = Green; u2x21 = 0; d2x21 = 0;}
   if(MaD14 < MaD1pr4){D14 = " V "; co64 = Red; u3x21 = 0; d3x21 = 1;}
   if(MaD14 > MaD1pr4){D14 = " /\\ "; co64 = Blue; u3x21 = 1; d3x21 = 0;}
   if(MaD14== MaD1pr4){D14 = " 0 "; co64 = Green; u3x21 = 0; d3x21 = 0;}

   if(MaH15 < MaH1pr5){H15 = " V "; co15 = Red;    u1x34 = 0; d1x34 = 1;}
   if(MaH15 > MaH1pr5){H15 = " /\\ "; co15 = Blue; u1x34 = 1; d1x34 = 0;}
   if(MaH15== MaH1pr5){H15 = " 0 "; co15 = Green; u1x34 = 0; d1x34 = 0;}
   if(MaH45 < MaH4pr5){H45 = " V "; co45 = Red;    u2x34 = 0; d2x34 = 1;}
   if(MaH45 > MaH4pr5){H45 = " /\\ "; co45 = Blue; u2x34 = 1; d2x34 = 0;}
   if(MaH45== MaH4pr5){H45 = " 0 "; co45 = Green; u2x34 = 0; d2x34 = 0;}
   if(MaD15 < MaD1pr5){D15 = " V "; co65 = Red;    u3x34 = 0; d3x34 = 1;}
   if(MaD15 > MaD1pr5){D15 = " /\\ "; co65 = Blue; u3x34 = 1; d3x34 = 0;}
   if(MaD15== MaD1pr5){D15 = " 0 "; co65 = Green; u3x34 = 0; d3x34 = 0;}

// Comment(";JGF:");
//        "\n", "H4 - ", H41 , 
//        "\n", "D1 - ", D11   );   

   ObjectSetText("label_object1","H1 - ",11,"Verdana",Lime);
   ObjectSetText("label_object2","H4 - ",11,"Verdana",Lime);
   ObjectSetText("label_object3","D1 - ",11,"Verdana",Lime);

   ObjectSetText("H11",H11,11,"Verdana",co11);
   ObjectSetText("H12",H12,11,"Verdana",co12);
   ObjectSetText("H13",H13,11,"Verdana",co13);
   ObjectSetText("H14",H14,11,"Verdana",co14);
   ObjectSetText("H15",H15,11,"Verdana",co15);

   ObjectSetText("H41",H41,11,"Verdana",co41);
   ObjectSetText("H42",H42,11,"Verdana",co42);
   ObjectSetText("H43",H43,11,"Verdana",co43);
   ObjectSetText("H44",H44,11,"Verdana",co44);
   ObjectSetText("H45",H45,11,"Verdana",co45);

   ObjectSetText("D11",D11,11,"Verdana",co61);
   ObjectSetText("D12",D12,11,"Verdana",co62);
   ObjectSetText("D13",D13,11,"Verdana",co63);
   ObjectSetText("D14",D14,11,"Verdana",co64);
   ObjectSetText("D15",D15,11,"Verdana",co65);

//----------------------------------------------------------------------------
// AC Bil Vil
   ObjectCreate("AC",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("AC","AC",9,"Verdana",Lime);
   ObjectSet("AC",OBJPROP_XDISTANCE,200);
   ObjectSet("AC",OBJPROP_YDISTANCE,0);

   double  ac  = iAC(NULL, 60, 0);
   double  ac1 = iAC(NULL, 60, 1);
   double  ac2 = iAC(NULL, 60, 2);
   double  ac3 = iAC(NULL, 60, 3);
//double  ac4 = iAO(NULL, 0, 4);             
   string ach11;
   color acco11=clrNONE;

   if((ac1>ac2 && ac2>ac3 && ac<0 && ac>ac1) || (ac>ac1 && ac1>ac2 && ac>0))
     {ach11="/\\ "; acco11=Blue; u1ac=3; d1ac=0;}
   if((ac1<ac2 && ac2<ac3 && ac>0 && ac<ac1) || (ac<ac1 && ac1<ac2 && ac<0))
     {ach11="V "; acco11=Red; u1ac=0; d1ac=3;}
   if((((ac1<ac2 || ac2<ac3) && ac<0 && ac>ac1) || (ac>ac1 && ac1<ac2 && ac>0)) || 
      (((ac1>ac2 || ac2>ac3) && ac>0 && ac<ac1) || (ac<ac1 && ac1>ac2 && ac<0)))
     {ach11="0 "; acco11=Green; u1ac=0; d1ac=0;}

   ObjectCreate("AC11",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("AC11",ach11,11,"Verdana",acco11);
   ObjectSet("AC11",OBJPROP_XDISTANCE,200);
   ObjectSet("AC11",OBJPROP_YDISTANCE,15);

   double  ac03=iAC(NULL,1440,0);
   double  ac13 = iAC(NULL, 1440, 1);
   double  ac23 = iAC(NULL, 1440, 2);
   double  ac33 = iAC(NULL, 1440, 3);
//double  ac4 = iAO(NULL, 0, 4);             
   string ach13;
   color acco13=clrNONE;

   if((ac13>ac23 && ac23>ac33 && ac03<0 && ac03>ac13) || (ac03>ac13 && ac13>ac23 && ac03>0))
     {ach13="/\\ "; acco13=Blue; u3ac=3; d3ac=0;}
   if((ac13<ac23 && ac23<ac33 && ac03>0 && ac03<ac13) || (ac03<ac13 && ac13<ac23 && ac03<0))
     {ach13="V "; acco13=Red; u3ac=0; d3ac=3;}
   if((((ac13<ac23 || ac23<ac33) && ac03<0 && ac03>ac13) || (ac03>ac13 && ac13<ac23 && ac03>0)) || 
      (((ac13>ac23 || ac23>ac33) && ac03>0 && ac03<ac13) || (ac03<ac13 && ac13>ac23 && ac03<0)))
     {ach13="0 "; acco13=Green; u3ac=0; d3ac=0;}
   ObjectCreate("AC13",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("AC13",ach13,11,"Verdana",acco13);
   ObjectSet("AC13",OBJPROP_XDISTANCE,200);
   ObjectSet("AC13",OBJPROP_YDISTANCE,55);

   double  ac02=iAC(NULL,240,0);
   double  ac12 = iAC(NULL, 240, 1);
   double  ac22 = iAC(NULL, 240, 2);
   double  ac32 = iAC(NULL, 240, 3);
//double  ac4 = iAO(NULL, 0, 4);             
   string ach12;
   color acco12=clrNONE;

   if((ac12>ac22 && ac22>ac32 && ac02<0 && ac02>ac12) || (ac02>ac12 && ac12>ac22 && ac02>0))
     {ach12="/\\ "; acco12=Blue; u2ac=3; d2ac=0;}
   if((ac12<ac22 && ac22<ac32 && ac02>0 && ac02<ac12) || (ac02<ac12 && ac12<ac22 && ac02<0))
     {ach12="V "; acco12=Red; u2ac=0; d2ac=3;}
   if((((ac12<ac22 || ac22<ac32) && ac02<0 && ac02>ac12) || (ac02>ac12 && ac12<ac22 && ac02>0)) || 
      (((ac12>ac22 || ac22>ac32) && ac02>0 && ac02<ac12) || (ac02<ac12 && ac12>ac22 && ac02<0)))
     {ach12="0 "; acco12=Green; u2ac=0; d2ac=0;}
   ObjectCreate("AC12",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("AC12",ach12,11,"Verdana",acco12);
   ObjectSet("AC12",OBJPROP_XDISTANCE,200);
   ObjectSet("AC12",OBJPROP_YDISTANCE,35);


   ObjectCreate("rez",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("rez","РЕЗУЛЬТАТЫ",9,"Verdana",Lime);
   ObjectSet("rez",OBJPROP_XDISTANCE,240);
   ObjectSet("rez",OBJPROP_YDISTANCE,0);

   double uitog1 = (u1x5 + u1x8 + u1x13 + u1x21 + u1x34 + u1ac) * 12.5;
   double uitog2 = (u2x5 + u2x8 + u2x13 + u2x21 + u2x34 + u2ac) * 12.5;
   double uitog3 = (u3x5 + u3x8 + u3x13 + u3x21 + u3x34 + u3ac) * 12.5;

   double ditog1 = (d1x5 + d1x8 + d1x13 + d1x21 + d1x34 + d1ac) * 12.5;
   double ditog2 = (d2x5 + d2x8 + d2x13 + d2x21 + d2x34 + d2ac) * 12.5;
   double ditog3 = (d3x5 + d3x8 + d3x13 + d3x21 + d3x34 + d3ac) * 12.5;

   string hr1,hr2,hr3;
   string dhr1,dhr2,dhr3;
   if(uitog1> ditog1) {hr1 = "Arial Black"; dhr1 = "Arial";}
   if(uitog1< ditog1) {hr1 = "Arial"; dhr1 = "Arial Black";}
   if(uitog1==ditog1) {hr1="Arial"; dhr1="Arial";}

   if(uitog2> ditog2) {hr2 = "Arial Black"; dhr2 = "Arial";}
   if(uitog2< ditog2) {hr2 = "Arial"; dhr2 = "Arial Black";}
   if(uitog2==ditog2) {hr2="Arial"; dhr2="Arial";}

   if(uitog3> ditog3) {hr3 = "Arial Black"; dhr3 = "Arial";}
   if(uitog3< ditog3) {hr3 = "Arial"; dhr3 = "Arial Black";}
   if(uitog3==ditog3) {hr3="Arial"; dhr3="Arial";}

   ObjectCreate("uitog1",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("uitog1",StringConcatenate("/\\ ",uitog1,"%"),12,hr1,DodgerBlue);
   ObjectSet("uitog1",OBJPROP_XDISTANCE,235);
   ObjectSet("uitog1",OBJPROP_YDISTANCE,15);

   ObjectCreate("uitog2",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("uitog2",StringConcatenate("/\\ ",uitog2,"%"),12,hr2,DodgerBlue);
   ObjectSet("uitog2",OBJPROP_XDISTANCE,235);
   ObjectSet("uitog2",OBJPROP_YDISTANCE,35);

   ObjectCreate("uitog3",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("uitog3",StringConcatenate("/\\ ",uitog3,"%"),12,hr3,DodgerBlue);
   ObjectSet("uitog3",OBJPROP_XDISTANCE,235);
   ObjectSet("uitog3",OBJPROP_YDISTANCE,55);

   ObjectCreate("ditog1",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("ditog1",StringConcatenate("\\/ ",ditog1,"%"),12,dhr1,Red);
   ObjectSet("ditog1",OBJPROP_XDISTANCE,310);
   ObjectSet("ditog1",OBJPROP_YDISTANCE,15);

   ObjectCreate("ditog2",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("ditog2",StringConcatenate("\\/ ",ditog2,"%"),12,dhr2,Red);
   ObjectSet("ditog2",OBJPROP_XDISTANCE,310);
   ObjectSet("ditog2",OBJPROP_YDISTANCE,35);

   ObjectCreate("ditog3",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("ditog3",StringConcatenate("\\/ ",ditog3,"%"),12,dhr3,Red);
   ObjectSet("ditog3",OBJPROP_XDISTANCE,310);
   ObjectSet("ditog3",OBJPROP_YDISTANCE,55);

   string txt;
   if(uitog1>50 && uitog2>50 && uitog3>50)

     {txt="Неплохой момент для открытия позиции BUY";}
   else
     {txt="Не рекомендуется открывать позиции. ЖДИТЕ.";}

   if(ditog1>50 && ditog2>50 && ditog3>50)
     {txt="Неплохой момент для открытия позиции SELL";}

   if(uitog1>=75 && uitog2>=75 && uitog3>=75)
     {txt="УДАЧНЫЙ момент для открытия позиции BUY";}
   if(ditog1>=75 && ditog2>=75 && ditog3>=75)
     {txt="УДАЧНЫЙ момент для открытия позиции SELL";}

   ObjectCreate("txt",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("txt",txt,14,"Verdana",Lime);
   ObjectSet("txt",OBJPROP_XDISTANCE,410);
   ObjectSet("txt",OBJPROP_YDISTANCE,35);

   ObjectCreate("txt2",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("txt2","Мультитаймфреймный индикатор \"TREND_ALEXCUD\"",9,"Verdana",Silver);
   ObjectSet("txt2",OBJPROP_XDISTANCE,11);
   ObjectSet("txt2",OBJPROP_YDISTANCE,80);
   ObjectCreate("txt3",OBJ_LABEL,WindowFind(short_name),0,0);
   ObjectSetText("txt3","Copyright © 2007 ALEXCUD",9,"Verdana",Silver);
   ObjectSet("txt3",OBJPROP_XDISTANCE,410);
   ObjectSet("txt3",OBJPROP_YDISTANCE,80);

   return(0);
  }
//+------------------------------------------------------------------+
