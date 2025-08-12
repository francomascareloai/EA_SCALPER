//+------------------------------------------------------------------+
//|                                                   CandleTime.mq4 |
//|                                         Copyright © 2010, Elmare |
//|                                        http://elmare.webnode.ru  |
//+------------------------------------------------------------------+
#property copyright "Elmare © 2010"
#property link      "http://elmare.webnode.ru/"

#property indicator_chart_window

//int per;
int tmp;
int sec;
int min;
int hor;

int barTime;
int curTime;

string cTime;
string sHor;
string sMin;
string sSec;

int per;
string sper;

extern int obCorner=3; // 0 - left up 3 - bottom right
extern int fsize=10; // font size

int init()
  {

per=Period();
if (per<60){sper="M"+per;}
else if(per>=60&&per<60*24) {sper="H"+per/60+" ";}
else {sper="D"+per/(60*24);} 
 
  
ObjectCreate("TimeLable12",OBJ_LABEL,0,0,0);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
ObjectDelete("TimeLable12");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  

  
//   int    counted_bars=IndicatorCounted();
per=Period();  
   
 
barTime=Time[0];
curTime=TimeCurrent();
tmp=curTime-barTime; //секунды с момента открытия свечи
tmp=per*60-tmp; //секунды до окончания свечи


//   {
     min=tmp/60;
     hor=min/60;
     min=min-hor*60;
     sec=tmp-min*60-hor*60*60;
//   }


if (min<10){sMin="0"+min;}
else {sMin=""+min;}

if (sec==60) {sec=59;}
if (sec<10){sSec="0"+sec;}
else {sSec=""+sec;}
if(hor>0)
{
   if (hor<10){sHor="0"+hor;}
   else {sHor=""+hor;}
}

if (hor==0) {
cTime=sMin+":"+sSec;
}
else {cTime=sHor+":"+sMin+":"+sSec;}

//----

ObjectSet("TimeLable12",OBJPROP_CORNER,obCorner);
ObjectSetText("TimeLable12",cTime,fsize,"Microsoft Sans Serif",Yellow);
ObjectSet("TimeLable12",OBJPROP_XDISTANCE,5);
ObjectSet("TimeLable12",OBJPROP_YDISTANCE,3);
   
//----

   return(0);
  }
//+------------------------------------------------------------------+