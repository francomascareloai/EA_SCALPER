//+------------------------------------------------------------------+
//|                                                    Coin Flip.mq4 |
//|                               Copyright 2015, Vladimir Gribachev |
//|                      https://www.mql5.com/ru/users/moneystrategy |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vladimir Gribachev"
#property link      "https://www.mql5.com/ru/users/moneystrategy"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum lang
  {
   en=0,     // English
   ru=1,     // Russian
  };
input double  Risk           = 0.25;
input double  Lot            = 0.01;
input double  Martingale     = 1.8;
input double  MaxLot         = 1.0;
input int     TakeProfit     = 50;
input int     StopLoss       = 25;
input int     MaxAttempts    = 10;
input int     Pause          = 30;
input int     Slippage       = 10;
input int     TrailingStart  = 14;
input int     TrailingStop   = 3;
sinput int    Magic          = 12345;
sinput string Com            = "Coin Flip";
input bool    DrawInfo       = true;
input lang    Languages      = en;
input color   TextColor      = clrWhite;

double iMartingale,TP,SL;
int dig=1,ticket,iTrailingStart,iTrailingStop,CountBuy,CountSell,iTakeProfit,iStopLoss;
uint l_orders[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   MathSrand(GetTickCount());
   if(Digits==3 || Digits==5)
     {
      dig*=10;
     }
   iMartingale=Martingale;
   iTrailingStart=TrailingStart;
   iTrailingStop=TrailingStop;
   iTakeProfit=TakeProfit;
   iStopLoss=StopLoss;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   for(int i=0; i<ObjectsTotal(0,-1,-1);i++)
     {
      if(StringFind(ObjectName(0,i),"Label")>=0)
         if(ObjectDelete(0,ObjectName(0,i)))
            i--;
     }
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(iTrailingStop<STOPLEVEL) iTrailingStop=(int)STOPLEVEL;
   if(iTrailingStart<STOPLEVEL) iTrailingStart=(int)STOPLEVEL;
   if(iStopLoss<STOPLEVEL) iStopLoss=(int)STOPLEVEL;
   if(iTakeProfit<STOPLEVEL) iTakeProfit=(int)STOPLEVEL;
   lTral_TrailingStop(iTrailingStart*dig,iTrailingStop*dig,_Symbol,Magic,DrawInfo,clrRed);

   double loss=0;
   if(value_profit()<0)
      loss=(-1*value_profit()*100)/AccountBalance();
   string  txt3=(DoubleToStr(loss,2));

   double profit=0;
   if(value_profit()>0)
      profit=(1*value_profit()*100)/AccountBalance();
   string  txt2=(DoubleToStr(profit,2));

   int spread=(int)MarketInfo(OrderSymbol(),MODE_SPREAD);

   if(DrawInfo)
     {
      if(Languages==1)
        {
         SetLabel("Label0","   Торговая информация по счету",TextColor,5,26);
         SetLabel("Label1","   ……………………………………………………………",TextColor,5,32);
         SetLabel("Label2","   ……………………………………………………………",TextColor,5,130);
         SetLabel("Label3","   Просадка: ",TextColor,5,46);
         SetLabel("Label4","   Профит: ",TextColor,5,59);
         SetLabel("Label5","   Заработано сегодня: ",TextColor,5,72);
         SetLabel("Label6","   Заработано вчера: ",TextColor,5,85);
         SetLabel("Label7","   В текущем месяце: ",TextColor,5,98);
         SetLabel("Label8","   В прошлом месяце: ",TextColor,5,111);
         SetLabel("Label9","   Текущая прибыль: ",TextColor,5,124);
         SetLabel("Label11",txt3,TextColor,145,46);
         SetLabel("Label12",txt2,TextColor,145,59);
         SetLabel("Label13",DoubleToStr(Profit(0),2),TextColor,145,72);
         SetLabel("Label14",DoubleToStr(Profit(1),2),TextColor,145,85);
         SetLabel("Label15",DoubleToStr(ProfitMons(0),2),TextColor,145,98);
         SetLabel("Label16",DoubleToStr(ProfitMons(1),2),TextColor,145,111);
         SetLabel("Label17",DoubleToStr(TotalProfit(),2),TextColor,145,124);
         SetLabel("Label19","%",TextColor,225,46);
         SetLabel("Label20","%",TextColor,225,59);
         SetLabel("Label21",AccountCurrency(),TextColor,225,72);
         SetLabel("Label22",AccountCurrency(),TextColor,225,85);
         SetLabel("Label23",AccountCurrency(),TextColor,225,98);
         SetLabel("Label24",AccountCurrency(),TextColor,225,111);
         SetLabel("Label25",AccountCurrency(),TextColor,225,124);
        }

      if(Languages==0)
        {
         SetLabel("Label0","   Trading information",TextColor,5,26);
         SetLabel("Label1","   ……………………………………………………",TextColor,5,32);
         SetLabel("Label2","   ……………………………………………………",TextColor,5,130);
         SetLabel("Label3","   Drawdown: ",TextColor,5,46);
         SetLabel("Label4","   Profit: ",TextColor,5,59);
         SetLabel("Label5","   Today: ",TextColor,5,72);
         SetLabel("Label6","   Yesterday: ",TextColor,5,85);
         SetLabel("Label7","   Current month: ",TextColor,5,98);
         SetLabel("Label8","   Previous month: ",TextColor,5,111);
         SetLabel("Label9","   Total profit: ",TextColor,5,124);
         SetLabel("Label11",txt3,TextColor,115,46);
         SetLabel("Label12",txt2,TextColor,115,59);
         SetLabel("Label13",DoubleToStr(Profit(0),2),TextColor,115,72);
         SetLabel("Label14",DoubleToStr(Profit(1),2),TextColor,115,85);
         SetLabel("Label15",DoubleToStr(ProfitMons(0),2),TextColor,115,98);
         SetLabel("Label16",DoubleToStr(ProfitMons(1),2),TextColor,115,111);
         SetLabel("Label17",DoubleToStr(TotalProfit(),2),TextColor,115,124);
         SetLabel("Label19","%",TextColor,195,46);
         SetLabel("Label20","%",TextColor,195,59);
         SetLabel("Label21",AccountCurrency(),TextColor,195,72);
         SetLabel("Label22",AccountCurrency(),TextColor,195,85);
         SetLabel("Label23",AccountCurrency(),TextColor,195,98);
         SetLabel("Label24",AccountCurrency(),TextColor,195,111);
         SetLabel("Label25",AccountCurrency(),TextColor,195,124);
        }
     }
   CountOrders(CountBuy,CountSell,Magic);
//---   
   if(CountBuy>0 || CountSell>0)
     {
      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(OrderMagicNumber()==Magic)
              {
               if(OrderType()==OP_BUY)
                 {
                  if(OrderStopLoss()==0 || OrderTakeProfit()==0)
                    {
                     SL=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)-StopLoss*dig*MarketInfo(OrderSymbol(),MODE_POINT),Digits);
                     TP=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_BID)+TakeProfit*dig*MarketInfo(OrderSymbol(),MODE_POINT),Digits);
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,clrNONE))Print("error: ",Error(GetLastError()));
                    }
                 }
               if(OrderType()==OP_SELL)
                 {
                  if(OrderStopLoss()==0 || OrderTakeProfit()==0)
                    {
                     SL=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)+StopLoss*dig*MarketInfo(OrderSymbol(),MODE_POINT),Digits);
                     TP=NormalizeDouble(MarketInfo(OrderSymbol(),MODE_ASK)-TakeProfit*dig*MarketInfo(OrderSymbol(),MODE_POINT),Digits);
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),SL,TP,0,clrNONE))Print("error: ",Error(GetLastError()));
                    }
                 }
              }
        }
     }
//---     
   if(iMartingale<1)iMartingale=1;
   double lot=0;
   double MinLots=MarketInfo(_Symbol,MODE_MINLOT);
   double MaxLots=MarketInfo(_Symbol,MODE_MAXLOT);
   bool CalcLot=true;
   if(iMartingale>0)
     {
      double LastLot;
      if(LastOrderLoss(Magic,LastLot))
        {
         lot=NormalizeLot(LastLot*Martingale);
         CalcLot=false;
         if(AccountFreeMarginCheck(_Symbol,OP_BUY,Lot)<=0)
           {
            lot=MoneyManagement();
           }
        }
     }
   if(CalcLot)
     {
      if(Risk>0)lot=MoneyManagement();
      if(lot<MinLots)lot=MinLots;
      if(lot>MaxLots)lot=MaxLots;
      if(Risk<=0)lot=Lot;
     }
   if(lot>MaxLot)lot=NormalizeDouble(MaxLot,2);
   lot=NormalizeLots(lot,_Symbol);
   int coin=MathRand();
   if(CountBuy+CountSell==0)
     {
      if(coin<8192 || coin>24575)
        {
         if(AccountFreeMarginCheck(Symbol(),OP_BUY,lot)<=0){Print("error: ",Error(GetLastError()));return;}
         if(AntiRequoteOrderSend(Symbol(),OP_BUY,lot,NormalizeDouble(Ask,Digits),Slippage*dig,0,0,Com,Magic,0,clrLawnGreen)==-1)
            Print("error: ",Error(GetLastError()));
        }
      if(coin>8192 && coin<24575)
        {
         if(AccountFreeMarginCheck(Symbol(),OP_SELL,lot)<=0){Print("error: ",Error(GetLastError()));return;}
         if(AntiRequoteOrderSend(Symbol(),OP_SELL,lot,NormalizeDouble(Bid,Digits),Slippage*dig,0,0,Com,Magic,0,clrOrangeRed)==-1)
            Print("error: ",Error(GetLastError()));
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LastOrderLoss(int magic,double &lot)
  {
   lot=0;
   for(int i=(OrdersHistoryTotal()-1); i>=0;i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
         if(OrderMagicNumber()==magic)
           {
            if(OrderProfit()<0)
               lot=OrderLots();
            break;
           }
   if(lot>0)
      return true;
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeLot(double lot)
  {
   double minLot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   double stepLot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   if(lot>0)
     {
      lot=MathMax(minLot,lot);
      lot=MathMin(maxLot,lot);
      lot=minLot+NormalizeDouble((lot-minLot)/stepLot,0)*stepLot;
     }
   else
      lot=0;
   return lot;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MoneyManagement()
  {
   double lots=0;
   double Free_Equity=AccountEquity();
   if(Free_Equity<=0)return(0);
   double TickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   double LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
   lots=MathFloor((Free_Equity*MathMin(Risk,100)/100)/(StopLoss*dig*TickValue)/LotStep)*LotStep;
   double MinLots=MarketInfo(Symbol(),MODE_MINLOT);
   double MaxLots=MarketInfo(Symbol(),MODE_MAXLOT);
   if(lots<MinLots)lots=MinLots;
   if(lots>MaxLots)lots=MaxLots;
   if(Risk<=0)lots=Lot;
   return(lots);
  }
//+------------------------------------------------------------------+
//|  Функция нормализации объема сделки                              |
//+------------------------------------------------------------------+
double NormalizeLots(double lots,string l_Symbol)
  {
   double result=0;
   double minLot=SymbolInfoDouble(l_Symbol,SYMBOL_VOLUME_MIN);
   double maxLot=SymbolInfoDouble(l_Symbol,SYMBOL_VOLUME_MAX);
   double stepLot=SymbolInfoDouble(l_Symbol,SYMBOL_VOLUME_STEP);
   if(lots>0)
     {
      lots=MathMax(minLot,lots);
      lots=minLot+NormalizeDouble((lots-minLot)/stepLot,0)*stepLot;
      result=MathMin(maxLot,lots);
     }
   else
      result=minLot;
   return (NormalizeDouble(result,2));
  }
//+------------------------------------------------------------------+
//| Функция отправки приказов без реквотов                           |
//+------------------------------------------------------------------+
int AntiRequoteOrderSend(string symbol,int cmd,double volume,double pric,int slippage,double stoploss,double takeprofit,string comment="",int magic=0,datetime expiration=0,color arrow_color=CLR_NONE)
  {
   ticket=0;
   int cnt=0;
   while(true)
     {
      if(cnt>=MaxAttempts) {Print("order not opened after ",MaxAttempts," attempts"); break;}
      cnt++;
      ticket=OrderSend(symbol,cmd,volume,pric,slippage,stoploss,takeprofit,comment,magic,expiration,arrow_color);
      if(ticket>0) break;
      Sleep(Pause*1000);
     }
   return(ticket);
  }
//+------------------------------------------------------------------+
//|   Количество ордеров                                             |
//+------------------------------------------------------------------+
void CountOrders(int &l_CountBuy,int &l_CountSell,int l_Magic)
  {
   l_CountBuy=l_CountSell=0;
   for(int i=0; i<OrdersTotal(); i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==_Symbol && OrderMagicNumber()==l_Magic)
        {
         if(OrderType()==ORDER_TYPE_BUY)
            l_CountBuy++;
         if(OrderType()==ORDER_TYPE_SELL)
            l_CountSell++;
        }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double value_profit()
  {
   double ID=0;
   int OT=OrdersTotal();
   if(OT>0)
     {
      for(int i=OT-1; i>=0; i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(OrderMagicNumber()==Magic && OrderSymbol()==Symbol())
               ID+=OrderProfit()+OrderSwap()+OrderCommission();
           }
        }
     }
   return(ID);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLabel(string nm,string tx,color cl,int xd,int yd,int cr=0,int fs=9,string font="Tahoma")
  {
   if(ObjectFind(nm)<0) ObjectCreate(nm,OBJ_LABEL,0,0,0);
   ObjectSetText(nm,tx,fs,font,cl);
   ObjectSet(nm,OBJPROP_COLOR,cl);
   ObjectSet(nm,OBJPROP_XDISTANCE,xd);
   ObjectSet(nm,OBJPROP_YDISTANCE,yd);
   ObjectSet(nm,OBJPROP_CORNER,cr);
   ObjectSet(nm,OBJPROP_FONTSIZE,fs);
   ObjectSet(nm,OBJPROP_BACK,false);
   ObjectSet(nm,OBJPROP_SELECTABLE,false);
   ObjectSet(nm,OBJPROP_READONLY,false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double TotalProfit()
  {
     {
      double OProfit=0;
      for(int i=0; i<OrdersHistoryTotal(); i++)
        {
         if(!(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))) break;
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
            if(OrderCloseTime()>=iTime(Symbol(),PERIOD_MN1,1200))OProfit+=OrderProfit();
        }
      return (OProfit);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Profit(int Bar)
  {
   double OProfit=0;
   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(!(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
         if(OrderCloseTime()>=iTime(Symbol(),PERIOD_D1,Bar) && OrderCloseTime()<iTime(Symbol(),PERIOD_D1,Bar)+86400) OProfit+=OrderProfit();
     }
   return (OProfit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitMons(int Bar)
  {
   double OProfit=0;
   for(int i=0; i<OrdersHistoryTotal(); i++)
     {
      if(!(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
         if(OrderCloseTime()>=iTime(Symbol(),PERIOD_MN1,Bar) && OrderCloseTime()<iTime(Symbol(),PERIOD_MN1,Bar)+2592000) OProfit+=OrderProfit();
     }
   return (OProfit);
  }
//+------------------------------------------------------------------+
//|  Функция ошибок                                                  |
//+------------------------------------------------------------------+
string Error(int error_code)
  {
   string error_string;
   switch(error_code)
     {
      case 0:
         error_string="no error returned.";                                                                  break;
      case 1:
         error_string="no error returned, but the result is unknown.";                                       break;
      case 2:
         error_string="common error.";                                                                       break;
      case 3:
         error_string="invalid trade parameters.";                                                           break;
      case 4:
         error_string="trade server is busy.";                                                               break;
      case 5:
         error_string="old version of the client terminal.";                                                 break;
      case 6:
         error_string="no connection with trade server.";                                                    break;
      case 7:
         error_string="not enough rights.";                                                                  break;
      case 8:
         error_string="too frequent requests.";                                                              break;
      case 9:
         error_string="malfunctional trade operation.";                                                      break;
      case 64:
         error_string="account disabled.";                                                                   break;
      case 65:
         error_string="invalid account.";                                                                    break;
      case 128:
         error_string="trade timeout.";                                                                      break;
      case 129:
         error_string="invalid price.";                                                                      break;
      case 130:
         error_string="invalid stops.";                                                                      break;
      case 131:
         error_string="invalid trade volume.";                                                               break;
      case 132:
         error_string="market is closed.";                                                                   break;
      case 133:
         error_string="trade is disabled.";                                                                  break;
      case 134:
         error_string="not enough money.";                                                                   break;
      case 135:
         error_string="price changed.";                                                                      break;
      case 136:
         error_string="off quotes.";                                                                         break;
      case 137:
         error_string="broker is busy.";                                                                     break;
      case 138:
         error_string="requote.";                                                                            break;
      case 139:
         error_string="order is locked.";                                                                    break;
      case 140:
         error_string="long positions only allowed.";                                                        break;
      case 141:
         error_string="too many requests.";                                                                  break;
      case 145:
         error_string="modification denied because an order is too close to market.";                        break;
      case 146:
         error_string="trade context is busy.";                                                              break;
      case 147:
         error_string="expirations are denied by broker.";                                                   break;
      case 148:
         error_string="the amount of opened and pending orders has reached the limit set by a broker.";      break;
      case 4000:
         error_string="no error.";                                                                           break;
      case 4001:
         error_string="wrong function pointer.";                                                             break;
      case 4002:
         error_string="array index is out of range.";                                                        break;
      case 4003:
         error_string="no memory for function call stack.";                                                  break;
      case 4004:
         error_string="recursive stack overflow.";                                                           break;
      case 4005:
         error_string="not enough stack for parameter.";                                                     break;
      case 4006:
         error_string="no memory for parameter string.";                                                     break;
      case 4007:
         error_string="no memory for temp string.";                                                          break;
      case 4008:
         error_string="not initialized string.";                                                             break;
      case 4009:
         error_string="not initialized string in an array.";                                                 break;
      case 4010:
         error_string="no memory for an array string.";                                                      break;
      case 4011:
         error_string="too long string.";                                                                    break;
      case 4012:
         error_string="remainder from zero divide.";                                                         break;
      case 4013:
         error_string="zero divide.";                                                                        break;
      case 4014:
         error_string="unknown command.";                                                                    break;
      case 4015:
         error_string="wrong jump.";                                                                         break;
      case 4016:
         error_string="not initialized array.";                                                              break;
      case 4017:
         error_string="DLL calls are not allowed.";                                                          break;
      case 4018:
         error_string="cannot load library.";                                                                break;
      case 4019:
         error_string="cannot call function.";                                                               break;
      case 4020:
         error_string="EA function calls are not allowed.";                                                  break;
      case 4021:
         error_string="not enough memory for a string returned from a function.";                            break;
      case 4022:
         error_string="system is busy.";                                                                     break;
      case 4050:
         error_string="invalid function parameters count.";                                                  break;
      case 4051:
         error_string="invalid function parameter value.";                                                   break;
      case 4052:
         error_string="string function internal error.";                                                     break;
      case 4053:
         error_string="some array error.";                                                                   break;
      case 4054:
         error_string="incorrect series array using.";                                                       break;
      case 4055:
         error_string="custom indicator error.";                                                             break;
      case 4056:
         error_string="arrays are incompatible.";                                                            break;
      case 4057:
         error_string="global variables processing error.";                                                  break;
      case 4058:
         error_string="global variable not found.";                                                          break;
      case 4059:
         error_string="function is not allowed in testing mode.";                                            break;
      case 4060:
         error_string="function is not confirmed.";                                                          break;
      case 4061:
         error_string="mail sending error.";                                                                 break;
      case 4062:
         error_string="string parameter expected.";                                                          break;
      case 4063:
         error_string="integer parameter expected.";                                                         break;
      case 4064:
         error_string="double parameter expected.";                                                          break;
      case 4065:
         error_string="array as parameter expected.";                                                        break;
      case 4066:
         error_string="requested history data in updating state.";                                           break;
      case 4067:
         error_string="some error in trade operation execution.";                                            break;
      case 4099:
         error_string="end of a file.";                                                                      break;
      case 4100:
         error_string="some file error.";                                                                    break;
      case 4101:
         error_string="wrong file name.";                                                                    break;
      case 4102:
         error_string="too many opened files.";                                                              break;
      case 4103:
         error_string="cannot open file.";                                                                   break;
      case 4104:
         error_string="incompatible access to a file.";                                                      break;
      case 4105:
         error_string="no order selected.";                                                                  break;
      case 4106:
         error_string="unknown symbol.";                                                                     break;
      case 4107:
         error_string="invalid price param.";                                                                break;
      case 4108:
         error_string="invalid ticket.";                                                                     break;
      case 4109:
         error_string="trade is not allowed.";                                                               break;
      case 4110:
         error_string="longs are not allowed.";                                                              break;
      case 4111:
         error_string="shorts are not allowed.";                                                             break;
      case 4200:
         error_string="object already exists.";                                                              break;
      case 4201:
         error_string="unknown object property.";                                                            break;
      case 4202:
         error_string="object does not exist.";                                                              break;
      case 4203:
         error_string="unknown object type.";                                                                break;
      case 4204:
         error_string="no object name.";                                                                     break;
      case 4205:
         error_string="object coordinates error.";                                                           break;
      case 4206:
         error_string="no specified subwindow.";                                                             break;
      case 4207:
         error_string="ERR_SOME_OBJECT_ERROR.";                                                              break;
      default:
         error_string="error is not known.";
     }
   return(error_string);
  }
//+------------------------------------------------------------------+
//|   Виртуальный трейлинг стоп                                      |
//+------------------------------------------------------------------+
void lTral_TrailingStop(uint l_trailing,//Трейлинг, пунктов
                        int l_trailing_step,//Шаг трейлинга, пунктов
                        string l_Symbol=NULL,//Инструмент, NULL для всех
                        int l_Magic=0,//Магик, 0 для всех
                        bool l_vision=false,//Визуализация стоп-лосса
                        color l_vision_color=clrRed //Цвет визуализации трейлинг-стопа
                        )
  {
   double l_OrderOpenPrice,l_Tral,l_Extremum;
   string l_OrderSymbol;
   if(l_trailing<=0)
      return;
   if(l_trailing_step<0)
      l_trailing_step=0;
   if(l_vision)
      for(uint i=0; i<(uint)ArraySize(l_orders); i++)
         if(!OrderSelect(l_orders[i],SELECT_BY_TICKET) || OrderCloseTime()>0)
           {
            lTral_DeleteOrderLine(i);
            i--;
           }
   for(int o=0; o<OrdersTotal(); o++)
      if(OrderSelect(o,SELECT_BY_POS,MODE_TRADES) && OrderProfit()>0)
         if((l_Symbol==NULL || OrderSymbol()==l_Symbol) && (l_Magic==0 || OrderMagicNumber()==l_Magic) && OrderCloseTime()==0)
           {
            l_OrderOpenPrice=OrderOpenPrice();
            l_OrderSymbol=OrderSymbol();
            int l_shift=iBarShift(OrderSymbol(),PERIOD_M1,OrderOpenTime(),false)-1;
            double l_point=SymbolInfoDouble(l_OrderSymbol,SYMBOL_POINT);
            if(l_shift<0)
               continue;
            switch(OrderType())
              {
               case OP_BUY:
                  l_Extremum=iHigh(l_OrderSymbol,PERIOD_M1,iHighest(l_OrderSymbol,PERIOD_M1,MODE_HIGH,(int)MathMax(l_shift,1),0));
                  l_Tral=l_Extremum-l_trailing*l_point;
                  if(l_Tral>=l_OrderOpenPrice+l_trailing_step*l_point)
                    {
                     if(OrderClosePrice()<=l_Tral)
                        if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrNONE))
                          {
                           o--;
                           break;
                          }
                     if(l_vision)
                        SetLabels(OrderTicket(),l_Tral,l_vision_color);
                    }
                  break;
               case OP_SELL:
                  l_Extremum=iLow(l_OrderSymbol,PERIOD_M1,iLowest(l_OrderSymbol,PERIOD_M1,MODE_LOW,(int)MathMax(l_shift,1),0));
                  l_Tral=l_Extremum+l_trailing*l_point;
                  if(l_Tral<=l_OrderOpenPrice-l_trailing_step*l_point)
                    {
                     if(OrderClosePrice()>=l_Tral)
                        if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0,clrNONE))
                          {
                           o--;
                           break;
                          }
                     if(l_vision)
                        SetLabels(OrderTicket(),l_Tral,l_vision_color);
                    }
                  break;
              }
           }
  }
//+------------------------------------------------------------------+
//| Удаление меток закрытого ордера                                  |
//+------------------------------------------------------------------+
void lTral_DeleteOrderLine(uint l_index)
  {
   uint ord=0;
   uint l_size=ArraySize(l_orders);
   if(l_index>=l_size || l_index<ord)
      return;
   string l_line="lTral_Line_"+IntegerToString(l_orders[l_index]);
   string l_label="lTral_Label_"+IntegerToString(l_orders[l_index]);
   if(ObjectFind(l_line)>=0)
      ObjectDelete(l_line);
   if(ObjectFind(l_label)>=0)
      ObjectDelete(l_label);
   for(uint i=l_index; i<(l_size-1); i++)
      l_orders[i]=l_orders[i+1];
   ArrayResize(l_orders,l_size-1);
   return;
  }
//+------------------------------------------------------------------+
//| Удаление всех меток (необходим запуск из OnDeinit)               |
//+------------------------------------------------------------------+
void lTral_Deinit()
  {
   for(int i=0;i<ObjectsTotal();i++)
     {
      string name=ObjectName(i);
      if(StringFind(name,"lTral",0)>=0)
        {
         ObjectDelete(name);
         i--;
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Установка/смещение меток                                         |
//+------------------------------------------------------------------+
void SetLabels(uint l_ticket,double l_price,color l_vision_color)
  {
   if(!OrderSelect(l_ticket,SELECT_BY_TICKET) || OrderCloseTime()>0 || (OrderType()!=OP_BUY && OrderType()!=OP_SELL) || OrderSymbol()!=_Symbol)
      return;
   long Chart=ChartID();
   string l_line="lTral_Line_"+IntegerToString(l_ticket);
   string l_label="lTral_Label_"+IntegerToString(l_ticket);
   if(ObjectFind(Chart,l_line)<0)
     {
      ObjectCreate(Chart,l_line,OBJ_HLINE,0,0,l_price);
      ObjectSetInteger(Chart,l_line,OBJPROP_COLOR,l_vision_color);
      ObjectSetInteger(Chart,l_line,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(Chart,l_line,OBJPROP_SELECTED,false);
      ObjectSetInteger(Chart,l_line,OBJPROP_HIDDEN,true);
      uint l_size=ArraySize(l_orders);
      ArrayResize(l_orders,l_size+1);
      l_orders[l_size]=l_ticket;
     }
   else
      ObjectSetDouble(Chart,l_line,OBJPROP_PRICE,l_price);
   datetime l_time=Time[(int)(ChartGetInteger(Chart,CHART_FIRST_VISIBLE_BAR)-2)];
   if(ObjectFind(l_label)>=0)
     {
      ObjectCreate(Chart,l_label,OBJ_LABEL,0,l_time,l_price);
      ObjectSetInteger(Chart,l_label,OBJPROP_COLOR,l_vision_color);
      ObjectSetString(Chart,l_label,OBJPROP_TEXT,IntegerToString(l_ticket));
      ObjectSetInteger(Chart,l_label,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
      ObjectSetInteger(Chart,l_label,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(Chart,l_label,OBJPROP_SELECTED,false);
      ObjectSetInteger(Chart,l_label,OBJPROP_HIDDEN,true);
     }
   else
     {
      ObjectSetDouble(Chart,l_label,OBJPROP_PRICE,l_price);
      ObjectSetInteger(Chart,l_label,OBJPROP_TIME,l_time);
     }
  }
//+------------------------------------------------------------------+
