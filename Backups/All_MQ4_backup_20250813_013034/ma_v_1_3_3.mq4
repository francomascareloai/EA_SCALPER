//+-------------------------------------------------------------------------------------------------------------------------------------------------+
//|                                                                                                                                   MA_v1.3.3.mq4 |
//+-------------------------------------------------------------------------------------------------------------------------------------------------+

/*------------------------------------------------------------------------------------------------------------------------------- specification ---//

//-------------------------------------------------------------------------------------------------------------------------------------------------*/

//=================================================================================================================================================//
enum ENUM_TF { current=0,M1=1,M5=5,M15=15,M30=30,H1=60,H4=240,D1=1440,W1=10080,MN1=43200 };
//========================================================================================================================== external variables ===//
extern             string _0_="___ Режим работы ___";
extern                int TradeMode=1;
extern             string _1_="___ Настройка Fast MA ___";
extern                int Period_=13,
Shift_=0;
extern     ENUM_MA_METHOD Method_MA_=MODE_SMA;
extern ENUM_APPLIED_PRICE Apply_to_=PRICE_CLOSE;
extern             string _2_="___ Настройка Slow MA ___";
extern                int Period__=21,
Shift__=0;
extern     ENUM_MA_METHOD Method_MA__=MODE_SMA;
extern ENUM_APPLIED_PRICE Apply_to__=PRICE_CLOSE;
extern             string _3_="___ Начальный лот ___",
_3_1_="___ true - постоянный, false - от баланса ___";
extern               bool LotConst_or_not=true;
extern             double Lot=0.1,
RiskPercent=1.0;
extern             string _3_2_="___ Увеличение лота ___";
extern             double FirstLotMultiplicator=1.65;
extern             double First_LotSize=1.0;
extern             double First_LotSize_TakeProfit=650.0;
extern             double First_MaxLotSize=2.5;
extern             string _4_="___ Настройка расстояние между Fast MA и Slow MA ___";
extern               bool Use_Distance=false;
extern             double Distance=100.0;
extern             string _5_="___ Прибыль в пунктах - TP ___";
extern               bool Use_TakeProfit=true;
extern             double TakeProfit=500.0;
extern             string _6_="___ Способ усреднения ___";
extern                int Varyant=1;
extern             string _7_="___ Стоп в пунктах - SL ___";
extern               bool Use_StopLoss=true;
extern             double StopLoss=250.0;
extern             string _8_="___ Расстояние между ордерами (Step Up) ___";
extern               bool Use_Step_Up=true;
extern             double Step_Up=100.0;
extern             string _8_1_="___ Trailing stop ___";
extern               bool Use_TrailingStop=true;
extern             double TrailingStop=250.0;
extern             string _9_="___ Расстояние между ордерами (Step Down) ___";
extern               bool Use_Step_Down=true;
extern             double Step_Down=150.0;
extern             string _10_="___ Идентификатор ордеров советника ___";
extern                int Magic=135;
extern             string _11_="___ Логотип и вывод данных (true - включить или false - отключить) ___";
extern               bool ShowTableOnTesting=false;
extern             string _12_="___ Рабочий тайм-фрейм эксперта, если current - тайм-фрейм текущего графика ___";
extern            ENUM_TF Tf=current;
extern             string _13_="___ Trade time ___";
extern               bool Use_trade_time=false;
extern             string Open_trade="08:00:00";
extern             string Close_trade="21:30:00";
extern             string _14_="___ Turn ___";
extern               bool Use_Turn=true;
extern             double Turn=250.0;
extern             double LotMultiplicator=1.65;
extern             double Turn_TakeProfit=500.0;
extern             double Turn_LotSize=1.0;
extern             double Turn_LotSize_TakeProfit=650.0;
extern             double Turn_MaxLotSize=2.5;
//============================================================================================================================ global variables ===//
double TickSize,TickValue,Spread,StopLevel,MinLot,MaxLot,LotStep,Pnt,
TP;
int order_type,T,
sumBO,sumSO,sumBS,sumSS,sumBL,sumSL,sumO,sumS,sumL,_sumBO,_sumSO,_sumBS,_sumSS,_sumBL,_sumSL,_sumO,_sumS,_sumL,
NumbUp,NumbDn,Numb,
PrevFirstTicket;
bool Ans,_Ans,Activate,FatalError,FreeMarginAlert,IsTester,IsVisual;
//=================================================================================================== The initialization function of the expert ===//
int init()
  {
   Activate=false; FatalError=false;
   if(IsTesting() || IsOptimization() || IsVisualMode()) IsTester=true; else IsTester=false;
   if(!IsOptimization()) IsVisual=true; else IsVisual=false;
   Pnt=Point;

   GetMarketInfo();
   HistoryCheck();

   if(IsVisual && ShowTableOnTesting) Info();

   Activate=true;
   return(0);
  }
//================================================================================================= The deinitialization function of the expert ===//
int deinit()
  {
   Comment("");

   if(!IsTester)
     {
      if(IsVisual && ShowTableOnTesting) Obj_Del();

      switch(UninitializeReason())
        {
         case 0: if(Use_Turn) GVD("Numb"); else { GVD("NumbUp"); GVD("NumbDn"); GVD("PrevFirstTicket"); }  break;
         case 1: if(Use_Turn) GVD("Numb"); else { GVD("NumbUp"); GVD("NumbDn"); GVD("PrevFirstTicket"); }  break;
        } // switch
     }

   return(0);
  }
//============================================================================================================= The main function of the expert ===//
int start()
  {
   if(!Activate || FatalError) return(0);
   if(!IsTester) GetMarketInfo();
   if(!HistoryCheck()) return(0);

   SumOrders();

   if(!IsTester) { if(Use_Turn) Numb=(int)GVG("Numb"); else { NumbUp=(int)GVG("NumbUp");  NumbDn=(int)GVG("NumbDn");  PrevFirstTicket=(int)GVG("PrevFirstTicket"); } }

   Trail();
   if(Use_Turn) Trade2(); else Trade();

   if(!IsTester) { if(Use_Turn) GVS("Numb",(double)Numb); else { GVS("NumbUp",(double)NumbUp);  GVS("NumbDn",(double)NumbDn);  GVS("PrevFirstTicket",(double)PrevFirstTicket); } }

   if(IsVisual && ShowTableOnTesting) Info();

   return(0);
  }
//=================================================================================================================================================//
void Trade()
  {

   double ma_fast=ma(Period_,Shift_,Method_MA_,Apply_to_,0),ma_slow=ma(Period__,Shift__,Method_MA__,Apply_to__,0),lot=0.0;

   if(sumBO==0 && (TradeMode==1 || (TradeMode==2 && sumSO==0)) && 
      ma_fast>ma_slow && (!Use_Distance || (Use_Distance && ND(ma_fast-ma_slow)>Distance*Pnt)))
     {
      if(!TradeTime()) return;
      lot=_GetLot();
      if(First_MaxLotSize>0.0 && NL(lot)>=First_MaxLotSize) lot=GetLot();
      if(First_LotSize>0.0 && NL(lot)>=First_LotSize) TP=First_LotSize_TakeProfit; else TP=TakeProfit;
      if(sumSO>0 && !ClosePos(OP_SELL)) return;
      if(MO(OP_BUY,lot,GetComment())==-1) return;
      if(!ModifyByTicket(T)) return;
      NumbUp=0; NumbDn=0; PrevFirstTicket=T;
     }
   else

      if(sumSO==0 && (TradeMode==1 || (TradeMode==2 && sumBO==0)) && 
         ma_fast<ma_slow && (!Use_Distance || (Use_Distance && ND(ma_slow-ma_fast)>Distance*Pnt)))
        {
         if(!TradeTime()) return;
         lot=_GetLot();
         if(First_MaxLotSize>0.0 && NL(lot)>=First_MaxLotSize) lot=GetLot();
         if(First_LotSize>0.0 && NL(lot)>=First_LotSize) TP=First_LotSize_TakeProfit; else TP=TakeProfit;
         if(sumBO>0 && !ClosePos(OP_BUY)) return;
         if(MO(OP_SELL,lot,GetComment())==-1) return;
         if(!ModifyByTicket(T)) return;
         NumbUp=0; NumbDn=0; PrevFirstTicket=T;
        }
   else

   if(sumBO>0)
     {
      lot=GetOrdDouble("lot",PrevFirstTicket);
      if(First_LotSize>0.0 && NL(lot)>=First_LotSize) TP=First_LotSize_TakeProfit; else TP=TakeProfit;

      if(Use_Step_Up && ND(Ask-ExtrLevOrd("BuyMax"))>=Step_Up*Pnt)
        {
         if(MO(OP_BUY,GetLot(),GetComment(NumbUp+1))==-1) return;
         if(!ModifyByTicket(T)) return;
         NumbUp++;
        }
      else
      if(Use_Step_Down && ND(ExtrLevOrd("BuyMin")-Ask)>=Step_Down*Pnt)
        {
         if(MO(OP_BUY,GetLot(),GetComment(NumbDn-1))==-1) return;
         if(Use_StopLoss) { if(!ModifyByTicket(T)) return; }
         if(Use_TakeProfit) { if(!Modify_TP(Get_TP(TP,OP_BUY),OP_BUY)) return; }
         NumbDn--;
        }
     }
   else

   if(sumSO>0)
     {
      lot=GetOrdDouble("lot",PrevFirstTicket);
      if(First_LotSize>0.0 && NL(lot)>=First_LotSize) TP=First_LotSize_TakeProfit; else TP=TakeProfit;

      if(Use_Step_Up && ND(ExtrLevOrd("SellMin")-Bid)>=Step_Up*Pnt)
        {
         if(MO(OP_SELL,GetLot(),GetComment(NumbUp+1))==-1) return;
         if(!ModifyByTicket(T)) return;
         NumbUp++;
        }
      else
      if(Use_Step_Down && ND(Bid-ExtrLevOrd("SellMax"))>=Step_Down*Pnt)
        {
         if(MO(OP_SELL,GetLot(),GetComment(NumbDn-1))==-1) return;
         if(Use_StopLoss) { if(!ModifyByTicket(T)) return; }
         if(Use_TakeProfit) { if(!Modify_TP(Get_TP(TP,OP_SELL),OP_SELL)) return; }
         NumbDn--;
        }
     }

  }
//=================================================================================================================================================//
void Trade2()
  {

   double lot=0.0,tp=0.0,lev_inst=0.0,ma_fast=ma(Period_,Shift_,Method_MA_,Apply_to_,0),ma_slow=ma(Period__,Shift__,Method_MA__,Apply_to__,0);

   if(sumO==0 && ma_fast>ma_slow && (!Use_Distance || (Use_Distance && ND(ma_fast-ma_slow)>Distance*Pnt)))
     {
      if(sumS>0 && !DelOrd()) return;
      if(!TradeTime()) return;
      if(sumSO>0 && !ClosePos(OP_SELL)) return;
      if(MO(OP_BUY,GetLot(),GetComment())==-1) return;
      if(!ModifyByTicket(T)) { Numb=1; return; }
      lev_inst=GetOrdDouble("sl",T);
      lot=GetOrdDouble("lot",T);
      if(Turn_MaxLotSize>0.0 && NL(LotMultiplicator*lot)>=Turn_MaxLotSize) { Numb=1; return; }
      if(Turn_LotSize>0.0 && NL(LotMultiplicator*lot)>=Turn_LotSize) tp=Turn_LotSize_TakeProfit; else tp=Turn_TakeProfit;
      if(PO(OP_SELLSTOP,lev_inst,lev_inst+Turn*Pnt,lev_inst-tp*Pnt,LotMultiplicator*lot,GetComment(1))==-1) { Numb=1; return; }
      Numb=1;
     }
   else

   if(sumO==0 && ma_fast<ma_slow && (!Use_Distance || (Use_Distance && ND(ma_slow-ma_fast)>Distance*Pnt)))
     {
      if(sumS>0 && !DelOrd()) return;
      if(!TradeTime()) return;
      if(sumBO>0 && !ClosePos(OP_BUY)) return;
      if(MO(OP_SELL,GetLot(),GetComment())==-1) return;
      if(!ModifyByTicket(T)) { Numb=1; return; }
      lev_inst=GetOrdDouble("sl",T);
      lot=GetOrdDouble("lot",T);
      if(Turn_MaxLotSize>0.0 && NL(LotMultiplicator*lot)>=Turn_MaxLotSize) { Numb=1; return; }
      if(Turn_LotSize>0.0 && NL(LotMultiplicator*lot)>=Turn_LotSize) tp=Turn_LotSize_TakeProfit; else tp=Turn_TakeProfit;
      if(PO(OP_BUYSTOP,lev_inst,lev_inst-Turn*Pnt,lev_inst+tp*Pnt,LotMultiplicator*lot,GetComment(1))==-1) { Numb=1; return; }
      Numb=1;
     }
   else

   if(sumBO>0 && sumSS==0)
     {
      T=GetTicket("market","last","trade");  if(T==-1) return;
      lev_inst=GetOrdDouble("sl",T);
      lot=GetOrdDouble("lot",T);
      if(lev_inst==0.0)
        {
         if(!ModifyByTicket(T)) return;
         lev_inst=GetOrdDouble("sl",T);
        }
      if(Turn_MaxLotSize>0.0 && NL(LotMultiplicator*lot)>=Turn_MaxLotSize) return;
      if(Turn_LotSize>0.0 && NL(LotMultiplicator*lot)>=Turn_LotSize) tp=Turn_LotSize_TakeProfit; else tp=Turn_TakeProfit;
      if(PO(OP_SELLSTOP,lev_inst,lev_inst+Turn*Pnt,lev_inst-tp*Pnt,LotMultiplicator*lot,GetComment(Numb+1))==-1) return;
      Numb++;
     }
   else

   if(sumSO>0 && sumBS==0)
     {
      T=GetTicket("market","last","trade");  if(T==-1) return;
      lev_inst=GetOrdDouble("sl",T);
      lot=GetOrdDouble("lot",T);
      if(lev_inst==0.0)
        {
         if(!ModifyByTicket(T)) return;
         lev_inst=GetOrdDouble("sl",T);
        }
      if(Turn_MaxLotSize>0.0 && NL(LotMultiplicator*lot)>=Turn_MaxLotSize) return;
      if(Turn_LotSize>0.0 && NL(LotMultiplicator*lot)>=Turn_LotSize) tp=Turn_LotSize_TakeProfit; else tp=Turn_TakeProfit;
      if(PO(OP_BUYSTOP,lev_inst,lev_inst-Turn*Pnt,lev_inst+tp*Pnt,LotMultiplicator*lot,GetComment(Numb+1))==-1) return;
      Numb++;
     }
   else

   if(sumO==0 && sumS>0)
     {
      if(!DelOrd()) return;
     }

  }
//=================================================================================================================================================//
int GetTicket(string type="",string position="last",string list="trade")
  {
   int pos=0,i=0,ticket=0,ticket_prev=-1;
   if(list=="trade")
     {
      for(pos=OrdersTotal()-1; pos>=0; pos--)
        {
         if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES) || OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
         if((type=="" && OrderType()>5) || (type=="market" && OrderType()>1) || (type=="buy" && OrderType()!=0) || (type=="sell" && OrderType()!=1)) continue;
         ticket=OrderTicket();
         if((position=="first" && (ticket_prev==-1 || ticket_prev>ticket)) || (position=="last" && (ticket_prev==-1 || ticket_prev<ticket)))
            ticket_prev=ticket;
        }
/*for*/
     }
   else
   if(list=="history")
     {
      for(pos=OrdersHistoryTotal()-1; pos>=0; pos--)
        {
         if(!OrderSelect(pos,SELECT_BY_POS,MODE_HISTORY) || OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
         if((type=="" && OrderType()>5) || (type=="market" && OrderType()>1) || (type=="buy" && OrderType()!=0) || (type=="sell" && OrderType()!=1)) continue;
         ticket=OrderTicket();
         if((position=="first" && (ticket_prev==-1 || ticket_prev>ticket)) || (position=="last" && (ticket_prev==-1 || ticket_prev<ticket)))
            ticket_prev=ticket;
         i++;  if(i==100) break;
        }
/*for*/
     }
   return(ticket_prev);
  }
//=================================================================================================================================================//
double GetOrdDouble(string value,int ticket)
  {
   if(!OrderSelect(ticket,SELECT_BY_TICKET)) return(0.0);
   if(value=="op") return(OrderOpenPrice()); else
   if(value=="lot") return(OrderLots()); else
   if(value=="sl") return(OrderStopLoss()); else
   if(value=="tp") return(OrderTakeProfit()); else
   if(value=="cp") return(OrderClosePrice()); else
   if(value=="result") return(OrderProfit()); else
   if(value=="swap") return(OrderSwap()); else
   if(value=="commission") return(OrderCommission());
   return(0.0);
  }
//=================================================================================================================================================//
int GetOrdInt(string value,int ticket)
  {
   if(!OrderSelect(ticket,SELECT_BY_TICKET)) return(-1);
   if(value=="type") return(OrderType()); else
   if(value=="id") return(OrderMagicNumber()); else
   if(value=="ot") return(OrderOpenTime()); else
   if(value=="ct") return(OrderCloseTime());
   return(-1);
  }
//=================================================================================================================================================//
void Trail()
  {
   if(Use_Turn || !Use_TrailingStop || sumO==0) return;

   double op,tp,sl,sl_lev;
   int i;

   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES) || OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic || OrderType()>1) continue;
      op=OrderOpenPrice(); sl=OrderStopLoss(); tp=OrderTakeProfit();
      Ans=false;

      if(OrderType()==OP_BUY)
        {
         if(ND(Bid-op)<=TrailingStop*Pnt) continue;
         if(sl!=0.0 && ND(Bid-sl)<=TrailingStop*Pnt) continue;
         sl_lev=Bid-TrailingStop*Pnt;
         if(ND(Bid-sl_lev)<StopLevel) continue;
        }

      else if(OrderType()==OP_SELL)
        {
         if(ND(op-Ask)<=TrailingStop*Pnt) continue;
         if(sl!=0.0 && ND(sl-Ask)<=TrailingStop*Pnt) continue;
         sl_lev=Ask+TrailingStop*Pnt;
         if(ND(sl_lev-Ask)<StopLevel) continue;
        }

      i=0;
      while(!Ans && i<5)
        {
         Ans=OrderModify(OrderTicket(),ND(op),ND(sl_lev),ND(tp),NULL,clrYellow);
         if(!Ans) { if(!Errors(GetLastError())) break; } i++;
        }
/*while*/
     }
/*for*/
  }
//=================================================================================================================================================//
bool TradeTime()
  {
   if(!Use_trade_time) return(true);

   datetime time_now=TimeCurrent(),time_start,time_end;
   int sec=86400,day=DayOfWeek();

   if(StringLen(Open_trade)==5)
      time_start=StrToTime(Open_trade);
   else if(StringLen(Open_trade)==8)
      time_start=StrToTime(StringSubstr(Open_trade,0,5))+StringToInteger(StringSubstr(Open_trade,6,2));

   if(StringLen(Close_trade)==5)
      time_end=StrToTime(Close_trade);
   else if(StringLen(Close_trade)==8)
      time_end=StrToTime(StringSubstr(Close_trade,0,5))+StringToInteger(StringSubstr(Close_trade,6,2));

   if(time_start>time_end)
     {
      if(time_now<time_start) { if(day==1) sec*=3;  time_start-=sec; }  else if(time_now>=time_start) { if(day==5) sec*=3;  time_end+=sec; }
     }

   if(time_now>=time_start && time_now<time_end) return(true);
   return(false);
  }
//=================================================================================================================================================//
double ma(int period,int ma_shift,ENUM_MA_METHOD ma_method,ENUM_APPLIED_PRICE ap_price,int shift)
  {
   return(ND(iMA(NULL,(int)Tf,period,ma_shift,ma_method,ap_price,shift)));
  }
//=================================================================================================================================================//
string GetComment(int i=0)
  {
   string comment=Symbol()+"- MovUp_v1.3.0";  if(i!=0) comment=comment+"."+IntegerToString(i);  return(StringConcatenate(comment));
  }
//=================================================================================================================================================//
double _GetLot()
  {

   if(OrderSelect(PrevFirstTicket,SELECT_BY_TICKET))
     {
      if((OrderProfit()+OrderSwap()+OrderCommission())<0.0)
        {
         if(AccountFreeMarginCheck(Symbol(),OrderType(),NL(FirstLotMultiplicator*OrderLots()))<=0.0 || GetLastError()==134)
           {
            if(!FreeMarginAlert)
              {
               Alert("Not enough money to send the order. Free Margin = ",DoubleToStr(AccountFreeMargin(),2));
               FreeMarginAlert=true;
              }
           }
         else
            return( FirstLotMultiplicator*OrderLots() );
        }
     }

   if(LotConst_or_not)
      return(Lot);
   else if(RiskPercent>0.0)
      return( 0.01*RiskPercent*AccountBalance()/MarketInfo(Symbol(),MODE_MARGINREQUIRED) );
   else
      return(MinLot);
  }
//=================================================================================================================================================//
double GetLot()
  {
   if(LotConst_or_not)
      return(Lot);
   else if(RiskPercent>0.0)
      return( 0.01*RiskPercent*AccountBalance()/MarketInfo(Symbol(),MODE_MARGINREQUIRED) );
   else
      return(MinLot);
  }
//=================================================================================================================================================//
double ExtrLevOrd(string str)
  {
   double order_value=0.0;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES) || OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;

      if(str=="BuyMax")
        {
         if(OrderType()==OP_BUY || OrderType()==OP_BUYSTOP)
            if(order_value==0.0 || OrderOpenPrice()>order_value)
               order_value=OrderOpenPrice();
        }
      else

      if(str=="BuyMin")
        {
         if(OrderType()==OP_BUY || OrderType()==OP_BUYSTOP)
            if(order_value==0.0 || OrderOpenPrice()<order_value)
               order_value=OrderOpenPrice();
        }
      else

      if(str=="SellMax")
        {
         if(OrderType()==OP_SELL || OrderType()==OP_SELLSTOP)
            if(order_value==0.0 || OrderOpenPrice()>order_value)
               order_value=OrderOpenPrice();
        }
      else

      if(str=="SellMin")
        {
         if(OrderType()==OP_SELL || OrderType()==OP_SELLSTOP)
            if(order_value==0.0 || OrderOpenPrice()<order_value)
               order_value=OrderOpenPrice();
        }
     }
/*for*/ return(order_value);
  }
//=================================================================================================================================================// 
double Get_TP(double tp_value,int OrdType)
  {
   double AvPrice=0.0,TotLot=0.0,loss_size=0.0,tp_lev=0.0;  int numb=0;

   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES) || OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic || OrdType!=OrderType()) continue;

      if(Varyant==1)
        {
         AvPrice+=OrderOpenPrice(); numb++;
        }
      else
      if(Varyant==2)
        {
         AvPrice+=OrderOpenPrice()*OrderLots(); TotLot+=OrderLots(); loss_size+=(OrderCommission()+OrderSwap());
        }
     } // for

   if(Varyant==1)
      AvPrice=ND(AvPrice/(double)numb); else
   if(Varyant==2)
     {
      AvPrice=ND(AvPrice/TotLot);
      if(loss_size>=0.0) loss_size=0.0; else loss_size=ND(MathAbs((loss_size/TickValue/TotLot)*TickSize));
     }

   if(OrdType==OP_BUY)
     {
      tp_lev=AvPrice+tp_value*Pnt; if(Varyant==2) tp_lev+=loss_size;
     }
   else
   if(OrdType==OP_SELL)
     {
      tp_lev=AvPrice-tp_value*Pnt; if(Varyant==2) tp_lev-=loss_size;
     }

   return(tp_lev);
  }
//=================================================================================================================================================//
bool Modify_TP(double tp_lev=NULL,int OrdType=-1)
  {
   double op,sl,tp;  int i;  color c=clrYellow;
   _Ans=true;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
      if(ND(tp_lev-OrderTakeProfit())==0.0) continue;
      order_type=OrderType(); if(OrdType>=0 && OrdType!=order_type) continue;
      op=OrderOpenPrice(); sl=OrderStopLoss(); tp=OrderTakeProfit();

      if(order_type==OP_BUY || order_type==OP_BUYSTOP || order_type==OP_BUYLIMIT)
        {
         if(ND(tp_lev-Bid)<StopLevel) tp_lev=Bid+1.5*StopLevel;
        }

      else if(order_type==OP_SELL || order_type==OP_SELLSTOP || order_type==OP_SELLLIMIT)
        {
         if(ND(Ask-tp_lev)<StopLevel) tp_lev=Ask-1.5*StopLevel;
        }

      i=0; Ans=false;
      while(!Ans && i<5)
        {
         Ans=OrderModify(OrderTicket(),ND(op),ND(sl),ND(tp_lev),0,c);
         if(!Ans) { if(!Errors(GetLastError())) break; } i++;
        }
/*while*/ if(!Ans) _Ans=false;
     }
/*for*/ return(_Ans);
  }
//=================================================================================================================================================//
bool ClosePos(int OrdType=-1)
  {
   double price; int i;
   _Ans=true;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
      order_type=OrderType(); if(order_type>1 || (OrdType>=0 && OrdType!=order_type)) continue;
      RefreshRates();
      i=0; Ans=false;
      while(!Ans && i<5)
        {
         if(order_type==OP_BUY) price=Bid; else price=Ask;
         Ans=OrderClose(OrderTicket(),OrderLots(),ND(price),2*MarketInfo(Symbol(),MODE_SPREAD));
         if(!Ans) { if(!Errors(GetLastError())) break; } i++;
        }
/*while*/ if(!Ans) _Ans=false;
     }
/*for*/ return(_Ans);
  }
//=================================================================================================================================================//
int MO(int OrdType,double lot,string comment="")
  { // market order
   double price;  color c;  int i;  T=-1;  RefreshRates();

   if(OrdType==OP_BUY) { c=clrLime;  price=Ask; } else if(OrdType==OP_SELL) { c=clrRed;  price=Bid; } else return(T);

   if(AccountFreeMarginCheck(Symbol(),OrdType,NL(lot))<=0.0 || GetLastError()==134)
     {
      if(!FreeMarginAlert)
        {
         Alert("Not enough money to send the order. Free Margin = ",DoubleToStr(AccountFreeMargin(),2));
         FreeMarginAlert=true;
        }
      return(T);
     }
   FreeMarginAlert=false;

   while(T<0 && i<5)
     {
      T=OrderSend(Symbol(),OrdType,NL(lot),ND(price),2*MarketInfo(Symbol(),MODE_SPREAD),NULL,NULL,comment,Magic,NULL,c);
      if(T<0) { if(!Errors(GetLastError())) return(T); } i++;
     }
/*while*/ return(T);
  }
//=================================================================================================================================================//
bool ModifyByTicket(int ticket)
  {
   if(!Use_Turn && !Use_TakeProfit && !Use_StopLoss) return(true);
   if(!OrderSelect(ticket,SELECT_BY_TICKET)) return(false);
   double sl=0.0,_sl=0.0,tp=0.0,op=OrderOpenPrice();  int i=0;  color c=clrYellow;
   if(Use_Turn) { _sl=Turn; TP=TakeProfit; } else _sl=StopLoss;
   RefreshRates();

   if(OrderType()==OP_BUY)
     {
      if(!Use_Turn && !Use_TakeProfit) tp=NULL; else tp=op+MathMax(TP*Pnt,StopLevel);
      if(!Use_Turn  &&  !Use_StopLoss) sl=NULL; else sl=op-MathMax(_sl*Pnt,StopLevel);
     }
   else if(OrderType()==OP_SELL)
     {
      if(!Use_Turn && !Use_TakeProfit) tp=NULL; else tp=op-MathMax(TP*Pnt,StopLevel);
      if(!Use_Turn  &&  !Use_StopLoss) sl=NULL; else sl=op+MathMax(_sl*Pnt,StopLevel);
     }

   i=0; Ans=false;
   while(!Ans && i<5)
     {
      Ans=OrderModify(ticket,ND(op),ND(sl),ND(tp),0,c);
      if(!Ans) { if(!Errors(GetLastError())) break; } i++;
     }
/*while*/ return(Ans);
  }
//=================================================================================================================================================//
int PO(int OrdType,double LevInst,double sl,double tp,double lot,string comment="")
  { // pending order
   int i=0,type;  color c;  T=-1;  RefreshRates();

   if(OrdType==OP_BUYSTOP)
     {
      type=OP_BUY;  c=clrBlue;
      if(ND(LevInst-Ask)<StopLevel) return(T);

     }
   else if(OrdType==OP_SELLSTOP)
     {
      type=OP_SELL;  c=clrRed;
      if(ND(Bid-LevInst)<StopLevel) return(T);

     }
   else return(T);

   if(AccountFreeMarginCheck(Symbol(),type,NL(lot))<=0.0 || GetLastError()==134)
     {
      if(!FreeMarginAlert)
        {
         Alert("Not enough money to send the order. Free Margin = ",DoubleToStr(AccountFreeMargin(),2));
         FreeMarginAlert=true;
        }
      return(T);
     }
   FreeMarginAlert=false;

   while(T<0 && i<5)
     {
      T=OrderSend(Symbol(),OrdType,NL(lot),ND(LevInst),0,ND(sl),ND(tp),comment,Magic,0,c);
      if(T==-1) { if(!Errors(GetLastError())) return(T); } i++;
     }
/*while*/ return(T);
  }
//=================================================================================================================================================//
bool DelOrd(int OrdType=-1)
  {
   int i;
   _Ans=true;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
      if((OrdType==-1 && OrderType()<=1) || (OrdType>0 && OrdType!=OrderType())) continue;
      i=0; Ans=false;
      while(!Ans && i<5)
        {
         Ans=OrderDelete(OrderTicket());
         if(!Ans) { if(!Errors(GetLastError())) break; } i++;
        }
/*while*/ if(!Ans) _Ans=false;
     }
/*for*/ return(_Ans);
  }
//=================================================================================================================================================//
void SumOrders(int i=0)
  {
   sumBO=0; sumSO=0; sumBS=0; sumSS=0; sumBL=0; sumSL=0; sumO=0; sumS=0; sumL=0;
   for(int pos=OrdersTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_TRADES)) continue;
      if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
      order_type=OrderType();
      if(order_type==OP_BUY)      sumBO++; else if(order_type==OP_SELL)      sumSO++; else
      if(order_type==OP_BUYSTOP)  sumBS++; else if(order_type==OP_SELLSTOP)  sumSS++; else
      if(order_type==OP_BUYLIMIT) sumBL++; else if(order_type==OP_SELLLIMIT) sumSL++;
     } // for 

   sumO=sumBO+sumSO; sumS=sumBS+sumSS; sumL=sumBL+sumSL;

   if(i==0) return; else

   if(i==1) { _sumBO=sumBO; _sumSO=sumSO; _sumBS=sumBS; _sumSS=sumSS; _sumBL=sumBL; _sumSL=sumSL; _sumO=sumO; _sumS=sumS; _sumL=sumL; }
  }
//=================================================================================================================================================//
bool HistoryCheck()
  {
   int i=0;
   while(i<10) { iTime(NULL,(int)Tf,0);  if(GetLastError()!=4066) break;  Sleep(1000);  i++; } // while
   if(i==10) { Comment("Update failed. Go to the next attempt."); return(false); }
   Comment(""); return(true);
  }
//=================================================================================================================================================//
void GetMarketInfo()
  {
   TickSize=MarketInfo(Symbol(),MODE_TICKSIZE); TickValue=MarketInfo(Symbol(),MODE_TICKVALUE);
   Spread=MarketInfo(Symbol(), MODE_SPREAD)*Point; StopLevel=MarketInfo(Symbol(), MODE_STOPLEVEL)*Point;
   MinLot=MarketInfo(Symbol(),MODE_MINLOT); MaxLot=MarketInfo(Symbol(),MODE_MAXLOT); LotStep=MarketInfo(Symbol(),MODE_LOTSTEP);
  }
//=================================================================================================================================================//
double NL(double L)
  {
   return(MathRound(MathMin(MathMax(L,MinLot),MaxLot)/LotStep)*LotStep);
  }
//=================================================================================================================================================//
double ND(double A)
  {
   return(NormalizeDouble(A,Digits));
  }
//=================================================================================================================================================//
//double NT(double A, int direction=0) { double _A=MathRound(A/TickSize)*TickSize;
// if(direction==1) { if(ND(A-_A)>0.0) _A+=TickSize; } else if(direction==-1) { if(ND(A-_A)<0.0) _A-=TickSize; } 
// return(_A); }
//=================================================================================================================================================//
datetime GVS(string Name,double Value)
  {
   return(GlobalVariableSet(Name+Name(),Value));
  }
//=================================================================================================================================================//
double GVG(string Name)
  {
   return(GlobalVariableGet(Name+Name()));
  }
//=================================================================================================================================================//
datetime GVZ(string Name)
  {
   return(GlobalVariableSet(Name+Name(),0.0));
  }
//=================================================================================================================================================//
bool GVD(string Name)
  {
   return(GlobalVariableDel(Name+Name()));
  }
//=================================================================================================================================================//
string Name()
  {
   if(IsTester) return("_"+Magic+"_"+Symbol()+"_"+"Tester"); else return("_"+Magic+"_"+Symbol());
  }
//=================================================================================================================================================//
bool Errors(int Error)
  {
   if(Error==0) return(false); // No error

   switch(Error)
     {
      // Crucial errors:
      case 4: // Trade server is busy  
         Sleep(3000); RefreshRates();
         return(true); // Avoidable error
      case 129: // Wrong price
      case 135: // Price changed
         RefreshRates(); // Refresh data
         return(true); // Avoidable error
      case 136: // No prices. Waiting for a new tick.
         while(RefreshRates()==false) Sleep(1);
         return(true); // Avoidable error
      case 137: // Broker is busy 
         Sleep(3000); RefreshRates();
         return(true); // Avoidable error
      case 146: // Trading subsystem is busy
         Sleep(500); RefreshRates();
         return(true); // Avoidable error
                       // Fatal error:
      case 2 :  // Generic error 
      case 5 :  // The old version of the client terminal
      case 64:  // Account blocked
      case 133: // Trading is prohibited
         Alert("A fatal error - expert stopped!"); FatalError=true; return(false); // Fatal error 
      default:  // Other variants
         return(false);
     }
/*switch*/
  }
//=================================================================================================================================================//
void Info()
  {
   drawFixedLbl("str_1_1","LeonLexx",0,500,50,24,"Arial",clrDodgerBlue);
   drawFixedLbl("str_1_2","MovingUp v_1.3.3",0,500,80,16,"Arial",clrDodgerBlue);

   drawFixedLbl("str_2_1","Сегодня: "+DoubleToStr(GetProfit(0),2),1,25,25,16,"Courier New",clrGold);
   drawFixedLbl("str_2_2","Вчера: "+DoubleToStr(GetProfit(1),2),1,25,50,16,"Courier New",clrGold);
   drawFixedLbl("str_2_3","Позавчера: "+DoubleToStr(GetProfit(2),2),1,25,75,16,"Courier New",clrGold);
   drawFixedLbl("str_2_4","Баланс: "+DoubleToStr(AccountBalance(),2),1,25,100,16,"Courier New",clrGold);

   WindowRedraw();
  }
//=================================================================================================================================================//
void drawFixedLbl(string objname,string s,int Corner,int DX,int DY,int FSize,string Font,color c,bool bg=false)
  {
   if(ObjectFind(objname)<0) {ObjectCreate(objname,OBJ_LABEL,0,0,0);}
   ObjectSet(objname,OBJPROP_CORNER,Corner);
   ObjectSet(objname,OBJPROP_XDISTANCE,DX);
   ObjectSet(objname,OBJPROP_YDISTANCE,DY);
   ObjectSet(objname,OBJPROP_BACK,bg);
   ObjectSetText(objname,s,FSize,Font,c);
  }
//=================================================================================================================================================//
void Obj_Del()
  {
   string label;
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      label=ObjectName(i);
      if(StringSubstr(label,0,3)=="str") { ObjectDelete(label); continue; }
     }
/*for*/
  }
//=================================================================================================================================================//
double GetProfit(int index)
  {
   datetime DailyStartTime=iTime(Symbol(),PERIOD_D1,index);
   double DailyProfit=0.0;

   for(int pos=OrdersHistoryTotal()-1; pos>=0; pos--)
     {
      if(!OrderSelect(pos,SELECT_BY_POS,MODE_HISTORY) || OrderSymbol()!=Symbol() || OrderMagicNumber()!=Magic) continue;
      if(OrderCloseTime()>=DailyStartTime && OrderCloseTime()<DailyStartTime+86400)
         DailyProfit+=(OrderProfit()+OrderCommission()+OrderSwap());
     }
/*for*/ return(DailyProfit);
  }
//=================================================================================================================================================//
