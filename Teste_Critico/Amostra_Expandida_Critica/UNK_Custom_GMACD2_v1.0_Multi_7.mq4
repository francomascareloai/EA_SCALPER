//+------------------------------------------------------------------+
//|                                                      GMACD#2.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

/*********************************************************************
* Author: Muhammad Hamizi Jaminan (hymns)
* Original Author: CJA
*
* Date: December 14, 2006
* Custom Indicator: GMACD2.mq4
* Version: 1.0.1
* Description: Multi TimeFrame MACD Signal & MACD Graph
*
* Change Logs
* Version 1.0.1
* - Rewriting Code. Using less variable & ObjectCreate. Reduce CPU 
*   Usage. Solve multiple object label show on load.
*
* Version G#MACD#2
* - Release by CJA
**********************************************************************/

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 DarkSlateGray  // HISTO
#property indicator_color2 Red // inside line
#property indicator_color3 Blue  // inside line
#property indicator_color4 Red  //middle line
#property indicator_color5 Blue  //middle line
#property indicator_color6 DarkOrange  // outside line
#property indicator_color7 DodgerBlue  //outside line
#property indicator_width1 2

//---- input parameters
extern int       FastEMA=8;
extern int       FFastEMA=7;
extern int       FFFastEMA=6;
extern int       SlowEMA=17;
extern int       SSlowEMA=16;
extern int       SSSlowEMA=15;
extern int       SignalSMA=9;
extern int       SSignalSMA=8;
extern int       SSSignalSMA=7;
extern bool      Show_MAJOR_TREND = false;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("GMACD2");
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,ExtMapBuffer6);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,ExtMapBuffer7);
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(0,OBJ_LABEL);
   ObjectDelete("Label1"); ObjectDelete("Label2"); ObjectDelete("Label3");
   ObjectDelete("DataM1"); ObjectDelete("DataM5"); ObjectDelete("DataM15");
   ObjectDelete("DataM30"); ObjectDelete("DataH1"); ObjectDelete("DataH4");
   ObjectDelete("DataD1"); ObjectDelete("DataW1"); ObjectDelete("DataMN");
   ObjectDelete("Trend1"); ObjectDelete("Trend2"); ObjectDelete("Level1");   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();

//----
   for(int i=Bars;i>=0;i--){
      ExtMapBuffer2[i]=iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i); 
      ExtMapBuffer3[i]=iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i);  
      ExtMapBuffer4[i]=iMACD(NULL,0,FFastEMA,SSlowEMA,SSignalSMA,PRICE_CLOSE,MODE_MAIN,i); 
      ExtMapBuffer5[i]=iMACD(NULL,0,FFastEMA,SSlowEMA,SSignalSMA,PRICE_CLOSE,MODE_SIGNAL,i);  
      ExtMapBuffer6[i]=iMACD(NULL,0,FFFastEMA,SSSlowEMA,SSSignalSMA,PRICE_CLOSE,MODE_MAIN,i); 
      ExtMapBuffer7[i]=iMACD(NULL,0,FFFastEMA,SSSlowEMA,SSSignalSMA,PRICE_CLOSE,MODE_SIGNAL,i); 
   
      ExtMapBuffer1[i]=ExtMapBuffer2[i] - ExtMapBuffer3[i]; 
   }
   
    double macd_M1=iMACD(NULL,PERIOD_M1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MM1=iMACD(NULL,PERIOD_M1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    double macd_M5=iMACD(NULL,PERIOD_M5,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MM5=iMACD(NULL,PERIOD_M5,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0);
    double macd_M15=iMACD(NULL,PERIOD_M15,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MM15=iMACD(NULL,PERIOD_M15,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0);
    double macd_M30=iMACD(NULL,PERIOD_M30,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MM30=iMACD(NULL,PERIOD_M30,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    double macd_H1=iMACD(NULL,PERIOD_H1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_HH1=iMACD(NULL,PERIOD_H1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0);
    double macd_H4=iMACD(NULL,PERIOD_H4,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_HH4=iMACD(NULL,PERIOD_H4,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 

    if (Show_MAJOR_TREND == true)
    {
    double macd_D1=iMACD(NULL,PERIOD_D1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_DD1=iMACD(NULL,PERIOD_D1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    double macd_W1=iMACD(NULL,PERIOD_W1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_WW1=iMACD(NULL,PERIOD_W1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    double macd_MN1=iMACD(NULL,PERIOD_MN1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,0); 
    double macd_MMN1=iMACD(NULL,PERIOD_MN1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,0); 
    }
        
    string  trend_signal = "", trend_main = "", trend_level = "";
    color   color_m1, color_m5, color_m15, color_m30, color_h1, color_h4, color_d1, color_w1, color_mn,
            color_signal, color_main, color_level;
           
    // UP Data
    if ((macd_M5 > macd_MM5) && (macd_M1 > macd_MM1)) { trend_signal = "TREND/UP"; color_signal = Lime;}
     //Down Data   
    if ((macd_M5 < macd_MM5) && (macd_M1 < macd_MM1)) { trend_signal = "TREND/DN"; color_signal = Red; }
    
    //Consolidation Data
    if ((macd_M5 < macd_MM5) && (macd_M1 > macd_MM1)) { trend_signal = "SIDEWAY"; color_signal = Orange; }
    if ((macd_M5 > macd_MM5) && (macd_M1 < macd_MM1)) { trend_signal = "SIDEWAY"; color_signal = Orange; }
    
    if ((macd_M15 < macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 > macd_HH1)&& (macd_H4 < macd_HH4)) { trend_level = "WEAK"; color_level = Tomato; }
    if ((macd_M15 > macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 < macd_HH1)&& (macd_H4 > macd_HH4)) { trend_level = "WEAK"; color_level = Tomato; }
     
    if ((macd_M15 < macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 < macd_HH1) && (macd_H4 < macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    if ((macd_M15 > macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 > macd_HH1) && (macd_H4 > macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    
    
    if ((macd_M5 > macd_MM5) && (macd_M15 > macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 < macd_HH1) && (macd_H4 > macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    if ((macd_M5 < macd_MM5) && (macd_M15 < macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 >macd_HH1) && (macd_H4 < macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    
    if ((macd_M15 < macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 > macd_HH1)) { trend_main = "TREND/UP"; color_main = YellowGreen; }
    if ((macd_M15 > macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 < macd_HH1)) { trend_main = "TREND/DN"; color_main = Tomato; }
    
    if ((macd_M15 < macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 > macd_HH1)) { trend_main = "TREND/DN"; color_main = Tomato; }
    if ((macd_M15 > macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 < macd_HH1)) { trend_main = "TREND/UP"; color_main = YellowGreen; }
    
    if ((macd_M15 < macd_MM15) && (macd_M30 > macd_MM30) && (macd_H1 < macd_HH1)) { trend_main = "TREND/DN"; color_main = Red; }
    if ((macd_M15 > macd_MM15) && (macd_M30 < macd_MM30) && (macd_H1 > macd_HH1)) { trend_main = "TREND/UP"; color_main = Lime; }
    
    if ((macd_M5 < macd_MM5) && (macd_M15 < macd_MM15) && (macd_H1 > macd_HH1) && (macd_H4 > macd_HH4)) { trend_level = "WEAK"; color_level = Tomato; }
    if ((macd_M5 > macd_MM5) && (macd_M15 > macd_MM15) && (macd_H1 < macd_HH1) && (macd_H4 < macd_HH4)) { trend_level = "WEAK"; color_level = Tomato; }
    
    if ((macd_M15 > macd_MM15) && (macd_H1 > macd_HH1) && (macd_M30 > macd_MM30) && (macd_H4 < macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    if ((macd_M15 < macd_MM15) && (macd_H1 < macd_HH1) && (macd_M30 < macd_MM30) && (macd_H4 > macd_HH4)) { trend_level = "MEDIUM"; color_level = Orange; }
    
    if ((macd_M15 > macd_MM15) && (macd_H1 > macd_HH1) && (macd_M30 > macd_MM30) && (macd_H4 > macd_HH4)) { trend_level = "STRONG"; color_level = Yellow; }
    if ((macd_M15 < macd_MM15) && (macd_H1 < macd_HH1) && (macd_M30 < macd_MM30) && (macd_H4 < macd_HH4)) { trend_level = "STRONG"; color_level = Yellow; }
    
    if ((macd_M15 > macd_MM15) && (macd_H1 > macd_HH1) && (macd_M30 > macd_MM30) && (macd_H4 > macd_HH4)) { trend_main = "TREND/UP"; color_main = Lime; }
    if ((macd_M15 < macd_MM15) && (macd_H1 < macd_HH1) && (macd_M30 < macd_MM30) && (macd_H4 < macd_HH4)) { trend_main = "TREND/DN"; color_main = Red; }
    
     
    if ((macd_M15 > macd_MM15) && (macd_H1 > macd_HH1) && (macd_M30 > macd_MM30) && (macd_H4 < macd_HH4)) { trend_main = "TREND/UP"; color_main = Lime; }
    if ((macd_M15 < macd_MM15) && (macd_H1 < macd_HH1) && (macd_M30 < macd_MM30) && (macd_H4 > macd_HH4)) { trend_main = "TREND/DN"; color_main = Red; }              
    
    //MACD Direction
    if ((macd_M1 > macd_MM1)) { color_m1 = Lime; }
    if ((macd_M1 < macd_MM1)) { color_m1 = Red; }
    
    if ((macd_M5 > macd_MM5)) { color_m5 = Lime; }
    if ((macd_M5 < macd_MM5)) { color_m5 = Red; }
    
    if ((macd_M15 > macd_MM15)) { color_m15 = Lime; }
    if ((macd_M15 < macd_MM15)) { color_m15 = Red; }
    
    if ((macd_M30 > macd_MM30)) { color_m30 = Lime; }
    if ((macd_M30 < macd_MM30)) { color_m30 = Red; }
    
    if ((macd_H1 > macd_HH1)) { color_h1 = Lime; }
    if ((macd_H1 < macd_HH1)) { color_h1 = Red; }
    
    if ((macd_H4 > macd_HH4)) { color_h4 = Lime; }
    if ((macd_H4 < macd_HH4)) { color_h4 = Red; }

    if (Show_MAJOR_TREND == true)
    {    
      if ((macd_D1 > macd_DD1)) { color_d1 = Lime; }
      if ((macd_D1 < macd_DD1)) { color_d1 = Red; }
    
      if ((macd_W1 > macd_WW1)) { color_w1 = Lime; }
      if ((macd_W1 < macd_WW1)) { color_w1 = Red; }
    
      if ((macd_MN1 > macd_MMN1)) { color_mn = Lime; }
      if ((macd_MN1 < macd_MMN1)) { color_mn = Red; }
    }      

    //Signal Labels           
    ObjectCreate("Label1", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);
        ObjectSetText("Label1","SIGNAL",8, "Arial Bold", Silver);
        ObjectSet("Label1", OBJPROP_CORNER, 0);
        ObjectSet("Label1", OBJPROP_XDISTANCE, 305);
        ObjectSet("Label1", OBJPROP_YDISTANCE, 4);       
     
    //MACD Direction M1-M5
    ObjectCreate("DataM1", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);//M1 SIGNAL
        ObjectSetText("DataM1","M1",9, "Arial Bold", color_m1);
        ObjectSet("DataM1", OBJPROP_CORNER, 0);
        ObjectSet("DataM1", OBJPROP_XDISTANCE, 350);
        ObjectSet("DataM1", OBJPROP_YDISTANCE, 4);
         
    ObjectCreate("DataM5", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);//M5 SIGNAL
        ObjectSetText("DataM5","M5",9, "Arial Bold", color_m5);
        ObjectSet("DataM5", OBJPROP_CORNER, 0);
        ObjectSet("DataM5", OBJPROP_XDISTANCE, 375);
        ObjectSet("DataM5", OBJPROP_YDISTANCE, 4);

    //M1 & M5 TREND Data 
    ObjectCreate("Trend1", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);
        ObjectSetText("Trend1",trend_signal,12, "Arial Bold", color_signal);
        ObjectSet("Trend1", OBJPROP_CORNER, 0);
        ObjectSet("Trend1", OBJPROP_XDISTANCE, 400);
        ObjectSet("Trend1", OBJPROP_YDISTANCE, 4);
            
    //Main Trend Label
    ObjectCreate("Label2", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);
        ObjectSetText("Label2","MAIN TREND", 8, "Arial Bold", Silver);
        ObjectSet("Label2", OBJPROP_CORNER, 0);
        ObjectSet("Label2", OBJPROP_XDISTANCE, 490);
        ObjectSet("Label2", OBJPROP_YDISTANCE, 4); 
    
    //MACD Direction M15-H4        
    ObjectCreate("DataM15", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);//M15 SIGNAL
        ObjectSetText("DataM15","M15",9, "Arial Bold", color_m15);
        ObjectSet("DataM15", OBJPROP_CORNER, 0);
        ObjectSet("DataM15", OBJPROP_XDISTANCE, 560);
        ObjectSet("DataM15", OBJPROP_YDISTANCE, 4);

    ObjectCreate("DataM30", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);//M30 SIGNAL
        ObjectSetText("DataM30","M30",9, "Arial Bold", color_m30);
        ObjectSet("DataM30", OBJPROP_CORNER, 0);
        ObjectSet("DataM30", OBJPROP_XDISTANCE, 590);
        ObjectSet("DataM30", OBJPROP_YDISTANCE, 4);

    ObjectCreate("DataH1", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);//H1 SIGNAL
        ObjectSetText("DataH1","H1",9, "Arial Bold", color_h1);
        ObjectSet("DataH1", OBJPROP_CORNER, 0);
        ObjectSet("DataH1", OBJPROP_XDISTANCE, 620);
        ObjectSet("DataH1", OBJPROP_YDISTANCE, 4);

    ObjectCreate("DataH4", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);//H4 SIGNAL
        ObjectSetText("DataH4","H4",9, "Arial Bold", color_h4);
        ObjectSet("DataH4", OBJPROP_CORNER, 0);
        ObjectSet("DataH4", OBJPROP_XDISTANCE, 640);
        ObjectSet("DataH4", OBJPROP_YDISTANCE, 4);

    //M15 - H4 TREND Data 
    ObjectCreate("Trend2", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);
        ObjectSetText("Trend2",trend_main,12, "Arial Bold", color_main);
        ObjectSet("Trend2", OBJPROP_CORNER, 0);
        ObjectSet("Trend2", OBJPROP_XDISTANCE, 665);
        ObjectSet("Trend2", OBJPROP_YDISTANCE, 4);
        
    //Level Data
    ObjectCreate("Level1", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);
        ObjectSetText("Level1",trend_level,8, "Arial Bold", color_level);
        ObjectSet("Level1", OBJPROP_CORNER, 0);
        ObjectSet("Level1", OBJPROP_XDISTANCE, 755);
        ObjectSet("Level1", OBJPROP_YDISTANCE, 4);
                
    if (Show_MAJOR_TREND == true)
    {
    ObjectCreate("Label3", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);
        ObjectSetText("Label3","MAJOR TREND", 8, "Arial Bold", Silver);
        ObjectSet("Label3", OBJPROP_CORNER, 0);
        ObjectSet("Label3", OBJPROP_XDISTANCE, 805);
        ObjectSet("Label3", OBJPROP_YDISTANCE, 4); 
            
    ObjectCreate("DataD1", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);//D1 SIGNAL
        ObjectSetText("DataD1","D1",9, "Arial Bold", color_d1);
        ObjectSet("DataD1", OBJPROP_CORNER, 0);
        ObjectSet("DataD1", OBJPROP_XDISTANCE, 885);
        ObjectSet("DataD1", OBJPROP_YDISTANCE, 4);
        
    ObjectCreate("DataW1", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);//W1 SIGNAL
        ObjectSetText("DataW1","W1",9, "Arial Bold", color_w1);
        ObjectSet("DataW1", OBJPROP_CORNER, 0);
        ObjectSet("DataW1", OBJPROP_XDISTANCE, 905);
        ObjectSet("DataW1", OBJPROP_YDISTANCE, 4);
        
    ObjectCreate("DataMN", OBJ_LABEL, WindowFind("GMACD2"), 0, 0);//MN SIGNAL
        ObjectSetText("DataMN","MN",9, "Arial Bold", color_mn);
        ObjectSet("DataMN", OBJPROP_CORNER, 0);
        ObjectSet("DataMN", OBJPROP_XDISTANCE, 930);
        ObjectSet("DataMN", OBJPROP_YDISTANCE, 4);
    }    
    
}
//----
   return(0);
  
//+------------------------------------------------------------------+