//+------------------------------------------------------------------+
//|                                                        (EK) 2008 |
//|                                                                  |
//+------------------------------------------------------------------+
 
//--------ANTI SERAKAH--------
extern string  Balance_Info   = "Bila sudah tercapai ROBOT berhenti, INGAT JANGAN serakah";
extern double  TargetBalance  = 3000000;     

extern string  AutoStop_Info   = "AutoStop=false, tidak buka posisi baru, posisi yg lama tetap di maintain";
extern bool    AutoStop        = false;     

//--------TradingTime--------
extern  string  Time_Info   = "Jam Trading waktu Server";
extern  int     OpenHour    = 20; //19
extern  int     CloseHour   = 9;
//int     CloseHour2   = 1;
 
extern  string  MM_Info   = "Kalau MM=true, isi risk berapa persen yg mau di pake.";
extern  bool    MM        = true;  // pake MM
extern  int     Risk      = 7;     // persentase MM

extern  string  Lots_Info = "Kalau MM=false, isi Lots yg mau di pake.";
extern  double  Lots      = 1;     // kalo 'MM=false' pake lot

string  MaxLots_Info = "Maximum dan Minimum Lot, nggak bisa lebih dari ini.";
extern  double  MaxLots     = 100; 
extern  double  MinLots     = 0.1;

string  LotsDigit_Info = "LotsDigit=0, maka akan ambil dari system";
extern  int     LotsDigit   = 1;
extern  int     Slippage    = 3;

extern  string  Trade_Info = "TP=TakeProfit, disarankan sedikit saja";
extern  int     TP         = 5;     // jangan besar-besar  

extern  string  SL1_Info   = "SL1=StopLoss bukan jam trading";
extern  int     SL1        = 19; //19   // SL kalau jam close

extern  string  SL2_Info   = "SL2=StopLoss jam trading";
extern  int     SL2        = 31; //31   // SL kalau jam trading

extern  string  HiddenTP_Info   = "Bila true, maka TP tidak di set";
extern  bool    HiddenTP        = true;

//----------------------------------------------------------------------------
extern  string  Filter_Info       = "Filter untuk buka posisi";
extern  int     SignalFilter      = 5;
extern  int     MaxTrades         = 7;
extern  int     MaxTradePerBar    = 7;  //3
extern  int     MaxTradePerPosition = 6;
extern  int     IMA_PERIOD        = 11;
extern  int     Magic             = 11111;

//----------------------------------------------------------------------------
int            TradePerBar = 0;

//---------------------------------------------------------------------------- 
double         Last_BUY_OpenPrice        = 0;
double         Last_SELL_OpenPrice       = 0;
int            BarCount                  = -1;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   if(1==2 || 3==4 && 5==6) return (0);
   
   Comment("\nMyLuckyPro V.0.4p",
           "\nLagi persiapan....");
           
   if(7==8 || 9==10 && 11==12) return (0);
   return(0);
  }
 
int start()
{ 

   if(AutoStop==true)
   {
      CloseAll(); 
      return(0);
   }   

   //Filter ANTI SERAKAH..
   if(TargetBalance>0 && AccountEquity() >= TargetBalance)
   {
      Comment("\nMyLuckyPro V.0.4p",
              "\nSTOP TRADING....",
              "\n\nTargetBalance = ", TargetBalance,
              "\nAccountEquity = ", AccountEquity(),
              "\n\nSELAMAT TARGET TELAH TERCAPAI...!",
	           "\nSEGERA WITHDRAW dan jangan LUPA BERAMAL..");			 
      
      ForceCloseAll(); 
      return(0);
   }
   
   if(                 2 != 3 ||
      AccountNumber()==125082 || 
      AccountNumber()==127249 ||
      AccountNumber()==133825 ||
      AccountNumber()==120076 ||
      AccountNumber()==129224 ||
      AccountNumber()==133291 ||
      AccountNumber()==213470 ||
      AccountNumber()==130860 ||
      AccountNumber()==133422 ||
      AccountNumber()==215814 ||
      AccountNumber()==114433 ||
      AccountNumber()==192854 ||
      AccountNumber()==115207 ||
      AccountNumber()==125203 ||
      AccountNumber()==215387 ||
      AccountNumber()==7695   ||
      AccountNumber()==20277  ||
      AccountNumber()==127599 ||
      AccountNumber()==131187 || 
                         1 != 2)
   {
      if(Year()>2008 && Month()>3)
      {
         Comment("\nMyLuckyPro V.0.4p",
                 "\nSTOP TRADING....");
         return(0);
      }
   }
   else {
       if(IsDemo()==false)
       {
         Comment("\nMyLuckyPro V.0.4p",
                 "\nSTOP TRADING....",
                 "\n\nAccount = ", AccountNumber(), " tidak terdaftar..." );
         return(0);
       }
   }   
   
   /*
   if(IsOptimization()==true && !(AccountNumber()==125082 || AccountNumber()==127249))
   {
      Print("Sudahlah, nggak usah pake optimization, pake forward test aza bro..");
      return(0);
   }
   if(IsTesting()==true && !(AccountNumber()==125082 || AccountNumber()==127249))
   {
      Comment("\nMyLuckyPro V.0.4p",
              "\nSTOP TRADING....");
      Print("Sudahlah, nggak usah pake testing segala, pake forward test aza bro..");
      return(0);
   }
   */

   
   int            BUY_OpenPosition     = 0;
   int            SELL_OpenPosition    = 0;
   int            TOTAL_OpenPosition   = 0;
   int            Ticket               = -1;
   int            cnt                  = 0;
   
   for (cnt = 0; cnt < OrdersTotal(); cnt++) 
   {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderCloseTime()==0) 
      {
         TOTAL_OpenPosition++;
         if (OrderType() == OP_BUY) 
         {
            BUY_OpenPosition++;
            Last_BUY_OpenPrice = OrderOpenPrice();
         }
         if (OrderType() == OP_SELL) 
         {
            SELL_OpenPosition++;
            Last_SELL_OpenPrice = OrderOpenPrice();
         }
      }
   }

   if (Tradetime()==1)   
   {
      if (Tradetime2()==1) 
         Comment("\nMyLuckyPro V.0.4p",
                 "\nIstirahat Dulu... Senin Pagi,Siang & Malam dan Jumat Siang & Malam (WIB)",
                 "\n\nMulai Trading Jam = ", OpenHour,
                 "\nSelesai Trading Jam = ", CloseHour,
	              "\nSekarang Jam = ", Hour()			 
	 	         );
	 	         
      else 
      {
         Comment("\nMyLuckyPro V.0.4p",
                 "\nLAGI TRADING...",
                 "\n\nMulai Trading Jam = ", OpenHour,
                 "\nSelesai Trading Jam = ", CloseHour,
                 "\nSekarang Jam = ", Hour()			 
 	            );

         if(TOTAL_OpenPosition <= MaxTrades)
         {
            if(BarCount != Bars)
            {
               TradePerBar = 0;
               BarCount = Bars;
            }

            RefreshRates();
            if ((SELL_OpenPosition <= MaxTradePerPosition) && (TradePerBar <= MaxTradePerBar) && ((Ask - Last_SELL_OpenPrice >= SignalFilter * Point) || SELL_OpenPosition < 1) && GetSignal(OP_SELL)==1)
            {

               if(AccountFreeMarginCheck(Symbol(),OP_SELL,GetLots())<=0 || GetLastError()==134) 
               {
                  Print("Bro, udah nggak punya Margin lagi nih, nggak bisa OP...");
               }
               else
               {
                  if(HiddenTP==true)
                     Ticket = OrderSend(Symbol(),OP_SELL,GetLots(),Bid,Slippage,Bid + SL2 * Point,0,"MyLucky"+Symbol(),Magic,0,Red); 
                  else
                     Ticket = OrderSend(Symbol(),OP_SELL,GetLots(),Bid,Slippage,Bid + SL2 * Point,Bid - TP * Point,"MyLucky"+Symbol(),Magic,0,Red); 
                  if (Ticket > 0) TradePerBar++;
               }
            }
            if ((BUY_OpenPosition <= MaxTradePerPosition) && (TradePerBar <= MaxTradePerBar) && ((Last_BUY_OpenPrice - Bid >= SignalFilter * Point ) || BUY_OpenPosition < 1) && GetSignal(OP_BUY)==1)
            {
		      
               if(AccountFreeMarginCheck(Symbol(),OP_BUY,GetLots())<=0 || GetLastError()==134) 
               {
                  Print("Bro, udah nggak punya Margin lagi nih, nggak bisa OP...");
               }
               else
               {
                  if(HiddenTP==true)
                     Ticket = OrderSend(Symbol(),OP_BUY,GetLots(),Ask,Slippage,Ask - SL2 * Point, 0,"MyLucky"+Symbol(),Magic,0,Blue); 
                  else
                     Ticket = OrderSend(Symbol(),OP_BUY,GetLots(),Ask,Slippage,Ask - SL2 * Point, Ask + TP * Point,"MyLucky"+Symbol(),Magic,0,Blue); 
                  if (Ticket > 0) TradePerBar++;
               }
            }
         
          }
       }
   }
   else
      Comment("\nMyLuckyPro V.0.4p",
              "\nIstirahat Dulu... ",
              "\n\nMulai Trading Jam = ", OpenHour,
              "\nSelesai Trading Jam = ", CloseHour,
              "\nSekarang Jam = ", Hour()			 
 	         );
   
   
   CloseAll(); 
   return(0);
} 

//----------------------------------------------------------------------------- 
int GetSignal(int OP)
{
  int signal=0;
  if (OP==OP_BUY)
  {
   if(iClose(Symbol(),0,0)<iMA(Symbol(),0,IMA_PERIOD,0,MODE_SMA,PRICE_OPEN,0)) signal=1;
  }
  else if (OP==OP_SELL)
  {
   if(iClose(Symbol(),0,0)>iMA(Symbol(),0,IMA_PERIOD,0,MODE_SMA,PRICE_OPEN,0)) signal=1;
  }
  return(signal);
}
//----------------------------------------------------------------------------- 
void CloseAll() 
{ 
   for (int cnt = OrdersTotal()-1 ; cnt >= 0; cnt--) 
   { 
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderCloseTime()==0) 
      { 
         if (SecurProfit()==1)
         { 
            if(OrderType()==OP_BUY)  OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue); 
            if(OrderType()==OP_SELL) OrderClose(OrderTicket(),OrderLots(),Ask,3,Red); 
         } 
         else 
         { 
            if (Tradetime() == 0)
            {
               if((OrderType()==OP_BUY)  && (((OrderOpenPrice()-Ask)/Point) > SL1)) 
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue); 
               if((OrderType()==OP_SELL) && (((Bid-OrderOpenPrice())/Point) > SL1)) 
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red); 
            }
            else
            {
               if((OrderType()==OP_BUY)  && (((OrderOpenPrice()-Ask)/Point) > SL2)) 
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue); 
               if((OrderType()==OP_SELL) && (((Bid-OrderOpenPrice())/Point) > SL2)) 
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red); 
            }
         } 
      } 
   } 
} 
//----------------------------------------------------------------------------- 
void ForceCloseAll() 
{ 
   for (int cnt = OrdersTotal()-1 ; cnt >= 0; cnt--) 
   { 
      OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); 
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderCloseTime()==0) 
      { 
            if(OrderType()==OP_BUY)  OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue); 
            if(OrderType()==OP_SELL) OrderClose(OrderTicket(),OrderLots(),Ask,3,Red); 
      } 
   } 
}
//----------------------------------------------------------------------------- 
int Tradetime() 
{
   int TradingTime=0;
   if (Hour() <= CloseHour || Hour() >= OpenHour)   
      TradingTime=1;
   return(TradingTime); 
}
//----------------------------------------------------------------------------- 
int Tradetime2() 
{
   int TradingTime=0;
   if ((DayOfWeek() == 1 && Hour() <= OpenHour) || (DayOfWeek() == 5 && Hour() >= CloseHour))
      TradingTime=1;
   return(TradingTime); 
}
//----------------------------------------------------------------------------- 
double GetLots() 
{
   double lots,MD,RM,FMM,MinLots; int lotsdigit;
   MD = NormalizeDouble(MarketInfo(Symbol(), MODE_LOTSTEP), 2); 
   RM = NormalizeDouble(MarketInfo(Symbol(), MODE_MARGINREQUIRED), 4);
   FMM = (RM+5)*100;
   if(LotsDigit==0)
   {
      if (MD==0.01) lotsdigit=2;
      else lotsdigit=1;
      LotsDigit=lotsdigit;
   }
   if (MM==true) lots = NormalizeDouble(AccountFreeMargin()/(FMM/Risk)-0.05,LotsDigit);
   else lots=Lots;
   MinLots=NormalizeDouble(MarketInfo(Symbol(),MODE_MINLOT),2);    
   //if (LotsDigit == 2) MinLots = 0.01; 
   if (lots < MinLots) lots = MinLots;  
   if (lots > MaxLots) lots = MaxLots;     
   return (lots);      
}
//----------------------------------------------------------------------------- 
double TickValue() 
{
   double tv;
   tv = NormalizeDouble(MarketInfo(Symbol(), MODE_TICKVALUE), 4); 
   return(tv);
}
//----------------------------------------------------------------------------- 
int SecurProfit() 
{
   int sp=0;
   if (OrderProfit()>(TickValue()*GetLots()*TP)) sp=1; 
   return(sp);
}
//----------------------------------------------------------------------------- 
   
   