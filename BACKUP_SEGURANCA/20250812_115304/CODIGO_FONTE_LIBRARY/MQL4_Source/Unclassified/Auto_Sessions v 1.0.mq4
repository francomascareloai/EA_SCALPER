//+------------------------------------------------------------------+
//|                                           Auto_Sessions_v1.0.mq4 |
//|                                        Copyright © 2010, cameofx |
//|                                                cameofx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, cameofx"
#property link      "cameofx@gmail.com"

#property indicator_chart_window
extern string _note      = "Enter sessions time with correct format" ;
extern string sAsiaBegin = "02:00";    
extern string sAsiaEnd   = "11:00";   

extern string sEurBegin  = "09:00";      
extern string sEurEnd    = "18:00";      

extern string sUSABegin  = "14:00";    
extern string sUSAEnd    = "23:00";     

extern color  AsiaColor  = C'0,32,0'; // C'5,55,6';    
extern color  EurColor   = C'48,0,0'; // C'5,35,56';   
extern color  USAColor   = C'0,0,56'; // C'65,5,46';   

static double Hi_USA, Hi_Eur, Hi_Asia ;
static double Lo_USA, Lo_Eur, Lo_Asia ; 
static datetime cur_Date, last_drawn_USA, last_drawn_Eur, last_drawn_Asia;
datetime t_Begin_Asia, t_End_Asia, t_Begin_Eur, t_End_Eur, t_Begin_USA, t_End_USA;
datetime t_TIME_BEGIN;

string sTIME_BEGIN = "1970.01.01" ;
//+------------------------------------------------------------------+
int init()
  {
   t_TIME_BEGIN = StrToTime(sTIME_BEGIN);   // the amount of seconds at beginning of MQL time = '0'
   
   t_Begin_Asia = StrToTime(StringConcatenate(sTIME_BEGIN," ",sAsiaBegin));  // unit of seconds of the session's start
   t_End_Asia   = StrToTime(StringConcatenate(sTIME_BEGIN," ",sAsiaEnd));    // unit of seconds of the session's end
   t_Begin_Eur  = StrToTime(StringConcatenate(sTIME_BEGIN," ",sEurBegin));   // we'll be using each of these to locate 
   t_End_Eur    = StrToTime(StringConcatenate(sTIME_BEGIN," ",sEurEnd));     // each date's beginning & end of sessions
   t_Begin_USA  = StrToTime(StringConcatenate(sTIME_BEGIN," ",sUSABegin));
   t_End_USA    = StrToTime(StringConcatenate(sTIME_BEGIN," ",sUSAEnd));
   
   last_drawn_USA  = t_TIME_BEGIN;  // initializing static memories with datetime '0'
   last_drawn_Eur  = t_TIME_BEGIN; 
   last_drawn_Asia = t_TIME_BEGIN; 
   cur_Date        = t_TIME_BEGIN;
   return(0);
  }
//+------------------------------------------------------------------+
datetime Strip_to_Date ( datetime a_Time )  // function to subtract Time[i] to the beginning of its day 
{                                           // discarding any amount of HH:MM:SS --> YYYY:MM:DD 00:00:00
   a_Time -= MathMod(a_Time,86400);         // 86400 is  24 * 60 * 60 (amount of seconds in one day)
   return(a_Time);                          // returns the date amount of seconds 
}
//+------------------------------------------------------------------+
//| Custom indicator iterations                                      |
//+------------------------------------------------------------------+
int start()
  {
      int i; 
      datetime Time_beg_Asia, Time_end_Asia;  // declaring/resetting the session border variables
      datetime Time_beg_Eur, Time_end_Eur;
      datetime Time_beg_USA, Time_end_USA;

      int counted_bars = IndicatorCounted();
      if(counted_bars< 0) return(-1);
      if(counted_bars> 0) counted_bars--;
   
      int limit = Bars - 1 - counted_bars ; 
      
      for(i=limit; i>=0; i--)
      {
         cur_Date = Strip_to_Date(Time[i]);       // strip current time until we have the date only
         
         Time_beg_Asia = cur_Date + t_Begin_Asia; // locate session's beginning & end by adding begin/end unit seconds to 
         Time_end_Asia = cur_Date + t_End_Asia;   // current stripped date seconds
  
         if(Time[i] >= Time_beg_Asia && Time[i] <= Time_end_Asia) // if current time is on Asia session
         {
            if(cur_Date > last_drawn_Asia){       // if it's more recent than last date saved
               last_drawn_Asia = cur_Date;        // save current stripped date as the last drawn date 
               Lo_Asia = Low[i];                  // to make sure during length of day we only create session objects once.
               Hi_Asia = High[i];                 // use High & Low as Upper & Lower Border

               create_("Asia_", cur_Date, t_Begin_Asia, Lo_Asia, t_End_Asia, Hi_Asia, AsiaColor ); // create it
            }
            if(Low[i] < Lo_Asia){                 // if current Low is lower than last Lo, save it as new Lo & redraw it
               Lo_Asia = Low[i]; 
               reDraw_("Asia_", cur_Date, Lo_Asia, Hi_Asia);
            }
            if(High[i] > Hi_Asia){                // if current High is greater than last Hi, save it as new Hi & redraw it
               Hi_Asia = High[i]; 
               reDraw_("Asia_", cur_Date, Lo_Asia, Hi_Asia);
            }
         }

         Time_beg_Eur = cur_Date + t_Begin_Eur;
         Time_end_Eur = cur_Date + t_End_Eur;

         if(Time[i] >= Time_beg_Eur && Time[i] <= Time_end_Eur) // do the same for Euro session
         {
            if(cur_Date > last_drawn_Eur){
               last_drawn_Eur = cur_Date;
               Lo_Eur = Low[i]; Hi_Eur = High[i];
               create_("Eur_", cur_Date, t_Begin_Eur, Lo_Eur, t_End_Eur, Hi_Eur, EurColor ); 
            }
            if(Low[i] < Lo_Eur){
               Lo_Eur = Low[i]; 
               reDraw_("Eur_", cur_Date, Lo_Eur, Hi_Eur);
            }
            if(High[i] > Hi_Eur){
               Hi_Eur = High[i]; 
               reDraw_("Eur_", cur_Date, Lo_Eur, Hi_Eur);
            }
         }

         Time_beg_USA = cur_Date + t_Begin_USA; 
         Time_end_USA = cur_Date + t_End_USA ; 

         if(Time[i] >= Time_beg_USA && Time[i] <= Time_end_USA) // ditto USA
         {
            if(cur_Date > last_drawn_USA){
               last_drawn_USA = cur_Date;
               Lo_USA = Low[i]; Hi_USA = High[i];
               create_("USA_", cur_Date, t_Begin_USA, Lo_USA, t_End_USA, Hi_USA, USAColor ); 
            }
            if(Low[i] < Lo_USA){
               Lo_USA = Low[i]; 
               reDraw_("USA_", cur_Date, Lo_USA, Hi_USA);
            }
            if(High[i] > Hi_USA){
               Hi_USA = High[i]; 
               reDraw_("USA_", cur_Date, Lo_USA, Hi_USA);
            }
         }
      }  
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   clear("USA_");   clear("Eur_");   clear("Asia_");
   return(0);
  }
//+------------------------------------------------------------------+
void clear(string prefix) {
int prefix_len = StringLen(prefix);
   for(int i=ObjectsTotal(); i>=0; i--)
   {      
     string name = ObjectName(i);
        if (StringSubstr(name,0,prefix_len) == prefix) ObjectDelete(name);
   }    
}
//+------------------------------------------------------------------+
void create_( string name, datetime cu_Date, datetime t1, double p1, datetime t2, double p2, color col )
{
   name = StringConcatenate(name, cu_Date);
   ObjectCreate(name, OBJ_RECTANGLE, 0, cu_Date + t1 , p1, cu_Date + t2 , p2);
   ObjectSet(name, OBJPROP_COLOR, col);
   ObjectSet(name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name, OBJPROP_BACK, True);
}
//+------------------------------------------------------------------+
void reDraw_(string name, datetime cu_Date, double price1, double price2)
{
   name = StringConcatenate(name, cu_Date);
   ObjectSet(name, OBJPROP_PRICE1, price1);
   ObjectSet(name, OBJPROP_PRICE2, price2);
}
//+------------------------------------------------------------------+