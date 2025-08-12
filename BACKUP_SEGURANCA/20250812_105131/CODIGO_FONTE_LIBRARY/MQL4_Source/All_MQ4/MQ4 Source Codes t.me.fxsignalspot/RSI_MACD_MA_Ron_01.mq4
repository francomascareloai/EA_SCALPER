//+------------------------------------------------------------------+
//| MA + MACD + RSI                               |
//+------------------------------------------------------------------+
#property copyright "Ron T"
#property link      "http://www.lightpatch.com/forex"

#property indicator_chart_window
#property indicator_buffers 5

#property indicator_color1 Red
#property indicator_color2 White

#property indicator_color3 Aqua
#property indicator_color4 LightGreen

#property indicator_color5 DodgerBlue

extern int MovingAvg1=5;
extern int MovingAvg2=8;
extern int RSIPeriod=14;
extern int MACDfast=12;
extern int MACDslow=26;
extern int MACDsignal=9;

//---- buffers
double Buffer0[];
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|

int init()
  {
   // 233 up arrow
   // 234 down arrow
   // 241 hollow up
   // 242 hollow down
   // 159 big dot
   // 158 little dot
   // 168 open square
   // 120 box with X
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0, Buffer0);
   SetIndexArrow(0,242);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1, Buffer1);
   SetIndexArrow(1,241);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2, Buffer2);

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3, Buffer3);

   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4, Buffer4);

   return(0);
  }


//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   int i;
   
   for( i=0; i<Bars; i++ ) Buffer0[i]=0;
   for( i=0; i<Bars; i++ ) Buffer1[i]=0;
   for( i=0; i<Bars; i++ ) Buffer2[i]=0;
   for( i=0; i<Bars; i++ ) Buffer3[i]=0;
   for( i=0; i<Bars; i++ ) Buffer4[i]=0;

   return(0);
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+


int start()
  {
   int      pos=Bars-100; // leave room for moving average periods
   int      ctr=0;

   double p=Point();

   double  i0, i1, i2, i3, i4;
         
   
   while(pos>=0)
     {
      
      i0=iMA(Symbol(),0,MovingAvg1,0,PRICE_OPEN,MODE_EMA,pos);
      i1=iMA(Symbol(),0,MovingAvg2,0,PRICE_OPEN,MODE_EMA,pos);
      i2=iMACD(Symbol(),0,MACDfast,MACDslow,MACDsignal,PRICE_OPEN, MODE_SIGNAL,pos);
      i3=iRSI(Symbol(),0,RSIPeriod,PRICE_OPEN,pos);
      
      Buffer2[pos]=i0;
      Buffer3[pos]=i1;

      //Long
      if (i2>0 && i3>50)
        {
         Buffer1[pos]=High[pos];
        }
        
      //Short
      if (i2<0 && i3<50)
        {
         Buffer0[pos]=Low[pos]; 
        }
        

      
 	   pos--;
     }

   return(0);
  }
//+------------------------------------------------------------------+