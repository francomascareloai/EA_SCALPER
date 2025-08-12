//+------------------------------------------------------------------+
//|                                                 Basket_Stats.mq4 |
//|                               Copyright © 2011, Patrick M. White |
//|                     https://sites.google.com/site/marketformula/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Patrick M. White"
#property link      "https://sites.google.com/site/marketformula/"
// late edited April 25, 2011
/*
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>.
    
    If you need a commercial license, please send me an email:
    market4mula@gmail.com
*/


#property indicator_chart_window
extern int MagicNumber = -1;
extern string CORNER= "--Screen Corner: 0=upper left, 1=upper right, 2=lower left, 3=lower right--";
extern int corner = 1;
extern string LROffset= "--lroffset = Use multiples of 300+, left or right offset (depending on the corner chosen).--";
extern int lroffset = 0;
extern string TBOffset= "--tboffset = top or bottom offset (depending on corner chosen). A single line height is 14. There are 2 top lines and one summation line + symbols * 14 or 42 + 14*(symbol count)--";
extern int tboffset =0;
double BeginningBalance = 0;
string symbols[30];
string s;
double tottrades, totlots, totopnl, totcpnl;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()


  {
  s = corner;
  s = s + tboffset;
  s = s + lroffset;
  DeleteObjects();
  BeginningBalance = CalcBeginningBalance();
//---- indicators
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   DeleteObjects();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   SetLabel(s+"objTitle", "Magic Number:" + MagicNumber, DarkGray, 250 + lroffset, 11 + tboffset, corner);
   SetLabel(s+"objSymbol", "Symbol", DimGray, 250 + lroffset, 25 + tboffset, corner);
   SetLabel(s+"objTrades", "Trades", DimGray, 200 + lroffset, 25 + tboffset, corner);
   SetLabel(s+"objLots", "Lots", DimGray, 150 + lroffset, 25 + tboffset, corner);
   SetLabel(s+"objOpenPnL", "O PnL", DimGray, 100 + lroffset, 25 + tboffset, corner);
   SetLabel(s+"objClosedPnL", "C PnL", DimGray, 50 + lroffset, 25 + tboffset, corner);
   
   Assign_Symbols();
   totlots =0.0; tottrades = 0.0; totopnl =0.0; totcpnl =0.0;
   for (int i =0; i <=30; i++) {
      if(StringLen(symbols[i])==0) break;
      Output_Row(i, symbols[i]);
   }
   int row = i;
   SetLabel(s+"objSymbol" + row, "Totals", White, 250 + lroffset, 25+ (row + 1)*14 + tboffset, corner);
   SetLabel(s+"objTrades" + row, DoubleToStr(tottrades,0), White, 200 + lroffset, 25 + (row + 1)*14 + tboffset, corner);
   SetLabel(s+"objLots" + row, DoubleToStr(totlots,2), White, 150 + lroffset, 25 + (row + 1)*14 + tboffset, corner);
   SetLabel(s+"objOpenPnL" + row, DoubleToStr(totopnl,2), White, 100 + lroffset, 25 + (row + 1)*14 + tboffset, corner);
   SetLabel(s+"objClosedPnL" + row, DoubleToStr(totcpnl,2), White, 50 + lroffset, 25 + (row + 1)*14 + tboffset, corner);
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

void Output_Row(int row, string sym)
{
   SetLabel(s+"objSymbol" + row, sym, DarkGray, 250 + lroffset, 25 + (row + 1)*14 +tboffset, corner);
   double trades =0;
   double lots = 0.0;
   double opnl = 0.0;
   double cpnl =0.0;
   double clots = 0.0;
   double ctrades = 0;
   int pos = 1, lcolor = DimGray;
   for(int i =0; i < OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && (OrderMagicNumber() == MagicNumber || MagicNumber == -1 ) && OrderSymbol() == sym) {
         opnl += OrderProfit()+OrderCommission()+OrderSwap();
         lots += OrderLots();
         trades +=1;
         if(OrderType() == OP_SELL) pos = -1;
      }
   }
   if (pos == 1) lcolor = Lime;
   if (pos ==-1) lcolor = Red;
   int clr = Lime; if(opnl <0) clr = Red;
   SetLabel(s+"objTrades" + row, DoubleToStr(trades,0), DimGray, 200 + lroffset, 25 + (row + 1)*14 + tboffset, corner);
   SetLabel(s+"objLots" + row, DoubleToStr(lots,2), lcolor, 150 + lroffset, 25 + (row + 1)*14 + tboffset, corner);
   SetLabel(s+"objOpenPnL" + row, DoubleToStr(opnl,2), clr, 100 + lroffset, 25 + (row + 1)*14 + tboffset, corner);
   
   for(i =0; i < OrdersHistoryTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && (OrderMagicNumber() == MagicNumber || MagicNumber == -1) && OrderSymbol() == sym) {
         cpnl += OrderProfit()+OrderCommission()+OrderSwap();
         clots += OrderLots();
         ctrades +=1;
      }
   }
   if (cpnl >=0) lcolor = Lime; else lcolor = Red;
   SetLabel(s+"objClosedPnL" + row, DoubleToStr(cpnl,2), lcolor, 50 + lroffset, 25 + (row + 1)*14 + tboffset, corner);
   tottrades += trades;
   totlots += lots;
   totopnl += opnl;
   totcpnl += cpnl;
}

void Assign_Symbols()
{
   int i =0;
   for (i =0; i < OrdersHistoryTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && (OrderMagicNumber() == MagicNumber || MagicNumber == -1)) {
         for (int k = 0; k<=30; k++) {
            if(OrderSymbol() == symbols[k]) break;
            if(StringLen(symbols[k]) == 0) {
               symbols[k] = OrderSymbol();
               break;
            }
         }
      }
   }
   
   for (i=0; i<OrdersTotal(); i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && (OrderMagicNumber() == MagicNumber || MagicNumber == -1)) {
         for (k = 0; k <=30; k++) {
            if(OrderSymbol() == symbols[k]) break;
            if(StringLen(symbols[k]) == 0) {
               symbols[k] = OrderSymbol();
               break;
            }         
         }
      }
   }
}

double CalcBeginningBalance()
{
   double pips = 0.0;
   for (int i = 0; i < 1; i++) {
      ;
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && (OrderMagicNumber() == MagicNumber || MagicNumber == -1)){
         pips += OrderProfit();
      }
   }
   return(pips);
}

//+--------------------------------------------------------------------------+
//| corner - room corner bindings - (0 - upper left)                         |
//| fontsize - font size - (9 - default)                                     |
//+--------------------------------------------------------------------------+
  void SetLabel(string name, string text, color clr, int xdistance, int ydistance, int corner_=1, int fontsize=9)
  {
   if (ObjectFind(name)==-1) {
      ObjectCreate(name, OBJ_LABEL, 0, 0,0);
      ObjectSet(name, OBJPROP_XDISTANCE, xdistance);
      ObjectSet(name, OBJPROP_YDISTANCE, ydistance);
      ObjectSet(name, OBJPROP_CORNER, corner_);
   }
   ObjectSetText(name, text, fontsize, "Arial", clr);
 
  }
//+--------------------------------------------------------------------------+

  void     DeleteObjects() {
  for(int i=ObjectsTotal()-1; i>-1; i--)
   if (StringFind(ObjectName(i),"obj")>=0)  ObjectDelete(ObjectName(i));  
   Comment("");
 }