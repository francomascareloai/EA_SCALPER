//+------------------------------------------------------------------+
//|                                      Auto Regression Channel.mq4 |
//|                                 Copyright © 2011, Michael Edward |
//|                                              kingooofx@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Michael Edward"
#property link      "kingooofx@yahoo.com"

#property indicator_chart_window

extern int Hr1_shift_small_start = 0;
extern int Hr1_shift_small_end = 0;
extern int Hr1_shift_big_start = 0;
extern int Hr1_shift_big_end = 0;
extern int Hr1_shift_big2_start = 0;
extern int Hr1_shift_big2_end = 0;

extern int Hr4_shift_small_start = 1;
extern int Hr4_shift_small_end = 1;
extern int Hr4_shift_big_start = 1;
extern int Hr4_shift_big_end = 1;
extern int Hr4_shift_big2_start = 1;
extern int Hr4_shift_big2_end = 1;

extern int Daily_shift_small_start = 0;
extern int Daily_shift_small_end = 0;
extern int Daily_shift_big_start = 0;
extern int Daily_shift_big_end = 0;
extern int Daily_shift_big2_start = 0;
extern int Daily_shift_big2_end = 0;

extern color small_color=Maroon;
extern color big_color=MidnightBlue;
extern color big2_color="13,13,47";
extern int small_width=1;
extern int big_width=1;
extern int big2_width=1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
ObjectsDeleteAll(0, OBJ_REGRESSION);
//     ObjectDelete("1hr_small"); 
//     ObjectDelete("1hr_big"); 
//     ObjectDelete("4hr_small"); 
//     ObjectDelete("4hr_big"); 
//     ObjectDelete("daily_small"); 
//     ObjectDelete("daily_small"); 

//     ObjectDelete("half_small"); 
//     ObjectDelete("half_big"); 
//     ObjectDelete("quart_small"); 
//     ObjectDelete("quart_big"); 
//     ObjectDelete("five_min_small"); 
//     ObjectDelete("five_min_big"); 
//     ObjectDelete("one_min_small"); 
//     ObjectDelete("one_min_big"); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
ObjectsDeleteAll(0, OBJ_REGRESSION);
//     ObjectDelete("1hr_small"); 
//     ObjectDelete("1hr_big"); 
//     ObjectDelete("4hr_small"); 
//     ObjectDelete("4hr_big"); 
//     ObjectDelete("daily_small"); 
//     ObjectDelete("daily_small"); 

//     ObjectDelete("half_small"); 
//     ObjectDelete("half_big"); 
//     ObjectDelete("quart_small"); 
//     ObjectDelete("quart_big"); 
//     ObjectDelete("five_min_small"); 
//     ObjectDelete("five_min_big"); 
//     ObjectDelete("one_min_small"); 
//     ObjectDelete("one_min_big"); 

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
ObjectsDeleteAll(0, OBJ_REGRESSION);
//     ObjectDelete("1hr_small"); 
//     ObjectDelete("1hr_big"); 
//     ObjectDelete("4hr_small"); 
//     ObjectDelete("4hr_big"); 
//     ObjectDelete("daily_small"); 
//     ObjectDelete("daily_small"); 

//     ObjectDelete("half_small"); 
//     ObjectDelete("half_big"); 
//     ObjectDelete("quart_small"); 
//     ObjectDelete("quart_big"); 
//     ObjectDelete("five_min_small"); 
//     ObjectDelete("five_min_big"); 
//     ObjectDelete("one_min_small"); 
//     ObjectDelete("one_min_big"); 

   int    counted_bars=IndicatorCounted();
//----
//for 1Hr
      draw_1("1hr_small", Time[iBarShift(Symbol(), PERIOD_H1, iTime(Symbol(),PERIOD_D1,1))+Hr1_shift_small_start], Time[iBarShift(Symbol(), PERIOD_H1, iTime(Symbol(),PERIOD_D1,0))+Hr1_shift_small_end] ,small_color, small_width);
      draw_1("1hr_big", Time[iBarShift(Symbol(), PERIOD_H1, iTime(Symbol(),PERIOD_D1,2))+Hr1_shift_big_start], Time[iBarShift(Symbol(), PERIOD_H1, iTime(Symbol(),PERIOD_D1,0))+Hr1_shift_big_end] ,big_color, big_width);
      draw_1("1hr_big2", Time[iBarShift(Symbol(), PERIOD_H1, iTime(Symbol(),PERIOD_D1,3))+Hr1_shift_big2_start], Time[iBarShift(Symbol(), PERIOD_H1, iTime(Symbol(),PERIOD_D1,0))+Hr1_shift_big2_end] ,big2_color, big2_width);
//for 4Hr
      draw_4("4hr_small", Time[iBarShift(Symbol(), PERIOD_H4, iTime(Symbol(),PERIOD_W1,1))-Hr4_shift_small_start], Time[iBarShift(Symbol(), PERIOD_H4, iTime(Symbol(),PERIOD_W1,0))-Hr4_shift_small_end] ,small_color, small_width);
      draw_4("4hr_big", Time[iBarShift(Symbol(), PERIOD_H4, iTime(Symbol(),PERIOD_W1,2))-Hr4_shift_big_start], Time[iBarShift(Symbol(), PERIOD_H4, iTime(Symbol(),PERIOD_W1,0))-Hr4_shift_big_end] ,big_color, big_width);
      draw_4("4hr_big2", Time[iBarShift(Symbol(), PERIOD_H4, iTime(Symbol(),PERIOD_W1,3))-Hr4_shift_big2_start], Time[iBarShift(Symbol(), PERIOD_H4, iTime(Symbol(),PERIOD_W1,0))-Hr4_shift_big2_end] ,big2_color, big2_width);
//for Daily 
      draw_daily("daily_small", Time[iBarShift(Symbol(), PERIOD_D1, iTime(Symbol(),PERIOD_MN1,1))-Daily_shift_small_start], Time[iBarShift(Symbol(), PERIOD_D1, iTime(Symbol(),PERIOD_MN1,0))-Daily_shift_small_end] ,small_color, small_width);
      draw_daily("daily_big", Time[iBarShift(Symbol(), PERIOD_D1, iTime(Symbol(),PERIOD_MN1,2))-Daily_shift_big_start], Time[iBarShift(Symbol(), PERIOD_D1, iTime(Symbol(),PERIOD_MN1,0))-Daily_shift_big_end] ,big_color, big_width);
      draw_daily("daily_big2", Time[iBarShift(Symbol(), PERIOD_D1, iTime(Symbol(),PERIOD_MN1,3))-Daily_shift_big2_start], Time[iBarShift(Symbol(), PERIOD_D1, iTime(Symbol(),PERIOD_MN1,0))-Daily_shift_big2_end] ,big2_color, big2_width);
//for 30MIN.
if (Hour()>=12)
{
draw_half("half_small", iTime(Symbol(),PERIOD_D1,0), Time[iBarShift(Symbol(), PERIOD_M30, iTime(Symbol(),PERIOD_D1,0))-24] ,small_color);
draw_half("half_big", Time[iBarShift(Symbol(), PERIOD_M30, iTime(Symbol(),PERIOD_D1,0))+24], Time[iBarShift(Symbol(), PERIOD_M30, iTime(Symbol(),PERIOD_D1,0))-24] ,big_color);
draw_half("half2_big", Time[iBarShift(Symbol(), PERIOD_M30, iTime(Symbol(),PERIOD_D1,0))+48], Time[iBarShift(Symbol(), PERIOD_M30, iTime(Symbol(),PERIOD_D1,0))-24] ,big2_color);
}
if (Hour()<12)
{
draw_half("half_small", Time[iBarShift(Symbol(), PERIOD_M30, iTime(Symbol(),PERIOD_D1,0))+24], iTime(Symbol(),PERIOD_D1,0) ,small_color);
draw_half("half_big", iTime(Symbol(),PERIOD_D1,1), iTime(Symbol(),PERIOD_D1,0) ,big_color);
draw_half("half2_big", iTime(Symbol(),PERIOD_D1,1), iTime(Symbol(),PERIOD_D1,0) ,big2_color);
}
//for 15MIN.
if (Hour()<6)
{
draw_quart("quart_small", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))+24], iTime(Symbol(),PERIOD_D1,0) ,small_color);
draw_quart("quart_big", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))+48], iTime(Symbol(),PERIOD_D1,0) ,big_color);
draw_quart("quart2_big", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))+72], iTime(Symbol(),PERIOD_D1,0) ,big2_color);
}
if (Hour()>=6 && Hour()<12)
{
draw_quart("quart_small", iTime(Symbol(),PERIOD_D1,0), Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-24] ,small_color);
draw_quart("quart_big", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))+24], Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-24] ,big_color);
draw_quart("quart2_big", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))+48], Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-24] ,big2_color);
}
if (Hour()>=12 && Hour()<18)
{
draw_quart("quart_small", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-24], Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-48] ,small_color);
draw_quart("quart_big", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-0], Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-48] ,big_color);
draw_quart("quart2_big", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))+24], Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-48] ,big2_color);

}
if (Hour()>=18)
{
draw_quart("quart_small", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-48], Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-72] ,small_color);
draw_quart("quart_big", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-24], Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-72] ,big_color);
draw_quart("quart2_big", Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0)) -0], Time[iBarShift(Symbol(), PERIOD_M15, iTime(Symbol(),PERIOD_D1,0))-72] ,big2_color);
}

//for 5MIN.
if (Hour()<3)
{
draw_five("five_min_small", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))+36], iTime(Symbol(),PERIOD_D1,0) ,small_color);
draw_five("five_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))+72], iTime(Symbol(),PERIOD_D1,0) ,big_color);
draw_five("five2_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))+108], iTime(Symbol(),PERIOD_D1,0) ,big2_color);
}
if (Hour()>=3 && Hour()<6)
{
draw_five("five_min_small", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))+0], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-36] ,small_color);
draw_five("five_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))+36], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-36] ,big_color);
draw_five("five2_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))+72], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-36] ,big2_color);
}
if (Hour()>=6 && Hour()<9)
{
draw_five("five_min_small", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-36], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-72] ,small_color);
draw_five("five_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-0], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-72] ,big_color);
draw_five("five2_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))+36], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-72] ,big2_color);
}
if (Hour()>=9 && Hour()<12)
{
draw_five("five_min_small", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-72], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-108] ,small_color);
draw_five("five_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-36], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-108] ,big_color);
draw_five("five2_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-0], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-108] ,big2_color);
}
if (Hour()>=12 && Hour()<15)
{
draw_five("five_min_small", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-108], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-144] ,small_color);
draw_five("five_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-72], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-144] ,big_color);
draw_five("five2_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-36], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-144] ,big2_color);
}
if (Hour()>=15 && Hour()<18)
{
draw_five("five_min_small", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-144], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-180] ,small_color);
draw_five("five_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-108], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-180] ,big_color);
draw_five("five2_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-72], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-180] ,big2_color);
}
if (Hour()>=18 && Hour()<21)
{
draw_five("five_min_small", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-180], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-216] ,small_color);
draw_five("five_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-144], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-216] ,big_color);
draw_five("five2_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-108], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-216] ,big2_color);
}
if (Hour()>=21)
{
draw_five("five_min_small", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-216], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-252] ,small_color);
draw_five("five_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-180], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-252] ,big_color);
draw_five("five2_min_big", Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-144], Time[iBarShift(Symbol(), PERIOD_M5, iTime(Symbol(),PERIOD_D1,0))-252] ,big2_color);
}

//for 1MIN.
if (Hour()<2)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+90], iTime(Symbol(),PERIOD_D1,0) ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+180], iTime(Symbol(),PERIOD_D1,0) ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+270], iTime(Symbol(),PERIOD_D1,0) ,big2_color);
}
if (Hour()>=2 && Hour()<3)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+0], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-90] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+90], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-90] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+180], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-90] ,big2_color);
}
if (Hour()>=3 && Hour()<5)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-90], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-180] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-0], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-180] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+90], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-180] ,big2_color);
}
if (Hour()>=5 && Hour()<6)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-180], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-270] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-90], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-270] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-0], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-270] ,big2_color);
}
if (Hour()>=6 && Hour()<8)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-270], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-360] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-180], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-360] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-90], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-360] ,big2_color);
}
if (Hour()>=8 && Hour()<9)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-360], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-450] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-270], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-450] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-180], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-450] ,big2_color);
}
if (Hour()>=9 && Hour()<11)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-450], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-540] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-360], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-540] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-270], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-540] ,big2_color);
}
if (Hour()>=11 && Hour()<12)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-540], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-630] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-450], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-630] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-360], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-630] ,big2_color);
}
if (Hour()>=12 && Hour()<14)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+630], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-720] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+540], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-720] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+450], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-720] ,big2_color);
}
if (Hour()>=14 && Hour()<15)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+720], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-810] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+630], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-810] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))+540], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-810] ,big2_color);
}
if (Hour()>=15 && Hour()<17)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-810], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-900] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-720], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-900] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-630], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-900] ,big2_color);
}
if (Hour()>=17 && Hour()<18)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-900], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-990] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-810], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-990] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-720], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-990] ,big2_color);
}
if (Hour()>=18 && Hour()<20)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-990], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1080] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-900], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1080] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-810], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1080] ,big2_color);
}
if (Hour()>=20 && Hour()<21)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1080], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1170] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-990], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1170] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-900], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1170] ,big2_color);
}
if (Hour()>=21 && Hour()<23)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1170], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1260] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1080], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1260] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-990], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1260] ,big2_color);
}
if (Hour()>=23)
{
draw_one("one_min_small", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1260], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1350] ,small_color);
draw_one("one_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1170], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1350] ,big_color);
draw_one("one2_min_big", Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1080], Time[iBarShift(Symbol(), PERIOD_M1, iTime(Symbol(),PERIOD_D1,0))-1350] ,big2_color);
}

//----
   return(0);
  }
  

//---------------------------------------------------------------------------------------------------------
void draw_one(string name,datetime T1,datetime T2,color Coloree)
    {
         ObjectCreate(name, OBJ_REGRESSION, 0,T1,0,T2,0);
         ObjectSet(name, OBJPROP_COLOR, Coloree);
         ObjectSet(name, OBJPROP_BACK, true);
          ObjectSet(name, OBJPROP_RAY, true);
          ObjectSet(name,OBJPROP_TIMEFRAMES, OBJ_PERIOD_M1);
    }  

void draw_five(string name,datetime T1,datetime T2,color Coloree)
    {
         ObjectCreate(name, OBJ_REGRESSION, 0,T1,0,T2,0);
         ObjectSet(name, OBJPROP_COLOR, Coloree);
         ObjectSet(name, OBJPROP_BACK, true);
          ObjectSet(name, OBJPROP_RAY, true);
          ObjectSet(name,OBJPROP_TIMEFRAMES, OBJ_PERIOD_M5);
    }  

void draw_quart(string name,datetime T1,datetime T2,color Coloree)
    {
         ObjectCreate(name, OBJ_REGRESSION, 0,T1,0,T2,0);
         ObjectSet(name, OBJPROP_COLOR, Coloree);
         ObjectSet(name, OBJPROP_BACK, true);
          ObjectSet(name, OBJPROP_RAY, true);
          ObjectSet(name,OBJPROP_TIMEFRAMES, OBJ_PERIOD_M15);
    }  

void draw_half(string name,datetime T1,datetime T2,color Coloree)
    {
         ObjectCreate(name, OBJ_REGRESSION, 0,T1,0,T2,0);
         ObjectSet(name, OBJPROP_COLOR, Coloree);
         ObjectSet(name, OBJPROP_BACK, true);
          ObjectSet(name, OBJPROP_RAY, true);
          ObjectSet(name,OBJPROP_TIMEFRAMES, OBJ_PERIOD_M30);
    }  

void draw_1(string name,datetime T1,datetime T2,color Coloree, int widthe)
    {
         ObjectCreate(name, OBJ_REGRESSION, 0,T1,0,T2,0);
         ObjectSet(name, OBJPROP_COLOR, Coloree);
         ObjectSet(name, OBJPROP_BACK, true);
          ObjectSet(name, OBJPROP_RAY, true);
          ObjectSet(name, OBJPROP_WIDTH, widthe);
          ObjectSet(name,OBJPROP_TIMEFRAMES, OBJ_PERIOD_H1);
    }  

void draw_4(string name,datetime T1,datetime T2,color Coloree, int widthe)
    {
         ObjectCreate(name, OBJ_REGRESSION, 0,T1,0,T2,0);
         ObjectSet(name, OBJPROP_COLOR, Coloree);
         ObjectSet(name, OBJPROP_BACK, true);
          ObjectSet(name, OBJPROP_RAY, true);
          ObjectSet(name, OBJPROP_WIDTH, widthe);
          ObjectSet(name,OBJPROP_TIMEFRAMES, OBJ_PERIOD_H4);
    }  

void draw_daily(string name,datetime T1,datetime T2,color Coloree, int widthe)
    {
         ObjectCreate(name, OBJ_REGRESSION, 0,T1,0,T2,0);
         ObjectSet(name, OBJPROP_COLOR, Coloree);
         ObjectSet(name, OBJPROP_BACK, true);
          ObjectSet(name, OBJPROP_RAY, true);
          ObjectSet(name, OBJPROP_WIDTH, widthe);
          ObjectSet(name,OBJPROP_TIMEFRAMES, OBJ_PERIOD_D1);
    }  
//+------------------------------------------------------------------+