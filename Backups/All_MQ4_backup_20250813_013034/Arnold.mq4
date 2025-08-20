//+------------------------------------------------------------------+
//|                                                      DLMv1.1.mq4 |
//|                              Copyright © 2005, Alejandro Galindo |
//|                                              http://elCactus.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Alejandro Galindo and Tom Maneval"
#property link      "http://elCactus.com"
//----
extern double TakeProfit=38;   // Profit Goal for the latest order opened
extern double Lots=0.1;        // We start with this lots number
extern double StopLoss=0;      // StopLoss
extern double TrailingStop=0;  // Pips to trail the StopLoss
//----
extern int MaxTrades=10;        // Maximum number of orders to open
extern int Pips=18;             // Distance in Pips from one order to another
extern int SecureProfit=10;     // If profit made is bigger than SecureProfit we close the orders
extern int AccountProtection=1; // If one the account protection will be enabled, 0 is disabled
extern int AllSymbolsProtect=0; // if one will check profit from all symbols, if cero only this symbol
extern int OrderstoProtect=3;   // Number of orders to enable the account protection
extern int ReverseCondition=0;  // if one the desition to go long/short will be reversed
extern int StartYear=2005;      // Year to start (only for backtest)
extern int StartMonth=1;        // month to start (only for backtest)
extern int EndYear=2030;        // Year to stop trading (backtest and live)
extern int EndMonth=12;         // Month to stop trading (backtest and live)
//extern int EndHour=22;
//extern int EndMinute=30;
extern int mm=0;                // if one the lots size will increase based on account size
extern int risk=0.01;           // risk to calculate the lots size (only if mm is enabled)
extern int AccountisNormal=0;   // Zero if account is not mini/micro
extern int MagicNumber=222777;  // Magic number for the orders placed
extern int Manual=0;            // If set to one then it will not open trades automatically
extern int OpenOrdersBasedOn=5; // Method to decide trades:0=MACD, 1=Pivot Point Time Zone, 2=Support and Resistance, 
                                // 3=i_Trend RSI, 4=i_TrendRSIStoch, 5=i-TrendRSIStochMoneyFlowIndex
extern int TimeZone=16;         // Time zone to calculate the pivots (not all the methods uses it)
//----
int  OpenOrders=0, cnt=0;
int  slippage=3;
double sl=0, tp=0;
double BuyPrice=0, SellPrice=0;
double lotsi=0, mylotsi=0;
int mode=0, myOrderType=0;
bool ContinueOpening=True;
double LastPrice=0;
int  PreviousOpenOrders=0;
double Profit=0;
int LastTicket=0, LastType=0;
double LastClosePrice=0, LastLots=0;
double Pivot=0;
double PipValue=0;
bool Reversed=False;
string text="";
double tmp=0;
double iTmpH=0;
double iTmpL=0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
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
   int cnt=0;
   if (AccountisNormal==1)
     {
      if (mm!=0) { lotsi=MathCeil(AccountBalance()*risk/10000); }
      else 
      {
       lotsi=Lots; 
      }
      }
       else 
       {  // then is mini
      if (mm!=0) { lotsi=MathCeil(AccountBalance()*risk/10000)/10; }
      else {
       lotsi=Lots; 
      }
     }
   if (lotsi>100){ lotsi=100; 
   }
   OpenOrders=0;
   for(cnt=0;cnt<OrdersTotal();cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         OpenOrders++;
        }
     }
   if (OpenOrders<1)
     {
      if (TimeYear(CurTime())<StartYear) { return(0);  }
      if (TimeMonth(CurTime())<StartMonth) { return(0); }
      if (TimeYear(CurTime())>EndYear) { return(0); }
      if (TimeMonth(CurTime())>EndMonth){ return(0); }
     }
   if (Symbol()=="EURUSD") { PipValue=10.00; }
   if (Symbol()=="GBPUSD") { PipValue=10.00; }
   if (Symbol()=="USDJPY") { PipValue=9.715; }
   if (Symbol()=="USDCHF") { PipValue=8.70; }
   if (PipValue==0) { PipValue=5; }
   if (PreviousOpenOrders>OpenOrders)
     {
      for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
        {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         mode=OrderType();
         if ((OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) || AllSymbolsProtect==1)
           {
            if (mode==OP_BUY) { OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Blue); }
            if (mode==OP_SELL) { OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,Red); }
            return(0);
           }
        }
     }
   PreviousOpenOrders=OpenOrders;
   if (OpenOrders>=MaxTrades)
     {
      ContinueOpening=False;
      }
       else 
      {
      ContinueOpening=True;
     }
   if (LastPrice==0)
     {
      for(cnt=0;cnt<OrdersTotal();cnt++)
        {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         mode=OrderType();
         if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            LastPrice=OrderOpenPrice();
            if (mode==OP_BUY) { myOrderType=2; }
            if (mode==OP_SELL) { myOrderType=1;   }
           }
        }
     }
   if (OpenOrders<1 && Manual==0)
     {
      switch(OpenOrdersBasedOn)
        {
         case 0:
            myOrderType=OpenOrdersBasedOnMACD(); break;
         case 1:
            myOrderType=OpenOrdersBasedOnPivot(); break;
         case 2:
            myOrderType=OpenOrdersBasedOnSupRes(); break;
         case 3:
            myOrderType=OpenOrdersBasedOni_TrendRSI(); break;
         case 4:
            myOrderType=OpenOrdersBasedOni_TrendRSISto(); break;
         case 5:
            myOrderType=OpenOrdersBasedOni_TrRSIStoMFI(); break;
         default:
            myOrderType=OpenOrdersBasedOnMACD(); break;
        }
      if (ReverseCondition==1)
        {
         if (myOrderType==1) { myOrderType=2; }
         else 
         { 
         if (myOrderType==2) { myOrderType=1; } 
         }
        }
     }
   // if we have opened positions we take care of them
   cnt=OrdersTotal();
   while(cnt>=0)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber) // && Reversed==False) 
        {
         Print("Ticket ",OrderTicket()," modified.");
         if (OrderType()==OP_SELL)
           {
            if (TrailingStop>0)
              {
               if ((OrderOpenPrice()-Ask)>=(TrailingStop*Point+Pips*Point))
                 {
                  if (OrderStopLoss()>(Ask+Point*TrailingStop) || OrderStopLoss()==0)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderClosePrice()-TakeProfit*Point-TrailingStop*Point,0,Purple);
                     return(0);
                    }
                 }
              }
           }
         if (OrderType()==OP_BUY)
           {
            if (TrailingStop>0)
              {
               if ((Bid-OrderOpenPrice())>=(TrailingStop*Point+Pips*Point))
                 {
                  if (OrderStopLoss()<(Bid-Point*TrailingStop))
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderClosePrice()+TakeProfit*Point+TrailingStop*Point,0,Yellow);
                     return(0);
                    }
                 }
              }
           }
        }
      cnt--;
     }
   if (OpenOrders>=(MaxTrades-OrderstoProtect) && AccountProtection==1)
     {
      Profit=0;
      LastTicket=0;
      LastType=0;
      LastClosePrice=0;
      LastLots=0;
      for(cnt=0;cnt<OrdersTotal();cnt++)
        {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
            LastTicket=OrderTicket();
            if (OrderType()==OP_BUY) { LastType=OP_BUY; }
            if (OrderType()==OP_SELL) { LastType=OP_SELL; }
            LastClosePrice=OrderClosePrice();
            LastLots=OrderLots();
            if (LastType==OP_BUY)
              {
               //Profit=Profit+(Ord(cnt,VAL_CLOSEPRICE)-Ord(cnt,VAL_OPENPRICE))*PipValue*Ord(cnt,VAL_LOTS);				
               if (OrderClosePrice()<OrderOpenPrice())
               { Profit=Profit-(OrderOpenPrice()-OrderClosePrice())*OrderLots()/Point; }
               if (OrderClosePrice()>OrderOpenPrice())
               { Profit=Profit+(OrderClosePrice()-OrderOpenPrice())*OrderLots()/Point; }
              }
            if (LastType==OP_SELL)
              {
               //Profit=Profit+(Ord(cnt,VAL_OPENPRICE)-Ord(cnt,VAL_CLOSEPRICE))*PipValue*Ord(cnt,VAL_LOTS);
               if (OrderClosePrice()>OrderOpenPrice())
               { Profit=Profit-(OrderClosePrice()-OrderOpenPrice())*OrderLots()/Point; }
               if (OrderClosePrice()<OrderOpenPrice())
               { Profit=Profit+(OrderOpenPrice()-OrderClosePrice())*OrderLots()/Point; }
              }
            //Print(Symbol,":",Profit,",",LastLots);
           }
        }
      Profit=Profit*PipValue;
      //Print(Symbol,":",Profit);
      if (AllSymbolsProtect==1) { tmp=AccountBalance(); }
      else 
      { tmp=SecureProfit; }
      if (Profit>=tmp)
        {
         OrderClose(LastTicket,LastLots,LastClosePrice,slippage,Yellow);
         ContinueOpening=False;
         return(0);
        }
     }
   //   if (CurTime()<1128110760) 
   //   {
   if (!IsTesting())
     {
      if (myOrderType==3) { text="No conditions to open trades"; }
      else { text="                         "; }
      Comment("LastPrice=",LastPrice," Previous open orders=",PreviousOpenOrders,"\nContinue opening=",ContinueOpening," OrderType=",myOrderType,"\nLots=",lotsi,"\n",text);
     }
   if (myOrderType==1 && ContinueOpening)
     {
      if ((Bid-LastPrice)>=Pips*Point || OpenOrders<1)
        {
         SellPrice=Bid;
         LastPrice=0;
         if (TakeProfit==0) { tp=0; }
         else { tp=SellPrice-TakeProfit*Point; }
         if (StopLoss==0) { sl=0; }
         else { sl=SellPrice+StopLoss*Point;  }
         if (OpenOrders!=0)
           {
            mylotsi=lotsi;
            for(cnt=1;cnt<=OpenOrders;cnt++)
              {
               if (MaxTrades>12) { mylotsi=NormalizeDouble(mylotsi*1.5,2); }
               else { mylotsi=NormalizeDouble(mylotsi*2,2); }
              }
           } else { mylotsi=lotsi; }
         if (mylotsi>100) { mylotsi=100; }
         OrderSend(Symbol(),OP_SELL,mylotsi,SellPrice,slippage,sl,tp,"DLM"+MagicNumber,MagicNumber,0,Red);
         return(0);
        }
     }
   if (myOrderType==2 && ContinueOpening)
     {
      if ((LastPrice-Ask)>=Pips*Point || OpenOrders<1)
        {
         BuyPrice=Ask;
         LastPrice=0;
         if (TakeProfit==0) { tp=0; }
         else { tp=BuyPrice+TakeProfit*Point; }
         if (StopLoss==0)  { sl=0; }
         else { sl=BuyPrice-StopLoss*Point; }
           if (OpenOrders!=0) {
            mylotsi=lotsi;
            for(cnt=1;cnt<=OpenOrders;cnt++)
              {
               if (MaxTrades>12) { mylotsi=NormalizeDouble(mylotsi*1.5,2); }
               else { mylotsi=NormalizeDouble(mylotsi*2,2); }
              }
           } 
           else { mylotsi=lotsi; }
         if (mylotsi>100) { mylotsi=100; }
         OrderSend(Symbol(),OP_BUY,mylotsi,BuyPrice,slippage,sl,tp,"DLM"+MagicNumber,MagicNumber,0,Blue);
         return(0);
        }
     }
   //   } else {
   //	  Comment("This version has expired. Alejandro Galindo, ag@elCactus.com");
   //   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//| FROM THIS SECTION I WILL INSERT ALL THE POSSIBLE FUNCTIONS TO    |
//| MAKE THE DECISION IF WE START LONG OR SHORT                      |
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrdersBasedOnSupRes()
  {
   int myOrderType=3;
   double iTmpR=0, iTmpS=0;
   iTmpR=iCustom(Symbol(),0,"Support and Resistance",0,0);
   iTmpS=iCustom(Symbol(),0,"Support and Resistance",1,0);
//----
   if (Close[0]==iTmpS) { myOrderType=1; }
   if (Close[0]==iTmpR) { myOrderType=2; }
   return(myOrderType);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrdersBasedOni_TrendRSI()
  {
   int myOrderType=3;
   double Buy1_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Buy1_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 1, 0);
   double Buy2_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Buy2_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 1);
   double Buy3_1=iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double Buy3_2=iRSI(NULL, 0, 14, PRICE_CLOSE, 1);
   double Sell1_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Sell1_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 1, 0);
   double Sell2_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Sell2_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 1);
   double Sell3_1=iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double Sell3_2=iRSI(NULL, 0, 14, PRICE_CLOSE, 1);
//----
   if (Buy1_1 > Buy1_2 && Buy2_1 > Buy2_2 && Buy3_1 > Buy3_2) { myOrderType=2; }
   if (Sell1_1 < Sell1_2 && Sell2_1 < Sell2_2 && Sell3_1 < Sell3_2) { myOrderType=1; }
   return(myOrderType);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrdersBasedOni_TrendRSISto()
  {
   int myOrderType=3;
   double Buy1_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Buy1_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 1, 0);
   double Buy2_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Buy2_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 1);
   double Buy3_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Buy3_2=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_SIGNAL, 0);
   double Buy4_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Buy4_2=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 1);
   double Buy5_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Buy5_2=80;
   double Buy6_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Buy6_2=20;
   double Buy7_1=iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double Buy7_2=iRSI(NULL, 0, 14, PRICE_CLOSE, 1);
   double Sell1_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Sell1_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 1, 0);
   double Sell2_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Sell2_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 1);
   double Sell3_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Sell3_2=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_SIGNAL, 0);
   double Sell4_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Sell4_2=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 1);
   double Sell5_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Sell5_2=80;
   double Sell6_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Sell6_2=30;
   double Sell7_1=iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double Sell7_2=iRSI(NULL, 0, 14, PRICE_CLOSE, 1);
//----
   if (Buy1_1 > Buy1_2 && Buy2_1 > Buy2_2 && Buy3_1 > Buy3_2 && Buy4_1 > Buy4_2 && Buy5_1 < Buy5_2 && Buy6_1 > Buy6_2 && Buy7_1 > Buy7_2) { myOrderType=2; }
   if (Sell1_1 < Sell1_2 && Sell2_1 < Sell2_2 && Sell3_1 < Sell3_2 && Sell4_1 < Sell4_2 && Sell5_1 < Sell5_2 && Sell6_1 > Sell6_2 && Sell7_1 < Sell7_2) { myOrderType=1; }
   return(myOrderType);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrdersBasedOni_TrRSIStoMFI()
  {
   int myOrderType=3;
   double Buy1_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Buy1_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 1, 0);
   double Buy2_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Buy2_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 1);
   double Buy3_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Buy3_2=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_SIGNAL, 0);
   double Buy4_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Buy4_2=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 1);
   double Buy5_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Buy5_2=80;
   double Buy6_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Buy6_2=20;
   double Buy7_1=iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double Buy7_2=iRSI(NULL, 0, 14, PRICE_CLOSE, 1);
   double Buy8_1=iMFI(NULL, 0, 5, 0);
   double Buy8_2=iMFI(NULL, 0, 5, 1);
   double Sell1_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Sell1_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 1, 0);
   double Sell2_1=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 0);
   double Sell2_2=iCustom(NULL, 0, "i_Trend", 0, 0, 0, 10, 2, 6, 300, 0, 1);
   double Sell3_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Sell3_2=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_SIGNAL, 0);
   double Sell4_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Sell4_2=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 1);
   double Sell5_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Sell5_2=80;
   double Sell6_1=iStochastic(NULL, 0, 8, 3, 4, MODE_EMA, 1, MODE_MAIN, 0);
   double Sell6_2=30;
   double Sell7_1=iRSI(NULL, 0, 14, PRICE_CLOSE, 0);
   double Sell7_2=iRSI(NULL, 0, 14, PRICE_CLOSE, 1);
   double Sell8_1=iMFI(NULL, 0, 5, 0);
   double Sell8_2=iMFI(NULL, 0, 5, 1);
//----
   if (Buy1_1 > Buy1_2 && Buy2_1 > Buy2_2 && Buy3_1 > Buy3_2 && Buy4_1 > Buy4_2 && Buy5_1 < Buy5_2 && Buy6_1 > Buy6_2 && Buy7_1 > Buy7_2 && Buy8_1 > Buy8_2) { myOrderType=2; }
   if (Sell1_1 < Sell1_2 && Sell2_1 < Sell2_2 && Sell3_1 < Sell3_2 && Sell4_1 < Sell4_2 && Sell5_1 < Sell5_2 && Sell6_1 > Sell6_2 && Sell7_1 < Sell7_2 && Sell8_1 < Sell8_2) { myOrderType=1; }
   return(myOrderType);
  }
//+------------------------------------------------------------------+