//+------------------------------------------------------------------+
//|                                        !jl_3_Candle_Doubling.mq4 |
//|                                                        jeanlouie |
//|                                   www.forexfactory.com/jeanlouie |
//+------------------------------------------------------------------+
#property copyright "jeanlouie"
#property link      "www.forexfactory.com/jeanlouie"
#property version   "1.00"
#property strict
#property indicator_chart_window

input int sequence_length = 3;      //Sequence length
input double min_ratio = 2;         //Min Ratio (recent to backwards)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
string tag = "";
int OnInit()
  {
//--- indicator buffers mapping
   tag = "3cd ";
   
   ArrayResize(candle_ratios,sequence_length);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
double candle_ratios[];
int candle_type;
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

   if(sequence_length<=1){
      Alert("Sequence length must be larger than 1.");
      return(0);
   }
   
   if(min_ratio<=1){
      Alert("Minimum ratio must be larger than 0.");
      return(0);
   }

if(prev_calculated < 0)return(-1);
int lookback = sequence_length;
int limit = MathMax(Bars-1-lookback-prev_calculated,0);

for(int i = limit; i >= 0 && !IsStopped(); i--){

   ArrayInitialize(candle_ratios,0);
   candle_type = 0;
   
   for(int x=i; x<i+sequence_length; x++){
      if(Close[x+1]!=Open[x+1]){
         candle_ratios[x-i] = MathAbs((Close[x]-Open[x])/(Close[x+1]-Open[x+1]));
      }
      else{
         candle_ratios[x-i] = 0;
      }
      
      if(Close[x]>=Open[x])candle_type++;
      if(Close[x]< Open[x])candle_type--;
      
   }
   
   if(candle_ratios[ArrayMinimum(candle_ratios,0,0)]>=min_ratio){
      if(candle_type == sequence_length){
         ArrowCreate(0,tag+IntegerToString(rates_total-i),0,Time[i],High[i],234,ANCHOR_BOTTOM,clrRed,STYLE_SOLID,1);
      }
      if(candle_type == sequence_length*-1){
         ArrowCreate(0,tag+IntegerToString(rates_total-i),0,Time[i],Low[i],233,ANCHOR_TOP,clrRoyalBlue,STYLE_SOLID,1);
      }
   }
   
}//end main i loop


   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
bool ArrowCreate(const long              chart_ID=0,           // chart's ID
                 const string            name="Arrow",         // arrow name
                 const int               sub_window=0,         // subwindow index
                 datetime                t=0,                  // anchor point time
                 double                  p=0,                  // anchor point price
                 const uchar             arrow_code=252,       // arrow code
                 const ENUM_ARROW_ANCHOR anchor=ANCHOR_BOTTOM, // anchor point position
                 const color             clr=clrRed,           // arrow color
                 const ENUM_LINE_STYLE   style=STYLE_SOLID,    // border line style
                 const int               width=3,              // arrow size
                 const bool              back=false,           // in the background
                 const bool              selectable=true,      //object can be selected        
                 const bool              selection=false,      // highlight to move
                 const bool              hidden=false,         // hidden in the object list
                 const long              z_order=0)            // priority for mouse click
{
   ResetLastError();
   ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,t,p);
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,arrow_code);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selectable);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   
return(true);
}


void OnDeinit(const int reason)
{
   // 0 = REASON_PROGRAM
   // 1 = REASON_REMOVE 
   // 2 = REASON_RECOMPILE
   // 3 = REASON_CHARTCHANGE 
   // 4 = REASON_CHARTCLOSE 
   // 5 = REASON_PARAMETERS 
   // 6 = REASON_ACCOUNT 
   // 7 = REASON_TEMPLATE 
   // 8 = REASON_INITFAILED 
   // 9 = REASON_CLOSE 
   //if(reason == 0 || reason == 1)
   //{
      for(int iObj=ObjectsTotal()-1; iObj >= 0; iObj--)
      {
         string objname = ObjectName(iObj);
         if(StringFind(objname,tag) != -1)
         {  
            ObjectDelete(0,objname);
         }
      }
   //}
}