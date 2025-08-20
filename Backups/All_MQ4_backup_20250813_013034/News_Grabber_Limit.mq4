//+------------------------------------------------------------------+
//|                                                 News_Grabber.mq4 |
//|                                                   ������� ������ |
//|                                                              S&K |
//+------------------------------------------------------------------+
#property copyright "������� ������"
#property link      "S&K"

extern string News="���������";
extern double Lots=0.01;
extern int    TakeProfit=200;
extern int    StopLoss=25;  
extern int    Step=10;
extern bool   Trailing=true;
extern bool   DeleteSecondOrders=true;
extern int    TrailingStop=5;
extern int    Befor_Minutes=3;
extern int    DeleteAfter_Minutes=6;
extern int    NumberAttempt=5;
extern int    Magic=159;


bool Permission=false;

string CloseTime, OpenTime, OldOpen;

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
     
   
      int tiket=-1, Attempt=0;
      
      string FileData=ReadFile(), minute;
       
      if (StopLoss<=0)
      {
      Alert("StopLoss ������ ���� ������ 0");
      return(0);
      }
      
    
  
      if (FileData=="579282") 
      {
      Print("���������� ������� ���� � �������, ������ - ",GetLastError());
      Comment("���������� ������� ���� � �������..."+"\n"+
      "���������, ���������� �� ��������� ��������� � �������...");
      return(0);
      }
       
      
      OpenTime=TimeToStr(StrToTime(FileData)-Befor_Minutes*60);
      CloseTime=TimeToStr(StrToTime(FileData)+DeleteAfter_Minutes*60);
      if (OldOpen!=OpenTime)  { Permission=true; }
      OldOpen=OpenTime;
      
      
      if (StrToTime(FileData)>TimeCurrent())
      {
        
         if  (TimeMinute(TimeCurrent())<10)
         {
         minute="0"+TimeMinute(TimeCurrent());
         }
         else 
         minute=TimeMinute(TimeCurrent());
         
      Comment("\n"+"������� ��������� �����: "+TimeHour(TimeCurrent())+":"+minute+"\n"+
              "��������� ������� ������: "+ FileData+"\n"+
              "��������� ��������� �������: "+OpenTime+"\n"+
              "����� ��������� ��������������� �������: "+CloseTime+"\n"+
              "�������� ������� �� ������� ����������� = "+OrdersTotalMagicLimit()+"\n"+
              "�������� ������� �� ������� ����������� = "+OrdersTotalMagicOpen()+"\n"+
              "������� � ������� �� ������ �������� ���� (���� "+Symbol()+") = "+OrderProfitInPips()+"\n"+
              "����� ������� ��������� � ������� �� ��������� ����� = "+AllProfitInPips()+"\n"+
              "Permission  -  "+Permission);
      }  
      else Comment("���� ��� ���������� � ������� ��������..."+"\n"+
                   "���������, ����������� �� ��������� ��������� � �������."+"\n"+
                   "���� ��������� �����������, ��������� ��������� �����.");    
      
     CloseAllOrdersLimitNotWorks();
      
      if (OrdersTotalMagicOpen()>0 && Trailing)
          TrailingStairs();
          
      
          
      
      if (Permission==true && OrdersTotalMagicLimit()==0 && OrdersTotalMagicOpen()==0 && TimeCurrent()>=StrToTime(OpenTime) && TimeCurrent()<StrToTime(FileData))
      {
          tiket=-1;
          
          while (tiket==-1)
          {
          RefreshRates();
          tiket=OrderSend(Symbol(),OP_BUYLIMIT,Lots, Bid-Step*Point, 0, (Bid-Step*Point)-StopLoss*Point, (Bid-Step*Point)+TakeProfit*Point, "News", Magic, CloseTime , Red);
          Permission=false;
               if (Attempt==NumberAttempt)
               {
               Print("�� ���� ��������� ����� OP_BUYLIMIT. ������� - "+Attempt);
               tiket=-1;
               Attempt=0;
               return(0);
               
               }
          Print(GetLastError());
          Sleep(3000);
          Attempt++;
          }
      
          tiket=-1;
      
          
          while (tiket==-1)
          {
          RefreshRates();
          tiket=OrderSend(Symbol(),OP_SELLLIMIT, Lots, Ask+Step*Point, 0, (Ask+Step*Point)+StopLoss*Point, (Ask+Step*Point)-TakeProfit*Point, "News", Magic, CloseTime , Blue);
          Permission=false;
               if (Attempt==NumberAttempt)
               {
               Print("�� ���� ��������� ����� OP_SELLLIMIT. ������� - "+Attempt);
               tiket=-1;
               Attempt=0;
               return(0);
               
               }
          Print(GetLastError());
          Sleep(3000);
          Attempt++;
          }
      } 
              
      if ((OrdersTotalMagicOpen()>0) && DeleteSecondOrders)
           CloseAllOrdersLimit();
      
//----
   return(0);
  }
//+------------------------------------------------------------------+

////////////���������� ���������� �������� ������� �� ������
int OrdersTotalMagicLimit()
{   
    int orders=0, cnt;
     for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=Magic)
     continue;
          if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
          {
          if (OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT) 
          orders++; 
          }
   }
   return(orders);
}
////////////�����

////////////���������� ���������� �������� ������� �� ������
int OrdersTotalMagicOpen()
{   
    int orders=0, cnt;
     for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
     if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=Magic)
     continue;
          if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
          {
          if (OrderType()==OP_SELL || OrderType()==OP_BUY) 
          orders++; 
          }
   }
   return(orders);
}
////////////�����

///////////////////////��������� �������� ���� �������� �������
void CloseAllOrdersLimit()
{
 
 for(int i=OrdersTotal()-1;i>=0;i--)
 {
  OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

  if(OrderSymbol()!=Symbol()||OrderMagicNumber()!= Magic)
   continue;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()== Magic)
  {
   if(OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
      {
     // OrderDelete(OrderTicket(), DeepPink);
      
      Sleep(3000);
      }
   
  }
  
 }
}
///////////////////////����� ��������� �������� �������


///////////////////////��������� �������� ���� ������������� �������� �������
void CloseAllOrdersLimitNotWorks()
{
 
 for(int i=OrdersTotal()-1;i>=0;i--)
 {
  OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
  
  if(OrderSymbol()!=Symbol() || OrderMagicNumber()!= Magic)
   continue;
  if(OrderSymbol()==Symbol() && OrderMagicNumber()== Magic)
  {
   if(OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
      {
          if ((OrderOpenTime()+DeleteAfter_Minutes*60)<TimeCurrent())
          OrderDelete(OrderTicket(), White);
          //Alert (DelTime+"     "+TimeCurrent());
          Sleep(3000);
      }
   
  }
  
 }
}
///////////////////////����� ��������� �������� �������





  //******************************************************
  // ���� ������������ ��������-����� � ������ � �����.
  //******************************************************
void TrailingStairs()
{

  
 for(int i=0;i<OrdersTotal();i++)
 {
   if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) continue;
   if((OrderSymbol()==Symbol()) && (OrderType()==OP_BUY || OrderType()==OP_SELL) && (OrderMagicNumber()== Magic))
   {
      if(OrderType()==OP_BUY)
      {
        if(Bid-OrderOpenPrice()>Point*TrailingStop)
        {
         if(OrderStopLoss()<Bid-Point*TrailingStop)
           {
            OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
            Sleep(3000);
            return(0);
           }
        }
      }
      if(OrderType()==OP_SELL)
      {
       if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
         {
          if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
            {
             OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
             Sleep(3000);
             return(0);
            }
         }
      }
    }
    
 } 
  return(0);
}
//+------------------------------------------------------------------+

//////////////������ �� �����
string ReadFile()
{
int handle;
string str;
    handle=FileOpen(Symbol()+".sts", FILE_READ);
    if(handle<1)
    {
     Print("������ ������� ���� � �������, ������ - ",GetLastError());
     return("579282");
    }
  FileReadString(handle, str);
  FileClose(handle);
  return(str);
}
//////////////�����

////////////���������� ������ �� ����� � �������
int AllProfitInPips()
{
   int pr=0;
   double pnt=0;
   
   for(int cnt=OrdersHistoryTotal()-1;cnt>=0;cnt--)
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
     if(OrderMagicNumber()!=Magic)
     continue;
     pnt=MarketInfo(OrderSymbol(), MODE_POINT); 
          if(OrderMagicNumber()==Magic && TimeDay(TimeCurrent())==TimeDay(OrderCloseTime()))
          {
               if (OrderType()==OP_SELL) 
               pr=pr+(OrderOpenPrice()-OrderClosePrice())/pnt;
               
               if (OrderType()==OP_BUY) 
               pr=pr+(OrderClosePrice()-OrderOpenPrice())/pnt;
             
          }
   }
return(pr);   
}
////////////����� ����������� ������� ���������� ����


////////////���������� ������ �� ����� � �������
int OrderProfitInPips()
{
   int pr=0;
   double pnt=0;
   
   for(int cnt=OrdersHistoryTotal()-1;cnt>=0;cnt--)
   {
     OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
     if(OrderMagicNumber()!=Magic || OrderSymbol()!=Symbol())
     continue;
     pnt=MarketInfo(OrderSymbol(), MODE_POINT); 
          if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && TimeDay(TimeCurrent())==TimeDay(OrderCloseTime()))
          {
               if (OrderType()==OP_SELL) 
               pr=pr+(OrderOpenPrice()-OrderClosePrice())/pnt;
               
               if (OrderType()==OP_BUY) 
               pr=pr+(OrderClosePrice()-OrderOpenPrice())/pnt;
             
          }
   }
return(pr);   
}
////////////����� ����������� ������� ���������� ����

/*
////////////���������� ���� �� ��� ������ �� ������ �������
int OrdersOpenPermission()
{   
    int orders=0, cnt;
    bool Permission=true;
    string FileData=ReadFile();
    OpenTime=TimeToStr(StrToTime(FileData)-Befor_Minutes*60);
     {
        for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
       {
        OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
        if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=Magic)
        continue;
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && (OrderType()==OP_SELL || OrderType()==OP_BUY))
        Permission=false;
        else Permission=true; 
       }
      
        for(cnt=OrdersHistoryTotal()-1;cnt>=0;cnt--)
       {
        OrderSelect(cnt, SELECT_BY_POS, MODE_HISTORY);
        if(OrderSymbol()!=Symbol()||OrderMagicNumber()!=Magic)
        continue;
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && (OrderType()==OP_SELL || OrderType()==OP_BUY) && OrderOpenTime()>=StrToTime(OpenTime) && OrderOpenTime()<StrToTime(FileData))
        Permission=false; 
        else Permission=true; 
       }
     }
 return(Permission);
}
////////////�����
*/