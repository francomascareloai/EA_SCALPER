//+------------------------------------------------------------------+
//|                                                    NEWEXPERT.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+sigmoi
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


extern double p1 = 0.1 ;
extern double p2 = 0.1 ;
extern double p3 = 0.1 ;

extern double q1 = 0.1 ;
extern double q2 = 0.1 ;
extern double q3 = 0.1 ;

extern double k1 = 0.1 ;
extern double k2 = 0.1 ;
extern double k3 = 0.1 ;

extern int  st =  1 ;
extern int  stop =  10 ;


extern int  m1 =  2 ;
extern int  m2 =  5 ;
extern int  m3 =  2 ;
extern int  m4 =  5 ;
extern int  m5 =  2 ;
extern int  m6 =  5 ;





extern bool   AllPositions  =True;         // Управлять всеми позициями
extern bool   ProfitTrailing=False;          // Тралить только профит
extern int    TrailingStop  =15;            // Фиксированный размер трала
extern int    TrailingStep  =2;             // Шаг трала
extern bool   UseSound      =False;          // Использовать звуковой сигнал
extern string NameFileSound ="expert.wav";  // Наименование звукового файла
double n1,n2,n3  ;

int hourtrade = 0 ;

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----

if ( Hour()==hourtrade )
{
   hourtrade =  Hour() ;
   return(0);  

}

  
double    s1=iMA(NULL,PERIOD_D1,m5,m6,MODE_SMMA,PRICE_MEDIAN,1);
double    s2=iMA(NULL,PERIOD_H1,m1,m2,MODE_SMMA,PRICE_MEDIAN,2);
double    s3=iMA(NULL,PERIOD_H1,m1,m2,MODE_SMMA,PRICE_MEDIAN,3);
double    s4=iMA(NULL,PERIOD_H1,m1,m2,MODE_SMMA,PRICE_MEDIAN,4);

double    r1=iMA(NULL,PERIOD_D1,m5,m6,MODE_SMMA,PRICE_MEDIAN,1);
double    r2=iMA(NULL,PERIOD_H4,m3,m4,MODE_SMMA,PRICE_MEDIAN,2);
double    r3=iMA(NULL,PERIOD_H4,m3,m4,MODE_SMMA,PRICE_MEDIAN,3);
double    r4=iMA(NULL,PERIOD_H4,m3,m4,MODE_SMMA,PRICE_MEDIAN,4);


double    t1=iMA(NULL,PERIOD_D1,m5,m6,MODE_SMMA,PRICE_MEDIAN,1);
double    t2=iMA(NULL,PERIOD_D1,m5,m6,MODE_SMMA,PRICE_MEDIAN,2);
double    t3=iMA(NULL,PERIOD_D1,m5,m6,MODE_SMMA,PRICE_MEDIAN,3);
double    t4=iMA(NULL,PERIOD_D1,m5,m6,MODE_SMMA,PRICE_MEDIAN,4);





 n1 = ((s1-s2)/s1)*p1 + ((s2-s3)/s3)*p2 + ((s3-s4)/s4)*p3  ; 
 n1= (MathRound (n1*10000 ));
 
 
 n2 = ((r1-r2)/r2)*q1 + ((r2-r3)/r3)*q2 + ((r3-r4)/r4)*q3  ; 
 n2=  (MathRound (n2*10000 ));

 n3 = ((t1-t2)/t2)*k1 + ((t2-t3)/t3)*k2 + ((t3-t4)/t4)*k3  ; 
 n3=  (MathRound (n3*10000));



Comment(n1 , "  " , n2 , "  " , n3); 
/*
double   s1=iATR(NULL,0,20,i1) ;
double   s2=iATR(NULL,0,20,i2) ;
 */


  // if((n1>0 && n2>0  )   )   {    BUY(10);}
  // if((n1>0 && n2<0  )   )   {   SELL(11);}
   
   
   if((n1>0 && n2>0  && n3>0)   )   {    BUY(10);}
   if((n1>0 && n2<0  && n3<0)   )   {   SELL(11);}
  
  
   
// if ( AllProfit() > 10  ) CloseAll() ;
   
   
  Trall() ;
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void BUY(int mag)
//================
{  int order ;

 int pos;
   int total = OrdersTotal();
   for ( pos = 0; pos<total; pos++ )
     {
       if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) == true)
         {
            if (mag == OrderMagicNumber() ) return(0) ;

         }
      }


 //  order=OrderSend(Symbol(),OP_BUY,1,Ask,3,Ask-25*Point,Ask+25*Point,"My order #2",mag,0,Green);
   order=OrderSend(Symbol(),OP_BUY, Lots() ,Ask,3,Ask-stop*Point,0,"My order BUY",mag,0,Green);
return(0) ; }

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void SELL(int mag)
//================
{  int order ;

int pos;
   int total = OrdersTotal();
   for ( pos = 0; pos<total; pos++ )
     {
       if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) == true)
         {
           if (mag == OrderMagicNumber() ) return(0) ;

         }
      }

 //  order=OrderSend(Symbol(),OP_BUY,1,Ask,3,Ask-25*Point,Ask+25*Point,"My order #2",mag,0,Green);
   order=OrderSend(Symbol(),OP_SELL, Lots() ,Bid,3,Bid+stop*Point,0,"My order SELL",mag,0,Green);
return(0) ; }




//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
double Profit(int mag)
//====================
{
double prof ;

prof =0; 

if(OrderSelect(mag, SELECT_BY_POS)==true)
    prof = OrderProfit();

return(prof) ;

}


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
double AllProfit()
//====================
{
double prof ;

prof =0; 


 int pos;
   int total = OrdersTotal();
   for ( pos = 0; pos<total; pos++ )
     {
       if (OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) == true)
         {
          // Print("Выбран ордер номер ", pos, " в списке открытых позиций");
           // делаем что-то с этой позицией
           prof=prof+OrderProfit();
         }
      } 


return(prof) ;

}


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int CloseAll()
{
 
string title="Скрипт";
string msg="Закрыть все ордера BUY и SELL? ";

int slippage=2;
for (int i=OrdersTotal()-1; i>=0; i--)
{
if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) break;
if (OrderType()==OP_BUY ) OrderClose (OrderTicket(),OrderLots(),MarketInfo(OrderSymbol( ),MODE_BID),slippage);
if (OrderType()==OP_SELL) OrderClose (OrderTicket(),OrderLots(),MarketInfo(OrderSymbol( ),MODE_ASK),slippage);
}
//----
   return(0);
} 


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void  Trall()
//==================
{
    for(int i=0; i<OrdersTotal(); i++) 
     {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
        {
           if (AllPositions || OrderSymbol()==Symbol()) 
           {
            TrailingPositions();
           }
        }
     }
     
        return(0);
} 

//+------------------------------------------------------------------+
//| Сопровождение позиции простым тралом                             |
//+------------------------------------------------------------------+
  void TrailingPositions() 
  {
   double pBid, pAsk, pp;
//----
   pp=MarketInfo(OrderSymbol(), MODE_POINT);
     if (OrderType()==OP_BUY) 
     {
      pBid=MarketInfo(OrderSymbol(), MODE_BID);
        if (!ProfitTrailing || (pBid-OrderOpenPrice())>TrailingStop*pp) 
        {
           if (OrderStopLoss()<pBid-(TrailingStop+TrailingStep-1)*pp) 
           {
            ModifyStopLoss(pBid-TrailingStop*pp);
            return;
           }
        }
     }
     if (OrderType()==OP_SELL) 
     {
      pAsk=MarketInfo(OrderSymbol(), MODE_ASK);
        if (!ProfitTrailing || OrderOpenPrice()-pAsk>TrailingStop*pp) 
        {
           if (OrderStopLoss()>pAsk+(TrailingStop+TrailingStep-1)*pp || OrderStopLoss()==0) 
           {
            ModifyStopLoss(pAsk+TrailingStop*pp);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Перенос уровня StopLoss                                          |
//| Параметры:                                                       |
//|   ldStopLoss - уровень StopLoss                                  |
//+------------------------------------------------------------------+
  void ModifyStopLoss(double ldStopLoss) 
  {
   bool fm;
   fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE);
   if (fm && UseSound) PlaySound(NameFileSound);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
double Lots()                                            // Вычисление лотов
   {
   double Prots = 10 ;
//============================================================================================
  double  Lot=NormalizeDouble(AccountEquity()*Prots/100/1000,1);// Вычисляем колич. лотов  
   double Min_Lot = MarketInfo(Symbol(), MODE_MINLOT);   // Минимально допустимая стоим. лотов
   if (Lot == 0 ) Lot = Min_Lot;                         // Для теста на постоян. миним. лотах
//============================================================================================
   //return(Lot);
   return(0.1);

   }
//жжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжжж

//------------------------------------------
// определение сигмоидальной функции  (тангенс гипреболический)
//------------------------------------------
double Sigma(double argument)
   {
   double help;
   help=(MathExp(argument)-MathExp(-argument))/(MathExp(argument)+MathExp(-argument));
   return(help);
   }