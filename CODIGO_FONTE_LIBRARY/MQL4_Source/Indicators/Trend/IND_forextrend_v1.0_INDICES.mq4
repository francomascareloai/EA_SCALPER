//+------------------------------------------------------------------+
//|                                                 SilverTrend .mq4 |
//|                             SilverTrend  rewritten by CrazyChart |
//|                                                 http://viac.ru/  |
//+------------------------------------------------------------------+
#property copyright "SilverTrend  rewritten by CrazyChart"
#property link      "http://viac.ru/ "

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DeepSkyBlue  //Red  //Aqua
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Yellow
//---- input parameters

double buycntr , sellcntr;
extern int       SSP=7;
extern double    Kmin=1.6;
extern double    Kmax=50.6; //24 21.6 21.6 
extern int       CountBars=300;



//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double Bufferup[];
double Bufferdwn[];
double up , down ,val1prev , val2prev;

buycntr=0;
sellcntr=0;
up=1;
down=1;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE,0,2,DeepSkyBlue);  //Red
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE,0,2,Red);  //Aqua
   SetIndexBuffer(1,ExtMapBuffer2);
   
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1,Red);  //SELL
   SetIndexBuffer(2,Bufferdwn);
   SetIndexArrow(2,234);
   
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,Yellow);  //BUY
   SetIndexBuffer(3,Bufferup);
   SetIndexArrow(3,233);
 
      
   
  // IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   
   //===============SHORT NAME========================================   
   string short_name;
   short_name="FxTrend("+SSP+")";
    IndicatorShortName(short_name);
     SetIndexLabel(0,short_name);

   
   
//----
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
 
  if (CountBars>=Bars) CountBars=Bars;
   SetIndexDrawBegin(0,Bars-CountBars+SSP);
   SetIndexDrawBegin(1,Bars-CountBars+SSP);
  int i, i2,loopbegin,counted_bars=IndicatorCounted();
  double SsMax, SsMin, K, val1, val2, smin, smax, price; 
  
  if(Bars<=SSP+1) return(0);
  //---- initial zero

//K=33-RISK; 

/*
if (firstTime==true)   { 
   loopbegin = CountBars; 
   if (loopbegin>(Bars-2*SSP+1)) loopbegin=Bars-2*SSP+1; 
   firstTime=False; 
}; рудимент старой программы 
*/
  if(Bars<=SSP+1) return(0);
//---- initial zero

//+++++++
if(counted_bars<SSP+1)
   {
      for(i=1;i<=SSP;i++) ExtMapBuffer1[CountBars-i]=0.0;
      for(i=1;i<=SSP;i++) ExtMapBuffer2[CountBars-i]=0.0;
   }
//+++++++-SSP


for(i=CountBars-SSP;i>=0;i--) { 


  SsMax = High[Highest(NULL,0,MODE_HIGH,SSP,i-SSP+1)]; 
  SsMin = Low[Lowest(NULL,0,MODE_LOW,SSP,i-SSP+1)]; 
   smin = SsMin-(SsMax-SsMin)*Kmin/100; 
   smax = SsMax-(SsMax-SsMin)*Kmax/100;  
   ExtMapBuffer1[i-SSP+6]=smax; 
   ExtMapBuffer2[i-SSP-1]=smax; 
   val1 = ExtMapBuffer1[i]; 
   val2 = ExtMapBuffer2[i]; 
   val1prev = ExtMapBuffer1[i+1]; 
   val2prev = ExtMapBuffer2[i+1]; 


   if (val1 > val2 +Point*1 &&
      val1prev < val2prev &&
      up==1)
      {
      Bufferup[i]=(ExtMapBuffer2[i])- Point * 10;
      }
      
   if (val1 < val2 +Point*1 &&
      val1prev > val2prev &&
      down==1)
      {
      Bufferdwn[i]=(ExtMapBuffer1[i])+ Point * 10;
      }
    


/*
if (val1 > val2+Point*2) 
{
//Comment("Buy ",val1);
if (buycntr==0)
{
//Alert(Symbol()," ",Period(),"min  FXtrend BUY ","\n",
//      "      ","\n",
//      "Price = ",val1);
buycntr=buycntr+1;
sellcntr=0;
}
}

if (val1 < val2-Point*2) 
{
//Comment("Sell ",val2);
if (sellcntr==0)
{
//Alert(Symbol()," ",Period(),"min  FXtrend SELL ","\n",
//      "     ","\n",
//      "Price = ",val2);
sellcntr=sellcntr+1;
buycntr=0;
}
*/


}
return(0);
}