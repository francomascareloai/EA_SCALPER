//+------------------------------------------------------------------+
//|                                                         new5.mq4 |
//+------------------------------------------------------------------+
#property copyright "maloma"

extern int ���������=19;
extern int ��������=8;
extern double ����������=0.1;
extern double ��������������=5;

bool time4enter()
{
 if((Hour()>=��������� && Hour()<=23) || (Hour()>=0 && Hour()<=��������)) return(true); else return(false);
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