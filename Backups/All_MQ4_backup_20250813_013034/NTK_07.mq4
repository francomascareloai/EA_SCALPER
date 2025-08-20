/*
Как работает:
ставим два отложенных оредра от текущей цены на расстоянии netstep
если один из них срабатывает, то второй удаляем
ставим еще один отложенный в направлении движения цены на расстоянии netstep, но с лотом умноженным на mul
и т.д. до тех пор пока не достигнем количества отрытых сделок maxtrades или LotLim
и дальше тащим стопы и профиты в направлении цены, т.е. задача поймать тренд и не слить на флете
поэтому maxtrades, стопы, профиты зависят от волатильности рынка, а mul по идее должен быть меньше двух, чтобы за счет накопленной маржи не слить много
вообщем эксперт наиболее стабильно работает с наименьшими возможными значениями этих параметров
тф любой

На рисунке 1 дан график суточного изменения цены по eurusd (суточные бары), параметры эксперта оптимизированы за период 01.01.2008 - 01.11.2008.
Эксперт нормально работает и последние два месяца и вторую половину 2007 года, что и подтверждается графиком

Обращаюсь за помощью к тем кому понравился этот эксперт или Вы нашли в нем рациональное зерно.
Основные проблемы:
1. Большая просадка, можно поставить фильтры на основе каких либо индикаторов чтобы закрывать раньше, позже или стопы, профиты передвигать (не получается у меня)
2. У кого есть хороший опыт работы на реале, то эксперт бы очень хотелось до этого состояния довести ...
(например, на демке fxstart не модифиуцирует ордера (в тестере нормально), а на forex4u все ок)
Буду благодарен за любые отзывы, пожелания и предложения.
Присылайте переделанные эксперты, set файлы для разных инструментов, найденные ошибки
Эксперт не буду закрывать или продавать, всем кто поможет довести его о ума буду высылать последние версии.
И я против того чтобы этот эксперт продавали !
(не потому что он хороший/плохой, а потому что IMHO только автор(ы) имеют на это право) 

Кстати, если Вам нужна куча экспертов, то вот она (351 мб) http://depositfiles.com/files/lxs1avv7l
(скачано в основном с одного сайта, там будет ссылка)
*/
//
//
#property copyright "runik"
#property link      "ngb2008@mail.ru"

//---- input parameters
extern string  g1="Основные параметры";
extern int       netstep=23;
extern int       sl=115;
extern int       tp=300;
extern int       TrailingStop=75;
extern double    mul=1.7;
extern int       trailprofit=1;   // передвигать ли профит

extern string  gg="Управление деньгами";

extern int       mm=2; 
                  // 0 - постоянный лот, 
                  // 1 - вычисляется в % от депо и maxtrades, 
                  // 2 - вычисляется в зависимости от первоначального лота и maxtrades
extern double    Lots=1;
extern double    LotLim=7;
extern int       maxtrades=4;
extern double    percent=10;
extern double    minsum=5000;
extern int       bezub=0; // если 1, переносятся стопы в безубыток
extern int       deltalast=5; // если после совершения последней сделки цена отойдет на 5 пунктов в нужную сторону, то переносим в безубыток 

extern string  bq="Фильтры";

extern int       usema=0;
extern int    MovingPeriod       = 100;
extern int    MovingShift        = 0;

extern string  bb="Малозначимые переменные";

extern int       chas1=0;        // часы работы
extern int       chas2=24;
extern int       per=0;       // период в барах
extern int       center=0; // 0 - торгуем от краев диапазона, 1- торгуем от центра
extern int       c10=10; // используется для округления лотов
extern int       c20=10000; // используется для округления цен

int oldtr=0;
double nulpoint=0;


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
 if (oldtr>TrailingStop) {TrailingStop=oldtr;}
//   Определяем размер лота, что-то не очень работает
if (mm==1)
   {
double lotsi=MathCeil(AccountBalance()/1000*percent/100);
  LotLim=lotsi;
  for(int t=1;t<=maxtrades;t++)   
    {
    lotsi=lotsi/mul;
    }
    lotsi=MathRound(lotsi*c10)/c10;    
    Lots=lotsi;
    }

if (mm==2)
   {
   lotsi=Lots;
  for(t=1;t<=maxtrades;t++)   
    {
    lotsi=lotsi*mul;
    }
    LotLim=lotsi;
    }    
    
    
    


if(DayOfWeek()==0 || DayOfWeek()==6)  return(0);// не работает в выходные дни.

if(AccountFreeMargin()<minsum) // деньги кончились
        {
         Print("We have no money. Free Margin = ", AccountFreeMargin());
         return(0);  
        }   
        
        

if (OrdersTotal()<1) // начинаем !
  {
  if (Hour()<chas1 || Hour()>(chas2) || chas1>chas2) return(0);// время в диапазоне
  
     if (per>0 && center==0) 
        {   
          double ssmax=High[1];
          double ssmin=Low[1];
          for (int x=2;x<=per;x++)
            {
            if (ssmax < High[x]) ssmax=High[x];
            if (ssmin > Low[x]) ssmin=Low[x];
            }
         if (Ask>=ssmax || Ask<=ssmin)
            {
            int ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask+netstep*Point,3,Ask+netstep*Point-sl*Point,Ask+netstep*Point+tp*Point,"BUYSTOP",0,0,Green);          
            ticket=OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid-netstep*Point,3,Bid-netstep*Point+sl*Point,Bid-netstep*Point-tp*Point,"STOPLIMIT",0,0,Green);   
            }
        }
        
     if (per>0 && center==1) 
        {   
          ssmax=High[1];
          ssmin=Low[1];
          for (x=2;x<=per;x++)
            {
            if (ssmax < High[x]) ssmax=High[x];
            if (ssmin > Low[x]) ssmin=Low[x];
            }
         if (Ask==(ssmax+ssmin)/2 || Bid==(ssmax+ssmin)/2)
            {
            ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask+netstep*Point,3,Ask+netstep*Point-sl*Point,Ask+netstep*Point+tp*Point,"BUYSTOP",0,0,Green);          
            ticket=OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid-netstep*Point,3,Bid-netstep*Point+sl*Point,Bid-netstep*Point-tp*Point,"STOPLIMIT",0,0,Green);   
            }
        }        
  
    if (per==0)
    {
    ticket=OrderSend(Symbol(),OP_BUYSTOP,Lots,Ask+netstep*Point,3,Ask+netstep*Point-sl*Point,Ask+netstep*Point+tp*Point,"BUYSTOP",0,0,Green) ;        
    ticket=OrderSend(Symbol(),OP_SELLSTOP,Lots,Bid-netstep*Point,3,Bid-netstep*Point+sl*Point,Bid-netstep*Point-tp*Point,"STOPLIMIT",0,0,Green);  
    }
    
  }

int cnt=0;
int mode=0; 

double buylot=0;double buyprice=0;double buystoplot=0;double buystopprice=0;double buylimitlot=0;double buylimitprice=0;
double selllot=0;double sellprice=0;double sellstoplot=0;double sellstopprice=0;double selllimitlot=0;double selllimitprice=0;
double buysl=0;double buytp=0;double sellsl=0;double selltp=0;
int bt=-1;int bst=-1;int blt=-1;int st=-1;int sst=-1;int slt=-1;

if (OrdersTotal()>0)////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
{

  for(cnt=0;cnt<OrdersTotal();cnt++)   // запоминаем параметры ордеров
    {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    mode = OrderType(); 
    
    if (mode==OP_BUY )        
      {
      if (buylot<OrderLots())  // запоминаем параметры самого большого открытого ордера
        {     buylot=OrderLots();
              buyprice=OrderOpenPrice();
              bt=OrderTicket(); 
              buysl=OrderStopLoss(); 
              buytp=OrderTakeProfit(); 
        }  
      }     
           
           
    if (mode==OP_BUYSTOP )    {       buystoplot=OrderLots();    buystopprice=OrderOpenPrice();    bst=OrderTicket();  }         
    if (mode==OP_BUYLIMIT )   {       buylimitlot=OrderLots();   buylimitprice=OrderOpenPrice();   blt=OrderTicket();  }      
    
    if (mode==OP_SELL )       
      { 
      if (selllot<OrderLots())      // запоминаем параметры самого большого открытого ордера
         {    selllot=OrderLots();       
              sellprice=OrderOpenPrice();       
              st=OrderTicket(); 
              sellsl=OrderStopLoss(); 
              selltp=OrderTakeProfit(); 
         }      
      }     
    
    if (mode==OP_SELLSTOP )   {       sellstoplot=OrderLots();   sellstopprice=OrderOpenPrice();   sst=OrderTicket();  }     
    if (mode==OP_SELLLIMIT )  {       selllimitlot=OrderLots();  selllimitprice=OrderOpenPrice();  slt=OrderTicket();  }     
    
    }   
    
if (selllot>=Lots) // если цена пошла вниз
  {   
  if (bst>0) {OrderDelete(bst);      return(0);    }
  
  if (sellstopprice==0  && LotLim>MathRound(c10*selllot*mul)/c10) {
  ticket=OrderSend(Symbol(),OP_SELLSTOP,MathRound(c10*selllot*mul)/c10,sellprice-netstep*Point,3,sellprice-netstep*Point+sl*Point,sellprice-netstep*Point-tp*Point,"STOPLIMIT",0,0,Green);         return(0);}
  }
  
if (buylot>=Lots) // если цена пошла вверх
  {   

  if (sst>0) {OrderDelete(sst);      return(0);    }  

  if (buystopprice==0 && LotLim>MathRound(c10*buylot*mul)/c10) {
  ticket=OrderSend(Symbol(),OP_BUYSTOP,MathRound(c10*buylot*mul)/c10,buyprice+netstep*Point,3,buyprice+netstep*Point-sl*Point,buyprice+netstep*Point+tp*Point,"BUYSTOP",0,0,Green);               return(0);}

  }

if (buylot!=0 || selllot!=0) // контролируем открытые позиции
  {
double tp1,sl1;

  for(cnt=0;cnt<OrdersTotal();cnt++)    // после того как был модифицирован самый большой ордер, надо более мелкие подтаскивать к стопу и профиту большого
    {
    OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
    mode = OrderType(); tp1=OrderTakeProfit();sl1=OrderStopLoss();
    if (mode==OP_BUY) 
      {
      if (buytp>tp1 || buysl>sl1 ) 
        {
        OrderModify(OrderTicket(),OrderOpenPrice(),buysl,buytp,0,Purple);return(0);
        }        
      }     
    if (mode==OP_SELL) 
      {
      if (selltp<tp1 || sellsl<sl1 ) 
        {        
        OrderModify(OrderTicket(),OrderOpenPrice(),sellsl,selltp,0,Purple);return(0);
        
        }        
      } 
    
    }
      
  oldtr=TrailingStop;
  if (LotLim<MathRound(c10*selllot*mul)/c10 || LotLim<MathRound(c10*buylot*mul)/c10) // лостигнут лимит количества открываемых сделок, надо тащить стоп и профит
    {     
    if(TrailingStop>0)
      {
         if (usema==1) 
         {
          double oldts=TrailingStop;
          double ma=iMA(NULL,0,MovingPeriod,MovingShift,MODE_SMA,PRICE_CLOSE,0);
             if (buylot>0 && Ask<ma){TrailingStop=MathRound(TrailingStop/2);}
             if (selllot>0 && Bid>ma){TrailingStop=MathRound(TrailingStop/2);}
             Print(Ask,"   ",ma,"   ",TrailingStop,"   ",buylot,"   ",selllot,"   ");
         }
         
         if (bezub==1) 
         {
           if (buyprice<(Ask+deltalast*Point)) 
             {
              OrderModify(bt,buyprice,nulfunc(),buytp,0,Green);return(0);   
             }
           if (sellprice>(Bid-deltalast*Point)) 
             {              
              OrderModify(st,sellprice,nulfunc(),selltp,0,Green);return(0);                 
             }             
         }      
      
      if(buysl>0)
        {
        if(High[0]-buysl>TrailingStop*Point+1*Point) // +1 - чтобы не было ERR_NO_RESULT 1 OrderModify пытается изменить уже установленные значения такими же значениями.
          {   
            if (trailprofit==1) 
            {
            //Print(Ask,"   ",bt,"   ",buyprice,"   ",High[0]-TrailingStop*Point,"   ",buytp);
            OrderModify(bt,buyprice,High[0]-TrailingStop*Point,High[0]+tp*Point,0,Green);return(0);               
            }else
            {
            OrderModify(bt,buyprice,High[0]-TrailingStop*Point,buytp,0,Green);return(0);
            }
          }   
        }   
        if(sellsl>0)
        {
        if(sellsl-Low[0]>TrailingStop*Point+1*Point)
          {
          //Print(Ask,"   ",st,"   ",sellprice,"   ",Low[0]+TrailingStop*Point,"   ",selltp);
            if (trailprofit==1) 
            {
            OrderModify(st,sellprice,Low[0]+TrailingStop*Point,Low[0]-tp*Point,0,Green);return(0);
            
            } else 
            {          
            OrderModify(st,sellprice,Low[0]+TrailingStop*Point,selltp,0,Green);return(0);
            
            }
          }   
        }       
                     
      }//if(TrailingStop>0)
    
    }//if (LotLim<MathRound(c10*selllot*mul)/c10 || LotLim<MathRound(c10*buylot*mul)/c10) 
  
  } // if (buylot!=0 || selllot!=0)
  
  if (buylot==selllot && buylot==0) // когда все сработало, но висит отложенный
  {
  if (bst>0 && buystoplot!=Lots) {OrderDelete(bst);      return(0);    }
  if (slt>0 && selllimitlot!=Lots) {OrderDelete(slt);      return(0);    }
  if (blt>0 && buylimitlot!=Lots) {OrderDelete(blt);      return(0);    }
  if (sst>0 && sellstoplot!=Lots) {OrderDelete(sst);      return(0);    }            
  } 

  
} //if (OrdersTotal()>0)


 
//----
   return(0);
  }
//+------------------------------------------------------------------+


double nulfunc() // для подсчета точки безубыточности всех открытых ордеров (если все их закрыть по этой цене то получим 0)
  {
    double np=0;double f=0; double p=0;double l=0; int m=0;
    for(int t1=0;t1<OrdersTotal();t1++)    
    {
    OrderSelect(t1, SELECT_BY_POS, MODE_TRADES); 
    m = OrderType();p=OrderOpenPrice();l=OrderLots();
    if  (m==OP_BUY || m==OP_SELL) 
      {
      np=np+l*p;  
      f=f+l;
      }
    }
    np=np/f;
    np=MathCeil(np*c20)/c20;
    Print(np);  
   return (np);
  }