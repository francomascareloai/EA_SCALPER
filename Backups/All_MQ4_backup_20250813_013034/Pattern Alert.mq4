//+------------------------------------------------------------------+
//|                                  Pattern Alert v1.1 (Official)   |
//|                                                                  |
//| You may improve and add to this code but please send it back to  |
//| me for an official release. Thanks.                              |
//|                                                                  |
//|              Copyright © 2005, Jason Robinson                    |
//|               (jasonrobinsonuk,  jnrtrading)                     |
//|                http://www.jnrtrading.co.uk                       |
//|                                                                  |
//|       **THE ONLY OFFICIAL VERSION IS FROM MY WEBSITE**           |
//|         (unless it has been posted by me on a forum)             |
//|                                                                  |
//|Obviously this is still work in progress and needs LOTS of testing|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Red

extern bool Show_Text_Labels = true;
extern bool Show_Bearish_Engulfing_Patterns = true;
extern bool Show_Bullish_Engulfing_Patterns = true;
extern bool Show_Star_Patterns = true;
extern bool Show_Tweezer_Bottoms = true;
extern bool Show_Tweezer_Tops = true;


//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
string PatternText[2000];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {

//---- indicators
   for (int i = 0; i < Bars; i++) { // Clear buffer
         //ExtMapBuffer1[i] = 0;
         //ExtMapBuffer2[i] = 0;
   }
      
   for (int j = 0; j < Bars; j++) { 
      PatternText[j] = CharToStr(j);
   }
   SetIndexStyle(0,DRAW_ARROW, EMPTY);
   SetIndexArrow(0,242);
   SetIndexBuffer(0, ExtMapBuffer1);
      
   SetIndexStyle(1,DRAW_ARROW, EMPTY);
   SetIndexArrow(1,241);
   SetIndexBuffer(1, ExtMapBuffer2);
      
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
   ObjectsDeleteAll(0, OBJ_TEXT);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){
   
   Comment("Pattern Alert v1.1 Official");
   
   static datetime prevtime = 0;
   int shift;
   int shift1;
   int shift2;
   int shift3;
   string pattern;
   int setPattern = 0;
   int alert = 0;
   int arrowShift;
   int textShift;
     
   if(prevtime == Time[0]) {
      return(0);
   }
   prevtime = Time[0];
   
   
   // Code to determine a good place to put the text and arrow
   switch (Period()) {
      case 1:
         arrowShift = 1;
         textShift = 3;
         break;
      case 5:
         arrowShift = 3;
         textShift = 8;
         break;
      case 30:
         arrowShift = 7;
         textShift = 13;
         break;
      case 15:
         arrowShift = 7;
         textShift = 15;
         break;
      case 60:
         arrowShift = 9;
         textShift = 25;
         break;
      case 1440:
         arrowShift = 3;
         textShift = 7;
         break;
      case 10080:
         arrowShift = 95;
         textShift = 235;
         break;
      case 43200:
         arrowShift = 150;
         textShift = 260;
         break;
   }
   
   for (int j = 0; j < Bars; j++) { 
         PatternText[j] = j;
   }
   
   for (shift = 0; shift < Bars; shift++) {
      shift1 = shift + 1;
      shift2 = shift + 2;
      shift3 = shift + 3;
         
   
      // Check for a Bearish Engulfing pattern
      if (Show_Bearish_Engulfing_Patterns == true) {
         if ((Close[shift2] > Open[shift2]) && (Open[shift1] > Close[shift2]) && (Close[shift1] < Open[shift2])) {
            if (Show_Text_Labels) {
               ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + (Point * textShift));
               ObjectSetText(PatternText[shift], "Bearish Engulfing", 9, "Times New Roman", Red);
            }
            ExtMapBuffer1[shift1] = High[shift1] + (Point * arrowShift);         
            if (setPattern == 0) {
               pattern="Bearish Engulfing Pattern";
               setPattern = 1;
               alert = 1;
            }
            continue;
         }
      }
      
      // Check for a Bullish Engulfing pattern
      if (Show_Bullish_Engulfing_Patterns == true) {
         if ((Close[shift2] < Open[shift2]) && (Open[shift1] < Close[shift2]) && (Close[shift1] > Open[shift2])) {
            if (Show_Text_Labels == true) {
               ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + (Point * textShift));
               ObjectSetText(PatternText[shift], "Bullish Engulfing", 9, "Times New Roman", Red);
            }
            ExtMapBuffer1[shift1] = High[shift1] + (Point * arrowShift);
            if (setPattern == 0) {
               pattern="Bullish Engulfing Pattern";
               setPattern = 1;
               alert = 1;
            }
            continue;
         }
      }

      
      // Check for a Dark Cloud Cover pattern
      if ((Close[2] > Open[2]) && (Open[1] > High[2]) && (Close[1] < ((Open[2] + Close[2]) / 2)) && (Close[1] > Open[2])) {
         
         if (Show_Text_Labels == true) {
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + (Point * textShift));
            ObjectSetText(PatternText[shift], "Dark Cloud Cover", 9, "Times New Roman", Red);
         }
         ExtMapBuffer1[shift1] = High[shift1] + (Point * arrowShift);
         if (setPattern == 0) {
            pattern="Dark Cloud Cover";
            setPattern = 1;
            alert = 1;
         }
           continue;
       }
      
      
      if (Show_Star_Patterns == true) {
      // Check for Evening Doji Star pattern
         if (
            (Close[3] > Open[3]) //Bullish candle
            && (Open[2] == Close[2]) && (Low[2] < Open[2]) && (High[2] > Open[2]) // Doji
            && (Low[2] >= Close[3]) // Doji close higher or equal to Bullish close
            && (High[1] <= Close[2]) && (Open[1] <= Low[2]) && (Open[1] >= Close[3]) &&
            (Close[1] < ((Open[3] + Close[3]) / 2)) && (Close[1] > Open[3]) // Bearish candle in pattern
            ) {
               if (Show_Text_Labels == true) {
                  ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + (Point * textShift));
                  ObjectSetText(PatternText[shift], "Evening Doji Star", 9, "Times New Roman", Red);
               }
               ExtMapBuffer1[shift1] = High[shift1] + (Point * arrowShift);
        
               if (setPattern == 0) {
                  pattern = "Evening Doji Star";
                  setPattern = 1;
                  alert = 1;
               }
               continue;
         }
      
      // Check for Morning Doji Star pattern
         if (
            (Close[3] < Open[3]) //Bearish candle
            && (Open[2] == Close[2]) && (Low[2] < Open[2]) && (High[2] > Open[2]) // Doji
            && (High[2] <= Close[3]) // Doji close lower or equal to bearish close
            && (Low[1] >= Close[2]) && (Open[1] >= High[2]) && (Open[1] <= Close[3]) &&
            (Close[1] > ((Open[3] + Close[3]) / 2)) && (Close[1] < Open[3]) // Bullish candle in pattern
            ) {
               if (Show_Text_Labels == true) {
                  ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + (Point * textShift));
                  ObjectSetText(PatternText[shift], "Morning Doji Star", 9, "Times New Roman", Red);
               }
               ExtMapBuffer1[shift1] = High[shift1] + (Point * arrowShift);
                       
               if (setPattern == 0) {
                  pattern = "Morning Doji Star";
                  setPattern = 1;
                  alert = 1;
               }
               continue;
         }
      
      // Check for Evening Star pattern
         if(
            (Close[3] > Open[3]) //Bullish candle
            && (Open[2] > Close[2]) && (Low[2] < Open[2]) && (High[2] > Open[2]) // Second, small candle
            && (Low[2] > Close[3]) // small candle gaps up.
            && (High[1] < Close[2]) && (Open[1] <= Low[2]) && (Open[1] > Close[3]) &&
            (Close[1] < ((Open[3] + Close[3]) / 2)) && (Close[1] > Open[3]) // Bearish candle in pattern
         ) {
            if (Show_Text_Labels == true) {
               ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + (Point * textShift));
               ObjectSetText(PatternText[shift], "Evening Star", 9, "Times New Roman", Red);
            }
            ExtMapBuffer1[shift1] = High[shift1] + (Point * arrowShift);
                       
            if (setPattern == 0) {
               pattern = "Evening Star";
               setPattern = 1;
               alert = 1;
            }
            continue;
         }
      
      // Check for Morning Star pattern
         if (
            (Close[3] < Open[3]) //Bearish candle
            && (Open[2] < Close[2]) && (Low[2] < Open[2]) && (High[2] > Open[2]) // Second, small candle
            && (High[2] < Close[3]) // Small candle gaps down
            && (Low[1] > Close[2]) && (Open[1] >= High[2]) && (Open[1] < Close[3]) &&
            (Close[1] > ((Open[3] + Close[3]) / 2)) && (Close[1] < Open[3]) // Bullish candle in pattern
            ) {
               if (Show_Text_Labels == true) {
                  ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + (Point * textShift));
                  ObjectSetText(PatternText[shift], "Morning Star", 9, "Times New Roman", Red);
               }
               ExtMapBuffer1[shift1] = High[shift1] + (Point * arrowShift);
                       
               if (setPattern == 0) {
                  pattern = "Morning Star";
                  setPattern = 1;
                  alert = 1;
               }
               continue;
            }
      } // End of Show_Star_Patterns condition
      
      // Check for Tweezer Top
      if (Show_Tweezer_Tops == true) { 
         if ((High[shift1] == High[shift2])) {
            if (Show_Text_Labels == true) {
               ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + (Point * textShift));
               ObjectSetText(PatternText[shift], "Tweezer Top", 9, "Times New Roman", Red);
              }
            ExtMapBuffer1[shift1] = High[shift1] + (Point * arrowShift);         
                 
            if (setPattern == 0) {
               pattern = "Tweezer Top";
               setPattern = 1;
               alert = 1;
            }
            continue;
         }
      }
      
      // Check for Tweezer Bottom
      if (Show_Tweezer_Bottoms == true) {
         if ((Low[shift1] == Low[shift2]))
         {
            if (Show_Text_Labels == true) {
               ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] - (Point * textShift));
               ObjectSetText(PatternText[shift], "Tweezer Bottom", 9, "Times New Roman", Red);
            }
            ExtMapBuffer2[shift1] = High[shift1] - (Point * (arrowShift + 7));         
                  
            if (setPattern == 0) {
               pattern = "Tweezer Bottom";
               setPattern = 1;
               alert = 1;
            }
            continue;
         }
      }
      if (shift == 1 && alert == 1) {
         Print(Symbol(),"  M", Period(),"  ", pattern);
         Alert(Symbol(),"  M", Period(),"  ", pattern);
      }
   } // End of for loop
     
  
      
   return(0);
}
//+------------------------------------------------------------------+