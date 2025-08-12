//+------------------------------------------------------------------+
//|                                               SHE_Baluev_Pro.mq4 |
//|                                         Copyright � 2006, Shurka |
//|                                                 shforex@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006, Shurka"
#property link      "shforex@narod.ru"

//---- �������� (����������) ���������
extern string  Starttime="00:00";
extern string  Endtime="00:00";
extern bool    CloseOrdersAtEndTime=false;
extern int     SecundForModify=0;
extern int     NumOfOrders=5;
extern int     Per=50; //������ � �������, ����� ������� ������������� ���������� ������
extern int     Profit=100; //�������� �������
extern int     Stop=100;
extern int     TrailStop=100;
extern int     TrailStep=10;
extern int     BezubLevel=30;
extern int     BezubSize=1;
extern double  Lots=0.1;
extern string  Symb="*";
//---- ������ ��������������� ����������
int            i, MAGIC, BS[35], SS[35], bi, si;
double         SL, TP, UR, PNT, ASK, BID, STP, SPR, maxs, mins, maxb, minb, Lot;
string         SMB;
datetime       st,et,lt;

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
   MAGIC=291106+StringGetChar(SMB,0)+StringGetChar(SMB,1)*2+StringGetChar(SMB,3)*3+StringGetChar(SMB,4)*4;
   lt=0;
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
   st=StrToTime(Starttime);
   et=StrToTime(Endtime);
   if(st!=et && CurTime()<st) return(0);
   if(st!=et && CurTime()>=et)
   {
      for(i=OrdersTotal()-1;i>=0;i--) // �������� �� ���� ������������ �������-----------------------------------
      {
         OrderSelect(i, SELECT_BY_POS); // ���������� ��������� �����, ���� � ��� �������� ���
         if(OrderSymbol()!=SMB || OrderMagicNumber()!=MAGIC) continue; // ���� �� ��� - ������� ���������
         if(OrderType()>OP_SELL) OrderDelete(OrderTicket()); else
         if(OrderType()==OP_SELL && CloseOrdersAtEndTime) OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE); else
         if(OrderType()==OP_BUY && CloseOrdersAtEndTime) OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);
      }
      return(0);
   }
   Lot=GlobalVariableGet("SHI_Lots");
   if(Lot>0) Lots=Lot;
   bi=0; si=0; // �������������� ��������������� ����������
   ASK=MarketInfo(SMB,MODE_ASK);
   BID=MarketInfo(SMB,MODE_BID);
   maxs=0; minb=0;
   for(i=0;i<OrdersTotal();i++) // �������� �� ���� ������������ �������-----------------------------------
   {
      OrderSelect(i, SELECT_BY_POS); // ���������� ��������� �����, ���� � ��� �������� ���
      if(OrderSymbol()!=SMB || OrderMagicNumber()!=MAGIC) continue; // ���� �� ��� - ������� ���������
      
      if(OrderType()==OP_BUYSTOP)
      {
         BS[bi]=i; bi++;
         if(minb==0 || minb>OrderOpenPrice()) minb=OrderOpenPrice();
         if(maxb==0 || maxb<OrderOpenPrice()) maxb=OrderOpenPrice();
      }   else // ���� �� �������, �� � BS ���������� ��� �����
      if(OrderType()==OP_SELLSTOP)
      {
         SS[si]=i; si++;
         if(maxs==0 || maxs<OrderOpenPrice()) maxs=OrderOpenPrice();
         if(mins==0 || mins>OrderOpenPrice()) mins=OrderOpenPrice();
      }  else // ���� �� ��������, �� � SS ���������� ��� �����
      if(OrderType()==OP_BUY) // ���� �� �������� � �������, ��...
      {
         if(BezubLevel>0 && BID-OrderOpenPrice()>=BezubLevel && OrderStopLoss()<OrderOpenPrice())
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+BezubSize*PNT,OrderTakeProfit(),0,CLR_NONE);
         if(TrailStop>=STP && OrderStopLoss()<=BID-(TrailStop+TrailStep)*PNT && OrderOpenPrice()<=BID-(TrailStop+TrailStep)*PNT)
            OrderModify(OrderTicket(),OrderOpenPrice(),BID-TrailStop*PNT,OrderTakeProfit(),0,CLR_NONE);
         //  ����� ����� ��������� ����������� �������� �����
      } else // �����, ���� ��� �������� ����� � ������� �� �� ��� � � �������� �� ��������
      if(OrderType()==OP_SELL)
      {
         if(BezubLevel>0 && OrderOpenPrice()-ASK>=BezubLevel && OrderStopLoss()>OrderOpenPrice())
            OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-BezubSize*PNT,OrderTakeProfit(),0,CLR_NONE);
         if(TrailStop>=STP && OrderStopLoss()>=ASK+(TrailStop+TrailStep)*PNT && OrderOpenPrice()>=ASK+(TrailStop+TrailStep)*PNT)
            OrderModify(OrderTicket(),OrderOpenPrice(),ASK+TrailStop*PNT,OrderTakeProfit(),0,CLR_NONE);
      }
   } // ���� ��������, �� ����������� ��� ������. ������...------------------------------------------------
   // ����� ��������� ���������� ������ ����� �� ���������
   if(SecundForModify==0)
   {
      if(BID-Per*PNT>maxs && maxs!=0)
      {
         UR=BID-Per*PNT; mins=0;
         for(i=0;i<si;i++) // ���� ��� ������ ���� ���� ��������
         {
            if(Profit<STP-SPR || Profit==0) TP=0; else TP=UR-(Profit+i*Per)*PNT;
            if(Stop<STP+SPR) SL=0; else SL=UR+(Stop-i*Per)*PNT;
            OrderSelect(SS[i], SELECT_BY_POS); // ������� ���
            OrderModify(OrderTicket(),UR-i*Per*PNT,SL,TP,0,CLR_NONE);
            if(mins==0 || mins>UR) mins=UR;
         }
      } else
      if(ASK+Per*PNT<minb)
      {
         UR=ASK+Per*PNT; maxb=0;
         for(i=0;i<bi;i++)
         {
            if(Profit<STP-SPR || Profit==0) TP=0; else TP=UR+(Profit+i*Per)*PNT;
            if(Stop<STP+SPR) SL=0; else SL=UR-(Stop-i*Per)*PNT;
            OrderSelect(BS[i], SELECT_BY_POS);
            OrderModify(OrderTicket(),UR+i*Per*PNT,SL,TP,0,CLR_NONE);
            if(maxb==0 || maxb<UR) maxb=UR;
         }
      }
   } else if(TimeCurrent()-lt>SecundForModify)
   {
      lt=TimeCurrent();
      if(BID-Per*PNT!=maxs && maxs!=0)
      {
         UR=BID-Per*PNT; mins=0;
         for(i=0;i<si;i++) // ���� ��� ������ ���� ���� ��������
         {
            if(Profit<STP-SPR || Profit==0) TP=0; else TP=UR-(Profit+i*Per)*PNT;
            if(Stop<STP+SPR) SL=0; else SL=UR+(Stop-i*Per)*PNT;
            OrderSelect(SS[i], SELECT_BY_POS); // ������� ���
            OrderModify(OrderTicket(),UR-i*Per*PNT,SL,TP,0,CLR_NONE);
            if(mins==0 || mins>UR) mins=UR;
         }
      }
      if(ASK+Per*PNT!=minb && minb!=0)
      {
         UR=ASK+Per*PNT; maxb=0;
         for(i=0;i<bi;i++)
         {
            if(Profit<STP-SPR || Profit==0) TP=0; else TP=UR+(Profit+i*Per)*PNT;
            if(Stop<STP+SPR) SL=0; else SL=UR-(Stop-i*Per)*PNT;
            OrderSelect(BS[i], SELECT_BY_POS);
            OrderModify(OrderTicket(),UR+i*Per*PNT,SL,TP,0,CLR_NONE);
            if(maxb==0 || maxb<UR) maxb=UR;
         }
      }
   }
   if(mins>0) UR=mins-Per*PNT; else UR=BID-Per*PNT;
   for(i=0;i<NumOfOrders-si;i++)// ������ ����� �������� ����������� ���������� �� 10 (5 � 5)
   {
      if(Profit<STP-SPR || Profit==0) TP=0; else TP=UR-(Profit+i*Per)*PNT;
      if(Stop<STP+SPR) SL=0; else SL=UR+(Stop-i*Per)*PNT;
      OrderSend(SMB,OP_SELLSTOP,Lots,UR-i*Per*PNT,3,SL,TP,NULL,MAGIC,0,CLR_NONE);
   }
   // �� �� ����� ������ � � ����������� � �������.
   if(maxb>0) UR=maxb+Per*PNT; else UR=ASK+Per*PNT;
   for(i=0;i<NumOfOrders-bi;i++)
   {
      if(Profit<STP-SPR || Profit==0) TP=0; else TP=UR+(Profit+i*Per)*PNT;
      if(Stop<STP+SPR) SL=0; else SL=UR-(Stop-i*Per)*PNT;
      OrderSend(SMB,OP_BUYSTOP,Lots,UR+i*Per*PNT,3,SL,TP,NULL,MAGIC,0,CLR_NONE);
   }
   return(0);
}
//+------------------------------------------------------------------+
// ��� �� ����, ������, �����������, �� �����������.