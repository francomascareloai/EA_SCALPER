//+------------------------------------------------------------------+
//|                                         SimpleH1_GBPUSD_EAv9.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                         SimpleH1_GBPUSD_EAv9.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property link "http://www.forexfactory.com/showthread.php?t=231650"

extern string TITLE = "Simple H1 GBPUSD EA V9";
extern string DETAILS = "Magic Number & Trade Comment";
extern int iMagicNumber = 54328108;
extern string trade_comment="EA V9";
int     iMagicNumber2;
datetime Time0 = 0;
extern string MAIN_SETTINGS = "TP1, TP2, SL and TSL settings.";
extern int TakeProfit1 = 24;
extern int TakeProfit2 =47;
extern int StopLoss = 140;
double Poin;
extern bool   useTrailing = true;
extern double iTrailingStop = 24;
extern string MM_SETTINGS = "Risk, Low 1% - Med 3% - High 5%";
extern bool   UseMoneyMgmt = false;
extern bool Low_Risk = false;
extern bool Med_Risk = false;
extern bool High_Risk= false;
extern string VERY_HIGH_RISK = "Choose Risk % for the V HIGH. ";
extern bool Vhigh_Risk= false;
extern double RiskPercent = 1;
extern string MANUAL_LOTS = "Set your fixed Lot Size 0.1 = $1 per pip.";
extern bool   Manual_Lot_Size = true;
extern double Lotsize = 0.1;
extern string INDICATORS = "Standard Indicator Settings.";
extern int fast_sma=10;
extern int slow_sma=197;
extern string BROKER_SETTINGS = "GMT offset.";
extern int GMToffset=2;
extern int Start_Time= 23;
extern string HIDING_TARGETS = "Set to True to hide TP & SL.";
extern bool Hide_Targets = false;
extern bool Show_Levels = true;
extern bool   MicroOrdersAllowed = true;
extern bool   MiniOrdersAllowed = true;
extern string SHOWS_SETTINGS = "Set to False when Testing or Optimising.";
extern bool   Show_Settings  = true;
bool trade=false;
double  high_price, low_price , high_price2, low_price2, dLots;
int   iTicket, iTotalOrders,trend,Status,signal, BarCount, TradePerBar, var2;
static double latest;
static double aLots;
static int halt=0;
static double last_high, last_low; 
double TimeOfLastUpFractal, TimeOfLastDownFractal, totalopenorders ;
double LastUpFractal_H1,LastDownFractal_H1,TimeOfLastDownFractal_H1,TimeOfLastUpFractal_H1;
static double latestbuy, latestup, latestdn;
static double latestsell ;  
double dblProfit=0;
double spread;
static int lastv, lastw;
int direction=0;
static double latest_hizig, latest_lozig;
double zigspread, TakeProfit, iStopLoss, average, current;
datetime GMT;
string GMTs;
string brokers;
string GMT_difference;
double GMT_offset;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
//iMagicNumber    = subGenerateMagicNumber( iMagicNumber, Symbol(), Period() );
iMagicNumber2   =  iMagicNumber+1;

//----
//Checking for unconventional Point digits number
if (Point == 0.00001) Poin = 0.0001; //6 digits
else if (Point == 0.001) Poin = 0.01; //3 digits (for Yen based pairs)
else Poin = Point; //Normal

 
   

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
if (Low_Risk==true){RiskPercent=0.1;//1%
   }
if (Med_Risk==true){RiskPercent=0.3;//3%
   }
if (High_Risk==true){RiskPercent=0.5;//5%
   }
if (Vhigh_Risk==true) RiskPercent=1.0;//10%

  double Risk = RiskPercent / 10;
  int OrdersizeAllowed = 0;
  
  if (MiniOrdersAllowed) OrdersizeAllowed=1;
  if (MicroOrdersAllowed) OrdersizeAllowed=2;        
 if (UseMoneyMgmt==true)
   {
    dLots = NormalizeDouble( AccountBalance()*Risk/StopLoss/(MarketInfo(Symbol(), MODE_TICKVALUE)),OrdersizeAllowed);
      }  
      
  if (Manual_Lot_Size == true) 
   {
  dLots = NormalizeDouble(Lotsize,OrdersizeAllowed); 
      }   
  if ((dLots < 0.01&&MicroOrdersAllowed) || (dLots < 0.1&&MiniOrdersAllowed&&MicroOrdersAllowed==false))
      {
         Comment("YOUR LOTS SIZE IS TOO SMALL TO PLACE!");
      } 

   int  iCrossed, xCrossed;
   
   // get total number of orders 
   iTotalOrders = OrdersTotal();
   
   // see if we have a new cross
   iCrossed  = CheckForCross();
   
   // do functions 
  if(iTotalOrders != 0 && useTrailing == true) TrailingStop(iTotalOrders);
//----
   return(0);
  }
//+------------------------------------------------------------------+

void TrailingStop(int iTotal){

   int iCount;
   
   if(iTrailingStop < 1)return(-1); // error
   
   for(iCount=0;iCount<iTotal;iCount++){

      OrderSelect(iCount, SELECT_BY_POS, MODE_TRADES);
      if( OrderSymbol()==Symbol() && OrderMagicNumber() == iMagicNumber2)
         switch(OrderType()){
            case OP_BUY:
               if(Bid-OrderOpenPrice()>Poin*iTrailingStop){
                  if(OrderStopLoss()<Bid-Poin*iTrailingStop){
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Poin*(iTrailingStop-2),OrderTakeProfit(),0,Aqua);
                  }
               }
               break;
            case OP_SELL:
               if((OrderOpenPrice()-Ask)>(Poin*iTrailingStop)){
                  if((OrderStopLoss()>(Ask+Poin*iTrailingStop)) || (OrderStopLoss()==0)){
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Poin*(iTrailingStop-2),OrderTakeProfit(),0,Orange);
                  }
               }
               break;
         }
      }
   
      return(0);
}

   
 //+---------------------------------------------------------+

   int CheckForCross(){

  if ( Show_Settings )
       PrintDetails();
   int i, cnt  ;
   int buyorder=0;
   int sellorder=0;
   int sellstop = 0;
   int buystop = 0;
   int dir=0;
   int order=0;
   int Ticket=0;
  
  int total = OrdersTotal();

      i= 0;
      for (i = 0; i < total; i++) 
      {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == iMagicNumber
      ||  OrderSymbol() == Symbol() && OrderMagicNumber() == iMagicNumber2)
         {
              if (OrderType()==OP_BUY) {buyorder = buyorder +1;}
         else if (OrderType()==OP_SELL) {sellorder = sellorder +1;}
         } //end if
     } //end for
     
     totalopenorders= buyorder+sellorder;

trade = true;
      
      int x;
      double adr_total, adr;
      average = 0;
      for( x=1;x<11;x++){
         adr = iHigh(NULL,PERIOD_D1,x)-iLow(NULL,PERIOD_D1,x);
         adr_total = adr_total+adr;        
         }//end for
         average = adr_total/10;
         
         current = MathAbs(iHigh(NULL,PERIOD_D1,0)-iLow(NULL,PERIOD_D1,0));
         
  static double daily_high;
  static double daily_low;
  static double daily_pivot;
   
      if(Hour() == 1 && Show_Levels==true){
             daily_high = High[iHighest(NULL,0,MODE_HIGH,24,1)];
             daily_low = Low[iLowest(NULL,0,MODE_LOW,24,1)];
            double daily_range= daily_high-daily_low;
             daily_pivot = daily_low + (daily_range/2);
            double bull_positive1= daily_range*0.34;
            TakeProfit = bull_positive1;
            double bull_target1= daily_high+bull_positive1;
            double bear_negative1=daily_range*0.34;
            iStopLoss = daily_range;
            double bear_target1= daily_low - bear_negative1;
            ObjectDelete("Daily_Pivot");
            ObjectDelete("Daily_High");
            ObjectDelete("Daily_Low");
            ObjectDelete("Bull_Tgt1");
            ObjectDelete("Bear_Tgt1");
            ObjectCreate("Bull_Tgt1",OBJ_HLINE,0,Time[1],bull_target1);
            ObjectSet("Bull_Tgt1",OBJPROP_COLOR,Aqua);          
            ObjectCreate("Daily_Pivot",OBJ_HLINE,0,Time[1],daily_pivot);
            ObjectSet("Daily_Pivot",OBJPROP_COLOR,Yellow);
            ObjectCreate("Daily_High",OBJ_HLINE,0,Time[1],daily_high);
            ObjectSet("Daily_High",OBJPROP_COLOR,Blue);
            ObjectCreate("Daily_Low",OBJ_HLINE,0,Time[1],daily_low);
            ObjectSet("Daily_Low",OBJPROP_COLOR,Lime);
            ObjectCreate("Bear_Tgt1",OBJ_HLINE,0,Time[1],bear_target1);
            ObjectSet("Bear_Tgt1",OBJPROP_COLOR,Magenta);
            }//end if 
     if(Show_Levels==false)
            {
            ObjectDelete("Daily_Pivot");
            ObjectDelete("Daily_High");
            ObjectDelete("Daily_Low");
            ObjectDelete("Bull_Tgt1");
            ObjectDelete("Bear_Tgt1");
            }//end else
            
   for(int v=1;v<Bars;v++){
      if(iFractals(NULL,PERIOD_M15, MODE_UPPER,v)!=0){
         LastUpFractal_H1=iFractals(NULL,PERIOD_M15, MODE_UPPER,v);
         TimeOfLastUpFractal_H1=Time[v];
         break;
         }//end if
      }//end for
   for(int w=1;w<Bars;w++){
      if(iFractals(NULL,PERIOD_M15, MODE_LOWER,w)!=0){
         LastDownFractal_H1=iFractals(NULL,PERIOD_M15, MODE_LOWER,w);
         TimeOfLastDownFractal_H1=Time[w];
         break;
         }//end if
      }//end for
      
      if(TimeOfLastUpFractal_H1 > TimeOfLastDownFractal_H1) trend=1;
      else trend=2;
      
// Close Orders......................................................

   for (int j = 0; j < OrdersTotal(); j++) {
         OrderSelect(j, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY && (OrderMagicNumber() == iMagicNumber)) {
            if (Bid < (OrderOpenPrice()-StopLoss*Poin) 
             || Bid > (OrderOpenPrice()+TakeProfit1*Poin)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), Bid, 3*Poin/Point, Yellow);
               }
               }
          if (OrderType() == OP_SELL && (OrderMagicNumber() == iMagicNumber)) {
            if (Ask > (OrderOpenPrice()+StopLoss*Poin)
             || Ask < (OrderOpenPrice()-TakeProfit1*Poin)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), Ask, 3*Poin/Point, Yellow);
               }
               }
           }//end for 
           
    for (int k = 0; k < OrdersTotal(); k++) {
         OrderSelect(k, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY && (OrderMagicNumber() == iMagicNumber2)) {
            if (Bid < (OrderOpenPrice()-StopLoss*Poin) 
             || Bid > (OrderOpenPrice()+TakeProfit2*Poin)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), Bid, 3*Poin/Point, Yellow);
               }
               }
          if (OrderType() == OP_SELL && (OrderMagicNumber() == iMagicNumber2)) {
            if (Ask > (OrderOpenPrice()+StopLoss*Poin)
             || Ask < (OrderOpenPrice()-TakeProfit2*Poin)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), Ask, 3*Poin/Point, Yellow);
               }
               }
           }
           
          
// Place order.......................................................  
 
   if(trade==true){
      int trade_hour = Start_Time+GMToffset;
      if (trade_hour >= 24) trade_hour = trade_hour - 24;
      //Print("Trade hour = ", trade_hour);
      
      
      if(Hour() == trade_hour
         && iMA(NULL,0,slow_sma,0,MODE_SMA,PRICE_CLOSE,1) >= iMA(NULL,0,slow_sma,0,MODE_SMA,PRICE_CLOSE,2)
         && iMA(NULL,0,fast_sma,0,MODE_SMA,PRICE_CLOSE,1) > iMA(NULL,0,fast_sma,0,MODE_SMA,PRICE_CLOSE,2)               
         && iFractals(NULL, PERIOD_M5, MODE_LOWER,3)!=0
         && trend==1
         )                  
       { 
         if (buyorder==0 && Time0 != Time[0] && Hide_Targets==true)
         {              
           int retries =10;
           while(retries > 0)
           {
             RefreshRates();
             OrderSend(Symbol(), OP_BUY, dLots, Ask, 3*Poin/Point, 0, 0, trade_comment, iMagicNumber, 0, Blue);
             if(GetLastError() < 0)
             {
               Print("Buy OrderSend 1 failed with error #", GetLastError());
               Sleep(1000);
              }
              else                 
              break;
              retries--;
            }//end while
               
            retries =10;
            while(retries > 0)
            {
              RefreshRates();
              OrderSend(Symbol(), OP_BUY, dLots, Ask, 3*Poin/Point, 0, 0, trade_comment, iMagicNumber2, 0, Blue);
              if(GetLastError() < 0)
              {
                Print("Buy OrderSend 2 failed with error #", GetLastError());
                Sleep(1000);
               }
               else                 
               break;
               retries--;
             }//end while             
             Time0 = Time[0];
           }
              
           if(buyorder==0 && Time0 != Time[0] && Hide_Targets==false)
           {
             retries =10;
             while(retries > 0)
             {
               RefreshRates();
               int iTicket=OrderSend(Symbol(),OP_BUY,dLots,Ask,3*Poin/Point,0,0,trade_comment,iMagicNumber,0,Blue);
               bool xbool = OrderSelect(iTicket, SELECT_BY_TICKET);
               OrderModify(iTicket,0,OrderOpenPrice()-Poin*StopLoss,OrderOpenPrice()+Poin*TakeProfit1 ,0,CLR_NONE); 
               
               if(GetLastError() < 0)
               {
                 Print("Buy OrderSend 1 failed with error #", GetLastError());
                 Sleep(1000);
                }
                else                 
                break;
                retries--;
              }//end while
               
              retries =10;
              while(retries > 0)
              {
                RefreshRates();
                iTicket=OrderSend(Symbol(),OP_BUY,dLots,Ask,3*Poin/Point,0,0,trade_comment,iMagicNumber2,0,Blue);
                xbool = OrderSelect(iTicket, SELECT_BY_TICKET);
                OrderModify(iTicket,0,OrderOpenPrice()-Poin*StopLoss,OrderOpenPrice()+Poin*TakeProfit2 ,0,CLR_NONE);
               
                if(GetLastError() < 0)
                {
                  Print("Buy OrderSend 2 failed with error #", GetLastError());
                  Sleep(1000);
                 }
                 else                 
                 break;
                 retries--;
               }//end while             
               Time0 = Time[0];              
           }   
       }
       
         if(Hour() == trade_hour
         && iMA(NULL,0,slow_sma,0,MODE_SMA,PRICE_CLOSE,1) <= iMA(NULL,0,slow_sma,0,MODE_SMA,PRICE_CLOSE,2)
         && iMA(NULL,0,fast_sma,0,MODE_SMA,PRICE_CLOSE,1) < iMA(NULL,0,fast_sma,0,MODE_SMA,PRICE_CLOSE,2)               
         && iFractals(NULL, PERIOD_M5, MODE_UPPER,3)!=0
         && trend==2
        )                  
       {                         
         if (sellorder==0 && Time0 != Time[0] && Hide_Targets==true)
         {              
            retries =10;
           while(retries > 0)
           {
             RefreshRates();             
             OrderSend(Symbol(),OP_SELL,dLots,Bid,3*Poin/Point,0,0,trade_comment,iMagicNumber,0,Red);
             if(GetLastError() < 0)
             {
               Print("Sell OrderSend 1 failed with error #", GetLastError());
               Sleep(1000);
              }
              else                 
              break;
              retries--;
            }//end while
               
            retries =10;
            while(retries > 0)
            {
              RefreshRates();
              OrderSend(Symbol(),OP_SELL,dLots,Bid,3*Poin/Point,0,0,trade_comment,iMagicNumber2,0,Red);
              if(GetLastError() < 0)
              {
                Print("Sell OrderSend 2 failed with error #", GetLastError());
                Sleep(1000);
               }
               else                 
               break;
               retries--;
             }//end while             
             Time0 = Time[0];
           }
              
           if(sellorder==0 && Time0 != Time[0] && Hide_Targets==false)
           {
             retries =10;
             while(retries > 0)
             {
               RefreshRates();
               iTicket=OrderSend(Symbol(),OP_SELL,dLots,Bid,3*Poin/Point,0,0,trade_comment,iMagicNumber,0,Red);
               xbool = OrderSelect(iTicket, SELECT_BY_TICKET);
               OrderModify(iTicket,0,OrderOpenPrice()+Poin*StopLoss,OrderOpenPrice()-Poin*TakeProfit1 ,0,CLR_NONE);
               
               if(GetLastError() < 0)
               {
                 Print("Sell OrderSend 1 failed with error #", GetLastError());
                 Sleep(1000);
                }
                else                 
                break;
                retries--;
              }//end while
               
              retries =10;
              while(retries > 0)
              {
                RefreshRates();
                iTicket=OrderSend(Symbol(),OP_SELL,dLots,Bid,3*Poin/Point,0,0,trade_comment,iMagicNumber2,0,Red);
                xbool = OrderSelect(iTicket, SELECT_BY_TICKET);
                OrderModify(iTicket,0,OrderOpenPrice()+Poin*StopLoss,OrderOpenPrice()-Poin*TakeProfit2 ,0,CLR_NONE);
               
                if(GetLastError() < 0)
                {
                  Print("Sell OrderSend 2 failed with error #", GetLastError());
                  Sleep(1000);
                 }
                 else                 
                 break;
                 retries--;
               }//end while             
               Time0 = Time[0];              
           }   
       }
       
      }  
   return(0);
} 

//---------------------------------------------------------------------

void PrintDetails()
{
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";
   
   sComment = sp;
   sComment = sComment + "H1 GBPUSD EA V9"+ NL;
   sComment = sComment + "Take Profit 1 = " + DoubleToStr(TakeProfit1,0) + " | ";
   sComment = sComment + "Take Profit 2 = " + DoubleToStr(TakeProfit2,0) + NL;
   sComment = sComment + "StopLoss = " + DoubleToStr(StopLoss,0) + NL;
   sComment = sComment + "TrailingStop = " + DoubleToStr(iTrailingStop,0) + NL;
   sComment = sComment + "OrderLots = " +DoubleToStr(dLots,2) +NL;
   //sComment = sComment + "MM Risk = " +DoubleToStr(RiskPercent*10,2) + "%"  + NL;  
   
   sComment = sComment + "-------------------------------------------------------------------------" +NL;
   sComment = sComment + "Analysis for Information Only:"+ NL;
   sComment = sComment + "Average Daily Range  = " +DoubleToStr(average*10000,0) + NL;
   sComment = sComment + "Current Daily Range  = " +DoubleToStr(current*10000,0) + NL;
   if(current >= average){
   sComment = sComment + "AVERAGE DAILY RANGE EXCEEDED"+ NL;} 
   else
   sComment = sComment + "Average Daily Range not reached"+ NL; 
   sComment = sComment + "-------------------------------------------------------------------------" +NL;
   sComment = sComment + "Account Information:"+ NL;
   sComment = sComment + "Account Balance = " +DoubleToStr(AccountBalance(),2)+" USD" + NL;
   sComment = sComment + "Account Equity  = " +DoubleToStr(AccountEquity(),2)+" USD" + NL;
   sComment = sComment + "-------------------------------------------------------------------------" +NL; 
   sComment = sComment + "Start Time = " +DoubleToStr(Start_Time,0)+":00" +NL;
   sComment = sComment + "Broker Time = " +DoubleToStr(Hour(),0)+":00" +NL;
 
   sComment = sComment + "GMT Offset = " +DoubleToStr(GMToffset,0) +NL;
   
   sComment = sComment + "-------------------------------------------------------------------------" +NL;  
   sComment = sComment + "Symbols: "+Symbol()+ NL;
   sComment = sComment + sp;
   //---- 3 seconds wait
   //Sleep(3000);
   //---- refresh data
   RefreshRates();

   Comment(sComment);
}

//------------------------------------------------------


