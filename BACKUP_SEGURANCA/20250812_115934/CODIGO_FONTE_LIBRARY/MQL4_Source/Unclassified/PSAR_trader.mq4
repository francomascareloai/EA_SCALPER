//+------------------------------------------------------------------+
//|                                                         Vita.mq4 |
//|                            Copyright © 2012, www.FxAutomated.com |
//|                                       http://www.FxAutomated.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, www.FxAutomated.com"
#property link      "http://www.FxAutomated.com"

//---- input parameters
extern string    Visit="www.fxautomated.com for more products";
extern string    SignalsAndManagedAccounts="www.TradingBug.com";
extern double    Lots=0.1;
extern int       Slip=5;
extern string    StopSettings="Set stops below";
extern double    TakeProfit=50;
extern double    StopLoss=50;
extern string    PSARsettings="Parabolic sar settings follow";
extern double    Step    =0.001;   //Parabolic setting
extern double    Maximum =0.2;    //Parabolic setting
extern bool      CloseOnOpposite=true;
extern string    TimeSettings="Set the hour range the EA should trade";
extern int       StartHour=0;
extern int       EndHour=23;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   Alert("Visit www.FxAutomated.com for more goodies!");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
int digits=MarketInfo("EURUSD",MODE_DIGITS);
int StopMultd=10;
int Slippage=Slip*StopMultd;

int MagicNumber1=220101,MagicNumber2=220102,i,closesell=0,closebuy=0;

//------------------------------------------------------------

double  TP=NormalizeDouble(TakeProfit*StopMultd,Digits);
double  SL=NormalizeDouble(StopLoss*StopMultd,Digits);



double slb=NormalizeDouble(Ask-SL*Point,Digits);
double sls=NormalizeDouble(Bid+SL*Point,Digits);


double tpb=NormalizeDouble(Ask+TP*Point,Digits);
double tps=NormalizeDouble(Bid-TP*Point,Digits);

//-------------------------------------------------------------------+
//Check open orders
//-------------------------------------------------------------------+
if(OrdersTotal()>0){
  for(i=1; i<=OrdersTotal(); i++)          // Cycle searching in orders
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // If the next is available
        {
          if(OrderMagicNumber()==MagicNumber1) {int halt1=1;}
          if(OrderMagicNumber()==MagicNumber2) {int halt2=1;}

        }
     }
}
//-------------------------------------------------------------------+
// time check
//-------------------------------------------------------------------
if((Hour()>=StartHour)&&(Hour()<=EndHour))
{
int TradeTimeOk=1;
}
else
{ TradeTimeOk=0; }
//-----------------------------------------------------------------
// Bar checks
//-----------------------------------------------------------------

 
 //-------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------------
// Opening criteria
//-----------------------------------------------------------------------------------------------------

Comment("For more goodies, managed accounts, forex signals and premium EAs visit www.FxAutomated.com");

// Open buy
 if((iSAR(NULL, 0,Step,Maximum, 0)<iClose(NULL,0,0))&&(iSAR(NULL, 0,Step,Maximum, 1)>iClose(NULL,0,1))&&(TradeTimeOk==1)&&(halt1!=1)){
 int openbuy=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slippage,0,0,"PSAR trader buy order",MagicNumber1,0,Blue);
 if(CloseOnOpposite==true)closesell=1;
 }


// Open sell
 if((iSAR(NULL, 0,Step,Maximum, 0)>iClose(NULL,0,0))&&(iSAR(NULL, 0,Step,Maximum, 1)<iClose(NULL,0,1))&&(TradeTimeOk==1)&&(halt2!=1)){
 int opensell=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slippage,0,0,"PSAR trader sell order",MagicNumber2,0,Green);
 if(CloseOnOpposite==true)closebuy=1;
 }


//-------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------
// Closing criteria
//-------------------------------------------------------------------------------------------------

if(closesell==1||closebuy==1||openbuy<1||opensell<1){// start

if(OrdersTotal()>0){
  for(i=1; i<=OrdersTotal(); i++){          // Cycle searching in orders
  
      if (OrderSelect(i-1,SELECT_BY_POS)==true){ // If the next is available
        
          if(OrderMagicNumber()==MagicNumber1&&closebuy==1) { OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,CLR_NONE); }
          if(OrderMagicNumber()==MagicNumber2&&closesell==1) { OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,CLR_NONE); }
          
          // set stops
          if((OrderMagicNumber()==MagicNumber1)&&(OrderTakeProfit()==0)&&(OrderSymbol()==Symbol())){ OrderModify(OrderTicket(),0,OrderStopLoss(),tpb,0,CLR_NONE); }
          if((OrderMagicNumber()==MagicNumber2)&&(OrderTakeProfit()==0)&&(OrderSymbol()==Symbol())){ OrderModify(OrderTicket(),0,OrderStopLoss(),tps,0,CLR_NONE); }
          if((OrderMagicNumber()==MagicNumber1)&&(OrderStopLoss()==0)&&(OrderSymbol()==Symbol())){ OrderModify(OrderTicket(),0,slb,OrderTakeProfit(),0,CLR_NONE); }
          if((OrderMagicNumber()==MagicNumber2)&&(OrderStopLoss()==0)&&(OrderSymbol()==Symbol())){ OrderModify(OrderTicket(),0,sls,OrderTakeProfit(),0,CLR_NONE); }

        }
     }
}


}// stop

//----
int Error=GetLastError();
  if(Error==130){Alert("Wrong stops. Retrying."); RefreshRates();}
  if(Error==133){Alert("Trading prohibited.");}
  if(Error==2){Alert("Common error.");}
  if(Error==146){Alert("Trading subsystem is busy. Retrying."); Sleep(500); RefreshRates();}

//----

//-------------------------------------------------------------------
   return(0);
  }
//+------------------------------------------------------------------+