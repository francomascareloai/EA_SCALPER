/*
�������� �������� ������ �� �����������
***************************************
������� ��������� ������� ����������� �������
101.102.103.104.105 - �������������� ������ �� ���
201.202.203.204.205 - �������������� ������ �� ����
*/

extern double StartLots = 0.1;
extern double Step = 20;
extern double StepFactor = 1;

extern double TimeOut = 5000;






//&& (OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT)
//**********************************************************************
// ������� �������� ������� ���������� ��� ���� �������� ������� �� ���� ������������� ������ ����� - ��� ���� // PRICE = ���� ������ �����������
//**********************************************************************
void setNewTakeProfitBuy(double NewTP) { 
   int TotalOrd, TekOrd, Tiket, Error;
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber() >= 101 &&  OrderMagicNumber() <= 105) {
         if (NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(NewTP, Digits) ) {
            Tiket = OrderModify(OrderTicket(), OrderOpenPrice(), 0, NewTP, 0, Green);
            Print ("����������� TP ��� OP_BUY. TP_New = ", OrderTakeProfit(), "->", NewTP, "  lots= ", OrderLots(), " num= ", OrderTicket());
            Print ("��������� = ",Tiket);
            if (Tiket !=1 ) {Error = GetLastError(); Print ("������ = ", Error); }                  
            Sleep(TimeOut);
         }
      }
   }  
}
//**********************************************************************
// ������� �������� ������� ���������� ��� ���� �������� ������� �� ���� ������������� ������ ����� - ��� ����� // PRICE = ���� ������ �����������
//**********************************************************************
void setNewTakeProfitSel(double NewTP) { 
   int TotalOrd, TekOrd, Tiket, Error;
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderType()==OP_SELL  && OrderMagicNumber() >= 201 &&  OrderMagicNumber() <= 205) {
         if ( NormalizeDouble(OrderTakeProfit(),Digits) != NormalizeDouble(NewTP, Digits) ) {
            Tiket = OrderModify(OrderTicket(), OrderOpenPrice(), 0, NewTP, 0, Yellow);
            Print ("����������� TP ��� OP_SELL. TP_New = ", OrderTakeProfit(), "->", NewTP, "  lots= ", OrderLots(), " num= ", OrderTicket() );
            Print ("��������� = ",Tiket);
            if (Tiket !=1 ) {Error = GetLastError(); Print ("������ = ", Error); }                  
            Sleep(TimeOut);
         } 
      }
   }   
}
//********************************************************************
//
//������� ��� ����������� ���������� ������� ������
//
//********************************************************************
// ���������� ���� �������� ������, ������� ��� �� ����������� (����� ��� ��������� 
// ����������� ������ ������ ������ ����� ��� ��� ����������� ���� ��������������  ����������� ������)      
//********************************************************************
double getNextOrderPriceByNum(int n1, double p1){
   switch (n1) {
      case 101: return (p1-Step*Point); //��� ������ ���� ���������� ������ ���� �� ��� � ������ �������
      case 102: return (p1-Step*MathPow(StepFactor,1)*Point);
      case 103: return (p1-Step*MathPow(StepFactor,2)*Point);
      case 104: return (p1-Step*MathPow(StepFactor,3)*Point);   
      case 201: return (p1+Step*Point); //��� ������ ���� ���������� ������ ���� �� ��� � ������ �������  
      case 202: return (p1+Step*MathPow(StepFactor,1)*Point);
      case 203: return (p1+Step*MathPow(StepFactor,2)*Point);
      case 204: return (p1+Step*MathPow(StepFactor,3)*Point);   
   }
   return (0);        
}
//********************************************************************
//������� ����������� ����������� ������
//����� �������� ����������� ���� �������� � ����������� ��� ���������� �������
//� ���� ��� ���������� �� ��� ��������������� ������, �������� ��
//********************************************************************
int modOrder(int num, double oprice, double prprice){
    int t, cnt1, tic, err;
    double p1, p2;
    t=OrdersTotal();
    for(cnt1=0;cnt1<t;cnt1++){
       OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
       if (OrderSymbol()==Symbol() && OrderMagicNumber()==num){ 
          if ((OrderOpenPrice()!=oprice || OrderTakeProfit()!=prprice) && oprice!=0 && prprice!=0) {     
             if (OrderType()==OP_BUYLIMIT){
                p1=oprice;
                p2=prprice;
               //NormalizeDouble(p2,Digits);
               if (NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(p1,Digits) || NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(p2,Digits) ) { 
                  //if (OrderOpenPrice()!=p1 || OrderTakeProfit()!=p2) {
                  tic=OrderModify(OrderTicket(),p1,0,p2,0,Red);
                  Print ("����� BUYLIMIT ", OrderOpenPrice(), "->", p1, " t/p ", OrderTakeProfit(),"->", p2);
                  Print ("��������� = ",tic);
                  if (tic!=1) {err=GetLastError(); Print ("������ = ",err);}                     
                Sleep(TimeOut);
                 }
              }
              if (OrderType()==OP_SELLLIMIT){
                  p1=oprice;
                  p2=prprice;
                 if (NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(p1,Digits) 
                     || NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(p2,Digits)) { 
                      tic=OrderModify(OrderTicket(),p1,0,p2,0,Green);
                      Print ("����� SELLLIMIT ", OrderOpenPrice(), "->", p1, " t/p ", OrderTakeProfit(),"->", p2);
                      Print ("��������� = ",tic);
                      if (tic!=1) {err=GetLastError();
                      Print ("������ = ",err);}                       
                      Sleep(TimeOut);
                  }                       
              }              
            }
          }
      }  
      return (1);      
     }    


//********************************************************************
//
// ����������� �������
//
//********************************************************************
//
// ���� �������� � ����������� ����������
//
//********************************************************************
// ��� ������� ��������� ������� ������ � ������ ���������� �������
// MODE - ��� �������� : 1=������ ��������� ��� ����� 2=��������� ��� ����� ��� BUYSTOP,SELLSTOP
// NUM - ����������� ���������� ����� ������
//********************************************************************
bool isMagNum(int mode, int num) { 
   int TotalOrd, TekOrd;     
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (mode == 1) {
         if (OrderMagicNumber()==num && OrderSymbol()==Symbol()) return (True); // ������������ ��������
      }
      if (mode == 2) {
         if (OrderMagicNumber()==num && OrderSymbol()==Symbol() && (OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP) ) return (True); // ������������ ��������
      }
   }  
return (False); }
//********************************************************************
//�������, ����������� ����������� �� ������ ����� � �������� �������   
//********************************************************************
bool isOrderActive(int num) {       
   int TotalOrd, TekOrd;     
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()== num && (OrderType()==OP_BUY || OrderType()==OP_SELL)) { return (True); } // ������������ ��������
   }  
   return (False);   
} 
//********************************************************************
//����� ���������� ������������ ���������� ����� ��������� ������ ��� ������
//********************************************************************
int getMaxLongNum(){
   int topL = 0, TotalOrd, TekOrd;
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()>topL) topL = OrderMagicNumber(); 
   }  
   return (topL); // ������������ ���������� ����� ������    
}
//********************************************************************
//����� ���������� ������������ ���������� ����� ��������� ������ ��� ������
//********************************************************************
int getMaxShortNum(){
   int topL = 0, TotalOrd, TekOrd;
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()>topL ) topL = OrderMagicNumber();
   }  
   return (topL); // ������������ ���������� ����� ������
}
//********************************************************************
//����������� ������������ (��������) ������ ��� �������� ������� ��� �������� ������� 
//********************************************************************
int getTopLevel (int mode) {       
   int TotalOrd, TekOrd, MaxLevel, cLev=0;
   TotalOrd = OrdersTotal();
   if (mode == 1) { //�������� ������ ��� ������
      for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol()==Symbol() && OrderType()==OP_BUY ) { //������ �������������� �������
            switch (OrderMagicNumber()) {
               case 105: cLev=5; break; 
               case 104: cLev=4; break;
               case 103: cLev=3; break;
               case 102: cLev=2; break;
               case 101: cLev=1; break;
            } 
            if (cLev > MaxLevel) MaxLevel = cLev;   
         }  
      }    return (MaxLevel);   
   }  
//********************************************************************
   if (mode == 2) { //�������� ������ ��� ������
      for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol()==Symbol() && OrderType()==OP_SELL ) { //������ �������������� �������
            switch (OrderMagicNumber()) {
               case 205: cLev=5; break; 
               case 204: cLev=4; break;
               case 203: cLev=3; break;
               case 202: cLev=2; break;
               case 201: cLev=1; break;             
            } 
            if (cLev > MaxLevel) MaxLevel = cLev;   
         }  
      }  return (MaxLevel); 
   }
}
//*******************************************************
// ��������� ���� �������� ������ �� ��� ����������� ������ === ������� ��� ��������� ���� �������� ������ �� ��� ������
//*******************************************************
double getOrderPriceByNum (int num) {       
   int t, cnt1;     
   t=OrdersTotal();
   for(cnt1=0;cnt1<t;cnt1++){
      OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()== num) { return (OrderOpenPrice()); }
   }  
   return (0);   
}
///************************************************************************
//����������� ���������� ����������� ������ �� �������     
//********************************************************************
int getNextOrderNum(int n1){
   switch (n1) {
      case 101: return (102); 
      case 102: return (103); 
      case 103: return (104); 
      case 104: return (105); 
      case 201: return (202); 
      case 202: return (203); 
      case 203: return (204); 
      case 204: return (205); 
    }
    return (0);       
}
//******************************************************
//����������� ������� ����� ��������� �� ��������� ������ ������
//******************************************************
double getLotByLevel(int Level) {       
   double Lot1;
   Lot1 = StartLots;//�������� �� ���������
   switch( Level ) {
      case 3: Lot1 = StartLots*2; break;
      case 4: Lot1 = StartLots*4; break;
      case 5: Lot1 = StartLots*8; break;
   }
   return (Lot1);
}
//********************************************************************
//
// ���� ����������� �������
//
//********************************************************************   
// ����������� ������ ������� ����� BUY & SELL
//********************************************************************
   //                ������  ��� ����  ��� ����        ���� ����  SL TP              �����������                 ��� ���
void Create_Prima_Buy() { 
   int Tiket, Error;
   Tiket = OrderSend(Symbol(), OP_BUY, StartLots, Ask,  3,  0, Ask+Step*Point,"101 ������ ������� ������", 101,0, Red);
   Print("�������� ������ ������� ����� ������ 101 ��� -> ",Symbol(),"  Ask = ", Ask,"  T/P = ",Ask+Step*Point,"  �i�et = ",Tiket);
   if ( Tiket == -1 ) {Error = GetLastError(); Print ("������ �������� ������ ������� ������ 101 = ",Error); } 
   Sleep(TimeOut);
}
//********************************************************************
void Create_Prima_Sell() { 
   int Tiket, Error;
   Tiket = OrderSend(Symbol(), OP_SELL, StartLots, Bid,3,0,Bid-Step*Point,"201 ������ ������� ������", 201, 0, Green);
   Print("�������� ������ ������� ����� ������ 201 ��� -> ",Symbol(),"  Bid = ", Bid, " �/� = ", Bid-Step*Point, "  �iket = ",Tiket);
   if (Tiket == -1) {Error = GetLastError(); Print ("������ �������� ������ ������� ����� ������ 201 = ", Error); } 
   Sleep(TimeOut);
}   
//********************************************************************
// ����������� ������ ������� ����� BUY_STOP & SELL_STOP
//********************************************************************
void Create_Modify_Prima_BuyStop() { 
   int TotalOrd, TekOrd;     
   int Tiket, Error;
   int MaxMagNumBuy;       // ����� ���������� ������������ ���������� ����� ��������� ������ ��� ������
   double OrderPriceBuy ;  // ���� �������� ������ �� ��� ����������� ������
   double PriceBuyStop; // ���� �������� ����������� ������ STOP
// ���������� ���� �������� ������ ����������� ������ �1 ����� ����� ���� ������������� �������� �����������               
   MaxMagNumBuy  = getMaxLongNum();                    // ����� ���������� ������������ ���������� ����� ��������� ������ ��� ������
   OrderPriceBuy = getOrderPriceByNum( MaxMagNumBuy ); // ��������� ���� �������� ������ �� ��� ����������� ������
   PriceBuyStop  = OrderPriceBuy + Step*Point + (Point * MarketInfo(Symbol(),MODE_SPREAD) ); // ���� �������� ����������� ������ STOP
// ��������� ���� �� ���������� ����� 
   if (isMagNum(2,101) == False) { //--- ���� ��� �� ������� �����
      Tiket = OrderSend(Symbol(), OP_BUYSTOP, StartLots, PriceBuyStop,  3,  0, PriceBuyStop + Step*Point,"BUY_STOP_�101", 101,0, Red);
      Print("�������� BUY_STOP_�101 ��� -> ",Symbol(),"  Ask = ", PriceBuyStop,"  T/P = ",PriceBuyStop+Step*Point,"  �i�et = ",Tiket);
      if ( Tiket == -1 ) {Error = GetLastError(); Print ("������ �������� BUY_STOP_�101 = ",Error); } 
      Sleep(TimeOut); }
   else { //--- ����� ��������� ��� � ���� ���� ������������ ���
      TotalOrd = OrdersTotal();
      for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber()==101 && OrderSymbol()==Symbol() && OrderType()==OP_BUYSTOP ) { // ����� ���������� ����� BUY_STOP
            if (NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(PriceBuyStop,Digits) || NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble((PriceBuyStop + Step*Point),Digits) ) { 
               Tiket = OrderModify(OrderTicket(),PriceBuyStop,0,(PriceBuyStop + Step*Point),0,Red);
               Print ("����������� BUY_STOP_�101 ", OrderOpenPrice(), "->", PriceBuyStop, " t/p = ", OrderTakeProfit(),"  -> ", (PriceBuyStop + Step*Point));
               if ( Tiket == 0 ) {Error = GetLastError(); Print ("������ ����������� BUY_STOP_�101 = ",Error); } 
               Sleep(TimeOut); break;
            }
         }
      }  
   }
}
//********************************************************************
//********************************************************************
void Create_Modify_Prima_SellStop() { 
   int TotalOrd, TekOrd;     
   int Tiket, Error;
   int MaxMagNumSell;       // ����� ���������� ������������ ���������� ����� ��������� ������ ��� ������
   double OrderPriceSell ;  // ���� �������� ������ �� ��� ����������� ������
   double PriceSellStop; // ���� �������� ����������� ������ STOP
// ���������� ���� �������� ������ ����������� ������ ��� ������ �1 ����� ����� ���� ������������� �������� �����������
   MaxMagNumSell  = getMaxShortNum();                     // ����� ���������� ������������ ���������� ����� ��������� ������ ��� ������
   OrderPriceSell = getOrderPriceByNum( MaxMagNumSell ); // ��������� ���� �������� ������ �� ��� ����������� ������
   PriceSellStop  = OrderPriceSell - Step*Point - (Point * MarketInfo(Symbol(),MODE_SPREAD) ); // ���� �������� ����������� ������ STOP
// ��������� ���� �� ���������� ����� 
   if (isMagNum(2,201) == False) { //--- ���� ��� �� ������� �����
      Tiket = OrderSend(Symbol(), OP_SELLSTOP, StartLots, PriceSellStop, 3, 0, PriceSellStop - Step*Point,"SELL_STOP_�201", 201, 0, Green);
      Print("�������� SELL_STOP_�201 ��� -> ",Symbol(),"  Bid = ", Bid, " �/� = ", Bid-Step*Point, "  �iket = ",Tiket);
      if (Tiket == -1) {Error = GetLastError(); Print ("������ �������� SELL_STOP_�201 = ", Error); } 
      Sleep(TimeOut); }
   else {
      TotalOrd = OrdersTotal();
      for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber()==201 && OrderSymbol()==Symbol() && OrderType()==OP_SELLSTOP ) { // ����� ���������� ����� BUY_STOP
            if (NormalizeDouble(OrderOpenPrice(),Digits)!=NormalizeDouble(PriceSellStop,Digits) || NormalizeDouble(OrderTakeProfit(),Digits)!=NormalizeDouble(PriceSellStop - Step*Point,Digits)) { 
               Tiket = OrderModify(OrderTicket(),PriceSellStop,0,(PriceSellStop - Step*Point),0,Green);
               Print ("����������� SELL_STOP_�201 ", OrderOpenPrice(), "->", PriceSellStop, " t/p = ", OrderTakeProfit(),"  -> ", PriceSellStop - Step*Point);
               if ( Tiket == 0 ) {Error = GetLastError(); Print ("������ ����������� SELL_STOP_�201 = ",Error); } 
               Sleep(TimeOut); break;
            }                       
         }
      }
   }
}   
//********************************************************************
//
// ���� �������� �������
//
//********************************************************************   
//������� �������� ������ �� ����������� ������ 
//********************************************************************   
bool deleteOrderNum(int num) { // NUM - ���������� ����� ������ ��� ��������
   int TotalOrd, TekOrd, Tiket, Error;     
   TotalOrd = OrdersTotal();
   for(TekOrd = 0; TekOrd < TotalOrd; TekOrd++) { OrderSelect(TekOrd, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderMagicNumber()== num ) {
         Print ("�������� ������ � = ", num, "   Tiket = ", OrderTicket() );
         Tiket = OrderDelete(OrderTicket()); 
         if (Tiket == 0) {Error = GetLastError(); Print ("������ �������� = ",Error);} 
         Sleep(1000); return (True);
      }   
   }  
   return (False);   
}     
//********************************************************************   
// ������ ��� �������� ���������� ������ (������� ��� ����������� + 1) ��� ����
//********************************************************************   
void Delete_BuyLimit_Old(){
   int NomMaxBuy;
// �������� ������ ������, ���� ��� ������ ������ �������
   if (isOrderActive(101) == False) { 
      if (isMagNum(1,102) == True) deleteOrderNum(102); 
      if (isMagNum(1,103) == True) deleteOrderNum(103); 
      if (isMagNum(1,104) == True) deleteOrderNum(104); 
      if (isMagNum(1,105) == True) deleteOrderNum(105); 
      return;
   }
//********************************************************************
// ����� ������ ������ ���������� ������ ��� ������
// ��� ����� ��� ���������� ����� ����� ������������ �������� ���� , 
// ���������� ��������� �� ������ �������� ����� � ������� ��� ���������
//********************************************************************
   NomMaxBuy = getMaxLongNum();                //����� ��������, ����� �������� ������� (��������) �����������
   if (NomMaxBuy  == 101 ) { 
      if (isMagNum(1,103) == True) deleteOrderNum(103); 
      if (isMagNum(1,104) == True) deleteOrderNum(104); 
      if (isMagNum(1,105) == True) deleteOrderNum(105); 
      return;
   }
   if (NomMaxBuy  == 102 ) { 
      if (isMagNum(1,104) == True) deleteOrderNum(104); 
      if (isMagNum(1,105) == True) deleteOrderNum(105); 
      return;
   }
   if (NomMaxBuy  == 103 ) { 
      if (isMagNum(1,105) == True) deleteOrderNum(105); 
      return;
   }
}
//********************************************************************   
// ������ ��� �������� ���������� ������ (������� ��� ����������� + 1) ��� �����
//********************************************************************   
void Delete_SellLimit_Old(){
   int NomMaxSell;
// �������� ������ ������, ���� ��� ������ ������ �������
   if (isOrderActive(201) == False) { 
      if (isMagNum(1,202) == True) deleteOrderNum(202); 
      if (isMagNum(1,203) == True) deleteOrderNum(203); 
      if (isMagNum(1,204) == True) deleteOrderNum(204); 
      if (isMagNum(1,205) == True) deleteOrderNum(205); 
      return;
   }
   NomMaxSell = getMaxShortNum(); // ����� ��������, ����� �������� ������� (��������) �����������
   if (NomMaxSell  == 201 ) { 
      if (isMagNum(1,203) == True) deleteOrderNum(203); 
      if (isMagNum(1,204) == True) deleteOrderNum(204); 
      if (isMagNum(1,205) == True) deleteOrderNum(205); 
      return;
   }
   if (NomMaxSell  == 202 ) { 
      if (isMagNum(1,204) == True) deleteOrderNum(204); 
      if (isMagNum(1,205) == True) deleteOrderNum(205); 
      return;
   }
   if (NomMaxSell  == 203 ) { 
      if (isMagNum(1,205) == True) deleteOrderNum(205); 
      return;
   }
}
//********************************************************************
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//********************************************************************
int start() {
//********************************************************************
//
// ����������� ����������
//
//********************************************************************
   double sig=0, curPrice, topLot, devPrice, newPrice, newPriceSel, newPriceBuy;
   double lastOpenPrice, curProfitPriceBuy, curProfitPriceSell, nullPrice, nullPrice2;
   int cnt, ticket, total, pr,  openPos, topLev, direct, topLevBuy, topLevSell; 
   int n1, n2, err;
   double p1, p2, prof, tpBuy, tpSell;
//********************************************************************
// ��������� ��������� �������� �� ����������� �������� ����� �� �����
// �������� ������������ ���������� ����� �� �����
//********************************************************************
if(AccountFreeMargin()<(500)) { Print("���� ����� �� �����. Free Margin = ", AccountFreeMargin()); return(0); }
//********************************************************************
// �������� ������ ������� ������� �� �����        
//********************************************************************
if(AccountEquity()<(600)) { Print("������ ����� ������� ����� = ", AccountEquity()); return(0); }
//********************************************************************
//
// �������� ���� �� ����� 1 ������� ��� ���� � �����
//
//********************************************************************
if (isMagNum(1,101) == False) Create_Prima_Buy();  // �������� ���� �� ����� 1 ������� ��� ����, ���� ��� ��� �� ������ �����1
if (isMagNum(1,201) == False) Create_Prima_Sell(); // �������� ���� �� ����� 1 ������� ��� �����, ���� ��� ��� �� ������ �����1
//********************************************************************
//
// �������� ���� �� BUY_STOP_�1 & SELL_STOP_�1
//
//********************************************************************
Create_Modify_Prima_BuyStop();  // �������� ���� �� ����� BuyStop1 ������� ��� ����, ���� ��� ��� �� ������ �����1 ������� ��������� ���� � �� � ���� ���� �������� �����
Create_Modify_Prima_SellStop(); // �������� ���� �� ����� SellStop1 ������� ��� �����, ���� ��� ��� �� ������ �����1 ����� ��������� ���� � �� � ���� ���� �������� �����
//********************************************************************
//
// ������ ��� �������� ������ ��� ���� � �����
//
//********************************************************************
Delete_BuyLimit_Old();  // ������ ��� �������� ���������� ������ (������� ��� ����������� + 1) ��� ����
Delete_SellLimit_Old(); // ������ ��� �������� ���������� ������ (������� ��� ����������� + 1) ��� �����
//********************************************************************
//
// �������� ���� �� BUY_LIMIT & SELL_LIMIT
//
//********************************************************************
//********************************************************************
// ��������� ����� ���� ��� ���������� ����������� ������
//********************************************************************
newPriceBuy = 0; newPriceSel = 0;
//********************************************************************
// ���������� ���� �������� ������ ����������� ������
// ����� ����� ���� ������������� �������� �����������               
//********************************************************************
topLevBuy  = getTopLevel(1); // ���� �������� ������� ��� ������
if (topLevBuy>0) {
   n1 = getMaxLongNum();                       // ����� ���������� ������������ ���������� ����� ��������� ������ ��� ������
   p1 = getOrderPriceByNum(n1);                // ��������� ���� �������� ������ �� ��� ����������� ������
   newPriceBuy=getNextOrderPriceByNum(n1, p1); // ���������� ���� �������� ������, ������� ��� �� ����������� (����� ��� ��������� 
   tpBuy = p1;                                 // ��������� �������� ��� ��������� ����������� ����������� ������ � = ���� �������� ����������� ������
}
//********************************************************************
// ���������� ���� �������� ������ ����������� ������ ��� ������
// ����� ����� ���� ������������� �������� �����������
//********************************************************************
topLevSell = getTopLevel(2); // ���� �������� ������� ��� ������
if (topLevSell>0) {
   n1 = getMaxShortNum();                         // ����� ���������� ������������ ���������� ����� ��������� ������ ��� ������
   p1 = getOrderPriceByNum(n1);                   // ��������� ���� �������� ������ �� ��� ����������� ������
   newPriceSel = getNextOrderPriceByNum(n1, p1);  // ���������� ���� �������� ������, ������� ��� �� ����������� (����� ��� ��������� 
   tpSell = p1;                                    // ��������� �������� ��� ��������� ����������� ����������� ������ � = ���� �������� ����������� ������
}
//********************************************************************
// ��� ����������� ���������, ��������� �� ����� ���� �� �����?
// ���� ���� ����� ���� ��� �������� ������, �� ����� ����� ���� �� ��������� ������ ���� (�� �����) �������
//********************************************************************
if (newPriceBuy > Bid) newPriceBuy = Bid - Step*Point;  //��� ��� ��������� �������
if (newPriceSel < Ask) newPriceSel = Ask + Step*Point;  //��� ��� ��������� �������
//********************************************************************
// ��������� ������� �������� ������� �� 2
//********************************************************************
if (topLevBuy==1 && isMagNum(1,102)==False) {
   ticket=OrderSend(Symbol(),OP_BUYLIMIT,getLotByLevel(2),newPriceBuy,3,0,tpBuy,"������ - ���������� ���� 102",102,0,Green);
   Print("�������� ������ ���������� ������� ������ 102 ",Symbol()," ask= ", Ask," t/p=",Ask+Step*Point," ticket=",ticket);
   if (ticket == -1 ) {err=GetLastError(); Print ("������ �������� ��������� 102 = ",err); } 
   Sleep(TimeOut);
}
if (topLevSell==1 && isMagNum(1,202)==False) {
   ticket=OrderSend(Symbol(),OP_SELLLIMIT,getLotByLevel(2),newPriceSel,3,0,tpSell,"������ - ���������� ���� 202",202,0,Red);
   Print("�������� ������ ���������� ������� ������ 202 ",Symbol()," Bid= ", Bid," t/p=",Bid-Step*Point," ticket=",ticket);               
   if (ticket == -1) {err=GetLastError(); Print ("������ �������� ��������� 202 = ",err); } 
   Sleep(TimeOut);
}
//********************************************************************
// ��������� ������� �������� ������� � 3
//********************************************************************
if (topLevBuy==2 && isMagNum(1,103)==False && isOrderActive(102)==True) {
   ticket=OrderSend(Symbol(),OP_BUYLIMIT,getLotByLevel(3),newPriceBuy,3,0,tpBuy,"������ - ���������� ���� 103",103,0,Green);
   Print("�������� ������� ���������� ������� ������ 103 ",Symbol()," ask= ", Ask," t/p=",Ask+Step*Point," ticket=",ticket);
   if (ticket == -1) {err=GetLastError(); Print ("������ �������� ��������� 103 = ",err); } 
   Sleep(TimeOut);
}
if (topLevSell==2 && isMagNum(1,203)==False && isOrderActive(202)==True) {
   ticket=OrderSend(Symbol(),OP_SELLLIMIT,getLotByLevel(3),newPriceSel,3,0,tpSell,"������ - ���������� ���� 203",203,0,Red);
   Print("�������� ������� ���������� ������� ������ 203 ",Symbol()," Bid= ", Bid," t/p=",Bid-Step*Point," ticket=",ticket);               
   if (ticket == -1) {err=GetLastError(); Print ("������ �������� ��������� 203 = ",err); } 
   Sleep(TimeOut);
}
//********************************************************************
// ��������� ������� �������� ������� � 4
//********************************************************************
if (topLevBuy==3 && isMagNum(1,104)==False && isOrderActive(103)==True) {
   ticket=OrderSend(Symbol(),OP_BUYLIMIT,getLotByLevel(4),newPriceBuy,3,0,tpBuy,"��������� - ���������� ���� 104",104,0,Green);
   Print("�������� �������� ���������� �������� ������ 104 ",Symbol()," ask= ", Ask," t/p=",Ask+Step*Point," ticket=",ticket);
   if (ticket == -1) {err=GetLastError(); Print ("������ �������� ��������� 104 = ",err); } 
   Sleep(TimeOut);
}
if (topLevSell==3 && isMagNum(1,204)==False && isOrderActive(203)==True) {
   ticket=OrderSend(Symbol(),OP_SELLLIMIT,getLotByLevel(4),newPriceSel,3,0,tpSell,"��������� - ���������� ���� 204",204,0,Red);
   Print("�������� �������� ���������� ������� ������ 204 ",Symbol()," Bid= ", Bid," t/p=",Bid-Step*Point," ticket=",ticket);               
   if (ticket == -1) {err=GetLastError(); Print ("������ �������� ��������� 204 = ",err); } 
   Sleep(TimeOut);
}
//********************************************************************
// ��������� ������� �������� ������� � 5
//********************************************************************
if (topLevBuy==4 && isMagNum(1,105)==False && isOrderActive(104)==True) {
   ticket=OrderSend(Symbol(),OP_BUYLIMIT,getLotByLevel(5),newPriceBuy,3,0,tpBuy,"����� - ���������� ���� 105",105,0,Green);
   Print("�������� ����� ���������� ������� ������ 105 ",Symbol()," ask= ", Ask," t/p=",Ask+Step*Point," ticket=",ticket);
   if (ticket == -1) {err=GetLastError(); Print ("������ �������� ��������� 105 = ",err); } 
   Sleep(TimeOut);
}
if (topLevSell==4 && isMagNum(1,205)==False && isOrderActive(204)==True) {
   ticket=OrderSend(Symbol(),OP_SELLLIMIT,getLotByLevel(5),newPriceSel,3,0,tpSell,"����� - ���������� ���� 205",205,0,Red);
   Print("�������� ����� ���������� ������� ������ 205 ",Symbol()," Bid= ", Bid," t/p=",Bid-Step*Point," ticket=",ticket);               
   if (ticket == -1) {err=GetLastError(); Print ("������ �������� ��������� 205 = ",err); } 
   Sleep(TimeOut);
}
//********************************************************************
//
// �������� ������������ �� �������� ������� ��� BUY & SELL
//
//********************************************************************
// ������ ����� ���������� ����, �� ������� ����� �������
// ��� ������ �� ������ �� ������ � ������� �������� ���� ������
// ����� �������� �������������� �����
//********************************************************************
curProfitPriceBuy  = getOrderPriceByNum(101) + Step*Point;
curProfitPriceSell = getOrderPriceByNum(201) - Step*Point;
//********************************************************************
// ���������� ����� ��� �������� �������� ������� ��� ������
//********************************************************************
if (isOrderActive(105)==True) curProfitPriceBuy=getOrderPriceByNum(104);
if (isOrderActive(105)==False && isOrderActive(104)==True) curProfitPriceBuy=getOrderPriceByNum(103);
if (isOrderActive(105)==False && isOrderActive(104)==False && isOrderActive(103)==True) curProfitPriceBuy=getOrderPriceByNum(102);
if (isOrderActive(105)==False && isOrderActive(104)==False && isOrderActive(103)==False && isOrderActive(102)==True){ if (isOrderActive(101)==True) curProfitPriceBuy=getOrderPriceByNum(101); }
//********************************************************************
// ���������� ��� �������� �������� ������� ��� ������
//********************************************************************
if (isOrderActive(205)==True) curProfitPriceSell=getOrderPriceByNum(204);
if (isOrderActive(205)==False && isOrderActive(204)==True) curProfitPriceSell=getOrderPriceByNum(203);
if (isOrderActive(205)==False && isOrderActive(204)==False && isOrderActive(203)==True) curProfitPriceSell=getOrderPriceByNum(202);
if (isOrderActive(205)==False && isOrderActive(205)==False && isOrderActive(203)==False && isOrderActive(202)==True){ if (isOrderActive(201)==True) curProfitPriceSell=getOrderPriceByNum(201); }
//********************************************************************
// ������������ �� ���� ������������� ������� 
//********************************************************************
setNewTakeProfitBuy(curProfitPriceBuy);  // ������������� �������� ��� ������ 
setNewTakeProfitSel(curProfitPriceSell); // ������������� �������� ��� ������
//********************************************************************
// ��� ���� �������� ������������ ��� ���������� ������� � �� ���������,
//     ���� ��� ����������
// ������� ��������� ����� ��� ������
//     p1 - ��� ����� ���� ������� ��� ��������� �������
//********************************************************************
n1=getMaxLongNum();                //����� ��������, ����� �������� ������� (��������) �����������
p1=getOrderPriceByNum(n1);         // ������ �������� ���� �������� ���� �������
p2=getNextOrderPriceByNum(n1, p1); // ������ ���� ��������� ���� �������� ����������� ������, ��������� ������� ����� ���� �������             
n2=getNextOrderNum(n1);            // ������, ����� ����� ��������� ����� ������
if (isMagNum(1,n2)==True && p2<(Bid-(Ask-Bid)-3*Point)) { modOrder(n2, p2, p1); } //������� ������������ ����� => ���� �� ������� ����������� ��� ���������� ������� 
//********************************************************************
// ��� �� �� ����� ������ ��� ������
//********************************************************************
n1=getMaxShortNum();               // ����� ��������, ����� �������� ������� (��������) �����������
p1=getOrderPriceByNum(n1);         // ������ �������� ���� �������� ���� �������
p2=getNextOrderPriceByNum(n1, p1); // ������ ���� ��������� ���� �������� ����������� ������, ��������� ������� ����� ���� �������
n2=getNextOrderNum(n1);            //������, ����� ����� ��������� ����� ������
if (isMagNum(1,n2)==True && p2>(Ask+(Ask-Bid)+3*Point)) { modOrder(n2, p2, p1); } 
//********************************************************************
//
// � � �
//
//********************************************************************
return(0);
}     
//********************************************************************
//
// THE  END
//
//********************************************************************

