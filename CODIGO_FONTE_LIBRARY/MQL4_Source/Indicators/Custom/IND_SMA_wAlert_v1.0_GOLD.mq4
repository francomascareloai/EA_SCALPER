//Original function header with author/copywrite details missing

//modified by jeanlouie, forexfactory.com, 29 aug 2020
// - request for alerts
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
//#property indicator_color3 Magenta
//#property indicator_color4 DodgerBlue

datetime PreBarTime;
bool NotSameBar=True;

extern bool EachTickMode = False;
extern int Fast_MA_Period = 1;
extern int Slow_MA_Period = 34;
extern int  Signal_period = 5;
extern string alert_TOP = "TOP";
extern string alert_BOTTOM = "BOTTOM";
extern bool alert_pop = false;
extern bool alert_push = false;
extern bool alert_email = false;

double      Buffer1[],
            Buffer2[],
            b2[],
            b3[];
double BuySignal,SellSignal;            
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
// two additional buffers used for counting
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,3);
   SetIndexArrow(0,242);  // down  226 234  242
// SetIndexStyle(0,DRAW_LINE,EMPTY,3);
   SetIndexBuffer(0,b2);
   
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,3);
   SetIndexArrow(1,241);   //UP   225  233 241
//  SetIndexStyle(1,DRAW_LINE,EMPTY,3);
   SetIndexBuffer(1,b3);
// These buffers are not plotted, just used to determine arrows
// SetIndexStyle(2,DRAW_LINE,EMPTY,1);
   SetIndexBuffer (2,Buffer1);
// SetIndexStyle(3,DRAW_LINE,EMPTY,1);
   SetIndexBuffer (3,Buffer2);
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    
   int    i, counted_bars=IndicatorCounted();
   double MA5,MA34;
   int limit=Bars-counted_bars;
   // Print(" print limit = ", limit);
   if(counted_bars>0) limit++;
   
   if(PreBarTime!=Time[0])
   {
        NotSameBar=True;
        PreBarTime=Time[0]; 
   }
   
      // Main line
      for(i=0; i<limit; i++)
      {
         MA5=iMA(NULL,0,Fast_MA_Period,0,MODE_SMA,PRICE_MEDIAN,i);
         MA34=iMA(NULL,0,Slow_MA_Period,0,MODE_SMA,PRICE_MEDIAN,i);
      
         Buffer1[i]=MA5-MA34;
      }       
      
      //if( (NotSameBar==True && EachTickMode == False) || EachTickMode == True )
      {
      // Signal line
      for(i=0; i<limit; i++)
      {
         Buffer2[i]=iMAOnArray(Buffer1,Bars,Signal_period,0,MODE_LWMA,i);
      }//end for
         
      // Displaying Arrows
      for(i=0; i<limit; i++)
      {
         if(Buffer1[i] > Buffer2[i] && Buffer1[i-1] < Buffer2[i-1])
         {
               b2[i] = High[i]+10*Point;      
               if(b2[i] != EMPTY_VALUE && b2[i] != BuySignal ) 
               {
                  BuySignal=b2[i];
                  //Print( TimeToStr(TimeCurrent(), TIME_MINUTES) + ", Indicator Send Sell Signal");
               }
         }
         if(Buffer1[i] < Buffer2[i] && Buffer1[i-1] > Buffer2[i-1])
         {
               b3[i] = Low[i]-10*Point; 
               if(b3[i] != EMPTY_VALUE && b3[i] != SellSignal ) 
               {
                  SellSignal=b3[i];     
                  //if(b3[i] != EMPTY_VALUE) Print( TimeToStr(TimeCurrent(), TIME_MINUTES) + ", Indicator Send Buy Signal");
               }
         }
      }//end for
      
      if(IndicatorCounted()>0){
         if(b2[1] < b3[1]){alert_function(alert_TOP);}
         if(b2[1] > b3[1]){alert_function(alert_BOTTOM);}
      }
      
      //Print("Time:" + TimeToStr(TimeCurrent(),TIME_MINUTES));
      NotSameBar=False;
   }   
   return(0);
  }
//+------------------------------------------------------------------+
void alert_function(string which)
{
   static int prev_bars;
   if(Bars!=prev_bars){
      prev_bars = Bars;
      string msg = Symbol()+" "+IntegerToString(Period())+", New "+which+" Signal @"+TimeToString(Time[1]);
      if(alert_pop==true)Alert(msg);
      if(alert_pop==true)SendNotification(msg);
      if(alert_email==true)SendMail(Symbol()+" SMA Alert "+which,msg);
   }

}
