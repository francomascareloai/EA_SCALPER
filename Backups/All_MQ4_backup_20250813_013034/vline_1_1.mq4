#property indicator_chart_window
extern color line_color = LightSlateGray;
int i;
//----
int init()
  {
   IndicatorShortName("ZeroVertical");
   return(0);
  }
//----
int deinit()
  {
   if(ObjectFind("ZeroVertical") != -1) ObjectDelete("ZeroVertical");
   return(0);
  }
//----
int start()
  {
   if(ObjectFind("ZeroVertical") != -1) ObjectDelete("ZeroVertical");
   ObjectCreate("ZeroVertical",OBJ_VLINE,0,Time[0],0);
   ObjectSet("ZeroVertical",OBJPROP_COLOR,line_color);
   ObjectSet("ZeroVertical",OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("ZeroVertical",OBJPROP_WIDTH,1);
   return(0);
  }