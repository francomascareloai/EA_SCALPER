//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "www.forex-tsd.com"
#property version     "1.02"
//------------------------------------------------------------------
//
// v1.01    9 dec 2020  Modified by jeanlouie, forexfactory.com/jeanlouie  mql5.com/en/users/jeanlouie_ff
// - added 2 simple moving average lines
// - separate inputs for periods
// v1.02    9 dec 2020  Modified by jeanlouie, forexfactory.com/jeanlouie  mql5.com/en/users/jeanlouie_ff
// - removed previous mod
// - replaced empty buffer values with non empty, indicators can now be applied to subwindow without inf result

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1

#property indicator_label1  "open;high;low;close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrLimeGreen,clrSandyBrown

//#property indicator_label2  "MA1"
//#property indicator_type2   DRAW_LINE
//#property indicator_color2  clrYellow
//
//#property indicator_label3  "MA2"
//#property indicator_type3   DRAW_LINE
//#property indicator_color3  clrRed

//
//
//
//
//

input int Seconds = 3;        // Seconds for candles interval
//input int ma_period_1 = 5;    //MA period 1
//input int ma_period_2 = 20;   //MA period 2

double canc[],cano[],canh[],canl[],colors[],seconds[][4];
double ma1[],ma2[];
#define sopen  0
#define sclose 1
#define shigh  2
#define slow   3
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,cano  ,INDICATOR_DATA);
   SetIndexBuffer(1,canh  ,INDICATOR_DATA);
   SetIndexBuffer(2,canl  ,INDICATOR_DATA);
   SetIndexBuffer(3,canc  ,INDICATOR_DATA);
   SetIndexBuffer(4,colors,INDICATOR_COLOR_INDEX);
   //SetIndexBuffer(5,ma1   ,INDICATOR_DATA);
   //SetIndexBuffer(6,ma2   ,INDICATOR_DATA);
      EventSetTimer(Seconds);
      IndicatorSetString(INDICATOR_SHORTNAME,(string)Seconds+" seconds chart");
   return(0);
}
void OnDeinit(const int reason)
{
   EventKillTimer();
}
void OnTimer()
{
   double close[]; CopyClose(_Symbol,_Period,0,1,close);
   int size = ArrayRange(seconds,0);
             ArrayResize(seconds,size+1);
                         seconds[size][sopen]  = close[0];
                         seconds[size][sclose] = close[0];
                         seconds[size][shigh]  = close[0];
                         seconds[size][slow]   = close[0];
   updateData();  
   
   //Print("canc size = ",ArraySize(canc));                       
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void updateData()
{
   int rates_total = ArraySize(canh);
   int size = ArrayRange(seconds,0); 
   double close[]; CopyClose(_Symbol,_Period,0,1,close);
      if (size<=0) 
      {
         for (int i=rates_total-1; i>=0; i--)
         {
            canh[i] = close[0];//EMPTY_VALUE;
            canl[i] = close[0];//EMPTY_VALUE;
            cano[i] = close[0];//EMPTY_VALUE;
            canc[i] = close[0];//EMPTY_VALUE;
            //ma1[i] = 1;//EMPTY_VALUE;
            //ma2[i] = 1;//EMPTY_VALUE;
         }
         return;
      }         
      seconds[size-1][shigh]  = MathMax(seconds[size-1][shigh] ,close[0]);
      seconds[size-1][slow]   = MathMin(seconds[size-1][slow]  ,close[0]);
      seconds[size-1][sclose] =                                 close[0];
   for (int i=(int)MathMin(rates_total-1,size-1); i>=0 && !IsStopped(); i--)
   {
      int y = rates_total-i-1;
         canh[y] = seconds[size-i-1][shigh ];
         canl[y] = seconds[size-i-1][slow  ];
         cano[y] = seconds[size-i-1][sopen ];
         canc[y] = seconds[size-i-1][sclose];
         colors[y] = cano[y]>canc[y] ? 2 : cano[y]<canc[y] ? 1 : 0; 
   }

//   if(size > MathMax(ma_period_1,ma_period_2)){
      static int prev_size;
      if(prev_size!=size){
         prev_size=size;
         ChartSetSymbolPeriod(0,_Symbol,PERIOD_CURRENT);
         //for (int i=(int)MathMin(rates_total-1-1,size-1); i>=0 && !IsStopped(); i--)
         //{
         //   ma1[rates_total-1-i-1] = ma1[rates_total-1-i];
         //   ma2[rates_total-1-i-1] = ma2[rates_total-1-i];
         //}
      }
//      double avg = 0;
//      for(int z=0; z<ma_period_1; z++){
//         avg+=canc[rates_total-1-z];
//      }
//      ma1[rates_total-1] = avg/(ma_period_1*1.0);
//      avg=0;
//      for(int z=0; z<ma_period_2; z++){
//         avg+=canc[rates_total-1-z];
//      }
//      ma2[rates_total-1] = avg/(ma_period_2*1.0);
//   
//   }

}

//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{ 
   int bars = Bars(_Symbol,_Period); if (bars<rates_total) return(-1); updateData();
   return(rates_total);
}