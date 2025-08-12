

#property indicator_chart_window

extern int GMTshift=3;
extern bool Show_Line_Labels = true;

extern string IIIIIIIIIIIIIIII="<<< Open Lines >>>>>"; 
extern int BUY_Area =25;
extern int SELL_Area = 25;
extern int BUY2_Area =55;
extern int SELL2_Area = 55;

#define Open_ "Open_"
#define BUY1 "BUY1"
#define SELL1 "SELL1"
#define BUY2 "BUY2"
#define SELL2 "SELL2"

extern color Open_Color = Red;
extern int Open_width = 1;
extern int Open_Line_Type = 0;

extern color BUY1_Color = Lime;
extern int BUY1_width = 1;
extern int BUY1_Line_Type = 0;

extern color SELL1_Color = Lime;
extern int SELL1_width = 1;
extern int SELL1_Line_Type = 0;

extern color BUY2_Color = CornflowerBlue;
extern int BUY2_width = 1;
extern int BUY2_Line_Type = 0;

extern color SELL2_Color = CornflowerBlue;
extern int SELL2_width = 1;
extern int SELL2_Line_Type = 0;


double P, S1, B1, S2, B2, S3, B3;

double day_high;
double day_low;
double yesterday_open;
double today_open;
double cur_day;
double prev_day;

double yesterday_high=0;
double yesterday_low=0;
double yesterday_close=0;
double tmp=0;
double Poin;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
IndicatorShortName("TARGET_LINES");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    ObjectsDeleteAll(0,OBJ_HLINE);
   ObjectDelete("Open_Label");
   ObjectDelete("Buy_Label_Open");ObjectDelete("Buy2_Label_Open");
   ObjectDelete("Sell_Label_Open");ObjectDelete("Sell2_Label_Open");
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    if (Point == 0.00001) Poin = 0.0001; 
   else if (Point == 0.001) Poin = 0.01; 
   else Poin = Point; 
   int counted_bars= IndicatorCounted(); 
 
//----
   CreatePVT();
 } 

void CreateLine(string Line, double start, double end,double w, double s,color clr)
  {
   ObjectCreate(Line, OBJ_HLINE, 0, iTime(NULL,1440,0)+GMTshift*3600, start, Time[0],w,s, end);
   ObjectSet(Line, OBJPROP_COLOR, clr);
   ObjectSet(Line,OBJPROP_RAY,TRUE);
   ObjectSet(Line,OBJPROP_WIDTH,w);
   ObjectSet(Line,OBJPROP_STYLE,s);
     }
        void DeleteLine()
   { 
  
  ObjectDelete(BUY1); ObjectDelete(SELL1);ObjectDelete(Open_);
  ObjectDelete(BUY2); ObjectDelete(SELL2);
   }
   void CreatePVT()
   {
    DeleteLine();
   double day_high=iHigh(NULL,1440,0);
   double day_low=iLow(NULL,1440,0);
   double yesterday_open=iOpen(NULL,1440,1);
   double today_open=iOpen(NULL,1440,0);
   
   double yesterday_high = iHigh(NULL,1440,1);
   double yesterday_low = iLow(NULL,1440,1);
   double yesterday_close = iClose(NULL,1440,1);
   
   cur_day=0;
   prev_day=0;
   
   int cnt=720;

   while (cnt!= 0)
   {
	  if (TimeDayOfWeek(Time[cnt]) == 0)
	  {
        cur_day = prev_day;
	  }
	  else
	  {
        cur_day = TimeDay(Time[cnt]-(GMTshift*3600));
	  }
	
  	  if (prev_day != cur_day)
	  {
		 yesterday_close = Close[cnt+1];
		 today_open = Open[cnt];
		 yesterday_high = iHigh(NULL,1440,1);
		 yesterday_low = iLow(NULL,1440,1);

		 day_high = High[cnt];
		 day_low  = Low[cnt];

		 prev_day = cur_day;
	  }
   
     if (High[cnt]>day_high)
     {
       day_high = High[cnt];
     }
   
     if (Low[cnt]<day_low)
     {
       day_low = Low[cnt];
     }
	
	  cnt--;

  }  
   
    double O = iClose(NULL,1440,1);
   
	 
	 double	B1O = yesterday_close + BUY_Area* Poin; 
	 double	S1O = yesterday_close - SELL_Area * Poin; 
	 double	B2O = yesterday_close + BUY2_Area* Poin; 
	 double	S2O = yesterday_close - SELL2_Area * Poin; 
	 
	 CreateLine(Open_,today_open,today_open,Open_width,Open_Line_Type,Open_Color);
	  
	      CreateLine(BUY1,B1O,B1O,BUY1_width,BUY1_Line_Type,BUY1_Color );
         CreateLine(SELL1,S1O,S1O,SELL1_width,SELL1_Line_Type, SELL1_Color );
         CreateLine(BUY2,B2O,B2O,BUY2_width,BUY2_Line_Type,BUY2_Color );
         CreateLine(SELL2,S2O,S2O,SELL2_width,SELL2_Line_Type, SELL2_Color );
        
        
        if(Show_Line_Labels==true){ 
  
         //Open
        ObjectDelete("Close_Label");
      if(ObjectFind("Close_Label") != 0)
    {  ObjectCreate("Close_Label", OBJ_TEXT, 0, Time[0], today_open);
       ObjectSetText("Close_Label", "                                         Stop Loss: "+ DoubleToStr(today_open,Digits)+"", 8, "Arial",Open_Color);
      } else{ ObjectMove("Close_Label", 0, Time[0], today_open); }
        //Open labels
         ObjectDelete("Buy_Label_Open");
      if(ObjectFind("Buy_Label_Open") != 0)
    {  ObjectCreate("Buy_Label_Open", OBJ_TEXT, 0, Time[0], B1O);
       ObjectSetText("Buy_Label_Open", "                                          BuyLine: "+ DoubleToStr(B1O,Digits)+"", 8, "Arial",BUY1_Color);
      } else{ ObjectMove("Buy_Label_Open", 0, Time[0], B1O); }
    
        ObjectDelete("Buy2_Label_Open");
      if(ObjectFind("Buy2_Label_Open") != 0)
    {  ObjectCreate("Buy2_Label_Open", OBJ_TEXT, 0, Time[0], B2O);
       ObjectSetText("Buy2_Label_Open", "                                          Buy TP: "+ DoubleToStr(B2O,Digits)+"", 8, "Arial",BUY2_Color);
      } else{ ObjectMove("Buy2_Label_Open", 0, Time[0], B2O); }
      
	       ObjectDelete("Sell_Label_Open");
      if(ObjectFind("Sell_Label_Open") != 0)
    {  ObjectCreate("Sell_Label_Open", OBJ_TEXT, 0, Time[0], S1O);
       ObjectSetText("Sell_Label_Open", "                                       Sell Line: "+ DoubleToStr(S1O,Digits)+"", 8, "Arial",SELL1_Color);
      } else{ ObjectMove("Sell_Label_Open", 0, Time[0], S1O); }
    
        ObjectDelete("Sell2_Label_Open");
      if(ObjectFind("Sell2_Label_Open") != 0)
    {  ObjectCreate("Sell2_Label_Open", OBJ_TEXT, 0, Time[0], S2O);
       ObjectSetText("Sell2_Label_Open", "                                         Sell TP: "+ DoubleToStr(S2O,Digits)+"", 8, "Arial",SELL2_Color);
      } else{ ObjectMove("Sell2_Label_Open", 0, Time[0], S2O); }
      }		
   
//----
   return;
  }
//+------------------------------------------------------------------+