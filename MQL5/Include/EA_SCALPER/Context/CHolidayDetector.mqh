//+------------------------------------------------------------------+
//|                                            CHolidayDetector.mqh |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - Holiday Detection     |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Holiday Types                                                     |
//+------------------------------------------------------------------+
enum ENUM_HOLIDAY_TYPE
{
   HOLIDAY_NONE = 0,
   HOLIDAY_US = 1,           // US Market Holiday
   HOLIDAY_UK = 2,           // UK Market Holiday
   HOLIDAY_US_UK = 3,        // Both US and UK
   HOLIDAY_PARTIAL = 4       // Partial/Early Close
};

//+------------------------------------------------------------------+
//| Holiday Info Structure                                            |
//+------------------------------------------------------------------+
struct SHolidayInfo
{
   bool              is_holiday;
   ENUM_HOLIDAY_TYPE type;
   string            name;
   bool              reduced_liquidity;
   double            size_multiplier;    // Reduce size on holidays
   
   void Reset()
   {
      is_holiday = false;
      type = HOLIDAY_NONE;
      name = "";
      reduced_liquidity = false;
      size_multiplier = 1.0;
   }
};

//+------------------------------------------------------------------+
//| Class: CHolidayDetector                                           |
//| Purpose: Detect US/UK market holidays that affect Gold liquidity  |
//+------------------------------------------------------------------+
class CHolidayDetector
{
private:
   //--- US Holidays (affect gold trading significantly)
   datetime          m_us_holidays[];
   string            m_us_holiday_names[];
   
   //--- UK Holidays
   datetime          m_uk_holidays[];
   string            m_uk_holiday_names[];
   
   //--- Current year holidays loaded
   int               m_loaded_year;
   
   //--- Configuration
   double            m_holiday_size_mult;    // Size multiplier on full holiday
   double            m_partial_size_mult;    // Size multiplier on partial holiday
   
public:
                     CHolidayDetector();
                    ~CHolidayDetector();
   
   //--- Initialization
   bool              Init(int year = 0);
   
   //--- Main Methods
   SHolidayInfo      CheckHoliday(datetime check_time = 0);
   bool              IsHoliday(datetime check_time = 0);
   bool              IsReducedLiquidity(datetime check_time = 0);
   double            GetSizeMultiplier(datetime check_time = 0);
   
   //--- Utility
   string            GetHolidayName(datetime check_time = 0);
   void              PrintHolidays();
   
private:
   void              LoadUSHolidays(int year);
   void              LoadUKHolidays(int year);
   datetime          CalculateEaster(int year);
   datetime          GetNthWeekdayOfMonth(int year, int month, int weekday, int n);
   datetime          GetLastWeekdayOfMonth(int year, int month, int weekday);
   bool              IsDateInArray(datetime date, datetime &arr[]);
   int               GetIndexInArray(datetime date, datetime &arr[]);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CHolidayDetector::CHolidayDetector()
{
   m_loaded_year = 0;
   m_holiday_size_mult = 0.5;   // 50% size on full holiday
   m_partial_size_mult = 0.75;  // 75% size on partial
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CHolidayDetector::~CHolidayDetector()
{
   ArrayFree(m_us_holidays);
   ArrayFree(m_us_holiday_names);
   ArrayFree(m_uk_holidays);
   ArrayFree(m_uk_holiday_names);
}

//+------------------------------------------------------------------+
//| Initialize with specific year                                     |
//+------------------------------------------------------------------+
bool CHolidayDetector::Init(int year = 0)
{
   if(year == 0)
   {
      MqlDateTime dt;
      TimeToStruct(TimeGMT(), dt);
      year = dt.year;
   }
   
   LoadUSHolidays(year);
   LoadUKHolidays(year);
   
   // Also load next year if we're in Q4
   MqlDateTime current_dt;
   TimeToStruct(TimeGMT(), current_dt);
   if(current_dt.mon >= 10)
   {
      LoadUSHolidays(year + 1);
      LoadUKHolidays(year + 1);
   }
   
   m_loaded_year = year;
   
   Print("CHolidayDetector: Initialized with ", ArraySize(m_us_holidays), 
         " US and ", ArraySize(m_uk_holidays), " UK holidays");
   
   return true;
}

//+------------------------------------------------------------------+
//| Load US Market Holidays                                           |
//+------------------------------------------------------------------+
void CHolidayDetector::LoadUSHolidays(int year)
{
   int current_count = ArraySize(m_us_holidays);
   
   // 10 major US holidays that affect markets
   ArrayResize(m_us_holidays, current_count + 10);
   ArrayResize(m_us_holiday_names, current_count + 10);
   
   // 1. New Year's Day (Jan 1, or observed)
   datetime new_year = StringToTime(IntegerToString(year) + ".01.01");
   MqlDateTime nyd;
   TimeToStruct(new_year, nyd);
   if(nyd.day_of_week == 0) new_year += 86400;       // Sunday -> Monday
   else if(nyd.day_of_week == 6) new_year -= 86400;  // Saturday -> Friday
   m_us_holidays[current_count + 0] = new_year;
   m_us_holiday_names[current_count + 0] = "New Year's Day";
   
   // 2. MLK Day (3rd Monday of January)
   m_us_holidays[current_count + 1] = GetNthWeekdayOfMonth(year, 1, 1, 3);
   m_us_holiday_names[current_count + 1] = "Martin Luther King Jr. Day";
   
   // 3. Presidents Day (3rd Monday of February)
   m_us_holidays[current_count + 2] = GetNthWeekdayOfMonth(year, 2, 1, 3);
   m_us_holiday_names[current_count + 2] = "Presidents Day";
   
   // 4. Good Friday (Friday before Easter)
   datetime easter = CalculateEaster(year);
   m_us_holidays[current_count + 3] = easter - 2 * 86400;  // -2 days
   m_us_holiday_names[current_count + 3] = "Good Friday";
   
   // 5. Memorial Day (Last Monday of May)
   m_us_holidays[current_count + 4] = GetLastWeekdayOfMonth(year, 5, 1);
   m_us_holiday_names[current_count + 4] = "Memorial Day";
   
   // 6. Juneteenth (June 19)
   datetime juneteenth = StringToTime(IntegerToString(year) + ".06.19");
   MqlDateTime jt;
   TimeToStruct(juneteenth, jt);
   if(jt.day_of_week == 0) juneteenth += 86400;
   else if(jt.day_of_week == 6) juneteenth -= 86400;
   m_us_holidays[current_count + 5] = juneteenth;
   m_us_holiday_names[current_count + 5] = "Juneteenth";
   
   // 7. Independence Day (July 4)
   datetime july4 = StringToTime(IntegerToString(year) + ".07.04");
   MqlDateTime j4;
   TimeToStruct(july4, j4);
   if(j4.day_of_week == 0) july4 += 86400;
   else if(j4.day_of_week == 6) july4 -= 86400;
   m_us_holidays[current_count + 6] = july4;
   m_us_holiday_names[current_count + 6] = "Independence Day";
   
   // 8. Labor Day (1st Monday of September)
   m_us_holidays[current_count + 7] = GetNthWeekdayOfMonth(year, 9, 1, 1);
   m_us_holiday_names[current_count + 7] = "Labor Day";
   
   // 9. Thanksgiving (4th Thursday of November)
   m_us_holidays[current_count + 8] = GetNthWeekdayOfMonth(year, 11, 4, 4);
   m_us_holiday_names[current_count + 8] = "Thanksgiving";
   
   // 10. Christmas (Dec 25)
   datetime christmas = StringToTime(IntegerToString(year) + ".12.25");
   MqlDateTime xmas;
   TimeToStruct(christmas, xmas);
   if(xmas.day_of_week == 0) christmas += 86400;
   else if(xmas.day_of_week == 6) christmas -= 86400;
   m_us_holidays[current_count + 9] = christmas;
   m_us_holiday_names[current_count + 9] = "Christmas Day";
}

//+------------------------------------------------------------------+
//| Load UK Bank Holidays                                             |
//+------------------------------------------------------------------+
void CHolidayDetector::LoadUKHolidays(int year)
{
   int current_count = ArraySize(m_uk_holidays);
   
   // 8 major UK bank holidays
   ArrayResize(m_uk_holidays, current_count + 8);
   ArrayResize(m_uk_holiday_names, current_count + 8);
   
   // 1. New Year's Day
   datetime new_year = StringToTime(IntegerToString(year) + ".01.01");
   MqlDateTime nyd;
   TimeToStruct(new_year, nyd);
   if(nyd.day_of_week == 0) new_year += 86400;
   else if(nyd.day_of_week == 6) new_year += 2 * 86400;  // Saturday -> Monday
   m_uk_holidays[current_count + 0] = new_year;
   m_uk_holiday_names[current_count + 0] = "New Year's Day (UK)";
   
   // 2. Good Friday
   datetime easter = CalculateEaster(year);
   m_uk_holidays[current_count + 1] = easter - 2 * 86400;
   m_uk_holiday_names[current_count + 1] = "Good Friday (UK)";
   
   // 3. Easter Monday
   m_uk_holidays[current_count + 2] = easter + 86400;
   m_uk_holiday_names[current_count + 2] = "Easter Monday (UK)";
   
   // 4. Early May Bank Holiday (1st Monday of May)
   m_uk_holidays[current_count + 3] = GetNthWeekdayOfMonth(year, 5, 1, 1);
   m_uk_holiday_names[current_count + 3] = "Early May Bank Holiday";
   
   // 5. Spring Bank Holiday (Last Monday of May)
   m_uk_holidays[current_count + 4] = GetLastWeekdayOfMonth(year, 5, 1);
   m_uk_holiday_names[current_count + 4] = "Spring Bank Holiday";
   
   // 6. Summer Bank Holiday (Last Monday of August)
   m_uk_holidays[current_count + 5] = GetLastWeekdayOfMonth(year, 8, 1);
   m_uk_holiday_names[current_count + 5] = "Summer Bank Holiday";
   
   // 7. Christmas Day
   datetime christmas = StringToTime(IntegerToString(year) + ".12.25");
   MqlDateTime xmas;
   TimeToStruct(christmas, xmas);
   if(xmas.day_of_week == 0) christmas += 86400;
   else if(xmas.day_of_week == 6) christmas += 2 * 86400;
   m_uk_holidays[current_count + 6] = christmas;
   m_uk_holiday_names[current_count + 6] = "Christmas Day (UK)";
   
   // 8. Boxing Day (Dec 26)
   datetime boxing = StringToTime(IntegerToString(year) + ".12.26");
   MqlDateTime box;
   TimeToStruct(boxing, box);
   if(box.day_of_week == 0) boxing += 2 * 86400;  // Sunday -> Tuesday
   else if(box.day_of_week == 6) boxing += 2 * 86400;  // Saturday -> Monday
   m_uk_holidays[current_count + 7] = boxing;
   m_uk_holiday_names[current_count + 7] = "Boxing Day (UK)";
}

//+------------------------------------------------------------------+
//| Calculate Easter Sunday date (Anonymous Gregorian algorithm)      |
//+------------------------------------------------------------------+
datetime CHolidayDetector::CalculateEaster(int year)
{
   int a = year % 19;
   int b = year / 100;
   int c = year % 100;
   int d = b / 4;
   int e = b % 4;
   int f = (b + 8) / 25;
   int g = (b - f + 1) / 3;
   int h = (19 * a + b - d - g + 15) % 30;
   int i = c / 4;
   int k = c % 4;
   int l = (32 + 2 * e + 2 * i - h - k) % 7;
   int m = (a + 11 * h + 22 * l) / 451;
   int month = (h + l - 7 * m + 114) / 31;
   int day = ((h + l - 7 * m + 114) % 31) + 1;
   
   string date_str = IntegerToString(year) + "." + 
                     (month < 10 ? "0" : "") + IntegerToString(month) + "." +
                     (day < 10 ? "0" : "") + IntegerToString(day);
   
   return StringToTime(date_str);
}

//+------------------------------------------------------------------+
//| Get the Nth weekday of a month (e.g., 3rd Monday)                 |
//+------------------------------------------------------------------+
datetime CHolidayDetector::GetNthWeekdayOfMonth(int year, int month, int weekday, int n)
{
   // weekday: 0=Sunday, 1=Monday, ..., 6=Saturday
   string date_str = IntegerToString(year) + "." + 
                     (month < 10 ? "0" : "") + IntegerToString(month) + ".01";
   datetime first_day = StringToTime(date_str);
   
   MqlDateTime dt;
   TimeToStruct(first_day, dt);
   
   // Find first occurrence of weekday
   int days_to_add = (weekday - dt.day_of_week + 7) % 7;
   datetime first_weekday = first_day + days_to_add * 86400;
   
   // Add weeks to get Nth occurrence
   return first_weekday + (n - 1) * 7 * 86400;
}

//+------------------------------------------------------------------+
//| Get the last weekday of a month                                   |
//+------------------------------------------------------------------+
datetime CHolidayDetector::GetLastWeekdayOfMonth(int year, int month, int weekday)
{
   // Start from first day of next month and go back
   int next_month = month + 1;
   int next_year = year;
   if(next_month > 12)
   {
      next_month = 1;
      next_year++;
   }
   
   string date_str = IntegerToString(next_year) + "." + 
                     (next_month < 10 ? "0" : "") + IntegerToString(next_month) + ".01";
   datetime first_of_next = StringToTime(date_str);
   datetime last_of_month = first_of_next - 86400;
   
   MqlDateTime dt;
   TimeToStruct(last_of_month, dt);
   
   int days_to_subtract = (dt.day_of_week - weekday + 7) % 7;
   return last_of_month - days_to_subtract * 86400;
}

//+------------------------------------------------------------------+
//| Check if date is in array                                         |
//+------------------------------------------------------------------+
bool CHolidayDetector::IsDateInArray(datetime date, datetime &arr[])
{
   // Compare only date part (ignore time)
   MqlDateTime check_dt;
   TimeToStruct(date, check_dt);
   datetime check_date = StringToTime(IntegerToString(check_dt.year) + "." +
                                       IntegerToString(check_dt.mon) + "." +
                                       IntegerToString(check_dt.day));
   
   for(int i = 0; i < ArraySize(arr); i++)
   {
      MqlDateTime arr_dt;
      TimeToStruct(arr[i], arr_dt);
      datetime arr_date = StringToTime(IntegerToString(arr_dt.year) + "." +
                                        IntegerToString(arr_dt.mon) + "." +
                                        IntegerToString(arr_dt.day));
      
      if(check_date == arr_date)
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Get index of date in array                                        |
//+------------------------------------------------------------------+
int CHolidayDetector::GetIndexInArray(datetime date, datetime &arr[])
{
   MqlDateTime check_dt;
   TimeToStruct(date, check_dt);
   datetime check_date = StringToTime(IntegerToString(check_dt.year) + "." +
                                       IntegerToString(check_dt.mon) + "." +
                                       IntegerToString(check_dt.day));
   
   for(int i = 0; i < ArraySize(arr); i++)
   {
      MqlDateTime arr_dt;
      TimeToStruct(arr[i], arr_dt);
      datetime arr_date = StringToTime(IntegerToString(arr_dt.year) + "." +
                                        IntegerToString(arr_dt.mon) + "." +
                                        IntegerToString(arr_dt.day));
      
      if(check_date == arr_date)
         return i;
   }
   
   return -1;
}

//+------------------------------------------------------------------+
//| Check if a date is a holiday                                      |
//+------------------------------------------------------------------+
SHolidayInfo CHolidayDetector::CheckHoliday(datetime check_time = 0)
{
   SHolidayInfo info;
   info.Reset();
   
   if(check_time == 0)
      check_time = TimeGMT();
   
   // Ensure we have holidays loaded for this year
   MqlDateTime dt;
   TimeToStruct(check_time, dt);
   if(dt.year != m_loaded_year && dt.year != m_loaded_year + 1)
      Init(dt.year);
   
   bool is_us = IsDateInArray(check_time, m_us_holidays);
   bool is_uk = IsDateInArray(check_time, m_uk_holidays);
   
   if(is_us && is_uk)
   {
      info.is_holiday = true;
      info.type = HOLIDAY_US_UK;
      info.reduced_liquidity = true;
      info.size_multiplier = m_holiday_size_mult * 0.5;  // Very low liquidity
      
      int idx = GetIndexInArray(check_time, m_us_holidays);
      if(idx >= 0)
         info.name = m_us_holiday_names[idx] + " & UK Holiday";
   }
   else if(is_us)
   {
      info.is_holiday = true;
      info.type = HOLIDAY_US;
      info.reduced_liquidity = true;
      info.size_multiplier = m_holiday_size_mult;
      
      int idx = GetIndexInArray(check_time, m_us_holidays);
      if(idx >= 0)
         info.name = m_us_holiday_names[idx];
   }
   else if(is_uk)
   {
      info.is_holiday = true;
      info.type = HOLIDAY_UK;
      info.reduced_liquidity = true;
      info.size_multiplier = m_partial_size_mult;  // Less impact than US
      
      int idx = GetIndexInArray(check_time, m_uk_holidays);
      if(idx >= 0)
         info.name = m_uk_holiday_names[idx];
   }
   
   // Check for day before/after major holidays (also reduced liquidity)
   if(!info.is_holiday)
   {
      datetime yesterday = check_time - 86400;
      datetime tomorrow = check_time + 86400;
      
      bool us_adjacent = IsDateInArray(yesterday, m_us_holidays) || 
                         IsDateInArray(tomorrow, m_us_holidays);
      
      if(us_adjacent)
      {
         info.type = HOLIDAY_PARTIAL;
         info.reduced_liquidity = true;
         info.size_multiplier = m_partial_size_mult;
         info.name = "Adjacent to US Holiday";
      }
   }
   
   return info;
}

//+------------------------------------------------------------------+
//| Simple check if today is a holiday                                |
//+------------------------------------------------------------------+
bool CHolidayDetector::IsHoliday(datetime check_time = 0)
{
   return CheckHoliday(check_time).is_holiday;
}

//+------------------------------------------------------------------+
//| Check if there's reduced liquidity                                |
//+------------------------------------------------------------------+
bool CHolidayDetector::IsReducedLiquidity(datetime check_time = 0)
{
   return CheckHoliday(check_time).reduced_liquidity;
}

//+------------------------------------------------------------------+
//| Get position size multiplier                                      |
//+------------------------------------------------------------------+
double CHolidayDetector::GetSizeMultiplier(datetime check_time = 0)
{
   return CheckHoliday(check_time).size_multiplier;
}

//+------------------------------------------------------------------+
//| Get holiday name                                                  |
//+------------------------------------------------------------------+
string CHolidayDetector::GetHolidayName(datetime check_time = 0)
{
   return CheckHoliday(check_time).name;
}

//+------------------------------------------------------------------+
//| Print all loaded holidays                                         |
//+------------------------------------------------------------------+
void CHolidayDetector::PrintHolidays()
{
   Print("=== US Holidays ===");
   for(int i = 0; i < ArraySize(m_us_holidays); i++)
   {
      Print(TimeToString(m_us_holidays[i], TIME_DATE), " - ", m_us_holiday_names[i]);
   }
   
   Print("=== UK Holidays ===");
   for(int i = 0; i < ArraySize(m_uk_holidays); i++)
   {
      Print(TimeToString(m_uk_holidays[i], TIME_DATE), " - ", m_uk_holiday_names[i]);
   }
}

//+------------------------------------------------------------------+
