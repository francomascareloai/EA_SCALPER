//+------------------------------------------------------------------+
//|                                            RoNz Rapid-Fire EA.mq4|
//|                                   Copyright 2014, Rony Nofrianto |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Rony Nofrianto"
#property link      ""
#property version   "1.01"
#property strict

// v1.03
// + Fixed not closing order on trend close option
// + Added Lot Risk Option
// + Fixed Lot Minimum/Maximum/Step

#define MAGICMA  19841129
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_LOTTYPE
  {
   LOTS_FIXED=0,//Fixed Lots
   LOTS_MAXRISK=1,//Risk Based Lots
   LOTS_DECREASE=2, //Decrease Lots When Loss
   LOTS_INCREASE=3, //Increase Lots When Loss
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CLOSETYPE
  {
   SL_Close=0,TrendClose=1
  };

input double inpLots=0.01;//Lots
extern ENUM_LOTTYPE inpLotsMode=LOTS_MAXRISK;//Lots Type
input double inpMaximumLotRisk   =0.02;
input double DecreaseFactor=1;
input int    StopLoss=150;
input int    TakeProfit=100;
input int    TrailingStop=0;
input bool    Averaging=false; //Use Averaging
input int    MAPeriod=60;
input double    PSARStep=0.02;
input double    PSARMax=0.2;
input ENUM_CLOSETYPE   CloseType=SL_Close;    //Close Type
sinput ENUM_APPLIED_PRICE AppliedPrice=PRICE_CLOSE;
sinput ENUM_MA_METHOD Method=MODE_SMA;

double InitialBalance=0;
string LotType="";
int PipRisk=1000;
int inpLotsFactor=1;
//+------------------------------------------------------------------+
//| Hitung Posisi Buka                                               |
//+------------------------------------------------------------------+
int CalculateCurrentOrders()
  {
   int TotalOrder=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         TotalOrder++;
        }
     }
   return TotalOrder;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OptimalLots()
  {
   double LotStep=MarketInfo(NULL,MODE_LOTSTEP);//Lot Step
   double MinLots=MarketInfo(NULL,MODE_MINLOT);//Minimum Lots
   double MaxLots=MarketInfo(NULL,MODE_MAXLOT);//Maximal Lots

   double lot=inpLots;
   int    losses=0;

   if(LotStep!=0)
      lot=MathFloor(lot/LotStep)*MathMod(LotStep,lot);

   if(lot<MinLots) lot=MinLots;

   if(inpLotsMode==LOTS_FIXED)
     {
      LotType="Fixed";
      return lot;
     }

   lot=NormalizeDouble((AccountFreeMargin()*(inpMaximumLotRisk/100))/PipRisk,2);
   lot=MathFloor(lot/LotStep)*MathMod(LotStep,lot);
   if(lot<MinLots) lot=MinLots;

   if(inpLotsMode==LOTS_MAXRISK)
     {
      LotType="Risk-Based";
      return lot;
     }

   if(inpLotsFactor>0)
     {

      for(int i=OrdersHistoryTotal()-1;i>=0;i--)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
           {
            Print("Error in history!");
            break;
           }
         if(OrderSymbol()!=Symbol() || OrderMagicNumber()!=MAGICMA || OrderType()>OP_SELL) continue;
         if(OrderProfit()>0) break;
         if(OrderProfit()<0) losses++;
        }

      if(inpLotsMode==LOTS_DECREASE)
        {
         LotType="Dec. Loss";
         if(losses>1)
            lot=NormalizeDouble(lot-(lot*losses/inpLotsFactor),2);
        }

      if(inpLotsMode==LOTS_INCREASE)
        {
         LotType="Inc. Loss";
         if(losses>1)
            lot=NormalizeDouble(lot+(lot*losses/inpLotsFactor),2);
        }

     }

   lot=MathFloor(lot/LotStep)*MathMod(LotStep,lot);
   if(lot<MinLots) lot=MinLots;

   return(lot);
  }
//--- Fungsi Analisa Trend
int AnalisaTrend(string mode,int opType)
  {
   int val=0;
   string msg;

   double iMa=iMA(NULL,0,MAPeriod,0,Method,AppliedPrice,0);
   double pSAR=iSAR(NULL,0,PSARStep,PSARMax,1);
   double SAR=iSAR(NULL,0,PSARStep,PSARMax,0);

//Indikator MA      
   bool iRZI_Buy=(Close[0]>iMa) && SAR<Close[0] && pSAR>Close[0];
   bool iRZI_Sell=(Close[0]<iMa) && SAR>Close[0] && pSAR<Close[0];

//Kombinasi strategi
   bool Uptrend=iRZI_Buy;
   bool Downtrend=iRZI_Sell;
   bool EndofUptrend,EndofDowntrend;

//Gunakan End of Trend jika StopLoss tidak diatur
   if(CloseType==TrendClose)
     {
      EndofUptrend=iRZI_Sell;
      EndofDowntrend=iRZI_Buy;
     }
   else if(CloseType==SL_Close)
     {
      EndofUptrend=false;
      EndofDowntrend=false;
     }

   msg=StringConcatenate(
                         " Bid/Ask [",NormalizeDouble(Bid,Digits()),"/",NormalizeDouble(Ask,Digits()),"]",
                         //" Volume [",Volume[1],"]",
                         " RZIBuySell [",iRZI_Buy,"|",iRZI_Sell,"]",
                         //" OHLC[1] [",pOpen,"|",pHigh,"|",pLow,"|",pClose,"]",
                         " Bal/Equ [",AccountBalance(),"/",AccountEquity(),"]",
                         "");

   if(opType==-1)
     {
      if(Uptrend)
        {
         Print(mode,": Uptrend dimulai! ",msg);
         val=3;
        }
      else if(Downtrend)
        {
         Print(mode,": Downtrend dimulai! ",msg);
         val=-3;
        }
     }
   else if(opType==OP_BUY)
     {
      if(Uptrend)
        {
         Print(mode,": Uptrend berlanjut! ",msg);
         val=2;
        }

      if(EndofUptrend)
        {
         Print(mode,": Uptrend berakhir! ",msg);
         val=1;
        }
     }
   else if(opType==OP_SELL)
     {
      if(Downtrend)
        {
         Print(mode,": Downtrend berlanjut! ",msg);
         val=-2;
        }
      if(EndofDowntrend)
        {
         Print(mode,": Downtrend berakhir! ",msg);
         val=-1;
        }
     }

   if(val==0)
     {
      //Print(mode,": Tidak ada trend! ",msg);
     }

   return val;
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string SymbolInfo()
  {
   return StringConcatenate("Bid = ", Bid, " Ask = ", Ask, " Spread = ", NormalizeDouble(Ask-Bid, Digits), " High = ", High[0], " Low = ", Low[0]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Jual(double lots,int SL,int TP,string comments)
  {
   double dTakeProfit=0;
   double dStopLoss=0;
//Normalisasi T/P dan S/L untuk Sell
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(SL>0) dStopLoss=NormalizeDouble(Ask+(minstoplevel+SL)*Point,Digits());
   if(TP>0) dTakeProfit=NormalizeDouble(Ask-(minstoplevel+TP)*Point,Digits());
   string PriceControlInfo=StringConcatenate("T/P  = ",dTakeProfit," S/L = ",dStopLoss);

   comments=StringConcatenate("RZ: ",comments);

   Print("Mulai Jual : ",SymbolInfo());
   if(!OrderSend(Symbol(),OP_SELL,lots,Bid,3,dStopLoss,dTakeProfit,comments,MAGICMA,0,Red))
      return 0;
   else
     {
      Print("Jual : Bid = ",Bid," ",PriceControlInfo);
      return 1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Beli(double lots,int SL,int TP,string comments)
  {
   double dTakeProfit=0;
   double dStopLoss=0;
//Normalisasi T/P dan S/L untuk Buy
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(SL>0) dStopLoss=NormalizeDouble(Bid-(minstoplevel+SL)*Point,Digits());
   if(TP>0) dTakeProfit=NormalizeDouble(Bid+(minstoplevel+TP)*Point,Digits());
   string PriceControlInfo=StringConcatenate("T/P  = ",dTakeProfit," S/L = ",dStopLoss);

   comments=StringConcatenate("RZ: ",comments);

   Print("Mulai Beli : ",SymbolInfo());
   if(!OrderSend(Symbol(),OP_BUY,lots,Ask,3,dStopLoss,dTakeProfit,comments,MAGICMA,0,Blue))
      return 0;
   else
     {
      Print("Beli : Ask = ",Ask," ",PriceControlInfo);
      return 1;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TrailStop(int TiketOrder,int JumlahPoin)
  {
   if(OrderSelect(TiketOrder,SELECT_BY_TICKET,MODE_TRADES)==false) return false;
//Hindari Kekurangan Profit yang didapat
   if(JumlahPoin>0)
     {
      int minstoplevel=(int)MarketInfo(Symbol(),MODE_STOPLEVEL);
      JumlahPoin=JumlahPoin+minstoplevel;

      if((OrderType()==OP_BUY) && (Bid-OrderOpenPrice()>Point*JumlahPoin))
        {
         if(OrderStopLoss()<Bid-Point*JumlahPoin)
           {
            Print("BuyTrailingStop: ",NormalizeDouble(Bid-Point*JumlahPoin,Digits()));
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*JumlahPoin,Digits),OrderTakeProfit(),0,Blue);
            if(res == true) return true;
            else return false;
           }
        }

      else if((OrderType()==OP_SELL) && (OrderOpenPrice()-Ask>Point*JumlahPoin))
        {
         if(OrderStopLoss()>Ask+Point*JumlahPoin)
           {
            Print("SellTrailingStop: ",NormalizeDouble(Ask+Point*JumlahPoin,Digits()));
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*JumlahPoin,Digits),OrderTakeProfit(),0,Blue);
            if(res == true) return true;
            else return false;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   RefreshRates();

   int Trend=AnalisaTrend("Analisa Open",-1);

   if(Trend>=3)
     {
      Beli(OptimalLots(),StopLoss,TakeProfit,IntegerToString(Trend));
     }
   else if(Trend<=-3)
     {
      Jual(OptimalLots(),StopLoss,TakeProfit,IntegerToString(Trend));
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckForAveraging()
  {
   if(!Averaging) return;

   int Trend=AnalisaTrend("Analisa Open",-1);

   if(Trend>=2)
     {
      Beli(OptimalLots(),StopLoss,TakeProfit,IntegerToString(Trend));
     }
   else if(Trend<=-2)
     {
      Jual(OptimalLots(),StopLoss,TakeProfit,IntegerToString(Trend));
     }
//---
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
  {
   RefreshRates();

   int Trend=0;

//---   
   for(int i=0;i<OrdersTotal();i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;

      string msgClose=StringConcatenate("Tutup Order. Price : ",OrderOpenPrice()," -> ",OrderClosePrice(),
                                        " Profit : ",OrderProfit());

      Trend=AnalisaTrend("Analisa Close "+(string)OrderType(),OrderType());

      if(OrderType()==OP_BUY && Trend==1)
        {
         Print(msgClose);

         if(!OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue))
            Print("Close Buy Error ",GetLastError());

        }

      if(OrderType()==OP_SELL && Trend==-1)
        {
         Print(msgClose);

         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,Red))
            Print("Sell Close Error ",GetLastError());
        }

      TrailStop(i,TrailingStop);

     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   InitialBalance=AccountBalance();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Bars<100 || IsTradeAllowed()==false)
      return;

   if(CalculateCurrentOrders()==0)
      CheckForOpen();

   CheckForAveraging();

   if(CalculateCurrentOrders()!=0)
      CheckForClose();
//---
  }

//+------------------------------------------------------------------+
