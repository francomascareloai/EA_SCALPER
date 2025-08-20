#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
#property description "Join Telegram Channel for daily Unlimited Source Codes @ex4tomq4decompilercom"
#property description "Find Fresh Decompiled Source Codes - https://www.ex4tomq4decompiler.com/free-mt4-robots"
//---
#property strict
      
extern string __c1="----------------------------------";
extern string __lotsize = "Money management";
extern bool   MM        = true;               
extern double Risk      = 2.0;                
extern double Lots      = 0.01;              
double LotDigits = 2;   

extern string __c2="----------------------------------";
extern double multiplier      = 1.5;
extern double profit          = 0;
extern double SingleOrderProfit = 3.0;
extern double globalprofit    = 0;
extern double pairglobalprofit= 1;
extern double maximaloss      = 0;
extern int    tradesperday    = 99;
extern bool   openonnewcandle = true;
bool   ReverseOrder    = false;

extern string __c3="----------------------------------";
extern double spacePips       = 14;
extern int    spaceOrders     = 5;
extern double spaceLots       = 0.01;

extern double space1Pips      = 50;
extern int    space1Orders    = 1;
extern double space1Lots      = 0.02;

extern double space2Pips      = 100;
extern int    space2Orders    = 1;
extern double space2Lots      = 0.03;

extern double space3Pips      = 200;
extern int    space3Orders    = 99;
extern double space3Lots      = 0.09;

extern string __c4="----------------------------------";
extern int     magicbuy        = 1;
extern string  buycomment      = "buy";
extern int     magicsell       = 2;
extern string  sellcomment     = "sell";
   

extern string __c5="----------------------------------";
extern string __timeFilter="Timer filter (Hour 0-24 Minute 0-59)";
extern int     Start_Hour      = 00;
extern int     Start_Minute    = 00;
extern int     Finish_Hour     = 23;
extern int     Finish_Minute   = 30;

extern string __c6="----------------------------------";
extern string __entry1="Determine entry based on SMA/parabolic";
extern bool    smaParabolicEntry = true;

extern string __entry2="Determine entry based on CCI";
extern int     cciperiod =     0;
extern double  ccimax    =   100;
extern double  ccimin    =  -100;


extern string __c7="----------------------------------";
extern bool    suspendtrades     = false;
extern bool    closeallsellsnow  = false;
extern bool    closeallbuysnow   = false;
extern bool    closeallnow       = false;

extern string __c8="----------------------------------";
extern bool    KeepTextOnTop     = true;//Disable the chart in foreground CrapTx setting so the candles do not obscure the text
extern int     DisplayX          = 50;
extern int     DisplayY          = 50;
extern int     fontSise          = 8;
extern string  fontName          = "Courier New";
extern color   colour            = Yellow;
 
double totalprofit; 
bool   sellallowed=false;
bool   buyallowed=false;
bool   firebuy=true;
bool   firesell=true;
string stoptrading="0"; 
bool   validSetup=true;
string error;
int    DisplayCount      = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

   if (Digits==3 || Digits==5)
   {
      spacePips  *= 10.0;
      space1Pips *= 10.0;
      space2Pips *= 10.0;
      space3Pips *= 10.0;
   }
   RemoveAllObjects();
   
   validSetup=false;
   double minLots = MarketInfo(Symbol(),MODE_MINLOT) ;
   double maxLots = MarketInfo(Symbol(),MODE_MAXLOT) ;
   if (MM == true)
   {
      if (LotDigits<1 || LotDigits>3)
      {
         error="Invalid LotDigits";
         return 0;
      }
      
      if (Risk < 0.01 || Risk >100)
      {
         error="Invalid Risk";
         return 0;
      }
   }   
   
   if (Lots < minLots || Lots > maxLots  )
   {
      error="invalid LotSize";
      return 0;
   }
   if (multiplier < 0)
   {
      error="invalid multiplier";
      return 0;
   }
   
   if (spacePips < 1  )
   {
      error="SpacePips invalid";
      return 0;
   }
   
   if (space1Pips < 1  )
   {
      error="SpacePips1 invalid";
      return 0;
   }
   
   if (space2Pips < 1  )
   {
      error="SpacePips2 invalid";
      return 0;
   }
   
   if (space3Pips < 1  )
   {
      error="SpacePips3 invalid";
      return 0;
   }
   
   if (spaceOrders < 1  )
   {
      error="spaceOrders invalid";
      return 0;
   }
   
   if (space1Orders < 1  )
   {
      error="space1Orders invalid";
      return 0;
   }
   
   if (space2Orders < 1  )
   {
      error="space2Orders invalid";
      return 0;
   }
   
   if (space3Orders < 1  )
   {
      error="space3Orders invalid";
      return 0;
   }
   
   if (multiplier==0)
   {
      if (space1Lots < minLots || space1Lots > maxLots)
      {
         error="space1Lots invalid";
         return 0;
      }
      if (space2Lots < minLots || space2Lots > maxLots)
      {
         error="space3Lots invalid";
         return 0;
      }
      if (space3Lots < minLots || space3Lots > maxLots)
      {
         error="space3Lots invalid";
         return 0;
      }
   }
   
   if (Start_Hour < 0 || Start_Hour > 24)
   {
         error="Start_Hour invalid";
         return 0;
   }
   
   if (Start_Minute < 0 || Start_Minute > 59)
   {
         error="Start_Minute invalid";
         return 0;
   }
   if (Finish_Hour < 0 || Finish_Hour > 24)
   {
         error="Finish_Hour invalid";
         return 0;
   }
   if (Finish_Minute < 0 || Finish_Minute > 59)
   {
         error="Finish_Minute invalid";
         return 0;
   }
   if (cciperiod<0)
   {
         error="cciperiod invalid";
         return 0;
   }
   if (cciperiod > 0)
   {
      if (ccimax < ccimin)
      {
         error="ccimax/ccimin invalid";
         return 0;
      }
      if (ccimax <-100 || ccimax > 100)
      {
         error="ccimax invalid";
         return 0;
      }
      if (ccimin <-100 || ccimin > 100)
      {
         error="ccimin invalid";
         return 0;
      }
   }
   
   validSetup=true;
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void RemoveAllObjects()
{
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      if (StringFind(ObjectName(i),"EA-",0) > -1)  ObjectDelete(ObjectName(i));
   }
}

//+------------------------------------------------------------------+
//| Display                               |
//+------------------------------------------------------------------+
void Display(string text)
{
  string lab_str = "EA-" + IntegerToString(DisplayCount);  
  double ofset = 0;  
  
  ObjectCreate("EA-BG",OBJ_RECTANGLE_LABEL,0,0,0);
  ObjectSet("EA-BG", OBJPROP_XDISTANCE, DisplayX-20);
  ObjectSet("EA-BG", OBJPROP_YDISTANCE, DisplayY-20);
  ObjectSet("EA-BG", OBJPROP_XSIZE,700);
  ObjectSet("EA-BG", OBJPROP_YSIZE,500);
  ObjectSet("EA-BG", OBJPROP_BGCOLOR,C'50,50,50');
  ObjectSet("EA-BG", OBJPROP_BORDER_TYPE,BORDER_SUNKEN);
  ObjectSet("EA-BG", OBJPROP_CORNER,CORNER_LEFT_UPPER);
  ObjectSet("EA-BG", OBJPROP_STYLE,STYLE_SOLID);
  ObjectSet("EA-BG", OBJPROP_COLOR,clrWhite);
  ObjectSet("EA-BG", OBJPROP_WIDTH,1);
  ObjectSet("EA-BG", OBJPROP_BACK,false);

  ObjectCreate(lab_str, OBJ_LABEL, 0, 0, 0);
  ObjectSet(lab_str, OBJPROP_CORNER, 0);
  ObjectSet(lab_str, OBJPROP_XDISTANCE, DisplayX + ofset);
  ObjectSet(lab_str, OBJPROP_YDISTANCE, DisplayY+DisplayCount*(fontSise+9));
  ObjectSet(lab_str, OBJPROP_BACK, false);
  ObjectSetText(lab_str, text, fontSise, fontName, colour);
    
}

//------------------------------------------------------------------+
//------------------------------------------------------------------+
void SM(string message)
{
   DisplayCount++;
   Display(message);
      
}//End void SM()


//------------------------------------------------------------------+
// Draw error screen
//------------------------------------------------------------------+
void DisplayErrors()
{
   DisplayCount=0;
   colour=Red;
   SM("Trading turned OFF");
   SM("");
   SM("Invalid settings:");
   SM(error);
}
//------------------------------------------------------------------+
// Draw info screen
//------------------------------------------------------------------+
void ShowStatus()
{
   if(IsOptimization()) return;
  // if(IsTesting()) return;
   
   DisplayCount=0;
   
 
   double lotsTrading=0;
   int openTrades=0;
   double profitLoss=0; 
   for (int k = OrdersTotal();k >=0 ;k--)
   {  
      if (OrderSelect(k, SELECT_BY_POS))
      {
          if ( OrderSymbol() == Symbol() )
          {
               if (OrderMagicNumber() == magicbuy || OrderMagicNumber() == magicsell) 
               {
                  lotsTrading+=OrderLots();
                  openTrades=openTrades+1;
                  profitLoss += (OrderProfit() + OrderSwap() + OrderCommission());
               }
          }
      }
   }
   
   
   int wonTrades=0;
   int lostTrades=0;
   double profitToday=0;
   double profitYesterday=0;   
   double profitTotal=0;  
   double totalLotsTraded=0;
   double maxLotsizeUsed=0;
   double profitFactor=-1;
   double totalAmountWon=0;
   double totalAmountLost=0;
   datetime today     = TimeCurrent() ;
   datetime yesterday = TimeCurrent() - (60 * 60 * 24);
   for (int l=OrdersHistoryTotal();l >= 0;l--)
   {
      if(OrderSelect(l, SELECT_BY_POS,MODE_HISTORY))
      {
        if ( OrderSymbol() == Symbol() )
        {
           if ( OrderMagicNumber() == magicbuy || OrderMagicNumber() == magicsell )
           {
               totalLotsTraded += OrderLots();
               maxLotsizeUsed   = MathMax(maxLotsizeUsed, OrderLots());
               if (OrderProfit() > 0) wonTrades++;
               else lostTrades++;
               
               double orderProfit = (OrderProfit() + OrderSwap() + OrderCommission());
               if (orderProfit<0) totalAmountLost += orderProfit;
               else totalAmountWon += orderProfit;
               
               profitTotal += orderProfit;
               
               if( TimeDay   (OrderCloseTime()) == TimeDay(today) &&
                   TimeMonth (OrderCloseTime()) == TimeMonth(today) &&
                   TimeYear  (OrderCloseTime()) == TimeYear(today) )
               {
                  profitToday += orderProfit;
               }
               
               if( TimeDay  (OrderCloseTime()) == TimeDay(yesterday) &&
                   TimeMonth(OrderCloseTime()) == TimeMonth(yesterday) &&
                   TimeYear (OrderCloseTime()) == TimeYear(yesterday) )
               {
                  profitYesterday += orderProfit;
               }
            }
        }
      }
   }
   if (totalAmountWon!=0 && totalAmountLost!=0)
   {
      profitFactor=MathAbs(totalAmountWon / totalAmountLost);
   }
   
   double totalTradeCount=(wonTrades+lostTrades);
   
   SM("Account balance         : " + DoubleToString(AccountBalance(),2) +" " + AccountCurrency());
   SM("Account equity          : " + DoubleToString(AccountEquity(),2) +" " + AccountCurrency());
   SM("Account free margin     : " + DoubleToString(AccountFreeMargin(),2) +" " + AccountCurrency());
   SM("Account margin          : " + DoubleToString(AccountMargin(),2) +" " + AccountCurrency());
   
   SM("");
   SM("Open trades             : " + (GetBuyOrderCount()+GetSellOrderCount()) + " ( "+DoubleToString(profitLoss,2)+" "+AccountCurrency()+" )" );
   SM("         buy trades     : " + GetBuyOrderCount());
   SM("         sell trades    : " + GetSellOrderCount() );
   SM("         lots in trades : " + DoubleToString(lotsTrading, 2) + " lots");
   
   SM("");
   SM("Total trades today      : " + TradesToday()+" / "+tradesperday);
   SM("Total trades all time   : " + (wonTrades+lostTrades) + ", Won:"+wonTrades+" / Lost:"+lostTrades);
   double percentage=0;
   if (totalTradeCount >0) percentage=(wonTrades / totalTradeCount) * 100;
   SM("                winrate : " + DoubleToString( percentage, 2)+"%");
   SM("");
   SM("Profit today            : " + DoubleToString(profitToday, 2)+ " " + AccountCurrency() );
   SM("Profit yesterday        : " + DoubleToString(profitYesterday,2 )+ " " + AccountCurrency() );
   SM("Profit all time         : " + DoubleToString(profitTotal, 2)+ " " + AccountCurrency() );
   
   double payoff=0;
   if (totalTradeCount>0 ) payoff=profitTotal/totalTradeCount;
   SM("Payoff expectancy/trade : " + DoubleToString(payoff, 2)+ " " + AccountCurrency() );
   if (profitFactor>=0)
      SM("Profit factor           : " + DoubleToString(profitFactor, 2));
   else SM("");
   SM("");
   
   double averageLots=0;
   if (totalTradeCount >0) averageLots = totalLotsTraded / totalTradeCount;
   SM("Overall volume traded   : " + DoubleToString(totalLotsTraded, 2) +" lots");
   SM("Average volume/trade    : " + DoubleToString(averageLots, 2) +" lots");
   SM("Max volume traded       : " + DoubleToString(maxLotsizeUsed, 2) +" lots");
}



//------------------------------------------------------------------+
// Generic Money management code
//------------------------------------------------------------------+
double GetLotSize()
{
   double minlot    = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlot    = MarketInfo(Symbol(), MODE_MAXLOT);
   double leverage  = AccountLeverage();
   double lotsize   = MarketInfo(Symbol(), MODE_LOTSIZE);
   double stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   double MinLots = 0.01; 
   double MaximalLots = 50.0;
   double lots = Lots;

   if(MM)
   {
      lots = NormalizeDouble(AccountFreeMargin() * Risk/100 / 1000.0, LotDigits);
      if(lots < minlot) lots = minlot;
      if (lots > MaximalLots) lots = MaximalLots;
      if (AccountFreeMargin() < Ask * lots * lotsize / leverage) 
      {
         Print("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
         Comment("We have no money. Lots = ", lots, " , Free Margin = ", AccountFreeMargin());
      }
   }
   else lots=NormalizeDouble(Lots, Digits);
   return(lots);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if (!validSetup) 
   {
      DisplayErrors();
      return;
   }
   
   int  ticketBuyOrder       =  GetTicketOfLargestBuyOrder();
   int  ticketSellOrder      =  GetTicketOfLargestSellOrder();
   bool isNewBar             =  IsNewBar();
   int  totalTradesDoneToday =  TradesToday();
   int  index;
   
   ShowStatus();
   
   if (GlobalVariableGet(stoptrading) == 1 && OrdersTotal() == 0 && CheckTradingTime() == true)
   {
      GlobalVariableSet(stoptrading,0);  
   }
   
   if (!smaParabolicEntry)
   {
      if (cciperiod == 0)
      {
         firesell = true;
         firebuy  = true;  
      } 
   }
   
   // determine entry based on SMA/parabolic
   if (smaParabolicEntry)
   {
      if (isNewBar==true)
      {
         firebuy  = false;
         firesell = false; 
         double ima  = iMA(NULL, 0, 7, 0, MODE_LWMA, PRICE_WEIGHTED, 0);
         double isar = iSAR(NULL, 0, 0.1, 0.8, 0); 
         
         if (ReverseOrder)
         {
            if(isar < ima)
            {
               firesell = false;
               firebuy = true;
            }
            
            if( isar > ima) 
            {
               firesell = true;
               firebuy = false;
            }             
         } else 
         {
            if(isar < ima)
            {
               firesell = true;
               firebuy = false;
            }
            
            if( isar > ima) 
            {
               firesell = false;
               firebuy = true;
            }         
         }
      }
   }
   
   // determine entry based on CCI
   if (cciperiod > 0 && isNewBar == true)
   {
      firebuy  = false;
      firesell = false;
      double cci = iCCI(Symbol(), 0, cciperiod, PRICE_TYPICAL, 0);
      
      if(sellallowed && cci < ccimin) 
      {
         firesell = true;
         sellallowed = false; 

      }
      if(buyallowed  && cci > ccimax) 
      {
         firebuy = true;
         buyallowed = false; 
      }
      
      if (cci < ccimax && cci > ccimin)
      {
         buyallowed  = true;
         sellallowed = true;
      }
   }
   
   if (tradesperday > totalTradesDoneToday && CheckTradingTime() && ticketBuyOrder==0 && suspendtrades==false && firebuy && closeallnow==false && GlobalVariableGet(stoptrading)==0)
   {
     index = OrderSend (Symbol(),OP_BUY, GetLotSize() , Ask , 3, 0, 0, buycomment, magicbuy, 0, Blue); 
     if (index >= 0)
     {
         firebuy = false; 
     }
   }         

   if ((openonnewcandle == 1 && isNewBar == true && ticketBuyOrder != 0)|| (openonnewcandle == 0 && ticketBuyOrder != 0))
   {
      if ( OrderSelect(ticketBuyOrder, SELECT_BY_TICKET))
      {
         double orderLots  = OrderLots();
         double orderPrice = OrderOpenPrice(); 
         if( Ask <= orderPrice - spacePips * Point() && GetBuyOrderCount() < spaceOrders)
         {
            if (multiplier  > 0) 
            {
               index = OrderSend (Symbol(), OP_BUY, NormalizeDouble(orderLots * multiplier, 2), Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue); 
            }
            else if (multiplier == 0) 
            {
              index = OrderSend (Symbol(), OP_BUY, spaceLots, Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue);
            }
         }  
         
         else if( Ask <= orderPrice - space1Pips * Point() && GetBuyOrderCount() <= (spaceOrders + space1Orders-1) && GetBuyOrderCount() >= spaceOrders)
         {
           if (multiplier  > 0) 
            {
               index = OrderSend (Symbol(), OP_BUY, NormalizeDouble(orderLots * multiplier, 2), Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend (Symbol(), OP_BUY, space1Lots, Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue);
            }
         }  
         
         else if( Ask <= orderPrice - space2Pips * Point()&& GetBuyOrderCount() <= (space2Orders + space1Orders + spaceOrders-1) && GetBuyOrderCount() > (spaceOrders + space1Orders-1))
         {
           if (multiplier  > 0) 
            {
               index = OrderSend (Symbol(), OP_BUY, NormalizeDouble(orderLots * multiplier, 2), Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend (Symbol(), OP_BUY,space2Lots, Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue);
             }
         }  
         
         else if( Ask <= orderPrice - space3Pips * Point() && GetBuyOrderCount() <= (space3Orders + space2Orders + space1Orders + spaceOrders) && GetBuyOrderCount() > (spaceOrders + space1Orders + space2Orders-1))
         {
           if (multiplier  > 0) 
            {
               index = OrderSend (Symbol(), OP_BUY, NormalizeDouble(orderLots * multiplier, 2), Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend (Symbol(), OP_BUY, space3Lots, Ask, 3, 0, 0, buycomment, magicbuy, 0, Blue);
            }
         }  
      }
   }
    
   // --------------------------------------------
   // sell orders
   // --------------------------------------------
   totalTradesDoneToday = TradesToday();
   if (tradesperday > totalTradesDoneToday && CheckTradingTime() == true && ticketSellOrder == 0 && suspendtrades == false && firesell == true && closeallnow == false && GlobalVariableGet(stoptrading) == 0)
   {
     index = OrderSend (Symbol(), OP_SELL, GetLotSize(), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);  
     if (index >= 0)
     {
         firesell = false;
     }
   }

   // manage sell order
   if ((openonnewcandle == 1 && isNewBar==true && ticketSellOrder !=0 )|| (openonnewcandle == 0 && ticketSellOrder != 0))
   {
      if ( OrderSelect(ticketSellOrder, SELECT_BY_TICKET))
      {
         double orderLots  = OrderLots();
         double orderPrice = OrderOpenPrice(); 
         if( Bid >= orderPrice + spacePips * Point() && GetSellOrderCount() < spaceOrders)
         {
           if (multiplier  > 0) 
            {
               index = OrderSend(Symbol(), OP_SELL, NormalizeDouble(orderLots * multiplier, 2), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red); 
            }
            else if (multiplier == 0)
            {
                index = OrderSend(Symbol(), OP_SELL, spaceLots, Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);
            }
         } 
         else if( Bid >= orderPrice + space1Pips * Point() && GetSellOrderCount() <= (spaceOrders + space1Orders - 1) && GetSellOrderCount() >= spaceOrders)      
         { 
            if (multiplier > 0) 
            {
               index = OrderSend(Symbol(), OP_SELL, NormalizeDouble(orderLots * multiplier, 2), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend(Symbol(), OP_SELL, space1Lots ,Bid, 3, 0, 0, sellcomment, magicsell ,0, Red);
            }
         } 
         else if( Bid >= orderPrice + space2Pips * Point() && GetSellOrderCount() <= (space2Orders + space1Orders + spaceOrders - 1) && GetSellOrderCount() > (spaceOrders + space1Orders-1))     
         {
           if (multiplier > 0) 
            {
               index = OrderSend(Symbol(),OP_SELL, NormalizeDouble(orderLots * multiplier, 2), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);  
            }
            else if (multiplier == 0) 
            {
               index = OrderSend(Symbol(),OP_SELL, space2Lots, Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);
            }
         } 
         else if( Bid >= orderPrice + space3Pips * Point() && GetSellOrderCount() <= (space3Orders + space2Orders + space1Orders + spaceOrders) && GetSellOrderCount() > (spaceOrders + space1Orders + space2Orders-1))     
         {
           if (multiplier  > 0) 
            {
               index = OrderSend(Symbol(),OP_SELL, NormalizeDouble(orderLots * multiplier, 2), Bid, 3, 0, 0, sellcomment, magicsell, 0, Red); 
            }
            else if (multiplier == 0) 
            {
               index = OrderSend(Symbol(),OP_SELL, space3Lots, Bid, 3, 0, 0, sellcomment, magicsell, 0, Red);
            }
         } 
      }
   } 
   
   double profitBuyOrders=0;
   for(int k=OrdersTotal()-1; k >=0; k--)
   {
      if ( OrderSelect(k,SELECT_BY_POS))
      {
         if (Symbol()==OrderSymbol() && OrderType()==OP_BUY && OrderMagicNumber() == magicbuy)
         {
            profitBuyOrders = profitBuyOrders + OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
   }

   if ((profit > 0 && profitBuyOrders >= profit) || closeallbuysnow == true)
   {
      CloseAllBuyOrders();
      firebuy = false;
   }  
   
   
   double profitSellOrders=0;
   for(int j=OrdersTotal()-1; j>=0; j--)
   {
      if (OrderSelect(j,SELECT_BY_POS))
      { 
         if (Symbol() == OrderSymbol() && OrderType()==OP_SELL && OrderMagicNumber() == magicsell)
         {
            profitSellOrders = profitSellOrders + OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
   }
   
   if ((profit > 0 && profitSellOrders >= profit) || closeallsellsnow == true)
   {
      CloseAllSellOrders();
      firesell = false;

   }  
   
   
   if (GetTotalOrderCount() == 1 ) {
         if (GetBuyOrderCount() == 1 && profitBuyOrders >= SingleOrderProfit)
         {
            CloseAllBuyOrders();
            firebuy = false;   
         } else
         if (GetSellOrderCount() == 1 && profitSellOrders >= SingleOrderProfit)
         {
            CloseAllSellOrders();
            firesell = false;   
         } 
   } else 
   if (pairglobalprofit> 0  && profitBuyOrders + profitSellOrders >= pairglobalprofit && GetTotalOrderCount() > 1 )
   {
      CloseAllSellOrders();
      CloseAllBuyOrders();
      firebuy=false;
      firesell=false;    
   }

   double totalglobalprofit = TotalProfit();
   if((globalprofit > 0 && totalglobalprofit >= globalprofit) || (maximaloss < 0 && totalglobalprofit <= maximaloss))
   {
      GlobalVariableSet(stoptrading, 1);
      CloseAllOrders();
      firebuy  = false;
      firesell = false;
   }
}
  
//+------------------------------------------------------------------+
int GetTotalOrderCount()
{
   int count=0;

   // find all open orders of today
   for (int k = OrdersTotal();k >=0 ;k--)
   {  
      if (OrderSelect(k, SELECT_BY_POS))
      {
         if (OrderSymbol() == Symbol()) 
         {
             count=count+1;
         }
      }
   }
   return count;
}    
//+------------------------------------------------------------------+
int GetBuyOrderCount()
{
   int count=0;

   // find all open orders of today
   for (int k = OrdersTotal();k >=0 ;k--)
   {  
      if (OrderSelect(k, SELECT_BY_POS))
      {
         if (OrderType()==OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magicbuy) 
         {
             count=count+1;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
int GetSellOrderCount()
{
   int count=0;

   // find all open orders of today
   for (int k = OrdersTotal(); k >=0 ;k--)
   {  
      if (OrderSelect(k, SELECT_BY_POS))
      {
         if (OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magicsell) 
         {
            count=count+1;
         }
      }
   }
   return count;
}
  
//+------------------------------------------------------------------+
// GetTicketOfLargestBuyOrder()
// returns the ticket of the largest open buy order 
//+------------------------------------------------------------------+

int GetTicketOfLargestBuyOrder()
{
   double maxLots=0;
   int    orderTicketNr=0;

   for (int i=0;i < OrdersTotal();i++)
   {
      if ( OrderSelect(i,SELECT_BY_POS)) 
      {
         if( OrderType()==OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber()==magicbuy)
         {
            
            double orderLots = OrderLots();  
            if (orderLots >= maxLots) 
            {
               maxLots       = orderLots; 
               orderTicketNr = OrderTicket();
            }   
         } 
      } 
   }
   return orderTicketNr;
}


//+------------------------------------------------------------------+
// GetTicketOfLargestSellOrder()
// returns the ticket of the largest open sell order 
//+------------------------------------------------------------------+
int GetTicketOfLargestSellOrder()
{
   double maxLots=0;
   int orderTicketNr=0;

   for (int l=0;l<=OrdersTotal();l++)
   {
      if ( OrderSelect(l,SELECT_BY_POS) )
      {
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magicsell)
         {
            double orderLots = OrderLots();  
            if (orderLots >= maxLots) 
            {
               maxLots = orderLots; 
               orderTicketNr = OrderTicket();
            }   
         }
      }  
   }
   return orderTicketNr;
}


//+------------------------------------------------------------------+
// CloseAllBuyOrders()
// closes all open buy orders
//+------------------------------------------------------------------+
void CloseAllBuyOrders()
{
   for (int m=OrdersTotal(); m>=0; m--)
   {
      if ( OrderSelect(m, SELECT_BY_POS))
      {
         if(OrderType() == OP_BUY && OrderSymbol() == Symbol() && OrderMagicNumber() == magicbuy)
         {
            RefreshRates();
            bool success = OrderClose(OrderTicket(), OrderLots(), Bid, 0, Blue);
         }
      }
    }
}


//+------------------------------------------------------------------+
// CloseAllSellOrders()
// closes all open sell orders
//+------------------------------------------------------------------+
void CloseAllSellOrders()
{
   for (int h=OrdersTotal();h>=0;h--)
   {
      if ( OrderSelect(h,SELECT_BY_POS) )
      {
         if(OrderType() == OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magicsell)
         {
            RefreshRates();
            bool success =OrderClose(OrderTicket(), OrderLots(), Ask, 0, Red);
         }
      }
   }
}


//+------------------------------------------------------------------+
// CloseAllOrders()
// closes all orders
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   CloseAllBuyOrders();
   CloseAllSellOrders();
}


//+------------------------------------------------------------------+
// TotalProfit()
// returns the total profit for all open orders
//+------------------------------------------------------------------+
double TotalProfit()
{
   double totalProfit = 0;
   for (int j=OrdersTotal();j >= 0; j--)
   {
      if( OrderSelect(j,SELECT_BY_POS))
      {
         if(OrderSymbol() == Symbol() )
         {
            if (OrderMagicNumber() == magicsell || OrderMagicNumber() == magicbuy)
            {
               RefreshRates();
         
               totalProfit = totalProfit + OrderProfit() + OrderSwap() + OrderCommission();
            }
         }
      }      
   }
   return totalProfit;
}


//+------------------------------------------------------------------+
// IsNewBar()
// returns if new bar has started
//+------------------------------------------------------------------+
bool IsNewBar()
{
   static datetime time = Time[0];
   if(Time[0] > time)
   {
      time = Time[0]; //newbar, update time
      return (true);
   } 
   return(false);
}

//+------------------------------------------------------------------+
// CheckTradingTime()
// returns true if we are allowed to trade
//+------------------------------------------------------------------+
bool CheckTradingTime()
{
   int min  = TimeMinute( TimeCurrent() );
   int hour = TimeHour( TimeCurrent() );
   
   // check if we can trade from 00:00 - 24:00
   if (Start_Hour == 0 && Finish_Hour == 24)
   {
      if (Start_Minute==0 && Finish_Minute==0)
      {
         // yes then return true
         return true; 
      } 
   } 
   
   if (Start_Hour > Finish_Hour) 
   {
      return(true);
   } 
    
   // suppose we're allowed to trade from 14:15 - 19:30
   
   // 1) check if hour is < 14 or hour > 19
   if ( hour < Start_Hour || hour > Finish_Hour ) 
   {   
      // if so then we are not allowed to trade
      return false;
   }
   
   // if hour is 14, then check if minute < 15
   if ( hour == Start_Hour && min < Start_Minute )
   {
      // if so then we are not allowed to trade
      return false;
   } 
   
   // if hour is 19, then check  minute > 30
   if ( hour == Finish_Hour && min > Finish_Minute )
   {
      // if so then we are not allowed to trade
      return false;
   }
   return true;
 }
   
   
//--------------------------------------------------------------------------------
// TradesToday()
// return total number of trades done today (closed and still open)
//--------------------------------------------------------------------------------
int TradesToday()
{
   int count=0;

   // find all open orders of today
   for (int k = OrdersTotal();k >=0 ;k--)
   {  
      if (OrderSelect(k,SELECT_BY_POS))
      {
         if (OrderSymbol() == Symbol() )
         {
             if(OrderLots() == Lots)
             {
                  if (OrderMagicNumber() == magicbuy || OrderMagicNumber() == magicsell) 
                  {
                     if( TimeDay(OrderOpenTime()) == TimeDay(TimeCurrent()))
                     { 
                        count=count+1;
                     }
                  }
             }
         }
      }
   }
   
   // find all closed orders of today
   for (int l=OrdersHistoryTotal();l >= 0;l--)
   {
      if(OrderSelect(l, SELECT_BY_POS,MODE_HISTORY))
      {
         if (OrderSymbol() == Symbol() )
         {
             if(OrderLots() == Lots)
             {
               if (OrderMagicNumber() != magicbuy && OrderMagicNumber() !=magicsell) 
               {
                  if(OrdersHistoryTotal() != 0 && TimeDay(OrderOpenTime()) == TimeDay(TimeCurrent()))
                  {
                     count = count + 1;
                  }
               }
             }
         }
      }
   }
   return(count);
}