//+------------------------------------------------------------------+
//|                                                Volume Arrow.mq4  |
//|                                  Copyright 2016, BestXerof Corp. |
//|                                              bestxerof@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, BestXerof Corp."
#property link      "bestxerof@gmail.com"
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_width1  1
#property indicator_color2 Red
#property indicator_width2  1

#define SIGNAL_BAR 1

double UpBuffer[];
double DnBuffer[];
double NPoint;
int    NDigits                  = 0;
double NDivider                 = 1;
bool   Normalize                = false;

extern bool    UseAlert         = false; // Use Alert
extern bool    ShowStats        = false; // Show Stat Info
extern color   FontColorSymbol  = Red;  // Set Color Symbol
extern color   FontColorPrice   = Blue; // Set Color Price
extern color   FontColorSpread  = Black; // Set Color Spread
extern color   FontColorTime    = Blue; // Set Color Time
extern color   FontColorStats   = Black; // Set Color Statistic
extern int     FontSize         = 14;    // Font Size
extern string  FontFace         = "Pirulen"; // Font Type
extern int     Corner           = 4; // What Main Corner?
extern int     CornerTS         = 3; // What Corner of Time and Spread

static int PrevTime             = 0;
static int PrevSignal           = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DnBuffer);

   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);

   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);

   SetIndexLabel(0,"Buy");
   SetIndexLabel(1,"Sell");

   if(Point==0.00001)
      NPoint=0.0001;
   else if(Point==0.001)
      NPoint=0.01;
   else
      NPoint=Point;

   ObjectCreate("Symbol",OBJ_LABEL,0,0,0);
   ObjectSet("Symbol",OBJPROP_CORNER,Corner);
   ObjectSet("Symbol",OBJPROP_XDISTANCE,5);
   ObjectSet("Symbol",OBJPROP_YDISTANCE,5);

   ObjectCreate("Price",OBJ_LABEL,0,0,0);
   ObjectSet("Price",OBJPROP_CORNER,Corner);
   ObjectSet("Price",OBJPROP_XDISTANCE,5);
   ObjectSet("Price",OBJPROP_YDISTANCE,50);

   ObjectCreate("Spread",OBJ_LABEL,0,0,0);
   ObjectSet("Spread",OBJPROP_CORNER,CornerTS);
   ObjectSet("Spread",OBJPROP_XDISTANCE,5);
   ObjectSet("Spread",OBJPROP_YDISTANCE,95);

   ObjectCreate("Time",OBJ_LABEL,0,0,0);
   ObjectSet("Time",OBJPROP_CORNER,CornerTS);
   ObjectSet("Time",OBJPROP_XDISTANCE,5);
   ObjectSet("Time",OBJPROP_YDISTANCE,125);

   if(ShowStats)
     {
      ObjectCreate("Account Name",OBJ_LABEL,0,0,0);
      ObjectSet("Account Name",OBJPROP_CORNER,Corner);
      ObjectSet("Account Name",OBJPROP_XDISTANCE,5);
      ObjectSet("Account Name",OBJPROP_YDISTANCE,150);

      ObjectCreate("Deposit",OBJ_LABEL,0,0,0);
      ObjectSet("Deposit",OBJPROP_CORNER,Corner);
      ObjectSet("Deposit",OBJPROP_XDISTANCE,5);
      ObjectSet("Deposit",OBJPROP_YDISTANCE,170);

      ObjectCreate("Balance",OBJ_LABEL,0,0,0);
      ObjectSet("Balance",OBJPROP_CORNER,Corner);
      ObjectSet("Balance",OBJPROP_XDISTANCE,5);
      ObjectSet("Balance",OBJPROP_YDISTANCE,190);

      ObjectCreate("Profit",OBJ_LABEL,0,0,0);
      ObjectSet("Profit",OBJPROP_CORNER,Corner);
      ObjectSet("Profit",OBJPROP_XDISTANCE,5);
      ObjectSet("Profit",OBJPROP_YDISTANCE,210);

      ObjectCreate("Position",OBJ_LABEL,0,0,0);
      ObjectSet("Position",OBJPROP_CORNER,Corner);
      ObjectSet("Position",OBJPROP_XDISTANCE,5);
      ObjectSet("Position",OBJPROP_YDISTANCE,230);

      ObjectCreate("Equity",OBJ_LABEL,0,0,0);
      ObjectSet("Equity",OBJPROP_CORNER,Corner);
      ObjectSet("Equity",OBJPROP_XDISTANCE,5);
      ObjectSet("Equity",OBJPROP_YDISTANCE,250);
     }

   if((NPoint>Point) && (Normalize))
     {
      NDivider= 10.0;
      NDigits = 1;
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("Spread");
   ObjectDelete("Time");
   ObjectDelete("Symbol");
   ObjectDelete("Price");
   ObjectDelete("Account Name");
   ObjectDelete("Deposit");
   ObjectDelete("Balance");
   ObjectDelete("Profit");
   ObjectDelete("Position");
   ObjectDelete("Equity");

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   RefreshRates();

//---declare variables

   double Spread=(Ask-Bid)/Point;
   string Percnt;
   string Position;
   string Equity;
   double AccBal=AccountBalance();
   int i;
   int NCountedBars=IndicatorCounted();
   int HistoryProcess=1000;
   string Number=DoubleToStr(AccountNumber(),0);

//---check division by zero

   if(GetDeposit()!=0 && GetProfit()!=0)
     {
      Percnt=DoubleToStr(GetProfit()/GetDeposit()*100,2);
     }
   else
      Percnt=DoubleToStr(0);

   if(AccBal==0)
      Position=DoubleToStr(0);
   else
      Position=DoubleToStr((AccountEquity()/AccBal-1)*100,2);
   if(GetDeposit()!=0)
      Equity=DoubleToStr((AccountEquity()/GetDeposit()-1)*100,2);
   else
      Equity=DoubleToStr(0);

//---object creation

   ObjectSetText("Spread","Spread: "+DoubleToStr(NormalizeDouble(Spread/NDivider,1),NDigits)+" points",FontSize,FontFace,FontColorSpread);
   ObjectSetText("Time","Time: "+TimeToStr(((Period()*60) -(TimeCurrent()-Time[0])),TIME_SECONDS),FontSize,FontFace,FontColorTime);
   ObjectSetText("Symbol",""+Symbol()+GetPeriod(),28,FontFace,FontColorSymbol);

   if(Symbol()=="EURJPY" || Symbol()=="GBPJPY" || Symbol()=="USDJPY" || Symbol()=="XAUUSD" || Symbol()=="AUDJPY")
      ObjectSetText("Price",""+DoubleToStr(NormalizeDouble(Bid,Digits),3),26,FontFace,FontColorPrice);
   else
      ObjectSetText("Price",""+DoubleToStr(NormalizeDouble(Bid,Digits),5),26,FontFace,FontColorPrice);
   if(ShowStats)
     {
      ObjectSetText("Account Name","Name: "+AccountName()+" "+Number+" | "+" ("+AccountCurrency()+")",9,FontFace,FontColorStats);
      ObjectSetText("Deposit","Deposit: "+DoubleToStr(GetDeposit(),2)+" | "+" ("+AccountCurrency()+") ",9,FontFace,FontColorStats);
      ObjectSetText("Balance","Balance: "+DoubleToStr(AccBal,2)+" | "+Percnt+" % ",9,FontFace,FontColorStats);
      ObjectSetText("Profit","Profit: "+DoubleToStr(GetProfit(),2)+" | "+" ("+AccountCurrency()+") ",9,FontFace,FontColorStats);
      ObjectSetText("Position","Position: "+DoubleToStr(AccountEquity()-AccountBalance(),2)+" | "+Position+" % ",9,FontFace,FontColorStats);
      ObjectSetText("Equity","Equity: "+DoubleToStr(AccountEquity(),2)+" | "+Equity+" % ",9,FontFace,FontColorStats);
     }
     
//---bars calculation
     
   i=Bars-NCountedBars-1;

   if(i>HistoryProcess-1)
      i=HistoryProcess-1;

   while(i>=0)
     {
      UpBuffer[i] = 0;
      DnBuffer[i] = 0;

      //---call indicator BetterVolume 1.4

      double VOLBuy=iCustom(Symbol(),0,"BetterVolume1.4",0,i);
      double VOLSell=iCustom(Symbol(),0,"BetterVolume1.4",4,i);

      // SELL SIGNAL
      if(Open[i]<Close[i] && VOLBuy!=0)
         DnBuffer[i]=High[i]+30*MarketInfo(Symbol(),MODE_POINT);
      if(Open[i]<Close[i] && VOLSell!=0)
         DnBuffer[i]=High[i]+30*MarketInfo(Symbol(),MODE_POINT);

      // BUY SIGNAL
      if(Open[i]>Close[i] && VOLSell!=0)
         UpBuffer[i]=Low[i]-30*MarketInfo(Symbol(),MODE_POINT);
      if(Open[i]>Close[i] && VOLBuy!=0)
         UpBuffer[i]=Low[i]-30*MarketInfo(Symbol(),MODE_POINT);
      i--;
     }

// USE ALERT

   if(SIGNAL_BAR>0 && Time[0]<=PrevTime)
      return(0);

   PrevTime=(int)Time[0];

   if(PrevSignal<=0 && UseAlert==true)
     {
      if(Close[SIGNAL_BAR]-UpBuffer[SIGNAL_BAR]>0)
        {
         PrevSignal=1;
         Alert("Signal ",Symbol(),GetPeriod()," -  BUY!!!");
        }
     }
   if(PrevSignal>=0 && UseAlert==true)
     {
      if(DnBuffer[SIGNAL_BAR]-Close[SIGNAL_BAR]>0)
        {
         PrevSignal=-1;
         Alert("Signal ",Symbol(),GetPeriod()," -  SELL!!!");
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
//| Function calculation timeframe                                   |
//+------------------------------------------------------------------+
string GetPeriod()
  {
   string DrawTF;

   switch(Period())
     {
      case 1:
         DrawTF=" M1";
         break;
      case 5:
         DrawTF=" M5";
         break;
      case 15:
         DrawTF=" M15";
         break;
      case 30:
         DrawTF=" M30";
         break;
      case 60:
         DrawTF=" H1";
         break;
      case 240:
         DrawTF=" H4";
         break;
      case 1440:
         DrawTF=" D1";
         break;
      case 10080:
         DrawTF=" W1";
         break;
      case 43200:
         DrawTF=" MN";
         break;
     }
   return(DrawTF);
  }
//+------------------------------------------------------------------+
//| Deposit calculation function                                     |
//+------------------------------------------------------------------+
double GetDeposit()
  {
   double NOrderSelect,Deposit=0.0;
   for(int d=0; d<OrdersHistoryTotal(); d++)
     {
      NOrderSelect=OrderSelect(d,SELECT_BY_POS,MODE_HISTORY);

      if(OrderType()==6 && OrderProfit()>0)
         Deposit+=OrderProfit();
     }
   return(Deposit);
  }
//+------------------------------------------------------------------+
//| The function of calculating the profit                           |
//+------------------------------------------------------------------+
double GetProfit()
  {
   double NOrderSelect,Profit=0.0;
   for(int p=0; p<OrdersHistoryTotal(); p++)
     {
      NOrderSelect=OrderSelect(p,SELECT_BY_POS,MODE_HISTORY);

      if(OrderType()<2)
         Profit+=OrderProfit()+OrderSwap()+OrderCommission();
     }
   return(Profit);
  }
//+------------------------------------------------------------------+
