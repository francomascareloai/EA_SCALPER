//+------------------------------------------------------------------+
//|                                                 #PriceToOpen.mq4 |
//+------------------------------------------------------------------+
//edited
// - added option to compare price against a mtf ma instead of up to 4h open
// - removed tf limit of 4hr
// - histogram width option
// - histogram height from 0-2 to 0-1
// - strict

#property description "Price relative to Open Histogram"
#property strict

//#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_minimum 0
#property indicator_maximum 1
//#property indicator_color1 Lime
//#property indicator_color2 Red
//#property indicator_width1 2
//#property indicator_width2 2
//---- input parameters
enum customlist_0                          
{
   m_1   = 0,                                      //___Select TF___
   m_5   = 5,                                      //5 MINUTE                 
   m_15  = 15,                                     //15 MINUTE
   m_30  = 30,                                     //30 MINUTE
   m_60  = 60,                                     //1 HOUR
   h_4   = 240,                                    //4 HOUR
   d_1   = 1440,                                   //1 DAY
   w_1   = 10080,                                  //1 WEEK
   mn_1  = 43200,                                  //1 MONTH
};
enum customlist_1                          
{
   use_open = 0,                                   //MTF Open
   use_ma = 1,                                     //MTF MA
};
input customlist_1  use_open_or_ma = use_open;     //Use MTF Open or MA?
input  customlist_0    TimeFrame=h_4;              //TF?     
input int ma_period = 20;                          //MA period
input ENUM_MA_METHOD ma_method = MODE_SMA;         //MA type
input ENUM_APPLIED_PRICE ma_price = PRICE_CLOSE;   //MA price

input color histo_up_clr = clrLime;                //Histogram up color
input color histo_dn_clr = clrRed;                 //Histogram down color
input int histo_width = 2;                         //Histogram width    

//---- buffers
double up[];
double dn[];
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
void init() {
   string a1="";
   string a2 = "";
   if(ma_method==MODE_SMA){a2="SMA";}
   if(ma_method==MODE_EMA){a2="EMA";}
   if(ma_method==MODE_SMMA){a2="SMMA";}
   if(ma_method==MODE_LWMA){a2="LWMA";}
   if(use_open_or_ma==0){a1 = " (open, TF"+IntegerToString(TimeFrame)+")";}
   if(use_open_or_ma==1){a1 = " (MA, "+IntegerToString(ma_period)+a2+", TF"+IntegerToString(TimeFrame)+")";}
   
   IndicatorShortName("Price to MTF Open or MA"+a1);
  SetIndexBuffer(0,up);
  SetIndexBuffer(1,dn);
  SetIndexStyle(0,DRAW_HISTOGRAM,0,histo_width,histo_up_clr);
  SetIndexStyle(1,DRAW_HISTOGRAM,0,histo_width,histo_dn_clr);
  //SetIndexArrow(0,110);
  //SetIndexArrow(1,110);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){
  datetime TimeArray[];
  int      i,y,limit,counted_bars;
  double   opn, ma_opn;
  counted_bars=IndicatorCounted();
  if(counted_bars<1)limit=Bars-1;
  else              limit=Bars-counted_bars;
  
  //if(Period()>=240)return(0);  
  if(Period()>TimeFrame)return(0);
  
     ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
        if(use_open_or_ma==0)
        {
            for(i=0,y=0;i<limit;i++){
          
            if(Time[i]<TimeArray[y])y++;
          
            up[i]=EMPTY_VALUE;
            dn[i]=EMPTY_VALUE;
      
            opn=iOpen( Symbol(),TimeFrame,y);
            
            if(Close[i+0]>opn)up[i+0]=2;
            else              dn[i+0]=2;
              
            }
        }
        else if(use_open_or_ma==1)
        {
            for(i=0,y=0;i<limit;i++){

            if(Time[i]<TimeArray[y])y++;
            ma_opn = iMA(Symbol(),TimeFrame,ma_period,0,ma_method,ma_price,y);
            up[i]=EMPTY_VALUE;
            dn[i]=EMPTY_VALUE;
            if(Close[i] > ma_opn)
            {
               up[i]=2;
            }
            if(Close[i] < ma_opn)
            {
               dn[i]=2;
            }
            }
        }
  
  
//----
  
 return(0);
}
//+------------------------------------------------------------------+