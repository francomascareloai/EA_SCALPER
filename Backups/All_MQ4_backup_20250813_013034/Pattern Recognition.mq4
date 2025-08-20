//+------------------------------------------------------------------+
//|                                     Pattern Recognition v1.0     |
//|          (complete rewrite and name change of pattern alert)     |
//|                                                                  |
//|                 Copyright © 2005, Jason Robinson                 |
//|                  (jasonrobinsonuk,  jnrtrading)                  |
//|                   http://www.jnrtrading.co.uk                    |
//|                                                                  |
//|      This is still work in progress and needs LOTS of testing    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)."
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Red

extern bool Show_Alert = true;
extern bool Display_Bearish_Engulfing = true;
extern bool Display_Three_Outside_Down = true;
extern bool Display_Three_Inside_Down = true;
extern bool Display_Dark_Cloud_Cover = true;
extern bool Display_Three_Black_Crows = true;
extern bool Display_Bullish_Engulfing = true;
extern bool Display_Three_Outside_Up = true;
extern bool Display_Three_Inside_Up = true;
extern bool Display_Piercing_Line = true;
extern bool Display_Three_White_Soldiers = true;
extern bool Display_Stars = true;
extern bool Display_Harami = true;

//---- buffers
double upArrow[];
double downArrow[];
string PatternText[5000];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {

//---- indicators
   
   SetIndexStyle(0,DRAW_ARROW, EMPTY);
   SetIndexArrow(0,72);
   SetIndexBuffer(0, downArrow);
      
   SetIndexStyle(1,DRAW_ARROW, EMPTY);
   SetIndexArrow(1,71);
   SetIndexBuffer(1, upArrow);
      
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

   double Range, AvgRange;
   int counter, setalert;
   static datetime prevtime = 0;
   int shift;
   int shift1;
   int shift2;
   int shift3;
   string pattern, period;
   int setPattern = 0;
   int alert = 0;
   int arrowShift;
   int textShift;
   double O, O1, O2, C, C1, C2, L, L1, L2, H, H1, H2;
     
   if(prevtime == Time[0]) {
      return(0);
   }
   prevtime = Time[0];
   
   switch (Period()) {
      case 1:
         period = "M1";
         break;
      case 5:
         period = "M5";
         break;
      case 15:
         period = "M15";
         break;
      case 30:
         period = "M30";
         break;      
      case 60:
         period = "H1";
         break;
      case 240:
         period = "H4";
         break;
      case 1440:
         period = "D1";
         break;
      case 10080:
         period = "W1";
         break;
      case 43200:
         period = "MN";
         break;
   }
   
   for (int j = 0; j < Bars; j++) { 
         PatternText[j] = "pattern-" + j;
   }
   
   for (shift = 0; shift < Bars; shift++) {
      
      setalert = 0;
      counter=shift;
      Range=0;
      AvgRange=0;
      for (counter=shift ;counter<=shift+9;counter++) {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
      shift1 = shift + 1;
      shift2 = shift + 2;
      shift3 = shift + 3;
      
      O = Open[shift1];
      O1 = Open[shift2];
      O2 = Open[shift3];
      H = High[shift1];
      H1 = High[shift2];
      H2 = High[shift3];
      L = Low[shift1];
      L1 = Low[shift2];
      L2 = Low[shift3];
      C = Close[shift1];
      C1 = Close[shift2];
      C2 = Close[shift3];
         
   // Bearish Patterns
   
      // Check for Bearish Engulfing pattern
      if ((C1>O1)&&(O>C)&&(O>=C1)&&(O1>=C)&&((O-C)>(C1-O1))) {
         if (Display_Bearish_Engulfing == true) {
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "Bearish Engulfing", 9, "Times New Roman", Red);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (setalert == 0 && Show_Alert == true) {
            pattern = "Bearish Engulfing Pattern";
            setalert = 1;
         }
      }
      
      // Check for a Three Outside Down pattern
      if ((C2>O2)&&(O1>C1)&&(O1>=C2)&&(O2>=C1)&&((O1-C1)>(C2-O2))&&(O>C)&&(C<C1)) {
         if (Display_Three_Outside_Down == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "Three Oustide Down", 9, "Times New Roman", Red);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (setalert == 0 && Show_Alert == true) {
            pattern="Three Oustide Down Pattern";
            setalert = 1;
         }
      }
      
      // Check for a Dark Cloud Cover pattern
      if ((C1>O1)&&(((C1+O1)/2)>C)&&(O>C)&&(O>C1)&&(C>O1)&&((O-C)/(0.001+(H-L))>0.6)) {
         if (Display_Dark_Cloud_Cover == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "Dark Cloud Cover", 9, "Times New Roman", Red);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (setalert == 0 && Show_Alert == true) {
            pattern="Dark Cloud Cover Pattern";
            setalert = 1;
         }
      }
      
      // Check for Evening Doji Star pattern
      if ((C2>O2)&&((C2-O2)/(0.001+H2-L2)>0.6)&&(C2<O1)&&(C1>O1)&&((H1-L1)>(3*(C1-O1)))&&(O>C)&&(O<O1)) {
         if (Display_Stars == true) {
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "Evening Doji Star", 9, "Times New Roman", Red);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (setalert == 0 && Show_Alert == true) {
            pattern="Evening Doji Star Pattern";
            setalert = 1;
         }
      }
      
      // Check for Bearish Harami pattern
      
      if ((C1>O1)&&(O>C)&&(O<=C1)&&(O1<=C)&&((O-C)<(C1-O1))) {
         if (Display_Harami == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "Bearish Harami", 9, "Times New Roman", Red);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Bearish Harami Pattern";
            setalert = 1;
         }
      }
      
      // Check for Three Inside Down pattern
      
      if ((C2>O2)&&(O1>C1)&&(O1<=C2)&&(O2<=C1)&&((O1-C1)<(C2-O2))&&(O>C)&&(C<C1)&&(O<O1)) {
         if (Display_Three_Inside_Down == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "Three Inside Down", 9, "Times New Roman", Red);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three Inside Down Pattern";
            setalert = 1;
         }
      }
      
      // Check for Three Black Crows pattern
      
      if ((O > C * 1.01)&&(O1 > C1 * 1.01)&&(O2 > C2*1.01)&&(C < C1)&&(C1 < C2)&&(O > C1)&&(O < O1)&&(O1 > C2)&&(O1 < O2)&&(((C - L)/(H - L))<0.2)&&(((C1 - L1)/(H1 - L1))<0.2)&&(((C2 - L2)/(H2 - L2))<0.2)){
         if (Display_Three_Black_Crows == true){   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "Three Black Crows", 9, "Times New Roman", Red);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three Black Crows Pattern";
            setalert = 1;
         }
      }
      // Check for Evening Star Pattern
      
      if ((C2>O2)&&((C2-O2)/(0.001+H2-L2)>0.6)&&(C2<O1)&&(C1>O1)&&((H1-L1)>(3*(C1-O1)))&&(O>C)&&(O<O1)) {
         if (Display_Stars == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], High[shift1] + Range*1.5);
            ObjectSetText(PatternText[shift], "Evening Star", 9, "Times New Roman", Red);
            downArrow[shift1] = High[shift1] + Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern = "Evening Star Pattern";
            setalert = 1;
         }
      }
   // End of Bearish Patterns
   
   // Bullish Patterns
   
      // Check for Bullish Engulfing pattern
      
      if ((O1>C1)&&(C>O)&&(C>=O1)&&(C1>=O)&&((C-O)>(O1-C1))) {
         if (Display_Bullish_Engulfing) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "Bullish Engulfing", 9, "Times New Roman", Red);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Bullish Engulfing Pattern";
            setalert = 1;
         }
      }
      
      // Check for Three Outside Up pattern
      
      if ((O2>C2)&&(C1>O1)&&(C1>=O2)&&(C2>=O1)&&((C1-O1)>(O2-C2))&&(C>O)&&(C>C1)) {
         if (Display_Three_Outside_Up == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "Three Outside Up", 9, "Times New Roman", Red);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three Outside Up Pattern";
            setalert = 1;
         }
      }
      
      // Check for Bullish Harami pattern
      
      if ((O1>C1)&&(C>O)&&(C<=O1)&&(C1<=O)&&((C-O)<(O1-C1))) {
         if (Display_Harami == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "Bullish Harami", 9, "Times New Roman", Red);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Bullish Harami Pattern";
            setalert = 1;
         }
      }
      
      // Check for Three Inside Up pattern
      
      if ((O2>C2)&&(C1>O1)&&(C1<=O2)&&(C2<=O1)&&((C1-O1)<(O2-C2))&&(C>O)&&(C>C1)&&(O>O1)) {
         if (Display_Three_Inside_Up == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "Three Inside Up", 9, "Times New Roman", Red);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three Inside Up Pattern";
            setalert = 1;
         }
      }
      
      // Check for Piercing Line pattern
      
      if ((C1<O1)&&(((O1+C1)/2)<C)&&(O<C)&&(O<C1)&&(C<O1)&&((C-O)/(0.001+(H-L))>0.6)) {
         if (Display_Piercing_Line == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "Piercing Line", 9, "Times New Roman", Red);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Piercing Line Pattern";
            setalert = 1;
         }
      }
      
      // Check for Three White Soldiers pattern
      
      if ((C>O*1.01)&&(C1>O1*1.01)&&(C2>O2*1.01)&&(C>C1)&&(C1>C2)&&(O<C1)&&(O>O1)&&(O1<C2)&&(O1>O2)&&(((H-C)/(H-L))<0.2)&&(((H1-C1)/(H1-L1))<0.2)&&(((H2-C2)/(H2-L2))<0.2)) {
         if (Display_Three_White_Soldiers == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "Three White Soldiers", 9, "Times New Roman", Red);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Three White Soldiers Pattern";
            setalert = 1;
         }
      }
      
      // Check for Morning Doji Star
      
      if ((O2>C2)&&((O2-C2)/(0.001+H2-L2)>0.6)&&(C2>O1)&&(O1>C1)&&((H1-L1)>(3*(C1-O1)))&&(C>O)&&(O>O1)) {
         if (Display_Stars == true) {   
            ObjectCreate(PatternText[shift], OBJ_TEXT, 0, Time[shift1], Low[shift1] - Range*1.5);
            ObjectSetText(PatternText[shift], "Morning Doji Star", 9, "Times New Roman", Red);
            upArrow[shift1] = Low[shift1] - Range*0.5;
         }
         if (shift == 0 && Show_Alert == true) {
            pattern="Morning Doji Star Pattern";
            setalert = 1;
         }
      }
      
      if (setalert == 1 && shift == 0) {
         Alert(Symbol(), " ", period, " ", pattern);
         setalert = 0;
      }
   } // End of for loop
     
   
      
   return(0);
}
//+------------------------------------------------------------------+