#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 White
#property indicator_color3 Black



#define FLINESIZE 14 // размер записи файла равен 14 байт

//TimeFrame, RsiPeriod, MaType, MaPeriod
extern string TimeFrame = "H4";
extern int RsiPeriod = 4;
extern int MaType = 1;
extern int MaPeriod = 2;
extern bool Interpolate = TRUE;
extern string arrowsIdentifier = "SBNR arrows";
extern color arrowsUpColor = Lime;
extern color arrowsDnColor = Red;
extern bool alertsOn = TRUE;
extern bool alertsSound = TRUE;
extern bool alertsOnCurrent = FALSE;
extern bool alertsMessage = FALSE;
extern bool alertsEmail = FALSE;
double G_ibuf_136[];
double G_ibuf_140[];
double G_ibuf_144[];
string gs_148;
bool gi_156 = FALSE;
bool gi_160 = FALSE;
int g_timeframe_164;
string gs_nothing_168 = "nothing";
datetime g_time_176;

datetime lastArrTime = EMPTY;

int init() {
   IndicatorBuffers(3);
   SetIndexBuffer(0, G_ibuf_136);
   SetIndexLabel(0, "");
   SetIndexBuffer(1, G_ibuf_140);
   SetIndexLabel(1, "");
   SetIndexBuffer(2, G_ibuf_144);
   SetIndexLabel(2, "");
   if (TimeFrame == "calculate") {
      gi_156 = TRUE;
      return (0);
   }
   if (TimeFrame == "returnBars") {
      gi_160 = TRUE;
      return (0);
   }
   g_timeframe_164 = f0_0(TimeFrame);
   gs_148 = WindowExpertName();
 
   
   StartFile();
   
   return (0);
}

int deinit() {
 
   f0_2();
   return (0);
}

int start() {

   int shift_0;
   int datetime_4;
   double Ld_8;
   int Li_16;
   int Li_32 = IndicatorCounted();
   if (Li_32 < 0) return (-1);
   if (Li_32 > 0) Li_32--;
   int Li_36 = MathMin(Bars - Li_32, Bars - 1);
   if (gi_160) {
      G_ibuf_136[0] = Li_36 + 1;
      return (0);
   }
   if (g_timeframe_164 > Period()) Li_36 = MathMax(Li_36, MathMin(Bars - 1, iCustom(NULL, g_timeframe_164, gs_148, "returnBars", 0, 0) * g_timeframe_164 / Period()));
   if (gi_156) {
      for (int Li_40 = 0; Li_40 < Li_36; Li_40++) G_ibuf_136[Li_40] = iRSI(NULL, 0, RsiPeriod, PRICE_CLOSE, Li_40);
      for (Li_40 = 0; Li_40 < Li_36; Li_40++) G_ibuf_140[Li_40] = iMAOnArray(G_ibuf_136, 0, MaPeriod, 0, MaType, Li_40);
      return (0);
   }
   int typeLastSignal = EMPTY;
   
   for (Li_40 = Li_36; Li_40 >= 0; Li_40--) {
      shift_0 = iBarShift(NULL, g_timeframe_164, Time[Li_40]);
      G_ibuf_136[Li_40] = iCustom(NULL, g_timeframe_164, gs_148, "calculate", RsiPeriod, MaType, MaPeriod, 0, shift_0);
      G_ibuf_140[Li_40] = iCustom(NULL, g_timeframe_164, gs_148, "calculate", RsiPeriod, MaType, MaPeriod, 1, shift_0);
      G_ibuf_144[Li_40] = G_ibuf_144[Li_40 + 1];
      if (G_ibuf_136[Li_40] > G_ibuf_140[Li_40]) G_ibuf_144[Li_40] = 1; 
      if (G_ibuf_136[Li_40] < G_ibuf_140[Li_40]) G_ibuf_144[Li_40] = -1; 
    //  f0_4(Time[Li_40]);
      if (G_ibuf_144[Li_40] != G_ibuf_144[Li_40 + 1]) {
         if (G_ibuf_144[Li_40] == 1.0) { DrawArrowForBar(Li_40, arrowsUpColor, 233, 0); typeLastSignal = OP_BUY;  }
         if (G_ibuf_144[Li_40] == -1.0){ DrawArrowForBar(Li_40, arrowsDnColor, 234, 1); typeLastSignal = OP_SELL; }
      }
      if (g_timeframe_164 <= Period() || shift_0 == iBarShift(NULL, g_timeframe_164, Time[Li_40 - 1])) continue;
      if (Interpolate) {
         datetime_4 = iTime(NULL, g_timeframe_164, shift_0);
         for (int Li_44 = 1; Li_40 + Li_44 < Bars && Time[Li_40 + Li_44] >= datetime_4; Li_44++) {
         }
         Ld_8 = 1.0 / Li_44;
         for (int Li_48 = 1; Li_48 < Li_44; Li_48++) {
            G_ibuf_136[Li_40 + Li_48] = Li_48 * Ld_8 * (G_ibuf_136[Li_40 + Li_44]) + (1.0 - Li_48 * Ld_8) * G_ibuf_136[Li_40];
            G_ibuf_140[Li_40 + Li_48] = Li_48 * Ld_8 * (G_ibuf_140[Li_40 + Li_44]) + (1.0 - Li_48 * Ld_8) * G_ibuf_140[Li_40];
         }
      }
   }
   
   if (alertsOn) {
      if (alertsOnCurrent) Li_16 = 0;
      else Li_16 = 1;
      if (G_ibuf_144[Li_16] != G_ibuf_144[Li_16 + 1]) {
         if (G_ibuf_144[Li_16] == 1.0) f0_5("Trend UP");
         if (G_ibuf_144[Li_16] == -1.0) f0_5("Trend DOWN");
      }
   }
   
   datetime curTime = iTime(NULL, g_timeframe_164, 0);
   string nameCurObj = arrowsIdentifier + ":" + iTime(NULL, g_timeframe_164, 0);      
   
   if( ObjectFind(nameCurObj) != EMPTY && curTime > lastArrTime )
   {
      if( typeLastSignal != EMPTY )
      {
         if( lastArrTime == EMPTY  )
            SaveSignal(curTime, typeLastSignal);
         else
         {
            datetime minuts = iTime(NULL, PERIOD_M1, 0);
            SaveSignal(curTime, typeLastSignal, minuts);
            
            if( Period() < g_timeframe_164 )   
               if( typeLastSignal == OP_BUY )
                  DrawArrowForTime(minuts, arrowsUpColor, 233, typeLastSignal);  
               else
                  DrawArrowForTime(minuts, arrowsDnColor, 234, typeLastSignal);  
         }                     
      }
      Print("Try save signal");
      lastArrTime = curTime;
   }
   
   if( lastArrTime == EMPTY ) lastArrTime = curTime - 1;
   
   
   return (0);
}

void DrawArrowForBar(int ai_0, color a_color_4, int ai_8, bool ai_12) {
   string name_16 = arrowsIdentifier + ":" + Time[ai_0];
   double Ld_24 = 3.0 * iATR(NULL, 0, 20, ai_0) / 4.0;
   ObjectCreate(name_16, OBJ_ARROW, 0, Time[ai_0], 0);
   ObjectSet(name_16, OBJPROP_ARROWCODE, ai_8);
   ObjectSet(name_16, OBJPROP_COLOR, a_color_4);
   if (ai_12) {
      ObjectSet(name_16, OBJPROP_PRICE1, High[ai_0] + Ld_24);
      return;
   }
   ObjectSet(name_16, OBJPROP_PRICE1, Low[ai_0] - Ld_24);
}

void DrawArrowForTime(datetime time, color a_color_4, int arrowCode, bool isDnArr) {
   int bar = iBarShift(NULL, 0, time);
   string name_16 = arrowsIdentifier + ":" + time;
   double Ld_24 = 3.0 * iATR(NULL, 0, 20, bar) / 4.0;
   ObjectCreate(name_16, OBJ_ARROW, 0, time, 0);
   ObjectSet(name_16, OBJPROP_ARROWCODE, arrowCode);
   ObjectSet(name_16, OBJPROP_COLOR, a_color_4);
   if (isDnArr) {
      ObjectSet(name_16, OBJPROP_PRICE1, High[bar] + Ld_24);
      return;
   }
   ObjectSet(name_16, OBJPROP_PRICE1, Low[bar] - Ld_24);
}

void f0_2() {
   string name_0;
   string ls_8 = arrowsIdentifier + ":";
   int str_len_16 = StringLen(ls_8);
   for (int Li_20 = ObjectsTotal() - 1; Li_20 >= 0; Li_20--) {
      name_0 = ObjectName(Li_20);
      if (StringSubstr(name_0, 0, str_len_16) == ls_8) ObjectDelete(name_0);
   }
}

void f0_4(int ai_0) {
   string name_4 = arrowsIdentifier + ":" + ai_0;
   ObjectDelete(name_4);
}

void f0_5(string as_0) {
   string str_concat_8;
   if (gs_nothing_168 != as_0 || g_time_176 != Time[0]) {
      gs_nothing_168 = as_0;
      g_time_176 = Time[0];
      str_concat_8 = StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " Signal Arrow ", as_0);
      if (alertsMessage) Alert(str_concat_8);
      if (alertsEmail) SendMail(StringConcatenate(Symbol(), "Signal Arrow"), str_concat_8);
      if (alertsSound) PlaySound("alert2.wav");
   }
}

int f0_0(string as_0) {
   int Li_8;
   for (int Li_12 = StringLen(as_0) - 1; Li_12 >= 0; Li_12--) {
      Li_8 = StringGetChar(as_0, Li_12);
      if ((Li_8 > '`' && Li_8 < '{') || (Li_8 > 'Я' && Li_8 < 256)) as_0 = StringSetChar(as_0, Li_12, Li_8 - 32);
      else
         if (Li_8 > -33 && Li_8 < 0) as_0 = StringSetChar(as_0, Li_12, Li_8 + 224);
   }
   int timeframe_16 = 0;
   if (as_0 == "M1" || as_0 == "1") timeframe_16 = 1;
   if (as_0 == "M5" || as_0 == "5") timeframe_16 = 5;
   if (as_0 == "M15" || as_0 == "15") timeframe_16 = 15;
   if (as_0 == "M30" || as_0 == "30") timeframe_16 = 30;
   if (as_0 == "H1" || as_0 == "60") timeframe_16 = 60;
   if (as_0 == "H4" || as_0 == "240") timeframe_16 = 240;
   if (as_0 == "D1" || as_0 == "1440") timeframe_16 = 1440;
   if (as_0 == "W1" || as_0 == "10080") timeframe_16 = 10080;
   if (as_0 == "MN" || as_0 == "43200") timeframe_16 = 43200;
   if (timeframe_16 == 0 || timeframe_16 < Period()) timeframe_16 = Period();
   return (timeframe_16);
}

string f0_3() {
   switch (g_timeframe_164) {
   case PERIOD_M1:
      return ("M(1)");
   case PERIOD_M5:
      return ("M(5)");
   case PERIOD_M15:
      return ("M(15)");
   case PERIOD_M30:
      return ("M(30)");
   case PERIOD_H1:
      return ("H(1)");
   case PERIOD_H4:
      return ("H(4)");
   case PERIOD_D1:
      return ("D(1)");
   case PERIOD_W1:
      return ("W(1)");
   case PERIOD_MN1:
      return ("MN(1)");
   }
   return ("Unknown timeframe");
}


//+----------------------------------------------------------------+
//
string ErrorStr = "";

string WorckFileName = "indti_snbr2_save2_";

int hFile = EMPTY;
//----------------+;
//
void StartFile()
{ 
    WorckFileName = WorckFileName+Symbol() + g_timeframe_164 +  "_" +RsiPeriod+"_"+MaType+"_"+MaPeriod+"_"+Interpolate+".csv";
    
    hFile = FileOpen( WorckFileName, FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_READ|FILE_SHARE_WRITE);
   
    if( hFile == INVALID_HANDLE )
    {  
      ErrorStr = StringConcatenate("Не получилось открыть файл для загрузки истории сигналов", WorckFileName, ", error ", GetLastError());
      Print(ErrorStr); 
      Comment( WindowExpertName() + " " + ErrorStr  );
      hFile = EMPTY; 
      return; 
    } 
    
   lastArrTime = EMPTY; 
   datetime time;
   int op;
   int counter = 0;

    while( !FileIsEnding(hFile) )
    {
        time = FileReadNumber(hFile);
        op = FileReadNumber(hFile);
        
        if( op == OP_BUY )
            DrawArrowForTime(time, arrowsUpColor, 233, op); 
            Alert("Ярославик ",Symbol()," M",Period()," наверно бай");
            
        if( op == OP_SELL )       
            DrawArrowForTime(time, arrowsDnColor, 234, op);
            Alert("Ярославик ",Symbol()," M",Period()," наверно селл");
            
        if( time > lastArrTime ) lastArrTime = time;
            
        counter++;
    }
     Print("Counter: ", counter);
    
 FileClose(hFile); 
}

//+----------------------------------------------------------------+
//


void SaveSignal( datetime time, int op, datetime time2 = EMPTY)
{

    hFile = FileOpen( WorckFileName, FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_READ|FILE_SHARE_WRITE);
   
    if( hFile == INVALID_HANDLE )
    {  
      ErrorStr = StringConcatenate("Не получилось открыть файл для сохранения сигнала", WorckFileName, ", error ", GetLastError());
      Print(ErrorStr); 
      Comment( WindowExpertName() + " " + ErrorStr  );      
      hFile = EMPTY; 
      return; 
    } 
    
   bool needWrite = false; 
  // bool needWrite = true;    // to test
   
   if( FileIsEnding(hFile) ) 
      needWrite = true;
   else if( FileSeek(hFile, -FLINESIZE, SEEK_END) )
   {
      datetime timeLastSignal = FileReadNumber(hFile);
      
      if( timeLastSignal < time || ( time2 != EMPTY || timeLastSignal < time2) )
         needWrite = true;
   }
   
   if( needWrite )
   if( FileSeek(hFile, 0, SEEK_END) )
   {
     if( FileWrite(hFile, time, op) == 0 )
        Print("Ошибка записи в файл ", WorckFileName);

     if( time2 != EMPTY )
     if( FileWrite(hFile, time2, op) == 0 )
        Print("Ошибка записи в файл ", WorckFileName);
   }
      
 FileClose(hFile);
}