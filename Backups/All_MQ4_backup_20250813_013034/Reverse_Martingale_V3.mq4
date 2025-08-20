//+------------------------------------------------------------------+
//|                                           Reverse_Martingale.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "3.00"
#property strict
#define     NL    "\n"

//input double FixLot=0.01; //Auto lot Size
input int AutoLot=5000; //Fix Lot Size
double FixLot;
input int    StopLoss=0; //Stoploss In Pips
input int    StopLossDD=26; //Stoploss In DD
input int    TakeProfit=30; //TakeProfit In Pips
input int    MagicNumber=123; //Order Magic Number
input int    Max_Orders=6; //Maximum Orders To Open
input long   Spread=5; //Spread In Pips
input bool   UseMartingale=true; //Use Martingale
input bool   nfp = true;//Avoid NFT
input int    new_year_days = 7; // No trading 7 days before and after new year
input double MaxLot=0.64; //Maximum Lot size To Use
input double Multiplier=2; //Lot Multiplier

input string  Moving_Average="=================";
input int     MaPeriod=200;
input int     MaShift=0;
//input ENUM_MA_METHOD     Ma_Method=MODE_SMA;
input ENUM_MA_METHOD     Ma_Method=MODE_LWMA;
input ENUM_APPLIED_PRICE Apply_Price=PRICE_CLOSE;

datetime candletime=0;
double stoplevel,Upper_stoplevel,Lower_stoplevel;
datetime EaStartTime=TimeCurrent();

// My stuff
double lotsize;
int max_opentrades=0;
double currentdde=0;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
  
  
  
  
  
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   
   
   //if( AccountProfit()> 0 && Max_Orders > 3 ) CloseAll();
   
   
   //Stoploss with Equity
   currentdde = NormalizeDouble(100 - (AccountEquity() * 100 / (AccountBalance() + AccountCredit())),2);
   if(currentdde>=StopLossDD && StopLossDD!=0 && AccountProfit()<0) CloseAll();
   
   
   
   if( (AccountBalance() + AccountCredit()) > AutoLot )
      FixLot = floor(((AccountBalance() + AccountCredit()) / AutoLot)) * 0.01;
   else FixLot = 0.01;
   
   
   
//---
bool signal = false;
AddOrder(signal);
//--- New Candle Filter
   bool IsNewBar=Time[0]>candletime;

//--- Spread Filter
   bool IsSpreadGood=SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)<(Spread*10);
   if(IsSpreadGood==false) Print("Current Spread is greater than the spread put in EA inputs");

//--- Trading Rules
   if(IsNewBar && IsSpreadGood && Count(0)+Count(1)<Max_Orders && signal==false && GoodTime())
     {
      if(Close[1]>MAvg(1)) {OpenOrder(0); candletime=Time[0];}
      if(Close[1]<MAvg(1)) {OpenOrder(1); candletime=Time[0];}
     }







   //Max concurrent open trades at the same time, some brokers limit open trades < 200.
   int c = 0;
   for( int k = 0 ; k < OrdersTotal() ; k++ ) {  
      if(OrderSelect( k, SELECT_BY_POS, MODE_TRADES )){
         c++;
      }
   } 
   if(c>max_opentrades) max_opentrades=c;
      
      
      


   Comment("                            ",NL,NL
           "                            Capital ", (AccountBalance() + AccountCredit()),"        MaxOpenTrades ",max_opentrades, NL,NL
           //"                            TP        % ",input_takeprofit," | $ ",input_takeprofitv,"        $ ",currenttpv," / ",max_currenttpv,NL,NL,NL,NL
           
           //"                            DDe        % ",input_dde," | $ ",input_ddev,"        % ",currentdde," / ",max_currentdde,"        $ ",-currentddev," / ",max_currentddev,NL,NL,NL,NL
           
           //"                            DDm        % ",input_ddm," | $ ",input_ddmv,"        % ",currentddm," / ",max_currentddm,"        $ ",-currentddmv," / ",max_currentddmv,NL,NL,NL,NL
           
           //"                            SL        % ",input_stoplose," / $ ",currentslv,NL,NL,NL,NL
           //"                            TPC ",takeprofit_counter,"     DDeC ",dde_counter,"     DDmC ",ddm_counter,"     SLC ",stoplose_counter
           );













  } //end of ontick
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Open Orders Counting Function                                    |
//+------------------------------------------------------------------+
int Count(int Type)
  {
   int count=0;
   for(int i=0; i<=OrdersTotal()-1; i++)
     {
      bool Select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(Select && OrderSymbol()==_Symbol && OrderMagicNumber()==MagicNumber && OrderType()==Type) count++;
     }
   return (count);
  }

//+------------------------------------------------------------------+
//| Open Pending Orders Function                                     |
//+------------------------------------------------------------------+
double OpenOrder(int Type , double lot =0)
  {
   double openprice=0; double stoploss=0; double takeprofit=0; double Lot=FixLot; double lots[]; LotSizeCalc(lots);

   if(_Point==0.00001 || _Point==0.001)
     {
      stoploss=(StopLoss*10)*_Point;
      takeprofit=(TakeProfit*10)*_Point;
     }

   if(_Point==0.0001 || _Point==0.01)
     {
      stoploss=(StopLoss)*_Point;
      takeprofit=(TakeProfit)*_Point;
     }

   if(lots[losscnt()]>=MaxLot)
     {
      EaStartTime=TimeCurrent();
      return 0;
     }

   if(Type==OP_BUY)
     {
      openprice=Ask;
      if(StopLoss>0) stoploss=openprice-stoploss;
      if(TakeProfit>0) takeprofit=openprice+takeprofit;
     }

   if(Type==OP_SELL)
     {
      openprice=Bid;
      if(StopLoss>0) stoploss=openprice+stoploss;
      if(TakeProfit>0) takeprofit=openprice-takeprofit;
     }

   if(Lot>PrevOrderLot()) lotsize=Lot;
  if(lot>0)Lot = lot;
  if(Lot>MaxLot) Lot=FixLot;
   int Ticket=OrderSend(_Symbol,Type,Lot,openprice,300,stoploss,takeprofit,"Order Placed",MagicNumber,0,clrGreen);

   return(Ticket);
  }
//+------------------------------------------------------------------+
//| Indicator Moving Average Function                                |
//+------------------------------------------------------------------+
double MAvg(int shift)
  {
   double MA=iMA(_Symbol,0,MaPeriod,MaShift,Ma_Method,Apply_Price,shift);

   return (MA);
  }
//+------------------------------------------------------------------+
//| Martingale LotSize Calculation Function                           |
//+------------------------------------------------------------------+
void LotSizeCalc(double &arr[])
  {
   ArrayResize(arr,100,0);
   arr[0]=FixLot;
   for(int i=1;i<ArraySize(arr);i++)
     {
      arr[i]=arr[i-1]*Multiplier;
     }
  }
//+------------------------------------------------------------------+
//| Orders WinCount & LossCount Function                             |
//+------------------------------------------------------------------+
int losscnt()
  {
   int WinCount=0;
   int Losscnt=0;

   for(int Count=OrdersTotal()-1;Count>=0; Count--)
     {
      bool select=OrderSelect(Count,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol && OrderType()<=1 && OrderOpenTime()>=EaStartTime)
        {
         if(OrderProfit()>0 && Losscnt==0) WinCount++;
         else if(OrderProfit()<0 && WinCount==0) Losscnt++;
         else break;
        }
     }

   return(WinCount);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Open Orders Lot Selecting Function                               |
//+------------------------------------------------------------------+
double PrevOrderLot()
  {
   double lot=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      bool Select=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(Select && OrderSymbol()==_Symbol && OrderType()<=1 && OrderMagicNumber()==MagicNumber)
       {
        lot=OrderLots();
        break;
       }
     }
   return (lot);
  }

struct COrders
  {
   int ticket;
   double lots;
   bool Istradeopen;
  }orders[];


bool IsTicketAlreadyExist(int ticket)
{
bool signal = false;
for(int i=0;i<ArraySize(orders);i++)
  {
   if(ticket ==  orders[i].ticket)
     {
     signal=true;
     break;
     }
  }
return(signal);
}

void AddOrder(bool &signal)
{
static datetime timer=TimeCurrent();

signal=false;
for(int i=OrdersHistoryTotal()-1;i>=0;i--)
  {
   bool select = OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
   if(select && OrderMagicNumber()==MagicNumber && OrderSymbol()==_Symbol && OrderCloseTime()>=timer
      && OrderProfit()+OrderSwap()+OrderCommission()>0)
     {
      if(IsTicketAlreadyExist(OrderTicket())==false)
        {
         ArrayResize(orders,ArraySize(orders)+1,0);
         orders[ArraySize(orders)-1].ticket=OrderTicket();
         orders[ArraySize(orders)-1].lots=OrderLots();
         orders[ArraySize(orders)-1].Istradeopen=false;
        }
     }
  }

//---
if(ArraySize(orders)>0)
  {
static datetime timecandle = Time[0];
bool IsNewBar = Time[0]>timecandle;

if(IsNewBar)
  {
  int index =-1;
double highest_lot = GetHighestOrderLotFromArray(index);
  if(highest_lot >0)
    {
    if(Close[1]>MAvg(1)) OpenOrder(0,NormalizeDouble(highest_lot*Multiplier,2));
    if(Close[1]<MAvg(1)) OpenOrder(1,NormalizeDouble(highest_lot*Multiplier,2));
    orders[index].Istradeopen=true;
    signal=true;
    candletime=Time[0];
    }
  
  timecandle=Time[0];
  }
  
  
  
  }

}
  


double GetHighestOrderLotFromArray(int &index )
{
double h_lot =0;

for(int i=0;i<ArraySize(orders);i++)
  {
   if(orders[i].lots>h_lot && orders[i].Istradeopen==false)
     {
      h_lot=orders[i].lots;
      index=i;
     }
  }
return(h_lot);
}



void CloseAll()
{
  for(int i=OrdersTotal()-1;i>=0;i--)
 {
    //OrderSelect(i, SELECT_BY_POS);
    if ( OrderSelect(i, SELECT_BY_TICKET)){continue;} 
    bool result = false;
        if ( OrderType() == OP_BUY)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red );
        if ( OrderType() == OP_SELL)  result = OrderClose( OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red );
        if ( OrderType()== OP_BUYSTOP)  result = OrderDelete( OrderTicket() );
        if ( OrderType()== OP_SELLSTOP)  result = OrderDelete( OrderTicket() );
 }
  return; 
}


bool GoodTime()
{
   if(nfp){ //0 = Sunday
      //if(DayOfWeek() == 5 && Day() <=7) return false;
      if(DayOfWeek() >= 2  && Day() <=7) return false;      
   }
   
   if(( Month() == 12 && Day() >= 31 -new_year_days) || ( Month() == 1 && Day() <= new_year_days)) return false;
   
   
   return true;
   
}