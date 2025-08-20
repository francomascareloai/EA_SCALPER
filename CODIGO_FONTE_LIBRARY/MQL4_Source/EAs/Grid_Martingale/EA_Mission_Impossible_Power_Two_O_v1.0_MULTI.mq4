//Mission Impossible Power Two : https://www.mql5.com/en/market/product/56691 
#property copyright "Stiopa"
#property link      "https://www.mql5.com/en/users/stiopa"
#property version   "1.00"
#property strict
input string          comment="Mission Impossible Power Two Open Version";//Comment
input int             slippage=1;//Slippage
input int             MagicNumber=1;//Magic Number
input ushort          SL=400;//Stop Loss
input ushort          TP1=15;//Take Profit (first position)
extern ushort         TP=7;//Take Profit (next position)
extern double         Lots=0.01;//Lots
extern double         MaxLots=2;//Max Lots
input double          power=13.0;//Power
extern ushort         PipsStep=21;//Max PipsStep for grid
extern int            MaxTrades=16;//MaxTrades
int Tick;
double gpoint_320;
string Error;
//+------------------------------------------------------------------+
//| For Broker 4 or 5 digits                                                                 |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Digits==3 ||Digits==5)
      gpoint_320=Point*10;
   else
      gpoint_320=Point;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Main function                                                                 |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Bars<100 || !IsConnected()|| IsTradeAllowed()==false)
      return;
//-----------------------------------------------
   Buy_main("buy");
   Sell_main("sell");
  }
//+------------------------------------------------------------------+
//|     Buy                                                             |
//+------------------------------------------------------------------+
void Buy_main(string ot_456)
  {
   if(Volume[0]>1)
      return;
   double lots;
   if(OrderAllowed())
      if((cou_tra_45(ot_456)==0 && Signal_1()==1)||(cou_tra_45(ot_456)>0 && nx_77(ot_456)))
        {
         lots=CheckVolumeValue(ne_234(ot_456));
         if(CheckMoney(lots,OP_BUY))
           {
            Tick=0;
            while(Tick<1)
              {
               while(IsTradeContextBusy())
                  Sleep(100);
               RefreshRates();
               Tick=OrderSend(Symbol(),OP_BUY,lots,nor_1(Ask),slippage,0,0,comment,MagicNumber,0,Blue);
               if(Tick<1)
                 {
                  Print("Error: ",GetLastError());
                  Sleep(1000);
                  RefreshRates();
                 }
               else
                 {
                  modify(ot_456);
                 }
              }
           }
        }
  }
//+------------------------------------------------------------------+
//|     Sell                                                             |
//+------------------------------------------------------------------+
void Sell_main(string ot_456)
  {
   if(Volume[0]>1)
      return;
   double lots;
   if(OrderAllowed())
      if((cou_tra_45(ot_456)==0 && Signal_1()==2)||(cou_tra_45(ot_456)>0 && nx_77(ot_456)))
        {
         lots=CheckVolumeValue(ne_234(ot_456));
         if(CheckMoney(lots,OP_SELL))
           {
            Tick=0;
            while(Tick<1)
              {
               while(IsTradeContextBusy())
                  Sleep(100);
               RefreshRates();
               Tick=OrderSend(Symbol(),OP_SELL,lots,nor_1(Bid),slippage,0,0,comment,MagicNumber,0,Red);
               if(Tick<1)
                 {
                  Print("Error: ",GetLastError());
                  Sleep(1000);
                  RefreshRates();
                 }
               else
                 {
                  modify(ot_456);
                 }
              }
           }
        }
  }
//+------------------------------------------------------------------+
//|  Modify Take Profit and Stop Loss                                                                |
//+------------------------------------------------------------------+
void modify(string ot_456)
  {
   int order=cou_tra_45(ot_456);
   int tr_45;
   double TP_all,SL_all,price;
   double avp_2=0;
   bool d;
   if(order>1){
      avp_2=avp_next(ot_456);
      }
   for(tr_45=OrdersTotal()-1; tr_45>=0; tr_45--)
     {
      if(!OrderSelect(tr_45,SELECT_BY_POS,MODE_TRADES))
         Print("Error in OrderSelect Takeprofit==true. Error code=",GetLastError());
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(ot_456=="buy")
           {
            if(OrderType()==OP_BUY)
              {
               if(order>1)
                 {
                  TP_all=nor_1(avp_2+(TP*gpoint_320));
                  SL_all=nor_1(avp_2-(SL*gpoint_320));
                  price=avp_2;
                 }
               else
                 {
                  TP_all=nor_1(OrderOpenPrice()+(TP1*gpoint_320));
                  SL_all=nor_1(OrderOpenPrice()-(SL*gpoint_320));
                  price=OrderOpenPrice();
                 }
               if(check_sl_tp(OP_BUY,SL_all,TP_all))
                  if(OrderTakeProfit()!=TP_all)
                     d=OrderModify(OrderTicket(),nor_1(price),SL_all,TP_all,0,Yellow);
               if(d)
                  Print("All TP for buy successfully");
               else
                  Print("Error in OrderModify buy Average + TP. Error code=",GetLastError());
              }
           }
         if(ot_456=="sell")
           {
            if(OrderType()==OP_SELL)
              {
               if(order>1)
                 {
                  TP_all=nor_1(avp_2-(TP*gpoint_320));
                  SL_all=nor_1(avp_2+(SL*gpoint_320));
                 }
               else
                 {
                  TP_all=nor_1(OrderOpenPrice()-(TP1*gpoint_320));
                  SL_all=nor_1(OrderOpenPrice()+(SL*gpoint_320));
                  price=OrderOpenPrice();
                 }
               if(check_sl_tp(OP_SELL,SL_all,TP_all))
                  if(OrderTakeProfit()!=TP_all)
                     d=OrderModify(OrderTicket(),nor_1(price),SL_all,TP_all,0,Yellow);
               if(d)
                  Print("All TP for sell successfully");
               else
                  Print("Error in OrderModify sell Average - TP. Error code=",GetLastError());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Average Order Price                                                                 |
//+------------------------------------------------------------------+
double avp_next(string ot_456)
  {
   double
   Count=0,
   avp_2=0;
   int tr_45;
   for(tr_45=OrdersTotal()-1; tr_45>=0; tr_45--)
     {
      if(OrderSelect(tr_45,SELECT_BY_POS,MODE_TRADES)==False)
         Print("Error in OrderSelect avp_2. Error code=",GetLastError());
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(ot_456=="buy")
           {
            if(OrderType()==OP_BUY)
              {
               avp_2=avp_2+OrderOpenPrice()*OrderLots();
               Count=Count+OrderLots();
              }
           }
         if(ot_456=="sell")
           {
            if(OrderType()==OP_SELL)
              {
               avp_2=avp_2+OrderOpenPrice()*OrderLots();
               Count=Count+OrderLots();
              }
           }
        }
     }
   if(avp_2>0 && Count>0)
      avp_2=NormalizeDouble(avp_2/Count,Digits);
   return(avp_2);
  }
//+------------------------------------------------------------------+
//| Digits                                                                 |
//+------------------------------------------------------------------+
int Lots_Digits()
  {
   double Lotstep=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int    LotsDigits=(int)MathCeil(MathAbs(MathLog(Lotstep)/MathLog(10)));
   return(LotsDigits);
  }
//+------------------------------------------------------------------+
//|  Normalize                                                                |
//+------------------------------------------------------------------+
double nor_1(double ad_0)
  {
   return (NormalizeDouble(ad_0, Digits));
  }
//+------------------------------------------------------------------+
//|    Signal                                                               |
//+------------------------------------------------------------------+
int Signal_1()
  {
   double
   Close_1=iClose(Symbol(),0,1),
   Open_1=iOpen(Symbol(),0,1);
   if(Close_1<Open_1)
      return(2);
   if(Close_1>Open_1)
      return(1);
   return(0);
  }
//+------------------------------------------------------------------+
//| Next positions                                                                |
//+------------------------------------------------------------------+
bool nx_77(string ot_456)
  {
   if(ot_456=="buy")
     {
      if(cou_tra_45(ot_456)>=MaxTrades)
         return false;
      if(control_price(ot_456)>=PipsStep *gpoint_320)
        {
         return(true);
        }
     }
   if(ot_456=="sell")
     {
      if(cou_tra_45(ot_456)>=MaxTrades)
         return false;
      if(control_price(ot_456)>=PipsStep*gpoint_320)
        {
         return(true);
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|  Control price                                                            |
//+------------------------------------------------------------------+
double control_price(string ot_456)
  {
   double a_0=0;
   if(ot_456=="buy")
     {
      a_0=nor_1(select(ot_456,"price")-Ask);
     }
   if(ot_456=="sell")
     {
      a_0=nor_1(Bid-select(ot_456,"price"));
     }
   return(a_0);
  }
//+------------------------------------------------------------------+
//|    Lots for first and next position                                                              |
//+------------------------------------------------------------------+
double ne_234(string ot_456)
  {
   double lo_45=0;
   if(ot_456=="buy")
     {
      double li_0=MathAbs(multiplier(ot_456)*power);
      if(cou_tra_45(ot_456)>0)
         lo_45=(double)DoubleToStr(li_0+Lots,Lots_Digits());
      else
         lo_45=NormalizeDouble(Lots,Lots_Digits());
     }
   if(ot_456=="sell")
     {
      double li_0=MathAbs(multiplier(ot_456)*power);
      if(cou_tra_45(ot_456)>0)
         lo_45=(double)DoubleToStr(li_0+Lots,Lots_Digits());
      else
         lo_45=NormalizeDouble(Lots,Lots_Digits());
     }
   if(lo_45>MaxLots)
      lo_45=MaxLots;
   return(lo_45);
  }
//+------------------------------------------------------------------+
//|  Multiplier                                                          |
//+------------------------------------------------------------------+
double multiplier(string ot_456)
  {
   double avp_2=0,
          Count=0;
   int tr_45;
   for(tr_45=OrdersTotal()-1; tr_45>=0; tr_45--)
     {
      if(OrderSelect(tr_45,SELECT_BY_POS,MODE_TRADES)==False)
         Print("Error in OrderSelect avp_2. Error code=",GetLastError());
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(ot_456=="buy")
           {
            if(OrderType()==OP_BUY)
              {
               avp_2=avp_2+OrderOpenPrice()*OrderProfit();
              }
           }
         if(ot_456=="sell")
           {
            if(OrderType()==OP_SELL)
              {
               avp_2=avp_2+OrderOpenPrice()*OrderProfit();
              }
           }
        }
     }
   avp_2=avp_2/Bid;
   return(avp_2*0.0001);
  }
//+------------------------------------------------------------------+
//|  Check Stop Loss and Take Profit                                                              |
//+------------------------------------------------------------------+
bool check_sl_tp(ENUM_ORDER_TYPE type,double sl,double tp)
  {
   int stops_level=(int)SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL);
   bool SL_check=false,TP_check=false;
   switch(type)
     {
      case  ORDER_TYPE_BUY:
        {
         SL_check=((Bid-sl>stops_level*gpoint_320) || sl==0);
         TP_check=((tp-Bid>stops_level*gpoint_320) || tp==0);
         return(SL_check && TP_check);
        }
      case  ORDER_TYPE_SELL:
        {
         SL_check=((sl-Ask>stops_level*gpoint_320) || sl==0);
         TP_check=((Ask-tp>stops_level*gpoint_320)|| tp==0);
         return(TP_check && SL_check);
        }
      break;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Check Money                                                                 |
//+--------------------------------------------------------------+
bool CheckMoney(double lots,int type)
  {
   string text;
   double margin=AccountFreeMarginCheck(Symbol(),type,lots);
   if(margin<0)
     {
      switch(type)
        {
         case 0:
            text="Buy";
            break;
         case 1:
            text="Sell";
            break;
         default:
            text="Order";
        }
      Print("Not enough money for ",text," ",lots," Error code=",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|  Check Volume Value                                                                |
//+------------------------------------------------------------------+
double CheckVolumeValue(double check)
  {
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(check<min_volume)
      return(min_volume);
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(check>max_volume)
      return(max_volume);
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   int ratio=(int)MathRound(check/volume_step);
   if(MathAbs(ratio*volume_step-check)>0.0000001)
      return(ratio*volume_step);
   return(check);
  }
//+------------------------------------------------------------------+
//| Order Allowed                                                                 |
//+------------------------------------------------------------------+
bool OrderAllowed()
  {
   int max_orders=(int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   if(max_orders==0)
      return(true);
   int orders_t=OrdersTotal();
   return(orders_t<max_orders);
  }
//+------------------------------------------------------------------+
//|  Count orders                                                                |
//+------------------------------------------------------------------+
int cou_tra_45(string ot_456)
  {
   int count=0,tr_45,oldticketnumber=0;
   for(tr_45=OrdersTotal()-1; tr_45>=0; tr_45--)
     {
      if(OrderSelect(tr_45,SELECT_BY_POS,MODE_TRADES)==False)
         Print("Error in OrderSellect cou_tra_45 . Error code=",GetLastError());
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(ot_456=="buy")
           {
            if(OrderType()==OP_BUY)
              {
               count++;
              }
           }
         if(ot_456=="sell")
           {
            if(OrderType()==OP_SELL)
              {
               count++;
              }
           }
        }
     }
   return(count);
  }
//+------------------------------------------------------------------+
//| Choose what you need                                                                 |
//+------------------------------------------------------------------+
double select(string ot_456,string a_0)
  {
   RefreshRates();
   double open=0;
   int tr_45,oldticketnumber=0,n=0;
   for(tr_45=OrdersTotal()-1; tr_45>=0; tr_45--)
     {
      if(OrderSelect(tr_45,SELECT_BY_POS,MODE_TRADES)==False)
         Print("Error in OrderSelect select(). Error code=",GetLastError());
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MagicNumber)
         continue;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber)
        {
         if(ot_456=="buy")
           {
            if(OrderType()==OP_BUY)
              {
               if(OrderTicket()>oldticketnumber)
                 {
                  open=OrderOpenPrice();
                  oldticketnumber=OrderTicket();
                 }
              }
           }
         if(ot_456=="sell")
           {
            if(OrderType()==OP_SELL)
              {
               if(OrderTicket()>oldticketnumber)
                 {
                  open=OrderOpenPrice();
                  oldticketnumber=OrderTicket();
                 }
              }
           }
        }
     }
   if(a_0=="price")
      return(open);
   return(0);
  }
//+------------------------------------------------------------------+
