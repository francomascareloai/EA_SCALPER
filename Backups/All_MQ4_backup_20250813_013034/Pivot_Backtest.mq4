//+------------------------------------------------------------------+
//|                                                        Pivot.mq4 |
//|                               Copyright © 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+------------------------------------------------------------------+
#property copyright "Poul Trade Forum"
#property link      "http://forex.kbpauk.ru/"

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 9
#property indicator_color1 White //Gold
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Lime
#property indicator_color5 Red
#property indicator_color6 Lime
#property indicator_color7 Red
#property indicator_color8 Yellow
#property indicator_color9 Yellow
#property indicator_color10 Yellow
//---- input parameters
   SetIndexStyle(0,DRAW_LINE,1,0,Gold); //Pivot
   SetIndexStyle(1,DRAW_LINE,0,1,Lime); //Sup1 //DarkBlue);
   SetIndexStyle(2,DRAW_LINE,0,1,Red); //Res1 //Maroon);
   SetIndexStyle(3,DRAW_LINE,0,1,Lime); //Sup2 
   SetIndexStyle(4,DRAW_LINE,0,1,Red);  //Res2
   SetIndexStyle(5,DRAW_LINE,0,1,Lime); //Sup3
   SetIndexStyle(6,DRAW_LINE,0,1,Red); //Res3
   SetIndexStyle(7,DRAW_LINE,0,1,Yellow); //Mid1
   SetIndexStyle(8,DRAW_LINE,0,1,Yellow);
   SetIndexStyle(9,DRAW_LINE,0,1,Yellow);   
//---- buffers
double PBuffer[];
double S1Buffer[];
double R1Buffer[];
double S2Buffer[];
double R2Buffer[];
double S3Buffer[];
double R3Buffer[];
double M1Buffer[];
double M2Buffer[];
double M3Buffer[];
string Pivot="Pivot Point",Sup1="S 1", Res1="R 1";
string Sup2="S 2", Res2="R 2", Sup3="S 3", Res3="R 3";
string Mid1="M 1", Mid2="M 2", Mid3="M 3";
int fontsize=10;
double P,S1,R1,S2,R2,S3,R3,M1,M2,M3;
double LastHigh,LastLow,x;


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here

   ObjectDelete("Pivot");
   ObjectDelete("Sup1");
   ObjectDelete("Res1");
   ObjectDelete("Sup2");
   ObjectDelete("Res2");
   ObjectDelete("Sup3");
   ObjectDelete("Res3");   
   ObjectDelete("Mid1");      
   ObjectDelete("Mid2");      
   ObjectDelete("Mid3");      

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;


//---- indicator line
   SetIndexStyle(0,DRAW_LINE,1,1,Gold); //Pivot
   SetIndexStyle(1,DRAW_LINE,0,1,Lime); //Sup1 //DarkBlue);
   SetIndexStyle(2,DRAW_LINE,0,1,Red); //Res1 //Maroon);
   SetIndexStyle(3,DRAW_LINE,0,1,Lime); //Sup2 
   SetIndexStyle(4,DRAW_LINE,0,1,Red);  //Res2
   SetIndexStyle(5,DRAW_LINE,0,1,Lime); //Sup3
   SetIndexStyle(6,DRAW_LINE,0,1,Red); //Res3
   SetIndexStyle(7,DRAW_LINE,0,1,Yellow); //Mid1
   SetIndexStyle(8,DRAW_LINE,0,1,Yellow);
   SetIndexStyle(9,DRAW_LINE,0,1,Yellow);   
   SetIndexBuffer(0,PBuffer);
   SetIndexBuffer(1,S1Buffer);
   SetIndexBuffer(2,R1Buffer);
   SetIndexBuffer(3,S2Buffer);
   SetIndexBuffer(4,R2Buffer);
   SetIndexBuffer(5,S3Buffer);
   SetIndexBuffer(6,R3Buffer);
   SetIndexBuffer(7,M1Buffer);   
   SetIndexBuffer(8,M2Buffer);   
   SetIndexBuffer(9,M3Buffer);   

   ObjectDelete("Pivot");
   ObjectDelete("Sup1");
   ObjectDelete("Res1");
   ObjectDelete("Sup2");
   ObjectDelete("Res2");
   ObjectDelete("Sup3");
   ObjectDelete("Res3");   
   ObjectDelete("Mid1");      
   ObjectDelete("Mid2");      
   ObjectDelete("Mid3");     


//---- name for DataWindow and indicator subwindow label
   short_name="Pivot Point";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);

//----
   SetIndexDrawBegin(0,1);
//----
 

//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()

  {
   int    counted_bars=IndicatorCounted();

   int limit, i;
//---- indicator calculation
if (counted_bars==0)
{
   x=Period();
   if (x>240) return(-1);
   ObjectCreate("Pivot", OBJ_TEXT, 0, 0,0);
   ObjectSetText("Pivot", "                 Pivot Point",fontsize,"Arial",Gold);
   ObjectCreate("Sup1", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Sup1", "      S 1",fontsize,"Arial",Lime);
   ObjectCreate("Res1", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Res1", "      R 1",fontsize,"Arial",Red);
   ObjectCreate("Sup2", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Sup2", "      S 2",fontsize,"Arial",Lime);
   ObjectCreate("Res2", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Res2", "      R 2",fontsize,"Arial",Red);
   ObjectCreate("Sup3", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Sup3", "      S 3",fontsize,"Arial",Lime);
   ObjectCreate("Res3", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Res3", "      R 3",fontsize,"Arial",Red);
   ObjectCreate("Mid1", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Mid1", "      M 1",fontsize,"Arial",Red);
   ObjectCreate("Mid2", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Mid2", "      M 2",fontsize,"Arial",Red);   
   ObjectCreate("Mid3", OBJ_TEXT, 0, 0, 0);
   ObjectSetText("Mid3", "      M 3",fontsize,"Arial",Red);   
}
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
//   if(counted_bars>0) counted_bars--;
   limit=(Bars-counted_bars)-1;



for (i=limit; i>=0;i--)
{ 

if (High[i+1]>LastHigh) LastHigh=High[i+1];
if (Low[i+1]<LastLow) LastLow=Low[i+1];

if (TimeDay(Time[i])!=TimeDay(Time[i+1]))
   { 
   P=(LastHigh+LastLow+Close[i+1])/3;
   R1 = (2*P)-LastLow;
   S1 = (2*P)-LastHigh;
   R2 = P+(LastHigh - LastLow);
   S2 = P-(LastHigh - LastLow);
   R3 = (2*P)+(LastHigh-(2*LastLow));
   S3 = (2*P)-((2* LastHigh)-LastLow); 
   //R4 = (3*P)+(yesterday_high-(3*yesterday_low));
   //S4 = (3*P)-((3* yesterday_high)-yesterday_low);
   //M0 = (S2+S3)/2;
   M1 = (S1+S2)/2;
   M2 = (P+S1)/2;
   M3 = (P+R1)/2;
   //M4 = (R1+R2)/2;
   //M5 = (R2+R3)/2;
   LastLow=Open[i]; LastHigh=Open[i];


   ObjectMove("Pivot", 0, Time[i],P);
   ObjectMove("Sup1", 0, Time[i],S1);
   ObjectMove("Res1", 0, Time[i],R1);
   ObjectMove("Sup2", 0, Time[i],S2);
   ObjectMove("Res2", 0, Time[i],R2);
   ObjectMove("Sup3", 0, Time[i],S3);
   ObjectMove("Res3", 0, Time[i],R3);
   ObjectMove("Mid1", 0, Time[i],M1);
   ObjectMove("Mid2", 0, Time[i],M2);
   ObjectMove("Mid3", 0, Time[i],M3);

   }
   
    PBuffer[i]=P;
    S1Buffer[i]=S1;
    R1Buffer[i]=R1;
    S2Buffer[i]=S2;
    R2Buffer[i]=R2;
    S3Buffer[i]=S3;
    R3Buffer[i]=R3;
    M1Buffer[i]=M1;
    M2Buffer[i]=M2;
    M3Buffer[i]=M3;

}

//----
   return(0);
  }
//+------------------------------------------------------------------+