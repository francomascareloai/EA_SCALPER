//+------------------------------------------------------------------+
//|                                  Dashboard-Strength Index v2.mq4 |
//|                                              Copyright 2015, GVC |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, GVC"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

#define BullColor Lime
#define BearColor Red


input int    Magic_Number        = 1111;
input double Lot                 = 0.01;
input int  Basket_Target         = 0; 
input int  Basket_StopLoss       = 0; 
input ENUM_TIMEFRAMES TimeFrame  = 1440; //TimeFrame to open chart
extern string usertemplate       = "Dash";
input int   x_axis               =10;
input int   y_axis               =50;

string button_close_basket_All = "btn_Close ALL"; 
string button_close_basket_Prof = "btn_Close Prof";
string button_close_basket_Loss = "btn_Close Loss";; 

struct Pair 
{
   string symbol;
   double pairpip;
   double pips;
   double spread;
   double hi;
   double lo;
   double open;
   double close;
   double point;
   double lots;
   double ask;
   double bid;
   double range;
   double ratio;
   double calc;
   int pipsfactor;
   
};
string Defaultpairs[]={ "AUDCAD","AUDCHF","AUDJPY","AUDNZD","AUDUSD","CADCHF","CADJPY",
                       "CHFJPY","EURAUD","EURCAD","EURCHF","EURGBP","EURJPY",
                       "EURNZD","EURUSD","GBPAUD","GBPCAD","GBPCHF",
                       "GBPJPY","GBPNZD","GBPUSD","NZDCAD",
                       "NZDCHF","NZDJPY","NZDUSD","USDCAD",
                       "USDCHF","USDJPY" };
                       
string curr[8] = {"USD","EUR","GBP","JPY","AUD","NZD","CAD","CHF"};                       
string postfix=StringSubstr(Symbol(),6,4);
string tempsym = "";                              
bool   Accending=true;
int    ticket;
color  tradeColor,LineColor;
double blots[28],slots[28],bprofit[28],sprofit[28],tprofit[28],bpos[28],spos[28],totalprofit,totallots;
Pair list[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  { 
   for(int i=0;i<ArraySize(Defaultpairs);i++)
     {
     Defaultpairs[i]=Defaultpairs[i]+postfix;
     }
   ArrayResize(list,ArraySize(Defaultpairs));
         
   for(int i=0; i<ArraySize(list); i++){
   SetPanel("Bar",0,x_axis,y_axis-45,901,45,clrNavy,LineColor,1); 
   SetPanel("BP",0,x_axis-1,y_axis-3,900,451,C'10,10,10',C'61,61,61',1); 
   SetPanel("A1"+IntegerToString(i),0,x_axis,(i*16)+y_axis-2,230,17,C'10,10,10',C'61,61,61',1);
   SetPanel("A2"+IntegerToString(i),0,x_axis+590,(i*16)+y_axis-2,308,17,C'10,10,10',C'61,61,61',1);
   SetPanel("TP",0,x_axis+805,y_axis-35,85,30,Black,White,1);
   SetPanel("TP1",0,x_axis+400,y_axis+150,115,30,Black,White,1);
   SetPanel("TP2",0,x_axis+400,y_axis+200,115,30,Black,White,1);  
           
   SetText("Pair"+IntegerToString(i),list[i].symbol,x_axis,(i*16)+y_axis+2,Colorstr(list[i].ratio),8);
   SetText("Spr1"+IntegerToString(i),DoubleToStr(list[i].spread,1),x_axis+70,(i*16)+y_axis,Orange,8);
   SetText("Pp1"+IntegerToString(i),DoubleToStr(MathAbs(list[i].pips),0),x_axis+95,(i*16)+y_axis,ColorPips(list[i].pips),8);
   SetText("fxs"+IntegerToString(i),DoubleToStr(MathAbs(list[i].ratio),1)+"%",x_axis+190,(i*16)+y_axis,Colorstr(list[i].ratio),8);
   SetText("bLots"+IntegerToString(i),DoubleToStr(blots[i],2),x_axis+600,(i*16)+y_axis,Colorstr(blots[i]),8);
   SetText("sLots"+IntegerToString(i),DoubleToStr(slots[i],2),x_axis+640,(i*16)+y_axis,Colorstr(slots[i]),8);
   SetText("bPos"+IntegerToString(i),DoubleToStr(bpos[i],0),x_axis+680,(i*16)+y_axis,Colorstr(bpos[i]),8);
   SetText("sPos"+IntegerToString(i),DoubleToStr(spos[i],0),x_axis+700,(i*16)+y_axis,Colorstr(spos[i]),8);
   SetText("TProf"+IntegerToString(i),DoubleToStr(MathAbs(bprofit[i]),2),x_axis+730,(i*16)+y_axis,ColorPips(bprofit[i]),8);
   SetText("SProf"+IntegerToString(i),DoubleToStr(MathAbs(sprofit[i]),2),x_axis+770,(i*16)+y_axis,ColorPips(sprofit[i]),8);
   SetText("TtlProf"+IntegerToString(i),DoubleToStr(MathAbs(tprofit[i]),2),x_axis+820,(i*16)+y_axis,ColorPips(tprofit[i]),8);
   SetText("TotProf",DoubleToStr(MathAbs(totalprofit),2),x_axis+808,y_axis-30,ColorPips(totalprofit),12);
   SetText("Symbol","Symbol        Sprd  Pips",x_axis+4,y_axis-20,White,8);
   SetText("Direct","Strength Meter",x_axis+140,y_axis-20,White,8);
   SetText("Trades","Buy       Sell     Buy  Sell      Buy      Sell",x_axis+600,y_axis-17,White,8);
   SetText("TTr","Lots           Orders",x_axis+620,y_axis-30,White,8);
   SetText("TPr","Basket TakeProfit",x_axis+410,y_axis+150,Yellow,9);
   SetText("TPr1","$ "+DoubleToStr(Basket_Target,0),x_axis+440,y_axis+165,Yellow,9);
   SetText("SL","Basket StopLoss",x_axis+410,y_axis+200,Yellow,9);
   SetText("SL1","$ -"+DoubleToStr(Basket_StopLoss,0),x_axis+440,y_axis+215,Yellow,9); 
   
   
   } 
   
//--- create timer
   EventSetTimer(1);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   ObjectsDeleteAll();    
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
  displayMeter();
  Trades();
  TradeManager(); 
  get_list_status(list); 
 for(int i=0; i<ArraySize(list); i++){ 
  
  
   SetText("Pair"+IntegerToString(i),list[i].symbol,x_axis,(i*16)+y_axis+2,Colorstr(list[i].ratio),8);
   SetText("Spr1"+IntegerToString(i),DoubleToStr(list[i].spread,1),x_axis+70,(i*16)+y_axis,Orange,8);
   SetText("Pp1"+IntegerToString(i),DoubleToStr(MathAbs(list[i].pips),0),x_axis+95,(i*16)+y_axis,ColorPips(list[i].pips),8);
   SetText("fxs"+IntegerToString(i),DoubleToStr(MathAbs(list[i].ratio),1)+"%",x_axis+190,(i*16)+y_axis,Colorstr(list[i].ratio),8);
   SetText("bLots"+IntegerToString(i),DoubleToStr(blots[i],2),x_axis+600,(i*16)+y_axis,Colorstr(blots[i]),8);
   SetText("sLots"+IntegerToString(i),DoubleToStr(slots[i],2),x_axis+640,(i*16)+y_axis,Colorstr(slots[i]),8);
   SetText("bPos"+IntegerToString(i),DoubleToStr(bpos[i],0),x_axis+680,(i*16)+y_axis,Colorstr(bpos[i]),8);
   SetText("sPos"+IntegerToString(i),DoubleToStr(spos[i],0),x_axis+700,(i*16)+y_axis,Colorstr(spos[i]),8);
   SetText("TProf"+IntegerToString(i),DoubleToStr(MathAbs(bprofit[i]),2),x_axis+730,(i*16)+y_axis,ColorPips(bprofit[i]),8);
   SetText("SProf"+IntegerToString(i),DoubleToStr(MathAbs(sprofit[i]),2),x_axis+770,(i*16)+y_axis,ColorPips(sprofit[i]),8);
   SetText("TtlProf"+IntegerToString(i),DoubleToStr(MathAbs(tprofit[i]),2),x_axis+820,(i*16)+y_axis,ColorPips(tprofit[i]),8);
   SetText("TotProf",DoubleToStr(MathAbs(totalprofit),2),x_axis+808,y_axis-30,ColorPips(totalprofit),12);
   SetText("Symbol","Symbol        Sprd  Pips",x_axis+4,y_axis-20,White,8);
   SetText("Direct","Strength Meter",x_axis+140,y_axis-20,White,8);
   SetText("Trades","Buy       Sell     Buy  Sell      Buy      Sell",x_axis+600,y_axis-17,White,8);
   SetText("TTr","Lots           Orders",x_axis+620,y_axis-30,White,8);
   SetText("TPr","Basket TakeProfit",x_axis+410,y_axis+150,Yellow,9);
   SetText("TPr1","$ "+DoubleToStr(Basket_Target,0),x_axis+440,y_axis+165,Yellow,9);
   SetText("SL","Basket StopLoss",x_axis+410,y_axis+200,Yellow,9);
   SetText("SL1","$ -"+DoubleToStr(Basket_StopLoss,0),x_axis+440,y_axis+215,Yellow,9);  
   
   if(list[i].ratio>0){SetObjText("Sig"+IntegerToString(i),CharToStr(217),x_axis+130,(i*16)+y_axis,clrDodgerBlue,12);}
   else if(list[i].ratio<0){SetObjText("Sig"+IntegerToString(i),CharToStr(218),x_axis+130,(i*16)+y_axis,clrFireBrick,12);}
   for(int b=0; b<=list[i].calc-1; b++){
   ObjectDelete("fx1"+IntegerToString(i)+IntegerToString(b));   
   if(list[i].ratio>0){SetText("fx1"+IntegerToString(i)+IntegerToString(b),"|",(b*3)+x_axis+150,(i*16)+y_axis,clrDodgerBlue,8);}
   else if(list[i].ratio<0){SetText("fx1"+IntegerToString(i)+IntegerToString(b),"|",(b*3)+x_axis+150,(i*16)+y_axis,clrFireBrick,8);}
   }
   
   Create_Button(IntegerToString(i)+"Pair",Defaultpairs[i],70 ,15,x_axis+525 ,(i*16)+y_axis,clrDarkGray,LineColor);
   Create_Button(IntegerToString(i)+"BUY","BUY",50 ,15,x_axis+230,(i*16)+y_axis,clrRoyalBlue,clrWhite);           
   Create_Button(IntegerToString(i)+"SELL","SELL",50 ,15,x_axis+285 ,(i*16)+y_axis,clrGoldenrod,clrWhite);
   Create_Button(IntegerToString(i)+"CLOSE","CLOSE",50 ,15,x_axis+340 ,(i*16)+y_axis,clrRed,clrWhite); 
   Create_Button(button_close_basket_All,"CLOSE ALL",90 ,18,x_axis+330 ,y_axis-35,clrDarkGray,clrRed);
   Create_Button(button_close_basket_Prof,"CLOSE PROFIT",90 ,18,x_axis+230 ,y_axis-45,clrDarkGray,clrRed);
   Create_Button(button_close_basket_Loss,"CLOSE LOSS",90 ,18,x_axis+230 ,y_axis-23,clrDarkGray,clrRed);
  }
  ChartRedraw();
  }

//-----------------------------------------------------------------------+    
void get_list_status(Pair &this_list[]) 
  {
   
   ArrayResize(this_list,ArraySize(Defaultpairs));
   for(int i=0; i<ArraySize(this_list); i++)   
     {
      this_list[i].symbol=Defaultpairs[i];      
      this_list[i].point=MarketInfo(this_list[i].symbol,MODE_POINT);       
      this_list[i].open=iOpen(this_list[i].symbol,PERIOD_D1,0);      
      this_list[i].close=iClose(this_list[i].symbol,PERIOD_D1,0);
      this_list[i].hi=MarketInfo(this_list[i].symbol,MODE_HIGH);
      this_list[i].lo=MarketInfo(this_list[i].symbol,MODE_LOW);
      this_list[i].ask=MarketInfo(this_list[i].symbol,MODE_ASK);
      this_list[i].bid=MarketInfo(this_list[i].symbol,MODE_BID);
      
      
      if(this_list[i].point==0.0001 || this_list[i].point==0.01)
      this_list[i].pipsfactor=1;
      if(this_list[i].point==0.00001 || this_list[i].point==0.001)
      this_list[i].pipsfactor=10;
      if(this_list[i].point !=0 && this_list[i].pipsfactor != 0){ 
      this_list[i].spread=MarketInfo(this_list[i].symbol,MODE_SPREAD)/this_list[i].pipsfactor;
      this_list[i].pips=(this_list[i].close-this_list[i].open)/this_list[i].point/this_list[i].pipsfactor;
      } 
      if(this_list[i].open>this_list[i].close) {       
      this_list[i].range=(this_list[i].hi-this_list[i].lo)*this_list[i].point;      
      this_list[i].ratio=MathMin((this_list[i].hi-this_list[i].close)/this_list[i].range*this_list[i].point/ (-0.01),100);
      this_list[i].calc=this_list[i].ratio/(-10);
      
      }
      else if(this_list[i].range !=0 ){
      this_list[i].range=(this_list[i].hi-this_list[i].lo)*this_list[i].point; 
      this_list[i].ratio=MathMin(100*(this_list[i].close-this_list[i].lo)/this_list[i].range*this_list[i].point,100);
      this_list[i].calc=this_list[i].ratio/10;
      
     }
      WindowRedraw();   
   }
// SORT THE TABLE!!!
   for(int i=0; i<ArraySize(this_list); i++)
      for(int j=i; j<ArraySize(this_list); j++) 
        {
         if(!Accending) 
           {
            if(this_list[j].ratio<this_list[i].ratio)
               swap(this_list[i],this_list[j]);
              } else {
            if(this_list[j].ratio>this_list[i].ratio)
               swap(this_list[i],this_list[j]);
           }
        }

 
  }   
  
//+------------------------------------------------------------------+

void SetText(string name,string text,int x,int y,color colour,int fontsize=12)
  {
   ObjectDelete(0,name);
   if(ObjectCreate(0,name,OBJ_LABEL,0,0,0))
     {
      
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
  }
//+------------------------------------------------------------------+

void SetObjText(string name,string CharToStr,int x,int y,color colour,int fontsize=12)
  {
   ObjectDelete(0,name);
   if(ObjectCreate(0,name,OBJ_LABEL,0,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,name,OBJPROP_COLOR,colour);
      ObjectSetInteger(0,name,OBJPROP_BACK,false);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
     }
  ObjectSetString(0,name,OBJPROP_TEXT,CharToStr);
  ObjectSetString(0,name,OBJPROP_FONT,"Wingdings");
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetPanel(string name,int sub_window,int x,int y,int width,int height,color bg_color,color border_clr,int border_width)
  {
   if(ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
      ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
     }
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
  }
//+------------------------------------------------------------------+
void Create_Button(string but_name,string label,int xsize,int ysize,int xdist,int ydist,int bcolor,int fcolor)
{
   if(ObjectFind(0,but_name)<0)
   {
      if(!ObjectCreate(0,but_name,OBJ_BUTTON,0,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",GetLastError());
         return;
        }
      ObjectSetString(0,but_name,OBJPROP_TEXT,label);
      ObjectSetInteger(0,but_name,OBJPROP_XSIZE,xsize);
      ObjectSetInteger(0,but_name,OBJPROP_YSIZE,ysize);
      ObjectSetInteger(0,but_name,OBJPROP_CORNER,CORNER_LEFT_UPPER);     
      ObjectSetInteger(0,but_name,OBJPROP_XDISTANCE,xdist);      
      ObjectSetInteger(0,but_name,OBJPROP_YDISTANCE,ydist);         
      ObjectSetInteger(0,but_name,OBJPROP_BGCOLOR,bcolor);
      ObjectSetInteger(0,but_name,OBJPROP_COLOR,fcolor);
      ObjectSetInteger(0,but_name,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,but_name,OBJPROP_HIDDEN,true);
      //ObjectSetInteger(0,but_name,OBJPROP_BORDER_COLOR,ChartGetInteger(0,CHART_COLOR_FOREGROUND));
      ObjectSetInteger(0,but_name,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      
      ChartRedraw();      
   }

}           
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
  if(id==CHARTEVENT_OBJECT_CLICK)
  
      {
      if (sparam==button_close_basket_All)
        {
               ObjectSetString(0,button_close_basket_All,OBJPROP_TEXT,"Closing...");               
               close_basket(Magic_Number);
               ObjectSetInteger(0,button_close_basket_All,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_All,OBJPROP_TEXT,"Close Basket"); 
               return;
        }
//-----------------------------------------------------------------------------------------------------------------     
      if (sparam==button_close_basket_Prof)
        {
               ObjectSetString(0,button_close_basket_Prof,OBJPROP_TEXT,"Closing...");               
               close_profit();
               ObjectSetInteger(0,button_close_basket_Prof,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_Prof,OBJPROP_TEXT,"Close Basket"); 
               return;
        }
//----------------------------------------------------------------------------------------------------------------- 
      if (sparam==button_close_basket_Loss)
        {
               ObjectSetString(0,button_close_basket_Loss,OBJPROP_TEXT,"Closing...");               
               close_loss();
               ObjectSetInteger(0,button_close_basket_Loss,OBJPROP_STATE,0);
               ObjectSetString(0,button_close_basket_Loss,OBJPROP_TEXT,"Close Basket"); 
               return;
        }
//-----------------------------------------------------------------------------------------------------------------
     if (StringFind(sparam,"BUY") >= 0)
        {
               int ind = StringToInteger(sparam);
               ticket=OrderSend(list[ind].symbol,OP_BUY,Lot,MarketInfo(list[ind].symbol,MODE_ASK),100,0,0,"OFF",Magic_Number,0,Blue);
               ObjectSetInteger(0,ind+"BUY",OBJPROP_STATE,0);
               ObjectSetString(0,ind+"BUY",OBJPROP_TEXT,"BUY"); 
               return;
        }
     if (StringFind(sparam,"SELL") >= 0)
        {
               int ind = StringToInteger(sparam);
               ticket=OrderSend(list[ind].symbol,OP_SELL,Lot,MarketInfo(list[ind].symbol,MODE_BID),100,0,0,"OFF",Magic_Number,0,Red);
               ObjectSetInteger(0,ind+"SELL",OBJPROP_STATE,0);
               ObjectSetString(0,ind+"SELL",OBJPROP_TEXT,"SELL");
               return;
        }
     if (StringFind(sparam,"CLOSE") >= 0)
        {
               int ind = StringToInteger(sparam);
               closeOpenOrders(list[ind].symbol);               
               ObjectSetInteger(0,ind+"CLOSE",OBJPROP_STATE,0);
               ObjectSetString(0,ind+"CLOSE",OBJPROP_TEXT,"CLOSE");
               return;
        }
         
      if (StringFind(sparam,"Pair") >= 0) {
         int ind = StringToInteger(sparam);
         ObjectSetInteger(0,sparam,OBJPROP_STATE,0);
         OpenChart(ind);
         return;         
      }   
     }
}
//+------------------------------------------------------------------+
//| closeOpenOrders                                                  |
//+------------------------------------------------------------------+
void closeOpenOrders(string currency )
{
   int cnt = 0;
    for (cnt = OrdersTotal()-1 ; cnt >= 0 ; cnt--)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
                  if(OrderType()==OP_BUY && OrderSymbol() == currency && OrderMagicNumber()==Magic_Number)
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
                  if(OrderType()==OP_SELL && OrderSymbol() == currency && OrderMagicNumber()==Magic_Number) 
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
                  if(OrderType()>OP_SELL) //pending orders
                     ticket=OrderDelete(OrderTicket());
                   
            }
}
void close_basket(int magic_number)
{ 
  
if (OrdersTotal()==0) return;
for (int i=OrdersTotal()-1; i>=0; i--)
      {//pozicio kivalasztasa
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)//ha kivalasztas ok
            {
            //Print ("order ticket: ", OrderTicket(), "order magic: ", OrderMagicNumber());
            if (OrderType()==0 && OrderMagicNumber()==Magic_Number)
               {//ha long
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               
               }
            if (OrderType()==1 && OrderMagicNumber()==Magic_Number)
               {//ha short
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               
               }  
            }
      }
  
//----
   return;
    
}
void close_profit()
{
 int cnt = 0; 
 for (cnt = OrdersTotal()-1 ; cnt >= 0 ; cnt--)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
               if (OrderProfit() > 0)
               {
                  if(OrderType()==OP_BUY && OrderMagicNumber()==Magic_Number)
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
                  if(OrderType()==OP_SELL && OrderMagicNumber()==Magic_Number) 
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
                  if(OrderType()>OP_SELL)
                     ticket=OrderDelete(OrderTicket());
               }
            } 
    }
void close_loss()
{
 int cnt = 0; 
 for (cnt = OrdersTotal()-1 ; cnt >= 0 ; cnt--)
            {
               if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)==true)
               if (OrderProfit() < 0)
               {
                  if(OrderType()==OP_BUY && OrderMagicNumber()==Magic_Number)
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Violet);
                  if(OrderType()==OP_SELL && OrderMagicNumber()==Magic_Number) 
                     ticket=OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Violet);
                  if(OrderType()>OP_SELL)
                     ticket=OrderDelete(OrderTicket());
               }
            } 
    }                            
//----------------------------------------------------------------------------------------------------------------------+ 
void OpenChart(int ind) {
long nextchart = ChartFirst();
   do {
      string sym = ChartSymbol(nextchart);
      if (StringFind(sym,Defaultpairs[ind]) >= 0) {
            ChartSetInteger(nextchart,CHART_BRING_TO_TOP,true);
            ChartSetSymbolPeriod(nextchart,Defaultpairs[ind],TimeFrame);
            ChartApplyTemplate(nextchart,usertemplate);
            return;
         }
   } while ((nextchart = ChartNext(nextchart)) != -1);
   long newchartid = ChartOpen(Defaultpairs[ind],TimeFrame);
   ChartApplyTemplate(newchartid,usertemplate);
 } 
 
//+------------------------------------------------------------------+
color ColorPips(double Pips) 
  {
   if(Pips>0)
      return (clrLawnGreen);
   if(Pips<0)
      return (clrRed);
   return (clrWhite);
  }
//+------------------------------------------------------------------+
color Colorstr(double tot) 
  {
   if(tot>0)
      return (clrDodgerBlue);
   if(tot<0)
      return (clrFireBrick);
   return (clrWhite);
  }
//-------------------------------------------------------------------+
void swap (Pair &i, Pair &j) {
   string strTemp;
   double dblTemp;
   int    intTemp;
   
   strTemp = i.symbol; i.symbol = j.symbol; j.symbol = strTemp;
   dblTemp = i.point; i.point = j.point; j.point = dblTemp;               
   dblTemp = i.open; i.open = j.open; j.open = dblTemp;
   dblTemp = i.close; i.close = j.close; j.close = dblTemp;               
   dblTemp = i.hi; i.hi = j.hi; j.hi = dblTemp;          
   dblTemp = i.lo; i.lo = j.lo; j.lo = dblTemp;               
   dblTemp = i.ask; i.ask = j.ask; j.ask = dblTemp;               
   dblTemp = i.bid; i.bid = j.bid; j.bid = dblTemp;               
   intTemp = i.pipsfactor; i.pipsfactor = j.pipsfactor; j.pipsfactor = intTemp;               
   dblTemp = i.spread; i.spread = j.spread; j.spread = dblTemp;      
   dblTemp = i.pips; i.pips = j.pips; j.pips = dblTemp;  
   dblTemp = i.range; i.range = j.range; j.range = dblTemp;  
   dblTemp = i.ratio; i.ratio = j.ratio; j.ratio = dblTemp;  
   dblTemp = i.calc; i.calc= j.calc; j.calc = dblTemp;  
   

}
//+------------------------------------------------------------------+ 
void displayMeter() {
   
   double arrt[8][2];
   int arr2;
   arrt[0][0] = currency_strength(curr[0]);
   arrt[1][0] = currency_strength(curr[1]);
   arrt[2][0] = currency_strength(curr[2]);
   arrt[3][0] = currency_strength(curr[3]);
   arrt[4][0] = currency_strength(curr[4]);
   arrt[5][0] = currency_strength(curr[5]);
   arrt[6][0] = currency_strength(curr[6]);
   arrt[7][0] = currency_strength(curr[7]);
   arrt[0][1] = 0;
   arrt[1][1] = 1;
   arrt[2][1] = 2;
   arrt[3][1] = 3;
   arrt[4][1] = 4;
   arrt[5][1] = 5;
   arrt[6][1] = 6;
   arrt[7][1] = 7;
   ArraySort(arrt, WHOLE_ARRAY, 0, MODE_DESCEND);
     
   for (int m = 0; m < 8; m++) {
      arr2 = arrt[m][1];
         SetText(curr[arr2]+"pos",IntegerToString(m+1)+".",x_axis+410,(m*16)+y_axis,color_for_profit(arrt[m][0]),11);
         SetText(curr[arr2]+"curr", curr[arr2],x_axis+425,(m*16)+y_axis,color_for_profit(arrt[m][0]),11);
         SetText(curr[arr2]+"currdig", DoubleToStr(arrt[m][0],2),x_axis+465,(m*16)+y_axis,color_for_profit(arrt[m][0]),11);
         }
 ChartRedraw(); 
}

color color_for_profit(double total) 
  {
   if(total<=2.0)
      return (clrCrimson);   
   if(total>=7.0)   
   return (clrLimeGreen);
   if(total>=5.5)   
   return (clrYellowGreen);
   if(total<=3.0)   
   return (clrOrangeRed);
   return(clrSteelBlue);
  }

double currency_strength(string pair) {
   int fact;
   string sym;
   double range;
   double ratio;
   double strength = 0;
   int cnt1 = 0;
   
   for (int x = 0; x < ArraySize(Defaultpairs); x++) {
      fact = 0;
      sym = Defaultpairs[x];
      if (pair == StringSubstr(sym, 0, 3) || pair == StringSubstr(sym, 3, 3)) {
         sym = sym + tempsym;
         range = (MarketInfo(sym, MODE_HIGH) - MarketInfo(sym, MODE_LOW)) * MarketInfo(sym, MODE_POINT);
         if (range != 0.0) {
            ratio = 100.0 * ((MarketInfo(sym, MODE_BID) - MarketInfo(sym, MODE_LOW)) / range * MarketInfo(sym, MODE_POINT));
            if (ratio > 3.0)  fact = 1;
            if (ratio > 10.0) fact = 2;
            if (ratio > 25.0) fact = 3;
            if (ratio > 40.0) fact = 4;
            if (ratio > 50.0) fact = 5;
            if (ratio > 60.0) fact = 6;
            if (ratio > 75.0) fact = 7;
            if (ratio > 90.0) fact = 8;
            if (ratio > 97.0) fact = 9;
            cnt1++;
            if (pair == StringSubstr(sym, 3, 3)) fact = 9 - fact;
            strength += fact;
         }
      }      
   }
   if(cnt1!=0)strength /= cnt1;
   return (strength);
 }
//------------------------------------------------------------------------------------------------+ 
void Trades()
{
   int i, j;
   totallots=0;
   totalprofit=0;

   for(i=0;i<ArraySize(Defaultpairs);i++)
   {
      
      bpos[i]=0;
      spos[i]=0;       
      blots[i]=0;
      slots[i]=0;     
      bprofit[i]=0;
      sprofit[i]=0;
      tprofit[i]=0;
   }
	for(i=0;i<OrdersTotal();i++)
	{
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         break;

      for(j=0;j<ArraySize(Defaultpairs);j++)
      {	  
         if((Defaultpairs[j]==OrderSymbol() || Defaultpairs[j]=="") && OrderMagicNumber()==Magic_Number)
         {
//            TradePairs[j]=OrderSymbol();                       
            tprofit[j]=tprofit[j]+OrderProfit()+OrderSwap()+OrderCommission();
           if(OrderType()==0){ bprofit[j]+=OrderProfit()+OrderSwap()+OrderCommission(); } 
           if(OrderType()==1){ sprofit[j]+=OrderProfit()+OrderSwap()+OrderCommission(); } 
           if(OrderType()==0){ blots[j]+=OrderLots(); } 
           if(OrderType()==1){ slots[j]+=OrderLots(); }
           if(OrderType()==0){ bpos[j]+=+1; } 
           if(OrderType()==1){ spos[j]+=+1; } 
                                
            totallots=totallots+OrderLots();
            totalprofit = totalprofit+OrderProfit()+OrderSwap()+OrderCommission();
            break;
	     }
	  }
   }
  }
void TradeManager() {

   double AccBalance=AccountBalance();
         
      //- Target
      if(Basket_Target>0 && totalprofit>=Basket_Target) {         
         close_basket(Magic_Number);
         return;
      }
      
      //- StopLoss
      if(Basket_StopLoss>0 && totalprofit<(0-Basket_StopLoss)) {         
         close_basket(Magic_Number);
         return;
      }
    }    