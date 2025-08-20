//+------------------------------------------------------------------+
//|                                                          AA+.mq4 |
//|                                                   vasbsm@mail.ru |
//+------------------------------------------------------------------+
#property copyright "@"
#property link      "zfs"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 OrangeRed
#property indicator_width1 4
#property indicator_width2 4
#property indicator_level1 20 //бай
#property indicator_level2 20 //селл
#property indicator_levelcolor Yellow
extern int JawsPeriod=13;
extern int JawsShift=8;
extern int TeethPeriod=8;
extern int TeethShift=5;
extern int LipsPeriod=5;
extern int LipsShift=3;
extern int TypeMA=MODE_SMMA;
extern int TypePrice=PRICE_MEDIAN;
//---- buffers
double OscBufferBuy[];
double OscBufferSell[];
//------------
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,OscBufferBuy);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,OscBufferSell);

   SetIndexDrawBegin(0,10);
   SetIndexDrawBegin(1,10);
   IndicatorShortName("AA+");
   return(0);
  }

int deinit()
  {
   ObjectsDeleteAll(0,OBJ_ARROW);
   return(0);
  }
int start()
  {
   int counted_bars=IndicatorCounted();
   int limit;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   int trend=0;
   int razvorot=0;
   double delta=0;
   string name_buy,name_sell;

   for(int i=0; i<limit; i++)
   {
     OscBufferBuy[i]=0;
     OscBufferSell[i]=0;
   }
   for(i=0; i<limit; i++)
   {
    double jaw=iAlligator(NULL,0,JawsPeriod,JawsShift,TeethPeriod,TeethShift,LipsPeriod,LipsShift,TypeMA,TypePrice,MODE_GATORJAW,i); 
    double lips=iAlligator(NULL,0,JawsPeriod,JawsShift,TeethPeriod,TeethShift,LipsPeriod,LipsShift,TypeMA,TypePrice,MODE_GATORLIPS,i);
    double high1=iHigh(NULL,0,i+1);
    double low1=iLow(NULL,0,i+1);
    double close1=iClose(NULL,0,i+1);
    double close0=iClose(NULL,0,i);
    
    if (lips>jaw)trend=1;
    if (lips<jaw)trend=-1;
    
    if (close1>(high1+low1)/2.0)razvorot=1;
    if (close1<(high1+low1)/2.0)razvorot=-1;
    
    if (trend==1)delta=close0-lips;
    if (trend==-1)delta=lips-close0;
    
    if (close0<lips&&trend==-1&&razvorot==1&&close0>high1)OscBufferBuy[i]=delta;
    if (close0>lips&&trend==1&&razvorot==-1&&close0<low1)OscBufferSell[i]=delta;

    name_buy="buy"+DoubleToStr(i,0);
    name_sell="sell"+DoubleToStr(i,0);
    
    if (OscBufferSell[i]>indicator_level2*Point)SetArrow(230,Red,name_sell,Time[i],High[i]+50*Point,1);
    if (OscBufferBuy[i]>indicator_level1*Point)SetArrow(228,Lime,name_buy,Time[i],Low[i]-50*Point,1); 
   }  
   return(0);
  }
void SetArrow(int cd, color cl,
              string nm="", datetime t1=0, double p1=0, int sz=0) {
  if (nm=="") nm=DoubleToStr(Time[0], 0);
  if (t1<=0) t1=Time[0];
  if (p1<=0) p1=Bid;
  if (ObjectFind(nm)<0) ObjectCreate(nm, OBJ_ARROW, 0, 0,0);
  ObjectSet(nm, OBJPROP_TIME1    , t1);
  ObjectSet(nm, OBJPROP_PRICE1   , p1);
  ObjectSet(nm, OBJPROP_ARROWCODE, cd);
  ObjectSet(nm, OBJPROP_COLOR    , cl);
  ObjectSet(nm, OBJPROP_WIDTH    , sz);
}

