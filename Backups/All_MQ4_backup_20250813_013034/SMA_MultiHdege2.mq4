//+------------------------------------------------------------------+
//|                                               SMA_MultiHdege.mq4 |
//|                                    Copyright © 2006, Little Evil |
//|                                                vixenme@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Little Evil"
#property link      "vixenme@gmail.com"
//----
#include <stdlib.mqh>
//----
extern bool    TradeAllowed               = false;
extern string  _........SMA.Zone.........="________________________________";
extern int       periodSMA                = 20;
extern string  _........CorRelation.......="________________________________";
extern int       cPeriod                  = 20;
extern string  _........................._="________________________________";
extern string  BaseSymbol                 = "GBPUSD";
extern bool    AutoLot                    = false;
extern int     MMBase                     = 3;
extern double  MaxRisk                    = 0.1;// 10% by default
extern double  Not.AutoLot.LotSize        = 0.1;
extern string  _........Hedge.Symbol......="________________________________";
extern bool    HedgeH1                    = true;
extern string  H1.Symbol                  = "EURUSD";
extern bool    H1.followBase              = false;
extern double  H1.LotsRatio               = 2;
extern double  H1.Expect.CorRelation      = 0.88;
extern string  _._._._._._._._._._._._._._="________________________________";
extern bool    HedgeH2                    = true;
extern string  H2.Symbol                  = "USDCHF";
extern bool    H2.followBase              = true;
extern double  H2.LotsRatio               = 1.5;
extern double  H2.Expect.CorRelation      = -0.90;
extern string  _.._.._.._.._.._.._.._.._.._="________________________________";
extern bool    HedgeH3                    = false;
extern string  H3.Symbol                  = "USDJPY";
extern bool    H3.followBase              = true;
extern double  H3.LotsRatio               = 2;
extern double  H3.Expect.CorRelation      = -0.90;
extern string  _.__.__.__.__.__.__.__.__.__="________________________________";
extern double     Expect.Profit           = 30;
extern int        MagicNo                 = 111;                 
extern bool       ShowStatus              = true;
extern bool       PlayAudio               = false;
//----
int BaseSP, 
    H1.SP, 
    H2.SP, 
    H3.SP, 
    BaseOP = -1,
    H1.OP = -1, 
    H2.OP = -1, 
    H3.OP = -1, 
    up;
double Lot,
       BaseOpen,
       H1.Open, H2.Open, H3.Open,
       BaseLots,
       H1.Lots, H2.Lots, H3.Lots,
       Baseswapshort,
       Baseswaplong,
       H1.swapshort, H2.swapshort, H3.swapshort,
       H1.swaplong, H2.swaplong, H3.swaplong,
       H1.Correlation,
       H2.Correlation,
       H3.Correlation,
       LotSize,
       TP2Close;
bool SResult = false, BResult = false, H1.profitswap, H2.profitswap, H3.profitswap;
bool SwapMode = true;
string H1.string = "", H2.string = "", H3.string = "", OrdComment = "";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Baseswapshort = MarketInfo(BaseSymbol, MODE_SWAPSHORT);
   Baseswaplong  = MarketInfo(BaseSymbol, MODE_SWAPLONG);
//---- 
   H1.swapshort = MarketInfo(H1.Symbol, MODE_SWAPSHORT);
   H1.swaplong  = MarketInfo(H1.Symbol, MODE_SWAPLONG);
//---- 
   H2.swapshort = MarketInfo(H2.Symbol, MODE_SWAPSHORT);
   H2.swaplong  = MarketInfo(H2.Symbol, MODE_SWAPLONG);
//---- 
   H3.swapshort = MarketInfo(H3.Symbol, MODE_SWAPSHORT);
   H3.swaplong  = MarketInfo(H3.Symbol, MODE_SWAPLONG);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   LotSize = Not.AutoLot.LotSize;
   TP2Close = Expect.Profit;
//----
   if(SMA(0) > SMA(1) && SMA(1) > SMA(2))    
       up = 1;
   else 
       if(SMA(0) < SMA(1) && SMA(1) < SMA(2))
           up = -1;
       else 
           up= 0;
//----
   if(AutoLot)
     {
       BaseLots = Lots(BaseSymbol, MaxRisk) ;
       H1.Lots = Lots(H1.Symbol, MaxRisk*H1.LotsRatio);
       H2.Lots = Lots(H2.Symbol, MaxRisk*H2.LotsRatio);
       H3.Lots = Lots(H3.Symbol, MaxRisk*H3.LotsRatio);
     }
   else
     {
       BaseLots = LotSize;
       H1.Lots = NormalizeDouble(LotSize*H1.LotsRatio, 1);
       H2.Lots = NormalizeDouble(LotSize*H2.LotsRatio, 1);
       H3.Lots = NormalizeDouble(LotSize*H3.LotsRatio, 1);
     }
   BaseSP = MarketInfo(BaseSymbol, MODE_SPREAD);
//----
   if(BaseSP == 0)
       BaseSP = MathRound((MarketInfo(BaseSymbol, MODE_ASK) -
                          MarketInfo(BaseSymbol, MODE_BID)) / 
                          MarketInfo(BaseSymbol, MODE_POINT));
//----
   if(up == 1) 
     {
       BaseOP = OP_BUY; 
       BaseOpen = MarketInfo(BaseSymbol, MODE_ASK);
     }
//----
   if(up == -1)
     {
       BaseOP = OP_SELL;
       BaseOpen = MarketInfo(BaseSymbol, MODE_BID);
     }
//----
   if(H1.Symbol != "" && HedgeH1)
     {
       H1.Correlation = Cor(BaseSymbol, H1.Symbol);
       H1.SP = MarketInfo(H1.Symbol, MODE_SPREAD);
       //----
       if(H1.SP == 0)
           H1.SP = MathRound((MarketInfo(H1.Symbol, MODE_ASK) -
                             MarketInfo(H1.Symbol, MODE_BID)) /
                             MarketInfo(H1.Symbol, MODE_POINT));                
       //----
       if(H1.Expect.CorRelation > 0 && H1.Correlation >= H1.Expect.CorRelation)
           bool H1.meetCor = true;
       else 
           if(H1.Expect.CorRelation < 0 && H1.Correlation <= H1.Expect.CorRelation)
               H1.meetCor = true;
       else 
           H1.meetCor = false;
       //----
       if(up == 1)// base long
         {
           //----
           if(H1.followBase) // H.long
             {
               H1.OP = OP_BUY; 
               H1.Open = MarketInfo(H1.Symbol, MODE_ASK);
               H1.profitswap = (((Baseswaplong*BaseLots) + (H1.swaplong*H1.Lots)) > 0);
             }
           else  // H.short
             {
               H1.OP = OP_SELL; 
               H1.Open = MarketInfo(H1.Symbol, MODE_BID);
               H1.profitswap = (((Baseswaplong*BaseLots) + (H1.swapshort*H1.Lots)) > 0);
             }
         }
       //----
       if(up == -1) // base short
         {
           //----
           if(H1.followBase) // H.short
             {
               H1.OP = OP_SELL; 
               H1.Open = MarketInfo(H1.Symbol, MODE_BID);
               H1.profitswap = (((Baseswaplong*BaseLots) + (H1.swapshort*H1.Lots)) > 0);
             }
           else            //H.long
             {
               H1.OP = OP_BUY; 
               H1.Open = MarketInfo(H1.Symbol, MODE_ASK);
               H1.profitswap = (((Baseswaplong*BaseLots) + (H1.swaplong*H1.Lots)) > 0);
             }
         }
       H1.string = "\n--------------------------------"
                   + "\n" + BaseSymbol + "->" + Val2String(BaseOP)
                   + " ~ " + H1.Symbol + "->" + Val2String(H1.OP)
                   + "\n" + BaseSymbol + "->" + DoubleToStr(BaseLots, 2)
                   + " ~ " + H1.Symbol + "->" + DoubleToStr(H1.Lots, 2)
                   + "\nFollow Base : " + bool2string(H1.followBase)
                   + "\nRaito : " + DoubleToStr(H1.LotsRatio, 2)
                   + "\nMagic No. : " + MagicNo
                   + "\nCur Correlation : " + DoubleToStr(H1.Correlation, 2)
                   + "\n" + "Expected Correlation : " + DoubleToStr(H1.Expect.CorRelation, 2)
                   + "\nOverAllProfit : " + DoubleToStr(TotalSwapnProfit(MagicNo), 2)
                   + "\nExpected : $" + DoubleToStr(TP2Close, 2);

     }
   else
       H1.string = "";
//----
   if(H2.Symbol != "" && HedgeH2)
     {
       H2.Correlation = Cor(BaseSymbol, H2.Symbol);
       H2.SP = MarketInfo(H2.Symbol, MODE_SPREAD);
       //----
       if(H2.SP == 0)
           H2.SP = MathRound((MarketInfo(H2.Symbol, MODE_ASK) -
                             MarketInfo(H2.Symbol, MODE_BID)) /
                             MarketInfo(H2.Symbol, MODE_POINT));
       //----
       if(H2.Expect.CorRelation > 0 && H2.Correlation >= H2.Expect.CorRelation)
           bool H2.meetCor = true;
       else 
           if(H2.Expect.CorRelation < 0 && H2.Correlation <= H2.Expect.CorRelation)
               H2.meetCor = true;
       else 
           H2.meetCor = false;
       //----
       if(up == 1) // base long
         {
           if(H2.followBase) // H.long
             {
               H2.OP = OP_BUY; 
               H2.Open = MarketInfo(H2.Symbol, MODE_ASK);
               H2.profitswap = (((Baseswaplong*BaseLots) + (H2.swaplong*H2.Lots)) > 0);
             }
           else  // H.short
             {
               H2.OP = OP_SELL; 
               H2.Open = MarketInfo(H2.Symbol, MODE_BID);
               H2.profitswap = (((Baseswaplong*BaseLots) + (H2.swapshort*H2.Lots)) > 0);
             }
         }
       //----
       if(up == -1) // base short
         {
           if(H2.followBase) // H.short
             {
               H2.OP = OP_SELL; 
               H2.Open = MarketInfo(H2.Symbol, MODE_BID);
               H2.profitswap = (((Baseswaplong*BaseLots) + (H2.swapshort*H2.Lots)) > 0);
             }
           else  // H.long
             {
               H2.OP = OP_BUY; 
               H2.Open = MarketInfo(H2.Symbol, MODE_ASK);
               H2.profitswap = (((Baseswaplong*BaseLots) + (H2.swaplong*H2.Lots)) > 0);
             }
         }
       H2.string = "\n--------------------------------"
                   + "\n" + BaseSymbol + "->" + Val2String(BaseOP)
                   + " ~ " + H2.Symbol+"->" + Val2String(H2.OP)
                   + "\n" + BaseSymbol+"->" + DoubleToStr(BaseLots, 2)
                   + " ~ " + H2.Symbol + "->" + DoubleToStr(H2.Lots, 2)
                   + "\nFollow Base : " + bool2string(H2.followBase)
                   + "\nRaito : " + DoubleToStr(H2.LotsRatio, 2)
                   + "\nMagic No. : " + DoubleToStr(MagicNo+1, 0)
                   + "\nCur Correlation : " + DoubleToStr(H2.Correlation, 2)
                   + "\n" + "Expected Correlation : " + DoubleToStr(H2.Expect.CorRelation, 2)
                   + "\nOverAllProfit : " + DoubleToStr(TotalSwapnProfit(MagicNo + 1), 2)
                   + "\nExpected : $" + DoubleToStr(TP2Close, 2);
     }
   else
     {
       H2.string = "";
     }
//----
   if(H3.Symbol != "" && HedgeH3)
     {
       H3.Correlation = Cor(BaseSymbol, H3.Symbol);
       H3.SP = MarketInfo(H3.Symbol, MODE_SPREAD);
       //----
       if(H3.SP == 0)
           H3.SP = MathRound((MarketInfo(H3.Symbol, MODE_ASK) -
                             MarketInfo(H3.Symbol, MODE_BID)) /
                             MarketInfo(H3.Symbol, MODE_POINT));
       //----
       if(H3.Expect.CorRelation > 0 && H3.Correlation >= H3.Expect.CorRelation)
           bool H3.meetCor = true;
       else 
           if(H3.Expect.CorRelation < 0 && H3.Correlation <= H3.Expect.CorRelation)
               H3.meetCor = true;
           else
               H3.meetCor = false;
       //----
       if(up == 1) // base long
         {
           if(H3.followBase) // H.long
             {
               H3.OP = OP_BUY; 
               H3.Open = MarketInfo(H3.Symbol, MODE_ASK);
               H3.profitswap = (((Baseswaplong*BaseLots) + (H3.swaplong*H3.Lots)) > 0);
             }
           else   // H.short
             {
               H3.OP = OP_SELL; 
               H3.Open = MarketInfo(H3.Symbol, MODE_BID);
               H3.profitswap = (((Baseswaplong*BaseLots) + (H3.swapshort*H3.Lots)) > 0);
             }
         }
       if(up == -1) // base short
         {
           if(H3.followBase) // H.short
             {
               H3.OP = OP_SELL; 
               H3.Open = MarketInfo(H3.Symbol, MODE_BID);
               H3.profitswap = (((Baseswaplong*BaseLots) + (H3.swapshort*H3.Lots)) > 0);
             }
           else  // H.long
             {
               H3.OP = OP_BUY; 
               H3.Open = MarketInfo(H3.Symbol, MODE_ASK);
               H3.profitswap = (((Baseswaplong*BaseLots) + (H3.swaplong*H3.Lots)) > 0);
             }
         }
       H3.string = "\n--------------------------------"
                   + "\n" + BaseSymbol + "->" + Val2String(BaseOP)
                   + " ~ " + H3.Symbol + "->" + Val2String(H3.OP)
                   + "\n" + BaseSymbol + "->" + DoubleToStr(BaseLots, 2)
                   + " ~ " + H3.Symbol + "->" + DoubleToStr(H3.Lots, 2)
                   + "\nFollow Base : " + bool2string(H3.followBase)
                   + "\nRaito : " + DoubleToStr(H3.LotsRatio, 2)
                   + "\nMagic No. : " + DoubleToStr(MagicNo + 2, 0)
                   + "\nCur Correlation : " +DoubleToStr(H3.Correlation, 2)
                   + "\n" + "Expected Correlation : " + DoubleToStr(H3.Expect.CorRelation, 2)
                   + "\nOverAllProfit : " + DoubleToStr(TotalSwapnProfit(MagicNo + 2), 2)
                   + "\nExpected : $" + DoubleToStr(TP2Close, 2);
     }
   else
     {
       H3.string = "";
     } // END
//----
   if(TradeAllowed && (up == 1 || up == -1))
     {
       //----
       if(H1.Symbol != "" && H1.meetCor && HedgeH1)
         {
           //----
           if(ExistPositions(BaseSymbol, BaseOP,MagicNo) == 0)
             {
               OrdComment = DoubleToStr(MagicNo, 0) + ":B"; // RefreshRates();
               //----
               if(OrderSend(BaseSymbol
                            ,BaseOP
                            ,BaseLots
                            ,BaseOpen
                            ,BaseSP
                            ,0
                            ,0
                            ,OrdComment
                            ,MagicNo
                            ,CLR_NONE)>0)
                 {
                   //----
                   if(PlayAudio)
                       PlaySound("expert.wav");
                 }
               else 
                   Print(BaseSymbol,": " ,Val2String(BaseOP), ", ", MagicNo," : ",
                         ErrorDescription(GetLastError()));
             }
           //----
           if(ExistPositions(H1.Symbol, H1.OP, MagicNo) == 0)
             {
               OrdComment = DoubleToStr(MagicNo, 0) + ":H"; // RefreshRates();
               //----
               if(OrderSend(H1.Symbol
                            ,H1.OP
                            ,H1.Lots
                            ,H1.Open
                            ,H1.SP
                            ,0
                            ,0
                            ,OrdComment
                            ,MagicNo
                            ,CLR_NONE)>0)
                 {
                   //----
                   if(PlayAudio)
                       PlaySound("expert.wav");
                 }
               else 
                   Print(H1.Symbol,": ",Val2String(H1.OP),", ",MagicNo," : ",
                         ErrorDescription(GetLastError()));
             }
         }
       // end H1
       if(H2.Symbol != "" && H2.meetCor && HedgeH2)
         {
           //----
           if(ExistPositions(BaseSymbol, BaseOP, MagicNo + 1) == 0)
             {
               OrdComment = DoubleToStr(MagicNo + 1, 0) + ":B"; // RefreshRates();
               //----
               if(OrderSend(BaseSymbol
                            ,BaseOP
                            ,BaseLots
                            ,BaseOpen
                            ,BaseSP
                            ,0
                            ,0
                            ,OrdComment
                            ,MagicNo+1
                            ,CLR_NONE)>0)
                 {
                   //----
                   if(PlayAudio)
                       PlaySound("expert.wav");
                 }
               else 
                   Print(BaseSymbol,": ", Val2String(BaseOP), ", ", MagicNo + 1, " : ",
                         ErrorDescription(GetLastError()));
             }
           //----
           if(ExistPositions(H2.Symbol, H2.OP, MagicNo + 1) == 0)
             {
               OrdComment = DoubleToStr(MagicNo + 1, 0) + ":H"; // RefreshRates();
               //----
               if(OrderSend(H2.Symbol
                            ,H2.OP
                            ,H2.Lots
                            ,H2.Open
                            ,H2.SP
                            ,0
                            ,0
                            ,OrdComment
                            ,MagicNo+1
                            ,CLR_NONE)>0)
                 {
                   //----
                   if(PlayAudio)
                       PlaySound("expert.wav");
                 }
               else 
                   Print(H2.Symbol, ": ", Val2String(H2.OP), ", ", MagicNo + 1, " : ", 
                         ErrorDescription(GetLastError()));
             }
         }
       // end H2
       if(H3.Symbol != "" && H3.meetCor && HedgeH3)
         {
           //----
           if(ExistPositions(BaseSymbol, BaseOP, MagicNo + 2) == 0)
             {
               OrdComment = DoubleToStr(MagicNo + 2, 0) + ":B"; // RefreshRates();
               //----
               if(OrderSend(BaseSymbol
                            ,BaseOP
                            ,BaseLots
                            ,BaseOpen
                            ,BaseSP
                            ,0
                            ,0
                            ,OrdComment
                            ,MagicNo+2
                            ,CLR_NONE)>0)
                 {
                   //----
                   if(PlayAudio)
                       PlaySound("expert.wav");
                 }
               else 
                   Print(BaseSymbol,": ", Val2String(BaseOP), ", ", MagicNo + 2, " : ",
                         ErrorDescription(GetLastError()));
             }
           //----
           if(ExistPositions(H3.Symbol, H3.OP, MagicNo + 2) == 0)
             {
               OrdComment = DoubleToStr(MagicNo + 3, 0) + ":H"; // RefreshRates();
               //----
               if(OrderSend(H3.Symbol
                            ,H3.OP
                            ,H3.Lots
                            ,H3.Open
                            ,H3.SP
                            ,0
                            ,0
                            ,OrdComment
                            ,MagicNo+2
                            ,CLR_NONE)>0)
                 {
                   //----
                   if(PlayAudio)
                       PlaySound("expert.wav");
                 }
               else 
                   Print(H3.Symbol,": ", Val2String(H3.OP), ", ", MagicNo + 2, " : ",
                         ErrorDescription(GetLastError()));
             }
         }
       // end H3
     } // TradeAllowed
//----
   if(H1.profitswap)
     {
       if(TotalCurProfit(MagicNo) > TP2Close)
         {
           if(CloseHedge(MagicNo))
             {
             }
         }   
     }
   else
     {
       if(TotalSwapnProfit(MagicNo) > TP2Close)
         {
           if(CloseHedge(MagicNo))
             {
             }
         }
     }
// end H1.profitswap
   if(H2.profitswap)
     {
       if(TotalCurProfit(MagicNo+1) > TP2Close)
         {
           if(CloseHedge(MagicNo + 1))
             {
             }
         }   
     }
   else
     {
       if(TotalSwapnProfit(MagicNo + 1) > TP2Close)
         {
           if(CloseHedge(MagicNo + 1))
             {
             }
         }
     }
// end H2.profitswap
   if(H3.profitswap)
     {
       if(TotalCurProfit(MagicNo + 2) > TP2Close)
         {
           if(CloseHedge(MagicNo + 2))
             {
             }
         }   
     }
   else
     {
       if(TotalSwapnProfit(MagicNo + 2) > TP2Close)
         {
           if(CloseHedge(MagicNo + 2))
             {
             }
         }
     }
// end H3.profitswap
   if(ShowStatus)
       Comment("\nTradeAllowed : ",bool2string(TradeAllowed) + H1.string + H2.string +
               H3.string + "\n--------------------------------" + "\nCurBalance: ",
               DoubleToStr(AccountBalance(), 2) + "\nCurEquity : ", 
               DoubleToStr(AccountEquity(), 2));
   else 
       Comment("");       
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseHedge(int magic)
  {  
   //_______________________________________________________________________
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {         
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == magic)
         {
           if(OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(),
              MarketInfo(OrderSymbol(), MODE_SPREAD), CLR_NONE))
               SResult = true;
         }
     }
   if(SResult || BResult)
     {
       if(PlayAudio)
         {
           PlaySound("ok.wav");
         }
       return(true);
     }
   else 
       Print("CloseHedge Error: ", ErrorDescription(GetLastError()));
   RefreshRates();
  }   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lots(string symbol, double risk)                      
  {
   if(risk > 1)
     risk=1;
   double Min_Lot = MarketInfo(symbol, MODE_MINLOT);     
   double Max_Lot = MarketInfo(symbol, MODE_MAXLOT);     
   double lot_step = MarketInfo(symbol, MODE_LOTSTEP);    
   Lot = NormalizeDouble(Base(MMBase)*risk / AccountLeverage() / 10.0, 2);                                                   
   Lot = NormalizeDouble(Lot / lot_step, 0)*lot_step;
   if(Lot < Min_Lot) 
       Lot = Min_Lot;                     
   if(Lot > Max_Lot) 
       Lot = Max_Lot;                     
   return(Lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Base(int MM)
  {
   switch(MM)
     {
       case 1: return(AccountBalance()); break;
       case 2: return(AccountEquity()); break;
       case 3: return(AccountFreeMargin());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalCurProfit(int magic)
  {   
   double MyCurrentProfit = 0;
   for(int cnt = 0 ; cnt < OrdersTotal() ; cnt++)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderMagicNumber() == magic)
         {
           MyCurrentProfit += OrderProfit();
         }   
     }
  return(MyCurrentProfit);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalSwapnProfit(int magic)
  {   
   double MyCurrentProfit = 0, CurSwap = 0;
   for(int cnt = 0 ; cnt < OrdersTotal() ; cnt++)
     {
       OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
       if(OrderMagicNumber() == magic)
         {
           MyCurrentProfit += OrderProfit();
           CurSwap += OrderSwap();
         }   
     }
   return(MyCurrentProfit+CurSwap);
  }   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Val2String(int val)
  {
   string S2R;
   switch(val)
     {
       case 0: S2R = "BUY"; break;
       case 1: S2R = "SELL"; break;
       case 2: S2R = "BUYLIMIT"; break;
       case 3: S2R = "SELLLIMIT"; break;
       case 4: S2R = "BUYSTOP"; break;
       case 5: S2R = "SELLSTOP"; break;
       default : S2R = "NONE"; break;
     }
   return(S2R);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string bool2string(bool cond)
  {
   if(cond)
       return("Yes");
   else    
       return("No");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SMA(int shift)
  {
   double sma = iMA(BaseSymbol, 0, periodSMA, 0, MODE_SMA, PRICE_CLOSE, shift);
   return(sma);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double symboldif(string symbol, int shift)
  {
    return(iClose(symbol, 0, shift) - iMA(symbol, 0, cPeriod, 0,MODE_SMA, 
           PRICE_CLOSE, shift));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double powdif(double val)
  {
   return(MathPow(val, 2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double u(double val1, double val2)
  {
   return((val1*val2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Cor(string base, string hedge)
  {  
   double u1 = 0, l1 = 0, s1 = 0;
   for(int i = cPeriod - 1; i >= 0; i--)
     {
       u1 += u(symboldif(base, i), symboldif(hedge, i));
       l1 += powdif(symboldif(base, i));
       s1 += powdif(symboldif(hedge, i));
     }
   double dMathSqrt = MathSqrt(l1*s1);
   if(dMathSqrt > 0) 
       return(u1 / dMathSqrt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ExistPositions(string symbol, int op, int magic) 
  {
   int NumPos = 0;
   for(int i = 0; i < OrdersTotal(); i++) 
     {
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) &&
          OrderSymbol() == symbol &&
          OrderMagicNumber() == magic &&
          OrderType() == op)
         { 
           NumPos++;
         }
     }
   return(NumPos);
  }
//+------------------------------------------------------------------+


