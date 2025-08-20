//+------------------------------------------------------------------+
//|Пробой уровня прошлой свечи            BreakdownLevelCandleMA.mq4 |
//|                               Copyright © 2011, Хлыстов Владимир |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, http://cmillion.narod.ru"
#property link      "cmillion@narod.ru"
//--------------------------------------------------------------------
extern string  _="M15 15 | M30 30 | H1 60 | H4 240 | D1 1440 | W1 10080 | MN1 43200";
extern int    TimeCandle   = 240;      //таймфрейм свечи, которую пробиваем 0 текущий ТФ
extern int    Delta        = 10,       //Выше или ниже екстремумов дня
              SL           = 120,      //Стоплосс в пунктах
              TP           = 90,       //Тейкпрофит в пунктах
              risk         = 0,        //Если 0 то по фиксированному лоту
              NoLoss       = 0,        //Если 0 то нет установки безубытка
              trailing     = 0;        //Если 0 то нет трейлинга
extern double Lot          = 0.10;     //используется только при risk = 0
extern int    MaxOrders    = 10;       //Максимальное кол-во ордеров одного направления
extern color  color_BAR    = DarkBlue; //цвет инфо
extern double ProfitClose  = 100;      //закрывать все ордера при получении профита
//--------------------------------------------------------------------
extern string  фильтр..МА="если FastMA выше SlowMA то только Buy";
extern int     periodFastMA         = 0 ;     //Фильтр по МА Если Fast и Slow = 0 то нет фильтра
extern int     periodSlowMA         = 0 ;     //если Fast > Slow то разрешены только Buy иначе только Sell
//--------------------------------------------------------------------
double        MaxPrice,MinPrice;
int           STOPLEVEL,magic=123321,tip,TimeBarBay,TimeBarSell,LastDay;
string txt;
//--------------------------------------------------------------------
int init()
{
   TimeCandle = next_period(TimeCandle);
   STOPLEVEL = MarketInfo(Symbol(),MODE_STOPLEVEL);
   if (SL < STOPLEVEL) SL = STOPLEVEL;
   if (TP < STOPLEVEL) TP = STOPLEVEL;
   if (NoLoss   < STOPLEVEL && NoLoss   != 0) NoLoss   = STOPLEVEL;
   if (trailing < STOPLEVEL && trailing != 0) trailing = STOPLEVEL;
   txt = StringConcatenate("Copyright © 2011 cmillion@narod.ru\nУстановленные параметры BreakdownLevelDay "+"\n"+
      "TimeCandle  " , StrPer(TimeCandle),"\n",
      "Delta            " , Delta,         "\n",
      "MaxOrders   " , MaxOrders,      "\n",
      "SL               ", SL,             "\n",
      "TP               " , TP,             "\n",
      "Lot               ", DoubleToStr(Lot,2),"\n",
      "risk              ", risk,              "\n",
      "NoLoss         "   , NoLoss,         "\n",
      "trailing     ", trailing,"\n");
}
//--------------------------------------------------------------------
int start()
{
   double Profit;
   if (Profit>=ProfitClose) CLOSEORDER();
   //-----------------------------------------------------------------
   int bay,sel;
   for (int i=0; i<OrdersTotal(); i++)
   {  if (OrderSelect(i, SELECT_BY_POS))
      {  
         if (OrderSymbol()!=Symbol() || OrderMagicNumber()!=magic) continue;
         tip=OrderType();
         if (tip==0) {bay++; Profit+=OrderProfit();}
         if (tip==1) {sel++; Profit+=OrderProfit();}
      }   
   }
   Comment(txt,"\nБаланс ",DoubleToStr(AccountBalance(),2),"\nЭквити ",DoubleToStr(AccountEquity(),2),"\nПрофит ",DoubleToStr(Profit,2),"\nBuy ",bay,"\nSel ",sel);
   if (bay>0 || sel>0) 
   {
      if (trailing!=0) TrailingStop(trailing);
      if (NoLoss!=0) No_Loss(NoLoss);
   }
   bool BUYOK=true,SELLOK=true;
   if ( periodFastMA!=0 && periodSlowMA!=0 )
   {
      double FastMA = iMA(NULL,0,periodFastMA,0,MODE_EMA,PRICE_OPEN,0);
      double SlowMA = iMA(NULL,0,periodSlowMA,0,MODE_EMA,PRICE_OPEN,0);
      BUYOK = (FastMA>SlowMA);
      SELLOK = (FastMA<SlowMA);
   }
   double TrPr,StLo;
   MaxPrice=NormalizeDouble(iHigh(NULL,TimeCandle,1)+Delta*Point,Digits);
   MinPrice=NormalizeDouble(iLow(NULL,TimeCandle,1)-Delta*Point,Digits);
   if (risk!=0) Lot = LOT(); 
   if (bay<MaxOrders && TimeBarBay!=iTime(NULL,TimeCandle,0) && BUYOK && Ask>=MaxPrice)
   {
      if (TP!=0) TrPr = NormalizeDouble(MaxPrice + TP * Point,Digits);                 
      if (SL!=0) StLo = NormalizeDouble(MaxPrice - SL * Point,Digits);                 
      if (!OrderSend(Symbol(),OP_BUY,Lot,NormalizeDouble(Ask,Digits),3,StLo,TrPr,"BreakdownLevelCandleMA",magic,0,Blue))
         Print("Error BUYSTOP ",GetLastError(),"   ",Symbol(),"   Lot ",Lot,"   Price ",MaxPrice,"   SL ",StLo,"   TP ",TrPr);
      else TimeBarBay=iTime(NULL,TimeCandle,0);
   }
   if (sel<MaxOrders && TimeBarSell!=iTime(NULL,TimeCandle,0) && SELLOK && Bid<=MinPrice)
   {
      if (TP!=0) TrPr = NormalizeDouble(MinPrice - TP * Point,Digits);                 
      if (SL!=0) StLo = NormalizeDouble(MinPrice + SL * Point,Digits);   
      if (!OrderSend(Symbol(),OP_SELL,Lot,NormalizeDouble(Bid,Digits),3,StLo,TrPr,"BreakdownLevelCandleMA",magic,0,Red ))
         Print("Error SELLSTOP ",GetLastError(),"   ",Symbol(),"   Lot ",Lot,"   Price ",MinPrice,"   SL ",StLo,"   TP ",TrPr);
      else TimeBarSell=iTime(NULL,TimeCandle,0);
   }
   if (bay<MaxOrders && sel<MaxOrders)
   {
      ObjectDelete("bar0");
      ObjectCreate("bar0", OBJ_RECTANGLE, 0, 0,0, 0,0);
      ObjectSet   ("bar0", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet   ("bar0", OBJPROP_COLOR, color_BAR);
      ObjectSet   ("bar0", OBJPROP_BACK,  true);
      ObjectSet   ("bar0", OBJPROP_TIME1 ,iTime(NULL,TimeCandle,1));
      ObjectSet   ("bar0", OBJPROP_PRICE1,MaxPrice);
      ObjectSet   ("bar0", OBJPROP_TIME2 ,TimeCurrent());
      ObjectSet   ("bar0", OBJPROP_PRICE2,MinPrice);
   }
   return(0);
}
//--------------------------------------------------------------------
void TrailingStop(int trailing)
{
   double StLo,OSL,OOP;
   int tip;
   bool error=true;
   color col;
   for (int i=0; i<OrdersTotal(); i++) 
   {
      if (OrderSelect(i, SELECT_BY_POS))
      {
         tip = OrderType();
         if (tip<2 && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
         {
            OSL   = NormalizeDouble(OrderStopLoss(),Digits);
            OOP   = NormalizeDouble(OrderOpenPrice(),Digits);
            if (tip==0)        
            {  
               StLo = NormalizeDouble(Bid - trailing*Point,Digits);
               if (StLo < OOP) continue;
               if (StLo > OSL)
                  error=OrderModify(OrderTicket(),OrderOpenPrice(),StLo,OrderTakeProfit(),0,White);

            }                                         
            if (tip==1)    
            {                                         
               StLo = NormalizeDouble(Ask + trailing*Point,Digits);           
               if (StLo > OOP) continue;
               if (StLo < OSL || OSL==0 )
                  error=OrderModify(OrderTicket(),OrderOpenPrice(),StLo,OrderTakeProfit(),0,White);
            } 
            if (!error) Alert("Error TrailingStop ",GetLastError(),"   ",Symbol(),"   SL ",StLo);
         }
      }
   }
}
//------------------------------------------------------------------+
double LOT()
{
   double MINLOT = MarketInfo(Symbol(),MODE_MINLOT);
   double LOT = AccountFreeMargin()*risk/100/MarketInfo(Symbol(),MODE_MARGINREQUIRED)/15;
   if (LOT>MarketInfo(Symbol(),MODE_MAXLOT)) LOT = MarketInfo(Symbol(),MODE_MAXLOT);
   if (LOT<MINLOT) LOT = MINLOT;
   if (MINLOT<0.1) LOT = NormalizeDouble(LOT,2); else LOT = NormalizeDouble(LOT,1);
   return(LOT);
}
//------------------------------------------------------------------+
void No_Loss(int NoLoss)
{
   double OOP,OSL;
   int tip;
   bool error=true;
   color col;
   for (int i=0; i<OrdersTotal(); i++) 
   {
      if (OrderSelect(i, SELECT_BY_POS))
      {
         tip = OrderType();
         if (tip<2 && OrderSymbol()==Symbol() && OrderMagicNumber()!=magic)
         {
            OOP = NormalizeDouble(OrderOpenPrice(),Digits); 
            OSL = NormalizeDouble(OrderStopLoss(),Digits); 
            if (tip==0)
            {  
               if ((Bid-OOP)/Point>=NoLoss && OOP > OSL) 
                  error=OrderModify(OrderTicket(),OOP,OOP,OrderTakeProfit(),0,White);
            }                                         
            if (tip==1)
            {                                         
               if ((OOP-Ask)/Point>=NoLoss && (OOP < OSL || OSL ==0))
                  error=OrderModify(OrderTicket(),OOP,OOP,OrderTakeProfit(),0,White);
             } 
            if (!error) Alert("Error No_Loss ",GetLastError(),"   ",Symbol());
         }
      }
   }
}
//------------------------------------------------------------------+
int next_period(int per)
{
   if (per > 43200)  return(0); 
   if (per > 10080)  return(43200); 
   if (per > 1440)   return(10080); 
   if (per > 240)    return(1440); 
   if (per > 60)     return(240); 
   if (per > 30)     return(60);
   if (per > 15)     return(30); 
   if (per >  5)     return(15); 
   if (per >  1)     return(5);   
   if (per == 1)     return(1);   
   if (per == 0)     return(Period());   
}
//+------------------------------------------------------------------+
string StrPer(int per)
{
   if (per == 1)     return("M1");
   if (per == 5)     return("M5");
   if (per == 15)    return("M15");
   if (per == 30)    return("M30");
   if (per == 60)    return("H1");
   if (per == 240)   return("H4");
   if (per == 1440)  return("D1");
   if (per == 10080) return("W1");
   if (per == 43200) return("MN1");
return("ошибка периода");
}
//+------------------------------------------------------------------+
void CLOSEORDER()
{
   bool error,Draw=1;
   int err,OT;
   while (true)
   {  error=true;
      for (int i=OrdersTotal()-1; i>=0; i--)
      {                                               
         if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic)
            {
               OT = OrderType();
               if (OT==OP_BUY)
                  error=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,Digits),3,CLR_NONE);
               if (OT==OP_SELL)
                  error=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,Digits),3,CLR_NONE);
            }
         }   
      }
      if (!error) {err++;Print("CLOSEORDER Error ",GetLastError());Sleep(2000);RefreshRates();}
      if (error || err >10) 
      {
         return;
      }
   }
}
//--------------------------------------------------------------------