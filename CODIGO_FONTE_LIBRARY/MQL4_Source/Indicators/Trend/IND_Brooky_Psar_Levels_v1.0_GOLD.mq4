//+------------------------------------------------------------------+
//|                                           Brooky_Psar_Levels.mq4 |
//|                     Copyright © 2010, www.Brooky-Indicators.com. |
//|                             http://www.www.Brooky-Indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, www.Brooky-Indicators.com."
#property link      "http://www.www.Brooky-Indicators.com"
extern string Hello_From = " www.Brooky-Indicators.com ";

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DarkOrange
#property indicator_color2 DodgerBlue
//---- input parameters
extern int          bars_back = 200;
extern double       sar_step = 0.02;
extern double       sar_max = 0.2;
extern int          level_style = 2;
extern int          price_size = 2;
extern color        lowpsar =  DodgerBlue;
extern color        hipsar = DarkOrange;
string              indi = "Brooky-Psar";
//---- buffers
double plow[];
double phi[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,118);
   SetIndexBuffer(0,plow);
   SetIndexEmptyValue(0,0.0);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,118);
   SetIndexBuffer(1,phi);
   SetIndexEmptyValue(1,0.0);
   
   IndicatorShortName(indi);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
     for(int j=0; j<bars_back; j++)
     {
     string timedelete = TimeToStr(iTime(NULL,0,j));
     
     ObjectDelete(indi+"Sup"+timedelete);
     ObjectDelete(indi+"Res"+timedelete);
     ObjectDelete(indi+"aUp"+timedelete);
     ObjectDelete(indi+"aDn"+timedelete);
     
     
     }
     Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
  int start()
    {
     int limit;
     int counted_bars=IndicatorCounted();
  //---- check for possible errors
     if(counted_bars<0) return(-1);
  //---- the last counted bar will be recounted
     if(counted_bars>0) counted_bars--;
     limit=Bars-counted_bars;

     if(limit>bars_back)limit=bars_back;
  //---- main loop
     double mysarnow,myopen,mysarb4,myopenb4;
 

     for(int i=0; i<limit; i++)
       {


     string bardelete = TimeToStr(iTime(NULL,0,i));
     string firstbardelete = TimeToStr(iTime(NULL,0,bars_back));
     
     
     ObjectDelete(indi+"Sup"+firstbardelete);
     ObjectDelete(indi+"Res"+firstbardelete);
     ObjectDelete(indi+"aUp"+firstbardelete);
     ObjectDelete(indi+"aDn"+firstbardelete);

  
 
        mysarnow = iSAR(NULL,0,sar_step,sar_max,i);
        mysarb4 = iSAR(NULL,0,sar_step,sar_max,i+1);
        
        myopen = iOpen(NULL,0,i);
        myopenb4 = iOpen(NULL,0,i+1);
        
        if(mysarnow>=myopen && mysarb4<myopenb4)
         {
                     plow[i]=mysarnow;
                     
                     
              	      string res = indi+"Res"+bardelete;

              	      
                     ObjectCreate(res, OBJ_HLINE, 0, Time[i], mysarnow);
                     ObjectSet(res, OBJPROP_STYLE, level_style);
                     ObjectSet(res, OBJPROP_COLOR,hipsar);
                     ObjectSet(res, OBJPROP_RAY,1);
                     
                     string named = indi+"aDn"+bardelete;

                     ObjectCreate(named,OBJ_ARROW, 0, Time[i], mysarnow);
                     ObjectSet(named, OBJPROP_STYLE, STYLE_SOLID);
                     ObjectSet(named, OBJPROP_ARROWCODE, 5);
                     ObjectSet(named, OBJPROP_COLOR,hipsar);
                     ObjectSet(named, OBJPROP_WIDTH,price_size);
                     
                     
         }else plow[i]=0.0;
        
        
        
        if(mysarnow<=myopen && mysarb4>myopenb4)
        {

                     phi[i]=mysarnow;
              	      string sup = indi+"Sup"+bardelete;
              	      
                     ObjectCreate(sup, OBJ_HLINE, 0, Time[i], mysarnow);
                     ObjectSet(sup, OBJPROP_STYLE, level_style);
                     ObjectSet(sup, OBJPROP_COLOR,lowpsar);
                     ObjectSet(sup, OBJPROP_RAY,1);
         
                     string nameu = indi+"aUp"+bardelete;
                     
                     ObjectCreate(nameu,OBJ_ARROW, 0, Time[i], mysarnow);
                     ObjectSet(nameu, OBJPROP_STYLE, STYLE_SOLID);
                     ObjectSet(nameu, OBJPROP_ARROWCODE, 5);
                     ObjectSet(nameu, OBJPROP_COLOR,lowpsar);
                     ObjectSet(nameu, OBJPROP_WIDTH,price_size);
               
               
         }else phi[i]=0.0;
         

       }
  //---- done
     return(0);
    }
//+------------------------------------------------------------------+

