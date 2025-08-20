//+------------------------------------------------------------------+
//|                                       ВЕЕР ФИБОНАЧЧИ_АВТО_МОД.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                         yupyalta-ВЕЕР ФИБОНАЧЧИ_АВТО_МОД
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://yupyalta-ВЕЕР ФИБОНАЧЧИ_АВТО_МОД"
 
#property indicator_chart_window
extern int   ExtDepth     = 24;
extern int   ExtDeviation = 12;
extern int   ExtBackstep  = 5;//---
extern int   Стильf0    = 0;
extern int   ширf0     = 1;
extern color цветf0    = Red;
extern int   Стильf0001    = 0;
extern int   ширf0001     = 1;
extern color цветf0001    = Red;
//---
//---
extern int   Стильf23    = 0;
extern int   ширf23      = 1;
extern color цветf23     = Yellow;
//---
extern int   Стильf38    = 0;
extern int   ширf38      = 1;
extern color цветf38     = Lime;
//---
extern int   Стильf50    = 0;
extern int   ширf50      = 2;
extern color цветf50     = DarkOrange;
//---
extern int   Стильf61    = 0;
extern int   ширf61      = 1;
extern color цветf61     = Lime;
//---
extern int   Стильf78    = 0;
extern int   ширf78      = 1;
extern color цветf78     = Lime;
//---
extern int   Стильf100    = 0;
extern int   ширf100      = 1;
extern color цветf100     = Yellow;
//---
extern int   Стильf161    = 0;
extern int   ширf161      = 1;
extern color цветf161     = Red;
//---
extern int   Стильf2618   = 0;
extern int   ширf2618     = 1;
extern color цвет2618     = Red;
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
   ObjectSet("Fibo0", OBJPROP_STYLE, Стильf161);
   ObjectSet("Fibo0", OBJPROP_WIDTH, ширf161); 
   ObjectSet("Fibo0", OBJPROP_COLOR, цветf161);
   ObjectSet("Fibo0", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo0");
   ObjectCreate("Fibo0", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f0001);
   ObjectSet("Fibo0", OBJPROP_STYLE, Стильf0001);
   ObjectSet("Fibo0", OBJPROP_WIDTH, ширf0001); 
   ObjectSet("Fibo0", OBJPROP_COLOR, цветf0001);
   ObjectSet("Fibo0", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo23");
   ObjectCreate("Fibo23", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f23);
   ObjectSet("Fibo23", OBJPROP_STYLE, Стильf23);
   ObjectSet("Fibo23", OBJPROP_WIDTH, ширf23); 
   ObjectSet("Fibo23", OBJPROP_COLOR, цветf23);
   ObjectSet("Fibo23", OBJPROP_BACK,  fon);
//----
   ObjectDelete("Fibo38");
   ObjectCreate("Fibo38", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f38);
   ObjectSet("Fibo38", OBJPROP_STYLE, Стильf38);
   ObjectSet("Fibo38", OBJPROP_WIDTH, ширf38); 
   ObjectSet("Fibo38", OBJPROP_COLOR, цветf38);
   ObjectSet("Fibo38", OBJPROP_BACK,  fon);
//----    
   ObjectDelete("Fibo50");
   ObjectCreate("Fibo50", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f50);
   ObjectSet("Fibo50", OBJPROP_STYLE, Стильf50);
   ObjectSet("Fibo50", OBJPROP_WIDTH, ширf50); 
   ObjectSet("Fibo50", OBJPROP_COLOR, цветf50);
   ObjectSet("Fibo50", OBJPROP_BACK,  fon);
//----
   ObjectDelete("Fibo61");
   ObjectCreate("Fibo61", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f61);
   ObjectSet("Fibo61", OBJPROP_STYLE, Стильf61);
   ObjectSet("Fibo61", OBJPROP_WIDTH, ширf61); 
   ObjectSet("Fibo61", OBJPROP_COLOR, цветf61);
   ObjectSet("Fibo61", OBJPROP_BACK,  fon); 
    //----
   ObjectDelete("Fibo78");
   ObjectCreate("Fibo78", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f78);
   ObjectSet("Fibo78", OBJPROP_STYLE, Стильf78);
   ObjectSet("Fibo78", OBJPROP_WIDTH, ширf78); 
   ObjectSet("Fibo78", OBJPROP_COLOR, цветf78);
   ObjectSet("Fibo78", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo100");
   ObjectCreate("Fibo100", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f100);
   ObjectSet("Fibo100", OBJPROP_STYLE, Стильf100);
   ObjectSet("Fibo100", OBJPROP_WIDTH, ширf100); 
   ObjectSet("Fibo100", OBJPROP_COLOR, цветf100);
   ObjectSet("Fibo100", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo161");
   ObjectCreate("Fibo161", OBJ_TREND, 0, Time[rd], ext1, Time[rg], f161);
   ObjectSet("Fibo161", OBJPROP_STYLE, Стильf161);
   ObjectSet("Fibo161", OBJPROP_WIDTH, ширf161); 
   ObjectSet("Fibo161", OBJPROP_COLOR, цветf161);
   ObjectSet("Fibo161", OBJPROP_BACK,  fon);
   //----
   ObjectDelete("Fibo261");
   ObjectCreate("Fibo261", OBJ_TREND, 0, Time[rd], ext1, Time[rg],f2618);
   ObjectSet("Fibo2.618", OBJPROP_STYLE, Стильf2618);
   ObjectSet("Fibo161", OBJPROP_WIDTH, ширf2618); 
   ObjectSet("Fibo261", OBJPROP_COLOR, цветf0);
   ObjectSet("Fibo261", OBJPROP_BACK,  fon);
   //----
   double CP=5*Point;
   ObjectDelete("F0");
   ObjectCreate("F0",OBJ_TEXT,0,Time[rg],f0-CP);
   ObjectSetText("F0","",8,"Arial",цветf0);
   //----
   
   ObjectDelete("F0");
   ObjectCreate("F0",OBJ_TEXT,0,Time[rg],f0001-CP);
   ObjectSetText("F0","",8,"Arial",цветf0001);
   //----
   
   ObjectDelete("F23");
   ObjectCreate("F23",OBJ_TEXT,0,Time[rg],f23-CP);
   ObjectSetText("F23","F23.6",8,"Arial",цветf23);
   //----  
   ObjectDelete("F38");
   ObjectCreate("F38",OBJ_TEXT,0,Time[rg],f38-CP);
   ObjectSetText("F38","F38.2",8,"Arial",цветf38);
//----  
   ObjectDelete("F50");
   ObjectCreate("F50",OBJ_TEXT,0,Time[rg],f50-CP);
   ObjectSetText("F50","F50.0",8,"Arial",цветf50);

   //----
   
   ObjectDelete("F61");
   ObjectCreate("F61",OBJ_TEXT,0,Time[rg],f61-CP);
   ObjectSetText("F61","F61.8",8,"Arial",цветf61);
   //----
   
   ObjectDelete("F78");
   ObjectCreate("F78",OBJ_TEXT,0,Time[rg],f78-CP);
   ObjectSetText("F78","F78.6",8,"Arial",цветf78);
   //----
   
   ObjectDelete("F100");
   ObjectCreate("F100",OBJ_TEXT,0,Time[rg],f100-CP);
   ObjectSetText("F100","F100",8,"Arial",цветf100);
   //----
   
   ObjectDelete("F161");
   ObjectCreate("F161",OBJ_TEXT,0,Time[rg],f161-CP);
   ObjectSetText("F161","F161.8",8,"Arial",цветf161);
   //----
   
   ObjectDelete("Ff2.618 ");
   ObjectCreate("Ff2.618",OBJ_TEXT,0,Time[rg],f2618-CP);
   ObjectSetText("Ff2.618","F261",8,"Arial",цветf0);
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