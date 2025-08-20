//+------------------------------------------------------------------+
//|                                             SHE_kanskigor.mq4 |
//|                                         Copyright © 2006, Shurka |
//|                                                 shforex@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Shurka"
#property link      "shforex@narod.ru"
#define MAGIC 130306

extern double        Lots=0.1;         // Количество лотов для торгов
extern int           Profit=35;        // Величина тейкпрофита, если 0 - играем без профита
extern int           Stop=55;          // Величина стоплосса, если 0 - играем без стопа
extern int           Slippage=5;       // Проскальзывание
extern string        Symb="*";         // Символ для торгов. Если * то по текущему символу графика
                                       // иначе нужно вписать инструмент типа EURUSD
extern string        StartTime="00:05";// Время старта по гринвичу

datetime             TimeStart;
double               stoplevel,profitlevel;
string               SMB;
bool                 trade=false;

//+------------------------------------------------------------------+
//| Основная функция                                                 |
//+------------------------------------------------------------------+
int start()
{
   int      i,b;
   
   // Переводим время из строчной величины StartTime во временнУю TimeStart
   TimeStart=StrToTime(StartTime);
   // Если текущее время меньше стартового или больше его на 5 минут, то выходим и ничего не делаем.
   // Но предварительно делаем переменную trade ложной. Просто сбрасываем информацию о том, что уже открывались.
   if(CurTime()<TimeStart || CurTime()>TimeStart+300) { trade=false; return(0); }
   // Если trade истинна, значит уже успели открыться.
   if(trade) return(0);
   // Если цена открытия вчера была больше цены закрытия, значит покупаем иначе продаём
   if(iOpen(SMB,PERIOD_D1,1)>iClose(SMB,PERIOD_D1,1)) b=OP_BUY; else b=OP_SELL;
   // Если покупаем
   if(b==OP_BUY)
   {
      // Если Stop был задан 0, то в стопуровень загоняем 0, иначе Ask-Stop
      if(Stop==0) stoplevel=0; else stoplevel=MarketInfo(SMB,MODE_ASK)-Stop*MarketInfo(SMB,MODE_POINT);
      // То же и с профит уровнем
      if(Profit==0) profitlevel=0; else profitlevel=MarketInfo(SMB,MODE_ASK)+Profit*MarketInfo(SMB,MODE_POINT);
      // Открываемся в покупку от цены Ask со стопом stoplevel и профитом profitlevel
      i=OrderSend(SMB,OP_BUY,Lots,MarketInfo(SMB,MODE_ASK),Slippage,stoplevel,profitlevel,NULL,MAGIC,0,Red);
      // Если ордер удачно открылся, то индикатор torg взводим в истину, чтобы больше пока не торговать
      if(i!=-1) trade=true;
   }
   // С продажей то же самое, что и с покупкой.
   if(b==OP_SELL)
   {
      if(Stop==0) stoplevel=0; else stoplevel=MarketInfo(SMB,MODE_BID)+Stop*MarketInfo(SMB,MODE_POINT);
      if(Profit==0) profitlevel=0; else profitlevel=MarketInfo(SMB,MODE_BID)-Profit*MarketInfo(SMB,MODE_POINT);
      i=OrderSend(SMB,OP_SELL,Lots,MarketInfo(SMB,MODE_BID),Slippage,stoplevel,profitlevel,NULL,MAGIC,0,Blue);
      if(i!=-1) trade=true;
   }
   return(0);
}
//+------------------------------------------------------------------+
//| Функция инициализации советника                                  |
//+------------------------------------------------------------------+
int init()
{
   int i;
   // Определяем пару для торговли
   if(Symb=="*") SMB=Symbol(); else SMB=Symb;
   return(0);
}
//+------------------------------------------------------------------+
//| Функция деинициализации советника                                |
//+------------------------------------------------------------------+
int deinit() { return(0); }
//+------------------------------------------------------------------+