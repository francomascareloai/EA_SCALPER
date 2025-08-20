//+------------------------------------------------------------------+
//|                                               Parabolic_ZZ.mq4   |
//|                                       Copyright © 2009, Vic2008  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Vic2008"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Magenta

//---- input parameters
extern double  SAR_step=0.02;     //Параметры параболика
extern double  SAR_maximum=0.2;

extern int BarsCount = 500;       //Дистанция в барах для отрисовки индикатора.
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_SECTION);
   
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_SECTION,0,2,DimGray);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(0,OBJ_ARROW);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int w,PosLow,PosHigh;
   double LPic=1000000,HPic=0,price;
   datetime TimeTmp;
   
//----
   ExtMapBuffer1[0]=Close[0];
   ExtMapBuffer2[0]=EMPTY_VALUE;

 for( w=0;w<BarsCount;w++){  
 
   if( w!=0 ){ ExtMapBuffer1[w]=EMPTY_VALUE; ExtMapBuffer2[w]=EMPTY_VALUE; }
     
   if( iSAR(NULL,0,SAR_step,SAR_maximum,w) > Close[w] && LPic>=Low[w] ){ LPic=Low[w]; PosLow=w;  }
   if( iSAR(NULL,0,SAR_step,SAR_maximum,w) < Close[w] && HPic<=High[w] ){ HPic=High[w]; PosHigh=w; }
   
   // H -> L
   if( iSAR(NULL,0,SAR_step,SAR_maximum,(w+1)) > Close[w+1] && iSAR(NULL,0,SAR_step,SAR_maximum,w) < Close[w] && HPic!=0)
   {
        ExtMapBuffer1[PosHigh]=HPic;
        ExtMapBuffer2[PosHigh]=HPic;
        HPic=0; 
   }
   
   // L -> H
   if( iSAR(NULL,0,SAR_step,SAR_maximum,w) < Close[w] && iSAR(NULL,0,SAR_step,SAR_maximum,w+1) > Close[w+1] && LPic!=1000000 ) 
   {
        ExtMapBuffer1[PosLow]=LPic;
        ExtMapBuffer2[PosLow]=LPic;
        LPic=1000000;
   }
   
   
 }   


 //Рисуем ценовые метки и уровни FIBO
 int wave_cnt=0;
 for( w=0;w<BarsCount;w++){  
    if( ExtMapBuffer2[w]!=EMPTY_VALUE ){ 
        if( wave_cnt<=3 ){ 
          ObjectDelete("PZZ_"+DoubleToStr( wave_cnt, 0));
          ObjectCreate("PZZ_"+DoubleToStr( wave_cnt, 0) , OBJ_ARROW, 0, Time[w], ExtMapBuffer2[w], Time[w], 0);
          ObjectSet("PZZ_"+DoubleToStr( wave_cnt, 0), OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE );
          ObjectSet("PZZ_"+DoubleToStr( wave_cnt, 0), SYMBOL_LEFTPRICE, ExtMapBuffer2[w]);
          ObjectSet("PZZ_"+DoubleToStr( wave_cnt, 0), OBJPROP_COLOR, Gray );
          
          //if(wave_cnt==1){
          //  ObjectDelete("FiboZZLast");
          //  ObjectCreate("FiboZZLast", OBJ_FIBO, 0, TimeTmp, ExtMapBuffer2[w], TimeTmp, price);
          //  ObjectSet("FiboZZLast", OBJPROP_LEVELCOLOR, Blue);
          //  ObjectSet("FiboZZLast", OBJPROP_COLOR, Blue);
          //  ObjectSet("FiboZZLast", OBJPROP_RAY , False );
          //}  
          
          //if(wave_cnt==2){
          //  ObjectDelete("FiboZZPrev");
          //  ObjectCreate("FiboZZPrev", OBJ_FIBO, 0, TimeTmp, ExtMapBuffer2[w], TimeTmp, price);
          //  ObjectSet("FiboZZPrev", OBJPROP_LEVELCOLOR, Blue);
          //  ObjectSet("FiboZZPrev", OBJPROP_COLOR, Blue);
           // ObjectSet("FiboZZPrev", OBJPROP_RAY , False );
          //}  
          
        }
        wave_cnt++;  
        price=ExtMapBuffer2[w];
        TimeTmp=Time[w];
    }
	
 }


//----
   return(0);
  }
//+------------------------------------------------------------------+