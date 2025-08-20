

//double Range = 0;
//Range = (period_High - period_Low) * Point


//+------------------------------------------------------------------+
//|                                                        Lines_HiLo.mq4 |
//|                      
//|                                      
//+------------------------------------------------------------------+
#property copyright "TradeForex or anyone who is willing to improve this indicator, willing to develop a working Cash Cow EA - Is it already there?"
#property link      ""

#property indicator_chart_window


//extern int Lookback_Period = 4;


extern bool ViewComment = true;
double period_Low=0;
double period_High=0;
double Todays_High = 0;
double Todays_Low =  0;

double Yester_High_Line=0;
double Yester_Low_Line=0;
double Yesters_High=0;
double Yesters_Low=0;

double Todays_High_Line=0;
double Todays_Low_Line=0;
double Today_High_=0;
double Today_Low=0;

//double Range = 0;


double Yesterdays_Range = 0;
double Todays_Range = 0;





//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{

   
}


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   ObjectDelete("Yesters_High Label"); 
   ObjectDelete("Yesters_High  Line");
   ObjectDelete("Yesters_Low Label");
   ObjectDelete("Yesters_Low Line");
   ObjectDelete("Today_High Label"); 
   ObjectDelete("Today_High  Line");
   ObjectDelete("Today_Low Label");
   ObjectDelete("Today_Low Line");
   
   
   
   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
     
         period_High =High[Highest(NULL,0,MODE_HIGH,1,1)];
         period_Low =Low[Lowest(NULL,0,MODE_LOW,1,1)];
              
         Todays_High = iHigh(NULL,0,0);
         Todays_Low = iLow(NULL,0,0);
         Yester_High_Line =  (period_High + 0.0030);
         Yester_Low_Line =  (period_Low - 0.0030  );
         Yesterdays_Range = (period_High - period_Low)/Point ;
         Todays_Range = (Todays_High - Todays_Low)/Point;
        
         
        Todays_High_Line =  (Todays_Low + 0.0070 );
        Todays_Low_Line =  (Todays_High - 0.0070 );
   
   if (ViewComment==true){

   Comment("Yesterdays Range = ",    Yesterdays_Range  ,", ", "Todays Range = ",Todays_Range,",  ", "TRADE IF YESTRERDAY'S RANGE > 140");
   //Comment ("Buy at Higher of = ",    Todays_High  ,"or  ", Todays_Low);
      }

 
   {
      SetLevel("Buy at  cross of Higher Green", Yester_High_Line, Green); //Green
      SetLevel("Sell at break of lower Red", Yester_Low_Line, Red); //Red
     SetLevel("Buy at cross of Higher  Green", Todays_High_Line, Green); //Green
    SetLevel("Sell at cross of lower  Red", Todays_Low_Line, Red); //Red
        
      
   
   }

  
   return(0);
}


//+------------------------------------------------------------------+
//| Helper                                                           |
//+------------------------------------------------------------------+
void SetLevel(string text, double level, color col1)
{
   string labelname= text + " Label";
   string linename= text + " Line";

   if (ObjectFind(labelname) != 0) {
      ObjectCreate(labelname, OBJ_TEXT, 0, Time[5], level);
      ObjectSetText(labelname, " " + text, 8, "Arial", White);
   }
   else {
      ObjectMove(labelname, 0, Time[5], level);
   }
   
   if (ObjectFind(linename) != 0) {
      ObjectCreate(linename, OBJ_HLINE, 0, Time[20], level);
      ObjectSet(linename, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(linename, OBJPROP_WIDTH, 2);
      ObjectSet(linename, OBJPROP_COLOR, col1);
      
      }
   else {
      ObjectMove(linename, 0, Time[20], level);
      
   }
}
      

