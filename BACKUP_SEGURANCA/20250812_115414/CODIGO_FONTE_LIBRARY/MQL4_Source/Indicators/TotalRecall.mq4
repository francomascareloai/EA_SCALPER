//+------------------------------------------------------------------+
//|                                                  TotalRecall.mq4 |
//|                                                     Bernd Kreuss |
//+------------------------------------------------------------------+
#property copyright "Bernd Kreuss"
#property link      "mailto:7bit@arcor.de" // <- small PayPal donations always welcome

#property indicator_separate_window
#property indicator_buffers 9
#property indicator_color1 Lime
#property indicator_color2 Blue
#property indicator_color3 Black

extern int pattern_size = 60;
extern int future_bars = 60;
extern int max_search_range = 60000;

double BufPast[];
double BufFuture[];
double BufBackground[];

int numbars;


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
   GlobalVariableDel("TotalRecall_"+Symbol()+Period()+"_future_bars");
   GlobalVariableDel("TotalRecall_"+Symbol()+Period()+"_pattern_size");
   GlobalVariableDel("TotalRecall_"+Symbol()+Period()+"_best_match");
   GlobalVariableDel("TotalRecall_"+Symbol()+Period()+"_second_best_match");
   GlobalVariableDel("TotalRecall_"+Symbol()+Period()+"_third_best_match");
   return(0);
}
 
int start(){
   if (Bars!=numbars){
      numbars = Bars;
      
      // this will do some expensive calculations and then
      // create some global variables for the other indicators
      // that show the other results.
      findBestMatch();
   }
   
   drawHistory(GlobalVariableGet("TotalRecall_"+Symbol()+Period()+"_best_match"));
   IndicatorShortName("\"TotalRecall\" Best match");

   // the other two indicators (if loaded) can now do the same 
   // with the other two global variables.

   return(0);
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

void getPatternAtIndex(int index, double& vector[]){
   int i;
   double sum, abs;
   for(i=0; i<pattern_size; i++){
      vector[i] = iMA(NULL,0,2,0,0,PRICE_WEIGHTED,index+i+1) - iMA(NULL,0,2,0,0,PRICE_WEIGHTED,index);
      //vector[i] = iAO(NULL,0,index+i);
      //vector[i] = iStochastic(NULL,0,5,3,3,0,0,MODE_MAIN,index+i)-50;
      sum += vector[i] * vector[i];
   }
   // normalize it
   abs = MathSqrt(sum);
   if (abs!=0){
      for(i=0; i<pattern_size; i++){
         vector[i] /= abs;
      }
   }
}

double getDifference(double a[], double b[]){
   double d, d1;
   int i;
   for(i=0; i<pattern_size; i++){
      d1 = a[i] - b[i];
      d += d1*d1;
   }
   return(d);
}

double getMirrorDifference(double a[], double b[]){
   double d, d1;
   int i;
   for(i=0; i<pattern_size; i++){
      d1 = a[i] + b[i];
      d += d1*d1;
   }
   return(d);
}

void findBestMatch(){
   int best_match, best_match2, best_match3;
   double current_pattern[];
   double pattern[];
   double distances[];
   double mirror_distances[];
   int maxbars = max_search_range;
   if (Bars < maxbars){
      maxbars = Bars;
   }
   ArrayResize(distances, maxbars);
   ArrayResize(mirror_distances, maxbars);
   ArrayResize(current_pattern, pattern_size);
   ArrayResize(pattern, pattern_size);
   double min_dist;
   int i;
   int first = maxbars - pattern_size;
   getPatternAtIndex(0, current_pattern);
   
   // find best matching
   min_dist = 999999999;
   for (i=pattern_size; i<first; i++){
      getPatternAtIndex(i, pattern);
      distances[i] = getDifference(pattern, current_pattern);
      if (distances[i] < min_dist){
         min_dist = distances[i];
         best_match = i;
      }
   }
   // search in the mirrors also
   for (i=pattern_size; i<first; i++){
      getPatternAtIndex(i, pattern);
      mirror_distances[i] = getMirrorDifference(pattern, current_pattern);
      if (mirror_distances[i] < min_dist){
         min_dist = mirror_distances[i];
         // minus sign is a flag that it points to a mirror pattern
         best_match = -i;
      }
   }
   
   
   // now we have the index of the pattern end in the variable best_match
   // if best_match is negative then we know that it points to a mirror pattern 
   
   
   // find second best matching
   min_dist = 999999999;
   
   // look for direct matches
   for (i=pattern_size; i<first; i++){
      // if best match is a mirror (negative) OR we are outside this area
      if (best_match < 0 || i < best_match - pattern_size || i > best_match + pattern_size){
         if (distances[i] < min_dist){
            min_dist = distances[i];
            best_match2 = i;
         }
      }
   }
   
   // look for mirrors
   for (i=pattern_size; i<first; i++){
      // if best_match is NOT a mirror (positive) OR we are outside this area
      // beware of the minus sign!
      if (best_match > 0 || i < -best_match - pattern_size || i > -best_match + pattern_size){
         if (mirror_distances[i] < min_dist){
            min_dist = mirror_distances[i];
            best_match2 = -i;
         }
      }
   }
   
   // find third best matching
   min_dist = 999999999;
   
   // direct
   for (i=pattern_size; i<first; i++){
      if ((best_match < 0 || i < best_match - pattern_size || i > best_match + pattern_size)
      && (best_match2 < 0 || i < best_match2 - pattern_size || i > best_match2 + pattern_size)){
         if (distances[i] < min_dist){
            min_dist = distances[i];
            best_match3 = i;
         }
      }
   }
   
   // mirrors
   for (i=pattern_size; i<first; i++){
      if ((best_match > 0 || i < -best_match - pattern_size || i > -best_match + pattern_size)
      && (best_match2 > 0 || i < -best_match2 - pattern_size || i > -best_match2 + pattern_size)){
         if (mirror_distances[i] < min_dist){
            min_dist = mirror_distances[i];
            best_match3 = -i;
         }
      }
   }
   
   GlobalVariableSet("TotalRecall_"+Symbol()+Period()+"_future_bars",future_bars);
   GlobalVariableSet("TotalRecall_"+Symbol()+Period()+"_pattern_size",pattern_size);
   GlobalVariableSet("TotalRecall_"+Symbol()+Period()+"_best_match",best_match);
   GlobalVariableSet("TotalRecall_"+Symbol()+Period()+"_second_best_match",best_match2);
   GlobalVariableSet("TotalRecall_"+Symbol()+Period()+"_third_best_match",best_match3);
}