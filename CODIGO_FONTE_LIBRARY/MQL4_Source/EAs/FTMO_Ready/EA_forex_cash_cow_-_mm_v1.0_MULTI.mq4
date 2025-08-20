//+------------------------------------------------------------------+
//|                                               FOREX CASH COW.mq4 |
//|                   Copyright © 2007, GwadaTradeBoy Software Corp. |
//|                                           GwadaTradeBoy@yahoo.fr |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, GwadaTradeBoy Software Corp."
#property link      "GwadaTradeBoy@yahoo.fr"

//---- 
extern int     Delta       = 140;
extern int     Rule2Dist   = 70;
extern int     Rule3Dist   = 30;
extern int     SL          = 60;
extern int     TP          = 100;

//----
int            PrevBarHiLo, LastDayTrade,ecnt, total;
int            JT_SL,                                 // Jumlah Trades Sell Limit
               JT_BL,                                 // Jumlah Trades Buy Limit
               JT_SS,                                 // Jumlah Trades Sell Stop
               JT_BS,                                 // Jumlah Trades Buy Stop
               JT_OS,                                 // Jumlah Trades Open Sell
               JT_OB;                                 // Jumlah Trades Open Buy
double         PriceRule2, PriceRule3;

//---- Money Management
extern bool    MoneyManagement   = true;
extern double  Lots              = 0.1;
extern double  MaximumRisk       = 0.02;
extern double  DecreaseFactor    = 3;
extern bool    AcountIsMini      = false;
double   lot;
int      orders, losses, spread;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
   {
//---- Expert Advisor
      spread = MarketInfo(Symbol(),MODE_SPREAD);
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
//| Calculs preliminaires de l'expert                                |
//+------------------------------------------------------------------+
//********** Calcul de la taille optimale du lot **********//
double LotsOptimized()
   {
      if (AcountIsMini)
         Lots = 0.01;
      lot=Lots;
      orders=HistoryTotal();     // Historique des ordres
      losses=0;                  // Nombre de trade perdants consécutif
/* Selection de la taille du lot */
      lot=NormalizeDouble(AccountFreeMargin()*MaximumRisk/1000,1);
/* Calcul du nombre de perte consecutive */
      if(DecreaseFactor>0)
         {
            for(int i=orders-1;i>=0;i--)
               {
                  if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==False) 
                     { 
                        Print("Erreur dans l historique!"); 
                        break; 
                     }
                  if(OrderSymbol()!=Symbol() || OrderType()>OP_SELL) 
                     continue;
//----
                  if(OrderProfit()>0) 
                     break;
                  if(OrderProfit()<0) 
                     losses++;
               }
            if(losses>1) 
               lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
         }
/* Retour de la taille du lot */
      if (AcountIsMini)
         if(lot<0.01) 
            lot=0.01;
      if(lot<0.1) 
         lot=0.1;
//----
      return(lot);
   }

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
   {
//----
      PrevBarHiLo = (High[1]-Low[1])/Point;
//---- Req.#1 - Price Explosion
      if (PrevBarHiLo >= Delta)
         {
//---- SELL Direction            
            if (Open[1]>Close[1])
               {
                  PriceRule3 = (Low[1]-(Rule3Dist*Point));
                  Print (PriceRule3);
//---- Req.#2 - 70 pips move in the direction of the price explosion
                  if ((High[0]-Bid)/Point>=Rule2Dist)
                     {
//---- Req.#3 - 30 pips between Low[1] et PriceRule2
                        //if (PriceRule2 <= PriceRule3)
                        //if ((Low[1]-Bid)/Point>=Rule3Dist)
                           //{
                              if (OrdersTotal()<=0 && TimeDayOfYear(CurTime())!=LastDayTrade)
                                 {
                                    LastDayTrade=TimeDayOfYear(CurTime());
                                    //OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,0,Bid+(SL*Point),Bid-(TP*Point),"Sell",0,0,Red);
                                    OrderSend(Symbol(),OP_SELLLIMIT,LotsOptimized(),PriceRule3,0,Bid+(SL*Point),Bid-(TP*Point),"Sell",0,0,Red);
                                 }
                           //}
                     }
               }
//---- BUY Direction      
            if (Open[1]<Close[1])
               {
                  PriceRule3 = (High[1]+(Rule3Dist*Point));
                  Print (PriceRule3);
//---- Req.#2 - 70 pips move in the direction of the price explosion
                  if ((Ask-Low[0])/Point>=Rule2Dist)
                     {
//---- Req.#3 - 30 pips between High[1] et PriceRule2
                        //if ((Ask-High[1])/Point>=Rule3Dist) 
                           //{
                              if (OrdersTotal()<=0 && TimeDayOfYear(CurTime())!=LastDayTrade)
                                 {
                                    LastDayTrade=TimeDayOfYear(CurTime());
                                    //OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,0,Ask-(SL*Point),Ask+(TP*Point),"Buy",0,0,Blue);
                                    OrderSend(Symbol(),OP_BUYLIMIT,LotsOptimized(),PriceRule3,0,Ask-(SL*Point),Ask+(TP*Point),"Buy",0,0,Blue);
                                 }
                           //}
                     }
               }
         }
      CheckAllTrade();
      if (JT_OS>0 || JT_OB>0)
         {
            SetSLtoBEP();
            if (TimeHour(CurTime())==23 && TimeMinute(CurTime())==30)
               {
                  TutupOpenPosisi();
               }
         }
//----
      return(0);
   }
//+------------------------------------------------------------------+

void CheckAllTrade()
   {
      JT_SL=0;
      JT_BL=0;
      JT_SS=0;
      JT_BS=0;
      JT_OS=0;
      JT_OB=0;
      total=OrdersTotal();
      for (ecnt=0;ecnt<total;ecnt++)
         {
            OrderSelect(ecnt,SELECT_BY_POS, MODE_TRADES);
            if (OrderType()==OP_SELLLIMIT && OrderSymbol()==Symbol())
               JT_SL++;
            else 
               if (OrderType()==OP_BUYLIMIT && OrderSymbol()==Symbol())
                  JT_BL++;         
               else 
                  if (OrderType()==OP_SELLSTOP && OrderSymbol()==Symbol())
                     JT_SS++;
                  else 
                     if (OrderType()==OP_BUYSTOP && OrderSymbol()==Symbol())
                        JT_BS++;         
                     else 
                        if (OrderType()==OP_SELL && OrderSymbol()==Symbol())
                           JT_OS++;
                        else 
                           if (OrderType()==OP_BUY && OrderSymbol()==Symbol())
                              JT_OB++;         
         }
   }

void SetSLtoBEP()
   {
      total=OrdersTotal();
      for (ecnt=0;ecnt<total;ecnt++)
         {
            OrderSelect(ecnt,SELECT_BY_POS, MODE_TRADES);
            if (OrderProfit()/10>=30)
               {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Brown);
               }
         }
   }
   
void TutupOpenPosisi()
   {
      total=OrdersTotal();
      for (ecnt=0;ecnt<total;ecnt++)
         {
            OrderSelect(ecnt,SELECT_BY_POS, MODE_TRADES);
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,Indigo);
         }
   }


