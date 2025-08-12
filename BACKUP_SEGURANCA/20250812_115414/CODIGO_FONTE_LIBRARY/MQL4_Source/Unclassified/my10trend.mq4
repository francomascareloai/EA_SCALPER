
extern double Lot = 0.1;
extern double Percent = 30;
extern int StopLoss = 400;
extern int TakeProfit = 1500;
extern int Slippage=10;
extern int Otstup = 10;
extern bool UseTrailing = false;
extern int TrailingStopLoss = 20;
extern int TrailingStep = 10;
extern int TSLBars = -1;
extern int TimeToDeath = 0;
extern int MaxDeals = 10;

extern string Param="------------------------------------------------------------------";
extern int WPR_Period=20;
/*
extern int RSI_Period=7;
extern int MA_Period=60;
extern int BB_Period=20;
extern int Envelopes_Period=10;
*/
extern int TimeShift=0;
extern int StartHour=23;
extern int EndHour=23;
extern int FridayLastWorkHour=20;
extern int MondayFirstWorkHour=6;
extern bool WorkOnlySelectedHours=false;
extern string HourPercent=">0 - fixed lot, 0 - not work, <0 - percent of this hour.";
extern double Pct0H=0, Pct1H=0, Pct2H=0, Pct3H=0, Pct4H=0, Pct5H=0, Pct6H=-10, Pct7H=0, Pct8H=0, Pct9H=0, Pct10H=0, Pct11H=0, Pct12H=0;
extern double Pct13H=0, Pct14H=0, Pct15H=0, Pct16H=0, Pct17H=0, Pct18H=0, Pct19H=0, Pct20H=0, Pct21H=0, Pct22H=0, Pct23H=-10;

extern double wprlvl=25, wprNoLosslvl=110, wprStartTraillvl=95, wprLossStartTraillvl=78, wprFinalTraillvl=98, wprTrailFactor=8;
extern int FinalTrailingStop = 20;
extern int PipStep=50;
extern int BarStep=5;
extern double Increment=1;
extern double PipStepIncrement=1;

static double time[24];
extern string TimeFrames = "-- 0, 1, 5, 15, 30, 60-H1, 240-H4, 1440-D1, 10080-W1, 43200-M1 --";
extern int TimeFrame = 60;

extern bool ProtectSL = true;
extern bool NotOpenIfBigStopLevel = false;
extern string comment="My4";
extern int MagicNumber = 8877667;
extern string gv="LDTime"; 
double Ttd=0;

static bool t0=false, t100=false;
bool initialized = false;
int MAX_TRAILING_STEP = 1;

int init() {
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   if (TakeProfit < stopLevel && TakeProfit>0 && !UseTrailing) {
      Alert("TakeProfit установлен меньше, чем разрешен вашим ДЦ. Минимальное значение: ", stopLevel);
      return(-1);
   }
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   if (Lot < minLot) {
      Alert("Lot установлен меньше, чем разрешен вашим ДЦ. Минимальное значение: ", minLot);
      return(-1);
   }
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   if (Lot > maxLot) {
      Alert("Lot установлен больше, чем разрешен вашим ДЦ. Максимальное значение: ", maxLot);
      return(-1);
   }
   if (UseTrailing) {
      if (TrailingStopLoss < stopLevel && TrailingStopLoss>0) {
         Alert("Минимальное значение TrailingStopLoss = ", stopLevel);
         return(-1);
      }
      if (TrailingStep < MAX_TRAILING_STEP) {
         Alert("Минимальное значение  TrailingStep = ", MAX_TRAILING_STEP);
         return(-1);
      }
   }
   time[0]=Pct0H; time[1]=Pct1H; time[2]=Pct2H; time[3]=Pct3H; time[4]=Pct4H; time[5]=Pct5H; time[6]=Pct6H; time[7]=Pct7H; time[8]=Pct8H; time[9]=Pct9H;
   time[10]=Pct10H; time[11]=Pct11H; time[12]=Pct12H; time[13]=Pct13H; time[14]=Pct14H; time[15]=Pct15H; time[16]=Pct16H; time[17]=Pct17H; time[18]=Pct18H; time[19]=Pct19H;
   time[20]=Pct20H; time[21]=Pct21H; time[22]=Pct22H; time[23]=Pct23H;
   initialized = true;
   GlobalVariableSet(gv, 0);
   return(0);
}

int deinit() {
   initialized = false;
   return(0);
}

int start() {
   if (!initialized) {
      return(0);
   }
   if (DayOfWeek() == 0 || DayOfWeek() == 6) {
      return(0);
   }
   if (!IsTradeAllowed()) {
      return(0);
   }
   double ldtm=0;
   if (GlobalVariableCheck(gv)) ldtm=GlobalVariableGet(gv); else GlobalVariableSet(gv, 0);

   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   bool prt=stopLevel>TrailingStopLoss*Point && ProtectSL;
   int per=TimeFrame;
   int ticket;
   int q = 0;

 
   
//   double spred = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   double spred = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;//18 * Point;
   double sl = StopLoss * Point;
   double tp = TakeProfit * Point;
   double otst = Otstup * Point;

   if (UseTrailing) {
      TrailingPositions(TrailingStopLoss, TrailingStep, MagicNumber);
   }
   if (TSLBars==0) TSLBars=WPR_Period;
   TrailingPositionsBars(TSLBars, per, MagicNumber);
  
   bool tm=false; int rtm=TimeHour(TimeCurrent())-TimeShift; if (rtm<0) rtm=rtm+24; if (rtm>23) rtm=rtm-24;
   if (rtm<0 || rtm>23) { Alert("Неправильный сдвиг времени"); return(0); }
   if (!WorkOnlySelectedHours) {
      if (StartHour<=EndHour && rtm>=StartHour && rtm<=EndHour) tm=true;
      if (StartHour>EndHour && (rtm>=StartHour || rtm<=EndHour)) tm=true;
   } else {
      if (time[rtm]<0) {tm=true; Percent=-time[rtm];}
      if (time[rtm]>0) {tm=true; Percent=0; Lot=time[rtm];}
   }
   if (TimeDayOfWeek(TimeCurrent())==5 && rtm>FridayLastWorkHour) tm=false;
   if (TimeDayOfWeek(TimeCurrent())==1 && rtm<MondayFirstWorkHour) tm=false;
   
   double realLot=Lot;
   if (Percent>0) {
      double base=MathMin(AccountEquity(), AccountBalance());
      realLot=MathFloor(base/100*Percent*Lot)/100;
      if (realLot<MarketInfo(Symbol(), MODE_MINLOT)) { Comment("Нечем торговать :("); return(0); }
      realLot=MathMin(MathMax(MarketInfo(Symbol(), MODE_MINLOT),MathFloor(base/100*Percent*Lot)/100),MarketInfo(Symbol(), MODE_MAXLOT));
   }
   if (tm) Comment("Lot=",realLot,"\n"); else Comment("Временно отдыхаем");

//   double bid = MarketInfo(OrderSymbol(), MODE_BID);
//   double ask = MarketInfo(OrderSymbol(), MODE_ASK);
   double bid = Bid;
   double ask = Ask;

   int ob=0, os=0, obs=0, oss=0, wob=0, wos=0;
   double bmin=1000, smax=0, bvmax=0, svmax=0, ltmb=0, ltms=0;
   for (q = 0; q < OrdersTotal(); q++) {
      if (OrderSelect(q, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUYSTOP) obs++;
         if (OrderType() == OP_SELLSTOP) oss++;
         if (OrderType() == OP_BUY) {
            ob++; bmin=MathMin(bmin, OrderOpenPrice()); bvmax=MathMax(bvmax, OrderLots()); ltmb=MathMax(ltmb, OrderOpenTime());
            if (OrderStopLoss()>=OrderOpenPrice()) wob++;
         }
         if (OrderType() == OP_SELL) {
            os++;  smax=MathMax(smax, OrderOpenPrice()); svmax=MathMax(svmax, OrderLots()); ltms=MathMax(ltms, OrderOpenTime());
            if (OrderStopLoss()<=OrderOpenPrice()) wos++;
         }
      }
   }

   double bsl=0, ssl=0, btp=0, stp=0;
   if (StopLoss>0) { bsl=bid - StopLoss*Point; ssl=bid + spred + StopLoss*Point;}
   if (TakeProfit>0) { btp=bid + TakeProfit*Point; stp=ask - TakeProfit*Point;}
///////////// Условия открытия позиций ////////////////////////////
//   bool condRSIBuy=false, condRSISell=false, condHiDown=false, condLowUp=false;
//   bool condMOMBuy=false, condMOMSell=false;
   bool condWPRBuy=false, condWPRSell=false,wprBST=false, wprBNL=false, wprSST=false, wprSNL=false, wprLSST=false, wprLBST=false, wprFSST=false, wprFBST=false;
   bool condBuy=false, condSell=false, condCloseBuy=false, condCloseSell=false, condCloseBuyPrt=false, condCloseSellPrt=false;
   bool condBuyNoLoss=false, condSellNoLoss=false, condLossBuyStartTrail=false, condLossSellStartTrail=false;
   bool condBuyStartTrail=false, condSellStartTrail=false, condFinalBuyStartTrail=false, condFinalSellStartTrail=false;
   bool condDemDeal=false;
   double L2 = iLow(NULL, per, 2), L1 = iLow(NULL, per, 1), L = iLow(NULL, per, 0);
   double H2 = iHigh(NULL, per, 2), H1 = iHigh(NULL, per, 1), H = iHigh(NULL, per, 0);
   double O2 = iOpen(NULL, per, 2), O1 = iOpen(NULL, per, 1), O = iOpen(NULL, per, 0);
   double C2 = iClose(NULL, per, 2), C1 = iClose(NULL, per, 1), C = iClose(NULL, per, 0);
   bool barup2=C2>=O2, barup1=C1>=O1;
   bool PrtCloseDown=C<MathMax(H, H1)-TrailingStopLoss*Point;
   bool PrtCloseUp=C>MathMin(L, L1)+TrailingStopLoss*Point;

//   double rsi0=iRSI(NULL, per, RSI_Period, PRICE_OPEN, 0), rsi1=iRSI(NULL, per, RSI_Period, PRICE_OPEN, 1), rsilvl=30;
//   if (rsi0<rsilvl && rsi0>rsi1) condRSIBuy=true; if (rsi0>100-rsilvl && rsi0<rsi1) condRSISell=true;
//   if (H2>H1) condHiDown=true; if (L2<L1) condLowUp=true;
   

//   double atr0=iATR(NULL, per, 1, 0), atr1=iATR(NULL, per, 1, 1), atr2=iATR(NULL, per, 1, 2);
//   double ma0=iMA(NULL, per, MA_Period, 0, MODE_EMA, PRICE_OPEN, 0), ma1=iMA(NULL, per, MA_Period, 0, MODE_EMA, PRICE_OPEN, 1);
   double wpr0=iWPR(NULL, per, WPR_Period, 0), wpr1=iWPR(NULL, per, WPR_Period, 1), wpr2=iWPR(NULL, per, WPR_Period, 2), wpr3=iWPR(NULL, per, WPR_Period, 3), wpr4=iWPR(NULL, per, WPR_Period, 4), wpr5=iWPR(NULL, per, WPR_Period, 5), wpr6=iWPR(NULL, per, WPR_Period, 6), wpr7=iWPR(NULL, per, WPR_Period, 7), wpr8=iWPR(NULL, per, WPR_Period, 8);
//   double dem0=iDeMarker(NULL, per, 14,0); if (dem0>=0.3 && dem0<=0.7) condDemDeal=true;
   condDemDeal=true;
//   double mom1=iMomentum(NULL,per,WPR_Period*4, PRICE_TYPICAL,0);
//   condMOMBuy=mom1>=100; condMOMSell=mom1<=100;
/*
   double bbu1=iBands(NULL, per, BB_Period, 2, 0, PRICE_OPEN, MODE_UPPER,1), bbu0=iBands(NULL, per, BB_Period, 2, 0, PRICE_OPEN, MODE_UPPER,0);
   double bbl1=iBands(NULL, per, BB_Period, 2, 0, PRICE_OPEN, MODE_LOWER,1), bbl0=iBands(NULL, per, BB_Period, 2, 0, PRICE_OPEN, MODE_LOWER,0);
   bool HiPeak=C>bbu0, LoPeak=C<bbl0;
   bool FinishDownTrend=ma0>bbu0, FinishUpTrend=ma0<bbl0;   
*/
//   double envu=iEnvelopes(NULL, per, Envelopes_Period, MODE_SMMA, 0, PRICE_OPEN, 0.04, MODE_UPPER,0);
//   double envl=iEnvelopes(NULL, per, Envelopes_Period, MODE_SMMA, 0, PRICE_OPEN, 0.04, MODE_LOWER,0);
   bool flat=false; // if (envu>ma0 && envl<ma0) flat=true; 
   flat=true;
   bool firsttick=TimeCurrent()-BarStep*per*60>=ldtm;//!iVolume(NULL,per,0)>1;
   bool ttb=TimeCurrent()-BarStep*per*60>=ltmb;
   bool tts=TimeCurrent()-BarStep*per*60>=ltms;
//   bool atrReverse=atr2/2>atr1;
//   bool maup=ma0>ma1;
//   double wprlvl=1, wprNoLosslvl=30, wprStartTraillvl=80, wprLossStartTraillvl=15, wprDelta=0;
   if (wpr1<=-100+wprlvl && wpr0>wpr1) condWPRBuy=true;
   if (wpr1>=0-wprlvl && wpr0<wpr1) condWPRSell=true;


   if (wpr0>=-100+wprStartTraillvl) wprBST=true;// else if (wpr0>=-100+wprNoLosslvl) wprBNL=true;
   if (wpr0<=0-wprStartTraillvl) wprSST=true;// else if (wpr0<=0-wprNoLosslvl) wprSNL=true;
   if (wpr0>=-100+wprLossStartTraillvl) wprLBST=true;// else if (wpr0>=-100+wprNoLosslvl) wprBNL=true;
   if (wpr0<=0-wprLossStartTraillvl) wprLSST=true;// else if (wpr0<=0-wprNoLosslvl) wprSNL=true;
   if (wpr0>=-100+wprFinalTraillvl) wprFBST=true;// else if (wpr0>=-100+wprNoLosslvl) wprBNL=true;
   if (wpr0<=0-wprFinalTraillvl) wprFSST=true;// else if (wpr0<=0-wprNoLosslvl) wprSNL=true;
   if (wpr0>=-100+wprNoLosslvl && !wprBST && !wprLBST && !wprFBST) wprBNL=true;
   if (wpr0<=0-wprNoLosslvl && !wprSST && !wprLSST && !wprFSST) wprSNL=true;
   if (wpr0>=-100+wprNoLosslvl) wprBNL=true;
   if (wpr0<=0-wprNoLosslvl) wprSNL=true;

//   wpr1=(wpr1+wpr2+wpr3+wpr4+wpr5+wpr6+wpr7)/7; wpr2=(wpr2+wpr3+wpr4+wpr5+wpr6+wpr7+wpr8)/7;
   condWPRBuy=(wpr1<-100+wprlvl && wpr0>=-100+wprlvl);
   condWPRSell=(wpr1>0-wprlvl && wpr0<=0-wprlvl);
//   t100=false; t0=false;
   condWPRBuy=((t100 || wpr2<-100+wprlvl) && wpr1>=-100+wprlvl && wpr0>wpr1);
   condWPRSell=((t0 || wpr2>0-wprlvl) && wpr1<=0-wprlvl && wpr0<wpr1);
   

   bool cb1;
//   cb1=condWPRBuy; condWPRBuy=condWPRSell;condWPRSell=cb1;
//   condBuy=condWPRBuy && ttb && ob<MaxDeals && C<bmin-PipStep*Point*MathPow(PipStepIncrement,ob);// && LoPeak atrReverse && C>L1 && L<L1; && condMOMBuy
//   condSell=condWPRSell && tts && os<MaxDeals  && C>smax+PipStep*Point*MathPow(PipStepIncrement,os);// && HiPeak atrReverse && C<H1 && H>H1; && condMOMSell;
   condBuy=condWPRBuy && ob<MaxDeals && !wprSST;// && LoPeak atrReverse && C>L1 && L<L1; && condMOMBuy
   condSell=condWPRSell && os<MaxDeals && !wprBST;// && HiPeak atrReverse && C<H1 && H>H1; && condMOMSell;
//   condBuy=condRSIBuy && ob==0 && maup;//atrReverse && C>L1 && L<L1;
//   condSell=condRSISell && os==0 && !maup;//atrReverse && C<H1 && H>H1;

   condCloseBuy=wprSST;
   condCloseSell=wprBST;
   condBuyNoLoss=wprBNL;
   condSellNoLoss=wprSNL;
   
//   condCloseBuy=condCloseBuy || condSell; condCloseSell=condCloseSell || condBuy;
//   cb1=condBuy; condBuy=condSell; condSell=cb1;
//   cb1=condCloseBuy; condCloseBuy=condCloseSell; condCloseSell=cb1;
//   cb1=condCloseBuy; condCloseBuy=condCloseBuy || condCloseSell; condCloseSell=condCloseSell || cb1;
  
//   cb1=condBuy; condBuy=condBuy || condSell; condSell=condSell || cb1;
//   
/*
   
   bool cb1=condBuy;
   condBuy=condBuy || condSell;
   condSell=condSell || cb1;
   condCloseBuy=wprSST;
   condCloseSell=wprBST;
   bool cb1=condBuy;
   condBuy=condBuy || condSell;
   condSell=condSell || cb1;
   condBuyStartTrail=wprBST; //condBuyNoLoss=condRSISell;
   condSellStartTrail=wprSST; //condSellNoLoss=condRSIBuy;
   condLossBuyStartTrail=wprLBST; //condBuyNoLoss=condRSISell;
   condLossSellStartTrail=wprLSST; //condSellNoLoss=condRSIBuy;
   condFinalBuyStartTrail=wprFBST; //condBuyNoLoss=condRSISell;
   condFinalSellStartTrail=wprFSST; //condSellNoLoss=condRSIBuy;
   condCloseBuy=condWPRSell && prt;
   condCloseSell=condWPRBuy && prt;
   condCloseBuyPrt=condLossBuyStartTrail && prt && PrtCloseDown;
   condCloseSellPrt=condLossSellStartTrail && prt && PrtCloseUp;
*/
///////////////////// Закрытие позиций ////////////////////////////
//   if (TSLBars<0)
   for (q = 0; q < OrdersTotal(); q++) {
      if (OrderSelect(q, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         int type=OrderType(); ticket=OrderTicket();
         double lots=OrderLots(), price=OrderOpenPrice(), stoploss=OrderStopLoss(), takeprofit=OrderTakeProfit(), nsl=0, nstp=0, nts=TrailingStep*Point;
         if (type == OP_BUY) {
            if (condCloseBuy || condCloseBuyPrt) {
               OrderClose(ticket, lots, bid, Slippage); t100=true;
            }
            if (condBuyNoLoss && bid>price+stopLevel && stoploss<price) OrderModify(ticket, price, price, takeprofit, OrderExpiration());
            if (((condBuyStartTrail || condBuyNoLoss) && bid>price+stopLevel)|| (condLossBuyStartTrail && stoploss<price) || condFinalBuyStartTrail){ //bid<price+stopLevel)) {
               if (condFinalBuyStartTrail) nstp=MathMax(stopLevel, TrailingStopLoss*Point);
                  else nstp=MathMax(stopLevel, NormalizeDouble(MathAbs(bid-price)/wprTrailFactor, Digits));
//               nstp=stopLevel+NormalizeDouble(MathAbs(bid-price)/5, Digits);
               nsl=bid-nstp;
               if (condBuyNoLoss) nsl=price;
               if (nsl>stoploss+nts) OrderModify(ticket, price, nsl, takeprofit, OrderExpiration());
            }
         }
         if (OrderType() == OP_SELL) {
            if (condCloseSell || condCloseSellPrt) {
               OrderClose(ticket, lots, ask, Slippage);
               t0=true;
            }
            if (condSellNoLoss && ask<price-stopLevel && stoploss>price) OrderModify(ticket, price, price, takeprofit, OrderExpiration());
            if (((condSellStartTrail || condSellNoLoss) && ask<price-stopLevel) || (condLossSellStartTrail && stoploss>price) || condFinalSellStartTrail) {// ask>price-stopLevel)) {
               if (condFinalSellStartTrail) nstp=MathMax(stopLevel, TrailingStopLoss*Point);
               else nstp=MathMax(stopLevel, NormalizeDouble(MathAbs(price-ask)/wprTrailFactor, Digits));
//               nstp=stopLevel+NormalizeDouble(MathAbs(price-ask)/5, Digits);
               nsl=ask+nstp;
               if (condSellNoLoss) nsl=price;
               if (nsl<stoploss-nts) OrderModify(ticket, price, nsl, takeprofit, OrderExpiration());
            }
         }
      }
   }


   if (!tm) return(0);
   if (prt && NotOpenIfBigStopLevel) {
     Comment("Стоплевел=",MarketInfo(Symbol(), MODE_STOPLEVEL), ", невозможно трейлить стоплосс.");
     return(0);
   }
/**/
//////////////////// Открытие позиций ////////////////////////////
   int t=0;
   if (condBuy) {
      t=OrderSend(Symbol(), OP_BUY, realLot*MathPow(Increment,ob), Ask, Slippage, bsl, btp, comment+"-"+DoubleToStr(TimeHour(TimeCurrent()),1), MagicNumber, 0);
      if (t>=0) { GlobalVariableSet(gv, TimeCurrent()); t100=false; }
      else Print ("Buy ",ask," ", bsl, " ", btp, "Error=",GetLastError());//iTime(Symbol(), per, 0) + per * 60, Blue);
   }
   if (condSell) {
      t=OrderSend(Symbol(), OP_SELL, realLot*MathPow(Increment,os), Bid, Slippage, ssl, stp, comment+"-"+DoubleToStr(TimeHour(TimeCurrent()),1), MagicNumber, 0);
      if (t>=0) { GlobalVariableSet(gv, TimeCurrent()); t0=false; }
      else Print ("Sell ",bid," ", ssl, " ", stp, "Error=",GetLastError());//iTime(Symbol(), per, 0) + per * 60, Blue);
   }
}

void TrailingPositions(int trailingStopLoss, int trailingStep, int magicNumber) {
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   trailingStopLoss=MathMax(trailingStopLoss, MarketInfo(Symbol(), MODE_STOPLEVEL));
   double bid = MarketInfo(OrderSymbol(), MODE_BID);
   double ask = MarketInfo(OrderSymbol(), MODE_ASK);
   for (int i = 0; i < OrdersTotal(); i++) {
      if (!(OrderSelect(i, SELECT_BY_POS)) || OrderSymbol() != Symbol() || OrderMagicNumber() != magicNumber) {
         continue;
      }
      if (OrderType() == OP_BUY) {
      if (TimeToDeath>0 && (TimeCurrent()-OrderOpenTime())>TimeToDeath && (OrderStopLoss()<OrderOpenPrice() || OrderStopLoss() == 0))// && ma0<ma1) 
         OrderClose(OrderTicket(),OrderLots(),bid,3,CLR_NONE);

         if (bid - OrderOpenPrice() > trailingStopLoss * Point) {
            if (OrderStopLoss() < bid - (trailingStopLoss + trailingStep - 1) * Point || OrderStopLoss() == 0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), bid - trailingStopLoss * Point, OrderTakeProfit(), OrderExpiration());
            }
         }

      } else if (OrderType() == OP_SELL) {
      if (TimeToDeath>0 && (TimeCurrent()-OrderOpenTime())>TimeToDeath && (OrderStopLoss()>OrderOpenPrice() || OrderStopLoss() == 0))// && ma0>ma1)
         OrderClose(OrderTicket(),OrderLots(),ask,3,CLR_NONE);

         if (OrderOpenPrice() - ask > trailingStopLoss * Point) {
            if (OrderStopLoss() > ask + (trailingStopLoss + trailingStep - 1) * Point || OrderStopLoss() == 0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), ask + trailingStopLoss * Point, OrderTakeProfit(), OrderExpiration());
            }
            
         }

      }
   }
}
void TrailingPositionsBars(int tslb, int pr, int magicNumber) {
   double MinL=10000, MaxH=0; int q=0;
   if (tslb>0) {
      for (q=1; q<tslb+1; q++) {
         MinL=MathMin(MinL, iLow(NULL, pr, q)); MaxH=MathMax(MaxH, iHigh(NULL, pr, q));
      }
   } else return(0);
   MinL=MinL-Otstup*Point; MaxH=MaxH+(18+Otstup)*Point;
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   double bid = MarketInfo(OrderSymbol(), MODE_BID);
   double ask = MarketInfo(OrderSymbol(), MODE_ASK);
   for (int i = 0; i < OrdersTotal(); i++) {
      if (!(OrderSelect(i, SELECT_BY_POS)) || OrderSymbol() != Symbol() || OrderMagicNumber() != magicNumber) {
         continue;
      }
      if (OrderType() == OP_BUY) {
            if (OrderStopLoss() < MinL && MinL<=bid-stopLevel) {
               OrderModify(OrderTicket(), OrderOpenPrice(), MinL, OrderTakeProfit(), OrderExpiration());
            }

      } else if (OrderType() == OP_SELL) {

            if ((OrderStopLoss() == 0 || OrderStopLoss() > MaxH) && MaxH>=ask+stopLevel) {
               OrderModify(OrderTicket(), OrderOpenPrice(), MaxH, OrderTakeProfit(), OrderExpiration());
            }
            
      }
   }
}

