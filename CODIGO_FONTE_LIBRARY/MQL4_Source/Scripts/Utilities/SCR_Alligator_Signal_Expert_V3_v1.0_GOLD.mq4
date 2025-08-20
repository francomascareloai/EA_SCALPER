//+------------------------------------------------------------------+
//|                                      Alligator_Signal_Expert.mq4 |
//|                                                              AVM |
//+------------------------------------------------------------------+
#property copyright "AVM"
#property link      ""
extern string rem1="��������� ��������";
extern int P_MA_1=13;
extern int P_MA_2=8;
extern int P_MA_3=5;
extern string rem2="����������� ��������";
extern int Delta=3;
extern string rem3="�������� ���������";
extern double Lot=1;
extern string rem34="��� ��������� �������� �� 10";
extern int StopLoss=50;
extern int TakeProfit=50;
extern string rem33="������� ��������� � ��";
extern int Level_NoLoss=30;
extern string rem4="����� 0-������� ���, 1-�������� ����������";
extern int Shift_Indik=1;
extern int Shift_open=0;
extern string rem5="����� ������";
extern int Magik=112233;
bool   Label_B=true,                    // ����� �������� ������ Buy
       Label_S=true;                    // ����� �������� ������ Sell
bool   Label_Modify=true;
int Lot_Close[];


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   bool
   Ans,
   Cls_B=false,                     // �������� ��� ��������  Buy
   Cls_S=false,                     // �������� ��� ��������  Sell
   Opn_B=false,                     // �������� ��� ��������  Buy
   Opn_S=false;                     // �������� ��� ��������  Sell
   int Total=0;                                    // ���������� ������� 
   int Ticket[5];
   double SL = StopLoss;
   double TP = TakeProfit;
   for(int i=1; i<=OrdersTotal(); i++)          // ���� �������� �����
     {
      if (OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES)==true) // ���� ���� ���������
        {                                       // ������ �������:
          if (OrderSymbol()!=Symbol())continue;      // �� ��� ���. �������
          if (OrderMagicNumber()!=Magik)continue;  
           ArrayResize(Ticket,Total+1);
           ArrayResize(Lot_Close,Total+1);
          Ticket[Total]=OrderTicket();
          Lot_Close[Total]=OrderLots();
          Total++;                               // ������� ���������� �������
//         if (Total>2)                           // �� ����� ���� ���
//           {
//            return;                             // ����� �� start()
//           }
        }
     }
     int    Error=GetLastError();
   double MA_1=iMA(NULL,0,P_MA_1,0,MODE_SMMA,PRICE_MEDIAN,Shift_Indik);
   double MA_2=iMA(NULL,0,P_MA_2,0,MODE_SMMA,PRICE_MEDIAN,Shift_Indik);
   double MA_3=iMA(NULL,0,P_MA_3,0,MODE_SMMA,PRICE_MEDIAN,Shift_Indik);  
 //  ---------------------------------------------------------------------------�������� ��������
   if (MA_3 > MA_2+Delta*Point && MA_2 > MA_1+Delta*Point  )  
     {  
       Opn_B=true; 
       Cls_S=true; 
     }
   if (MA_1 > MA_2+Delta*Point && MA_2 > MA_3+Delta*Point  )  
    { 
      Opn_S=true; 
      Cls_B=true; 
    }
 //--------------------------------------------------------------------------- ���� ����� � �������, ��������� � ���������
  for (i=0; i<Total; i++)
  {
   if (Label_Modify == true 
       && OrderSelect(Ticket[i],SELECT_BY_TICKET) == true 
       && OrderProfit() > 0 
       && MathAbs(iClose(NULL,0,0)-OrderOpenPrice()) > Level_NoLoss*Point  ) 
    {
    OrderModify(Ticket[i],OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0);
    Label_Modify=false;
    }
  }
//-------------------------------------------------- ���� ���� ��������������� ������, ��������� ���.

  for (i=0; i < Total; i++)
  {
    if (Cls_B==true)
       if ( OrderSelect(Ticket[i],SELECT_BY_TICKET) == true && OrderType()==0 )
          { OrderClose(Ticket[i],Lot,Bid,2); }
    if (Cls_S==true)
      if ( OrderSelect(Ticket[i],SELECT_BY_TICKET) == true && OrderType()==1)
         {  OrderClose(Ticket[i],Lot,Ask,2); }
 }

 //------------------------------------- �������� �������
if ( Total==0 && Opn_B==true && Label_B==true  && iClose(NULL,0,Shift_open) < MA_2 )
  {
   if (StopLoss !=0)    SL = Bid-StopLoss*Point;
   if (TakeProfit !=0)  TP = Bid+TakeProfit*Point;
   Ticket[1]=OrderSend(Symbol(),OP_BUY,Lot,Ask,2,SL,TP,"������ MA",Magik);
   Label_Modify = true;
  } 
if ( Total==1 && Opn_B==true && Label_B==true && iClose(NULL,0,Shift_open) < MA_1 )
  { 
   if (StopLoss !=0)    SL = Bid-StopLoss*Point;
   if (TakeProfit !=0)  TP = Bid+TakeProfit*Point;
   Ticket[2]=OrderSend(Symbol(),OP_BUY,Lot,Ask,2,SL,TP,"������� MA",Magik);
   Label_B=false;
   Label_S=true;
   Label_Modify = true;
  }

if ( Total==0 && Opn_S==true && Label_S==true  && iClose(NULL,0,Shift_open) > MA_2 )
  {
    if (StopLoss !=0)    SL = Ask+StopLoss*Point;
    if (TakeProfit !=0)  TP = Ask-TakeProfit*Point;
    Ticket[1]=OrderSend(Symbol(),OP_SELL,Lot,Bid,2,SL,TP,"������ MA",Magik);
    Label_Modify = true;
  }
if ( Total==1 && Opn_S==true && Label_S==true &&  iClose(NULL,0,Shift_open) > MA_1 )
  {
    if (StopLoss !=0)    SL = Ask+StopLoss*Point;   else SL=0;
    if (TakeProfit !=0)  TP = Ask-TakeProfit*Point; else TP=0;
   Ticket[2]=OrderSend(Symbol(),OP_SELL,Lot,Bid,2,SL,TP,"������� MA",Magik);
   Label_S=false;
   Label_B=true;
   Label_Modify = true;
  }
//----


 Fun_Error(Error);
return(0);
}
//+------------------------------------------------------------------+

int Fun_Error(int Error)                        // �-�� ������� ������
  {
   switch(Error)
     {                                          // ����������� ������   
      case  0:    return(0);         
    //  case  4105: return(0);  
      case  4: Alert("�������� ������ �����. ������� ��� ���..");
         Sleep(3000);                           // ������� �������
         return(1);                             // ����� �� �������
      case 135:Alert("���� ����������. ������� ��� ���..");
         RefreshRates();                        // ������� ������
         return(1);                             // ����� �� �������
      case 136:Alert("��� ���. ��� ����� ���..");
         while(RefreshRates()==false)           // �� ������ ����
            Sleep(1);                           // �������� � �����
         return(1);                             // ����� �� �������
      case 137:Alert("������ �����. ������� ��� ���..");
         Sleep(3000);                           // ������� �������
         return(1);                             // ����� �� �������
      case 146:Alert("���������� �������� ������. ������� ���..");
         Sleep(500);                            // ������� �������
         return(1);                             // ����� �� �������
         // ����������� ������
      case  2: Alert("����� ������.");
         return(0);                             // ����� �� �������
      case 133:Alert("�������� ���������.");
         return(0);                             // ����� �� �������
      case 134:Alert("������������ ����� ��� ���������� ��������.");
         return(0);                             // ����� �� �������
      default: Alert("�������� ������ ",Error); // ������ ��������   
         return(0);                             // ����� �� �������
     }
  }
//-------------------------------------------------------------- 11 --


