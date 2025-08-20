
//+------------------------------------------------------------------+
//|                                                     KPArrows.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

/*

Original Formula

FM:=MOV(C,3,E)-MOV(C,10,E);
SM:=MOV(C,4,E)-MOV(C,18,E);
HLTu:=FM>0 AND SM>0;
{ -this will paint the candles blue}
HLTd:=FM<0 AND SM<0;
{ -this will paint the candles red (set candle color to yellow, so you get yellow neutral bars)}
PLRosc:=MOV(TP(),4,S)-MOV(TP(),32,S);
PLRu:= CROSS(PLRosc,0);
{ - This plots the large black up arrows}
PLRd:= CROSS(0,PLRosc);
{ - This plots the large black down arrows}
WBP:=(HHV(HIGH,5)+LLV(LOW,5)+CLOSE)/3;
VFORCE:= SUM(((TP()-REF(TP(),-1))/REF(TP(),-1))*VOLUME,13)/SUM(VOLUME,13);
VFORCEup:=IF(PLRu OR PLRd,0,VFORCE);
{ - if plr is true, we only want a large arrow on the bar}
VFORCEdn:=IF(PLRd OR PLRu,0,VFORCE);
{ - if plr is true, we only want a large arrow on the canlde}
FORCEu:=VFORCEup>0;
{ - plots a blue arrow on candles}
FORCEd:=VFORCEdn<0;
{ -plots a red arrow on candles}


*/


#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Brown
#property indicator_color3 Aqua
#property indicator_color4 Pink
#property indicator_color5 White

//---- input parameters


//---- buffers  WHH=HHV(WH,25);WLL=LLV(WL,25);WBP_MA=MOV(WBP,25,S)
double PLRu[];
double PLRd[];
double WBP[],VFu[],VFd[],VFn[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 3 additional buffers are used for counting.
   IndicatorBuffers(6);
//---- name for DataWindow and indicator subwindow label
   SetIndexBuffer(5,WBP);

   

//----
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,2);
   SetIndexBuffer(0, PLRu);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,2);
   SetIndexBuffer(1, PLRd);
   SetIndexArrow(0,221);
   SetIndexArrow(1,222);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexBuffer(2, VFu);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexBuffer(3, VFd);
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,3);
   SetIndexBuffer(4, VFn);
   SetIndexArrow(2,159);
   SetIndexArrow(3,159);
   SetIndexArrow(4,159);
   short_name="KPArrows";
   IndicatorShortName(short_name);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| KPArrows(PLR/TP)                                                 |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k,counted_bars=IndicatorCounted();
   double VF,space; space=4*MathPow(0.5,Digits);
   if(Bars<=32) return(0);
//---- initial zero

//---- last counted bar will be recounted
   int limit=Bars-counted_bars;
   if(counted_bars>0) limit++; 

/*---- PLRosc:=MOV(TP(),4,S)-MOV(TP(),32,S);
PLRu:= CROSS(PLRosc,0);
{ - This plots the large black up arrows}
PLRd:= CROSS(0,PLRosc);
{ - This plots the large black down arrows}*/
   double T1,T2;
   for(i=0; i<limit; i++)
     { T1=iMA(NULL,0,4,0,MODE_SMA,PRICE_TYPICAL,i+1)-iMA(NULL,0,32,0,MODE_SMA,PRICE_TYPICAL,i+1);
      T2=iMA(NULL,0,4,0,MODE_SMA,PRICE_TYPICAL,i)-iMA(NULL,0,32,0,MODE_SMA,PRICE_TYPICAL,i);
      if (T1>=0 && T2<0) {PLRd[i]=High[i]+space;PLRu[i]=0;}
      else if (T1<=0 && T2>0) {PLRu[i]=Low[i]-space;PLRd[i]=0;}
           else {PLRu[i]=0;PLRd[i]=0;}
     }

/*

VFORCE:= SUM(((TP()-REF(TP(),-1))/REF(TP(),-1))*VOLUME,13)/SUM(VOLUME,13);
VFORCEup:=IF(PLRu OR PLRd,0,VFORCE);
{ - if plr is true, we only want a large arrow on the bar}
VFORCEdn:=IF(PLRd OR PLRu,0,VFORCE);
{ - if plr is true, we only want a large arrow on the canlde}
FORCEu:=VFORCEup>0;
{ - plots a blue arrow on candles}
FORCEd:=VFORCEdn<0;
{ -plots a red arrow on candles}*/

 for(i=0; i<limit-1; i++)
      {T1=(High[i]+Low[i]+Close[i])/3;T2=(High[i+1]+Low[i+1]+Close[i+1])/3;
       T1=T1-T2;WBP[i]=T1/T2*Volume[i];
       //VM[i]=13*iMA(NULL,0,13,0,MODE_SMA,MODE_VOLUME,i);
       }
    double TP;  
 for(i=0; i<limit; i++) 
 {VF=iMAOnArray(WBP,Bars,13,0,MODE_SMA,i);TP=(Close[i]+High[i]+Low[i])/3;
 if (VF>0 ) {VFu[i]=TP;VFd[i]=0;VFn[i]=0;}
    else if (VF<0) {VFu[i]=0;VFd[i]=TP;VFn[i]=0;}
         else {VFn[i]=TP;VFd[i]=0;VFu[i]=0;}
  }
/* */ 
   return(0);
  }
//+------------------------------------------------------------------+