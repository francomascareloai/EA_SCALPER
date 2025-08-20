//+------------------------------------------------------------------+
//|                                                 TrailingStop.mq4 |
//|                       Copyright © 2006, http://www.forex-tsd.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © Steve Wilson - Forex TSD Forum"
#property link      "http://www.forex-tsd.com"

//+--------------------------------------------------------------------+
// This trailing stoploss is made of features found in other Experts.  |
// 1. Trailing Stop Loss which is chart specific                       |
// 2. AllPositions - Trailing Stop Loss which is account specific      |
//    Attach to any chart and it will modify stop loss on all trades.  |
// 3. ProfitTrailing - Modify only trades that are in profit           |
// 4. Hedge Option - Does not open positions but will close all trades |
//    if a specified target is reached on your trading account.        |
//    Activate it by giving a value to ProfitTarget. Disables stop     |
//    loss by setting value to 5000                                    |
//+--------------------------------------------------------------------+

extern bool   AllPositions = false; // (True To modify all positions ) False(modify chart positions)
extern bool   ProfitTrailing = True; //(To Trail only postions on profit not loss ) 
extern int TrailingStop=5;    // Minimum is 5
extern int ProfitTarget=0;    // Setting this value will calculate all open trades and close if profit reached. 
extern int    TrailingStep   = 1;
extern bool   UseSound       = True;  
extern string NameFileSound  = "expert.wav"; 

bool runnable=true;
bool init=true;
bool result;
double pBid, pAsk, pp;
int i=0;

datetime timeprev=0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{

if (ProfitTarget>0)
{

TrailingStop=0;
ChartComment();
ClearStops();
CloseAllTrades();
  
}



if (AllPositions == false){
//+------------------------------------------------------------------+
//| Expert start function - Chart Specific                                           |
//+------------------------------------------------------------------+
 
// Clean the chart
if (ProfitTarget==0)
CleanChart();


//Trailing Stop
   TrailingAlls(TrailingStop);   
   
//Close/Open
   if(timeprev==Time[0])
    return(0);
   timeprev=Time[0];
    
return(0);
}
else
{
//+------------------------------------------------------------------+
//| Expert Start Function - All Positions                            |
//+------------------------------------------------------------------+

// Clean the chart
if (ProfitTarget==0)
CleanChart();

for (int i=0; i<OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      TrailingPositions();
    }
}
     return(0);
   }
}

void TrailingAlls(int trail)
{
   if (trail==0)
    return;
    
   double stopcrnt;
   double stopcal;
   
   int trade;
   int trades=OrdersTotal();
   
   for(trade=0;trade<trades;trade++)
   {
      OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
                
      if(OrderSymbol()!=Symbol())
       continue;
      
      pp = MarketInfo(OrderSymbol(), MODE_POINT); 
      
      
 //Long
      
      if(OrderType()==OP_BUY)
      {
         
         pBid = MarketInfo(OrderSymbol(), MODE_BID);
         if (!ProfitTrailing || (pBid-OrderOpenPrice())>TrailingStop*pp) {
         if (OrderStopLoss()<pBid-(TrailingStop+TrailingStep-1)*pp) {
                  
         stopcrnt=OrderStopLoss();
         stopcal=Bid-(trail*Point);
         if(stopcrnt==0)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
         }
         else
         {
            if(stopcal>stopcrnt)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Blue);
            }
         }
      }
      
         return;
   }
}//Long 
     
//Shrt
      if(OrderType()==OP_SELL)      
      {
         
         
    pAsk = MarketInfo(OrderSymbol(), MODE_ASK);
    if (!ProfitTrailing || OrderOpenPrice()-pAsk>TrailingStop*pp) {
      if (OrderStopLoss()>pAsk+(TrailingStop+TrailingStep-1)*pp || OrderStopLoss()==0) {
        
         stopcrnt=OrderStopLoss();
         stopcal=Ask+(trail*Point);
         if(stopcrnt==0)
         {
            OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
         }
         else
         {
            if(stopcal<stopcrnt)
            {
               OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
            }
         }      
      
      }
        return;
   }
}//Shrt
      
   }//for
   
}


//+------------------------------------------------------------------+
//| Functions for All Positions                                      |
//+------------------------------------------------------------------+
void TrailingPositions() {
//  double pBid, pAsk, pp;

  pp = MarketInfo(OrderSymbol(), MODE_POINT);
  if (OrderType()==OP_BUY) {
    pBid = MarketInfo(OrderSymbol(), MODE_BID);
    if (!ProfitTrailing || (pBid-OrderOpenPrice())>TrailingStop*pp) {
      if (OrderStopLoss()<pBid-(TrailingStop+TrailingStep-1)*pp) {
        ModifyStopLoss(pBid-TrailingStop*pp);
        return;
      }
    }
  }
  if (OrderType()==OP_SELL) {
    pAsk = MarketInfo(OrderSymbol(), MODE_ASK);
    if (!ProfitTrailing || OrderOpenPrice()-pAsk>TrailingStop*pp) {
      if (OrderStopLoss()>pAsk+(TrailingStop+TrailingStep-1)*pp || OrderStopLoss()==0) {
        ModifyStopLoss(pAsk+TrailingStop*pp);
        return;
      }
    }
  }
}

//+------------------------------------------------------------------+
//| Modify StopLoss                                                  |
//+------------------------------------------------------------------+
void ModifyStopLoss(double ldStopLoss) {
  bool fm;

  fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE);
  if (fm && UseSound) PlaySound(NameFileSound);
}
//+------------------------------------------------------------------+




void ChartComment()
{
   string sComment   = "";
   string sp         = "****************************\n";
   string NL         = "\n";

   sComment = NL + sp;
   sComment = sComment + "Current Profits (USD) = $" + DoubleToStr(AccountProfit(),2) + NL;
   sComment = sComment + "Profit Target (USD)   = $" + ProfitTarget + NL;
   sComment = sComment + "Open Trades            =   " + OrdersTotal() + NL;
   sComment = sComment + "Stop Loss Disabled    =  ("+ TrailingStop+")" + NL;
   sComment = sComment + NL + sp;
  
   Comment(sComment);
}	  

void CleanChart()
{
   string sComment   = "";
   string sp         = "****************************\n";
   string NL         = "\n";

   sComment = sComment + NL;
   sComment = sComment + NL;
   sComment = sComment + NL;
   sComment = sComment + NL;
   sComment = sComment + NL;
   sComment = sComment + NL;
   sComment = sComment + NL;
   Comment(sComment);
}	  

// Close all open trades when in profit
void CloseAllTrades(){
if (AccountProfit() >= ProfitTarget){
   for (i=OrdersTotal()-1;i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
             if (OrderType()==OP_SELL)result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,CLR_NONE);
             if(result!=TRUE) Print("LastError = ", GetLastError());
             if (OrderType()==OP_BUY)result=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,CLR_NONE);
             if(result!=TRUE) Print("LastError = ", GetLastError());
             if (OrderType()==OP_BUYSTOP)result=OrderDelete(OrderTicket());
             if(result!=TRUE) Print("LastError = ", GetLastError());
             if (OrderType()==OP_SELLSTOP)result=OrderDelete(OrderTicket());
             if(result!=TRUE) Print("LastError = ", GetLastError());

         }
      else Print( "Error when order select ", GetLastError());
      }
   } 
}

// Function to clear all existing Stop Losses
void ClearStops(){
for (int i=0;i<OrdersTotal();i++){
   if (OrderSelect(i,SELECT_BY_POS)){
      OrderSelect(i,SELECT_BY_POS);
      OrderModify(OrderTicket(),OrderOpenPrice(),0,OrderTakeProfit(),OrderExpiration(),Brown);
      }
         else Print( "Error when clearing Stops ", GetLastError());
      }
      return(0);  
 
}