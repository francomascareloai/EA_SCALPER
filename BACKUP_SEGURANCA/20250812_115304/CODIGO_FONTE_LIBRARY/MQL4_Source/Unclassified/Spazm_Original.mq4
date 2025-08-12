//+------------------------------------------------------------------+
//|                                                    Plech_vol.mq4 |
//|                                                      space cowboy|
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Lizhniyk E"
#property link      "http://www.metaquotes.net"

extern double k=5.0;//множитель для открытия сделки относит. текущей волатильности т.е. движение_для_открытия=волатильность_за_период*k 
extern int period=24;//период для расчёта волатильности в барах
extern int exp=0;//режим сглаживания волатильности 0-постое скользящее 1-линейно-взвешенное 
extern int open_close=0;//режим расчёта волатильности по 1-open/close, 0-High/Low
extern double SL_pp=0;//установка стопа в процентах от состоявшегося движеня (от 0 до 1, 0-стоп не ставим вообще)
extern bool visualize=true; //отрисовка движений

//extern double rsi=70;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int spread, stoplevel, freeze;
int tf=4; 

double lh=0, ll=0;
bool trend;
double udat[100000][2];
int ucnt=0;
double ddat[100000][2];
int dcnt=0;
int tc, tl=0, th=0;
double koef[];
int plech=0;
int ttf;

int init()
  {
//----
  int highest=iHighest(NULL,0,MODE_HIGH,period*3,0);
  int lowest=iLowest(NULL,0,MODE_LOW,period*3,0);
  if(highest<lowest) {trend=false;} 
  else {trend=true;} 
  
  lh=High[highest]; th=Time[highest]; udat[ucnt][0]=High[highest]; 
  udat[ucnt][1]=Time[highest]; udat[ucnt][2]=1; ucnt++;
  ll=Low[highest]; tl=Time[highest]; ddat[dcnt][0]=Low[lowest]; 
  ddat[dcnt][1]=Time[lowest]; ddat[dcnt][2]=1; dcnt++;

  //**************
  plech=calc_vol()*k;
  //**************
  if(period<1) period=1; 
  ArrayResize(koef, period);
  double val=2.0/period;
  double inc=2.0;
  for(int j=0;j<period;j++)
    {
    koef[j]=inc;
    inc-=val;
    }
  //*********************  
  stoplevel=MarketInfo(Symbol(), MODE_STOPLEVEL)+1;
  spread=MarketInfo(Symbol(), MODE_SPREAD);
  freeze=MarketInfo(Symbol(), MODE_FREEZELEVEL)+1; 
  //***********************
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
bool work=true;
int tmp;
double vol=0;
double positive=0, negative=0, per, prsi=0;
int objs=0;
double nakl=0;

int start()
  {
//----
  tc=TimeCurrent(); 
  //***********************
  int tfbars=Bars;
  if(tmp!=tfbars)
   {
   plech=calc_vol()*k;
   }
  tmp=tfbars; 
  //************************
  if(Bid>lh) {lh=Bid;th=tc;} 
  if(Bid<ll) {ll=Bid;tl=tc;} 
  //************************
  if(trend && Bid<lh-plech*Point)
        {
        trend=false;
        if(ucnt>99999) ucnt=0;
        udat[ucnt][0]=lh;
        udat[ucnt][1]=th;
        ucnt++;
        if(visualize) vis();
        ll=Bid; tl=tc;   
        close_all();
        //sell();
        buy();
        }
   if(!trend && Bid>ll+plech*Point)
        {
        trend=true;
        if(dcnt>99999) dcnt=0;
        ddat[dcnt][0]=ll;
        ddat[dcnt][1]=tl;
        dcnt++;
        if(visualize) vis();
        lh=Bid; th=tc;
        close_all();
        //buy();
        sell();
        }
  //*************************** 
//----
   return(0);
  }
//+------------------------------------------------------------------+
void close_all()
{
int tot=OrdersTotal();
for(int i=0;i<tot;i++)
 {
 OrderSelect(i,SELECT_BY_POS);
 if(OrderType()==0) OrderClose(OrderTicket(),OrderLots(),Bid,0);
 if(OrderType()==1) OrderClose(OrderTicket(),OrderLots(),Ask,0);
 }
}

int sell()
{
double ssl=0;
if(SL_pp>0)
 {
 int ppl=plech*SL_pp;
 if(ppl<stoplevel) ppl=stoplevel;
 ssl=NormalizeDouble(Ask+ppl*Point, Digits);
 }
int t=-1;
t=OrderSend(Symbol(),OP_SELL,1,Bid,0,ssl,0,"order_sell",29072007,0,0x0000FF);
return(t);
}

int buy()
{
double ssl=0;
if(SL_pp>0)
 {
 int ppl=plech*SL_pp;
 if(ppl<stoplevel) ppl=stoplevel;
 ssl=NormalizeDouble(Bid-ppl*Point, Digits);
 }
int t=-1;
t=OrderSend(Symbol(),OP_BUY,1,Ask,0,ssl,0,"order_buy",19072007,0,0xFF0000);
return(t);
}

void vis()
{
string nnn=TimeToStr(tc)+" "+DoubleToStr(objs,0);
ObjectCreate(nnn,OBJ_TREND,0,ddat[dcnt-1][1],ddat[dcnt-1][0],udat[ucnt-1][1],udat[ucnt-1][0]);
ObjectSet(nnn,OBJPROP_RAY,false);
objs++;
}

double calc_vol()
{
double res=0;
for(int j=0;j<period;j++)
 {
 if(!open_close)
  {
  if(!exp)
  res+=(High[j+1]-Low[j+1])/Point;
  else res+=((High[j+1]-Low[j+1])/Point) * koef[j];
  }
 else
  {
  if(!exp)
  res+=MathAbs(Open[j+1]-Close[j+1])/Point;
  else res+=(MathAbs(Open[j+1]-Close[j+1])/Point) * koef[j];
  } 
 }
res/=period; 
if(res==0) res=(High[2]-Low[2])/Point;
return(res);
}


