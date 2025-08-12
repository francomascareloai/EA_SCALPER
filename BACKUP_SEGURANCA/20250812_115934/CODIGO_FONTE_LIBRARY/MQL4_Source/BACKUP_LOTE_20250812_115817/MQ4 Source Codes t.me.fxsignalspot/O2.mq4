#property   copyright "VladMsk"
#property   link      "vlad@rosfi.ru"
#define  pi 3.141592653589793238462643383279502884197169399375105820974944592
extern int     Trend = 0;
//extern bool    OnlyTrend = True;
extern int     TrendTimeFrame = PERIOD_M5;
extern int     TrendPeriod = 36;
extern int     HLPeriod = 240;
extern double  TPAsPercentageOfATR = 33;
extern double  TPvsTrendAsPercentageOfTP = 50;
extern double  Risk = 10.0;
extern int     PipsNoRollback = 0;
extern int     Magic =  20080531;
extern int     Magic2 =  -1;
extern int     Attempt = 4;
extern int     SleepForWait=333;
extern int     NeedLog = 0;

int   CCIPeriod           =  30;
int   CCIOversold         = -100;
int   CCIOverbought       =  100;

bool  NeedUpdateTP = true;
bool  IsIndCalc = False;
int   PrevOBuy = 0, PrevOSell = 0, PrevTarget = 0;

double TRVI(string symbol, int timeframe, int RVIPeriod = 36, int shift = 0)  {
string sy = symbol;
int   tf = timeframe;
if(symbol == "")  sy  = Symbol();
if(timeframe == 0)   tf = Period();
double   sOpen[], sClose[], sHigh[], sLow[], sVolume[];
ArrayCopySeries(sOpen,MODE_OPEN,sy,tf);
if(GetLastError()==4066)   {Print("HISTORY WILL UPDATED: ", sy); IsIndCalc = False; return(0.0);}
ArrayCopySeries(sClose,MODE_CLOSE,sy,tf);
if(GetLastError()==4066)   {Print("HISTORY WILL UPDATED: ", sy); IsIndCalc = False; return(0.0);}
ArrayCopySeries(sHigh,MODE_HIGH,sy,tf);
if(GetLastError()==4066)   {Print("HISTORY WILL UPDATED: ", sy); IsIndCalc = False; return(0.0);}
ArrayCopySeries(sLow,MODE_LOW,sy,tf);
if(GetLastError()==4066)   {Print("HISTORY WILL UPDATED: ", sy); IsIndCalc = False; return(0.0);}
ArrayCopySeries(sVolume,MODE_VOLUME,sy,tf);
if(GetLastError()==4066)   {Print("HISTORY WILL UPDATED: ", sy); IsIndCalc = False; return(0.0);}
double   dNum = 0.0, dDeNum = 0.0;
for(int  k = 0; k < RVIPeriod; k++)   {
   int   j = shift + k;
   double   Norm = RVIPeriod - k + 1;
   dNum += Norm * ((sVolume[j]*(sClose[j] - sOpen[j])+8.0*sVolume[j+1]*(sClose[j+1]-sOpen[j+1])+8.0*sVolume[j+2]*(sClose[j+2]-sOpen[j+2])+sVolume[j+3]*(sClose[j+3]-sOpen[j+3])));
   dDeNum += Norm * ((sVolume[j]*(sHigh[j]-sLow[j])+8.0*sVolume[j+1]*(sHigh[j+1]-sLow[j+1])+8.0*sVolume[j+2]*(sHigh[j+2]-sLow[j+2])+sVolume[j+3]*(sHigh[j+3]-sLow[j+3])));
   }
IsIndCalc = True; 
double   res = 0.0;
if(dDeNum != 0.0)   res = dNum/dDeNum;
else  res = dNum;
return(res);
}

int init()  {
return(0);  }

int start() {
int   na, i, res, Total = OrdersTotal();
bool  OK = true;
string   sy = Symbol();
double   Profit, AvgBuy, AvgSell, MinBuy, MinSell, MaxBuy, MaxSell, BuyLots, SellLots, ProfitBuy, ProfitSell;
int   OBuy, OSell;
for(na = 0;na < Attempt;na++) {
   Profit = 0.0;
   AvgBuy = 0.0;
   AvgSell = 0.0;
   MinBuy = 0.0;
   MinSell = 0.0;
   MaxBuy = 0.0;
   MaxSell = 0.0;
   BuyLots = 0.0;
   SellLots = 0.0;
   OBuy = 0;
   OSell = 0;
   for(i = 0;i <  Total; i++) {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false) {
         OK = False;
         break;   }
      int   OMN = OrderMagicNumber();
      if(OrderSymbol() != sy) continue;
      if(Magic2 != -1 && Magic != OMN && Magic2 != OMN) continue;
      int   OType = OrderType();
      if(OType != OP_BUY && OType != OP_SELL)   continue;
      double   OPrice = OrderOpenPrice(); //OrderCommission
      double   OLots = OrderLots();
      double   OTP = OrderTakeProfit();
      if(OTP == 0.0) NeedUpdateTP = True;
      double   OProfit = OTP + OrderSwap() + OrderCommission();
      if(OType == OP_BUY)  {
         OBuy++;
         BuyLots += OLots;
         AvgBuy += OLots * OPrice;
         MaxBuy = MathMax(MaxBuy,MathMax(OPrice,OTP));
         if(OPrice < MinBuy || MinBuy == 0.0)  MinBuy = OPrice;
         ProfitBuy += OProfit;   }
      if(OType == OP_SELL)  {
         OSell++;
         SellLots += OLots;
         AvgSell += OLots * OPrice;
         if(OPrice > MaxSell)  MaxSell = OPrice;
         if(OPrice < MinSell || MinSell == 0.0)  MinSell = OPrice;
         if(OTP < MinSell && OTP != 0.0)  MinSell = OTP;
         ProfitSell += OProfit;   }   
       OK = True;
       }
      if(OK)   break;
      }
if(!OK)  {
   Print("Ќе удалось получить достоверную статистику!");
   return(0);  }
if(PrevOBuy != OBuy)  NeedUpdateTP = true;
if(PrevOSell != OSell)  NeedUpdateTP = true;
PrevOBuy = OBuy;
PrevOSell = OSell;
double   RVI = 0.0;
double   sPoint = MarketInfo(sy,MODE_POINT);
int      sDigits = MarketInfo(sy,MODE_DIGITS);
double   sAsk = NormalizeDouble(MarketInfo(sy,MODE_ASK), sDigits);
double   sBid = NormalizeDouble(MarketInfo(sy,MODE_BID), sDigits);
double   sSpread = sAsk - sBid;
double   ATR = MathMax(24.0 * sSpread, MathMax(iATR(sy,PERIOD_D1,20,0),iATR(sy,PERIOD_D1,20,1)));
double   TPTrend = NormalizeDouble(ATR * TPAsPercentageOfATR * 0.01, sDigits);
double   TPvsTrend = NormalizeDouble(TPTrend * TPAsPercentageOfATR * 0.01, sDigits);
double   MinPipStep = TPTrend;
int   Target = Trend;
if(Trend == 0) {
   for(na = 0;na < Attempt;na++) {
      if(na > 0)  {
         Sleep(SleepForWait);
         RefreshRates();   }
      RVI = TRVI(sy, TrendTimeFrame, TrendPeriod, 0);
      if(IsIndCalc)  break;   }
   if(!IsIndCalc) {
      Print("Pair: ", sy, " , TRVI not calculated!");
      return(0);  }  
   if(RVI > 0.0)  Target = 1;
   if(RVI < 0.0)  Target = -1;   }
if(Target != PrevTarget)  NeedUpdateTP = true;
PrevTarget = Target;
for(na = 0;na < Attempt;na++) {
   OK = False;
   if(na > 0)  {
      RefreshRates();
      sAsk = NormalizeDouble(MarketInfo(sy,MODE_ASK), sDigits);
      sBid = NormalizeDouble(MarketInfo(sy,MODE_BID), sDigits);   }
   int      SlipPage = ((sAsk - sBid)/sPoint/3.0);
   int      TypePrice = PRICE_CLOSE;
   if(Target > 0) TypePrice = PRICE_LOW;
   if(Target < 0) TypePrice = PRICE_HIGH;
   double   cci0 = iCCI(sy,PERIOD_M1,CCIPeriod,TypePrice,0);
   double   cci1 = iCCI(sy,PERIOD_M1,CCIPeriod,TypePrice,1);
   bool  NeedSell = (cci0 > CCIOverbought && cci0 < cci1) && (iHighest(sy, PERIOD_M1, MODE_HIGH, HLPeriod, 0) < 3);
   bool  NeedBuy =  (cci0 < CCIOversold && cci0 > cci1) && (iLowest(sy, PERIOD_M1, MODE_LOW, HLPeriod, 0) < 3);
   if(!NeedSell && !NeedBuy)  {  OK = True;  break;   }
   if(NeedSell && Target > 0 && SellLots <= 0.0)   {  OK = True;  break;   }
   if(NeedBuy && Target < 0 && BuyLots <= 0.0)   {  OK = True;  break;   }
   if(NeedSell && SellLots > 0.0 && (sBid  < (MaxSell + MinPipStep)))   {  OK = True;  break;   } //  || sBid < (MaxSell + MinPipStep)
   if(NeedBuy  && BuyLots  > 0.0 && (sAsk  > (MinBuy  - MinPipStep)))   {  OK = True;  break;   } //  || sAsk < (MaxBuy  + MinPipStep)
   if(NeedSell && ((sBid > MaxSell && SellLots > 0.0) || (Target < 0 && (sBid < MinSell || sBid > MaxSell))))   {
      MaxSell = MathMax(MaxSell, sBid);
      if(MinSell == 0.0)   MinSell = sBid;
      MinSell = MathMin(MinSell, sBid);
      int   GonePips = (MaxSell - MinSell)/sPoint;
      if(OSell < 1) GonePips = TPTrend/sPoint;
      double   GoneLots = SellLots - BuyLots;
      if(GoneLots <= 0.0)   GoneLots = MathMax(0.0,0.5 * SellLots);
      double lots = Lots(GoneLots,  GonePips, PipsNoRollback, sy);
      if(lots == 0.0)   {
         OK = True;
         break;   } 
      if(AccountFreeMarginCheck(sy,OP_SELL,lots) <= 0.0 || GetLastError() == 134)   {
         OK = True;
         Print("NOT ENOUGH MONEY. SELL. Lot = ", lots, ", Pair = ", sy);
         break;   }
      if(OrderSend(sy, OP_SELL, lots, sBid, SlipPage,0,0,"", Magic, 0, RoyalBlue) == -1) {
         if(MyError() != 1) return(0);
         OK = False;
         continue;   }
      OK = True;
      NeedUpdateTP = True;
      return(0);   }
   if(NeedBuy && ((sAsk < MinBuy && BuyLots > 0.0) || (Target > 0 && (sAsk < MinBuy || sAsk > MaxBuy))))   {
      MaxBuy = MathMax(MaxBuy, sAsk);
      if(MinBuy == 0.0)   MinBuy = sAsk;
      MinBuy = MathMin(MinBuy, sAsk);
      GonePips = (MaxBuy - MinBuy)/sPoint;
      if(OBuy < 1) GonePips = TPTrend/sPoint; //Print("TPTrend =", TPTrend, " ,TPvsTrend =", TPvsTrend);
      GoneLots = BuyLots - SellLots;
      if(GoneLots <= 0.0)   GoneLots = MathMax(0.0,0.5 * BuyLots);
      lots = Lots(GoneLots,  GonePips, PipsNoRollback, sy);
      if(lots == 0.0)   {
         OK = True;
         break;   } 
      if(AccountFreeMarginCheck(sy,OP_BUY,lots) <= 0.0 || GetLastError() == 134)   {
         OK = True;
         Print("NOT ENOUGH MONEY. BUY. Lot = ", lots, ", Pair = ", sy);
         break;   }
      if(OrderSend(sy, OP_BUY, lots, sAsk, SlipPage,0,0,"", Magic, 0, Gold) == -1) {
         if(MyError() != 1) return(0);
         OK = False;
         continue;   }
      OK = True;
      NeedUpdateTP = True;
      return(0);   }
   if(OK)   break;
}
if(NeedUpdateTP)  {
   double   TPSell = 0.0, TPBuy = 0.0;
   if(Target == 0)   {
      TPSell = TPvsTrend;  TPBuy = TPvsTrend;   }
   if(Target > 0) {
      TPSell = TPvsTrend;  TPBuy = TPTrend;   }
   if(Target < 0) {
      TPSell = TPTrend;  TPBuy = TPvsTrend;   }
   if(OSell > 0)  TPSell = NormalizeDouble(AvgSell/SellLots - TPSell, sDigits);
      else  TPSell = NormalizeDouble(sAsk - TPvsTrend, sDigits);
   if(OBuy > 0)  TPBuy = NormalizeDouble(AvgBuy/BuyLots + TPBuy, sDigits);
      else  TPBuy = NormalizeDouble(sBid + TPvsTrend, sDigits);
   if(OSell > 0 && TPSell >= sAsk) TPSell = NormalizeDouble(sAsk - TPvsTrend, sDigits);
   if(OBuy > 0 && TPBuy <= sBid) TPBuy = NormalizeDouble(sBid + TPvsTrend, sDigits);
   for(na = 0;na < Attempt;na++) {
      OK = True;
      for(i = 0;i <  Total; i++) {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false) {
            OK = False;
            continue;   }
         OMN = OrderMagicNumber();
         if(OrderSymbol() != sy) continue;
         if(Magic2 != -1 && Magic != OMN && Magic2 != OMN) continue;
         OType = OrderType();
         if(OType != OP_BUY && OType != OP_SELL)   continue;
         bool  lOK = True;
         if(OType == OP_SELL && OrderTakeProfit() != TPSell)   lOK = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), TPSell, 0, CLR_NONE);
         if(OType == OP_BUY && OrderTakeProfit() != TPBuy)   lOK = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), TPBuy, 0, CLR_NONE);
         if(!lOK)  {
            if(MyError() != 1) {
               NeedUpdateTP = True;
               return(0); } }
         if(OK && lOK)   OK = True;
            else  OK = False;
         }
   if(OK)   {
      NeedUpdateTP = False;
      break;   }
   }
}
return(0);
}


#include <stdlib.mqh>
int MyError()
{
int Error = GetLastError();
switch(Error)
{
   case 0: return(0);
   case 4066: if(NeedLog > 3) Print(ErrorDescription(Error));
      Sleep(SleepForWait);
      RefreshRates();
      return(1);
   case 4: if(NeedLog > 3) Print(ErrorDescription(Error));
      while(!IsTradeAllowed())   {
         Sleep(SleepForWait);
         RefreshRates();   }
      return(1);
   case 135:if(NeedLog > 3) Print(ErrorDescription(Error));
      RefreshRates();
      return(1);
   case 136:if(NeedLog > 3) Print(ErrorDescription(Error));
      while(!RefreshRates())
         Sleep(1);
      return(1);
   case 137:if(NeedLog > 3) Print(ErrorDescription(Error));
      while(!IsTradeAllowed())   {
         Sleep(SleepForWait);
         RefreshRates();   }
      return(1);
   case 146:if(NeedLog > 3) Print(ErrorDescription(Error));
      while(!IsTradeAllowed())   {
         Sleep(SleepForWait);
         RefreshRates();   }
      return(1);
   default: if(NeedLog > 0) Print(ErrorDescription(Error));
      return(0);
}
}

double Lots(double   inGoneLots, int   inGonePips, int   inPipsNoRollback = 0, string  insymbol = "")  {
string sy = insymbol;
if(sy == "")  sy  = Symbol();
int   SL = inPipsNoRollback;
double   sPoint = MarketInfo(sy,MODE_POINT);
double   MinLot = MarketInfo(sy, MODE_MINLOT);
double   MaxLot = MarketInfo(sy, MODE_MAXLOT);
double   LotStep = MarketInfo(sy, MODE_LOTSTEP);
double   MR = MarketInfo(sy,MODE_MARGINREQUIRED);
double   TV = MarketInfo(sy,MODE_TICKVALUE);
if(SL == 0) SL = MathMax(iATR(sy,PERIOD_W1,12,0),iATR(sy,PERIOD_W1,12,1))/sPoint;
if(inGonePips >= SL) {
   Print("Pair: ", sy, " , GonePips > SL!");
   Print("GoneLot=", inGoneLots, " ,GonePips=",  inGonePips, " ,PipsNoRollback=", SL, ", symbol = ", insymbol);
   return(0.0);   }
double   k = Risk * 0.01 / (SL * TV);
double   MaxLots = AccountFreeMargin() * k / (1.0 + MR * k);
if(MaxLots < inGoneLots) {
   Print("Pair: ", sy, " , GoneLot > MaxLots!");
   return(0.0);   }
double   l = inGonePips * MaxLots / (SL - inGonePips);
if(l > MaxLots) l = MaxLots;
double   Lot = l - inGoneLots;
if(Lot <= 0.0) return(0.0);
Lot = LotStep * NormalizeDouble(Lot/LotStep, 0);
if(Lot < MinLot)  Lot = 0.0;
if(Lot > MaxLot)  Lot = MaxLot; //Print("GoneLot=", inGoneLot, " ,GonePips=",  inGonePips, " ,PipsNoRollback=", SL, " ,MaxLots=", MaxLots, ", symbol = ", insymbol, " ,Lot = ", Lot);
return(Lot);   }


