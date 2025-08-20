//+------------------------------------------------------------------+
//|                                             AutoFibAutoTrend.mq4 |
//|                                                    zzuegg        |
//|                                       when-money-makes-money.com |
//+------------------------------------------------------------------+
#property copyright "zzuegg"
#property link      "when-money-makes-money.com"

#property indicator_chart_window
extern int period=0;
extern bool ShowFib=true;
extern color FibColor=Red;
extern int   FibSize=1;

extern bool ShowFibFan=true;
extern color FibFanColor=Yellow;
extern int FibFanSize=1;

extern bool ShowTrend=true;
extern color TrendColor=Blue;
extern int TrendSize=5;

string fib1="";
string trend="";
string fibf1="";
int init()
  {
   fib1="fib1"+period;
   trend="trend1"+period; 
   fibf1="fibf1"+period;  
   return(0);
  }

int deinit()
  {
   ObjectDelete(fib1);
   ObjectDelete(trend);
   ObjectDelete(fibf1);
   return(0);
  }


int start()
  {
   int    counted_bars=IndicatorCounted();
   static datetime curr=0;
   if(curr!=iTime(Symbol(),period,0)){
      curr=iTime(Symbol(),period,0);
      ObjectDelete(fib1);
      ObjectDelete(trend);
      double swing.value[4]={0,0,0,0};
      datetime swing.date[4]={0,0,0,0};
      int found=0;
      double tmp=0;
      int i=0;
      while(found<4){
         if(iCustom(Symbol(),period,"ZigZag",12,5,3,0,i)!=0){
            swing.value[found]=iCustom(Symbol(),period,"ZigZag",12,5,3,0,i);
            swing.date[found]=iTime(Symbol(),period,i);
            found++;
         }
         i++;
      }
      ObjectDelete(trend);
      if(ShowTrend){
      ObjectCreate(trend,OBJ_CHANNEL,0,swing.date[3],swing.value[3],swing.date[1],swing.value[1],swing.date[2],swing.value[2]);
      ObjectSet(trend,OBJPROP_COLOR,TrendColor);
      ObjectSet(trend,OBJPROP_WIDTH,TrendSize);
      }
      ObjectDelete(fib1);
      if(ShowFib){
      ObjectCreate(fib1,OBJ_FIBO,0,swing.date[2],swing.value[2],swing.date[1],swing.value[1]);
      ObjectSet(fib1,OBJPROP_LEVELCOLOR,FibColor);      
      ObjectSet(trend,OBJPROP_LEVELWIDTH,FibSize);
      }
      ObjectDelete(fibf1);
      if(ShowFibFan){
      ObjectCreate(fibf1,OBJ_FIBOFAN,0,swing.date[2],swing.value[2],swing.date[1],swing.value[1]);
      ObjectSet(fibf1,OBJPROP_LEVELCOLOR,FibFanColor);      
      ObjectSet(fibf1,OBJPROP_LEVELWIDTH,FibFanSize); 
      }
   }   

   Comment("Support us, donate on this website: www.when-money-makes-money.com/download");
   return(0);
  }