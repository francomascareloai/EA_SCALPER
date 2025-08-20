//WallStreetRobot_v4.5_nodll
// + FFCal (FXTS)


extern int Tick =1;
extern int Magic = 46985;
extern string OrdersComment = "";
extern double MaxSpread = 3.5;
extern int Slippage = 0;
extern bool CloseOnlyOnProfit = TRUE;

extern string CS = "==== Custom Settings ====";
extern int StopLoss = 200;
extern int TakeProfit = 300;
extern int ProfitBU = 30;
extern int PipBU = 10;

extern string UseSettingsFrom = "EURUSD";
extern string MM = "==== Risk Management ====";
//extern bool RecoveryMode = FALSE;
extern double FixedLots = 0.1;
extern double AutoMM = 0.0;
//extern double AutoMM_Max = 20.0;
//extern int MaxAccountTrades = 0;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////|
extern string O1="==== OPTIMIZATION PARAMETERS ====";///////////////////////////////////////////////////////////////////////////////////////////////////////////|
//extern string O2="=========== DISABLED IF ============";///|EURUSD|EURUSD| EUR33 |GBPUSD|GBPUSD| GBP52 |GBP52T| GBP30 |USDJPY|USDJPY|USDCHF|USDCAD|AUDUSD|NZDUSD|
//extern string O3="==== <USECUSTOMPAIR> = TRUE ====";///////|------| _new |-------|------| _new |-------|------|-------|------| _new |------|------|------|------|
//extern string O4="======= Use it only for optimization ======";///|//////|///////|//////|//////|///////|//////|///////|//////|//////|//////|//////|//////|//////|
extern int iMA_Period = 75;                        //   1  |  75  |  75  |  75   |  75  |  75  |  75   |  75  |  75   |  85  |  85  |  70  |  65  |  75  |  45  |
extern int iMA_Filter_Open_b = 390;                 //   2  |  39  |  30  |  42   |  33  |  34  |  30   |  21  |  39   |  21  |  10  |  25  |  15  |  33  |  70  |
extern int iWPR_Filter_OpenSignal_b = 5;           //   3  |   5  |   5  |   5   |   6  |   6  |   6   |   6  |   6   |   5  |   3  |   9  |  11  |   2  |   2  |
extern int iMA_Filter_Open_a = 150;                 //   4  |  15  |  17  |  42   |  12  |  12  |  12   |   3  |  13   |   5  | -14  |   8  |   5  |  13  |  14  |
extern int iWPR_Filter_OpenSignal_a = 1;           //   5  |   1  |   1  |   5   |   1  |   1  |   2   |   3  |   2   |   1  |   1  |   5  |   1  |   2  |   2  |
extern int iWPR_Filter_Close = 19;                 //   6  |  19  |  15  |  14   |  19  |  19  |  25   |  33  |  22   |  27  |  28  |  22  |   6  |  12  |  -5  |
extern int MaxLossPoints = -65;                    //   7  | -65  |   0  |  -5   |-200  | -30  | -30   | -25  | -50   | -80  |-200  | -40  | -30  | -40  | -40  |
extern int iWPR_Period = 11;                       //   8  |  11  |  11  |  10   |  12  |  12  |  12   |  12  |  22   |  12  |  12  |  12  |  16  |  18  |  15  |
//extern int Price_Filter_Close = 14;                //   9  |  14  |  14  |  14   |  18  |  13  |  10   |  13  |  11   |  13  |  10  |  11  |  14  |   8  |  20  |
extern int iWPR_Close_Period = 11;                  //  14  |   0  |   0  |   1   |   0  |   0  |   0   |   0  |   0   |   0  |   1  |   0  |   0  |   0  |   0  |
extern int iCCI_OpenFilter = 200;                  //  17  | 150  | 155  | 190   | 290  | 250  | 240   | 160  | 240   |2000  | 190  | 170  | 130  | 140  | 120  |
extern int iCCI_Period = 18;                       //  18  |  18  |  18  |   5   |  12  |  11  |  10   |  12  |  10   |  12  |  12  |  14  |  12  |  18  |  18  |
extern int iCCI_PriceOpenFilter = 450;
extern double DM_Filter_Open = 0.1;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


void init() {
  return (0);
}

int deinit() {

   return (0);
}

int start() 
{
   if(Volume[0]>Tick)return(0);
   int b=0,s=0,n=0,ob=0,os=0;
   if (DayOfWeek() == 1 && iVolume(NULL, PERIOD_D1, 0) < 5.0) return (0);
   if (StringLen(Symbol()) < 6) return (0);
        double Lot=0;
        int m;
        double MG;

        MG=AccountFreeMargin();       
        double Min_Lot = MarketInfo(Symbol(), MODE_LOTSTEP);             
        if(AutoMM>0)
        {
        m=MG/MarketInfo (Symbol(), MODE_MARGINREQUIRED)*AutoMM*0.01/Min_Lot;
        Lot = m*Min_Lot;
        if(Lot < MarketInfo(Symbol(), MODE_MINLOT))
        Lot =MarketInfo(Symbol(), MODE_MINLOT);            
        if(Lot > MarketInfo (Symbol(), MODE_MAXLOT))
        Lot = MarketInfo (Symbol(), MODE_MAXLOT);                  
        }
        if(AutoMM==0)Lot= FixedLots;

//-------------------------------------------------------------+   
 
   double clos = iClose(NULL, 1, 1);
   double ma = iMA(NULL, 1, iMA_Period, 0, 2, 0, 1);
   double ma1 = iMA(NULL, 1, iMA_Period, 0, 2, 0, 1);
   double wpr = iWPR(NULL, 1, iWPR_Period, 1);
   double wpr2 = iWPR(NULL, 1, iWPR_Close_Period, 1);
   double cci = iCCI(NULL, 1, iCCI_Period, PRICE_TYPICAL, 1);
   double dm = iDeMarker(NULL, 1, 2, 0);  
   
   if(Volume[0]<3&&(dm<=DM_Filter_Open||DM_Filter_Open==0)&&((clos>=ma+iMA_Filter_Open_a*Point&&wpr<=-100+iWPR_Filter_OpenSignal_a)
   ||(clos>=ma+iMA_Filter_Open_b*Point&&wpr<=-100+iWPR_Filter_OpenSignal_b)))ob=1;
   
   if(Volume[0]<3&&(dm>=1-DM_Filter_Open||DM_Filter_Open==0)&&((clos<=ma1-iMA_Filter_Open_a*Point&&wpr>=0-iWPR_Filter_OpenSignal_a)
   ||(clos<=ma1-iMA_Filter_Open_b*Point&&wpr>=0-iWPR_Filter_OpenSignal_b))) os=1;     
    for (int q = OrdersTotal(); q >=0; q--)   
   {
      OrderSelect(q, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()&&OrderMagicNumber()==Magic)
      {
       if(OrderType()==OP_BUY||OrderType()==OP_BUYSTOP)b++;
       if(OrderType()==OP_SELL||OrderType()==OP_SELLSTOP)s++;
       if(OrderType()==OP_BUY&&OrderStopLoss()==0)//Volume[0]<2)
         {
         OrderModify(OrderTicket(),OrderOpenPrice(),Bid - StopLoss*Point,Ask+TakeProfit*Point, 0, CLR_NONE);
         }
       if(OrderType()==OP_SELL&&OrderStopLoss()==0)//Volume[0]<2)
         {
         OrderModify(OrderTicket(),OrderOpenPrice(),Ask + StopLoss*Point,Bid-TakeProfit*Point, 0, CLR_NONE);
         }
           
       if(OrderType()==OP_BUY&&Bid>=OrderOpenPrice()+ProfitBU*Point)//Volume[0]<2)
         {
         OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+PipBU*Point,OrderTakeProfit(), 0, CLR_NONE);
         }
       if(OrderType()==OP_SELL&&Ask<OrderOpenPrice()-ProfitBU*Point)//Volume[0]<2)
         {
         OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-PipBU*Point,OrderTakeProfit(), 0, CLR_NONE);
         } 
       //if(OrderType()==OP_SELLSTOP&&OrderOpenPrice()<Bid-20*Point)OrderModify(OrderTicket(),Bid-20*Point,0,0, OrderExpiration(), CLR_NONE);
       //if(OrderType()==OP_BUYSTOP&&OrderOpenPrice()>Ask+20*Point)OrderModify(OrderTicket(),Ask+20*Point,0,0, OrderExpiration(), CLR_NONE);  
       
 
             
       if(OrderType()==OP_BUY&&wpr2>0-iWPR_Filter_Close&&(OrderProfit()+OrderCommission()>0||CloseOnlyOnProfit != TRUE))OrderClose(OrderTicket(),OrderLots(),Bid,0,CLR_NONE);
       if(OrderType()==OP_SELL&&wpr2<-100+iWPR_Filter_Close&&(OrderProfit()+OrderCommission()>0||CloseOnlyOnProfit != TRUE))OrderClose(OrderTicket(),OrderLots(),Ask,0,CLR_NONE);                  
       n++;
      }
   }  
  if(Ask-Bid<MaxSpread*Point&&DayOfWeek( ) !=0&&DayOfWeek() !=6)
  {
   if(b==0&&ob==1)
   {OrderSend(Symbol(),OP_BUY,Lot,Ask,0,0,0,OrdersComment,Magic,0,Lime);return(0);}
   
   if(s==0&&os==1)
   {OrderSend(Symbol(),OP_SELL,Lot,Bid,0,0,0,OrdersComment,Magic,0,Red);return(0);}
  }
return(0);
}