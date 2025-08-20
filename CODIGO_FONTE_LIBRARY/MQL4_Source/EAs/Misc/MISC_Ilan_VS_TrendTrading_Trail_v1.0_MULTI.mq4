//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
#property copyright "" 
#property link      ""
#include <stderror.mqh>
#include <stdlib.mqh>

//���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
double Stoploss = 500.0;            // ������� ���������
double TrailStart = 10.0;
double TrailStop = 10.0;
//���������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
string w1 = "��� Exponent 0-����������/1-����������/2-���������";
int    TypeLotExponent = 0;  //��� ����������:
                                       //0-���������� (1-� ������)� ������ ������� ����������� Exponent �� Lots
                                       //1-���������� (2-� ������)� ������ ������� ����������� Exponent �� LotExponent
                                       //2-��������� � ������ ������� ����������� Exponent � LotExponent-���
double LotExponent = 1.4;              // �� ������� �������� ��� ��� ����������� ���������� ������. ������: ������ ��� 0.1, �����: 0.16, 0.26, 0.43 ...
extern double  PipStepExponent = 1;     //����������� ���������� ��������
extern int     DefaultPips     = 50;    //�������������� �������� PipStep
extern int     MaxPips         = 100;   //������������ �������� PipStep
double         slip            = 4.0;   // �� ������� ����� ���������� ���� � ������ ���� �� �������� ������� (� ��������� ������ ������� �������� ����)
extern double  Lots            = 0.1;   // ������ ���� ��� ������ ������
extern int     lotdecimal      = 2;     // ������� ������ ����� ������� � ���� ������������ 0 - ���������� ���� (1), 1 - �������� (0.1), 2 - ����� (0.01)
extern int     Trail_TimeFrame    = 3;     // ���� ����� �����
                                          // 0 - ������� ������
                                          // 1 - 1 ���
                                          // 2 - 5 ���
                                          // 3 - 15 ���
                                          // 4 - 30 ���
                                          // 5 - 1 ���
                                          // 6 - 4 ����
                                          // 7 - 1 ����
// extern int     TakeProfitFirstOrder      = 20.0;  // �� ���������� �������� ������� ������� ��������� ������
// extern int     TakeProfitSeria      = 20.0;  // �� ���������� �������� ������� ������� ��������� �����
extern int     MA_TimeFrame    = 7;     // ���� ����� ��
                                          // 0 - ������� ������
                                          // 1 - 1 ���
                                          // 2 - 5 ���
                                          // 3 - 15 ���
                                          // 4 - 30 ���
                                          // 5 - 1 ���
                                          // 6 - 4 ����
                                          // 7 - 1 ����
extern int     MA_Period       = 6;     // ������ ��
extern int     MA_Delta        = 3;     // �� ������� ������ ���������� �� �� �������� �����, ����� ������ ��������
extern int     CCIlevel = 160;          // ������� �� ������ CCI �� �������, ���� ������� ��������, �� ����� �� ����� �����������
extern int     MagicNumber = 2222;      // ��������� ����� (�������� ��������� �������� ���� ������ �� �����)
int PipStep=0;
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
extern int MaxTrades = 10;                 // ����������� ���������� ������������ �������� �������
//extern bool UseLastTradeTP = FALSE;     //������������ �� ����� ���������� ����������� �� �� ��������� �����
//extern int LastTradeNumber = 5;        //� ������ ������ ������������ ����������� �������� �� �� ��������� �����         
//-----------------------------------------------------------------------------------------------------------+BosSLtd
extern bool    MM             = false;
extern double  risk           = 1;    // �� 0.01 - ���.
extern int     balans         = 1000; // ������ ����������������, �� ������ 1000 ���� ����� ��������� ��� �� ����
//-----------------------------------------------------------------------------------------------------------+BosSLtd
extern bool ManualFirstOrder = false;      // ��������� ������ ����� �������
extern bool debug = false; 
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
double  TakeProfit;
double AveragePrice,buf;
double LastBuyPrice, LastSellPrice, Spread, LastTP;
string EAName="Ilan_VS_TrendTrading_Trail";
int timeprev = 0;
int NumOfTrades = 0;
double iLots;
int cnt = 0, total, prev_total, i1, ma_tf, trail_tf;
bool LongTrade = FALSE, ShortTrade = FALSE;
int ticket, Error;
double Exponent, TP_Shift, LastTP_Lot, LastTP_Price_shift, TrailPrice;
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
int init() {
   switch(MA_TimeFrame)                                  // ��������� switch
     {                                            // ������ ���� switch
      case 0 : ma_tf = 0;     break;               // 1 ������� ������
      case 1 : ma_tf = 1;     break;               // 1 ���
      case 2 : ma_tf = 5;     break;               // 5 ���
      case 3 : ma_tf = 15;    break;               // 15 ���
      case 4 : ma_tf = 30;    break;               // 30 ���
      case 5 : ma_tf = 60;    break;               // 1 ���
      case 6 : ma_tf = 240;   break;               // 4 ����
      case 7 : ma_tf = 1440;  break;               // 1 ����
      default: ma_tf = 0;                          // ���� � case �� ������� �� ������� ������
     }                                            // ����� ���� switch   

   switch(Trail_TimeFrame)                                  // ��������� switch
     {                                            // ������ ���� switch
      case 0 : trail_tf = 0;     break;               // 1 ������� ������
      case 1 : trail_tf = 1;     break;               // 1 ���
      case 2 : trail_tf = 5;     break;               // 5 ���
      case 3 : trail_tf = 15;    break;               // 15 ���
      case 4 : trail_tf = 30;    break;               // 30 ���
      case 5 : trail_tf = 60;    break;               // 1 ���
      case 6 : trail_tf = 240;   break;               // 4 ����
      case 7 : trail_tf = 1440;  break;               // 1 ����
      default: trail_tf = 0;                          // ���� � case �� ������� �� ������� ������
     }                                            // ����� ���� switch   

  Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;
  timeprev = Time[0];
  return (0);
}

int deinit() 
{
   return (0);
}
//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
int start()
{
  /************************************************************/
  /* ����� ����� ����, ������� �������� ��� ������ ����� ���� */ 
  /************************************************************/
  double PrevCl;
  double CurrCl;

  if (timeprev == Time[0]) return(0);   //��������� ��������� ������ ����

  /*****************************************************************************/
  /* ������ ���� ����� ����, ������� �������� ������ ��� ��������� ������ ���� */ 
  /*****************************************************************************/
  timeprev = Time[0];
total = CountOfOrders();

//-----------------------------------------------------------------------------------------------------------+BosSLtd
 if(MM) Lots = GetLots();
 
//-----------------------------------------------------------------------------------------------------------+BosSLtd
  switch(TypeLotExponent)
   {
    case 0://�������������� ����� ������� �������������
      Exponent = Lots * (1 + total);//� ������ ������� ����������� Exponent �� Lots
      break;
    case 1://�������������� ����� ������� �������������
      Exponent = Lots + (LotExponent*total);//� ������ ������� ����������� Exponent �� LotExponent
      break;
    case 2://�������������� ����� ������� �������������
      Exponent = Lots * MathPow(LotExponent, total);
      break;
   }
  //===============================================================================
  // ��� ����������� �������. 
  //===============================================================================
  PipStep = MathRound(DefaultPips * MathPow(PipStepExponent, (total-1)));
  if (PipStep>MaxPips)
   PipStep=MaxPips;
  if (total > 0)  //��������� ��� ��� ������ ���� ���� ������ � �����, ����� ��� ������.
  {
    for (int i = 0; i < OrdersTotal(); i++) 
      if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES))
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
          switch(OrderType())
          {
            case OP_BUY:
              LongTrade = TRUE;
              ShortTrade = FALSE;
              break;
            case OP_SELL:
              LongTrade = FALSE;
              ShortTrade = TRUE;
              break;//������� �� ������ switch
          }
          break;//������� �� ����� for
        }
  //===============================================================================
  // ����� ����������� ����� �� ��������� ��������� ������ ����� �������
  //===============================================================================
    LastBuyPrice = FindLastBuyPrice();
    LastSellPrice = FindLastSellPrice();
  }
   
  //===============================================================================
  // ����� ������������ ������, ����� � ����� ��� ���� �������� ������.
  //===============================================================================
   if((total > 0) && !(total > MaxTrades))
   { 
    if((LongTrade && LastBuyPrice - Ask >= PipStep * Point) || (ShortTrade && Bid - LastSellPrice >= PipStep * Point))
     {
      iLots = NormalizeDouble(Exponent, lotdecimal);
      if (ShortTrade) 
      {
        if((iMA(NULL,ma_tf,MA_Period,0,0,0,1)-iMA(NULL,ma_tf,MA_Period,0,0,0,0)) > (MA_Delta*Point))
        ticket = SendMarketOrder(OP_SELL, iLots, 0, 0, MagicNumber, EAName + "-" + NumOfTrades + "-" + PipStep, Error);
      }
      if (LongTrade) 
      {
        if((iMA(NULL,ma_tf,MA_Period,0,0,0,0)-iMA(NULL,ma_tf,MA_Period,0,0,0,1)) > (MA_Delta*Point))
        ticket = SendMarketOrder(OP_BUY, iLots, 0, 0, MagicNumber, EAName + "-" + NumOfTrades + "-" + PipStep, Error);
      }
     } 
    }  
  //===============================================================================
  // ����� ������������ ������, ����� � ����� ��� �������� �������.
  //===============================================================================
 if (total < 1)
  {
    if (!ManualFirstOrder)
    {
     Print("��������� ������� ��� �������� ������� ������");
     ticket = 0;
     PrevCl = iClose(Symbol(), 0, 2);
     CurrCl = iClose(Symbol(), 0, 1);
     if ((PrevCl > CurrCl) 
     && iMA(NULL,ma_tf,MA_Period,0,0,0,1)-iMA(NULL,ma_tf,MA_Period,0,0,0,0) > MA_Delta*Point
     && iCCI(Symbol(),1440,14,PRICE_TYPICAL,0)>CCIlevel*(-1)) 
     {
       if (debug) Print("��������� ������� SELL");
       ticket = SendMarketOrder(OP_SELL, Lots, 0, 0, MagicNumber, EAName + "-" + total , Error);
     }
     else Print ("��� ������� ��� �������� ������ SELL"); 
     if (PrevCl < CurrCl 
     && iMA(NULL,ma_tf,MA_Period,0,0,0,0)-iMA(NULL,ma_tf,MA_Period,0,0,0,1) > MA_Delta*Point
     && iCCI(Symbol(),1440,14,PRICE_TYPICAL,0)<CCIlevel) 
     {
       if (debug) Print("��������� ������� BUY");
       ticket = SendMarketOrder(OP_BUY, Lots, 0, 0, MagicNumber, EAName + "-" + total , Error);
     }
     else Print ("��� ������� ��� �������� ������ BUY"); 
   }  
  }
total = CountOfOrders();
Trail();
  
  return (0);
}
//�������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
int CountOfOrders()
{
  int count = 0;
  for (int i = 0; i < OrdersTotal(); i++) 
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if ((OrderSymbol() == Symbol()) && (OrderMagicNumber() == MagicNumber)) 
        if ((OrderType() == OP_SELL) || (OrderType() == OP_BUY)) 
          count++;
  return(count);
}

//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������


//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
//=========================================================================
int SendMarketOrder(int Type, double Lots, int TP, int SL, int Magic, string Cmnt, int& Error)
{
  double Price, Take, Stop;
  int Ticket, Slippage, Color, Err; 
  bool Delay = False;
  if (debug) Print("������� SendMarketOrder");
  while(!IsStopped())
  {
    if(!IsExpertEnabled())
    {
      Error = ERR_TRADE_DISABLED;
      Print("�������� ��������� ���������! ������ \"��������\" ������.");
      return(-1);
    }
    if (debug) Print("�������� ��������� ���������");
    if(!IsConnected())
    {
      Error = ERR_NO_CONNECTION;
      Print("����� �����������!");
      return(-1);
    }
    Print("����� � �������� �����������");
    if(IsTradeContextBusy())
    {
      Print("�������� ����� �����!");
      Print("������� 3 ���...");
      Sleep(3000);
      Delay = True;
      continue;
    }
    if (debug) Print("�������� ����� ��������");
    if(Delay) 
    {
      Print("��������� ���������");
      RefreshRates();
      Delay = False;
    }
    else
    {
      if (debug) Print("�������� �� ����");
    }
    switch(Type)
    {
      case OP_BUY:
        if (debug) Print("�������������� ��������� ��� BUY-������");
        Price = NormalizeDouble( Ask, Digits);
        Take = IIFd(TP == 0, 0, NormalizeDouble( Ask + TP * Point, Digits));
        Stop = IIFd(SL == 0, 0, NormalizeDouble( Ask - SL * Point, Digits));
        Color = Blue;
        break;
      case OP_SELL:
        if (debug) Print("�������������� ��������� ��� SELL-������");
        Price = NormalizeDouble( Bid, Digits);
        Take = IIFd(TP == 0, 0, NormalizeDouble( Bid - TP * Point, Digits));
        Stop = IIFd(SL == 0, 0, NormalizeDouble( Bid + SL * Point, Digits));
        Color = Red;
        break;
      default:
        Print("��� ������ �� ������������� �����������.");
        return(-1);
    }
    Slippage = MarketInfo(Symbol(), MODE_SPREAD);
    Print("Slippage = ",Slippage);
    if(IsTradeAllowed())
    {
      if (debug) Print("�������� ���������, ���������� �����...");
      Ticket = OrderSend(Symbol(), Type, Lots, Price, Slippage, Stop, Take, Cmnt, Magic, 0, Color);
      if(Ticket < 0)
      {
        Err = GetLastError();
        if (Err == 4   || /* SERVER_BUSY */
            Err == 129 || /* INVALID_PRICE */ 
            Err == 135 || /* PRICE_CHANGED */ 
            Err == 137 || /* BROKER_BUSY */ 
            Err == 138 || /* REQUOTE */ 
            Err == 146 || /* TRADE_CONTEXT_BUSY */
            Err == 136 )  /* OFF_QUOTES */
        {
          Print("������(OrderSend - ", Err, "): ", ErrorDescription(Err));
          Print("������� 3 ���...");
          Sleep(3000);
          Delay = True;
          continue;
        }
        else
        {
          Print("����������� ������(OrderSend - ", Err, "): ", ErrorDescription(Err));
          Error = Err;
          break;
        }
      }
      break;
    }
    else
    {
      Print("�������� ��������� ���������! ����� ����� � ��������� ��������.");
      //Print("������� 3 ���...");
      //Sleep(3000);
      //Delay = True;
      //continue;
      Ticket = -1;
      break;
    }
  }
  if(Ticket > 0)
    Print("����� ��������� �������. ����� = ",Ticket);
  else
    Print("������! ����� �� ���������. (ErrorCode = ", Error, ": ", ErrorDescription(Error), ")");
  return(Ticket);
}
//==================================================================
double IIFd(bool condition, double ifTrue, double ifFalse) 
{
  if (condition) return(ifTrue); else return(ifFalse);
}

//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������

double FindLastBuyPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
         oldticketnumber = OrderTicket();
         if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
         }
      }
   }
   return (oldorderopenprice);
}

double FindLastSellPrice() {
   double oldorderopenprice;
   int oldticketnumber;
   double unused = 0;
   int ticketnumber = 0;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
         oldticketnumber = OrderTicket();
         if (oldticketnumber > ticketnumber) {
            oldorderopenprice = OrderOpenPrice();
            unused = oldorderopenprice;
            ticketnumber = oldticketnumber;
         }
      }
   }
   return (oldorderopenprice);
}
//�������������������������������������������������������������������������������������������������������������������������������������������������������������������
double CalculateAveragePrice()
{
  double AveragePrice = 0;
  double Count = 0;
  for (int i = 0; i < OrdersTotal(); i++)
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        if (OrderType() == OP_BUY || OrderType() == OP_SELL) 
        {
           AveragePrice += OrderOpenPrice() * OrderLots();
           Count += OrderLots();
        }
  if(AveragePrice > 0 && Count > 0)
    return( NormalizeDouble(AveragePrice / Count, Digits));
  else
    return(0);
}
//�������������������������������������������������������������������������������������������������������������������������������������������������������������������

//--------------------------------------------------------
bool ModifyOrder( double stoploss)
{
  while(!IsStopped())
  {
    Print("������� ModifyOrder");
    if(IsTradeContextBusy())
    {
      Print("�������� ����� �����!");
      Sleep(3000);
      continue;
    }
    if (debug) Print("�������� ����� ��������");
    if(!IsTradeAllowed())
    {
      Print("�������� ��������� ���������!");
      //Sleep(3000);
      //continue;
      return(False);
    }
    if (debug) Print("�������� ���������, ������������ ����� #",OrderTicket());
    if(stoploss != NormalizeDouble(OrderStopLoss(),Digits))
    {
      if(!OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(stoploss,Digits), 0, 0, Yellow))
      {
         Print("�� ������� �������������� �����");
         int Err = GetLastError();
         Print("������(",Err,"): ",ErrorDescription(Err));
         return(False);
         //break;
         //Sleep(1000);
         //continue;
      }
      else
      {
         if (debug) Print("����������� ������ ��������� �������");
         break;
      }
     return(True);
    }
    else
    {
    if (debug) Print("����� �� ��������� � �����������");
    break;
    }  
  }
  return(True);
}
//--------------------------------------------------------
//-----------------------------------------------------------------------------------------------------------+BosSLtd
double GetLots() 
{
double minlot = MarketInfo(Symbol(), MODE_MINLOT);
double maxlot = MarketInfo(Symbol(), MODE_MAXLOT);
double lot = NormalizeDouble(AccountBalance() * risk /100 / balans, 2);
if(lot < minlot) lot = minlot; if(lot > maxlot) lot = maxlot;
return(lot);
} 
//-----------------------------------------------------------------------------------------------------------+BosSLtd
//--------------------------------------------------------------------------------
double LongTrail ()
{
double firstbar, secondbar, trailprice;
firstbar = iLow(Symbol(),trail_tf,1);
secondbar = iLow(Symbol(),trail_tf,2);
if(firstbar > secondbar) trailprice = NormalizeDouble(secondbar, Digits);
    else trailprice = NormalizeDouble(firstbar, Digits);
return(trailprice);
}
//--------------------------------------------------------------------------------   
double ShortTrail ()
{
double firstbar, secondbar, trailprice;
firstbar = iHigh(Symbol(),trail_tf,1);
secondbar = iHigh(Symbol(),trail_tf,2);
if(firstbar > secondbar) trailprice = NormalizeDouble(firstbar, Digits);
    else trailprice = NormalizeDouble(secondbar, Digits);
return(trailprice);
}
//--------------------------------------------------------------------------------   
void Trail()
{
double trailprice;
double PriceTarget = 0;
      if(total>0)
      {
      //===
      for (int i = 0; i < OrdersTotal(); i++) 
         if(OrderSelect( i, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            {
               switch(OrderType())
               {
                  case OP_BUY:
                     LongTrade = TRUE;
                     ShortTrade = FALSE;
                     break;
                  case OP_SELL:
                     LongTrade = FALSE;
                     ShortTrade = TRUE;
                     break;//������� �� ������ switch
               }
               break;//������� �� ����� for
            }
         //===
         AveragePrice = CalculateAveragePrice();
         trailprice = AveragePrice;
         if(ShortTrade) 
            {  
            if(trailprice > ShortTrail() && (Ask + MarketInfo(Symbol(), MODE_STOPLEVEL)*Point) < ShortTrail()) 
               {
               trailprice = ShortTrail();
               if (AveragePrice > trailprice) PriceTarget = trailprice;
                        if (debug) Print("������������ ��� ������ � �����");
               for (i1 = 0; i1 < OrdersTotal(); i1++)
                  {  
                  if(OrderSelect(i1, SELECT_BY_POS, MODE_TRADES))
                     {
                     if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
                        { 
                        if(NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(PriceTarget,Digits))
                        ModifyOrder(PriceTarget);
                        }
                     }
                  }
               }
            }
         if(LongTrade) 
            {
            if(trailprice < LongTrail() && (Bid - MarketInfo(Symbol(), MODE_STOPLEVEL)*Point) > LongTrail()) 
            {
            trailprice = LongTrail();
            if (AveragePrice < trailprice) PriceTarget = trailprice;
               if (debug) Print("������������ ��� ������ � �����");
               for (i1 = 0; i1 < OrdersTotal(); i1++)
                  {  
                  if(OrderSelect(i1, SELECT_BY_POS, MODE_TRADES))
                     {
                     if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
                        { 
                        if(NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(PriceTarget,Digits))
                        ModifyOrder(PriceTarget);
                        }
                     }
                  }
               } 
            }
       }
return;
}