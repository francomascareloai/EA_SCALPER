//+------------------------------------------------------------------+
//|                                                       THV EA.mq4 |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


#define MAGICMA  20050610

extern double     Lots             = 1;
extern double     MaximumRisk      = 0.3;
extern double     DecreaseFactor   = 1;
extern bool       PrefSettings     = true;
extern bool       MM               = true;
extern bool       AccountIsMicro   = false;
extern int        TakeProfit       = 42;
extern int        StopLoss         = 84;
extern int        TrailingStop     = 50;
extern double     lTrailingStop = 50;
extern double     sTrailingStop = 50;

extern bool       UseSignal1       = true;
extern bool       UseSignal2       = true;
extern bool       UseSignal3       = true;
extern bool       UseSignal4       = true;
extern bool       UseSignal5       = true;
extern bool       UseSignal6       = true;

extern int        TradeFrom1       = 0;
extern int        TradeUntil1      = 24;
extern int        TradeFrom2       = 0;
extern int        TradeUntil2      = 0;
extern int        TradeFrom3       = 0;
extern int        TradeUntil3      = 0;
extern int        TradeFrom4       = 0;
extern int        TradeUntil4      = 0;

color             color1           = Red;
color             color2           = White;
color             color3           = Red;
color             color4           = White;

bool              Alert_On         = false;
bool              Arrows_On        = false;
bool              Email_Alert      = false;

// 'THV3 Trix v4.01 Div'
extern string note1 = "Trix level colors";
extern  color HighLine_Color = FireBrick;
extern  color ZeroLine_Color = DimGray;
extern  color LowLine_Color = DarkGreen;
extern  int Line_style = 2;
extern  string note2 = "Cobra Label colors";
extern  color text1Color;
extern  color text2Color;
extern  color text3Color = Green;
extern  bool MsgAlerts = false;
extern  bool SoundAlerts = true;
extern  bool eMailAlerts = false;
extern  bool AlertOnTrixCross = true;
extern  bool AlertOnTrixSigCross = true;
extern  bool AlertOnSlopeChange = true;
extern  string TrixCrossSound = "trixcross.wav";
extern  int AnalyzeLabelWindow = 1;
extern  bool AnalyzeLabelonoff = true;
extern  int Trixnum_bars = 750;
extern  string seperator2 = "*** Convergence/Divergence Settings ***";
extern  int NumberOfDivergenceBars = 500;
extern  bool drawPriceTrendLines = true;
extern  bool drawIndicatorTrendLines = false;
extern  bool ShowIn1MChart = false;
extern  string _ = "--- Divergence Alert Settings ---";
extern  bool EnableAlerts = true;
extern  string _Info1 = "";
extern  string _Info2 = "------------------------------------";
extern  string _Info3 = "SoundAlertOnDivergence only works";
extern  string _Info4 = "when EnableAlerts is true.";
extern  string _Info5 = "";
extern  string _Info6 = "If SoundAlertOnDivergence is true,";
extern  string _Info7 = "then sound alert will be generated,";
extern  string _Info8 = "otherwise a pop-up alert will be";
extern  string _Info9 = "generated.";
extern  string _Info10 = "------------------------------------";
extern  string _Info11 = "";
extern  bool SoundAlertOnDivergence = true;
extern  bool EmailDivergenceAlerts = false;
extern  string __ = "--- Divergence Color Settings ---";
extern  color BullishDivergenceColor = DodgerBlue;
extern  color BearishDivergenceColor = FireBrick;
extern  string ___ = "--- Divergence Sound Files ---";
extern  string ClassicBullDivSound = "CBullishDiv.wav";
extern  string ReverseBullDivSound = "RBullishDiv.wav";
extern  string ClassicBearDivSound = "CBearishDiv.wav";
extern  string ReverseBearDivSound = "RBearishDiv.wav";

int res;
int lasttrend = 0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
         Comment("THV Forex Trading Strategy By CobraForex - Coded by OllyTrader");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
         Comment("");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
         //---- check for history and trading
         if(Bars<100 || IsTradeAllowed()==false) return;
         
         //---- calculate open orders by current symbol
         if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
         else 
         {
               CheckForClose();
               //TrailingPositions();
               TrailingPositionsBuy(lTrailingStop);
               TrailingPositionsSell(sTrailingStop);
      
         }
         //CheckForClose();
         
         
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//---- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }



//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=Lots;
   int    orders=HistoryTotal();    
   int    losses=0;                 

   lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000.0,1);

   if(DecreaseFactor>0)
     {
      for(int i=orders-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false) { Print("Error in history!"); break; }
         if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) continue;
         //----
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }
      if(losses>1) lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }

   if(lot<0.1) lot=0.1;
   if(MM==false) lot=Lots;
   if(AccountIsMicro==true) lot=lot/10;
//--- for CONTEST only
//   if(lot > 5) lot=5; 
   return(lot);
  }


//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
{
      bool BuySignal1 = false, SellSignal1 = false;
      bool BuySignal2 = false, SellSignal2 = false;
      bool BuySignal3 = false, SellSignal3 = false;
      bool BuySignal4 = false, SellSignal4 = false;
      bool BuySignal5 = false, SellSignal5 = false;
      bool BuySignal6 = false, SellSignal6 = false;

      double coral = iCustom(NULL, 0, "THV3 Coral_THICK",Alert_On,Arrows_On,Email_Alert,0,0);
      
      double haOpen = iCustom(NULL, 0, "Heiken Ashi",color1,color2,color3,color4,2,0);
      double haClose = iCustom(NULL, 0, "Heiken Ashi",color1,color2,color3,color4,3,0);
      
      //double haLow = iCustom(NULL, 0, "Heiken Ashi",color1,color2,color3,color4,0,0);
      //double haHigh = iCustom(NULL, 0, "Heiken Ashi",color1,color2,color3,color4,1,0);

      double haOpen1 = iCustom(NULL, 0, "Heiken Ashi",color1,color2,color3,color4,2,1);
      double haClose1 = iCustom(NULL, 0, "Heiken Ashi",color1,color2,color3,color4,3,1);
      
      double ssa = iIchimoku(NULL, 0, 2, 3, 5, MODE_SENKOUSPANA, 0);
      double ssb = iIchimoku(NULL, 0, 2, 3, 5, MODE_SENKOUSPANB, 0);
      int fasttrix = 0;
      int slowtrix = 0;
      
      double thvtrendDn = iCustom(NULL, 0, "THV3 trend",0,1);
      double thvtrendUp = iCustom(NULL, 0, "THV3 trend",1,1);
      double thvtrendFlat = iCustom(NULL, 0, "THV3 trend",2,1);
      
      fasttrix = trix("fast");
      slowtrix = trix("slow");
      
      
      if(UseSignal1)
      {
            if((haOpen < coral)) 
            {
                  SellSignal1 = true;
            } 
            if(haOpen > coral)   
            {
                  BuySignal1  = true;
            }
      }
      
      if(UseSignal2)
      {
            if(haOpen < ssb) 
            {
                  SellSignal2 = true;
            } 
            if(haOpen > ssa)   
            {
                  BuySignal2  = true;
            }
      }
      
      if(UseSignal3)
      {
            if(fasttrix == 2 && slowtrix == 4) 
            {
                  SellSignal3 = true;
            } 
            if(fasttrix == 1 && slowtrix == 3)   
            {
                  BuySignal3  = true;
            }
      }
      
      if(UseSignal4)
      {
            int iHour=TimeHour(LocalTime());
            int ValidTradeTime = F_ValidTradeTime(iHour);
            if(ValidTradeTime==true)
            {
                  BuySignal4=true;
                  SellSignal4=true;
            }
      }
      
      if(UseSignal5)
      {
            if(thvtrendDn > 0) 
            {
                  SellSignal5 = true;
            } 
            if(thvtrendUp > 0)   
            {
                  BuySignal5  = true;
            }
      }
      
      if(UseSignal6)
      {
            if(haOpen > haClose) 
            {
                  SellSignal6 = true;
            } 
            if(haOpen < haClose)   
            {
                  BuySignal6  = true;
            }
      }


   

//=================END SIGNALS=====

      
      
      
 //=================SELL CONDITIONS=====

      // if((SellSignal1==true) && (SellSignal2==true) && (SellSignal3==true))  
      if((SellSignal1==true) && (SellSignal2==true) && (SellSignal3==true) && (SellSignal4==true) && (SellSignal5==true) && (SellSignal6==true))   
      {
            if(AccountFreeMargin()<(1000*LotsOptimized()))
            {
                  Print("We have no money. Free Margin = ", AccountFreeMargin());         
                  return(0);          
            }
            
            Print("thvtrendDn:",DoubleToStr(thvtrendDn,4),";thvtrendUp:",DoubleToStr(thvtrendUp,4),";thvtrendFlat:",DoubleToStr(thvtrendFlat,4),";Sell|Coral: ",DoubleToStr(coral,4),";haOpen: ",haOpen,";ssa:",ssa,";ssb",ssb);
            if((lasttrend == 1) || (lasttrend == 0)) //res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Bid+StopLoss*Point,Bid-TakeProfit*Point,"THV ea",MAGICMA,0,Red);
            Alert("Sell Signal on ",Symbol()," -> ",Period());
            lasttrend = -1;
            return;
     }
     
//=================BUY CONDITIONS====

      // if((BuySignal1==true) && (BuySignal2==true) && (BuySignal3==true)) 
      if((BuySignal1==true) && (BuySignal2==true) && (BuySignal3==true) && (BuySignal4==true) && (BuySignal5==true) && (BuySignal6==true)) 
      {
            if(AccountFreeMargin()<(1000*LotsOptimized()))
            {
                  Print("We have no money. Free Margin = ", AccountFreeMargin());         
                  return(0);
            }
            Print("thvtrendDn:",DoubleToStr(thvtrendDn,4),";thvtrendUp:",DoubleToStr(thvtrendUp,4),";thvtrendFlat:",DoubleToStr(thvtrendFlat,4),";Buy|Coral: ",DoubleToStr(coral,4),";haOpen: ",haOpen,";ssa:",ssa,";ssb",ssb);
            if((lasttrend == -1) || (lasttrend == 0)) //res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Ask-StopLoss*Point,Ask+TakeProfit*Point,"THV ea",MAGICMA,0,Blue);
            Alert("Buy Signal on ",Symbol()," -> ",Period());
            lasttrend = 1;
            return;
      }

//=================END SELL/BUY CONDITIONS==========================

}


//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
{

      int fasttrix = trix("fast");
      double thvtrendDn = iCustom(NULL, 0, "THV3 trend",0,1);
      double thvtrendUp = iCustom(NULL, 0, "THV3 trend",1,1);
      double thvtrendFlat = iCustom(NULL, 0, "THV3 trend",2,1);


      for(int i=0;i<OrdersTotal();i++)
      {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)  break;
            
            if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
            
            // if((OrderType() == OP_BUY) && ((fasttrix == 2) || (thvtrendDn > 0)) )
            if((OrderType() == OP_BUY) && ((fasttrix == 2) && (thvtrendDn > 0)) )
            {
                    orderclosebuy(i);
                    return(0);
                    
            } // if((OrderType() == OP_SELL) && ((fasttrix == 1) || (thvtrendUp > 0)) )
            else if((OrderType() == OP_SELL) && ((fasttrix == 1) && (thvtrendUp > 0)) )
            {
                    orderclosesell(i);
                    return(0);
            } 
      }
}


int orderclosebuy(int cnt)
{
      string symbol = Symbol();
      int ticketbuy;
      double lotsbuy;
      
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
      {
               ticketbuy = OrderTicket();
               OrderSelect(ticketbuy, SELECT_BY_TICKET, MODE_TRADES);
               lotsbuy = OrderLots() ; 
               double bid = MarketInfo(symbol,MODE_BID); 
               RefreshRates();
               OrderClose(ticketbuy,lotsbuy,bid,3,Magenta); 
      }
      
      return(0);
}

int orderclosesell(int cnt)
{
      string symbol = Symbol();
      int ticketsell;
      double lotssell;
      
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
      {
               ticketsell = OrderTicket();
               OrderSelect(ticketsell, SELECT_BY_TICKET, MODE_TRADES);
               lotssell = OrderLots() ; 
               double ask = MarketInfo(symbol,MODE_ASK); 
               RefreshRates();
               OrderClose(ticketsell,lotssell,ask,3,Magenta); 
      }
      
      return(0);
}


 //=============== FUNCTION VALID TRADE TIME

bool F_ValidTradeTime (int iHour)
   {
      if(((iHour >= TradeFrom1) && (iHour <= (TradeUntil1-1)))||((iHour>= TradeFrom2) && (iHour <= (TradeUntil2-1)))||((iHour >= TradeFrom3)&& (iHour <= (TradeUntil3-1)))||((iHour >= TradeFrom4) && (iHour <=(TradeUntil4-1))))
      {
       return (true);
      }
      else
       return (false);
   }  
   
   
void ModifyStopLoss(double ldStopLoss) 
{ 
   bool fm;
   ldStopLoss = NormalizeDouble(ldStopLoss,5);
   fm = OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE); 
}    


void TrailingPositionsBuy(int trailingStop) { 
   for (int i=0; i<OrdersTotal(); i++) { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
         if (OrderSymbol()==Symbol()) { 
            if (OrderType()==OP_BUY) { 
               if (Bid-OrderOpenPrice()>trailingStop*Point) { 
                  if (OrderStopLoss()<Bid-trailingStop*Point) 
                     ModifyStopLoss(Bid-trailingStop*Point); 
               } 
            } 
         } 
      } 
   } 
} 

void TrailingPositionsSell(int trailingStop) { 
   for (int i=0; i<OrdersTotal(); i++) { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { 
         if (OrderSymbol()==Symbol()) { 
            if (OrderType()==OP_SELL) { 
               if (OrderOpenPrice()-Ask>trailingStop*Point) { 
                  if (OrderStopLoss()>Ask+trailingStop*Point || 
OrderStopLoss()==0)  
                     ModifyStopLoss(Ask+trailingStop*Point); 
               } 
            } 
         } 
      } 
   } 
} 
   
   
void TrailingPositions()
  {

   for(int i=0;i<OrdersTotal();i++)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)        break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
         {
         if(OrderType() == OP_BUY)
            {
            if(TrailingStop > 0)
               {
               if((Bid-OrderOpenPrice()) > (Point*TrailingStop))
                  {
                  if((OrderStopLoss()) < (Bid-Point*TrailingStop))
                     {
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,GreenYellow);
                     return(0);
                     }
                  } 
               }                  
 
            }

            if(OrderType() == OP_SELL)
               {
               if(TrailingStop > 0)
                  {
                  if(OrderOpenPrice()-Ask>Point*TrailingStop)
                     {
                     if(OrderStopLoss()>Ask+Point*TrailingStop)
                        {
                        OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
                        return(0);              
                        }
                     }     
                  }
                }
             }
          }
     }



int trix(string mode)
{
        double ftrix_0 = iCustom(NULL, 0, "THV3 Trix v4.01 Div", note1,HighLine_Color,ZeroLine_Color,LowLine_Color,Line_style,note2,text1Color,text2Color,text3Color,
MsgAlerts,SoundAlerts,eMailAlerts,AlertOnTrixCross,AlertOnTrixSigCross,AlertOnSlopeChange,
TrixCrossSound,AnalyzeLabelWindow,AnalyzeLabelonoff,Trixnum_bars,seperator2,NumberOfDivergenceBars,drawPriceTrendLines,
drawIndicatorTrendLines,ShowIn1MChart,_,EnableAlerts,_Info1,_Info2,_Info3,_Info4,
_Info5,_Info6,_Info7,_Info8,_Info9,_Info10,_Info11,SoundAlertOnDivergence,EmailDivergenceAlerts,__, BullishDivergenceColor, BearishDivergenceColor,___,ClassicBullDivSound,ReverseBullDivSound,ClassicBearDivSound,ReverseBearDivSound, 6, 1);


        double ftrix_1 = iCustom(NULL, 0, "THV3 Trix v4.01 Div", note1,HighLine_Color,ZeroLine_Color,LowLine_Color,Line_style,note2,text1Color,text2Color,text3Color,
MsgAlerts,SoundAlerts,eMailAlerts,AlertOnTrixCross,AlertOnTrixSigCross,AlertOnSlopeChange,
TrixCrossSound,AnalyzeLabelWindow,AnalyzeLabelonoff,Trixnum_bars,seperator2,NumberOfDivergenceBars,drawPriceTrendLines,
drawIndicatorTrendLines,ShowIn1MChart,_,EnableAlerts,_Info1,_Info2,_Info3,_Info4,
_Info5,_Info6,_Info7,_Info8,_Info9,_Info10,_Info11,SoundAlertOnDivergence,EmailDivergenceAlerts,__, BullishDivergenceColor, BearishDivergenceColor,___,ClassicBullDivSound,ReverseBullDivSound,ClassicBearDivSound,ReverseBearDivSound, 6, 2);



        double strix_0 = iCustom(NULL, 0, "THV3 Trix v4.01 Div", note1,HighLine_Color,ZeroLine_Color,LowLine_Color,Line_style,note2,text1Color,text2Color,text3Color,
MsgAlerts,SoundAlerts,eMailAlerts,AlertOnTrixCross,AlertOnTrixSigCross,AlertOnSlopeChange,
TrixCrossSound,AnalyzeLabelWindow,AnalyzeLabelonoff,Trixnum_bars,seperator2,NumberOfDivergenceBars,drawPriceTrendLines,
drawIndicatorTrendLines,ShowIn1MChart,_,EnableAlerts,_Info1,_Info2,_Info3,_Info4,
_Info5,_Info6,_Info7,_Info8,_Info9,_Info10,_Info11,SoundAlertOnDivergence,EmailDivergenceAlerts,__, BullishDivergenceColor, BearishDivergenceColor,___,ClassicBullDivSound,ReverseBullDivSound,ClassicBearDivSound,ReverseBearDivSound, 7, 1);


        double strix_1 = iCustom(NULL, 0, "THV3 Trix v4.01 Div", note1,HighLine_Color,ZeroLine_Color,LowLine_Color,Line_style,note2,text1Color,text2Color,text3Color,
MsgAlerts,SoundAlerts,eMailAlerts,AlertOnTrixCross,AlertOnTrixSigCross,AlertOnSlopeChange,
TrixCrossSound,AnalyzeLabelWindow,AnalyzeLabelonoff,Trixnum_bars,seperator2,NumberOfDivergenceBars,drawPriceTrendLines,
drawIndicatorTrendLines,ShowIn1MChart,_,EnableAlerts,_Info1,_Info2,_Info3,_Info4,
_Info5,_Info6,_Info7,_Info8,_Info9,_Info10,_Info11,SoundAlertOnDivergence,EmailDivergenceAlerts,__, BullishDivergenceColor, BearishDivergenceColor,___,ClassicBullDivSound,ReverseBullDivSound,ClassicBearDivSound,ReverseBearDivSound, 7, 2);


         if(mode == "fast")
         {
               if(ftrix_0 > ftrix_1)  return(1);
               if(ftrix_0 < ftrix_1)  return(2);
         }

         if(mode == "slow")
         {
               if(strix_0 > strix_1)  return(3);
               if(strix_0 < strix_1)  return(4);
         }
         
         return(0);
}