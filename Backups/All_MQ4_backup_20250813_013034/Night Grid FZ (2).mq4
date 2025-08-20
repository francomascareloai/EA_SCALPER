//+------------------------------------------------------------------+
//|                                                Night Grid FZ.mq4 |
//|                                                     forexzona.ru |
//|                                              http://forexzona.ru |
//+------------------------------------------------------------------+
#property copyright "forexzona.ru"
#property link      "http://forexzona.ru"
//-----------------------���������------------------------------------+
extern double   Risk          =0.5;       //���� � ��������� �� ��������
extern double   MaxRisk       =3;         //������������ ���� (���� ������������� ����������)
extern int      TakeProfit    =10;        //���� ������
extern double   StopMinus     =10;        //���� � ��������� �� �������
extern double   UpLot         =1.2;       //������� ���������� ���� 
extern int      Step          =10;        //��� �����  
extern int      MaxOrders     =30;        //������������ ���������� ������� � �����  
extern int      TimeStart     =0;         //����� ������ ������
extern int      TimeEnd       =9;         //����� ���������� ������
extern int      Magic         =7777;      //������ �������
//--------------------------------------------------------------------+
string          CommentEA     ="Night Grid FZ";
double   OpPric        =0;
int D,x,y,i;
string Name;
int tframe[]={1,5,15,30,60,240,1440};
bool Buy,Sell;
int Ticket;
double NewTP,NewSL;
int init()
  {
   D=1;
   if (Digits==5 || Digits==3)D=10;
   Name=WindowExpertName();
   return(0);
  }
//--------------------------------------------------------------------+
int start()
{

double Lot=0;
Lot=NormalizeDouble(AccountBalance()/100*Risk/(MarketInfo(Symbol(),MODE_TICKVALUE)*100*D),2);
if (Lot<MarketInfo(Symbol(),MODE_MINLOT))Lot=MarketInfo(Symbol(),MODE_MINLOT);

double MaxLot=0;
MaxLot=NormalizeDouble(AccountBalance()/100*MaxRisk/(MarketInfo(Symbol(),MODE_TICKVALUE)*100*D),2);
if (MaxLot<MarketInfo(Symbol(),MODE_MINLOT))MaxLot=MarketInfo(Symbol(),MODE_MINLOT);

if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.01) int dig =2;
if(MarketInfo(Symbol(),MODE_LOTSTEP)==0.10)     dig =1;
if(MarketInfo(Symbol(),MODE_LOTSTEP)==1.00)     dig =0;
//--------------------------------------------------------------------+
   int OB,OS;
   double PipBuy,PipSell;
   for (i=0; i<OrdersTotal(); i++)
        {
         bool sel1=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if (OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
            {
             if (OrderType()==0){OB++;PipBuy=Bid-OrderOpenPrice();}
             if (OrderType()==1){OS++;PipSell=OrderOpenPrice()-Ask;}
            }
        }
//--------------------------------------------------------------------+        
 Buy=false;Sell=false;
 if (Open[1]<Close[1] && Open[2]<Close[2] && Open[3]>Close[3] && Open[4]>Close[4] && Open[5]>Close[5])Buy=true;
 if (Open[1]>Close[1] && Open[2]>Close[2] && Open[3]<Close[3] && Open[4]<Close[4] && Open[5]<Close[5])Sell=true;
 
double NLot=Lot*(MathPow(UpLot,OB+OS));
if(NLot>=MaxLot){double NewLot=MaxLot;}
if(NLot<MaxLot){NewLot=NLot;}
//--------------------------------------------------------------------+
if(TimeHour(TimeCurrent())>=TimeStart && TimeHour(TimeCurrent())<TimeEnd)
{ 
 if (OB+OS==0)
      {
       if (Buy)Ticket=OpenOrder(Symbol(),OP_BUY,Lot,NormalizeDouble(Ask,Digits),0,NormalizeDouble(Ask+TakeProfit*D*Point,Digits),CommentEA,Magic);
       if (Sell)Ticket=OpenOrder(Symbol(),OP_SELL,Lot,NormalizeDouble(Bid,Digits),0,NormalizeDouble(Bid-TakeProfit*D*Point,Digits),CommentEA,Magic);
      }}
//--------------------------------------------------------------------+
double lots=0;
   double sum=0;
   for (i=0; i<OrdersTotal(); i++)
   {if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) break;
      if (OrderSymbol()!=Symbol()) continue;
      if (OrderType()==OP_BUY)
      {lots=lots+OrderLots();
         sum=sum+OrderLots()*OrderOpenPrice();}
      if (OrderType()==OP_SELL)
      {lots=lots-OrderLots();
      sum=sum-OrderLots()*OrderOpenPrice();}}
      
double price=0;
   if (lots!=0) price=sum/lots;
   if (price>0) OpPric=NormalizeDouble(price,Digits);
//--------------------------------------------------------------------+
  if (OB>0 && OB<MaxOrders && PipBuy/D/Point<=-Step)
   {OpenOrder(Symbol(),OP_BUY,NewLot,NormalizeDouble(Ask,Digits),0,0,CommentEA,Magic);
    OB++;
    NewTP=OpPric+TakeProfit*D*Point;
    for (i=0; i<OrdersTotal(); i++)
        {bool sel2=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if (OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()==0)
            {ModifyOrder(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NewTP);}}
   }
//--------------------------------------------------------------------+
 if (OS>0 && OS<MaxOrders && PipSell/D/Point<=-Step)
   {OpenOrder(Symbol(),OP_SELL,NewLot,NormalizeDouble(Bid,Digits),0,0,CommentEA,Magic);
    OS++;
    NewTP=OpPric-TakeProfit*D*Point;
    
    for (i=0; i<OrdersTotal(); i++)
        {bool sel3=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
         if (OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()==1)
            {ModifyOrder(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),NewTP);}}
   }
//--------------------------------------------------------------------+
double S_Max=(AccountBalance()/100)*StopMinus*(-1);

if(OB+OS>0 && Profit(-1)<S_Max && S_Max!=0)
{CloserB();
 CloserS();}
//--------------------------------------------------------------------+
//--------------------------------------------------------------------+
//--------------------------------------------------------------------+
   return(0);
  }
//--------------------------------------------------------------------+
int OpenOrder(string symbol,int cmd,double volume,double price,double stoploss,double takeprofit,string comment,int magic)
             {
              int err,i1,ticket;
              while(i1<10)
                   {
                    RefreshRates();
                    if (cmd==0)price=Ask;
                    if (cmd==1)price=Bid;
                    ticket=OrderSend(symbol,cmd,volume,NormalizeDouble(price,Digits),1000*D,NormalizeDouble(stoploss,Digits),NormalizeDouble(takeprofit,Digits),comment,magic);
                    err = GetLastError();
                    if (err == 0) break;
                    Print(Name,Symbol(),Error(err),"  ��� �������� ������");
                    Sleep(1000);
                    i1++;
                   }
              return(ticket);
             }
//--------------------------------------------------------------------+
int ModifyOrder(int ticket,double price,double stoploss,double takeprofit)
               {
                int err,i1;
                
                while(i1<MaxOrders)
                   {
                    RefreshRates();
                    bool sel7=OrderModify(ticket,NormalizeDouble(price,Digits),NormalizeDouble(stoploss,Digits),NormalizeDouble(takeprofit,Digits),0,CLR_NONE);
                    err = GetLastError();
                    if (err == 0) break;
                    Print(Name,Symbol(),Error(err),"  ��� ����������� ������");
                    Sleep(1000);
                    i1++;
                   }
                return(0);
               }
//--------------------------------------------------------------------+
string Error(int error_code)
  {
   string error_string;
   switch(error_code)
     {
      case 0:   error_string="��� ������";                                                     break;
      case 1:   error_string="��� ������, �� ��������� ����������";                            break;
      case 2:   error_string="����� ������";                                                   break;
      case 3:   error_string="������������ ���������";                                         break;
      case 4:   error_string="�������� ������ �����";                                          break;
      case 5:   error_string="������ ������ ����������� ���������";                            break;
      case 6:   error_string="��� ����� � �������� ��������";                                  break;
      case 7:   error_string="������������ ����";                                              break;
      case 8:   error_string="������� ������ �������";                                         break;
      case 9:   error_string="������������ �������� ���������� ���������������� �������";      break;
      case 64:  error_string="���� ������������";                                              break;
      case 65:  error_string="������������ ����� �����";                                       break;
      case 128: error_string="����� ���� �������� ���������� ������";                          break;
      case 129: error_string="������������ ����";                                              break;
      case 130: error_string="������������ �����";                                             break;
      case 131: error_string="������������ �����";                                             break;
      case 132: error_string="����� ������";                                                   break;
      case 133: error_string="�������� ���������";                                             break;  
      case 134: error_string="������������ ����� ��� ���������� ��������";                     break;
      case 135: error_string="���� ����������";                                                break;
      case 136: error_string="��� ���";                                                        break;
      case 137: error_string="������ �����";                                                   break;
      case 138: error_string="����� ����";                                                     break;
      case 139: error_string="����� ������������ � ��� ��������������";                        break;
      case 140: error_string="��������� ������ �������";                                       break;
      case 141: error_string="������� ����� ��������";                                         break;
      case 145: error_string="����������� ���������, ��� ��� ����� ������� ������ � �����";    break;
      case 146: error_string="���������� �������� ������";                                     break;
      case 147: error_string="������������� ���� ��������� ������ ��������� ��������";         break;
      case 148: error_string="���������� �������� � ���������� ������� �������� �������, �������������� ��������.";break;
      case 4000: error_string="��� ������";                                                      break;
      case 4001: error_string="������������ ��������� �������";                                  break;
      case 4002: error_string="������ ������� - ��� ���������";                                  break;
      case 4003: error_string="��� ������ ��� ����� �������";                                    break;
      case 4004: error_string="������������ ����� ����� ������������ ������";                    break;
      case 4005: error_string="�� ����� ��� ������ ��� �������� ����������";                     break;
      case 4006: error_string="��� ������ ��� ���������� ���������";                             break;
      case 4007: error_string="��� ������ ��� ��������� ������";                                 break;
      case 4008: error_string="�������������������� ������";                                     break;
      case 4009: error_string="�������������������� ������ � �������";                           break;
      case 4010: error_string="��� ������ ��� ���������� �������";                               break;
      case 4011: error_string="������� ������� ������";                                          break;
      case 4012: error_string="������� �� ������� �� ����";                                      break;
      case 4013: error_string="������� �� ����";                                                 break;
      case 4014: error_string="����������� �������";                                             break;
      case 4015: error_string="������������ �������";                                            break;
      case 4016: error_string="�������������������� ������";                                     break;
      case 4017: error_string="������ DLL �� ���������";                                         break;
      case 4018: error_string="���������� ��������� ����������";                                 break;
      case 4019: error_string="���������� ������� �������";                                      break;
      case 4020: error_string="������ ������� ������������ ������� �� ���������";                break;
      case 4021: error_string="������������ ������ ��� ������, ������������ �� �������";         break;
      case 4022: error_string="������� ������";                                                  break;
      case 4050: error_string="������������ ���������� ���������� �������";                      break;
      case 4051: error_string="������������ �������� ��������� �������";                         break;
      case 4052: error_string="���������� ������ ��������� �������";                             break;
      case 4053: error_string="������ �������";                                                  break;
      case 4054: error_string="������������ ������������� �������-���������";                    break;
      case 4055: error_string="������ ����������������� ����������";                             break;
      case 4056: error_string="������� ������������";                                            break;
      case 4057: error_string="������ ��������� ����������� ����������";                         break;
      case 4058: error_string="���������� ���������� �� ����������";                             break;
      case 4059: error_string="������� �� ��������� � �������� ������";                          break;
      case 4060: error_string="������� �� ���������";                                            break;
      case 4061: error_string="������ �������� �����";                                           break;
      case 4062: error_string="��������� �������� ���� string";                                  break;
      case 4063: error_string="��������� �������� ���� integer";                                 break;
      case 4064: error_string="��������� �������� ���� double";                                  break;
      case 4065: error_string="� �������� ��������� ��������� ������";                           break;
      case 4066: error_string="����������� ������������ ������ � ��������� ����������";          break;
      case 4067: error_string="������ ��� ���������� �������� ��������";                         break;
      case 4099: error_string="����� �����";                                                     break;
      case 4100: error_string="������ ��� ������ � ������";                                      break;
      case 4101: error_string="������������ ��� �����";                                          break;
      case 4102: error_string="������� ����� �������� ������";                                   break;
      case 4103: error_string="���������� ������� ����";                                         break;
      case 4104: error_string="������������� ����� ������� � �����";                             break;
      case 4105: error_string="�� ���� ����� �� ������";                                         break;
      case 4106: error_string="����������� ������";                                              break;
      case 4107: error_string="������������ �������� ���� ��� �������� �������";                 break;
      case 4108: error_string="�������� ����� ������";                                           break;
      case 4109: error_string="�������� �� ���������. ���������� �������� ����� ��������� ��������� ��������� � ��������� ��������.";            break;
      case 4110: error_string="������� ������� �� ���������. ���������� ��������� �������� ��������.";           break;
      case 4111: error_string="�������� ������� �� ���������. ���������� ��������� �������� ��������.";          break;
      case 4200: error_string="������ ��� ����������";                                           break;
      case 4201: error_string="��������� ����������� �������� �������";                          break;
      case 4202: error_string="������ �� ����������";                                            break;
      case 4203: error_string="����������� ��� �������";                                         break;
      case 4204: error_string="��� ����� �������";                                               break;
      case 4205: error_string="������ ��������� �������";                                        break;
      case 4206: error_string="�� ������� ��������� �������";                                    break;
      default:   error_string="������ ��� ������ � ��������";
     }
   return(error_string);
  }
//------------------������� �������\������ ----------------------------+
double Profit(int type) 
{double Profit = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
      {if (OrderSymbol() == Symbol() && (OrderType() == type || type==-1)) Profit += OrderProfit()+OrderSwap()+OrderCommission();}}
       return (Profit);}
       
//--------------------��������-----------------------------------------+
void CloserS()
{for(i=OrdersTotal()-1;i>=0;i--)
 if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
  {if(Symbol()==OrderSymbol())
  if(OrderType()==OP_SELL) bool sel8=OrderClose(OrderTicket(),OrderLots(),Ask,1000,0);}}
   
void CloserB()
{for(i=OrdersTotal()-1;i>=0;i--)
 if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
  {if(Symbol()==OrderSymbol())
  if(OrderType()==OP_BUY) bool sel9=OrderClose(OrderTicket(),OrderLots(),Bid,1000,0);}}