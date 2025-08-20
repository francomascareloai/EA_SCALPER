//+------------------------------------------------------------------+
//|                                       ���� ���������_����_���.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                         yupyalta-���� ���������_����_���
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://yupyalta-���� ���������_����_���"
 
#property indicator_chart_window
extern int   ExtDepth     = 24;
extern int   ExtDeviation = 12;
extern int   ExtBackstep  = 5;//---
extern int   �����f0    = 0;
extern int   ���f0     = 1;
extern color ����f0    = Red;
extern int   �����f0001    = 0;
extern int   ���f0001     = 1;
extern color ����f0001    = Red;
//---
//---
extern int   �����f23    = 0;
extern int   ���f23      = 1;
extern color ����f23     = Yellow;
//---
extern int   �����f38    = 0;
extern int   ���f38      = 1;
extern color ����f38     = Lime;
//---
extern int   �����f50    = 0;
extern int   ���f50      = 2;
extern color ����f50     = DarkOrange;
//---
extern int   �����f61    = 0;
extern int   ���f61      = 1;
extern color ����f61     = Lime;
//---
extern int   �����f78    = 0;
extern int   ���f78      = 1;
extern color ����f78     = Lime;
//---
extern int   �����f100    = 0;
extern int   ���f100      = 1;
extern color ����f100     = Yellow;
//---
extern int   �����f161    = 0;
extern int   ���f161      = 1;
extern color ����f161     = Red;
//---
extern int   �����f2618   = 0;
extern int   ���f2618     = 1;
extern color ����2618     = Red;
//---
//---
extern bool   fon = false;
int rg,rd;
double f2618, f161,f100,f78,f76, f61, f50, f38,f23, f0001,f0,ext1, ext0;
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("Fibo0");
   ObjectDelete("Fibo0.001");
   ObjectDelete("Fibo23");
   ObjectDelete("Fibo38");
   ObjectDelete("Fibo50");
   ObjectDelete("Fibo61");
   ObjectDelete("Fibo78");
   ObjectDelete("Fibo100");
   ObjectDelete("Fibo161");
   ObjectDelete("Fibo261.8");
   ObjectDelete("F0");
   ObjectDelete("F0.001");
   ObjectDelete("F23");
   ObjectDelete("F38");
   ObjectDelete("F50");
   ObjectDelete("F61");
   ObjectDelete("F78");
   ObjectDelete("F100");
   ObjectDelete("F161");
   ObjectDelete("F261.8");
//----
   return(0);
  }
//+------------------------------------------------------------------+ 
int start()
  {
//----
   rg=GetExtremumZZBar(0);
   rd=GetExtremumZZBar(1); 
//---- 
   ext0=GetExtremumZZPrice(0);
   ext1=GetExtremumZZPrice(1);
//---- 
   f0=ext1+((ext0-ext1)*0);
   f0001=ext1+((ext1-ext0)*0.001);
   f23=ext1+((ext0-ext1)*0.236);
   f38=ext1+((ext0-ext1)*0.382); 
   f50=ext1+((ext0-ext1)*0.500);
   f61=ext1+((ext0-ext1)*0.618);
   f78=ext1+((ext0-ext1)*0.786); 
   f100=ext1+((ext0-ext1)*1);
   f161=ext1+((ext0-ext1)*1.618);
   f2618=ext1+((ext0-ext1)*2.618);
   //----
   ObjectDelete("Fibo0");
   ObjectCreate("Fibo0", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f161);
   ObjectSet("Fibo0", OBJPROP_STYLE, �����f161);
   ObjectSet("Fibo0", OBJPROP_WIDTH, ���f161); 
   ObjectSet("Fibo0", OBJPROP_COLOR, ����f161);
   ObjectSet("Fibo0", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo0");
   ObjectCreate("Fibo0", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f0001);
   ObjectSet("Fibo0", OBJPROP_STYLE, �����f0001);
   ObjectSet("Fibo0", OBJPROP_WIDTH, ���f0001); 
   ObjectSet("Fibo0", OBJPROP_COLOR, ����f0001);
   ObjectSet("Fibo0", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo23");
   ObjectCreate("Fibo23", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f23);
   ObjectSet("Fibo23", OBJPROP_STYLE, �����f23);
   ObjectSet("Fibo23", OBJPROP_WIDTH, ���f23); 
   ObjectSet("Fibo23", OBJPROP_COLOR, ����f23);
   ObjectSet("Fibo23", OBJPROP_BACK,  fon);
//----
   ObjectDelete("Fibo38");
   ObjectCreate("Fibo38", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f38);
   ObjectSet("Fibo38", OBJPROP_STYLE, �����f38);
   ObjectSet("Fibo38", OBJPROP_WIDTH, ���f38); 
   ObjectSet("Fibo38", OBJPROP_COLOR, ����f38);
   ObjectSet("Fibo38", OBJPROP_BACK,  fon);
//----    
   ObjectDelete("Fibo50");
   ObjectCreate("Fibo50", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f50);
   ObjectSet("Fibo50", OBJPROP_STYLE, �����f50);
   ObjectSet("Fibo50", OBJPROP_WIDTH, ���f50); 
   ObjectSet("Fibo50", OBJPROP_COLOR, ����f50);
   ObjectSet("Fibo50", OBJPROP_BACK,  fon);
//----
   ObjectDelete("Fibo61");
   ObjectCreate("Fibo61", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f61);
   ObjectSet("Fibo61", OBJPROP_STYLE, �����f61);
   ObjectSet("Fibo61", OBJPROP_WIDTH, ���f61); 
   ObjectSet("Fibo61", OBJPROP_COLOR, ����f61);
   ObjectSet("Fibo61", OBJPROP_BACK,  fon); 
    //----
   ObjectDelete("Fibo78");
   ObjectCreate("Fibo78", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f78);
   ObjectSet("Fibo78", OBJPROP_STYLE, �����f78);
   ObjectSet("Fibo78", OBJPROP_WIDTH, ���f78); 
   ObjectSet("Fibo78", OBJPROP_COLOR, ����f78);
   ObjectSet("Fibo78", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo100");
   ObjectCreate("Fibo100", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f100);
   ObjectSet("Fibo100", OBJPROP_STYLE, �����f100);
   ObjectSet("Fibo100", OBJPROP_WIDTH, ���f100); 
   ObjectSet("Fibo100", OBJPROP_COLOR, ����f100);
   ObjectSet("Fibo100", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo161");
   ObjectCreate("Fibo161", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f161);
   ObjectSet("Fibo161", OBJPROP_STYLE, �����f161);
   ObjectSet("Fibo161", OBJPROP_WIDTH, ���f161); 
   ObjectSet("Fibo161", OBJPROP_COLOR, ����f161);
   ObjectSet("Fibo161", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo261");
   ObjectCreate("Fibo261", OBJ_TREND, 0, Time[rd], ext1, Time[rg],f2618);
   ObjectSet("Fibo2.618", OBJPROP_STYLE, �����f2618);
   ObjectSet("Fibo161", OBJPROP_WIDTH, ���f2618); 
   ObjectSet("Fibo261", OBJPROP_COLOR, ����f0);
   ObjectSet("Fibo261", OBJPROP_BACK,  fon);
   //----
   double CP=5*Point;
   ObjectDelete("F0");
   ObjectCreate("F0",OBJ_TEXT,0,Time[rg],f0-CP);
   ObjectSetText("F0","",8,"Arial",����f0);
   //----
   
   ObjectDelete("F0");
   ObjectCreate("F0",OBJ_TEXT,0,Time[rg],f0001-CP);
   ObjectSetText("F0","",8,"Arial",����f0001);
   //----
   
   ObjectDelete("F23");
   ObjectCreate("F23",OBJ_TEXT,0,Time[rg],f23-CP);
   ObjectSetText("F23","F23.6",8,"Arial",����f23);
   //----  
   ObjectDelete("F38");
   ObjectCreate("F38",OBJ_TEXT,0,Time[rg],f38-CP);
   ObjectSetText("F38","F38.2",8,"Arial",����f38);
//----  
   ObjectDelete("F50");
   ObjectCreate("F50",OBJ_TEXT,0,Time[rg],f50-CP);
   ObjectSetText("F50","F50.0",8,"Arial",����f50);

   //----
   
   ObjectDelete("F61");
   ObjectCreate("F61",OBJ_TEXT,0,Time[rg],f61-CP);
   ObjectSetText("F61","F61.8",8,"Arial",����f61);
   //----
   
   ObjectDelete("F78");
   ObjectCreate("F78",OBJ_TEXT,0,Time[rg],f78-CP);
   ObjectSetText("F78","F78.6",8,"Arial",����f78);
   //----
   
   ObjectDelete("F100");
   ObjectCreate("F100",OBJ_TEXT,0,Time[rg],f100-CP);
   ObjectSetText("F100","F100",8,"Arial",����f100);
   //----
   
   ObjectDelete("F161");
   ObjectCreate("F161",OBJ_TEXT,0,Time[rg],f161-CP);
   ObjectSetText("F161","F161.8",8,"Arial",����f161);
   //----
   
   ObjectDelete("Ff2.618 ");
   ObjectCreate("Ff2.618",OBJ_TEXT,0,Time[rg],f2618-CP);
   ObjectSetText("Ff2.618","F261",8,"Arial",����f0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
int GetExtremumZZBar(int ne) {
  double zz;
  int i, k=iBars(Symbol(), 0), ke=0;
  for (i=0; i<k; i++) {
    zz=iCustom(Symbol(), 0, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, i);
    if (zz!=0) {
      ke++;
      if (ke>ne) return(i);
    }
  }
  return(-1);
}
//+------------------------------------------------------------------+
double GetExtremumZZPrice(int ne) {
  double zz;
  int    i, k=iBars(Symbol(), 0), ke=0;
  for (i=0; i<k; i++) {
    zz=iCustom(Symbol(), 0, "ZigZag", ExtDepth, ExtDeviation, ExtBackstep, 0, i);
    if (zz!=0) {
      ke++;
      if (ke>ne) return(zz);
    }
  }
  return(0);
}
//+------------------------------------------------------------------+