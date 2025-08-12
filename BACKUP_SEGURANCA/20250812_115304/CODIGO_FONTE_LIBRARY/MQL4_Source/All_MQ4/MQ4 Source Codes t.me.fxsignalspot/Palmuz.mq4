//+------------------------------------------------------------------+
//|                                                        Palmuz.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, vr."
#property link      "http://www.palmuz.ee"

extern int        Magic                = 16108;
extern string     Настройки_объемов;
extern double     StartLot             = 0.1;
extern double     Multipl              = 1.25;
extern string     Основные_настройки;
extern int        OrderStep            = 190;
extern int        TakeProfit           = 120;
extern string     Блок_анализа_тренда;
extern bool       Use_Trand_Analiz     = false;
extern int        MA_Period            = 70;
extern string     Методы_усреднения_МА = "0-Simple, 1-Exponet, 2-Smooted, 3-Linear Wed";
extern int        MA_Aver_Metod        = 0;
extern string     MA_Prices            = "0-Close, 1-Open, 2- High,3-Low"; 
extern int        MA_Use_Price         = 0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {

   Comment("");

   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
  
   Comment("");
  
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  int random;
  int ord[8];
  double tp, step, sr_cena, lot, sumlot,lotprice;
  double maxlot = -1;
  double minbuyprice = 10000000000;
  double maxsellprice=-1;
  double MA=iMA(Symbol(),0,MA_Period,0,MA_Aver_Metod,MA_Use_Price,0);
  //-----------------------
  if (Digits==2||Digits==4){tp=TakeProfit*Point;step=OrderStep*Point;}
  if (Digits==3||Digits==5){tp=TakeProfit*10*Point;step=OrderStep*10*Point;}
  lot=StartLot;
  Uchet_orderov(Magic,Symbol(),ord);
   if (ord[6]==0&&ord[7]==0){
    if (!Use_Trand_Analiz)  {
    MathSrand(TimeLocal());
    random = MathRand();
    if (random < 16384){ 
    OrderSend(Symbol(),OP_SELL,lot,Bid,100,0,Bid-tp,NULL,Magic,0,Red);
    OrderSend(Symbol(),OP_SELLLIMIT,NormalizeDouble(lot*Multipl,2),Bid+step,100,0,0,NULL,Magic,0,Red);
    }
    else{
    OrderSend(Symbol(),OP_BUY,lot,Ask,100,0,Ask+tp,NULL,Magic,0,Green);
    OrderSend(Symbol(),OP_BUYLIMIT,NormalizeDouble(lot*Multipl,2),Ask-step,100,0,0,NULL,Magic,0,Green);
     }
    }
    else{
    if (Close[0]>MA){
    OrderSend(Symbol(),OP_BUY,lot,Ask,100,0,Ask+tp,NULL,Magic,0,Green);
    OrderSend(Symbol(),OP_BUYLIMIT,NormalizeDouble(lot*Multipl,2),Ask-step,100,0,0,NULL,Magic,0,Green);
    }
    else if (Close[0]<MA){
    OrderSend(Symbol(),OP_SELL,lot,Bid,100,0,Bid-tp,NULL,Magic,0,Red);
    OrderSend(Symbol(),OP_SELLLIMIT,NormalizeDouble(lot*Multipl,2),Bid+step,100,0,0,NULL,Magic,0,Red);
      }
     }
    } 
    if (ord[6]==0&&ord[7]==1){
    OrderSelect(0,SELECT_BY_POS);
    OrderDelete(OrderTicket());
    }
    if (ord[6]>0&&ord[7]==0){
    for (int pos=0; pos<OrdersTotal(); pos++){
    OrderSelect(pos,SELECT_BY_POS);
    if (OrderMagicNumber()==Magic&&OrderSymbol()==Symbol()){
    lotprice=lotprice+OrderOpenPrice()*OrderLots();
    sumlot=sumlot+OrderLots();
    if (maxlot<OrderLots()) maxlot=OrderLots();
    if (OrderType()==OP_BUY && minbuyprice>OrderOpenPrice())minbuyprice=OrderOpenPrice();
    if (OrderType()==OP_SELL && maxsellprice<OrderOpenPrice())maxsellprice=OrderOpenPrice();
    int tipsdelok=OrderType();
      }
    }  
     
   sr_cena = NormalizeDouble(lotprice/sumlot,Digits);
   for (pos=0; pos<OrdersTotal(); pos++){ 
   OrderSelect(pos,SELECT_BY_POS); 
   if (OrderMagicNumber()==Magic&&OrderSymbol()==Symbol()&&tipsdelok==OP_BUY){
   OrderModify(OrderTicket(),0,0,sr_cena+tp,0,CLR_NONE);
   }
   if (OrderMagicNumber()==Magic&&OrderSymbol()==Symbol()&&tipsdelok==OP_SELL){
   OrderModify(OrderTicket(),0,0,sr_cena-tp,0,CLR_NONE); 
     }
   }  
  if (tipsdelok==OP_BUY)
      OrderSend(Symbol(),OP_BUYLIMIT,NormalizeDouble(maxlot*Multipl,2),minbuyprice-step,100,0,0,NULL,Magic,0,Green);
  if (tipsdelok==OP_SELL)
      OrderSend(Symbol(),OP_SELLLIMIT,NormalizeDouble(maxlot*Multipl,2),maxsellprice+step,100,0,0,NULL,Magic,0,Red);
  }
  
  Comment("Баланс:     ", DoubleToStr(AccountBalance(),2),"   Всего шортов:  ",TSell(),
          "\nСредства: ", DoubleToStr(AccountEquity(),2), "   Всего лонгов:  ",TBuy());
          
  
   return(0);
  }
//+------------------------------------------------------------------+
//  Учет ордеров
//+------------------------------------------------------------------+

void Uchet_orderov(int Mag, string Symb, int &mas[8]){
ArrayInitialize(mas,0);
//mas[0] - покупки
//mas[1] - продажи
//mas[2] - buylimit
//mas[3] - selllimit
//mas[4] - buystop
//mas[5] - sellstop
//mas[6] - sdelki
//mas[7] - otlozki
int tip;
for (int pos=0; pos<OrdersTotal(); pos++){
OrderSelect(pos,SELECT_BY_POS,MODE_TRADES);
tip=OrderType();
switch (tip){

    case 0:{mas[0]++;mas[6]++;break;}
    case 1:{mas[1]++;mas[6]++;break;}
    case 2:{mas[2]++;mas[7]++;break;}
    case 3:{mas[3]++;mas[7]++;break;}
    case 4:{mas[4]++;mas[7]++;break;}
    case 5:{mas[5]++;mas[7]++;break;}
        }
      }
   }     
//+------------------------------------------------------------------+
//     хвункция подсчета открытых ордеров
//+------------------------------------------------------------------+

int TBuy()
{
 int vsego =0;
 for (int opord = OrdersTotal()-1; opord >=0; opord--)
  {
   OrderSelect(opord, SELECT_BY_POS, MODE_TRADES);
   if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
   {
   
     if (OrderType() == OP_BUY)
     vsego++;
   }
  
  }
  return (vsego);
}
//+------------------------------------------------------------------+
int TSell()
{
 int vsego =0;
 for (int opord = OrdersTotal()-1; opord >=0; opord--)
  {
   OrderSelect(opord, SELECT_BY_POS, MODE_TRADES);
   if(OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
   {
   
     if (OrderType() == OP_SELL)
     vsego++;
   }
  
  }
  return (vsego);
}