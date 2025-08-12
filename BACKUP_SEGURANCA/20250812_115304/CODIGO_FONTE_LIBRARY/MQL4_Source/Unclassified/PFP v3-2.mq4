//+------------------------------------------------------------------+
//|                                                          PFP.mq4 |
//|                                              Copyright 2012, 165 |
//|                                        http://www.eckras.yomu.ru/|
//|                                     �� �������: WMR 418193222614 |
//+------------------------------------------------------------------+
// 1-1 �������� ���������� ���� ��� ������������ �������� 
// 1-2 �������� ���������� ����
// 1-3 ������� ������� ����������, ��� �������� �� ����� ����������
#property copyright "Copyright 2012, 165"
#property link      "http://www.eckras.yomu.ru/"

extern string     _Add_Op1 = "������� ���������";
extern double     StartLots=0.01; 
extern double     Mul=2; 
 
extern int        MODE = 2;
extern int        TimeStart=5;     //��� ������ ������
extern int        TimeEnd=23;     //��� ����� ������
extern int        Slippage = 3;     // ���������� ��������������� ����
extern int        Magic=16500;     //�����

extern string     _Add_Op3 = "�������� ���������";
extern color      clOpenBuyStop      = Indigo;    // ���� ������ �������� Buy
extern color      clOpenSellStop     = LightCoral;   // ���� ������ �������� Sell
//extern color      clModifyBuy        = LightBlue;    // ���� ������ �������� Buy
//extern color      clModifySell       = LightCoral;   // ���� ������ �������� Sell
extern color      clCloseBuy         = LightBlue;    // ���� ������ �������� Buy
extern color      clCloseSell        = LightCoral;   // ���� ������ �������� Sell

double dPivot; //�����
double dSoprot1;
double dSoprot2;
double dSoprot3;
double dPodder1;
double dPodder2;
double dPodder3;

int   iWorks = 0;    // 0-��� �������, 1-����������, 2-�������� �������� �����
double   pp;   // ��������� �� 4� ���� = 1, �� 5 ���� = 10
int   iKolOrders = 0;   //���������� ������� ������� ������ ���� �������
int   TypeMarketOrder;   //��� ��������� ������ 1-�, 2-�
double   Balans = 0;       //������
double   iLots;         //��� ������� ����� ����������� ������, ����� ������������� ��� �������
double   SPREAD,STOPLEVEL;
int   TIME=-1;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init(){
   if (Digits < 4) {
      pp = 0.01;
   }else {
      pp = 0.0001;
   }
   if (OrdersTotal()==0) iLots = StartLots;
   SPREAD=MarketInfo(Symbol(),(MODE_SPREAD))*pp;
   STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL)*pp;
   if (STOPLEVEL==0) STOPLEVEL=0.0003;
   return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start(){
   int total, ii;
   CheckLot(); //��������� ���
   Comment("�� ��������: WMR 418193222614 \n �����: \n ���: ",TimeHour(TimeCurrent())," - ",TimeMinute(TimeCurrent())," \n �����: ",dPivot," \n �������������: ",dSoprot1," \n ���������: ",dPodder1," \n ���: ",iLots);
   // ������� ����� ��� ������� ������
   if (TIME!=TimeDay(TimeCurrent())){
      //if (!bnew_day) PFP();
      PFP();
      TIME=TimeDay(TimeCurrent());
      //Alert(TIME);
   }
   // ���� ����� ��������� � ����� ������������� ���������� ������
   if (IsTradeTime() ){
      //���� ��� �������� ������
      if (check()==0 && iWorks==0){    //��� �� ���������� ������
         //��������� ��� ��������� ����, ��������� ����� ���������� � ��������������
         if ((Close[0]<(dSoprot1-STOPLEVEL*2))&&(Close[0]>(dPodder1+STOPLEVEL*2))){
            //���������� ������
            OpenBuyLimitOrder(NormalizeDouble(iLots,2),dPodder1,dPodder2+SPREAD, dPivot);
            OpenBuyLimitOrder(NormalizeDouble(iLots*Mul,2),dPodder2,dPodder3+SPREAD, dPodder1);
            OpenBuyLimitOrder(NormalizeDouble(iLots*Mul*Mul,2),dPodder3,NormalizeDouble(dPodder3 - dPodder2 +dPodder3,Digits),dPodder2);
            OpenSellLimitOrder(NormalizeDouble(iLots,2),dSoprot1,dSoprot2-SPREAD, dPivot);
            OpenSellLimitOrder(NormalizeDouble(iLots*Mul,2),dSoprot2,dSoprot3-SPREAD, dSoprot1);
            OpenSellLimitOrder(NormalizeDouble(iLots*Mul*Mul,2),dSoprot3,NormalizeDouble(dSoprot3 - dSoprot2 +dSoprot3,Digits),dSoprot2);
            iWorks=1;
            iKolOrders=check();
            Balans=AccountEquity();
         }
      }else{
         if (iKolOrders!=check()){//������ ��� ������ ����� �� �����
            if (OrderSelect(GetHistOrdTicketByNumber(0,Symbol(),Magic),SELECT_BY_TICKET)){
               if (OrderProfit()<0){ //����� ��� ������ �� ���� ����
                  iLots=OrderLots()*Mul;
               }
               if (OrderProfit()>=0){
                  iLots=StartLots;
                  close_();
                  iKolOrders=check();
               }
            }
         }
         if (MarketOrders()!=0){//���� �������� �����
            if (MarketOrders() ==1)close_reserve_sell();
            if (MarketOrders() ==2)close_reserve_buy();
            iKolOrders=check();
         }
      } 
   }
   else { //�� �������� �����
      if (check()>0){
         //��������� ������
         close_();
         //bnew_day=false;
      }
      iWorks=0;
      iKolOrders=check();
   }
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int check(){
   int kol=0;
   int total = OrdersTotal() - 1;   
   for (int i = total; i >= 0; i--) { 
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == Magic){
            kol++;
         }
      }
   }
   return(kol);
}
//+------------------------------------------------------------------+
//| MarketOrders ��������� ���� �� �������� ������                   |
//| 0-��� ������, 1-������ �, 2-������ �                             |
//+------------------------------------------------------------------+
int MarketOrders(){
   int total = OrdersTotal() - 1;   
   for (int i = total; i >= 0; i--) { //--- ������� �������� �������
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == Magic){
            if (OrderType() == OP_BUY) return(1);
            if (OrderType() == OP_SELL){
               return(2);       
            }
         }       
      }    
   } 
   return (0);
}
//+------------------------------------------------------------------+
//| ����������� ����������� ������� � ��������� ����������.          |
//+------------------------------------------------------------------+
void close_(){  
   CloseAll();
   close_reserve();
}
//+------------------------------------------------------------------+
//| �������� ������� �� magic ������.                                |
//+------------------------------------------------------------------+
void close_reserve(){
   int total = OrdersTotal() - 1;   
   for (int i = total; i >= 0; i--){ //--- ������� �������� �������
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if (OrderMagicNumber() == Magic){
            if (OrderType() == OP_BUYLIMIT) OrderDelete(OrderTicket());
            if (OrderType() == OP_BUYSTOP)  OrderDelete(OrderTicket());
            if (OrderType() == OP_SELLLIMIT)OrderDelete(OrderTicket());
            if (OrderType() == OP_SELLSTOP) OrderDelete(OrderTicket());           
         }    
      }    
   } 
}
//+------------------------------------------------------------------+
//| �������� ������� �� magic ������.                                |
//+------------------------------------------------------------------+
void close_reserve_buy(){
   int total = OrdersTotal() - 1;   
   for (int i = total; i >= 0; i--){ //--- ������� �������� �������
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if (OrderMagicNumber() == Magic){
            if (OrderType() == OP_BUYLIMIT) OrderDelete(OrderTicket());          
         }    
      }    
   } 
}
//+------------------------------------------------------------------+
//| �������� ������� �� magic ������.                                |
//+------------------------------------------------------------------+
void close_reserve_sell(){
   int total = OrdersTotal() - 1;   
   for (int i = total; i >= 0; i--){ //--- ������� �������� �������
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if (OrderMagicNumber() == Magic){
            if (OrderType() == OP_SELLLIMIT) OrderDelete(OrderTicket());          
         }    
      }    
   } 
}
//+------------------------------------------------------------------+
//| �������� ���� �������� �������.                                  |
//+------------------------------------------------------------------+
void CloseAll(){
   int total = OrdersTotal() - 1;   
   for (int i = total; i >= 0; i--) { //--- ������� �������� �������
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)){
         if (OrderMagicNumber() == Magic){
            if (OrderType() == OP_SELL)
               OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 20, Yellow);
            else
               if (OrderType() == OP_BUY)
                  OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 20, Yellow);
            
         }    
      }    
   }
}
//+------------------------------------------------------------------+
//| IsTradeTime ������ true ����� ���������                          |
//+------------------------------------------------------------------+
bool IsTradeTime() {
   if (TimeStart < TimeEnd && TimeHour(TimeCurrent()) < TimeStart || TimeHour(TimeCurrent()) >= TimeEnd) return (FALSE);
   if (TimeStart > TimeEnd && (TimeHour(TimeCurrent()) < TimeStart && TimeHour(TimeCurrent()) >= TimeEnd)) return (FALSE);
   return (TRUE);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| IsPivotTime ������ true ����� ����� ���������� ������, � 1 ���   |
//| ��� �� �� 1 ��� � ���� ������ ��������� ������ �����             |
//+------------------------------------------------------------------+
bool IsPivotTime() {
   if ((TimeStart == TimeHour(TimeCurrent()))&&(TimeMinute(TimeCurrent()) == 0)) return (true);
   return (false);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| OpenBuyLimitOrder. �������� ������ BuyStop                        |
//+------------------------------------------------------------------+
int OpenBuyLimitOrder(double iiLot, double iiPrice, double iiSL, double iiTP){
   int iierr, iiticket=-1;
   int n=3;
   while (IsTradeAllowed()==false) Sleep(1000);
   while (iiticket<0 && n>0){
      iiticket=OrderSend(Symbol(), OP_BUYLIMIT, iiLot, iiPrice, Slippage, iiSL, iiTP, "", Magic, 0, clOpenBuyStop);
      n--;
   }
   if (iiticket<0) {
      iierr=GetLastError();
      Print("IIError(",iierr,") open ",GetNameOP(OP_BUYSTOP)," ���� ������=",iiPrice," ���� ������ ���=",MarketInfo(Symbol(), MODE_ASK)," loss=",iiSL," Profit=",iiTP ); 
   }
   return(iiticket);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| OpenSellLimitOrder. �������� ������ SellStop                      |
//+------------------------------------------------------------------+
int OpenSellLimitOrder(double iiLot, double iiPrice, double iiSL, double iiTP){
   int iierr, iiticket=-1;
   int n=3;
   while (IsTradeAllowed()==false) Sleep(1000);
   while (iiticket<0 && n>0){
      iiticket=OrderSend(Symbol(), OP_SELLLIMIT, iiLot, iiPrice, Slippage, iiSL, iiTP, "", Magic, 0, clOpenSellStop);
      n--;
   }
   if (iiticket<0) {
      iierr=GetLastError();
      Print("12Error(",iierr,") open ",GetNameOP(OP_SELLSTOP)); 
   }
   return(iiticket);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CheckLot. ������� ��� � ��� � ���                                |
//+------------------------------------------------------------------+
void CheckLot(){
   if (iLots<MarketInfo(Symbol(),MODE_MINLOT)) iLots = MarketInfo(Symbol(),MODE_MINLOT);
   if (iLots>MarketInfo(Symbol(),MODE_MAXLOT)) iLots = MarketInfo(Symbol(),MODE_MAXLOT);
   return(0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| PFP. ����������� ���������, � ������� �� ���� ����. (��� � �����)|
//+------------------------------------------------------------------+
void PFP(){
   int now_time;
   double R; 
   double rates[5][6],yesterday_close,yesterday_high,yesterday_low;
   bool     bnew_day = false;   //��� �� ������ ����� ������ 1 ���
   now_time = TimeDay(Time[0]);
   yesterday_high = 0;
   yesterday_low = 0;
   for (int ii=1; ii<=2880; ii++){
      //Print("Data = ",TimeDay(Time[ii])); 
      if ((TimeDay(Time[ii])!=now_time)&&(bnew_day==false)&&(TimeDayOfWeek(Time[ii])!=0)&&(TimeDayOfWeek(Time[ii])!=6)){
         yesterday_close = Close[ii];
         bnew_day=true;
         now_time = TimeDay(Time[ii]);
         yesterday_high = High[ii];
         yesterday_low = Low[ii];
      }
      if ((bnew_day==True)&&(TimeDay(Time[ii])!=now_time)) {
         break;
      }
      if (bnew_day==true){
         if (High[ii]>yesterday_high)yesterday_high = High[ii];
         if (Low[ii]<yesterday_low) yesterday_low = Low[ii];
      }
   }
   R = (yesterday_high - yesterday_low);//range
   dPivot = (yesterday_high + yesterday_low + yesterday_close)/3;// Standard Pivot
   dSoprot3 = NormalizeDouble(dPivot + (R * 1.000),Digits);
   dSoprot2 = NormalizeDouble(dPivot + (R * 0.618),Digits);
   dSoprot1 = NormalizeDouble(dPivot + (R * 0.382),Digits);
   dPodder1 = NormalizeDouble(dPivot - (R * 0.382),Digits);
   dPodder2 = NormalizeDouble(dPivot - (R * 0.618),Digits);
   dPodder3 = NormalizeDouble(dPivot - (R * 1.000),Digits);
   return(0);
}
//+------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//|  �������� : ���������� ������������ �������� ��������                      |
//+----------------------------------------------------------------------------+
//|  ���������:                                                                |
//|    op - ������������� �������� ��������                                    |
//+----------------------------------------------------------------------------+
string GetNameOP(int op) {
   switch (op) {
      case OP_BUY      : return("Buy");
      case OP_SELL     : return("Sell");
      case OP_BUYLIMIT : return("BuyLimit");
      case OP_SELLLIMIT: return("SellLimit");
      case OP_BUYSTOP  : return("BuyStop");
      case OP_SELLSTOP : return("SellStop");
      default          : return("Unknown Operation");
   }
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                 Function:GetHistOrdTicketByNumber(int,string,int)|
//+------------------------------------------------------------------+
//|               Description:                                       |
//+------------------------------------------------------------------+
int GetHistOrdTicketByNumber(int num,string sy="",int mn=0){
   int i,ii,tickets[5000][3];
   ii=0;
   for(i=OrdersHistoryTotal();i>=0;i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)){
         if(sy!=""){if(OrderSymbol()!=sy){continue;}}
         if(mn!=0 ){if(OrderMagicNumber()!=mn){continue;}}
         tickets[ii][0]=OrderCloseTime();
         tickets[ii][1]=OrderTicket();
         //tickets[ii][2]=OrderType();
         ii++;
      }
   }
   ArrayResize(tickets,ii);
   ArraySort(tickets,WHOLE_ARRAY,0,MODE_DESCEND);
   //Print(" ��������� �������� ������, ����� 1 = ",tickets[1][1],"  ������ = ",tickets[1][2]," history = ",OrdersHistoryTotal());
   //Print(" ��������� �������� ������, ����� 0 = ",tickets[0][1],"  ������ = ",tickets[0][2]);
   return(tickets[num][1]);
}