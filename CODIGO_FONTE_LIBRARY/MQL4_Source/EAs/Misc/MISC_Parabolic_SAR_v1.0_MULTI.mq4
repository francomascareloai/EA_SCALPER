//+------------------------------------------------------------------+
//|                                                  MyParabolic.mq4 |
//|                                                  Victor Karavaev |
//|                                               http://www.n-dv.ru |
//+------------------------------------------------------------------+
#property copyright "Victor Karavaev"
#property link      "http://www.n-dv.ru"

//---- input parameters
extern double Step=0.003;
extern double Maximum=0.08;
extern double lot = 2; // lot
extern int SL = 500; 

//extern bool Alert_Sound=true;
//---- buffers
double SarBuffer[];
double MaBuffer[];
double ep,sar,price_low,price_high,price; 
//----
int    save_lastreverse;
bool   save_dirlong;
double save_start;
double save_last_high;
double save_last_low;
double save_ep;
double save_sar;
//---- ����� ����, �� �������� ����� �������� ������
#define SIGNAL_BAR 1

int ticket;
double iSAR_value;
int trendnew =3;
int trend;
int myparam;
int tsignal;

double Mybands;

#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
//---- indicators
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
int start()
  {
//----

price=iSAR(NULL,0,Step,Maximum,0);   
 
if(price>Close[SIGNAL_BAR]){tsignal=1;}
if(price<Close[SIGNAL_BAR]){tsignal=0;}
trendnew = trend;
trend=tsignal;

if(trend!=trendnew)
  {
   int t=OrdersTotal();
   while(t>=0)
     {

      if(OrderSelect(t,SELECT_BY_POS,MODE_TRADES)==true)
         if(OrderType()==OP_BUY) OrderClose(OrderTicket(),
            OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),0);
      if(OrderType()==OP_SELL) OrderClose(OrderTicket(),
         OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),0);
      t--;
     }
   ticket=-1;
   trendnew=trend;
   //Print("������: ",myparam," price: ",price,"  Close[SIGNAL_BAR]: ",Close[SIGNAL_BAR]);
  }
  
if(price>Close[SIGNAL_BAR])
  {  
   if(ticket<0)
     {ticket=OrderSend(Symbol(),OP_SELL,lot,Bid,3,SL,0,"Sell",0,0,Blue);}
  }

if(price<Close[SIGNAL_BAR])
  {
   if(ticket<0)
     {ticket=OrderSend(Symbol(),OP_BUY,lot,Ask,3,SL,0,"Buy",0,0,Red);}
  }     
//---- ����� ���������� ���� � ����������� ���������� �������
   static int PrevSignal=0, PrevTime=0;
//---- ���� ����� ��� ������� ������ �� 0-�, ��� ��� ������ ��������� ������
//---- ��������� ���. ���� �� ������� ����� ���, �������.
   if(SIGNAL_BAR > 0 && Time[0]<=PrevTime)
      return(0);
//---- ��������, ��� ���� ��� ��������
   PrevTime=Time[0];

//----
   return(0);
  }
//+------------------------------------------------------------------+