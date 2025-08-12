//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
CTrade trade;


//DYNAMIC LOTSIZING INPUT
double PositionSize(){
double lot;
double lot_min = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
double lot_max = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
double AcctEquity = AccountInfoDouble(ACCOUNT_EQUITY);

lot = 3.00/50*AcctEquity;
if(lot<=lot_min){
lot=lot_min;
}
if(lot>=lot_max){
lot=lot_max;
}
return(lot);
}



//static input long inpMagicnumber =54321;
input int inpBars=20; //bars for high/low
static input double inpLots=1.00;
input int inpStopLoss=2;
input int inpTakeProfit=1500;
//input int stoplossinpoints=5;
input bool inpTrailingSL=true;

///GLOBAL VARIBLES
double high=0;
double low=0;
MqlTick currentTick, previousTick;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



datetime Expire_Time = D'2024.01.30 12:59:00';
int OnInit()
  {


 trade.SetExpertMagicNumber(5243);
        if(TimeCurrent() > Expire_Time)
        {
         Alert("The EA has expired...");
         ExpertRemove();
        }
        

  
//set magicnumber
//trade.SetExpertMagicNumber(inpMagicnumber);

   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+11                                                                                                                                                                                                                                    11 11111111111111111111111111111111111111111111111111
void OnTick()
  {
  
  
  //CHECK FOR NEW BAR OPEN TICK
  
  if(!IsNewBar()){return;}
   double Lotsize = NormalizeDouble(PositionSize(),2); 
  //Get tick
  previousTick=currentTick;
  if(!SymbolInfoTick(_Symbol,currentTick)){Print("fail to get currenttick");return;}
  
  ///count open positions
  int cntBuy, cntSell;
  if(!CountOpenPositions(cntBuy,cntSell)){return;}
  
  
  
  
  
   //check for sell position
 if(cntSell==0 && low!=0 && previousTick.bid>low && currentTick.bid<=low){
  
  //calculte stoploss /take profit
  double sl=inpStopLoss==0?0:currentTick.ask+inpStopLoss*_Point;
  double tp=inpTakeProfit==0?0:currentTick.ask-inpTakeProfit*_Point;
  if(!NormalizePrice(sl)){return;}
  if(!NormalizePrice(tp)){return;}
  
 trade.PositionOpen(_Symbol,ORDER_TYPE_SELL,Lotsize,currentTick.bid,sl,tp,"highbreakout");
  
 // Print("open sell position");
  }
  
 
  
  
  
  
  
  
  
  ///update stoploss/takeprofit
  if(inpStopLoss>0 && inpTrailingSL){
  UpdateStopLoss(inpStopLoss*_Point);
  }
  
//CALCULATE HIGH AND LOW
   high =iHigh(_Symbol,PERIOD_CURRENT,iHighest(_Symbol,PERIOD_CURRENT,MODE_HIGH,inpBars,1));
   low =iLow(_Symbol,PERIOD_CURRENT,iLowest(_Symbol,PERIOD_CURRENT,MODE_LOW,inpBars,1));
 
}
void DrawObjects(){
 

datetime time =iTime(_Symbol,PERIOD_CURRENT,inpBars);

//RESISTANCE/HIGH LEVELS
ObjectDelete(NULL,"high");
ObjectCreate(NULL,"high",OBJ_TREND,0,time,high,TimeCurrent(),high);
ObjectSetInteger(NULL,"high",OBJPROP_WIDTH,2);
ObjectSetInteger(NULL,"high",OBJPROP_COLOR,clrBlack);

//SUPPORTS/LOW LEVELS
ObjectDelete(NULL,"low");
ObjectCreate(NULL,"low",OBJ_TREND,0,time,low,TimeCurrent(),low);
ObjectSetInteger(NULL,"low",OBJPROP_COLOR,clrRed);

}

//check for new bar
bool IsNewBar(){
static datetime previousTime=0;
datetime currentTime=iTime (_Symbol,PERIOD_CURRENT,0);
if (previousTime!=currentTime){
previousTime=currentTime;
return true;
}
return false;
}


//count open positions
 bool CountOpenPositions(int &cntBuy,int &cntSell){
ObjectSetInteger(NULL,"low",OBJPROP_WIDTH,2);
  
  cntBuy=0;
  cntSell=0;
  int total= PositionsTotal();
  for (int i=total-1; i>=0; i--){
  ulong ticket = PositionGetTicket(1);
  if(ticket<=0){Print("failed to get position ticket");return false;}
  if(!PositionSelectByTicket(ticket)){Print("failed to select position");return false;}
  long magic;
  if(!PositionGetInteger(POSITION_MAGIC,magic)){Print("failed to get position magicnumber");return false;}
  if(magic==5243){
  long type;
  if(!PositionGetInteger(POSITION_TYPE,type)){Print("failed to get position type");return false;}
  if(type==POSITION_TYPE_BUY){cntBuy++;}
  if(type==POSITION_TYPE_SELL){cntSell++;}
  }
  }
  return true;
  }
  
//Normalize price
bool NormalizePrice(double &price){
double tickSize=0;
if(!SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE,tickSize)){
Print("failed to get tick size");
}
return true;


price= NormalizeDouble(MathRound(price/tickSize)*tickSize,_Digits);
return true;

}

//update stop loss
void UpdateStopLoss(double slDistance){



//loop through open positions
int total=PositionsTotal ();
for(int i=total-1; i>=0; i--){
ulong ticket = PositionGetTicket(i);
if(ticket<=0){Print("failed to get position ticket");return;}
if(!PositionSelectByTicket(ticket)){Print("failed to select position by ticket");return;}
ulong magicnumber;
if(!PositionGetInteger(POSITION_MAGIC,magicnumber)){Print("failed to select position magicnumber");return;}
if (5243==magicnumber){



//get type
long type;
if(!PositionGetInteger(POSITION_TYPE,type)){Print("failed to select position type");return;}
//get current sl and tp
double currSL, currTP;
if(!PositionGetDouble(POSITION_SL,currSL)){Print("failed to GET CURRENT STOP LOSS");return;}
if(!PositionGetDouble(POSITION_TP,currTP)){Print("failed to GET CURRENT TAKE PROFIT");return;}

//CALCULATE STOP LOSS
double currPrice=type==POSITION_TYPE_BUY ? currentTick.bid : currentTick.ask;
int        n    =type==POSITION_TYPE_BUY ? 1:-1;
double newSL    =currPrice-slDistance*n;
if (!NormalizePrice(newSL)){return;}

//CHECK IF NEW STOPLOSS IS CLOSER TO CURRENT PRICE THAN EXISTING STOP
if ((newSL*n)<(currSL*n) ||NormalizeDouble(MathAbs(newSL-currSL),_Digits)<_Point){
continue;
}
//check for stop levels
long level=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
if (level!=0 && MathAbs(currPrice-newSL)<=level*_Point){
Print("new stoploss inside stop level");
continue;

}
//modify position with new stop loss
if (!trade.PositionModify(ticket,newSL,currTP)){
Print("failed to modify position ticket:",(string)ticket,"currSL:",(string)currSL,
"newSL:",(string)newSL,"currTP:",(string)currTP);
return;
}
}

}

}








