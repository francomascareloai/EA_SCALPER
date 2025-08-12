//+------------------------------------------------------------------+
//|                               Copyright © 2014, Хлыстов Владимир |
//|                                                cmillion@narod.ru |
//|                                                                  |
//--------------------------------------------------------------------
#property copyright "Copyright © 2014, Хлыстов Владимир"
#property link      "http://cmillion.ru/"
#property version     "600.0"
#property description "Советник открывает позицию в зависимости от закрытия прошлой позиции. Если позиции не было то в зависимости от направления прошлой свечи"
#property description "При достижение Т/P следующий ордер открывается в эту же сторону"
#property description "При достижение S/L следующий открывается в противоположную сторону"

 //--------------------------------------------------------------------
extern int    stoploss     = 100,
              takeprofit   = 100;
extern double risk         = 0.1; //процент от депозита для рассчета объема первой позиции
extern double KoeffMartin  = 2.0;
extern int    OkrLOT       = 2;//округление лота
extern int    slippage     = 3;//Максимально допустимое отклонение цены для рыночных ордеров
extern int    MagicNumb    = 77;//Magic

double MINLOT,MAXLOT;
//--------------------------------------------------------------------
int init()
{
   MAXLOT = MarketInfo(Symbol(),MODE_MAXLOT);
   MINLOT = MarketInfo(Symbol(),MODE_MINLOT);
   return(0);
}
//--------------------------------------------------------------------
int start()
{
   for (int i=0; i<OrdersTotal(); i++)
   {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumb)
         {
            return(0);
         }
      }
   }
   int tip=-1;
   double Lot=0;
   
   for (i=OrdersHistoryTotal()-1; i>=0; i--)
   {
      if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
      {
         if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumb)
         {
            if (OrderProfit()<0) 
            {
               Lot=lot(OrderLots(),KoeffMartin);
               tip=OrderType();
            }
            else tip=-1;
            break;
         }
      }
   }

   if (tip==-1)
   {
      Lot=lot(0,1);
      if (Open[1]>Close[1]) tip=OP_BUY;
      else tip=OP_SELL;
   }
   
   if (tip==OP_BUY) if (OrderSend(Symbol(),OP_SELL,Lot,NormalizeDouble(Bid,Digits),slippage,
                                    NormalizeDouble(Ask + stoploss*Point,Digits),
                                    NormalizeDouble(Bid - takeprofit*Point,Digits),NULL,MagicNumb,Blue)!=-1) Comment("Open Sell");
   if (tip==OP_SELL) if (OrderSend(Symbol(),OP_BUY ,Lot,NormalizeDouble(Ask,Digits),slippage,
                                    NormalizeDouble(Bid - stoploss*Point,Digits),
                                    NormalizeDouble(Ask + takeprofit*Point,Digits),NULL,MagicNumb,Blue)!=-1) Comment("Open Buy");
                                    
   return(0);
}
//--------------------------------------------------------------------
double lot(double l,double k)
{
   double ML = AccountFreeMargin()/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   if (k==1) l = ML*risk/100;
   else l = NormalizeDouble(l*k,OkrLOT);
   if (l>ML) l = ML;
   if (l>MAXLOT) l = MAXLOT;
   if (l<MINLOT) l = MINLOT;
   return(l);
}
//-----------------------------------------------------------------
