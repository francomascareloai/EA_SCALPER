//+------------------------------------------------------------------+
//|                                                         new5.mq4 |
//+------------------------------------------------------------------+
#property copyright "maloma"

extern int ЧасСтарта=19;
extern int ЧасСтопа=8;
extern double РазмерЛота=0.1;
extern double ЖелаемыйПрофит=5;

bool time4enter()
{
 if((Hour()>=ЧасСтарта && Hour()<=23) || (Hour()>=0 && Hour()<=ЧасСтопа)) return(true); else return(false);
}

int start
{
 int j=OrdersTotal();
 int LastOrder=
 for (int i=j;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
  }
 return(0);
}

//+------------------------------------------------------------------+