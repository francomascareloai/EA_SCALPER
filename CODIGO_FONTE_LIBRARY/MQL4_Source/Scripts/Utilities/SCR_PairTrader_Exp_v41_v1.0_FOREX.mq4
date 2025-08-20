//+------------------------------------------------------------------+
//|                                           PairTrader_Exp v.4.mq4 |
//|                                   Copyright � 2012, Mr.SilverKZ  |
//|                                                silverkz@@mail.kz |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Mr.SilverKZ"
#property link      "silverkz@mail.kz"
//--------------------------------------------------------------------
extern bool    OpenPair  =  false;    // true - �������� ���������, 
                                      // false - �������� ���������
extern bool    Trade     =  true;                                      
extern bool    ClosePair =  false;    // true - ������������� ������� �������, 
                                      // false - �� ���� �� ������
extern string  Symbol_2  =  "GBPUSD"; // ���������� ���������� �2
extern bool    Revers    =  false;    // true  - ������������� ����������  
                                      // false - ������������� ���������� 
extern int     Delta     =  50;       // ������ ��������� � ������� ��� �����
extern int     Step      =  50;       // ������ ��������� � ������� ��� �������, 0 - ������� ���
extern int     Count     =  5;        // ������������ ���������� �������
extern int     Profit    =  25;       // ������ � ������ �������� ��� �������� �������
extern int     StopLoss  =  1000;     // ������ � ������ �������� ��� �������� �������
extern int     Trailing  =  20;       // ��������-���� � ������ ��������, 0 - ��������� ���
extern double  Lot       =  0.1;      // ������� ���
extern double  MM        =  0;        // ���������� �����
                                      // MM = 0 - ���������� ������� ��� 
                                      // MM = 1 - ���������� �� ������� ���
                                      // MM > 1 - ����������� ��������� ����
extern int     Magic     =  10345;    // ������������� �������
//-------------------------------------------------------------------- 
int            Mas_Tip_Symb1[6];      // [] ��� ���: 0=B,1=S,2=BL,3=SL,4=BS,5=SS 
int            Mas_Tip_Symb2[6];      // [] ��� ���: 0=B,1=S,2=BL,3=SL,4=BS,5=SS  
string         Txt, Text_1, Text_2, Text_3, Text_4;
string         Symbol_1;
double         Koef; 
int            i, K;
double         ProfitMax;
double         lot;
//--------------------------------------------------------------------
int init() 
{
   Symbol_1  = Symbol();
   Create(Time[20]);
   i = 20;   
   if(Revers) K = -1;
   else       K =  1;  
   //if (Digits==5 || Digits==3) T = 20;
   if(Step>0)Txt = "��������";
   else Txt = "���������";
   return (0);
}
//-------------------------------------------------------------------
int deinit()
{
   return(0);
}
//-------------------------------------------------------------------
int start()
{
   //----------------------------------------------------------------
   datetime T1 = ObjectGet(WindowExpertName(),OBJPROP_TIME1);
   int Error=GetLastError();              
   if (Error==4202)                    
     {
      Alert("������ ������������ ����� ���������",
            "\n��� ����������� ��������. ������� ������.");
      Create(Time[i]);                       
      T1=Time[i];                      
     }
   i = iBarShift(Symbol(),0,T1); 
   //----------------------------------------------------------------
   double Price1 = (iClose(Symbol_1,0,0) - iClose(Symbol_1,0,i)) / MarketInfo(Symbol_1, MODE_POINT);
   double Price2 = K*(iClose(Symbol_2,0,0) - iClose(Symbol_2,0,i)) / MarketInfo(Symbol_2, MODE_POINT);
   double Spread = Price1 - Price2;
   //----------------------------------------------------------------   
   if (Terminal()==0) lot = Lot;
   //---------------------------------------------------------------- 
   bool   Sig_Buy    = MathAbs(Spread) >= Delta+Step*Mas_Tip_Symb1[0] && Spread < 0 && Mas_Tip_Symb1[0]<=Count;
   bool   Sig_Sell   = MathAbs(Spread) >= Delta+Step*Mas_Tip_Symb1[1] && Spread > 0 && Mas_Tip_Symb1[1]<=Count;
   //---------------------------------------------------------------- 
   if(Spread < 0) 
      {
       Text_1 = Symbol_1+" Buy ";
       if(Revers)Text_2 = Symbol_2+" Buy ";
       else Text_2 = Symbol_2+" Sell ";
      }
   if(Spread > 0) 
      {
       Text_1 = Symbol_1+" Sell ";
       if(Revers)Text_2 = Symbol_2+" Sell ";
       else Text_2 = Symbol_2+" Buy ";
      }
   if((Mas_Tip_Symb1[0]+Mas_Tip_Symb1[1])==0) Text_3 = "0"; else Text_3 = (Mas_Tip_Symb1[0]+Mas_Tip_Symb1[1]) - 1;
   if(OpenPair) Text_4 = "���������";    else Text_4 = "���������";
   //---------------------------------------------------------------- 
   Comment("----------------------------------------------------",
           "\n�����������: ",Text_1," - ",Text_2,
           "\n��������: ",Text_4,
           "\n������� �������: ",Txt,
           "\n----------------------------------------------------",
           "\n������� ��������� = ",MathAbs(Spread),
           "\n��������� ��� ����� = ",Delta+Step*(Mas_Tip_Symb1[0]+Mas_Tip_Symb1[1]),
           "\n----------------------------------------------------",
           "\n���������� ������� = ",Text_3,
           "\n������������ ���������� ������� = ",Count,
           "\n----------------------------------------------------",
           "\n������� �������/������ = ",ProfitAll(),
           "\n����-������ ��� ������ = ",Profit,
           "\n����-���� ��� ������ = ",StopLoss,
           "\n��������-���� = ",Trailing,
           "\n----------------------------------------------------");
   //-------------------------------------------------------------------- 
   // Close
   //--------------------------------------------------------------------
   double Profits = ProfitAll();
   if (Profits>ProfitMax) ProfitMax=Profits;
   if (Trailing>0 && (ProfitMax-Profits)>Trailing && Profits>0)
     {
      CloseAll();
     }
   if((Terminal()>0 && (Profits>=Profit || Profits<=(-StopLoss))) || ClosePair)
     {
      CloseAll();
     }
   //--------------------------------------------------------------------
   if(!OpenPair) return(0); 
   if(Trade && Terminal()==0) return(0);
   //--------------------------------------------------------------------
   // Open
   //-------------------------------------------------------------------- 
   if(Step<=0 && Terminal()!=0)return(0);
   if(Sig_Sell)                                    // Sell
     {
      if(Revers) 
         {
          OPENORDER (Symbol_1, lot, "Sell");
          OPENORDER (Symbol_2, lot, "Sell");
         }
      else 
         {
          OPENORDER (Symbol_1, lot, "Sell");
          OPENORDER (Symbol_2, lot, "Buy");
         }  
      CountLots();       
     }
   if(Sig_Buy)                                     // Buy
     {
      if(Revers) 
         {
          OPENORDER (Symbol_1, lot, "Buy");
          OPENORDER (Symbol_2, lot, "Buy");
         }
      else 
         {
          OPENORDER (Symbol_1, lot, "Buy");
          OPENORDER (Symbol_2, lot, "Sell");
         }
      CountLots(); 
     }   
   //--------------------------------------------------------------------   
return(0);
}
// END
//-----------------------------------------------------------------------
double ProfitAll()
{
   double Prof;
   for (int i=OrdersTotal()-1; i>=0; i--)
   {                                               
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if ((OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderMagicNumber()==Magic) 
         {
             Prof+=OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
   }
   return(Prof);
}
//--------------------------------------------------------------------
void OPENORDER(string symbol, double  Lots, string ord)
{
   int error,err;
   while (true)
   {  
      error=true;
      if (ord=="Buy") 
         {
          error=OrderSend(symbol,OP_BUY, Lots,NormalizeDouble(MarketInfo(symbol,MODE_ASK),MarketInfo(symbol,MODE_DIGITS)),3,0,0,"",Magic,0,Blue);
         }
      if (ord=="Sell")
         {
          error=OrderSend(symbol,OP_SELL,Lots,NormalizeDouble(MarketInfo(symbol,MODE_BID),MarketInfo(symbol,MODE_DIGITS)),3,0,0,"",Magic,0,Red);
         }
      if (error==-1)
      {  
         Print("Error  " ,GetLastError()," ",symbol);
         err++;Sleep(2000);RefreshRates();
      }
      if (error!=-1 || err >20) return;
   }
  return;
} 
//--------------------------------------------------------------------
bool CloseAll()
{ 
   bool error=true;
   int  err,nn,OT;
   for (int j = OrdersTotal()-1; j >= 0; j--)
     {
      if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber()==Magic)
         {
           OT = OrderType();
           if (OT<2) 
           {
             while(true)
               {
                if (OT==OP_BUY)  error=OrderClose(OrderTicket(),OrderLots(),
                                                  NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID),MarketInfo(OrderSymbol(),MODE_DIGITS)),3,Blue);
                if (OT==OP_SELL) error=OrderClose(OrderTicket(),OrderLots(),
                                                  NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK),MarketInfo(OrderSymbol(),MODE_DIGITS)),3,Red);
                if (error) break;
                else
                  {
                   err++;
                   if (err>10) break;
                   Sleep(1000);
                   RefreshRates();
                  }                                
               }
            }
  
         }
      }
   ProfitMax = 0;
   return(1);
}
//--------------------------------------------------------------------
int Terminal()
  {
   int Qnt=0;                         
   Qnt=0;                              
   ArrayInitialize(Mas_Tip_Symb1, 0);  
   ArrayInitialize(Mas_Tip_Symb2, 0);       
   for(int i=0; i<OrdersTotal(); i++) 
     {
      if(OrderSelect(i,SELECT_BY_POS)==true && OrderMagicNumber()==Magic)     
         {
          Qnt++;                              
          if(OrderSymbol()==Symbol_1) Mas_Tip_Symb1[OrderType()]++;  
          if(OrderSymbol()==Symbol_2) Mas_Tip_Symb2[OrderType()]++;    
         }
      }
   return(Qnt);
  }
//-------------------------------------------------------------------
int Create(datetime TimeL)                          
  {                                   
   ObjectCreate(WindowExpertName(), OBJ_VLINE, 0, TimeL, 0);
   ObjectSet(   WindowExpertName(), OBJPROP_COLOR, Blue);   
   ObjectSet(   WindowExpertName(), OBJPROP_STYLE, DRAW_LINE);
   ObjectSet(   WindowExpertName(), OBJPROP_WIDTH, 1);
   WindowRedraw();                     
  }
//------------------------------------------------------------------- 
void CountLots()
  {
   double Min_Lot = MarketInfo(Symbol(),MODE_MINLOT);         // ����������� ���������� �����
   double Max_Lot = MarketInfo(Symbol(),MODE_MAXLOT);         // ������������ ���������� �����   
   if(MM<1)  lot = Lot; 
   if(MM==1) lot += Lot;
   if(MM>1)  lot = lot*MM;
   lot = NormalizeDouble(lot,2);
   if(lot < Min_Lot) lot = Min_Lot;                   
   if(lot > Max_Lot) lot = Max_Lot;             
 }
//--------------------------------------------------------------------- 