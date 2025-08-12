//+------------------------------------------------------------------+
//|                                               Divergence Trader  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Ron Thompson"
#property link      "http://www.lightpatch.com/forex"
// user input
extern double Lots = 0.1;               // how many lots to trade at a time 
extern int    Slippage = 2;             // how many pips of slippage can you tolorate
extern int    Fast_Period = 7;
extern int    Fast_Price = PRICE_OPEN;
extern int    Slow_Period = 88;
extern int    Slow_Price = PRICE_OPEN;
extern double DVBuySell = 0.0011;
extern double DVStayOut = 0.0079;
extern double ProfitMade = 0;           // how much money do you expect to make
extern double LossLimit = 0;            // how much loss can you tolorate
extern double TrailStop = 9999;         // trailing stop (999=no trailing stop)
extern int    PLBreakEven = 9999;       // set break even when this many pips are made (999=off)
extern int    StartHour = 0;            // your local time to start making trades
extern int    StopHour = 24;            // your local time to stop making trades
extern int    BasketProfit = 75;        // if equity reaches this level, close trades
extern int    BasketLoss = 9999;        // if equity reaches this negative level, close trades
extern bool   FileData = false;
// naming and numbering
int      MagicNumber  = 200601182020; // allows multiple experts to trade on same account
string   TradeComment = "Divergence_00_";
// Bar handling
datetime bartime = 0;                   // used to determine when a bar has moved
int      bartick = 0;                   // number of times bars have moved
int      objtick = 0;                   // used to draw objects on the chart
int      tickcount = 0;
// Trade control
bool TradeAllowed = true;               // used to manage trades
// Min/Max tracking
double maxOrders;
double maxEquity;
double minEquity;
double CECount;
double CEProc;
double CEBuy;
double CESell;
//+-------------+
//| Custom init |
//|-------------+
// Called ONCE when EA is added to chart or recompiled
int init()
  {
   int    i;
   string o;
   //remove the old objects 
   for(i = 0; i < Bars; i++) 
     {
       o=DoubleToStr(i,0);
       ObjectDelete("myx"+o);
       ObjectDelete("myz"+o);
     }
   objtick = 0;
//----
   ObjectDelete("Cmmt");
   ObjectCreate("Cmmt", OBJ_TEXT, 0, Time[20], High[20] + (5*Point));
   ObjectSetText("Cmmt", "Divergence=0.0020", 10, "Arial", White);
//----
   Print("Init happened ", CurTime());
   Comment(" ");
  }
//+----------------+
//| Custom DE-init |
//+----------------+
// Called ONCE when EA is removed from chart
int deinit()
  {
   int    i;
   string o;
   //remove the old objects 
   for(i = 0; i < Bars; i++) 
     {
       o=DoubleToStr(i,0);
       ObjectDelete("myx"+o);
       ObjectDelete("myz"+o);
     }
   objtick = 0;
//----
   Print("MAX number of orders ", maxOrders);
   Print("MAX equity           ", maxEquity);
   Print("MIN equity           ", minEquity);
   Print("Close Everything     ", CECount);
   Print("Close Proc           ", CEProc);
   Print("Proc Buy             ", CEBuy);
   Print("Proc Sell            ", CESell);
//----
   Print("DE-Init happened ",CurTime());
   Comment(" ");
  }
//+-----------+
//| Main      |
//+-----------+
// Called EACH TICK
int start()
  {
   double p = Point;
   double spread = Ask-Bid;  
//----
   int cnt = 0;
   int gle = 0;
   int OrdersPerSymbol = 0;
   int OrdersBUY = 0;
   int OrdersSELL = 0;
//----
   int iFileHandle;
   // stoploss and takeprofit and close control
   double SL = 0;
   double TP = 0;
   double CurrentProfit = 0;
   double CurrentBasket = 0;
   // direction control
   bool BUYme = false;
   bool SELLme = false;
   // Trade stuff
   double diverge;
   // bar counting
   if(bartime != Time[0]) 
     {
       bartime = Time[0];
       bartick++; 
       objtick++;
       TradeAllowed = true;
     }
//----
   OrdersPerSymbol = 0;
   for(cnt = OrdersTotal(); cnt >= 0; cnt--)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
           OrdersPerSymbol++;
           if(OrderType() == OP_BUY) 
             {
               OrdersBUY++;
             }
           if(OrderType() == OP_SELL)
             {
               OrdersSELL++;
             }
         }
     }
   if(OrdersPerSymbol > maxOrders) 
       maxOrders = OrdersPerSymbol;
//+-----------------------------+
//| Insert your indicator here  |
//| And set either BUYme or     |
//| SELLme true to place orders |
//+-----------------------------+
   diverge = divergence(Fast_Period, Slow_Period, Fast_Price, Slow_Price, 0);
   ObjectDelete("Cmmt");
   ObjectCreate("Cmmt", OBJ_TEXT, 0, Time[0], High[0] + (10*p));
   ObjectSetText("Cmmt","Divergence=" + DoubleToStr(diverge, 4), 10, "Arial", White);
   if(diverge >= DVBuySell && diverge <= DVStayOut)
       BUYme = true;
   if(diverge <= (DVBuySell*(-1)) && diverge >= (DVStayOut*(-1))) 
       SELLme = true;
   //if( diverge>=DVBuySell        ) BUYme=true;
   //if( diverge<=(DVBuySell*(-1)) ) SELLme=true;
//----
   if(FileData)
     {
       tickcount++;
       iFileHandle = FileOpen("iDivergence", FILE_CSV|FILE_READ|FILE_WRITE, ",");
       FileSeek(iFileHandle, 0, SEEK_END);
       FileWrite(iFileHandle, bartick, " ", tickcount, " ", diverge);
       FileFlush(iFileHandle);
       FileClose(iFileHandle);
     }
//+------------+
//| End Insert |
//+------------+
//ENTRY LONG (buy, Ask) 
   if(TradeAllowed && BUYme)
     {
       //Ask(buy, long)
       if(LossLimit == 0) 
           SL = 0; 
       else 
           SL = Ask - ((LossLimit + 7)*Point);
       if(ProfitMade == 0) 
           TP = 0; 
       else 
           TP = Ask + ((ProfitMade + 7)*Point);
       OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, SL, TP, TradeComment, MagicNumber, White);
       gle = GetLastError();
       if(gle == 0)
         {
           Print("BUY  Ask=", Ask, " bartick=", bartick);
           ObjectCreate("myx" + DoubleToStr(objtick, 0), OBJ_TEXT, 0, Time[0], High[0] + (5*p));
           ObjectSetText("myx" + DoubleToStr(objtick, 0), "B", 15, "Arial", Red);
           bartick = 0;
           TradeAllowed = false;
         }
       else 
         {
           Print("-----ERROR----- BUY  Ask=", Ask, " error=", gle, " bartick=", bartick);
         }
     }
//ENTRY SHORT (sell, Bid)
   if(TradeAllowed && SELLme )
     {
       //Bid (sell, short)
       if(LossLimit == 0) 
           SL = 0; 
       else 
           SL = Bid + ((LossLimit + 7)*Point);
       if(ProfitMade == 0) 
           TP = 0; 
       else 
           TP = Bid - ((ProfitMade + 7)*Point);
       OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, SL, TP, TradeComment, MagicNumber, Red);
       gle = GetLastError();
       if(gle == 0)
         {
           Print("SELL Bid=", Bid, " bartick=", bartick); 
           ObjectCreate("myx" + DoubleToStr(objtick, 0), OBJ_TEXT, 0, Time[0], High[0] + (5*p));
           ObjectSetText("myx" + DoubleToStr(objtick, 0), "S", 15, "Arial", Red);
           bartick = 0;
           TradeAllowed = false;
         }
       else 
         {
           Print("-----ERROR----- SELL Bid=", Bid, " error=", gle, " bartick=", bartick);
         }
     }
//Basket profit or loss
   CurrentBasket = AccountEquity() - AccountBalance();
//----
   if(CurrentBasket > maxEquity) 
       maxEquity = CurrentBasket;
   if(CurrentBasket < minEquity) 
       minEquity = CurrentBasket;
   // actual basket closure
   if(CurrentBasket >= BasketProfit || CurrentBasket <= (BasketLoss*(-1)))
     {
       CloseEverything();
       CECount++;
     }
   // CLOSE order if profit target made
   for(cnt = 0; cnt < OrdersTotal(); cnt++)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
           if(OrderType() == OP_BUY)
             {
               CurrentProfit = Bid - OrderOpenPrice();
               // modify for break even
               if(CurrentProfit >= PLBreakEven*p && OrderOpenPrice() > OrderStopLoss())
                 {
                   SL = OrderOpenPrice() + (spread*2);
                   TP = OrderTakeProfit();
                   OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, White);
                   gle = GetLastError();
                   if(gle == 0)
                     {
                       Print("MODIFY BREAKEVEN BUY  Bid=", Bid, " bartick=", bartick); 
                       ObjectCreate("myz" + DoubleToStr(objtick, 0), OBJ_TEXT, 0, Time[0], 
                                    Low[0] - (7*p));
                       ObjectSetText("myz" + DoubleToStr(objtick, 0), "BE", 15, "Arial",
                                     White);
                     }
                      else 
                     {
                      Print("-----ERROR----- MODIFY BREAKEVEN BUY  Bid=", Bid, " error=", 
                            gle, " bartick=", bartick);
                     }
                 }

               // modify for trailing stop
               if(CurrentProfit >= TrailStop*p )
                 {
                   SL = Bid - (TrailStop*p);
                   TP = OrderTakeProfit();
                   OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, White);
                   gle = GetLastError();
                   if(gle == 0)
                     {
                       Print ("MODIFY TRAILSTOP BUY  StopLoss=", SL, "  bartick=", 
                              bartick, "OrderTicket=", OrderTicket(), " CurrProfit=",
                              CurrentProfit); 
                       ObjectCreate("myz" + DoubleToStr(objtick, 0), OBJ_TEXT, 0, Time[0],
                                    Low[0] - (7*p));
                       ObjectSetText("myz" + DoubleToStr(objtick, 0), "TS", 15, "Arial", White);
                     }
                   else 
                     {
                       Print("-----ERROR----- MODIFY TRAILSTOP BUY  Bid=",Bid," error=",gle," bartick=",bartick);
                     }
                 }

               // did we make our desired BUY profit
               // or did we hit the BUY LossLimit
               if((ProfitMade > 0 && CurrentProfit >= (ProfitMade*p)) || (LossLimit > 0 && 
                  CurrentProfit <= ((LossLimit*(-1))*p)))
                 {
                   OrderClose(OrderTicket(), Lots, Bid, Slippage, White);
                   gle = GetLastError();
                   if(gle == 0)
                     {
                       Print("CLOSE BUY  Bid=", Bid, " bartick=", bartick); 
                       ObjectCreate("myz" + DoubleToStr(objtick, 0), OBJ_TEXT, 0, Time[0],
                                    Low[0] - (7*p));
                       ObjectSetText("myz" + DoubleToStr(objtick, 0), "C", 15, "Arial", White);
                     }
                   else 
                     {
                       Print("-----ERROR----- CLOSE BUY  Bid=", Bid, " error=", gle, 
                             " bartick=", bartick);
                     }
                 }
              
             } // if BUY
           if(OrderType()==OP_SELL)
             {
               CurrentProfit = OrderOpenPrice() - Ask;
               // modify for break even
               if(CurrentProfit >= PLBreakEven*p && OrderOpenPrice() < OrderStopLoss())
                 {
                   SL = OrderOpenPrice() - (spread*2);
                   TP = OrderTakeProfit();
                   OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, Red);
                   gle = GetLastError();
                   if(gle == 0)
                     {
                       Print("MODIFY BREAKEVEN SELL Ask=", Ask, " bartick=", bartick);
                       ObjectCreate("myz" + DoubleToStr(objtick, 0), OBJ_TEXT, 0, Time[0], 
                                    Low[0] - (7*p));
                       ObjectSetText("myz" + DoubleToStr(objtick, 0), "BE", 15, "Arial", Red);
                     }
                   else 
                     {
                       Print("-----ERROR----- MODIFY BREAKEVEN SELL Ask=", Ask, " error=", 
                             gle, " bartick=", bartick);
                     }
                 }
               // modify for trailing stop
               if(CurrentProfit >= TrailStop*p)
                 {
                   SL = Ask + (TrailStop*p);
                   TP = OrderTakeProfit();
                   OrderModify(OrderTicket(), OrderOpenPrice(), SL, TP, Red);
                   gle = GetLastError();
                   if(gle == 0)
                     {
                       Print ("MODIFY TRAILSTOP SELL StopLoss=",SL,"  bartick=",bartick,"OrderTicket=",OrderTicket()," CurrProfit=",CurrentProfit); 
                        ObjectCreate("myz"+DoubleToStr(objtick,0), OBJ_TEXT, 0, Time[0], Low[0]-(7*p));
                       ObjectSetText("myz"+DoubleToStr(objtick,0),"TS",15,"Arial",Red);
                     }
                   else 
                     {
                       Print("-----ERROR----- MODIFY TRAILSTOP SELL Ask=", Ask, " error=", 
                             gle, " bartick=", bartick);
                     }
                 }

               // did we make our desired SELL profit?
               if((ProfitMade > 0 && CurrentProfit >= (ProfitMade*p)) || (LossLimit > 0 && 
                  CurrentProfit <= ((LossLimit*(-1))*p)))
                 {
                   OrderClose(OrderTicket(), Lots, Ask, Slippage, Red);
                   gle = GetLastError();
                   if(gle == 0)
                     {
                       Print("CLOSE SELL Ask=", Ask, " bartick=", bartick);
                       ObjectCreate("myz" + DoubleToStr(objtick, 0), OBJ_TEXT, 0, Time[0], 
                                    Low[0] - (7*p));
                       ObjectSetText("myz" + DoubleToStr(objtick, 0), "C", 15, "Arial", Red);
                     }
                   else 
                     {
                       Print("-----ERROR----- CLOSE SELL Ask=", Ask, " error=", gle, 
                             " bartick=", bartick);
                     }
                 
                 }

             } //if SELL
           
         } // if(OrderSymbol)
        
     } // for

  } // start()
//+-----------------+
//| CloseEverything |
//+-----------------+
// Closes all OPEN and PENDING orders
int CloseEverything()
  {
    double myAsk;
    double myBid;
    int    myTkt;
    double myLot;
    int    myTyp;
//----
    int i;
    bool result = false;
//----
    for(i = OrdersTotal(); i >= 0; i--)
      {
        OrderSelect(i, SELECT_BY_POS);
        //----
        myAsk = MarketInfo(OrderSymbol(), MODE_ASK);            
        myBid = MarketInfo(OrderSymbol(), MODE_BID);            
        myTkt = OrderTicket();
        myLot = OrderLots();
        myTyp = OrderType();
        //----    
        switch(myTyp)
          {
            //Close opened long positions
            case OP_BUY      :result = OrderClose(myTkt, myLot, myBid, Slippage, Red);
                              CEBuy++;
                              break;
            //Close opened short positions
            case OP_SELL     :result = OrderClose(myTkt, myLot, myAsk, Slippage, Red);
                              CESell++;
                              break;

            //Close pending orders
            case OP_BUYLIMIT :
            case OP_BUYSTOP  :
            case OP_SELLLIMIT:
            case OP_SELLSTOP :result = OrderDelete( OrderTicket() );
          }
        //----
        if(result == false)
          {
            Alert("Order " , myTkt , " failed to close. Error:" , GetLastError() );
            Print("Order " , myTkt , " failed to close. Error:" , GetLastError() );
            Sleep(3000);
          }  
        Sleep(1000);
        CEProc++;
      } //for
   } // closeeverything
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double divergence(int F_Period, int S_Period, int F_Price, int S_Price, int mypos)
  {
    int i;
//----
    double maF1, maF2, maS1, maS2;
    double dv1, dv2;
//----
    maF1 = iMA(Symbol(), 0, F_Period, 0, MODE_SMA, F_Price, mypos);
    maS1 = iMA(Symbol(), 0, S_Period, 0, MODE_SMA, S_Price, mypos);
    dv1 = (maF1 - maS1);

    maF2 = iMA(Symbol(), 0, F_Period, 0, MODE_SMA, F_Price, mypos + 1);
    maS2 = iMA(Symbol(), 0, S_Period, 0, MODE_SMA, S_Price, mypos + 1);
    dv2 = ((maF1 - maS1) - (maF2 - maS2));
//----
    return(dv1 - dv2);
  }
//+------------------------------------------------------------------+