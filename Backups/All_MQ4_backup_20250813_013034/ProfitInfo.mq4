//+------------------------------------------------------------------+
//|                                                   ProfitInfo.mq4 |
//|                                         Copyright © 2016, Ice FX |
//|                                              http://www.icefx.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Ice FX <http://www.icefx.eu>"
#property link      "http://www.icefx.eu"
#property version   "1.52"
#property strict

#property indicator_chart_window
#property indicator_buffers 0

extern int     MagicNumber          = -1;
extern string  CommentFilter        = "";
extern bool    OnlyAttachedSymbol   = TRUE;
extern string  StartDateFilter      = "";

extern ENUM_BASE_CORNER Corner      = CORNER_RIGHT_LOWER;
extern int     XOffset              = 0;
extern int     YOffset              = 0;

extern color   BGColor              = Black;
extern int     FontSize             = 8;
extern color   FontColor            = Gray;
extern color   FontColorPlus        = Green;
extern color   FontColorMinus       = FireBrick;

int      windowIndex                = 0;
double   pip_multiplier             = 1.0;
int      daySeconds                 = 86400;
string   Symb                       = "";
datetime startDateFilter            = 0;
datetime LastDrawProfitInfo         = 0;

string   IndiName                   = "ProfitInfo v1.5.2";


/*******************  Version history  ********************************

   v1.5.2 - 2016.03.13
   --------------------
      - fixed 2-digits XAU
      
   v1.5.1 - 2016.03.07
   --------------------
      - support 2-digits CFDs
      
   v1.5.0 - 2015.12.30
   --------------------
      - add lot column
      
   v1.4.3 - 2014.01.28
   --------------------
      - Background draw problem with offset

   v1.4.2 - 2013.11.13
   --------------------
      - Some percentage bug fixed

   v1.4.1 - 2013.11.04
   --------------------
      - Some bug fixed

   v1.4.0 - 2013.10.17
   --------------------
      - StartDateFilter: beállítható a profitszámítás kezdõ idõpontja
      - Show daily and monthly average gain
      - Refresh only every 10 seconds
      - Helyes sorrendû megjelenítés bal sarkok esetén
      

   v1.3.2 - 2013.07.09
   --------------------
      - Fixed some bug in pip calculation logic
      - Comment filter
      - Background


   v1.3.1 - 2013.07.03
   --------------------
      - MagicNumber filter

***********************************************************************/


int init()
{
	IndicatorShortName(IndiName);

   if (OnlyAttachedSymbol) Symb = Symbol();

   SetPipMultiplier(Symb);

   if (StartDateFilter != "")
      startDateFilter = StrToTime(StartDateFilter);

   start();
   
   return(0);
}

int start()
{
   windowIndex = 0;

   DrawProfitHistory();

   return(0);
}

int deinit()
{
   DeleteAllObject();


   return(0);
}

//+------------------------------------------------------------------+
void DrawProfitHistory() {
//+------------------------------------------------------------------+
   if (LastDrawProfitInfo > TimeCurrent() - 10) return;
   LastDrawProfitInfo = TimeCurrent();

   datetime day, today, now, prevDay;

   int row = 0;
   int step = 1;
   if (Corner > 1)
   {
      row = 13;
      step = -1;
   }

   DrawBackground("ProfitInfo_00_BG1", Corner, 1 , 30, BGColor, 133, "gg");
   DrawBackground("ProfitInfo_00_BG2", Corner, 1 ,  5, BGColor, 133, "gg");

   if (Corner % 2 == 0)
   {
      DrawText(Corner, row, 0,   "LOT", FontColor, FontSize); 
      DrawText(Corner, row, 60,  "DATE", FontColor, FontSize); 
      DrawText(Corner, row, 130, "PIPS", FontColor, FontSize); 
      DrawText(Corner, row, 210, "PROFIT", FontColor, FontSize); 
      DrawText(Corner, row, 280, "GAIN %", FontColor, FontSize); 
   } else {
      DrawText(Corner, row, 280, "DATE", FontColor, FontSize); 
      DrawText(Corner, row, 210, "PIPS", FontColor, FontSize); 
      DrawText(Corner, row, 130, "PROFIT", FontColor, FontSize); 
      DrawText(Corner, row, 60,  "GAIN %", FontColor, FontSize); 
      DrawText(Corner, row, 0,   "LOT", FontColor, FontSize); 
   }
   row += step;
   DrawText(Corner, row, 0, "====================================", FontColor, FontSize); 
   row += step;

   now = TimeCurrent();
   today = StrToTime(TimeToStr(now, TIME_DATE));

   DrawDayHistoryLine(today, now, row, "Today");
   row += step;

   day = today; prevDay = GetPreviousDay(day - daySeconds);
   DrawDayHistoryLine(prevDay, day, row, "Yesterday");
   row += step;

   day = prevDay; prevDay = GetPreviousDay(day - daySeconds);
   DrawDayHistoryLine(prevDay, day, row);
   row += step;

   day = prevDay; prevDay = GetPreviousDay(day - daySeconds);
   DrawDayHistoryLine(prevDay, day, row);
   row += step;

   day = prevDay; prevDay = GetPreviousDay(day - daySeconds);
   DrawDayHistoryLine(prevDay, day, row);
   row += step;
   
   day = DateOfMonday();
   DrawDayHistoryLine(day, now, row, "Week");
   row += step;

   day = StrToTime(Year()+"."+Month()+".01");
   DrawDayHistoryLine(day, now, row, "Month");
   row += step;

   day = StrToTime(Year()+".01.01");
   DrawDayHistoryLine(day, now, row, "Year");
   row += step;
   
   DrawText(1, row, 0, "------------------------------------------------------------", Gray, FontSize); 
   row += step;

   // Daily & Monthly profit
   if (AccountBalance() != 0.0)
   {
      double pips, profit, lots = 0;
      datetime firstOrderTime = GetHistoryInfoFromDate(day, now, pips, profit, lots);
      int oneDay = 86400; //int oneMonth = oneDay * 30.4;
      //double monthly = (profit / ((now - firstOrderTime) / oneMonth)) / (AccountBalance() - profit) * 100.0;
      double daily   = MathDiv(MathDiv(profit, MathDiv(now - firstOrderTime, oneDay)), (AccountBalance() - profit)) * 100.0;
      double monthly = daily * 30.4;

      DrawText(Corner, row, 0, StringConcatenate("Monthly: ", DTS(monthly, 2), "%"), ColorOnSign(monthly), FontSize); 
      DrawText(Corner, row, 150, StringConcatenate("Daily: ", DTS(daily, 2), "%"), ColorOnSign(daily), FontSize); 
   }   
   row += step;

   DrawText(Corner, row, 0, "====================================", FontColor, FontSize); 
   row += step;
   if (Corner < 2) // ha felül van, akkor plusz eggyel lentebb kell rakni valamiért
      row += step;
      

   string text = StringConcatenate(IndiName, " - Created by Ice FX - www.icefx.eu"); 
   DrawText(Corner, row, 0, text, DimGray, 7);
}

//+------------------------------------------------------------------+
void DrawDayHistoryLine(datetime prevDay, datetime day, int row, string header = "") {
//+------------------------------------------------------------------+
   if (header == "") header = TimeToStr(prevDay, TIME_DATE); 

   double pips, profit, percent, lots = 0.0;
   string text;
   
   GetHistoryInfoFromDate(prevDay, day, pips, profit, lots);
   double profitp = 0;
   if (AccountBalance() > 0) profitp = profit / (AccountBalance() - profit) * 100.0;
   
   if (Corner % 2 == 0)
   {
      text = DTS(lots, 2); 
      DrawText(Corner, row, 0, text, ColorOnSign(profit), FontSize); 

      text = StringConcatenate(header, ": "); 
      DrawText(Corner, row, 60, text, FontColor, FontSize); 

      text = DTS(pips, 1); 
      DrawText(Corner, row, 140, text, ColorOnSign(pips), FontSize); 

      text = DTS(profit, 2); 
      DrawText(Corner, row, 240, text, ColorOnSign(profit), FontSize); 

      text = StringConcatenate(DTS(profitp, 2), "%"); 
      DrawText(Corner, row, 280, text, ColorOnSign(profitp), FontSize); 
      
   } else {
      text = StringConcatenate(header, ": "); 
      DrawText(Corner, row, 260, text, FontColor, FontSize); 

      text = DTS(pips, 1); 
      DrawText(Corner, row, 210, text, ColorOnSign(pips), FontSize); 

      text = DTS(profit, 2); 
      DrawText(Corner, row, 130, text, ColorOnSign(profit), FontSize); 

      text = StringConcatenate(DTS(profitp, 2), "%"); 
      DrawText(Corner, row, 60, text, ColorOnSign(profitp), FontSize); 

      text = DTS(lots, 2); 
      DrawText(Corner, row, 0, text, ColorOnSign(profit), FontSize); 
   }
}

//+------------------------------------------------------------------+
datetime GetHistoryInfoFromDate(datetime prevDay, datetime day, double &pips, double &profit, double &lots) {
//+------------------------------------------------------------------+
   datetime res = day;
   int i, k = OrdersHistoryTotal();
   pips = 0;
   profit = 0;
   lots = 0;
  
   for (i = 0; i < k; i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if ( IsValidOrder() ) {
           if (OrderType()==OP_BUY || OrderType()==OP_SELL) {
               if (day >= OrderCloseTime() && OrderCloseTime() >= prevDay && OrderCloseTime() > startDateFilter) {
                  profit += OrderProfit() + OrderCommission() + OrderSwap();

                  if (OrderType() == OP_BUY) {
                     pips += point2pip(OrderClosePrice() - OrderOpenPrice(), OrderSymbol());
                  }
                  if (OrderType() == OP_SELL) {
                     pips += point2pip(OrderOpenPrice() - OrderClosePrice(), OrderSymbol());
                  }       
                  lots += OrderLots();           
                  
                  if (OrderCloseTime() < res) res = OrderCloseTime();
               }
            }
         }
      }
   }
   return(res);
}

//+------------------------------------------------------------------+
datetime GetPreviousDay(datetime curDay) {
//+------------------------------------------------------------------+
   datetime prevDay = curDay;
   
   while (TimeDayOfWeek(prevDay) < 1 || TimeDayOfWeek(prevDay) > 5) prevDay -= daySeconds;
   return(prevDay);
}

//+------------------------------------------------------------------+
datetime DateOfMonday(int no = 0) {
//+------------------------------------------------------------------+
  datetime dt = StrToTime(TimeToStr(TimeCurrent(), TIME_DATE));

  while (TimeDayOfWeek(dt) != 1) dt -= daySeconds;
  dt += no * 7 * daySeconds;

  return(dt);
}

//+------------------------------------------------------------------+
color ColorOnSign(double value) {
//+------------------------------------------------------------------+
  color lcColor = FontColor;

  if (value > 0) lcColor = FontColorPlus;
  if (value < 0) lcColor = FontColorMinus;

  return(lcColor);
}

//+------------------------------------------------------------------+
string DTS(double value, int decimal = 0) { return(DoubleToStr(value, decimal)); }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double point2pip(double point, string Symb = "") {
//+------------------------------------------------------------------+
   if (Symb == "") Symb = Symbol();

   SetPipMultiplier(Symb);
   
   return(MathDiv(MathDiv(point, MarketInfo(Symb, MODE_POINT)), pip_multiplier));
}

//+------------------------------------------------------------------+
double MathDiv(double a, double b) {
//+------------------------------------------------------------------+
   if (b != 0.0)
      return(a/b);

   return(0.0);
}  

//+------------------------------------------------------------------+
double SetPipMultiplier(string Symb, bool simple = false) {
//+------------------------------------------------------------------+
   pip_multiplier = 1;
   int digit = MarketInfo(Symb, MODE_DIGITS);
   
   if (simple)
   {
      if (digit % 4 != 0) pip_multiplier = 10; 
        
   } else {
      if (digit == 5 || 
         (digit == 3 && StringFind(Symb, "JPY") > -1) ||     // If 3 digits and currency is JPY
         (digit == 2 && StringFind(Symb, "XAU") > -1) ||     // If 2 digits and currency is gold
         (digit == 2 && StringFind(Symb, "GOLD") > -1) ||    // If 2 digits and currency is gold
         (digit == 3 && StringFind(Symb, "XAG") > -1) ||     // If 3 digits and currency is silver
         (digit == 3 && StringFind(Symb, "SILVER") > -1) ||  // If 3 digits and currency is silver
         (digit == 1))                                       // If 1 digit (CFDs)
            pip_multiplier = 10;
      else if (digit == 6 || 
         (digit == 4 && StringFind(Symb, "JPY") > -1) ||     // If 4 digits and currency is JPY
         (digit == 3 && StringFind(Symb, "XAU") > -1) ||     // If 3 digits and currency is gold
         (digit == 3 && StringFind(Symb, "GOLD") > -1) ||    // If 3 digits and currency is gold
         (digit == 4 && StringFind(Symb, "XAG") > -1) ||     // If 4 digits and currency is silver
         (digit == 4 && StringFind(Symb, "SILVER") > -1) ||  // If 4 digits and currency is silver
         (digit == 2))                                       // If 2 digit (CFDs)
            pip_multiplier = 100;
   }  
   //Print("PipMultiplier: ", pip_multiplier, ", Digits: ", Digits);
   return(pip_multiplier);
}

//+------------------------------------------------------------------+
void DrawText(int corner, int row, int x, string text, color c, int size = 7) {
//+------------------------------------------------------------------+
   string objName = "ProfitInfo_" + DTS(Corner) + "_" + DTS(x) + "_" + DTS(row);
   if (ObjectFind(objName) != 0) {
      ObjectCreate(objName, OBJ_LABEL, windowIndex, 0, 0);
      ObjectSet(objName, OBJPROP_CORNER, Corner);
   }

   ObjectSetText(objName, text, size, "Verdana", c);
   ObjectSet(objName, OBJPROP_XDISTANCE, 12 + XOffset + x);
   ObjectSet(objName, OBJPROP_YDISTANCE, 6 + YOffset + row * (size + 6));
   ObjectSet(objName, OBJPROP_BACK, false);
}

//+------------------------------------------------------------------+
void DrawBackground(string name, int corner, int X, int Y, color c, int size = 180, string ch = "g") {
//+------------------------------------------------------------------+
   if (name == "") name = "BKGR";
   
   if (ObjectFind(name) < 0)
      ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
    
   ObjectSet(name, OBJPROP_CORNER, corner);
   ObjectSet(name, OBJPROP_BACK, false);
   ObjectSet(name, OBJPROP_XDISTANCE, XOffset + X);
   ObjectSet(name, OBJPROP_YDISTANCE, YOffset + Y);
   ObjectSetText(name, ch, size, "Webdings", c);
}

//+------------------------------------------------------------------+
bool IsValidOrder() {
//+------------------------------------------------------------------+
   if (Symb == "" || OrderSymbol() == Symbol()) 
      if ( MagicNumber == -1 || MagicNumber == OrderMagicNumber() )
         if (CommentFilter == "" || StringFind(OrderComment(), CommentFilter) != -1)
            return(true);

   return(false);
}

//+------------------------------------------------------------------+
void DeleteAllObject() {
//+------------------------------------------------------------------+
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
      if(StringFind(ObjectName(i), "ProfitInfo_", 0) >= 0)
         ObjectDelete(ObjectName(i));

}

