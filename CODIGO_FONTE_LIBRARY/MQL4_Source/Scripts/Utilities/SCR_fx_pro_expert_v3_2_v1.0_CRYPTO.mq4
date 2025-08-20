extern int     MMType=1;       /// LotExponent
extern bool    UseClose=false; ///  PipStep = false 
extern bool    UseAdd=true;    /// LotExponent  MMType  = true
extern double  LotExponent=1.777; /// 0.1, 0.16, 0.26, 0.43 
extern double  slip=3;   
extern double  Lots=0.1; /// 0.01 0.1 0.16
extern double  LotsDigits=2;  /// 2 - 0.01, 1 - 0.1, 0 - 1.0
extern double  TakeProfit=10; 
double  Stoploss=0.0; 
double  TrailStart=0;
double  TrailStop=0;
extern double  PipStep=7; 
extern int     MaxTrades=2;
extern bool    UseEquityStop=false;
extern double  TotalEquityRisk=0.10;
extern bool    UseTrailingStop=false;
extern bool    UseTimeOut=false;
extern double  MaxTradeOpenHours=0;
//----
int MagicNumber=12324;
double PriceTarget, StartEquity, BuyTarget, SellTarget;
int sav;
double AveragePrice, SellLimit, BuyLimit;
double LastBuyPrice, LastSellPrice, ClosePrice, Spread;
int flag;
string EAName="fx pro expert v3";
int vee;
datetime timeprev=0, expiration;
int NumOfTrades=0;
int wbf;
double iLots;
int cnt=0, total;
double Stopper=0;
bool TradeNow=true, LongTrade=true, ShortTrade=true;
int ticket;
bool NewOrdersPlaced=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Spread=MarketInfo(Symbol(), MODE_SPREAD)*Point;
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int start()
  {
     if (UseTrailingStop)
     {
      TrailingAlls(TrailStart, TrailStop, AveragePrice);
     }
     if (UseTimeOut){
        if(CurTime()>=expiration)
        {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
        }
     }
     if(timeprev==Time[0])
     {
      return(0);
     }
   timeprev=Time[0];
//----
   double CurrentPairProfit=CalculateProfit();
     if(UseEquityStop){
        if(CurrentPairProfit<0 && MathAbs(CurrentPairProfit)>(TotalEquityRisk/100)*AccountEquityHigh())
        {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         NewOrdersPlaced=false;
        }
     }
   total=CountTrades();
//----
     if (total==0)
     {
      flag=0;
     }
   double LastBuyLots;
   double LastSellLots;
     for(cnt=OrdersTotal()-1;cnt>=0;cnt--){
      sav=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)continue;
      if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
           if(OrderType()==OP_BUY)
           {
            LongTrade=true;
            ShortTrade=false;
            LastBuyLots=OrderLots();
            break;
           }
      if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
           if(OrderType()==OP_SELL)
           {
            LongTrade=false;
            ShortTrade=true;
            LastSellLots=OrderLots();
            break;
           }
     }
     if(total>0 && total<=MaxTrades)
     {
      RefreshRates();
      LastBuyPrice=FindLastBuyPrice();
      LastSellPrice=FindLastSellPrice();
        if(LongTrade && (LastBuyPrice - Ask)>=(PipStep*Point))
        {
         TradeNow=true;
        }
        if(ShortTrade && (Bid - LastSellPrice)>=(PipStep*Point))
        {
         TradeNow=true;
        }
     }
     if (total < 1)
     {
      ShortTrade=false;
      LongTrade=false;
      TradeNow=true;
      StartEquity=AccountEquity();
     }
     if (TradeNow)
     {
      LastBuyPrice=FindLastBuyPrice();
      LastSellPrice=FindLastSellPrice();
        if(ShortTrade)
        {
           if(UseClose)
           {
            fOrderCloseMarket(false,true);
            iLots=NormalizeDouble(LotExponent*LastSellLots,LotsDigits);
           }
           else
           {
            iLots=fGetLots(OP_SELL);
           }
           if(UseAdd)
           {
            NumOfTrades=total;
              if(iLots>0)
              {//#
               RefreshRates();
               ticket=OpenPendingOrder(OP_SELL,iLots,Bid,slip,Ask,0,0,EAName+"-"+NumOfTrades,MagicNumber,0,HotPink);
               if(ticket<0){Print("Error: ",GetLastError()); return(0);}
               LastSellPrice=FindLastSellPrice();
               TradeNow=false;
               NewOrdersPlaced=true;
              }//#
           }
        }
        else if (LongTrade)
        {
              if(UseClose)
              {
               fOrderCloseMarket(true,false);
               iLots=NormalizeDouble(LotExponent*LastBuyLots,LotsDigits);
              }
              else
              {
               iLots=fGetLots(OP_BUY);
              }
              if(UseAdd)
              {
               NumOfTrades=total;
                 if(iLots>0)
                 {//#
                  ticket=OpenPendingOrder(OP_BUY,iLots,Ask,slip,Bid,0,0,EAName+"-"+NumOfTrades,MagicNumber,0,Lime);
                  if(ticket<0)
                  {Print("Error: ",GetLastError()); return(0);}
                  LastBuyPrice=FindLastBuyPrice();
                  TradeNow=false;
                  NewOrdersPlaced=true;
                 }//#
              }
           }
     }
     if (TradeNow && total<1)
     {
      double PrevCl=iClose(Symbol(),0,2);
      double CurrCl=iClose(Symbol(),0,1);
      SellLimit=Bid;
      BuyLimit=Ask;
        if(!ShortTrade && !LongTrade)
        {
         NumOfTrades=total;
           if(PrevCl > CurrCl)
           {
            iLots=fGetLots(OP_SELL);
              if(iLots>0)
              {//#
               ticket=OpenPendingOrder(OP_SELL,iLots,SellLimit,slip,SellLimit,0,0,EAName+"-"+NumOfTrades,MagicNumber,0,HotPink);
               if(ticket<0){Print(iLots,"Error: ",GetLastError()); return(0);
               }
               LastBuyPrice=FindLastBuyPrice();
               NewOrdersPlaced=true;
              }//#
           }
           else
           {
            iLots=fGetLots(OP_BUY);
              if(iLots>0)
              {//#      
               ticket=OpenPendingOrder(OP_BUY,iLots,BuyLimit,slip,BuyLimit,0,0,EAName+"-"+NumOfTrades,MagicNumber,0,Lime);
               if(ticket<0){Print(iLots,"Error: ",GetLastError()); return(0);}
               LastSellPrice=FindLastSellPrice();
               NewOrdersPlaced=true;
              }//#
           }
        }
      if(ticket>0) expiration=CurTime()+MaxTradeOpenHours*60*60;
      TradeNow=false;
     }
//----------------------- CALCULATE AVERAGE OPENING PRICE
   total=CountTrades();
   AveragePrice=0;
   double Count=0;
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      sav=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
         if(OrderType()==OP_BUY || OrderType()==OP_SELL)
           {
            AveragePrice=AveragePrice+OrderOpenPrice()*OrderLots();
            Count=Count + OrderLots();
           }
     }
   if(total > 0)
      AveragePrice=NormalizeDouble(AveragePrice/Count, Digits);
//----------------------- RECALCULATE STOPLOSS & PROFIT TARGET BASED ON AVERAGE OPENING PRICE
   if(NewOrdersPlaced)
      for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
        {
         sav=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
            continue;
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
            if(OrderType()==OP_BUY) // Calculate profit/stop target for long 
              {
               PriceTarget=AveragePrice+(TakeProfit*Point);
               BuyTarget=PriceTarget;
               Stopper=AveragePrice-(Stoploss*Point);
               //      Stopper=0; 
               flag=1;
              }
         if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
            if(OrderType()==OP_SELL) // Calculate profit/stop target for short
              {
               PriceTarget=AveragePrice-(TakeProfit*Point);
               SellTarget=PriceTarget;
               Stopper=AveragePrice+(Stoploss*Point);
               //      Stopper=0; 
               flag=1;
              }
        }
//----------------------- IF NEEDED CHANGE ALL OPEN ORDERS TO NEWLY CALCULATED PROFIT TARGET    
   if(NewOrdersPlaced)
      if(flag==1)// check if average has really changed
        {
         for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
           {
            //     PriceTarget=total;
            sav=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
            if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
               continue;
            if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
               //      OrderModify(OrderTicket(),0,Stopper,PriceTarget,0,Yellow);// set all positions to averaged levels
               wbf=OrderModify(OrderTicket(),AveragePrice,OrderStopLoss(),PriceTarget,0,Yellow);// set all positions to averaged levels
            NewOrdersPlaced=false;
           }
        }
  return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ND(double v){return(NormalizeDouble(v,Digits));}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int fOrderCloseMarket(bool aCloseBuy=true,bool aCloseSell=true)
  {
   int tErr=0;
     for(int i=OrdersTotal()-1;i>=0;i--)
     {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
           if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
           {
              if(OrderType()==OP_BUY && aCloseBuy)
              {
               RefreshRates();
                 if(!IsTradeContextBusy())
                 {
                    if(!OrderClose(OrderTicket(),OrderLots(),ND(Bid),5,CLR_NONE))
                    {
                     Print("Error close BUY "+OrderTicket());//+" "+fMyErDesc(GetLastError())); 
                     tErr=-1;
                    }
                 }
                 else
                 {
                  static int lt1=0;
                    if(lt1!=iTime(NULL,0,0))
                    {
                     lt1=iTime(NULL,0,0);
                     Print("Need close BUY "+OrderTicket()+". Trade Context Busy");
                    }
                  return(-2);
                 }
              }
              if(OrderType()==OP_SELL && aCloseSell)
              {
               RefreshRates();
                 if(!IsTradeContextBusy())
                 {
                    if(!OrderClose(OrderTicket(),OrderLots(),ND(Ask),5,CLR_NONE))
                    {
                     Print("Error close SELL "+OrderTicket());//+" "+fMyErDesc(GetLastError())); 
                     tErr=-1;
                    }
                 }
                 else
                 {
                  static int lt2=0;
                    if(lt2!=iTime(NULL,0,0))
                    {
                     lt2=iTime(NULL,0,0);
                     Print("Need close SELL "+OrderTicket()+". Trade Context Busy");
                    }
                  return(-2);
                 }
              }
           }
        }
     }
   return(tErr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  double fGetLots(int aTradeType)
  {
   double tLots;
     switch(MMType)
     {
         case 0:
            tLots=Lots;
            break;
         case 1:
            tLots=NormalizeDouble(Lots*MathPow(LotExponent,NumOfTrades),LotsDigits);
            break;
         case 2:
            int LastClosedTime=0;
            tLots=Lots;
              for(int i=OrdersHistoryTotal()-1;i>=0;i--)
              {
                 if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
                 {
                    if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
                    {
                       if(LastClosedTime<OrderCloseTime())
                       {
                        LastClosedTime=OrderCloseTime();
                          if(OrderProfit()<0)
                          {
                           tLots=NormalizeDouble(OrderLots()*LotExponent,LotsDigits);
                          }
                          else
                          {
                           tLots=Lots;
                          }
                       }
                    }
                 }
                 else
                 {
                  return(-3);
                 }
              }
            break;
        }
        if(AccountFreeMarginCheck(Symbol(),aTradeType,tLots)<=0)
        {
         return(-1);
        }
        if(GetLastError()==134)
        {
         return(-2);
        }
      return(tLots);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         int CountTrades()
           {
            int count=0;
            int trade;
            for(trade=OrdersTotal()-1;trade>=0;trade--)
              {
               sav=OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
               if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
                  continue;
               if(OrderSymbol()==Symbol()&&OrderMagicNumber()==MagicNumber)
                  if(OrderType()==OP_SELL || OrderType()==OP_BUY)
                     count++;
              }//for
            return(count);
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         void CloseThisSymbolAll()
           {
            int trade;
            for(trade=OrdersTotal()-1;trade>=0;trade--)
              {
               sav=OrderSelect(trade,SELECT_BY_POS,MODE_TRADES);
               if(OrderSymbol()!=Symbol())
                  continue;
               if(OrderSymbol()==Symbol() && OrderMagicNumber()== MagicNumber)
                 {
                  if(OrderType()==OP_BUY)
                     vee=OrderClose(OrderTicket(),OrderLots(),Bid,slip,White);
                  if(OrderType()==OP_SELL)
                      vee=OrderClose(OrderTicket(),OrderLots(),Ask,slip,Red);
                 }
               Sleep(1000);
              }
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         int OpenPendingOrder(int pType,double pLots,double pLevel,int sp, double pr, int sl, int tp,string pComment,int pMagic,datetime pExpiration,color pColor)
           {
            int ticket=0;
            int err=0;
            int c=0;
            int NumberOfTries=100;
            switch(pType)
              {
               case OP_BUYLIMIT:
                  for(c=0;c < NumberOfTries;c++)
                    {
                     ticket=OrderSend(Symbol(),OP_BUYLIMIT,pLots,pLevel,sp,StopLong(pr,sl),TakeLong(pLevel,tp),pComment,pMagic,pExpiration,pColor);
                     err=GetLastError();
                     if(err==0)
                       {
                        break;
                       }
                     else
                       {
                        if(err==4 || err==137 ||err==146 || err==136) //Busy errors
                          {
                           Sleep(1000);
                           continue;
                          }
                        else //normal error
                          {
                           break;
                          }
                       }
                    }
                  break;
               case OP_BUYSTOP:
                  for(c=0;c < NumberOfTries;c++)
                    {
                     ticket=OrderSend(Symbol(),OP_BUYSTOP,pLots,pLevel,sp,StopLong(pr,sl),TakeLong(pLevel,tp),pComment,pMagic,pExpiration,pColor);
                     err=GetLastError();
                     if(err==0)
                       {
                        break;
                       }
                     else
                       {
                        if(err==4 || err==137 ||err==146 || err==136) //Busy errors
                          {
                           Sleep(5000);
                           continue;
                          }
                        else //normal error
                          {
                           break;
                          }
                       }
                    }
                  break;
               case OP_BUY:
                  for(c=0;c < NumberOfTries;c++)
                    {
                     RefreshRates();
                     ticket=OrderSend(Symbol(),OP_BUY,pLots,Ask,sp,StopLong(Bid,sl),TakeLong(Ask,tp),pComment,pMagic,pExpiration,pColor);
                     err=GetLastError();
                     if(err==0)
                       {
                        break;
                       }
                     else
                       {
                        if(err==4 || err==137 ||err==146 || err==136) //Busy errors
                          {
                           Sleep(5000);
                           continue;
                          }
                        else //normal error
                          {
                           break;
                          }
                       }
                    }
                  break;
               case OP_SELLLIMIT:
                  for(c=0;c < NumberOfTries;c++)
                    {
                     ticket=OrderSend(Symbol(),OP_SELLLIMIT,pLots,pLevel,sp,StopShort(pr,sl),TakeShort(pLevel,tp),pComment,pMagic,pExpiration,pColor);
                     err=GetLastError();
                     if(err==0)
                       {
                        break;
                       }
                     else
                       {
                        if(err==4 || err==137 ||err==146 || err==136) //Busy errors
                          {
                           Sleep(5000);
                           continue;
                          }
                        else //normal error
                          {
                           break;
                          }
                       }
                    }
                  break;
               case OP_SELLSTOP:
                  for(c=0;c < NumberOfTries;c++)
                    {
                     ticket=OrderSend(Symbol(),OP_SELLSTOP,pLots,pLevel,sp,StopShort(pr,sl),TakeShort(pLevel,tp),pComment,pMagic,pExpiration,pColor);
                     err=GetLastError();
                     if(err==0)
                       {
                        break;
                       }
                     else
                       {
                        if(err==4 || err==137 ||err==146 || err==136) //Busy errors
                          {
                           Sleep(5000);
                           continue;
                          }
                        else //normal error
                          {
                           break;
                          }
                       }
                    }
                  break;
               case OP_SELL:
                  for(c=0;c < NumberOfTries;c++)
                    {
                     ticket=OrderSend(Symbol(),OP_SELL,pLots,Bid,sp,StopShort(Ask,sl),TakeShort(Bid,tp),pComment,pMagic,pExpiration,pColor);
                     err=GetLastError();
                     if(err==0)
                       {
                        break;
                       }
                     else
                       {
                        if(err==4 || err==137 ||err==146 || err==136) //Busy errors
                          {
                           Sleep(5000);
                           continue;
                          }
                        else //normal error
                          {
                           break;
                          }
                       }
                    }
                  break;
              }
 
            return(ticket);
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         double StopLong(double price,int stop)
           {
            if(stop==0)
               return(0);
            else
               return(price-(stop*Point));
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         double StopShort(double price,int stop)
           {
            if(stop==0)
               return(0);
            else
               return(price+(stop*Point));
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         double TakeLong(double price,int take)
           {
            if(take==0)
               return(0);
            else
               return(price+(take*Point));
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         double TakeShort(double price,int take)
           {
            if(take==0)
               return(0);
            else
               return(price-(take*Point));
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         double CalculateProfit()
           {
            double Profit=0;
            for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
              {
               sav=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
               if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
                  continue;
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
                  if(OrderType()==OP_BUY || OrderType()==OP_SELL)
                    {
                     Profit=Profit+OrderProfit();
                    }
              }
            return(Profit);
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         void TrailingAlls(int start,int stop, double AvgPrice)
           {
            int profit;
            double stoptrade;
            double stopcal;
            if(stop==0)
               return;
            int trade;
            for(trade=OrdersTotal()-1;trade>=0;trade--)
              {
               if(!OrderSelect(trade,SELECT_BY_POS,MODE_TRADES))
                  continue;
               if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
                  continue;
               if(OrderSymbol()==Symbol()||OrderMagicNumber()==MagicNumber)
                 {
                  if(OrderType()==OP_BUY)
                    {
                     profit=NormalizeDouble((Bid-AvgPrice)/Point,0);
                     if(profit<start)
                        continue;
                     stoptrade=OrderStopLoss();
                     stopcal=Bid-(stop*Point);
                     if(stoptrade==0||(stoptrade!=0&&stopcal>stoptrade))
                        //     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,White);
                        wbf=OrderModify(OrderTicket(),AvgPrice,stopcal,OrderTakeProfit(),0,White);
                    }//Long
                  if(OrderType()==OP_SELL)
                    {
                     profit=NormalizeDouble((AvgPrice-Ask)/Point,0);
                     if(profit<start)
                        continue;
                     stoptrade=OrderStopLoss();
                     stopcal=Ask+(stop*Point);
                     if(stoptrade==0||(stoptrade!=0&&stopcal<stoptrade))
                        //     OrderModify(OrderTicket(),OrderOpenPrice(),stopcal,OrderTakeProfit(),0,Red);
                        wbf=OrderModify(OrderTicket(),AvgPrice,stopcal,OrderTakeProfit(),0,Red);
                    }//Shrt
                 }
               Sleep(1000);
              }//for
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         double AccountEquityHigh()
           {
            static double AccountEquityHighAmt,PrevEquity;
            if(CountTrades()==0) AccountEquityHighAmt=AccountEquity();
            if(AccountEquityHighAmt < PrevEquity) AccountEquityHighAmt=PrevEquity;
            else AccountEquityHighAmt=AccountEquity();
            PrevEquity=AccountEquity();
            return(AccountEquityHighAmt);
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         double FindLastBuyPrice()
           {
            double oldorderopenprice=0, orderprice;
            int cnt, oldticketnumber=0, ticketnumber;
            for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
              {
               sav=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
               if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
                  continue;
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY)
                 {
                  ticketnumber=OrderTicket();
                  if(ticketnumber>oldticketnumber)
                    {
                     orderprice=OrderOpenPrice();
                     oldorderopenprice=orderprice;
                     oldticketnumber=ticketnumber;
                    }
                 }
              }
            return(orderprice);
           }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
         double FindLastSellPrice()
           {
            double oldorderopenprice=0, orderprice;
            int cnt, oldticketnumber=0, ticketnumber;
            for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
              {
               sav=OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
               if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=MagicNumber)
                  continue;
               if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL)
                 {
                  ticketnumber=OrderTicket();
                  if(ticketnumber>oldticketnumber)
                    {
                     orderprice=OrderOpenPrice();
                     oldorderopenprice=orderprice;
                     oldticketnumber=ticketnumber;
                    }
                 }
              }
            return(orderprice);
           }
//+------------------------------------------------------------------+