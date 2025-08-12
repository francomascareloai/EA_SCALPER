//+------------------------------------------------------------------+
//|                                                   wlxBWACsig.mq4 |
//|                        Copyright © 2005 B.Williams, coding wellx |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005 B.Williams, coding wellx"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 MediumBlue
#property indicator_color2 HotPink
//---- input parameters
extern int       updown=8;
//---- buffers
double BWACup[];
double BWACdown[];

int pos=0;
double AC1,AC2,AC3,AC4,AC5;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,119);
   SetIndexBuffer(0,BWACup);
   SetIndexEmptyValue(0,0.0);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,119);
   SetIndexBuffer(1,BWACdown);
   SetIndexEmptyValue(1,0.0);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int  cbars=IndicatorCounted();
   if  (cbars<0) return(-1);
   if  (cbars>0) cbars--;
   
//---- TODO: add your code here
   if (cbars > (Bars-40)) pos=(Bars-40);
   else pos=cbars;
//   pos=10;
   while (pos > 0)
   {
     BWACup[pos]=NULL;
     BWACdown[pos]=NULL;    
     AC1=iAC(NULL,0,pos);
     AC2=iAC(NULL,0,pos+1);
     AC3=iAC(NULL,0,pos+2);
     AC4=iAC(NULL,0,pos+3);
     AC5=iAC(NULL,0,pos+4);
     
     if (((AC4>0 && AC3>0 && AC2>0 && AC1>0) && (AC4>AC3 && AC2>AC3 && AC1>AC2)) ||
         ((AC4<0 && AC3<0 && AC2<0 && AC1>0) && (AC4>AC3 && AC2>AC3 && AC1>AC2)) ||
         ((AC5<0 && AC4<0 && AC3<0 && AC2<0 && AC1<0) && 
          (AC5>AC4 && AC4<AC3 && AC3<AC2 && AC2<AC1)))
             BWACup[pos]=(High[pos]+updown*Point) ;
             
     if (((AC4<0 && AC3<0 && AC2<0 && AC1<0) && (AC4<AC3 && AC2<AC3 && AC1<AC2)) ||
         ((AC4>0 && AC3>0 && AC2>0 && AC1<0) && (AC4<AC3 && AC2<AC3 && AC1<AC2)) ||
         ((AC5>0 && AC4>0 && AC3>0 && AC2>0 && AC1>0) && 
          (AC5<AC4 && AC4>AC3 && AC3>AC2 && AC2>AC1)))
             BWACdown[pos]=(Low[pos]-updown*Point) ;        
     
     pos--;
   }
   return(0);
  }
//+------------------------------------------------------------------+