//+------------------------------------------------------------------+
//|                                                  TotalRecall.mq4 |
//|                                                     Bernd Kreuss |
//+------------------------------------------------------------------+
#property copyright "Bernd Kreuss"
#property link      "mailto:7bit@arcor.de" // <- small PayPal donations always welcome

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Lime
#property indicator_color2 Blue
#property indicator_color3 Black

double BufPast[];
double BufFuture[];
double BufBackground[];

extern string comment = "works only with \"TotalRecall\" attached!";
extern int show_second_or_third_best = 2;

int pattern_size;
int future_bars;

int init(){
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,BufPast);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,BufFuture);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,BufBackground);
   return(0);
}

int deinit(){
   return(0);
}

int start(){
   if (GlobalVariableCheck("TotalRecall_"+Symbol()+Period()+"_pattern_size")==False){
      IndicatorShortName("\"TotalRecall\" indicator is not attached to this chart!");
      drawHistory(0);
      return(0);
   }
   pattern_size = GlobalVariableGet("TotalRecall_"+Symbol()+Period()+"_pattern_size");
   future_bars = GlobalVariableGet("TotalRecall_"+Symbol()+Period()+"_future_bars");
   if (show_second_or_third_best == 2){
      IndicatorShortName("Second best match");
      drawHistory(GlobalVariableGet("TotalRecall_"+Symbol()+Period()+"_second_best_match"));
      return(0);
   }
   if (show_second_or_third_best == 3){
      IndicatorShortName("Third best match");
      drawHistory(GlobalVariableGet("TotalRecall_"+Symbol()+Period()+"_third_best_match"));
      return(0);
   }
   IndicatorShortName("Only Values of 2 or 3 are allowed!");
   drawHistory(0);
}

void drawHistory(int end){
   int i;
   bool mirror = False;
   
   for(i=0; i<Bars; i++){
      BufBackground[i] = EMPTY_VALUE;
      BufFuture[i] = EMPTY_VALUE;
      BufPast[i] = EMPTY_VALUE;
   }
   
   if (end<0){
      end = -end;
      mirror = True;
   }
   
   int end_in_window = future_bars;
   for (i = 0; i<pattern_size; i++){
      if (mirror){
         BufBackground[end_in_window+i] = -Low[end+i];
         BufPast[end_in_window+i] = -High[end+i];
      }else{
         BufBackground[end_in_window+i] = Low[end+i];
         BufPast[end_in_window+i] = High[end+i];
      }
   } 
   for (i = 0; i<future_bars; i++){
      if (mirror){
         BufBackground[end_in_window-i] = -Low[end-i];
         BufFuture[end_in_window-i] = -High[end-i];
      }else{
         BufBackground[end_in_window-i] = Low[end-i];
         BufFuture[end_in_window-i] = High[end-i];
      }
   }
   
   // force the correct y-scaling by inserting 2 invisible bars at the beginning
   if (mirror){
      BufBackground[end_in_window + pattern_size + 1] = -High[iHighest(NULL,0,MODE_HIGH,future_bars,end-future_bars)];
      BufBackground[end_in_window + pattern_size + 2] = -Low[iLowest(NULL,0,MODE_HIGH,future_bars,end-future_bars)];
   }else{
      BufBackground[end_in_window + pattern_size + 1] = High[iHighest(NULL,0,MODE_HIGH,future_bars,end-future_bars)];
      BufBackground[end_in_window + pattern_size + 2] = Low[iLowest(NULL,0,MODE_HIGH,future_bars,end-future_bars)];
   }
    
   SetIndexShift(0,future_bars);
   SetIndexShift(1,future_bars);
   SetIndexShift(2,future_bars);
}

