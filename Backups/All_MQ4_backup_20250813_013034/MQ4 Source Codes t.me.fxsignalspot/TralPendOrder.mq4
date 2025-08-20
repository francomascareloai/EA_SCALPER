//+------------------------------------------------------------------+
//|                                                TralPendOrder.mq4 |
//|                                                            SiLeM |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "SiLeM"
#property link      ""

//---- input parameters
extern int       MN=999;
extern int       LevMov=15;
extern int       LevTP=1;
extern bool      UseSound=true;
extern string NameFileSound    = "expert.wav"; // Наименование звукового файла
// тралир байстоп или селлстоп по указанного МН и на указанном расстоянии
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
  double pp, B, BB, S, SS;
  int    nd;
  for (int i=0; i<OrdersTotal(); i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==Symbol()) {
//        if (OrderStopLoss()==0) SetSL();
  if (OrderType()==OP_SELLSTOP && OrderMagicNumber()==MN) {
   if ((Bid-OrderOpenPrice()-(LevMov+LevTP)*Point)>0) //1.21-1.2080-10
     {
      B=Bid-LevMov*Point;
      
      Print("B=",B);
      if (B>BB){OrderModify(OrderTicket(),B,0,0,0,Blue);}
      if (B<=BB){BB=BB;}     }     }
      Print("B=",B,", BB=",BB);
  if (OrderType()==OP_BUYSTOP && OrderMagicNumber()==MN) {
   if ((OrderOpenPrice()-Ask-(LevMov+LevTP)*Point)>0)
     {
      S=Ask+LevMov*Point;
//      Print("S=",S);
      if (S>SS){OrderModify(OrderTicket(),S,0,0,0,Blue);}
      if (S<=SS){SS=SS;      }     }     }
//      Print("S=",S,", SS=",SS);
      }
    }
  }

   
//----
   return(0);
  }
//+------------------------------------------------------------------+