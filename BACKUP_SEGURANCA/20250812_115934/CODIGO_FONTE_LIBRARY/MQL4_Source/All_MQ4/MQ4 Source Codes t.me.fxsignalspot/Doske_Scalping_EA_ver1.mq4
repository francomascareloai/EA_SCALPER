//+------------------------------------------------------------------+
//|                                       Doske_Scalping_EA_ver1.mq4 |
//|                                                              Zen |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Zen"
#property link      ""
#include <stdlib.mqh>
#include <stderror.mqh>

#define ARRAY_SIZE    1000

extern int       EA_MAGIC_NUM = 113142;
extern int       iOpenHour = 6;  // open day hour 
extern int       HoursToTrade = 24;
extern bool      Use275SMA = true;
extern int       QQE5Buffer = 5;
extern int       QQE60Buffer = 5;

extern double    Slippage = 3.0;
extern int       TakeProfit = 0;
extern int       StopLoss = 0;
extern int       TrailingStop = 15;

extern bool      MoneyManagement = false;
extern double    RiskPercent = 1.0;
extern double    Lots = 0.1;
extern double    MaxLots = 15.0;
extern double    MinLots = 0.01;

string           msg = "";

int iCloseHour;
int DOSKE_MAGIC_NUM;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----
   DOSKE_MAGIC_NUM = EA_MAGIC_NUM + Period();
   iCloseHour = iOpenHour + HoursToTrade;
   if (iCloseHour >= 24)
   {
      iCloseHour = iCloseHour - 24;
   }
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

void WriteComment()
{
   msg = "";
   /*
   msg = msg + "GetGreenMA3Value: "+GetGreenMA3Value(0);
   msg = msg +" \nGetGreenMA5Value: "+GetGreenMA5Value(0);
   msg = msg + "\nGetGreenMA7Value: "+GetGreenMA7Value(0);
   msg = msg + "\nGetGreenMA9Value: "+GetGreenMA9Value(0);
   msg = msg +" \nGetGreenMA11Value: "+GetGreenMA11Value(0);
   msg = msg + "\nGetGreenMA13Value: "+GetGreenMA13Value(0);
   msg = msg + "\nGetPinkMA55Value: "+GetPinkMA55Value(0);
   msg = msg + "\nGetQQE5BlueLineValue: "+GetQQE5BlueLineValue(0);
   msg = msg + "\nGetQQE60BlueLineValue: "+GetQQE60BlueLineValue(0);
   msg = msg + "\nGetQQE60RedLineValue: "+GetQQE60RedLineValue(0);
   */
   
   Comment(msg);
}

double GetGreenMA3Value(int index)
{
   return (iMA(NULL, 0, 3, 0, MODE_EMA, PRICE_CLOSE, index));
}

double GetGreenMA5Value(int index)
{
   return (iMA(NULL, 0, 5, 0, MODE_EMA, PRICE_CLOSE, index));
}

double GetGreenMA7Value(int index)
{
   return (iMA(NULL, 0, 7, 0, MODE_EMA, PRICE_CLOSE, index));
}

double GetGreenMA9Value(int index)
{
   return (iMA(NULL, 0, 9, 0, MODE_EMA, PRICE_CLOSE, index));
}

double GetGreenMA11Value(int index)
{
   return (iMA(NULL, 0, 11, 0, MODE_EMA, PRICE_CLOSE, index));
}

double GetGreenMA13Value(int index)
{
   return (iMA(NULL, 0, 13, 0, MODE_EMA, PRICE_CLOSE, index));
}

double GetPinkMA55Value(int index)
{
   return (iMA(NULL, 0, 55, 0, MODE_EMA, PRICE_CLOSE, index));
}

double GetYellowMA275Value(int index)
{
   return (iMA(NULL, 0, 275, 0, MODE_SMA, PRICE_CLOSE, index));
}

double GetQQE5BlueLineValue(int index)
{
   return (iCustom(NULL,0,"QQE_Alert_MTF_v5",5,0," ",false,false,false,false,false,false,"","","","","","","","","","","","","","","",false,false,false,false,false,false,"",CLR_NONE,CLR_NONE,CLR_NONE,CLR_NONE,CLR_NONE,CLR_NONE,"",30,0,index));
}

double GetQQE60BlueLineValue(int index)
{
   return (iCustom(NULL,0,"QQE_Alert_MTF_v5",60,0," ",false,false,false,false,false,false,"","","","","","","","","","","","","","","",false,false,false,false,false,false,"",CLR_NONE,CLR_NONE,CLR_NONE,CLR_NONE,CLR_NONE,CLR_NONE,"",30,0,index));
}

double GetQQE60RedLineValue(int index)
{
   return (iCustom(NULL,0,"QQE_Alert_MTF_v5",60,0," ",false,false,false,false,false,false,"","","","","","","","","","","","","","","",false,false,false,false,false,false,"",CLR_NONE,CLR_NONE,CLR_NONE,CLR_NONE,CLR_NONE,CLR_NONE,"",30,1,index));
}

bool MAsSayBuy()
{
   if(GetGreenMA3Value(1)>GetPinkMA55Value(1) && GetGreenMA5Value(1)>GetPinkMA55Value(1) && GetGreenMA7Value(1)>GetPinkMA55Value(1) && GetGreenMA9Value(1)>GetPinkMA55Value(1) && GetGreenMA11Value(1)>GetPinkMA55Value(1) && GetGreenMA13Value(1)>GetPinkMA55Value(1))
   {
      if (Use275SMA)
      {
         if(GetGreenMA3Value(1)>GetYellowMA275Value(1) && GetGreenMA5Value(1)>GetYellowMA275Value(1) && GetGreenMA7Value(1)>GetYellowMA275Value(1) && GetGreenMA9Value(1)>GetYellowMA275Value(1) && GetGreenMA11Value(1)>GetYellowMA275Value(1) && GetGreenMA13Value(1)>GetYellowMA275Value(1))
         {
            return (true);
         }
      }
      else
      {
         return (true);
      }
   }
   return (false);
}

bool MAsSaySell()
{
   if(GetGreenMA3Value(1)<GetPinkMA55Value(1) && GetGreenMA5Value(1)<GetPinkMA55Value(1) && GetGreenMA7Value(1)<GetPinkMA55Value(1) && GetGreenMA9Value(1)<GetPinkMA55Value(1) && GetGreenMA11Value(1)<GetPinkMA55Value(1) && GetGreenMA13Value(1)<GetPinkMA55Value(1))
   {
      if (Use275SMA)
      {
         if(GetGreenMA3Value(1)<GetYellowMA275Value(1) && GetGreenMA5Value(1)<GetYellowMA275Value(1) && GetGreenMA7Value(1)<GetYellowMA275Value(1) && GetGreenMA9Value(1)<GetYellowMA275Value(1) && GetGreenMA11Value(1)<GetYellowMA275Value(1) && GetGreenMA13Value(1)<GetYellowMA275Value(1))
         {
            return (true);
         }
      }
      else
      {
         return (true);
      }
   }
   return (false);
}

bool QQE5SaysBuy()
{
   if(GetQQE5BlueLineValue(1)>50)
   {
      for (int i=2; i<=2+QQE5Buffer; i++)
      {
         if(GetQQE5BlueLineValue(i)<50)
         {
            return (true);
         }
      }
   }
   return (false);
}

bool QQE5SaysSell()
{
   if(GetQQE5BlueLineValue(1)<50)
   {
      for (int i=2; i<=2+QQE5Buffer; i++)
      {
         if(GetQQE5BlueLineValue(i)>50)
         {
            return (true);
         }
      }
   }
   return (false);
}

bool QQE60SaysBuy()
{
   if(GetQQE60BlueLineValue(1)>GetQQE60RedLineValue(1))
   {
      for (int i=2; i<=2+QQE60Buffer; i++)
      {
         if(GetQQE60BlueLineValue(i)<GetQQE60RedLineValue(i))
         {
            return (true);
         }
      }
   }
   return (false);
}

bool QQE60SaysSell()
{
   if(GetQQE60BlueLineValue(1)<GetQQE60RedLineValue(1))
   {
      for (int i=2; i<=2+QQE60Buffer; i++)
      {
         if(GetQQE60BlueLineValue(i)>GetQQE60RedLineValue(i))
         {
            return (true);
         }
      }
   }
   return (false);
}

bool ShouldBuy()
{
   if (MAsSayBuy() && QQE5SaysBuy() && QQE60SaysBuy())
   {
      return (true);
   }
   return (false);
}

bool ShouldSell()
{
   if (MAsSaySell() && QQE5SaysSell() && QQE60SaysSell())
   {
      return (true);
   }
   return (false);
}

double PositionSizeToOpen() // only works for JPY, CHF, CAD, GBP, NZD, AUD and USD secondary based pairs (apologies to exotic pairs traders)
{
   if (MoneyManagement && StopLoss != 0)
   {  
      double riskDollars = (AccountBalance()/100)*RiskPercent;
      double PositionSize;
      double USDCHFBid, USDJPYBid, USDCADBid, GBPUSDBid, AUDUSDBid, NZDUSDBid;
      
      if (StringSubstr(Symbol(), 3, 3)=="USD")
      {
         PositionSize = riskDollars / (StopLoss * Point) / 100000;
      }
      
      if (StringSubstr(Symbol(), 3, 3)=="CHF")
      {
         USDCHFBid = iClose("USDCHF",PERIOD_D1,1); // get yesterday's exchange rate between USD and CHF
         PositionSize = riskDollars / (StopLoss * Point * (1/USDCHFBid)) / 100000;
      }
      
      if (StringSubstr(Symbol(), 3, 3)=="JPY")
      {
         USDJPYBid = iClose("USDJPY",PERIOD_D1,1); // get yesterday's exchange rate between USD and JPY
         PositionSize = riskDollars / (StopLoss * Point * (1/USDJPYBid)) / 100000;
      }
      
      if (StringSubstr(Symbol(), 3, 3)=="CAD")
      {
         USDCADBid = iClose("USDCAD",PERIOD_D1,1); // get yesterday's exchange rate between USD and CAD
         PositionSize = riskDollars / (StopLoss * Point * (1/USDCADBid)) / 100000;
      }
      
      if (StringSubstr(Symbol(), 3, 3)=="GBP")
      {
         GBPUSDBid = iClose("GBPUSD",PERIOD_D1,1); // get yesterday's exchange rate between GBP and USD
         PositionSize = riskDollars / (StopLoss * Point * GBPUSDBid) / 100000;
      }
      
      if (StringSubstr(Symbol(), 3, 3)=="NZD")
      {
         NZDUSDBid = iClose("NZDUSD",PERIOD_D1,1); // get yesterday's exchange rate between NZD and USD
         PositionSize = riskDollars / (StopLoss * Point * NZDUSDBid) / 100000;
      }
      
      if (StringSubstr(Symbol(), 3, 3)=="AUD")
      {
         AUDUSDBid = iClose("AUDUSD",PERIOD_D1,1); // get yesterday's exchange rate between NZD and USD
         PositionSize = riskDollars / (StopLoss * Point * AUDUSDBid) / 100000;
      }
      
      PositionSize = NormalizeDouble(PositionSize,2);
      if (PositionSize < MinLots)
      {
         PositionSize = MinLots;
      }
      if (PositionSize > MaxLots)
      {
         PositionSize = MaxLots;
      }
      return (PositionSize);
   }
   else
   {
      return (Lots);
   }  
}

void WriteToLogFile(string input)
{
   string filename = "ZEROLAG-"+Symbol()+"-"+Day()+"-"+Month()+"-"+Year()+".log";
   int handle = FileOpen(filename,FILE_READ|FILE_WRITE);
   if (handle>1)
   {
      FileSeek(handle, 0, SEEK_END); // go to end of file
      FileWrite(handle, input);
      FileClose(handle);
   }
}


bool DecideToOpenTrade(int tradeType)
{
   int total = OrdersTotal();
   if (total > 0)
   {
      for(int cnt=0;cnt<total;cnt++)
      {
         if(OrderSelect(cnt,SELECT_BY_POS))
         {
            if(OrderSymbol()==Symbol() && OrderMagicNumber() == DOSKE_MAGIC_NUM && (OrderType()==tradeType))
            {
              // if (Time[0] <= OrderOpenTime()) // don't open a new position if we're still on the same candle
            //   {
                  return (false);
            //   }
            }
         }
      }
   }
   // in case trades has already opened and closed within the candle
   int histotal = OrdersHistoryTotal();
   if (histotal > 0)
   {
      for(cnt=0;cnt<histotal;cnt++)
      {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_HISTORY))
         {
            if(OrderSymbol()==Symbol() && OrderMagicNumber() == DOSKE_MAGIC_NUM && (OrderType()==tradeType))
            {
               if (Time[0] <= OrderOpenTime()) // don't open a new position if we're still on the same candle
               {
                  return (false);
               }
            }
         }
      }
   }
   return (true);
}

void SendOrders (int BuyOrSell, double LotSize, double PriceToOpen, double Slippage, double SL_Price, double TP_Price, string comments, datetime ExpirationTime)
{
   int PositionType, ticket, errorType;
   
   if (BuyOrSell == OP_BUY)
   {  
      PositionType = OP_BUY;
      Print("Bid: "+Bid+" Ask: "+Ask+" | Opening Buy Order: "+Symbol()+", "+PositionType+", "+LotSize+", "+PriceToOpen+", "+Slippage+", "+SL_Price+", "+TP_Price+", "+comments+", "+DOSKE_MAGIC_NUM+", "+ExpirationTime+", Green");
      ticket=OrderSend(Symbol(),PositionType,LotSize,PriceToOpen,Slippage,SL_Price,TP_Price,comments,DOSKE_MAGIC_NUM,ExpirationTime,Green);
      if(ticket>0)
      {
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
         {
            
            Print("BUY order opened : ",OrderOpenPrice());
            msg = ticket + ": Buy position opened on "+Symbol()+" at "+ Day()+"/"+Month()+"/"+Year()+" - "+Hour()+":"+Minute()+":"+Seconds();
            WriteToLogFile(msg);
         }
      }
      else 
      {  
         errorType = GetLastError();
         Print("Error opening BUY order : ", ErrorDescription(errorType));
         msg = "CANNOT open BUY position on "+Symbol()+" at "+ Day()+"/"+Month()+"/"+Year()+" - "+Hour()+":"+Minute()+":"+Seconds();
         WriteToLogFile(msg);
      }
   }
   if (BuyOrSell == OP_SELL)
   {  
      PositionType = OP_SELL;
      Print("Bid: "+Bid+" Ask: "+Ask+" | Opening Sell Order: "+Symbol()+", "+PositionType+", "+LotSize+", "+PriceToOpen+", "+Slippage+", "+SL_Price+", "+TP_Price+", "+comments+", "+DOSKE_MAGIC_NUM+", "+ExpirationTime+", Red");
      ticket=OrderSend(Symbol(),PositionType,LotSize,PriceToOpen,Slippage,SL_Price,TP_Price,comments,DOSKE_MAGIC_NUM,ExpirationTime,Red);
      if(ticket>0)
      {
         if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) 
         {
            
            Print("Sell order opened : ",OrderOpenPrice());
            msg = ticket + ": Sell position opened on "+Symbol()+" at "+ Day()+"/"+Month()+"/"+Year()+" - "+Hour()+":"+Minute()+":"+Seconds();
            WriteToLogFile(msg);
         }
      }
      else 
      {  
         errorType = GetLastError();
         Print("Error opening SELL order : ", ErrorDescription(errorType));
         msg = "CANNOT open SELL position on "+Symbol()+" at "+ Day()+"/"+Month()+"/"+Year()+" - "+Hour()+":"+Minute()+":"+Seconds();
         WriteToLogFile(msg);
      }
   }
}

void UpdateStatus()
{
   int total = OrdersTotal();
   if (total > 0)
   {
      for(int cnt=0;cnt<total;cnt++)
      {
         if(OrderSelect(cnt,SELECT_BY_POS))
         {
            if(OrderSymbol()==Symbol() && OrderMagicNumber() == DOSKE_MAGIC_NUM)
            {
               if (OrderType() == OP_BUY)
               {
                  if(GetQQE60BlueLineValue(0)<GetQQE60RedLineValue(0))
                  {
                     OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Yellow);
                  }
               }
               
               if (OrderType() == OP_SELL)
               {
                  if(GetQQE60BlueLineValue(0)>GetQQE60RedLineValue(0))
                  {
                     OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Yellow);
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
//----
   UpdateStatus();
   //WriteComment();
   
   int CurrentHour = TimeHour(TimeCurrent());
   // Only monitor a user defined period of the day
   if ((CurrentHour >= iOpenHour && CurrentHour < iCloseHour) ||  HoursToTrade == 24)
   {
      double PriceToOpen;
      double TakeProfitPrice;
      double StopLossPrice;
      
      if (ShouldBuy())
      {
         if (DecideToOpenTrade(OP_BUY))
         {
            PriceToOpen = Ask;
            if (TakeProfit == 0)
            {
               TakeProfitPrice = 0;
            }
            else
            {
               TakeProfitPrice = PriceToOpen + (TakeProfit * Point);
               TakeProfitPrice = NormalizeDouble(TakeProfitPrice,Digits);
            }
            if (StopLoss == 0)
            {
               StopLossPrice = 0;
            }
            else
            {
               StopLossPrice = PriceToOpen - (StopLoss * Point);
               StopLossPrice = NormalizeDouble(StopLossPrice,Digits);
            }
            SendOrders(OP_BUY, PositionSizeToOpen(), PriceToOpen, Slippage, StopLossPrice, TakeProfitPrice, "DOSKE_Buy_"+DOSKE_MAGIC_NUM+" [PRIMARY]", 0);
         }
      }
      if (ShouldSell())
      {
         if (DecideToOpenTrade(OP_SELL))
         {
            PriceToOpen = Bid;
            if (TakeProfit==0)
            {
               TakeProfitPrice = 0;
            }
            else
            {
               TakeProfitPrice = PriceToOpen - (TakeProfit * Point);
               TakeProfitPrice = NormalizeDouble(TakeProfitPrice,Digits);
            }
            if (StopLoss==0)
            {
               StopLossPrice = 0;
            }
            else
            {
               StopLossPrice = PriceToOpen + (StopLoss * Point);
               StopLossPrice = NormalizeDouble(StopLossPrice,Digits);
            }
            SendOrders(OP_SELL, PositionSizeToOpen(), PriceToOpen, Slippage, StopLossPrice, TakeProfitPrice, "DOSKE_Sell_"+DOSKE_MAGIC_NUM+" [PRIMARY]", 0);
         }
      }
   }
//----
   return(0);
}
//+------------------------------------------------------------------+