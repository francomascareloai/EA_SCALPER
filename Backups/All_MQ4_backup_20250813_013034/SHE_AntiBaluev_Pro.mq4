//+------------------------------------------------------------------+
//|                                           SHE_AntiBaluev_Pro.mq4 |
//|                                         Copyright � 2006, Shurka |
//|                                                 shforex@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006, Shurka"
#property link      "shforex@narod.ru"
#define MAGIC 201206

//---- �������� (����������) ���������
extern int     NumOfOrders=5;
extern int     Per=50; //������ � �������, ����� ������� ������������� ���������� ������
extern int     Profit=100; //�������� �������
extern int     Stop=100;
extern int     TrailStop=100;
extern int     TrailStep=10;
extern double  Lots=0.1;
extern string  Symb="*";
//---- ������ ��������������� ����������
int            i, SL[55], BL[55], sli, bli;
double         sl, tp, UR, PNT, ASK, BID, STP, SPR, maxs, mins, maxb, minb, Lot;
string         SMB;

//+------------------------------------------------------------------+
//| ������� ������������� ��������                                   |
//| ����������� ���� ��� ��� ������������ ��������� � �������        |
//| ��� ��� ����� ���� ��� ����������                                |
//+------------------------------------------------------------------+
int init()
{
   if(Symb=="*") SMB=Symbol(); else SMB=Symb;
   PNT=MarketInfo(SMB,MODE_POINT);
   STP=MarketInfo(SMB,MODE_STOPLEVEL);
   SPR=MarketInfo(SMB,MODE_SPREAD);
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
   } else Comment("");
   Lot=GlobalVariableGet("SHI_Lots");
   if(Lot>0) Lots=Lot;
   sli=0; bli=0; // �������������� ��������������� ����������
   ASK=MarketInfo(SMB,MODE_ASK);
   BID=MarketInfo(SMB,MODE_BID);
   maxs=0; minb=0;
   for(i=0;i<OrdersTotal();i++) // �������� �� ���� ������������ �������-----------------------------------
   {
      OrderSelect(i, SELECT_BY_POS); // ���������� ��������� �����, ���� � ��� �������� ���
      if(OrderSymbol()!=SMB || OrderMagicNumber()!=MAGIC) continue; // ���� �� ��� - ������� ���������
      
      if(OrderType()==OP_SELLLIMIT)
      {
         SL[sli]=i; sli++;
         if(minb==0 || minb>OrderOpenPrice()) minb=OrderOpenPrice();
         if(maxb==0 || maxb<OrderOpenPrice()) maxb=OrderOpenPrice();
      }   else // ���� �� ��������, �� � SL ���������� ��� �����
      if(OrderType()==OP_BUYLIMIT)
      {
         BL[bli]=i; bli++;
         if(maxs==0 || maxs<OrderOpenPrice()) maxs=OrderOpenPrice();
         if(mins==0 || mins>OrderOpenPrice()) mins=OrderOpenPrice();
      }  else // ���� �� ��������, �� � BL ���������� ��� �����
      if(OrderType()==OP_BUY) // ���� �� �������� � �������, ��...
      {
         if(TrailStop>=STP && OrderStopLoss()<=BID-(TrailStop+TrailStep)*PNT && OrderOpenPrice()<=BID-(TrailStop+TrailStep)*PNT)
            OrderModify(OrderTicket(),OrderOpenPrice(),BID-TrailStop*PNT,OrderTakeProfit(),0,CLR_NONE);
         //  ����� ����� ��������� ����������� �������� �����
      } else // �����, ���� ��� �������� ����� � ������� �� �� ��� � � �������� �� ��������
      if(OrderType()==OP_SELL)
      {
         if(TrailStop>=STP && OrderStopLoss()>=ASK+(TrailStop+TrailStep)*PNT && OrderOpenPrice()>=ASK+(TrailStop+TrailStep)*PNT)
            OrderModify(OrderTicket(),OrderOpenPrice(),ASK+TrailStop*PNT,OrderTakeProfit(),0,CLR_NONE);
      }
   } // ���� ��������, �� ����������� ��� ������. ������...------------------------------------------------
   // ����� ��������� ���������� ������ ����� �� ���������
   if(BID-Per*PNT>maxs && maxs!=0)
   {
      UR=BID-Per*PNT; mins=0;
      for(i=0;i<bli;i++)
      {
         if(Profit<STP-SPR || Profit==0) tp=0; else tp=UR+(Profit+i*Per)*PNT;
         if(Stop<STP+SPR) sl=0; else sl=UR-(Stop-i*Per)*PNT;
         OrderSelect(BL[i], SELECT_BY_POS); // ������� ���
         OrderModify(OrderTicket(),UR-i*Per*PNT,sl,tp,0,CLR_NONE);
         if(mins==0 || mins>UR) mins=UR;
      }
   } else
   if(ASK+Per*PNT<minb)
   {
      UR=ASK+Per*PNT; maxb=0;
      for(i=0;i<sli;i++)
      {
         if(Profit<STP-SPR || Profit==0) tp=0; else tp=UR-(Profit+i*Per)*PNT;
         if(Stop<STP+SPR) sl=0; else sl=UR+(Stop-i*Per)*PNT;
         OrderSelect(SL[i], SELECT_BY_POS);
         OrderModify(OrderTicket(),UR+i*Per*PNT,sl,tp,0,CLR_NONE);
         if(maxb==0 || maxb<UR) maxb=UR;
      }
   }
   if(mins>0) UR=mins-Per*PNT; else UR=BID-Per*PNT;
   for(i=0;i<NumOfOrders-bli;i++)// ������ ����� �������� ����������� ���������� �� 10 (5 � 5)
   {
      if(Profit<STP-SPR || Profit==0) tp=0; else tp=UR+(Profit+i*Per)*PNT;
      if(Stop<STP+SPR) sl=0; else sl=UR-(Stop-i*Per)*PNT;
      OrderSend(SMB,OP_BUYLIMIT,Lots,UR-i*Per*PNT,3,sl,tp,NULL,MAGIC,0,CLR_NONE);
   }
   // �� �� ����� ������ � � ����������� � �������.
   if(maxb>0) UR=maxb+Per*PNT; else UR=ASK+Per*PNT;
   for(i=0;i<NumOfOrders-sli;i++)
   {
      if(Profit<STP-SPR || Profit==0) tp=0; else tp=UR-(Profit+i*Per)*PNT;
      if(Stop<STP+SPR) sl=0; else sl=UR+(Stop-i*Per)*PNT;
      OrderSend(SMB,OP_SELLLIMIT,Lots,UR+i*Per*PNT,3,sl,tp,NULL,MAGIC,0,CLR_NONE);
   }
   return(0);
}
//+------------------------------------------------------------------+
// ��� �� ����, ������, �����������, �� �����������.