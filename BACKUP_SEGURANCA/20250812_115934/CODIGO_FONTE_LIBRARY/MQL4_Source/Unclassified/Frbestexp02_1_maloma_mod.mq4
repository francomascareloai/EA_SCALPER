//+------------------------------------------------------------------+
//|                   FrBestExp02_1.mq4                              |
//|                                                                  |
//|                   1 более надёжные точки входа                   | 
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//----
extern double  Lots = 1.00;
extern int     Stop_Loss = 1000;
extern int     Take_Profit = 1000;
extern int     Trailing_Stop = 0;
//    Only for M15
extern int Vlim=50;
extern int fper=12,sper=26,sigper=9;   // периоды индикатора OsMA
extern int stop=300;                   // Уровень отсечки профита
extern int  hedg=1;                    // флаг разрешения хеджа
extern double  kh=10;                  // коэфф.хеджирования
extern int lok;                        // флаг разрешения локирования позиции
extern int rpr=1;                      // флаг определения просадки позы или по всему тесту
extern int ttime=900;                  // Задержка выставления хедж-ордера на 1 свечу
extern int hstop=-3000;                // стоп-лосс для хеджа
//----
int cnt;                               // индекс цикла
int sigs,sigb;                         // суммирующий сигнал на проведение операции купли-продажи
//----
double ssig,bsig;                      // сигналы на куплю-продажу от индикатора фракталов
double  osmanul,osmaone;               // сигналы индикатора OsMA от нулевого и первого баров
int s,b;                               // количество активных сэлл и бай ордеров
int hml;                               // флаг закрытия позиции с минусовым профитом (закрывается позиция с меньшим лотом
int pl;                                // флаг закрытия всех позиций по условию наличия установленного положительного профита
double summa;                          // суммарный профит по всем позициям
double mlot;                           // величина торгуемого лота
double ssum,bsum;                      // профит по ордерам сэлл и бай раздельно
double pr;                             // величинга просадки
int hblok,shblok,bhblok;               // флаг блокирования выставления хедж-ордера и флаги повторного запуска хедж-процедуры
double DHMax,DLMin;
bool ft=true;
int rang;
double pt;
int nul;                               // переменные для вычисления поворотной точки при запуске и в 00.00 каждых суток
int LastTradeTime;
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
double FractalBest(int Dir)
 {
  double up,dw;
//----
   if(High[3]>High[4] && High[3]>High[5] && High[3]>High[2] && High[3]>High[1]){ 
      up=Low[0]-3*Point;
   }
      else
   {
      up=0;
   }
   if(Low[3]<Low[4] && Low[3]<Low[5] && Low[3]<Low[2] && Low[3]<Low[1]){ 
      dw=High[0]+3*Point;
   }
      else
   {
      dw=0;
   }
 if (Dir==0) {return(up);}
 if (Dir==1) {return(dw);}
 }
int start()
{
   mlot=Lots; // определение величины рабочего лота
//--------------------------------------------Вычисленияповоротной точки------------------------------------------
   if ((Hour()==0 && Minute()==0) || ft){   //начались сутки или первый запуск
      DHMax=0;
      DLMin=1000;
         if(ft)
         {// первый запуск 
            rang=MathRound((Hour()*60+Minute())/Period());
            nul=rang;
         }
            else
         {
            nul=96;//за сутки на 15
            rang=1;
         }
         for(cnt=rang;cnt<=rang+95;cnt++)
         {//поиск макс и мин за последние сутки
            if(DHMax<High[cnt])DHMax=High[cnt];
            if(DLMin>Low[cnt])DLMin=Low[cnt];
         }
      pt=(DHMax+DLMin+Close[nul])/3;//поворотная точка
      ft=false;
   }
//----------------------------------------------------------------------------------------------------------------
   if(CurTime()-LastTradeTime<20)return(0);
//----------------------------Определения общего и позиционного профита, а такжеподсчёт позиций-------------------
   s=0;b=0;summa=0;bsum=0;ssum=0;
      for(cnt=0;cnt<OrdersTotal();cnt++)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderType()==OP_SELL)
            {
               ssum=ssum+OrderProfit();
               s=s+1;
            }
            if(OrderSymbol()==Symbol() && OrderType()==OP_BUY){
             
               bsum=bsum+OrderProfit();
               b=b+1;
            }
      }
   summa=bsum+ssum;summa=MathRound(summa);
//------------------------------------------------------Трейлинг-Стоп---------------------------------------------
   if(Trailing_Stop>0 && hedg==1)
   { 
      for(cnt=0;cnt<OrdersTotal();cnt++)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderProfit()>0)
            { 
               if(Bid-OrderOpenPrice()>Point*Trailing_Stop)
               { 
                  if(OrderStopLoss()<Bid-Point*Trailing_Stop)
                  { 
                     OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*Trailing_Stop,OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
               if(OrderOpenPrice()-Ask>Point*Trailing_Stop)
               { 
                  if(OrderStopLoss()>Ask+Point*Trailing_Stop)
                  { 
                     OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*Trailing_Stop,OrderTakeProfit(),0,Red);
                     return(0);
                  }
               }
            }
        }
   }
//---------------------------------------------------Выставление хедж-ордера--------------------------------------
   if(hblok==1)
   {
      shblok=0;bhblok=0;
      for(cnt=0;cnt<OrdersTotal();cnt++)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
            if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderLots()==mlot*kh)shblok=1;
            if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderLots()==mlot*kh)bhblok=1;
      }
   }
   if(shblok==1 && bhblok==1)hblok=1;
   if(shblok==0 && bhblok==0)hblok=0;
   //if s+b=0 then hblok=0;
   if((s+b<=2 && (lok==1 || lok==0)) && hedg==1 && hblok==0)
   {
      if(CurTime()-LastTradeTime<ttime)return(0);
      if(ssum>=150 || bsum<-300)
      { 
         OrderSend(Symbol(),OP_SELL,kh*mlot,Bid,5,Bid+Stop_Loss*Point,Bid-Take_Profit*Point,NULL,0,0,Aqua);
         //SetArrow(Time[0],H+5*Point,159,Aqua);
         hblok=1;
         return(0);
      }
      if(bsum>=150 || ssum<-300)
      {
         OrderSend(Symbol(),OP_BUY,kh*mlot,Ask,5,Ask-Stop_Loss*Point,Ask+Take_Profit*Point,NULL,0,0,Red);
         //SetArrow(Time[0],L-5*Point,159,Red);
         hblok=1;
         return(0);
      }
   }
//------------------------------------------Вычисление просадки в процессе торгов------------------------------
   if(s+b==0 && rpr==0)pr=0;
   if(pr>summa && summa<0)pr=MathRound(summa);
//-----------------------------------Определение основного сигнала и сигналов индикаторов------------------------
//   bsig=iCustom(NULL,0,"FractalBest",0,0);
//   ssig=iCustom(NULL,0,"FractalBest",1,0);
   bsig=FractalBest(0);
   ssig=FractalBest(1);
   osmanul=iOsMA(NULL,0,fper,sper,sigper,PRICE_CLOSE,0);
   osmaone=iOsMA(NULL,0,fper,sper,sigper,PRICE_CLOSE,1);
//----   
   if(ssig>1 && Volume[1]>Vlim && Volume[1]>Volume[2] && osmaone>osmanul && osmaone<=0 && osmanul<0 && Close[0]>pt)
   {
      sigs=1;
   }
      else
   {
      sigs=0;
   }
   if(bsig>1 && Volume[1]>Vlim && Volume[1]>Volume[2] && osmaone<osmanul && osmaone>=0 && osmanul>0 && Close[0]<pt)
   {
      sigb=1;
   }
      else
   {
      sigb=0;
   }
   /*
//--------------------------------------------Вывод дампа работы эксперта в журнал---------------------------------
Print("Data: ",Year(),".",Month(),".",Day(),"  Time ",Hour(),":",Minute(),"   1Tik=",Volume[2],"  0Tiks=",Volume[1],"  PT=",pt,
      "  Price=",Close[0],"  BSig=",MathRound(bsig),"  SSig=",MathRound(ssig),"  SSum=",MathRound(ssum),"  BSum=",MathRound(bsum),
      "  Prosadka=",pr,"  HBlok=",hblok);
//---------------------------------Определене модели закрытия ордеров по профиту-----------------------------------
*/
   if(s+b<=1)
   {
      hml=0;pl=0;
   }
   if(summa>=stop*mlot && s+b==1 && Trailing_Stop==0)pl=1;
   if(summa>2*stop && s+b==2 && lok==0 && Trailing_Stop==0)pl=1;
   if(summa>=3*stop*mlot && s+b==3 && lok==1 && Trailing_Stop==0)pl=1;
   if(Trailing_Stop>0)pl=0;
   if(Trailing_Stop>0 && (ssum<hstop || bsum<hstop))pl=1; // стоп для неудачного хеджа
   if(Trailing_Stop>0 && ((ssum<-300 && bsum>300) || (ssum>300 && bsum<-300)) && s+b>=2 && hedg==1 && pl==0)hml=1; 
// Удаление мелкой позиции с отрицательным профитов после удачного запуска хеджа
//------------------------------Удаление хеджируемого ордера при получении заданного профита-----------------------
   if(hml==1)
   {
      for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); 
            if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && ssum<-2*stop && NormalizeDouble(OrderLots(),1)==NormalizeDouble(1.0*mlot,1))
            {                                    
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
               //return(0);
            } 
            if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && bsum<-2*stop && NormalizeDouble(OrderLots(),1)==NormalizeDouble(1.0*mlot,1))
            { 
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
               //return(0);
            }
      }
      return(0);
   }
//---------------------------Закрытие всех открытых на паре ордеров при достижении заданного профита
   if(pl==1)
   { 
      for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
      {
         OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES); 
            if(OrderSymbol()==Symbol() && OrderType()==OP_SELL)
            {                                    
               OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
               //return(0);
            }
            if(OrderSymbol()==Symbol() && OrderType()==OP_BUY)
            {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,Red);
               //return(0);
            }
      }
      return(0);
   }
//------------------------------------------Выставление основных и локирующих ордеров------------------------------
   if(s+b<=1)
   { 
      if((sigs==1 && s+b==0) || (bsum<-150 && lok==1))
      { 
         OrderSend(Symbol(),OP_SELL,mlot,Bid,5,Bid+Stop_Loss*Point,Bid-Take_Profit*Point,NULL,0,0,Lime);
         //SetArrow(Time[0],H+5*Point,242,Lime);
         return(0);
      }
      if((sigb==1 && s+b==0) || (ssum<-150 && lok==1))
      {
         OrderSend(Symbol(),OP_BUY,mlot,Ask,5,Ask-Stop_Loss*Point,Ask+Take_Profit*Point,NULL,0,0,Gold);
         //SetArrow(Time[0],L-5*Point,241,Gold);
         return(0);
      }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+