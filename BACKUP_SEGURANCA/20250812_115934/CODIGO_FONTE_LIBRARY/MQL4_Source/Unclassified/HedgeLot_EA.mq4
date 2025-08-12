//+------------------------------------------------------------------+
//|                                                  HedgeLot_EA.mq4 |
//|                                     Copyright © 2009, metropolis |
//|                                           metropolisfx@yahoo.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, metropolis"
#property link      "metropolisfx@yahoo.com"

extern int  TP = 35;
extern int  SL = 70;
extern bool UseInstantOrder = true;
extern double InstantLot = 0.1;
extern double PendingLot = 0.3;
extern int LotDecimal = 1;//jumlah angka dibelakang koma
extern double LotMultiplicator = 2.0; // faktor pengali

#define Slippage 2
#define id1 12345
#define id2 67890

//global variables
static datetime lastB = -1;
static datetime lastS = -1;
static double nextLot;
static double levelBuy;
static double levelSell;
static bool firstRun;
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
Comment("\n", "     Broker Time         : ",TimeToStr(TimeCurrent()),"\n",
        "\n", "     Stop Level           : ",MarketInfo(Symbol(),MODE_STOPLEVEL),
        "\n", "     Equity                : ",AccountEquity(),
        "\n", "     Balance              : ",AccountBalance(),
        "\n", "     Next Lot OP        : ",nextLot,
        "\n", "     Orders Total        : ",OrdersTotal(),"\n",
        "\n", "     HedgeLot_EA Copyright © 2009, metropolis - metropolisfx@yahoo.com"); 
         
if(!IsTradeAllowed())
{ 
   Print("Server tidak mengizinkan trade");
   Sleep(5000);
   return(0);
}
if(IsTradeContextBusy())
{ 
   Print("Trade context is busy. Tunggu sebentar");
   Sleep(5000);
   return(0);
}
if(!IsConnected())
{ 
   Print("Nggak ada koneksi untuk order dari EA ke server");
   Sleep(5000);
   return(0);
}
if(MarketInfo(Symbol(),MODE_STOPLEVEL)>TP || MarketInfo(Symbol(),MODE_STOPLEVEL)>SL)
{
   Print("Stop Level lebih besar dari pada SL atau TP");
   return(0);
}  

if(!firstRun)
{       
   for (int i=OrdersHistoryTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_HISTORY);
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==id2 && OrderProfit()>0 )
      {
         if(OrderType()==OP_SELL && OrderOpenTime()==lastS) 
         {  
            deleteAll(OP_BUYSTOP);
            lastS = -1;
            Sleep(5000);
         }
           
         if(OrderType()==OP_BUY && OrderOpenTime()==lastB) 
         {  
            deleteAll(OP_SELLSTOP);  
            lastB = -1;
            Sleep(5000);
         }
      }
   }         
}

manageTrade();

if(OrdersTotal()==0) firstRun();

   
//----
   return(0);
  }
//+------------------------------------------------------------------+

double p()
{
   double p;
   if(Digits==5 || Digits==3) p = 10*(MarketInfo(Symbol(),MODE_POINT));
   else p = MarketInfo(Symbol(),MODE_POINT);
   return (p);
}  

void openOrder(string simbol, int trade, double lotsize, double price, double sl, double tp,string pesan, int magic, color warna) 
{                     
   int tiket=OrderSend(simbol,trade,lotsize,price,Slippage,sl,tp,pesan,magic,0,warna);                              
   if(tiket>0)
   {  
        if(OrderSelect(tiket,SELECT_BY_TICKET,MODE_TRADES)) OrderPrint(); 
   }
   else Print("Tidak bisa buka order karena : ",GetLastError());        
}

void firstRun()
{//

   RefreshRates();
   int spread = MarketInfo(Symbol(),MODE_SPREAD);

   //buy
   double buyTP = Ask+(TP-spread)*p();
   double buySL = Bid-SL*p();
   if(UseInstantOrder) openOrder(Symbol(),OP_BUY,InstantLot,Ask,buySL,buyTP,"buy awal",id1,Blue);
   levelBuy = Ask;
   
   //sell
   double sellTP = Bid-(TP-spread)*p();
   double sellSL = Ask+SL*p();
   if(UseInstantOrder) openOrder(Symbol(),OP_SELL,InstantLot,Bid,sellSL,sellTP,"sell awal",id1,Red);
   levelSell = Bid;
   
   //buystop
   openOrder(Symbol(),OP_BUYSTOP,PendingLot,buyTP+spread*p(),levelSell,buyTP+TP*p(),"buy lanjut",id2,Blue);
   
   //sellstop
   openOrder(Symbol(),OP_SELLSTOP,PendingLot,sellTP-spread*p(),levelBuy,sellTP-TP*p(),"sell lanjut",id2,Red);
   
   nextLot = NormalizeDouble(PendingLot*LotMultiplicator,LotDecimal);
   firstRun = true;
}

void manageTrade()
{
   int i;
   int spread = MarketInfo(Symbol(),MODE_SPREAD);
   bool NewBuyExist = false;
   bool NewSellExist = false;
   
   for (i=OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==id2 && OrderType()==OP_BUY)
         {
            if(lastB < OrderOpenTime())
            {
               lastB = OrderOpenTime();
               levelBuy = OrderOpenPrice();
               NewBuyExist = true;
               break;
            }  
         }
      }
   }
      
   if(NewBuyExist)
   {
      if(firstRun)
      {
         for(i=0;i<OrdersTotal();i++)
         {
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==id2 && OrderType()==OP_SELLSTOP)
            {
               OrderDelete(OrderTicket());
               firstRun = false;
            }  
         }
      }
      
      if(!firstRun) 
      {
         double sellTP = levelSell-(TP-spread)*p();
         double sellSL = levelSell+SL*p();
         openOrder(Symbol(),OP_SELLSTOP,nextLot,levelSell,sellSL,sellTP,"sell lanjut",id2,Red);
         nextLot = NormalizeDouble(LotMultiplicator*nextLot,LotDecimal);
         NewBuyExist = false;
         return(0);
      } 
   
   }
   
   for (i=OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==id2 && OrderType()==OP_SELL)
         {
            if(lastS < OrderOpenTime())
            {
               lastS = OrderOpenTime(); 
               levelSell = OrderOpenPrice();
               NewSellExist = true;
               break;
            }  
         }
      }
   }   
   
   if(NewSellExist)
   {
      if(firstRun)
      {
         for(i=0;i<OrdersTotal();i++)
         {
            OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==id2 && OrderType()==OP_BUYSTOP)
            {
               OrderDelete(OrderTicket());
               firstRun = false;
            }  
         }
      }
      
      if(!firstRun) 
      {
         double buyTP = levelBuy+(TP-spread)*p();
         double buySL = levelBuy-SL*p();
         openOrder(Symbol(),OP_BUYSTOP,nextLot,levelBuy,buySL,buyTP,"buy lanjut",id2,Blue);
         nextLot = NormalizeDouble(LotMultiplicator*nextLot,LotDecimal);
         NewSellExist = false;
         return(0);
      } 
   }

//---

}//


void deleteAll( int trade)
{
   int i;
   
   for (i=0;i<OrdersTotal();i++)
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if(OrderSymbol()==Symbol() && OrderMagicNumber()==id2)
   {
      if(OrderType()==trade) OrderDelete(OrderTicket());
   }
}


