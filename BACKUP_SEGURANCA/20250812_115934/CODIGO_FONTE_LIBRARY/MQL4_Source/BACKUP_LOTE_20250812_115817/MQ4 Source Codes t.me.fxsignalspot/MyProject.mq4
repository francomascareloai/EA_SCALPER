//+------------------------------------------------------------------+
//|                                                   OtlojOrder.mq4 |
//|                                                        Rene Kard |
//|                                           http://www.nazirov.com |
//+------------------------------------------------------------------+
#property copyright "Rene Kard"
#property link      "http://www.nazirov.com"

int    PipsCount;         // ���������� ������ �� Open
int    BarsCount;         // ���������� �����, ��� ���������� ������������ �������
int    TakeProfit;        // ������������� ����� � ������
int    StopLoss;          // ���������� ������ �� ������
int    SlipPage;          // ������������ ���������� ���� ��� �������� ������
int    MagicNumber;       // ���������� ����� ���������
int    LotsCount;
int    I;

int MyPendingLevel;


int init()
  {
      BarsCount  = Bars;
      LotsCount  = 1;
      StopLoss   = 10;
      TakeProfit = 20; 
      SlipPage   = 5;
      
      PipsCount  = 20;
       
      MagicNumber = 7; 
      return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
      if ( Bars != BarsCount) 
      {
         if ( Ask - Open[0] > 0 )
         {
            if ( MathAbs(Ask - Open[0])/Point > PipsCount  )
            {
               I = OrderSend(Symbol(),OP_SELLSTOP,LotsCount,Open[0]-PipsCount*Point,SlipPage,Open[0]+Point*StopLoss-PipsCount*Point,Open[0]-Point*TakeProfit-PipsCount*Point,"����� Buy ���������",MagicNumber,TimeCurrent()+86400,Blue);
               BarsCount = Bars;
            }
         }
         else
            if ( Ask - Open[0] < 0 )
               if ( MathAbs(Ask - Open[0])/Point > PipsCount ) 
               {
                   I = OrderSend(Symbol(),OP_BUYSTOP,LotsCount,Open[0]+20*Point,SlipPage,Open[0]-Point*StopLoss+PipsCount*Point,Open[0]+Point*TakeProfit+PipsCount*Point,"����� Buy ���������",MagicNumber,TimeCurrent()+86400,Blue);
                   BarsCount = Bars;
               }
      }
      
      return(0);
  }