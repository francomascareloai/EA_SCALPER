//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 1999-2007, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
extern double TakeProfit=5;
extern double StopLoss=49;
extern double Lots=1.0;
extern double KoridorOC=10;
extern int Dow=5;
//+------------------------------------------------------------------+
//| Система по пятницам на переворот!                                |
//+------------------------------------------------------------------+
int start()
  {
   int cnt, ticket, total;
   double OpCl=0,ClOp=0,ClLo=0,HiCl=0,OpD=0;
   // on a chart of less than 100 bars
   if(Bars<100)
     {
      Print("bars less than 100");
      return(0);
     }
   if(TakeProfit<5)
     {
      Print("TakeProfit less than 5");
      return(0);  // check TakeProfit
     }
   total=OrdersTotal();
   // Закрываем ордера
   for(cnt=0;cnt<total;cnt++)
     {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if(OrderType()<=OP_SELL &&   // check for opened position 
         OrderSymbol()==Symbol())  // check for symbol
        {
         if(OrderType()==OP_BUY)   // long position is opened
           {
            // should it be closed?
            if(total>0 && Hour()==22 && Minute()>45)
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet); // close position
               return(0); // exit
              }
           }
         else // go to short position
           {
            // should it be closed?
            if(total>0 && Hour()==22 && Minute()>45)
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet); // close position
               return(0); // exit
              }
           }
        }
     } // Конец закрывания ордеров
   if(total<1)
     {
      OpCl=Open[24]-Close[1];
      ClOp=Close[1]-Open[24];
      ClLo=Close[1]-Low[Lowest(NULL,60,MODE_LOW,24,0)];
      HiCl=High[Highest(NULL,60,MODE_HIGH,24,0)]-Close[1];
      OpD=Open[0];
      //Lots=AccountFreeMargin()/(Ask*1000); // Торгуем на максимум лотов
      // no opened orders identified
      if(AccountFreeMargin()<(Ask*1000*Lots))
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);
        }
      // check for long position (BUY) possibility
      if(Hour()==0 && Minute()<=3 && DayOfWeek()==Dow && OpCl>KoridorOC*Point)
        {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,OpD,10,OpD-StopLoss*Point,OpD+(TakeProfit+3)*Point,"Sys",16384,0,LawnGreen);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("BUY order opened : ",OrderOpenPrice());
           }
         else Print("Error opening BUY order : ",GetLastError());
         return(0);
        }
      // check for short position (SELL) possibility
      if(Hour()==0 && Minute()<=3 && DayOfWeek()==Dow && ClOp>KoridorOC*Point)
        {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,OpD,10,OpD+StopLoss*Point,OpD-TakeProfit*Point,"Sys",16384,0,Red);
         if(ticket>0)
           {
            if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) Print("SELL order opened : ",OrderOpenPrice());
           }
         else Print("Error opening SELL order : ",GetLastError());
         return(0);
        }
      return(0);
     }
   return(0);
  }
// the end.
//+------------------------------------------------------------------+