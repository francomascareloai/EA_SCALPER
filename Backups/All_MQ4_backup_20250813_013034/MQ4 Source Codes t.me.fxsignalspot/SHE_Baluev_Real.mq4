//+------------------------------------------------------------------+
//|                                              SHE_Baluev_Real.mq4 |
//|                                         Copyright � 2006, Shurka |
//|                                                 shforex@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006, Shurka"
#property link      "shforex@narod.ru"
#define MAGIC 130106

//---- �������� (����������) ���������
extern int     Per=50; //������ � �������, ����� ������� ������������� ���������� ������
extern int     Profit=100; //�������� �������
extern int     Stop=100; //�������� ���������, ��� �� ��������
extern int     StepTrail=10;
extern double  Lots=0.1;
extern string  Symb="*";
//---- ������ ��������������� ����������
int    i, BS[5], SS[5], bi, si, B;
double SL, TP, UR, PNT, ASK, BID;
string SMB;

//+------------------------------------------------------------------+
//| ������� ������������� ��������                                   |
//| ����������� ���� ��� ��� ������������ ��������� � �������        |
//| ��� ��� ����� ���� ��� ����������                                |
//+------------------------------------------------------------------+
int init()
{
   if(Symb=="*") SMB=Symbol(); else SMB=Symb;
   PNT=MarketInfo(SMB,MODE_POINT);
   return(0);
}
//+------------------------------------------------------------------+
//| ������� ��������������� ��������                                 |
//| ��� ������ �� ������. ����������� ��� ���������� ���������       |
//+------------------------------------------------------------------+
int deinit() {   return(0); }
//+------------------------------------------------------------------+
//| ������ ��� ��������                                              |
//+------------------------------------------------------------------+
int start()
{
   if(!IsTradeAllowed())
   {
      Comment("�������� �� ����� ����������� ��������� ��� �������� ����� �����."); return(0);
   } else Comment("                                                                    ");
   bi=0; si=0; B=0; // �������������� ��������������� ����������
   SL=MarketInfo(SMB,MODE_ASK);
   ASK=MarketInfo(SMB,MODE_ASK);
   BID=MarketInfo(SMB,MODE_BID);
   for(i=0;i<OrdersTotal();i++) // �������� �� ���� ������������ �������-----------------------------------
   {
      OrderSelect(i, SELECT_BY_POS); // ���������� ��������� �����, ���� � ��� �������� ���
      if(OrderSymbol()!=SMB || OrderMagicNumber()!=MAGIC) continue; // ���� �� ��� - ������� ���������
      
      if(OrderType()==OP_BUYSTOP) {BS[bi]=i;bi++;}   else // ���� �� �������, �� � BS ���������� ��� �����
      if(OrderType()==OP_SELLSTOP) {SS[si]=i;si++;}  else // ���� �� ��������, �� � SS ���������� ��� �����
      if(OrderType()==OP_BUY) // ���� �� �������� � �������, ��...
      {
         B=1; // ��������, ��� ��� ����� �������� � �������.
         if(OrderStopLoss()<BID-(Stop+StepTrail)*PNT) // ����������� ���� ���� ������� ������
            OrderModify(OrderTicket(),OrderOpenPrice(),BID-Stop*PNT,OrderTakeProfit(),0,CLR_NONE);
         if( SL>OrderStopLoss()) SL=OrderStopLoss(); // � SL ���������� ������� ���������,
         //  ����� ����� ��������� ����������� �������� �����
      } else // �����, ���� ��� �������� ����� � ������� �� �� ��� � � �������� �� ��������
      if(OrderType()==OP_SELL)
      {
         B=-1; // ��������, ��� ��� ����� �������� � �������.
         if(OrderStopLoss()>ASK+(Stop+StepTrail)*PNT)
            OrderModify(OrderTicket(),OrderOpenPrice(),ASK+Stop*PNT,OrderTakeProfit(),0,CLR_NONE);
         if( SL<OrderStopLoss()) SL=OrderStopLoss();
      }
   } // ���� ��������, �� ����������� ��� ������. ������...------------------------------------------------
   // ����� ��������� ���������� ������ ����� �� ���������
   if(B==1) // ���� ����� ��� ��� ���� ���� �������� � �������, � �� ������ ����, �� ����� ����
            // ������������ ������� ������ � � ������� � � �������, ������ � ���� �������.
            // ���������� ����������� ������ ����� ��������� ������ ����� ����.
   {
      for(i=0;i<si;i++) // ���� ��� ������ ���� ���� ��������
      {
         if(Profit==0) TP=0; else TP=SL-(Profit+i*Per)*PNT;
         OrderSelect(SS[i], SELECT_BY_POS); // ������� ���
         OrderModify(OrderTicket(),SL-i*Per*PNT,SL+(Stop-i*Per)*PNT,TP,0,CLR_NONE); // �������� �� �������
         // ����������� ��������� ��� ��� �������
      }
   } else // �����, ���� ��� ��� �������, �� ���� ���� ������, �� ��� �� ���� ����
   if(B==-1)
   {
      for(i=0;i<bi;i++)
      {
         if(Profit==0) TP=0; else TP=SL+(Profit+i*Per)*PNT;
         OrderSelect(BS[i], SELECT_BY_POS);
         OrderModify(OrderTicket(),SL+i*Per*PNT,SL+(i*Per-Stop)*PNT,TP,0,CLR_NONE);
      }
   }// ��������� � ������������ ������ �������� ������������ ���������� ������� �� ������� ������
   // �������� �������-------------------------------------------------------------------------------------
   // � ���������� UR ���������� ������� ��� ���������� ����������� SellStop ������.
   // �����, ����� ���������� � ������� � ������� �� ������������ �������, ������� ���� ������� �����
   // ������ ��� 2 �������, �� ������ ���������� ������ ������ ���� �� �� ���������� Per ����� � ����
   // �� ������� ����, � �� ���������� Stop ���� �� �����, �.� �������� Stop �� ����.
   if(Stop>2*Per) UR=BID-(Stop/2)*PNT;
   else UR=BID-Per*PNT;
   for(i=0;i<si;i++) // ��������� �� ���� ������������ ���������� � ������� � �������� UR ����
                     // �� ������ �������.
   {
      OrderSelect(SS[i], SELECT_BY_POS); // ������� ���
      if(UR>OrderOpenPrice()) UR=OrderOpenPrice();
   }
   if(si>0) UR-=Per*PNT;
   for(i=si;i<5;i++)// ������ ����� �������� ����������� ���������� �� 10 (5 � 5)
   {
      if(Profit==0) TP=0; else TP=UR-(Profit+(i-si)*Per)*PNT;
      OrderSend(SMB,OP_SELLSTOP,Lots,UR-(i-si)*Per*PNT,3,UR+(Stop-(i-si)*Per)*PNT,TP,NULL,MAGIC,0,CLR_NONE);
   }
   // �� �� ����� ������ � � ����������� � �������.
   if(Stop>2*Per) UR=ASK+(Stop/2)*PNT;
   else UR=ASK+Per*PNT;
   for(i=0;i<bi;i++)
   {
      OrderSelect(BS[i], SELECT_BY_POS); // ������� ���
      if(UR<OrderOpenPrice()) UR=OrderOpenPrice();
   }
   if(bi>0) UR+=Per*PNT;
   for(i=bi;i<5;i++)
   {
      if(Profit==0) TP=0; else TP=UR+(Profit+(i-bi)*Per)*PNT;
      OrderSend(SMB,OP_BUYSTOP,Lots,UR+(i-bi)*Per*PNT,3,UR+((i-bi)*Per-Stop)*PNT,TP,NULL,MAGIC,0,CLR_NONE);
   }
   return(0);
}
//+------------------------------------------------------------------+
// ��� �� ����, ������, �����������, �� �����������.