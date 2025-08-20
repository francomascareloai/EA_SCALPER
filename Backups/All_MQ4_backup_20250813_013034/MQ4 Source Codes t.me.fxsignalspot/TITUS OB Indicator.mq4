//+------------------------------------------------------------------+
//|                                      shved_supply_and_demand.mq4 |
//+------------------------------------------------------------------+

#define ForEach(index, array) for (int index = 0,                    \
   max_##index=ArraySize((array));                                   \
   index<max_##index; index++)    
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   string array[]={"12","23","34","45"};
//--- bypass the array using ForEach
   ForEach(i,array)
     {
      PrintFormat("%d: array[%d]=%s",i,i,array[i]);
     }
  
* Output result  
   0: array[0]=12
   1: array[1]=23
   2: array[2]=34
   3: array[3]=45
study('Jayce_Liquility', overlay=true)
Maru_rate = input(0.1,"Maru rate(%)", input.float) // 50
Compare = input(0,"Maru 3 - 1 (%)", input.float) // 10
MA = input(1,"Big candle period",input.integer) // 9
urgent_rate = input(1,"Maru compare sma", input.float)
// Deviation high - low
Up = close > open ? -open+close : 0
Down = close < open ? open-close : 0
UP_Sum = sma(Up,MA)
Do_Sum = sma(Down,MA)
Check_Up_Urgent = close > open and high - low > urgent_rate*UP_Sum ? 1 : 0
Check_Dow_Urgent = close < open and high - low > urgent_rate*Do_Sum ? 1 : 0
// Up_Liquid
Maru_up = close > open and close - open >= Maru_rate*(high - low)/100 ? 1 : 0 // Define maru Up
Maru3_Maru1 = Maru_up == 1 ? (high - low)[1]/ (high-low)[2] >= Compare/100 ? 1 : 0 : 0 // Define maru 3 and 1 same 80%
M3_H_M1 =Maru3_Maru1 == 1 ? high[2] < low ? 1 : 0 : 0 // and low[2] < low : 0 // Define contious maru
conti = close[2] > open[2] and close[1]> open[1] ? 1 : 0
Up_liqi = M3_H_M1 == 1 and conti == 1
barcolor(Up_liqi == 1 and Check_Up_Urgent ==1 ? #00FF00 : na)
barcolor(Up_liqi == 1 and Check_Up_Urgent ==1 ? #00FF00 : na, offset = -1;)
barcolor(Up_liqi == 1 and Check_Up_Urgent ==1 ? #00FF00 : na, offset = -2)
// Marubozu nen 1 nen 2 tuong dong 80 . High low cua 3 cay nen tach roi nhau ro rang.
// Down_liquid
Maru_down = close < open and abs(close - open) >= Maru_rate*(high - low)/100 ? 1 : 0 // Define maru Up
Maru3_Maru1_down = Maru_down == 1 ? (high - low)/ (high-low)[2] >= Compare/100 ? 1 : 0 : 0 // Define maru 3 and 1 same 80%
M3_H_M1_down =Maru3_Maru1_down == 1 ? low[2] > high ? 1 : 0 : 0 // Define contious maru
conti_down = close[2] < open[2] and close[1] < open[1] ? 1 : 0
Down_liquid = M3_H_M1_down == 1 and conti_down == 1
barcolor(Down_liquid == 1 and Check_Dow_Urgent ==1 ? color.yellow : na)
barcolor(Down_liquid == 1 and Check_Dow_Urgent ==1 ? color.yellow : na, offset = -1)
barcolor(Down_liquid == 1 and Check_Dow_Urgent ==1 ? color.yellow : na, offset = -2)

eturn(0)}
}

// ------------------------------------END-----------------------------------------}