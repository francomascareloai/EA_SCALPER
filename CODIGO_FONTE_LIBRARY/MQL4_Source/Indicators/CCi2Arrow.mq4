//+------------------------------------------------------------------+
//|                                                    CCi2Arrow.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#property link                      "https://forexsystemsru.com/member.php?u=66268"
#property copyright                 "zz43"
#property version                   "1.0"
#property description               "CCi2Arrow"
#property indicator_chart_window
#property indicator_buffers          2
//---- plot Line 
#property indicator_label1 "Arrow" 
#property indicator_color1 clrBlue
#property indicator_width1 1 
#property indicator_type1  DRAW_ARROW
#property indicator_label2 "Arrow" 
#property indicator_color2 clrRed 
#property indicator_width2 1 
#property indicator_type2  DRAW_ARROW
//--- indicator parameters

extern int                  cci_period        = 14;    
extern ENUM_APPLIED_PRICE   applied_price     = PRICE_OPEN;   
extern double               level1            = 0.0;   
extern double               level2            = 0.0;         
extern int                  indent_arrow_up   = 10;                     
extern int                  indent_arrow_down = 10;                     
extern int                  counted_bars      = 1000;                    
extern string               sound_file        = "alert.wav";             
extern bool                 use_sound         = true;                    
extern bool                 use_notification  = false;                   
extern bool                 use_mail          = false;  
int                         code_arrow_up     = 234;                     
int                         code_arrow_down   = 233; 
                 
//--- indicator buffers 
double arrow_up[];
double arrow_down[];
//--- type
bool sound_up = false; 
bool sound_down = false;
bool flag_up = false;
bool flag_down = false;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit() 
  {
SetIndexBuffer(1,arrow_up);
SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,0);
SetIndexArrow(1,code_arrow_up);
SetIndexBuffer(0,arrow_down);
SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,0);
SetIndexArrow(0,code_arrow_down);
//--- 
   return(INIT_SUCCEEDED); 
  } 
int OnCalculate(const int rates_total, 
                const int prev_calculated, 
                const datetime& time[], 
                const double& open[], 
                const double& high[], 
                const double& low[], 
                const double& close[], 
                const long& tick_volume[], 
                const long& volume[], 
                const int& spread[]) 
  { 
   for(int shift=counted_bars;shift>=0;shift--)
   {
   double eclipse1 = iCustom(NULL,0,"i-g-cci2",cci_period,applied_price,0,shift);
   double eclipse12 = iCustom(NULL,0,"i-g-cci2",cci_period,applied_price,0,shift+1);
   {
   if(flag_up==false)
   if(eclipse12 > level1 && eclipse1 < level1)
   {
   arrow_up[shift]=High[shift]+indent_arrow_up*Point;
   flag_up=true;
   flag_down=false;
   }
   else
   {
   arrow_up[shift]=EMPTY_VALUE;
   }
   if(flag_down==false)
   if(eclipse12 < level2 && eclipse1 > level2)
   {
   arrow_down[shift]=Low[shift]-indent_arrow_down*Point;
   flag_up=false;
   flag_down=true;
   }
   else
   {
   arrow_down[shift]=EMPTY_VALUE;
   }
   if(arrow_up[0]!=EMPTY_VALUE&&arrow_up[0]!=0&&sound_up){
   sound_up=false;
   if(use_sound)PlaySound(sound_file);
      Alert("Signal Sell !" "  " + Symbol() + ",  " + (string)Period() + " ," + "  " + (string)Bid); 
   if(use_mail)
      SendMail("Arrows" "  ",  "  " + Symbol()+ ",  " + (string)Period() + " " + ",  " + (string)Bid );
   if(use_notification)
      SendNotification("Arrows" "  " + Symbol() + ",  " + (string)Period() + "  " + ",  " + (string)Bid);    
   }
   if(!sound_up&&(arrow_up[0]==EMPTY_VALUE||arrow_up[0]==0))sound_up=true;
   }
   
   if(arrow_down[0]!=EMPTY_VALUE&&arrow_down[0]!=0&&sound_down){
   sound_down=false;
   if(use_sound)PlaySound(sound_file);
      Alert("Signal Buy !" "  " + Symbol() + ",  " + (string)Period() + " ," + "  " + (string)Bid); 
   if(use_mail)
      SendMail("Arrows" " .. ",  "  " + Symbol()+ ",  " + (string)Period() + " " + ",  " + (string)Bid );
   if(use_notification)
      SendNotification("Arrows" "  " + Symbol() + ",  " + (string)Period() + "  " + ",  " + (string)Bid);    
   }
   if(!sound_down&&(arrow_down[0]==EMPTY_VALUE||arrow_down[0]==0))sound_down=true;
   }
   return(INIT_SUCCEEDED); 
  }