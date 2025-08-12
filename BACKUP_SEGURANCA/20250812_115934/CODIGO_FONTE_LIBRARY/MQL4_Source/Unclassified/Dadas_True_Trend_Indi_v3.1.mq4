//+------------------------------------------------------------------+
//|                                   Dadas_True_Trend_Indi_v3.1.mq4 |
//|                                            Copyright 2014, Dadas |
//|                                   http://www.fx-nvatc.comeze.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Dadas"
#property link      "http://www.fx-nvatc.comeze.com"

#property indicator_chart_window

extern bool Show_Indi = true;
extern int Tf = 60;
extern int Begin_Bar = 0;
extern color ColorUp     = Blue;
extern color ColorDown     = Red;
extern color ColorNeutral = DarkKhaki;
extern bool Back = true;
extern int Width = 2;
extern bool Show_Extensions = true;
extern int ExtWidth = 1;
extern int ExtStyle = 2;
extern int Offset = 2;

int i,Prev_Bar;
color Color,PrevColor;




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
if(Tf==0) Tf=Period();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
if(Tf==0) Tf=Period();

for (i=0; i<=Bars; i++) 
    {
ObjectDelete(Tf+"High_Arrow"+i); 
ObjectDelete(Tf+"Low_Arrow"+i);
ObjectDelete(Tf+"ExtHigh_Arrow"+i); 
ObjectDelete(Tf+"ExtLow_Arrow"+i);
    }  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  if(IsNewBar())
   {  
  if(Show_Indi&&Period()<Tf)
    {
//----    

   for (i=Begin_Bar; i<=Bars; i++) 
    {
ObjectDelete(Tf+"High_Arrow"+i); 
ObjectDelete(Tf+"Low_Arrow"+i);
ObjectDelete(Tf+"ExtHigh_Arrow"+i); 
ObjectDelete(Tf+"ExtLow_Arrow"+i);


// iBar2 = iHighest( NULL, 0, MODE_HIGH, iNumber, iBarShift(NULL, 0, Time0 - 1) );  //highest in previous Fixed_Trend_Tf_Follow
// iBar1 = iHighest( NULL, 0, MODE_HIGH, iNumber, iBarShift(NULL, 0, Time2 - 1) );    //highest in pre-previous Fixed_Trend_Tf_Follow
// you need to find a bar on M1 which has the highest or lowest value
// iHighest and iLowest will do that
// let me find what are their params
// k:- iNumber - number of bars to review starting from the last parameter
// iNumber = MasterTf/CurrentTf
// oh, Time2 or Time0 - it's the time of the bar on MasterTF where you have extremum
// so, the algo is:
// 1) find extremum(s) on master tf
// 2) find the time of that bar
// 3) go on M1 and find a bar/value starting from iBarShift(.....) for next iNumber bars
// -1 is for shifting one bar from beginning of a period 
    datetime time1 = iTime(NULL,Tf,i);
    datetime time2 = iTime(NULL,Tf,i+1);
    int iBarLowest1 = iLowest( NULL, 0, MODE_LOW, Tf/Period()+1, iBarShift(NULL, 0, time1) );  //lowest in previous Fixed_Trend_Tf_Follow
    int iBarLowest2 = iLowest( NULL, 0, MODE_LOW, Tf/Period()+1, iBarShift(NULL, 0, time2) );    //lowest in pre-previous Fixed_Trend_Tf_Follow
    double price_lowest1 = iLow(NULL,0,iBarLowest1);    
    double price_lowest2 = iLow(NULL,0,iBarLowest2);
    datetime time_lowest1 = iTime(NULL,0,iBarLowest1);
    datetime time_lowest2 = iTime(NULL,0,iBarLowest2);    
    int iBarHighest1 = iHighest( NULL, 0, MODE_HIGH, Tf/Period()+1, iBarShift(NULL, 0, time1) );  //highest in previous Fixed_Trend_Tf_Follow
    int iBarHighest2 = iHighest( NULL, 0, MODE_HIGH, Tf/Period()+1, iBarShift(NULL, 0, time2) );    //highest in pre-previous Fixed_Trend_Tf_Follow
    double price_highest1 = iHigh(NULL,0,iBarHighest1);    
    double price_highest2 = iHigh(NULL,0,iBarHighest2); 
    datetime time_highest1 = iTime(NULL,0,iBarHighest1);
    datetime time_highest2 = iTime(NULL,0,iBarHighest2);  
    datetime time3 = iTime(NULL,Tf,i)+Offset*Tf*60;  
                
    Color = ColorNeutral;
                   
if(price_highest2>price_highest1)
 {
  Color = ColorDown; 
 
    ObjectCreate(Tf+"High_Arrow"+i, OBJ_TREND, 0, 0,0, 0,0);
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_TIME1,time_highest1);
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_TIME2,time_highest2); 
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_PRICE1,price_highest1);
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_PRICE2,price_highest2);    
       
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_BACK,Back);  
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_COLOR,Color); 
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_STYLE,0); 
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_WIDTH,Width); 
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_RAY,false); 
    ObjectSet(Tf+"High_Arrow"+i,OBJPROP_SELECTABLE,false); 
    
if(Show_Extensions)
  {
  string Ext_Name = IntegerToString(Tf,0)+"ExtHigh_Arrow"+IntegerToString(i,0);

    ObjectCreate(Ext_Name, OBJ_TREND, 0, 0,0, 0,0);
    ObjectSet(Ext_Name,OBJPROP_TIME1,time_highest1);
    ObjectSet(Ext_Name,OBJPROP_TIME2,time3); 
    ObjectSet(Ext_Name,OBJPROP_PRICE1,price_highest1);
    ObjectSet(Ext_Name,OBJPROP_PRICE2,price_highest1);    
       
    ObjectSet(Ext_Name,OBJPROP_BACK,Back);  
    ObjectSet(Ext_Name,OBJPROP_COLOR,Color); 
    ObjectSet(Ext_Name,OBJPROP_STYLE,ExtStyle); 
    ObjectSet(Ext_Name,OBJPROP_WIDTH,ExtWidth); 
    ObjectSet(Ext_Name,OBJPROP_RAY,false); 
    ObjectSet(Ext_Name,OBJPROP_SELECTABLE,false);
    
    ObjectSet(Tf+"ExtHigh_Arrow"+Begin_Bar,OBJPROP_TIME2,Time[0]); 
    if(ObjectFind(0,Tf+"ExtHigh_Arrow"+Begin_Bar)<0)
      {
      Prev_Bar=Begin_Bar+1;
      ObjectSet(Tf+"ExtHigh_Arrow"+Prev_Bar,OBJPROP_TIME2,Time[0]); 
      }
  }      
    
  }
  
if(price_lowest2<price_lowest1)
 {
  Color = ColorUp; 
  
    ObjectCreate(Tf+"Low_Arrow"+i, OBJ_TREND, 0, 0,0, 0,0);
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_TIME1,time_lowest1);
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_TIME2,time_lowest2); 
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_PRICE1,price_lowest1);
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_PRICE2,price_lowest2);    
       
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_BACK,Back);  
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_COLOR,Color); 
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_STYLE,0); 
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_WIDTH,Width); 
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_RAY,false); 
    ObjectSet(Tf+"Low_Arrow"+i,OBJPROP_SELECTABLE,false); 
    
if(Show_Extensions)
  {
  Ext_Name = IntegerToString(Tf,0)+"ExtLow_Arrow"+IntegerToString(i,0);
  
    ObjectCreate(Ext_Name, OBJ_TREND, 0, 0,0, 0,0);
    ObjectSet(Ext_Name,OBJPROP_TIME1,time_lowest1);
    ObjectSet(Ext_Name,OBJPROP_TIME2,time3); 
    ObjectSet(Ext_Name,OBJPROP_PRICE1,price_lowest1);
    ObjectSet(Ext_Name,OBJPROP_PRICE2,price_lowest1);    
       
    ObjectSet(Ext_Name,OBJPROP_BACK,Back);  
    ObjectSet(Ext_Name,OBJPROP_COLOR,Color); 
    ObjectSet(Ext_Name,OBJPROP_STYLE,ExtStyle); 
    ObjectSet(Ext_Name,OBJPROP_WIDTH,ExtWidth); 
    ObjectSet(Ext_Name,OBJPROP_RAY,false); 
    ObjectSet(Ext_Name,OBJPROP_SELECTABLE,false); 
    
    ObjectSet(Tf+"ExtLow_Arrow"+Begin_Bar,OBJPROP_TIME2,Time[0]); 
    if(ObjectFind(0,Tf+"ExtLow_Arrow"+Begin_Bar)<0)
      {
      Prev_Bar=Begin_Bar+1;
      ObjectSet(Tf+"ExtLow_Arrow"+Prev_Bar,OBJPROP_TIME2,Time[0]); 
      }    
    
         
  }      
    
  }  

 if(ObjectFind(NULL,IntegerToString(Tf,0)+"ExtHigh_Arrow"+IntegerToString(i,0))==0&&ObjectFind(NULL,IntegerToString(Tf,0)+"ExtLow_Arrow"+IntegerToString(i,0))==0   )
   {   
      ObjectSet(IntegerToString(Tf,0)+"ExtHigh_Arrow"+IntegerToString(i,0),OBJPROP_WIDTH,Width+1);
      ObjectSet(IntegerToString(Tf,0)+"ExtHigh_Arrow"+IntegerToString(i,0),OBJPROP_COLOR,ColorNeutral); 
      ObjectSet(IntegerToString(Tf,0)+"ExtLow_Arrow"+IntegerToString(i,0),OBJPROP_WIDTH,Width+1);
      ObjectSet(IntegerToString(Tf,0)+"ExtLow_Arrow"+IntegerToString(i,0),OBJPROP_COLOR,ColorNeutral);
   }   
//----
  }
  }
  }
   return(0);
  }
//+------------------------------------------------------------------+

bool IsNewBar()
{ 
  static datetime Trend_Candle_prevTime1 = -1;
  
  if(Trend_Candle_prevTime1 != Time[6])
  { 
   Trend_Candle_prevTime1 = Time[6]; 
       
   return(true);  
  } 

  return(false); 
}
//+------------------------------------------------------------------+