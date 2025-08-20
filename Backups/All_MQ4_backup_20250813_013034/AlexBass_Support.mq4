//+------------------------------------------------------------------+
//|                                             AlexBass_Support.mq4 |
//|                                          Copyright � 2006, Silem |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2006, Silem"
#property link      "silem@k66.ru"
#include <stdlib.mqh>
//#include <VisualTestingTools.mq4>

//---- input parameters
extern double    FirstLot=0.1;            // ��������� ���
extern double    UpPrice=1.29;            // ������� ������ (�� ��� ���)
extern double    DnPrice=1.275;           // ������� ����� (�� ��� �����)
extern int       MailCount=3;             // ����� ����� �������� ���������
extern int       MailPer=5;               // ������� ����� �������
extern int       MinPr=10;                // ����������� ������ � ������    
extern int       Setka=80;                // �����
extern bool      UseCloseDouble=false;    // ��������� ��� ���� ��� ���������� ������� ���������
extern int       DoubleCloseCount=0;      // ����� ������� ������� ��� �������. ������� ������ �����
extern int       MN=999;                  // ����������
extern int       timeOut=3000;            // ����� ����� ����������
//+------------------------------------------------------------------+
//| �������� ���������                                               |
//+------------------------------------------------------------------+
/*
�������� ������������ ��� ������ �� ������� � �������� � ���������� ������
30/8 - �������� ���������� �������, �������� ���������, ������ �������, �������� �������
02/8 - ������ ������� ������ � ������ ��������� AlexBass
*/

// ���������� ������ ����������
int SmalPer, BigPer, a, b, k, n, dLts, ls, x, xx;
double dLtsPr, dLtsPrPips, dLtsPrPipsCl, dLtsPrPipsCl1, CurAsk, CurBid, lastSellBid, lastSellLots, z, ss;
datetime lastOpenSell;
//����������� �������
  //***������� ��������� ����������� �������� ���� �� ��������� Setka �������
   bool LastQuoteUp() {       
     int i,Last;     
     for(i=0; i<=Bars-2; i++){
       Last=(High[i+1]+Low[i+1])/2;              
       if (Last-(Bid+Ask)/2>=Setka*Point) {return(True);}      
       if (Last-(Bid+Ask)/2>=-Setka*Point) {return(False);}}}                   
  //***����w�� ��������� ���� �������� ���������� ������ ����
   double GetLastOpenPriceBid(){      
     int t, cnt1, HighTicket;     
     t=OrdersTotal();
     HighTicket=0;
     for(cnt1=t;cnt1>=0;cnt1--){
       OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
       if (OrderType()==OP_SELL){               
         if (OrderTicket()>HighTicket){
           HighTicket=OrderTicket();}}}  
     OrderSelect(HighTicket, SELECT_BY_TICKET);     
     return (OrderOpenPrice());}  
  //***������� �������� ������� �� ���� ��������     
   double getAllProfit(){
     int t, cnt1;
     double pf;
     t=OrdersTotal();
     pf=0;
     for(cnt1=t;cnt1>=0;cnt1--){
       OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);{      
         if (OrderSymbol()==Symbol() && (OrderType()==OP_BUY || OrderType()==OP_SELL)){
           pf=pf+OrderProfit()+OrderSwap()+OrderCommission();}}}
//     Print ("������� ������ �� ���� ",pf); 
     return (pf);}  
  //***������� �������� ������� �� ���������� �������
   bool getProfitOrdersClose(){       
     int t, cnt1, tic, err;     
     t=OrdersTotal();
     for(cnt1=t;cnt1>=0;cnt1--){
       OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol()==Symbol() && OrderMagicNumber()==MN){
          if (OrderType()!=OP_BUY && OrderType()!=OP_SELL){
            tic=OrderDelete(OrderTicket());
            if (tic==1) PlaySound("timeout.wav");
            if (tic!=1){err=GetLastError(); Print ("������ �������� ������ = ",ErrorDescription(err));}}
          if (OrderType()==OP_BUY){
            tic=OrderClose(OrderTicket(),OrderLots(),Ask,3,Green);
            if (tic==1) PlaySound("timeout.wav");
            if (tic!=1){err=GetLastError(); Print ("������ �������� ������ = ",ErrorDescription(err));}}
          if (OrderType()==OP_SELL){
            tic=OrderClose(OrderTicket(),OrderLots(),Bid,3,Green);
            if (tic==1) PlaySound("timeout.wav");
            if (tic!=1){err=GetLastError(); Print ("������ �������� ������ = ",ErrorDescription(err));}}}}  
     return (False);}
  //***������� �������� ������ ��� � �������� ������ ���������� �������
   void putFirstOrders(int mode)
    {
     double spread,shag,DoubleLot,curAsk,curBid;
     int tiket,err;
     int s=MarketInfo(Symbol(),MODE_SPREAD);
     DoubleLot=FirstLot*2;
     curAsk=Ask;
     curBid=Bid;
     spread=s*Point;   
     shag=Setka*Point;
      if (mode==1){ // ���� �������
        tiket=OrderSend(Symbol(),OP_BUY,DoubleLot,curAsk,3,curAsk-2*shag-spread,curAsk+shag-spread,"������� ���� � �����",MN,0,RoyalBlue);            
        if (tiket==-1) {err=GetLastError(); Print("������ �������� ������� �������� �����(!)= ",ErrorDescription(err));} 
//        Sleep(timeOut);                 
        tiket=OrderSend(Symbol(),OP_SELL,FirstLot,curBid,3,curBid+shag+spread,curBid-shag+spread,"��������� ���� � �����",MN,0,Coral);   
        if (tiket==-1) {err=GetLastError(); Print("������ �������� ������� �����(!)= ",ErrorDescription(err));}
        Sleep(timeOut);  
        tiket=OrderSend(Symbol(),OP_BUYLIMIT,FirstLot,curAsk-shag,3,curAsk-4*shag-spread,curBid,"������ ��������",MN,0,Blue);            
        if (tiket==-1) {err=GetLastError(); Print("������ �������� ������� ��������� (!)= ",ErrorDescription(err));} 
        Sleep(timeOut);                 
        tiket=OrderSend(Symbol(),OP_SELLSTOP,DoubleLot,curBid-shag,3,0,0,"������ ��������",MN,0,Red);   
        if (tiket==-1) {err=GetLastError(); Print("������ �������� ������� ���������(!)= ",ErrorDescription(err));}
        Sleep(timeOut);}
      if (mode==2){ // ���� ���������
        tiket=OrderSend(Symbol(),OP_BUY,FirstLot,curAsk,3,curAsk-shag-spread,curAsk+shag-spread,"��������� ���� � �����",MN,0,RoyalBlue);
        if (tiket==-1) {err=GetLastError(); Print("������ �������� ������� ���������� �����(!)= ",ErrorDescription(err));}
//        Sleep(timeOut);                 
        tiket=OrderSend(Symbol(),OP_SELL,DoubleLot,curBid,3,curBid+2*shag+spread,curBid-shag+spread,"������� ���� � �����",MN,0,Coral);
        if (tiket==-1) {err=GetLastError(); Print("������ �������� ������� �������� �����(!)= ",ErrorDescription(err));}
        Sleep(timeOut);  
        tiket=OrderSend(Symbol(),OP_BUYSTOP,DoubleLot,curAsk+shag,3,0,0,"������ �������",MN,0,Blue);            
        if (tiket==-1) {err=GetLastError(); Print("������ �������� ������� �������� (!)= ",ErrorDescription(err));} 
        Sleep(timeOut);
        tiket=OrderSend(Symbol(),OP_SELLLIMIT,FirstLot,curBid+shag,3,curAsk+4*shag,curAsk,"������ ��������",MN,0,Red);   
        if (tiket==-1) {err=GetLastError(); Print("������ �������� ������� ���������(!)= ",ErrorDescription(err));}
        Sleep(timeOut);}}

//***������� ���������� ����������� ���������� �������
   void pmd_LimitsOrd(){
     double spread,shag,DoubleLot,pr1;
     int t, cnt1, tic, err, _low, _high, _work, tiket, Err, tic1, tic2;  
     int s=MarketInfo(Symbol(),MODE_SPREAD);      
     spread=s*Point;   
     shag=Setka*Point;
     DoubleLot=FirstLot*2;
     _low=0;
     _high=0;
     _work=0;
     t=OrdersTotal();
     for(cnt1=t;cnt1>=0;cnt1--){
       OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);         
       if (OrderType()==OP_BUYLIMIT)     {_low=_low+1;}
       if (OrderType()==OP_SELLSTOP)     {_low=_low+1;}            
       if (OrderType()==OP_BUYSTOP)      {_high=_high+1;}
       if (OrderType()==OP_SELLLIMIT)    {_high=_high+1;}}  
     _work=t-_low-_high;// ��-������ ������� - ������ ������ - ����� �� ������ ����� ������
//     Print("������ ����� ",t," ������� ���� ",_high,", ������� ���� ",_low,", ������� ",_work);     
         
  //���� ������ ��������� ���� � ������� - �����
     if (_low==2 && _high==2){return;}
  //���� ������ ��������� �������� - ������� ���������� ����������
     if (_work==0){
       for(cnt1=t;cnt1>=0;cnt1--){
         OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
         if (OrderType()!=OP_SELL && OrderType()!=OP_BUY){
           tiket=OrderDelete(OrderTicket());
           if (tiket==-1) {Err=GetLastError(); Print("������ �������� ������ = ",ErrorDescription(err));} 
           Sleep(timeOut);}}}
  //������ ������� ������� ������ � ������� ��
     if (_work>=5)
      {
       for(cnt1=t;cnt1>=0;cnt1--)
        {
         OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
         if (OrderLots()==DoubleLot && OrderType()==OP_SELL)
          {
           tic1=OrderTicket();
           pr1=OrderOpenPrice();
           for(cnt1=t;cnt1>=0;cnt1--)
            {
             OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
             if (OrderLots()==DoubleLot && OrderType()==OP_BUY)
              {
               tic2=OrderTicket();
               if (OrderOpenPrice()-pr1==spread)
                {
                 tic=OrderClose(tic1,OrderLots(),Ask,3,Green);
                 if (tic!=1){err=GetLastError(); Print ("������ �������� ������ = ",ErrorDescription(err));}
                 tic=OrderClose(tic2,OrderLots(),Bid,3,Green);
                 if (tic!=1){err=GetLastError(); Print ("������ �������� ������ = ",ErrorDescription(err));}
                }
              }

            }

          }
        }
      }
  //���� ��������� ������ � ���������� ������ ���
     if (_low==0 && _high==0 && _work>2){

//���������� ����������� ������ � ����� 
       tiket=OrderSend(Symbol(),OP_BUYLIMIT,FirstLot,GetLastOpenPriceBid()-shag+spread,3,GetLastOpenPriceBid()-4*shag,GetLastOpenPriceBid(),"���������� ��������",MN,0,Blue);            
       if (tiket==-1) {Err=GetLastError(); Print("������ ��������� ��������� (!)= ",ErrorDescription(err));} 
       Sleep(timeOut);
       tiket=OrderSend(Symbol(),OP_SELLSTOP,DoubleLot,GetLastOpenPriceBid()-shag,3,0,0,"���������� ��������",MN,0,Red);   
       if (tiket==-1) {Err=GetLastError(); Print("������ ��������� ���������(!)= ",ErrorDescription(err));}
       Sleep(timeOut);
       tiket=OrderSend(Symbol(),OP_BUYSTOP,DoubleLot,GetLastOpenPriceBid()+shag+spread,3,0,0,"���������� �������",MN,0,Blue);            
       if (tiket==-1) {Err=GetLastError(); Print("������ ��������� ��������(!)= ",ErrorDescription(err));} 
       Sleep(timeOut);                 
       tiket=OrderSend(Symbol(),OP_SELLLIMIT,FirstLot,GetLastOpenPriceBid()+shag,3,GetLastOpenPriceBid()+4*shag+spread,GetLastOpenPriceBid()+spread,"���������� ��������",MN,0,Red);   
       if (tiket==-1) {Err=GetLastError(); Print("������ ��������� ���������(!)= ",ErrorDescription(err));}
       Sleep(timeOut);
  // � ������������ �� � �� � ���� � ����������� �������
       for(cnt1=t;cnt1>=0;cnt1--){
         OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
         if (OrderLots()==DoubleLot){
           tiket=OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,Red);
           if (tiket==-1) {Err=GetLastError(); Print("������ ����������� ������ ��� = ",ErrorDescription(err));} 
           Sleep(timeOut);}}}
  //���� ��������� ������ ������ � ������� ������ ����
     if (_low==2 && _high==0 && _work>2){
  //���������� ����������� ������
       tiket=OrderSend(Symbol(),OP_BUYSTOP,DoubleLot,GetLastOpenPriceBid()+shag+spread,3,0,0,"���������� �������",MN,0,Blue);            
       if (tiket==-1) {Err=GetLastError(); Print("������ ��������� ��������(!)= ",ErrorDescription(err));} 
       Sleep(timeOut);                 
       tiket=OrderSend(Symbol(),OP_SELLLIMIT,FirstLot,GetLastOpenPriceBid()+shag,3,GetLastOpenPriceBid()+4*shag+spread,GetLastOpenPriceBid()+spread,"���������� ��������",MN,0,Red);   
       if (tiket==-1) {Err=GetLastError(); Print("������ ��������� ���������(!)= ",ErrorDescription(err));}
       Sleep(timeOut);  
  //����������� ������������ ���������� �����
       for(cnt1=t;cnt1>=0;cnt1--){
         OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
         if (OrderType()==OP_BUYLIMIT){
           tiket=OrderModify(OrderTicket(),GetLastOpenPriceBid()-shag+spread,GetLastOpenPriceBid()-4*shag,GetLastOpenPriceBid(),0,Blue);
           if (tiket==-1) {Err=GetLastError(); Print("������ ����������� ��������� = ",ErrorDescription(err));} 
           Sleep(timeOut);}
         if (OrderLots()==DoubleLot){
           tiket=OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,Red);
           if (tiket==-1) {Err=GetLastError(); Print("������ ����������� ������ ��� = ",ErrorDescription(err));} 
           Sleep(timeOut);}
         if (OrderType()==OP_SELLSTOP){
           tiket=OrderModify(OrderTicket(),GetLastOpenPriceBid()-shag,0,0,0,Red);   
           if  (tiket==-1) {err=GetLastError(); Print("������ ����������� ��������� = ",ErrorDescription(err));}
           Sleep(timeOut);}}}
  //���� ��������� ������� ������
     if (_high==2 && _low==0 && _work>2){
  //���������� ����������� �����
       tiket=OrderSend(Symbol(),OP_BUYLIMIT,FirstLot,GetLastOpenPriceBid()-shag+spread,3,GetLastOpenPriceBid()-4*shag,GetLastOpenPriceBid(),"���������� ��������",MN,0,Blue);            
       if (tiket==-1) {err=GetLastError(); Print("������ ��������� ��������� (!)= ",ErrorDescription(err));} 
       Sleep(timeOut);
       tiket=OrderSend(Symbol(),OP_SELLSTOP,DoubleLot,GetLastOpenPriceBid()-shag,3,0,0,"���������� ��������",MN,0,Red);   
       if (tiket==-1) {err=GetLastError(); Print("������ ��������� ���������(!)= ",ErrorDescription(err));}
       Sleep(timeOut);
  //����������� ������������ ���������� ������
       for(cnt1=t;cnt1>=0;cnt1--){
         OrderSelect(cnt1, SELECT_BY_POS, MODE_TRADES);
         if (OrderType()==OP_BUYSTOP){
           tiket=OrderModify(OrderTicket(),GetLastOpenPriceBid()+shag+spread,0,0,0,Blue);
           if (tiket==-1) {err=GetLastError(); Print("������ ����������� �������� = ",ErrorDescription(err));} 
           Sleep(timeOut);}
         if (OrderLots()==DoubleLot){
           tiket=OrderModify(OrderTicket(),OrderOpenPrice(),0,0,0,Blue);
           if (tiket==-1) {err=GetLastError(); Print("������ ����������� ������ ���� = ",ErrorDescription(err));} 
           Sleep(timeOut);}
         if (OrderType()==OP_SELLLIMIT){
           tiket=OrderModify(OrderTicket(),GetLastOpenPriceBid()+shag,GetLastOpenPriceBid()+4*shag+spread,GetLastOpenPriceBid()+spread,0,Red);   
           if (tiket==-1) {err=GetLastError(); Print("������ ����������� ��������� = ",ErrorDescription(err));}
           Sleep(timeOut);}}}}


//int init(){vTerminalInit();return(0);}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//     vTerminalRefresh();
//   double Spr=Ask-Bid;
   //������� �������z � �������������
//   SmalPer=120000;
//   BigPer=MailPer*60*1000;
   //���������� �������� ���� � ����
//   CurAsk=Ask;
//   CurBid=Bid;
//   z=0;
//   x=0;
//   xx=0;
    // ������� �������� ���� � ���� ��� ����� �� ������������� ���� ������� -
    // �������� ��������� 
/*   if (CurAsk>=UpPrice && a<MailCount)
    {
     for (a=1; a<=MailCount; a++)
      {
       for (k=1; k<=3; k++)
        {
         SendMail("AlexBass Info","Price reached up boder at"+DoubleToStr(UpPrice,Digits));
         k=k+1;
         Sleep(SmalPer);
        }
       a=a+1;
       Sleep(BigPer);
      }
    }
   if (CurBid<=DnPrice && b<MailCount)
    {
     for (b=1; b<=MailCount; b++)
      {
       for (n=1; n<=3; n++)
        {
     SendMail("AlexBass Info","Price reached down boder at"+DoubleToStr(DnPrice,Digits));
         n=n+1;
         Sleep(SmalPer);
        }
       b=b+1;
       Sleep(BigPer);
      }
    }*/
  // ��������� ��� ������, ���� ���� ������
   double MinPr1=MinPr*FirstLot*10;
   if (getAllProfit()>=MinPr1){getProfitOrdersClose();}
  // ����������� ��������� �������, ���� ��������� ����������
   pmd_LimitsOrd();
  // ����������� ������ �������, ���� �� ���
   if (OrdersTotal()==0){if (LastQuoteUp()==true){putFirstOrders(1);}else{putFirstOrders(2);}}
   return(0);
  }
//+-------------------------------

