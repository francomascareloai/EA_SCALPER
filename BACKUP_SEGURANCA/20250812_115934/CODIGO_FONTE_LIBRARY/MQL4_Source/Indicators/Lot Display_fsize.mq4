//+------------------------------------------------------------------+
//|                                                   lot profit.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Jai Sri Ram"
#property link      ""
#property description ""
#property version   ""
#property strict
#property indicator_chart_window

input int font_size = 10;      //Font size
//+------------------------------------------------------------------+
string val;
//+------------------------------------------------------------------+
int OnInit()
  {
   val=" "+AccountCurrency();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   double Profit=0,ProfitB=0,ProfitS=0;
   double LotB=0,LotS=0;
   int i,b=0,s=0,tip;
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol())
           {
            tip=OrderType();
            if(tip==OP_BUY)
              {
               ProfitB+=OrderProfit()+OrderSwap()+OrderCommission();
               LotB+=OrderLots();
               b++;
              }
            if(tip==OP_SELL)
              {
               ProfitS+=OrderProfit()+OrderSwap()+OrderCommission();
               LotS+=OrderLots();
               s++;
              }
           }
        }
     }
   DrawLABEL("cm buy Lot"     ,StringConcatenate("Buy Lot Size:   " ,DoubleToStr(LotB,2)," :"),100,20,LotB>0?clrDarkBlue:clrDarkBlue);
   DrawLABEL("cm sell Lot"    ,StringConcatenate("Sell Lot Size:   ",DoubleToStr(LotS,2)," :"),100,35,LotS>0?clrGreen:clrBlack);
   DrawLABEL("cm buy Profit"  ,StringConcatenate(DoubleToStr(ProfitB,2),val),10,20,ProfitB>0?clrGreen:clrRed);
   DrawLABEL("cm sell Profit" ,StringConcatenate(DoubleToStr(ProfitS,2),val),10,35,ProfitS>0?clrGreen:clrRed);
   return(rates_total);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,"cm");
  }
//+------------------------------------------------------------------+
void DrawLABEL(string name,string Name,int X,int Y,color clr)
  {
   if(ObjectFind(name)==-1)
     {
      ObjectCreate(name,OBJ_LABEL,0,0,0);
      ObjectSet(name,OBJPROP_CORNER,1);
      ObjectSet(name,OBJPROP_XDISTANCE,X);
      ObjectSet(name,OBJPROP_YDISTANCE,Y);
     }
   ObjectSetText(name,Name,font_size,"Arial",clr);
  }
//--------------------------------------------------------------------
