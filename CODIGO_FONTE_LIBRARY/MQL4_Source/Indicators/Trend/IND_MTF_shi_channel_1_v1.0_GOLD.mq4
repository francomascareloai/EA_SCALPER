//+------------------------------------------------------------------+ 
//| SHI_Channel.mq4                                                  | 
//|                                                   |
//+------------------------------------------------------------------+ 
#property copyright "" 
#property link ""  

#property indicator_chart_window 
#property indicator_buffers 1 
#property indicator_color1 Red 
double ExtMapBuffer1[]; 
//---- input parameters 
extern int TimeFrame=60;
extern int AllBars=240; 
extern int BarsForFract=0; 
extern double flatCriteria=0.25;
extern color collor=Lime;

int CurrentBar=0; 
double Step=0; 
int B1=-1,B2=-1; 
int UpDown=0; 
double P1=0,P2=0,PP=0; 
int i=0,AB=300,BFF=0; 
int ishift=0; 
double iprice=0; 
datetime T1,T2; 
int trend,flat;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function | 
//+------------------------------------------------------------------+ 
int init() 
   { 
   //---- indicators 
   SetIndexStyle(0,DRAW_ARROW); 
   SetIndexArrow(0,164); 
   SetIndexBuffer(0,ExtMapBuffer1); 
   SetIndexEmptyValue(0,0.0); 
   //---- 

 

   return(0); 
   } 
  
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function | 
//+------------------------------------------------------------------+ 
int deinit() 
{ 
//---- 

//---- 
return(0); 
} 

void DelObj() 
{ 

ObjectDelete("TL1"+TimeFrame); 
ObjectDelete("TL2"+TimeFrame); 
ObjectDelete("MIDL"+TimeFrame); 
} 

//+------------------------------------------------------------------+ 
//| Custom indicator iteration function | 
//+------------------------------------------------------------------+ 
int start() 
   { 
 
   int    i,limit,y=0;
   int counted_bars=IndicatorCounted();  
 
      limit=Bars-counted_bars;
 
   int X = (Ask-P1);
   int X2 = (Bid-P2);
   //---- 
 
    if ((AllBars==0) || (Bars<AllBars)) AB=Bars; else AB=AllBars; //AB-количество обсчитываемых баров 
//    string TimeFrame;
 
   if (BarsForFract>0) 
      BFF=BarsForFract; 
   else 
      { 
      switch (TimeFrame) 
      { 
      case 1: BFF=12;  break; 
      case 5: BFF=48; break; 
      case 15: BFF=24; break; 
      case 30: BFF=24; break; 
      case 60: BFF=12; break; 
      case 240: BFF=15; break; 
      case 1440: BFF=10; break; 
      case 10080: BFF=6; break; 
      default: DelObj(); return(-1); break; 
      X = P1;
      } 
   } 
   
    
   
   
   CurrentBar=2; //считаем с третьего бара, чтобы фрактал "закрепился 
   B1=y-1; B2=y-1; UpDown=0; 
   while(((B1==-1) || (B2==-1)) && (CurrentBar<AB)) 
      { 

      //UpDown=1 значит первый фрактал найден сверху, UpDown=-1 значит первый фрактал 
      //найден снизу, UpDown=0 значит фрактал ещё не найден. 
      //В1 и В2 - номера баров с фракталами, через них строим опорную линию. 
      //Р1 и Р2 - соответственно цены через которые будем линию проводить 

      if((UpDown<1) && (CurrentBar==Lowest(Symbol(),TimeFrame,MODE_LOW,BFF*2+1,CurrentBar-BFF))) 
         { 
         if(UpDown==0) 
            {
            UpDown=-1; B1=CurrentBar; P1=iLow(Symbol(),TimeFrame,B1); 
            } 
         else 
            { 
            B2=CurrentBar; P2=iLow(Symbol(),TimeFrame,B2);
            } 
         } 
      if((UpDown>-1) && (CurrentBar==Highest(Symbol(),TimeFrame,MODE_HIGH,BFF*2+1,CurrentBar-BFF)))
         { 
         if(UpDown==0) 
            { 
            UpDown=1; B1=CurrentBar; P1=iHigh(Symbol(),TimeFrame,B1); 
            } 
         else 
            { 
            B2=CurrentBar; P2=iHigh(Symbol(),TimeFrame,B2); 
            } 
         } 
      CurrentBar++; 
      } 
   if((B1==-1) || (B2==-1)) 
      {
      DelObj(); 
      return(-1);
      } // Значит не нашли фракталов среди 300 баров  
   Step=(P2-P1)/(B2-B1);//Вычислили шаг, если он положительный, то канал нисходящий 
   P1=P1-B1*Step; B1=0;//переставляем цену и первый бар к нулю 
   //А теперь опорную точку противоположной линии канала. 
   ishift=0; iprice=0; 
   if(UpDown==1) 
      { 
      PP=iLow(Symbol(),TimeFrame,2)-2*Step; 
      for(i=3;i<=B2;i++) 
         { 
         if(iLow(Symbol(),TimeFrame,i)<PP+Step*i) 
            { 
            PP=iLow(Symbol(),TimeFrame,i)-i*Step; 
            } 
         } 
      if(iLow(Symbol(),TimeFrame,0)<PP) 
         {
         ishift=0; 
         iprice=PP;
         } 
      if(iLow(Symbol(),TimeFrame,1)<PP+Step) 
         {
         ishift=1; 
         iprice=PP+Step;
         } 
      if(iHigh(Symbol(),TimeFrame,0)>P1) 
         {
         ishift=0; 
         iprice=P1;
         } 
      if(iHigh(Symbol(),TimeFrame,1)>P1+Step) 
         {
         ishift=1; 
         iprice=P1+Step;
         } 
      } 
   else 
      { 
      PP=iHigh(Symbol(),TimeFrame,2)-2*Step; 
      for(i=3;i<=B2;i++) 
         { 
         if(iHigh(Symbol(),TimeFrame,i)>PP+Step*i) 
            { 
            PP=iHigh(Symbol(),TimeFrame,i)-i*Step;
            } 
         } 
      if(iLow(Symbol(),TimeFrame,0)<P1) 
         {
         ishift=0; 
         iprice=P1;
         } 
      if(iLow(Symbol(),TimeFrame,1)<P1+Step) 
         {
         ishift=1; 
         iprice=P1+Step;
         } 
      if(iHigh(Symbol(),TimeFrame,0)>PP) 
         {
         ishift=0; 
         iprice=PP;
         } 
      if(iHigh(Symbol(),TimeFrame,1)>PP+Step) 
         {
         ishift=1; 
         iprice=PP+Step;
         } 
      } 
      
   //Теперь переставим конечную цену и бар на АВ, чтобы линии канала рисовались подлиннее 
   P2=P1+AB*Step; 
    T1=Time[iBarShift(Symbol(),0,iTime(Symbol(),TimeFrame,B1))]; 
    T2=Time[iBarShift(Symbol(),0,iTime(Symbol(),TimeFrame,AB))]; 
   //Print("P1=",P1,"  P2=",P2);

   //Если не было пересечения канала, то 0, иначе ставим псису. 
   if(iprice!=0) ExtMapBuffer1[ishift]=iprice; 

   //DelObj(); 

   if (Step>0) trend=-1; else trend=1;

   if (MathAbs(Step*20)>=2*iATR(Symbol(),TimeFrame,40,0)*flatCriteria) flat=0; else flat=1;
   
   if (ObjectFind("TL1"+TimeFrame)==-1)   
      {
      ObjectCreate("TL1"+TimeFrame,OBJ_TREND,0,T2,PP+Step*AB,T1,PP); 
      ObjectSet("TL1"+TimeFrame,OBJPROP_COLOR,collor); 
		ObjectSet("TL1"+TimeFrame,OBJPROP_WIDTH,2); 
      }
   else
      {
      ObjectSet("TL1"+TimeFrame, OBJPROP_TIME1,T2);       
      ObjectSet("TL1"+TimeFrame, OBJPROP_PRICE1,PP+Step*AB);       
      ObjectSet("TL1"+TimeFrame, OBJPROP_TIME2,T1);       
      ObjectSet("TL1"+TimeFrame, OBJPROP_PRICE2,PP); 
      ObjectSet("TL1"+TimeFrame,OBJPROP_COLOR,collor); 
		ObjectSet("TL1"+TimeFrame,OBJPROP_WIDTH,2);       
      }   
/*
   ObjectSet("TL1",OBJPROP_COLOR,ForestGreen); 
   ObjectSet("TL1",OBJPROP_WIDTH,2); 
   ObjectSet("TL1",OBJPROP_STYLE,STYLE_SOLID);
*/
   if (ObjectFind("TL2"+TimeFrame)==-1) 
      {
      ObjectCreate("TL2"+TimeFrame,OBJ_TREND,0,T2,P2,T1,P1); 
      ObjectSet("TL2"+TimeFrame,OBJPROP_COLOR,collor); 
		ObjectSet("TL2"+TimeFrame,OBJPROP_WIDTH,2); 
      }
   else
      {
      ObjectSet("TL2"+TimeFrame, OBJPROP_TIME1,T2);       
      ObjectSet("TL2"+TimeFrame, OBJPROP_PRICE1,P2);       
      ObjectSet("TL2"+TimeFrame, OBJPROP_TIME2,T1);       
      ObjectSet("TL2"+TimeFrame, OBJPROP_PRICE2,P1);   
     	ObjectSet("TL2"+TimeFrame,OBJPROP_COLOR,collor); 
		ObjectSet("TL2"+TimeFrame,OBJPROP_WIDTH,2);     
      }   
/*
   ObjectSet("TL2",OBJPROP_COLOR,ForestGreen); 
   ObjectSet("TL2",OBJPROP_WIDTH,2); 
   ObjectSet("TL2",OBJPROP_STYLE,STYLE_SOLID); 
*/
   if (ObjectFind("MIDL"+TimeFrame)==-1)  
      {
      ObjectCreate("MIDL"+TimeFrame,OBJ_TREND,0,T2,(P2+PP+Step*AB)/2,T1,(P1+PP)/2); 
     	ObjectSet("MIDL"+TimeFrame,OBJPROP_COLOR,collor); 
		ObjectSet("MIDL"+TimeFrame,OBJPROP_WIDTH,1); 
		ObjectSet("MIDL"+TimeFrame,OBJPROP_STYLE,STYLE_DOT); 
      }
   else
      {
      ObjectSet("MIDL"+TimeFrame, OBJPROP_TIME1,T2);       
      ObjectSet("MIDL"+TimeFrame, OBJPROP_PRICE1,(P2+PP+Step*AB)/2);       
      ObjectSet("MIDL"+TimeFrame, OBJPROP_TIME2,T1);       
      ObjectSet("MIDL"+TimeFrame, OBJPROP_PRICE2,(P1+PP)/2);    
      ObjectSet("MIDL"+TimeFrame,OBJPROP_WIDTH,1); 
		ObjectSet("MIDL"+TimeFrame,OBJPROP_STYLE,STYLE_DOT); 
		ObjectSet("MIDL"+TimeFrame,OBJPROP_COLOR,collor);   
      }   
/*
   ObjectSet("MIDL",OBJPROP_COLOR,ForestGreen); 
   ObjectSet("MIDL",OBJPROP_WIDTH,1); 
   ObjectSet("MIDL",OBJPROP_STYLE,STYLE_DOT); 
*/
   if (flat==1)
      {
      //Print("flat=1");
      if(PP+Step*AB>P2)
         { 
         ObjectSetText("TL1"+TimeFrame,"Sell"); 
         ObjectSetText("TL2"+TimeFrame,"Buy"); 
         }
      else
         {
         ObjectSetText("TL2"+TimeFrame,"Sell"); 
         ObjectSetText("TL1"+TimeFrame,"Buy"); 
         }   
      }
   else
      {
      //Print("flat=0");
      if((PP+Step*AB>P2)&&(trend==-1))
         {
         ObjectSetText("TL1"+TimeFrame,"Sell"); 
         ObjectSetText("TL2"+TimeFrame,"Take"); 
         }   
      if((PP+Step*AB>P2)&&(trend==1))
         {
         ObjectSetText("TL1"+TimeFrame,"Take"); 
         ObjectSetText("TL2"+TimeFrame,"Buy"); 
         }
      if((PP+Step*AB<P2)&&(trend==-1))
         {
         ObjectSetText("TL2"+TimeFrame,"Sell"); 
         ObjectSetText("TL1"+TimeFrame,"Take"); 
         }   
      if((PP+Step*AB<P2)&&(trend==1))
         {
         ObjectSetText("TL2"+TimeFrame,"Take"); 
         ObjectSetText("TL1"+TimeFrame,"Buy"); 
         }
      }   
 //}  //---- 
 //  Comment("Верх канала = ",PP,"\n","Середина = ",(P1+PP)/2,"\n","Низ канала = ",P1,"\n","Ширина = ",(PP-P1),"\n","Касание Верха = ",-(PP-Bid)," пипсов","\n","Касание Низа = ",(P1-Ask)," пипсов"); 
   return(0); 
   } 
//+------------------------------------------------------------------+