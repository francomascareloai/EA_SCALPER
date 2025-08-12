// Id:  
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65770

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property description "Indicator will draw fan retracement lines from a manually drawn trend line"
#property description "- You must draw a trend line from a recognizable high and low"
#property description "- Then on its properties rename this trend line to 'speedline' or the one you define in the windows properties"

#property indicator_chart_window

extern string trendline_name = "speedline";
extern color  fan_color      = clrYellow;
extern int    fan_style      = STYLE_SOLID;
extern int    fan_width      = 2;
extern bool   show_labels    = true;
extern color  labels_color   = clrWhite;
input double level_1 = 0.382; // Level 1
input double level_2 = 0.5; // Level 2
input double level_3 = 0.618; // Level 3
input double level_4 = 0.764; // Level 4

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init(){
   IndicatorName = GenerateIndicatorName("Speedlines");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   Limpiar();
   return(0);
}

int start()
{   
   Limpiar();
   
   if (ObjectType("speedline")==OBJ_TREND){
      
      datetime tl_start  = ObjectGet("speedline",OBJPROP_TIME1);
      double tl_price1 = ObjectGet("speedline",OBJPROP_PRICE1);
      double tl_price2 = ObjectGet("speedline",OBJPROP_PRICE2);

      double tl_333, tl_500, tl_667;
      double level_4_val;      
      if (tl_price2 < tl_price1)
      {
         tl_333 = tl_price2 + (tl_price1 - tl_price2) * level_1;
         tl_500 = tl_price2 + (tl_price1 - tl_price2) * level_2;
         tl_667 = tl_price2 + (tl_price1 - tl_price2) * level_3;
         level_4_val = tl_price2 + (tl_price1 - tl_price2) * level_4;
      }
      else
      {
         tl_333 = tl_price2 - (tl_price2 - tl_price1) * level_1;
         tl_500 = tl_price2 - (tl_price2 - tl_price1) * level_2;
         tl_667 = tl_price2 - (tl_price2 - tl_price1) * level_3;
         level_4_val = tl_price2 - (tl_price2 - tl_price1) * level_4;
      }
      
      Pivot("tl_333",tl_start,tl_price1,Time[0],tl_333, fan_color, fan_width, fan_style, DoubleToString(level_1 * 100, 1) + "%");
      Pivot("tl_500",tl_start,tl_price1,Time[0],tl_500, fan_color, fan_width, fan_style, DoubleToString(level_2 * 100, 1) + "%");
      Pivot("tl_667",tl_start,tl_price1,Time[0],tl_667, fan_color, fan_width, fan_style, DoubleToString(level_3 * 100, 1) + "%");
      Pivot("tl_4",tl_start,tl_price1,Time[0],level_4_val, fan_color, fan_width, fan_style, DoubleToString(level_4 * 100, 1) + "%");
   
   }
   
//----
   return(0);
}

void Pivot(string Nombre, datetime tiempo1, double precio1, datetime tiempo2, double precio2, color bpcolor, int ancho, int style, string label){
   ObjectDelete(IndicatorObjPrefix + Nombre);
   ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_TREND, 0, tiempo1, precio1, tiempo2, precio2);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, bpcolor);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_RAY, False);
   ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, true );
   if (show_labels){
      ObjectDelete(IndicatorObjPrefix + "T"+Nombre);
      ObjectCreate(IndicatorObjPrefix + "T"+Nombre, OBJ_TEXT, 0, tiempo2+(2*Period()*60), precio2 );
      ObjectSetText(IndicatorObjPrefix + "T"+Nombre, label, 10, "Arial", bpcolor );
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_TIME1, tiempo2+(2*Period()*60));
      ObjectSet(IndicatorObjPrefix + "T"+Nombre, OBJPROP_PRICE1, precio2);
   }
}

void Limpiar(){
   ObjectDelete(IndicatorObjPrefix + "tl_333");
   ObjectDelete(IndicatorObjPrefix + "tl_500");
   ObjectDelete(IndicatorObjPrefix + "tl_667");
}