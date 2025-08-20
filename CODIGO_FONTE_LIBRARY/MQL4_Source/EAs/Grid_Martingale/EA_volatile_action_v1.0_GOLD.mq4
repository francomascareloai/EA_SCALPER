//+------------------------------------------------------------------+
//|                                              Volatile action.mq4 |
//|                                                     Alexey Zykov |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Alexey Zykov"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input double        VolN=3;                  // Volatility coef.
input int           Magic=7101;              // Magic Number
input double        Risk=0;                  // Leverage
input double        Fix_Lot=0.01;            // Fix_Lot
input double        ns=0.6;                  // Coefloss
input double        np=1.0;                  // Coefprof
input int           ATR=23;                  // ATR
datetime ct;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int OpenOrd=0;
   bool static Error=true; // Flag fatal Error
   if(Error==false)
     {
      Comment("Fatal error, EA does not work!");
      return;
     }
//--- Orders 
   int OrderBuy=0,OrderSell=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)!=true)
         Error=Error();
      if(OrderType()==OP_BUY && OrderSymbol()==_Symbol && OrderMagicNumber()==Magic)
         OrderBuy++;
      if(OrderType()==OP_SELL && OrderSymbol()==_Symbol && OrderMagicNumber()==Magic)
         OrderSell++;
     }
   if(OrderBuy!=0 || OrderSell!=0)
     {
      if(OrderTakeProfit()==0 || OrderStopLoss()==0)
        {
         if(OrderMod(OrderBuy,OrderSell)!=true)
            Error=Error();
        }
      Comment("EA is supporting opened order(s)");
      return;
     }
   else
      Comment("EA is waiting for a signal for opening an order");

   if(SignalGator()==0)
      return;
   if(SignalGator()>0 && SignalVol()>0)
     {
      if(ct!=Time[0])
        {
         ct=Time[0];
         int Sign=1;
         OpenOrd=OpenOrder(Sign);
         if(OpenOrd<0)
            Error=Error();
        }
     }
   if(SignalGator()<0 && SignalVol()<0)
     {
      if(ct!=Time[0])
        {
         ct=Time[0];
         int Sign=-1;
         OpenOrd=OpenOrder(Sign);
         if(OpenOrd<0)
            Error=Error();
        }
     }
  }
//+------------------------------------------------------------------+
//|                   Function SignalVolatility                      | 
//+------------------------------------------------------------------+
int SignalVol()
  {
   int SignalVol=0; double Min=1000,Max=0;
   double Vol_140=iATR(_Symbol,PERIOD_CURRENT,ATR,1);
   double Vol_1=iATR(_Symbol,PERIOD_CURRENT,1,1);
   double HL=MathAbs(High[1]-Low[1]);
   double HC=MathAbs(High[1]-Close[1]);
   double LC=MathAbs(Low[1]-Close[1]);
   for(int i=20;i>0;i--)
     {
      if(Low[i]<=Min)
         Min=Low[i];
     }
   for(int i=24;i>0;i--)
     {
      if(High[i]>=Max)
         Max=High[i];
     }
//--- Buy position
   if(Vol_1>VolN*Vol_140 && Close[1]>Open[1] && Max==High[1] && 0.3*HL>=HC)
      SignalVol=1;
//--- Sell position
   if(Vol_1>VolN*Vol_140 && Close[1]<Open[1] && Min==Low[1] && 0.3*HL>LC)
      SignalVol=-1;
   return(SignalVol);
  }
//+------------------------------------------------------------------+
//|                   Function SignalGator                           | 
//+------------------------------------------------------------------+
int SignalGator()
  {
   int SignalGator=0;
   double Gator_Jaw=iAlligator(_Symbol,PERIOD_H4,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);             // Blue line Alligator
   double Gator_Teeth=iAlligator(_Symbol,PERIOD_H4,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);         // Red line Alligator
   double Gator_Lips=iAlligator(_Symbol,PERIOD_H4,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);           // Green line Alligator  
//--- Buy position
   if(Gator_Lips>Gator_Teeth && Gator_Lips>Gator_Jaw && Gator_Teeth>Gator_Jaw && iClose(_Symbol,PERIOD_H4,1)>Gator_Teeth && iOpen(_Symbol,PERIOD_H4,1)>Gator_Teeth)
      SignalGator=1;
//--- Sell position
   if(Gator_Lips<Gator_Teeth && Gator_Lips<Gator_Jaw && Gator_Teeth<Gator_Jaw && iClose(_Symbol,PERIOD_H4,1)<Gator_Teeth && iOpen(_Symbol,PERIOD_H4,1)<Gator_Teeth)
      SignalGator=-1;
   return(SignalGator);
  }
//+------------------------------------------------------------------+
//|                   Function Error                                 | 
//+------------------------------------------------------------------+
bool Error()
  {
   int Err=GetLastError();
   switch(Err)
     {
      //--- Avoidable error 
      case 0:   return (true);
      case 4:   Print("Error 4. Trade server is busy"); Sleep(180000); return (true);
      case 6:   Print("Error 6. No connection with trade server"); while(!IsConnected()) Sleep(5000); return (true);
      case 8:   Print("Error 8. Too frequent requests"); Sleep(10000);return (true);
      case 128: Print("Error 128. Trade timeout"); Sleep(60000); return (true);
      case 132: Print("Error 132. Market is closed"); Sleep(180000); return (true);
      case 135: Print("Error 135. Price changed"); return (true);
      case 136: Print("Error 136. Off quotes"); Sleep(5000); return (true);
      case 137: Print("Error 137. Broker is busy"); Sleep(10000); return (true);
      case 138: Print("Error 138. Requote"); return (true);
      case 139: Print("Error 139. Order is locked"); Sleep(60000); return (true);
      case 141: Print("Error 141. Too many requests"); Sleep(10000); return (true);
      case 142: Print("Error 142. The order is queued"); Sleep(60000); return (true);
      case 143: Print("Error 142. Order accepted by the dealer for execution"); Sleep(60000); return (true);
      case 145: Print("Error 145. Modification denied because order is too close to market"); Sleep(15000); return (true);
      case 146: Print("Error 146. Trade context is busy"); while(IsTradeContextBusy()==true) Sleep(500); return (true);
      //--- Fatal Error
      case 2:   Print("Error 2. Common error"); return (false);
      case 3:   Print("Error 3. Invalid trade parameters"); return (false);
      case 5:   Print("Error 5. Old version of the client terminal"); return (false);
      case 7:   Print("Error 7. Not enough rights"); return (false);
      case 64:  Print("Error 64. Account disabled"); return (false);
      case 65:  Print("Error 65. Invalid account"); return (false);
      case 129: Print("Error 129. Invalid price"); return (false);
      case 130: Print("Error 130. Invalid stops"); return (false);
      case 131: Print("Error 131. Invalid trade volume"); return (false);
      case 133: Print("Error 133. Trade is disabled"); return (false);
      case 134: Print("Error 134. Not enough money for trading"); return (false);
      case 140: Print("Error 140. Buy orders only allowed"); return (false);
      case 147: Print("Error 147. Expirations are denied by broker"); return (false);
      case 148: Print("Error 148. The amount of open and pending orders has reached the limit set by the broker"); return (false);
      case 149: Print("Error 149. An attempt to open an order opposite to the existing one when hedging is disabled"); return (false);
      case 150: Print("Error 150. An attempt to close an order contravening the FIFO rule"); return (false);
      default:  Print("Error ",Err); return (false);
     }
  }
//+---------------------------------------------------------------------+
//|                   Function OpenOrder                                |
//+---------------------------------------------------------------------+
int OpenOrder(int Sign)
  {
   int Order=0;
   color clr=clrBlack; int typeOrder=-1; double price=0, Lot=0.01;
   string comment="VolAct";
   switch(Sign)
     {
      case -1: typeOrder=OP_SELL;price=Bid;clr=clrRed;break; // Select the order type
      case  1: typeOrder=OP_BUY;price=Ask;clr=clrGreen;break;
     }

   if(Risk==0)
      Lot=Fix_Lot;
   else
      Lot=Risk*AccountFreeMargin()/100000; // Volume position 
   if(Lot<MarketInfo(_Symbol,MODE_MINLOT))
      Lot=MarketInfo(_Symbol,MODE_MINLOT);
   if(Lot>MarketInfo(_Symbol,MODE_MAXLOT))
      Lot=MarketInfo(_Symbol,MODE_MAXLOT);
   if(AccountFreeMargin()<Lot*MarketInfo(_Symbol,MODE_MARGINREQUIRED))
      Lot=AccountFreeMargin()/MarketInfo(_Symbol,MODE_MARGINREQUIRED);
   while(IsTradeAllowed()==false)
     {
      Comment("Trade context busy");
      Sleep(100);
     }
   RefreshRates();
   Order=OrderSend(_Symbol,typeOrder,NormalizeDouble(Lot,2),NormalizeDouble(price,_Digits),30,0,0,comment,Magic,0,clr); // Order send
   return(Order);
  }
//+------------------------------------------------------------------------+
//|                     Function OrderMod                                  |
//+------------------------------------------------------------------------+           
bool OrderMod(int ordbuy,int ordsell)
  {
   double TP=0,SL=0;
   double Vol_1=iATR(_Symbol,PERIOD_CURRENT,1,1);
   bool OrderMod=true;
   if(ordbuy>0)
     {
      TP=OrderOpenPrice()+np*NormalizeDouble(Vol_1,_Digits);
      SL=OrderOpenPrice()-ns*NormalizeDouble(Vol_1,_Digits);
      int Ticket=OrderTicket();
      OrderMod=OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrGreen);
     }
   if(ordsell>0)
     {
      TP=OrderOpenPrice()-np*NormalizeDouble(Vol_1,_Digits);
      SL=OrderOpenPrice()+ns*NormalizeDouble(Vol_1,_Digits);
      int Ticket=OrderTicket();
      OrderMod=OrderModify(Ticket,OrderOpenPrice(),SL,TP,0,clrRed);
     }
   return(OrderMod);
  }
//+------------------------------------------------------------------+
