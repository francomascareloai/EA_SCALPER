//+------------------------------------------------------------------+
//|                                            JOHN ANAK ANTHONY.mq4 |
//|                                           https://t.me/Astrologe |
//|                                           https://t.me/Astrologe |
//+------------------------------------------------------------------+
#property copyright "https://t.me/Astrologe  28.5.2017"
#property link      "https://t.me/Astrologe"
#property version   "9.99"
#property strict
#property description " New Version: Created for JOHN ANAK ANTHONY 2.5.2017"


string EA;
string  EA1                             =  "EA Superstar v99.9";   //  Comment To Dispaly In Order
extern int     magic                    =  1;                //  Magic Number
extern double  lot_initial              =  0.01;                   //  Lot Started
extern double  multiplier               =  2.0;                    //  Multiplier  
extern int     takeprofit               =  20;                     //  TakeProfit (Pips)
extern int     distance_pips            =  15;                     //  Distance Open Position (Pips)
extern int     maxlayer                 =  100;                    //  Max Position(layer) Per Side
extern bool    display_info             =  true;                   //  Show Info On Chart
extern color   kolor_display            =  clrYellow;              //  Info's Text Color
extern int     fontsize                 =  10;                     //  Font Size

double lotsbuy[];
double lotssell[];

string buy = " buy ";
string sell= " sell ";


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
  OnTick();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
ObjectsDeleteAll();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

if (magic==0 || magic >999999999)
  Comment(" Pls Adjust Ur Magic Number, EA is DISABLE for good");
else setup();
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
double stoplvl()
{
double value    =  0;
double value1   =  MarketInfo(Symbol(),MODE_STOPLEVEL);
double value2   =  MarketInfo(Symbol(),MODE_FREEZELEVEL); 

if (value1  >  value2)  value   =  value1;else 
if (value1  <  value2)  value   =  value2;

return(value*Point);
}// end stplvl
//+------------------------------------------------------------------+
int dec(){   int decimal;   if (Digits==3|| Digits==5) decimal=10;   else  decimal=1;   return(decimal);}
//+------------------------------------------------------------------+
double ask(){RefreshRates();return(nl(MarketInfo(Symbol(),MODE_ASK)));}//
//--------------------------------------------------------------------+
double bid(){RefreshRates();return(nl(MarketInfo(Symbol(),MODE_BID)));}//
//+------------------------------------------------------------------+
double minlot(){return(MarketInfo(Symbol(),MODE_MINLOT));}
//+------------------------------------------------------------------+
double maxlot(){return(MarketInfo(Symbol(),MODE_MAXLOT));}
//+------------------------------------------------------------------+

void openorder( int type, double Lot,double price,double SLvalue, double TPvalue, color kolor)
{ 
if (Lot  < minlot()) Print( " periksa saiz lot = ", DoubleToStr(Lot,2)," kecil.. minimum lot broker= ", minlot());
if (Lot  > maxlot()) Print( " periksa saiz lot = ", DoubleToStr(Lot,2)," besar.. maximum lot broker= ", maxlot());

if (AccountFreeMarginCheck(Symbol(),type,Lot)>0)
   {
   Comment("");
   bool order  =  OrderSend(Symbol() ,type ,Lot ,price ,3*dec() ,SLvalue ,TPvalue ,EA ,magic ,0 ,kolor);
   if  (!order)   Print(Symbol()  ,",  Orderticket = ",OrderTicket(),", type= ",type,", ERROR=", GetLastError());
   } 
else Comment("Bro.. Pls check ur account margin..");
}// end
//--------------------------------------------------------------------+

int counter(int type, int magicnumber)
{
int count  =  0;
for (int x=0;x<OrdersTotal();x++)
   { 
     if(OrderSelect        (x,SELECT_BY_POS,MODE_TRADES) )
     if (OrderSymbol()     != Symbol())      continue;
     if( OrderMagicNumber()!= magicnumber)   continue;
     if (OrderType()       != type)          continue;
         count++;
   }// for loop
return(count);
}// end
//--------------------------------------------------------------------+
void array_resize()
{
   int max        =  maxlayer ;
   int reserved   =  max+100;
   ArrayResize(lotsbuy ,max,reserved);
   ArrayResize(lotssell,max,reserved);
   
}// end
//--------------------------------------------------------------------+

void initialize_lotbuy()
{
lotsbuy[0]= lot_initial;
lotsbuy[1]= lot_initial;

for(int x=2; x<maxlayer ; x++)
      lotsbuy[x]   =  lotsbuy[x-1]*multiplier;  
       
for(int x=0; x<maxlayer ; x++)
      lotsbuy[x]  =  NormalizeDouble(lotsbuy[x],2);

}// end
//+------------------------------------------------------------------+

void initialize_lotsell()
{
lotssell[0]= lot_initial;
lotssell[1]= lot_initial;

for(int x=2; x<maxlayer; x++)
      lotssell[x]   =  lotssell[x-1]*multiplier;   
      
for(int x=0; x<maxlayer ; x++)
      lotssell[x]  =  NormalizeDouble(lotssell[x],2);

}// end
//+------------------------------------------------------------------+

double latest_openprice(int type)
{
double value=0;
int ticket  =  get_latest_ticket(type);
if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
   value= OrderOpenPrice();

return(value);
}// end
//--------------------------------------------------------------------+

double nextlayer_pricebuy()
{
double value  =  latest_openprice(OP_BUY)  - dist();
return(nl(value));
}// end
//+------------------------------------------------------------------+

double nextlayer_pricesell()
{
double value  =  latest_openprice(OP_SELL)  + dist();
return(nl(value));
}// end
//+------------------------------------------------------------------+

double dist()
{return(distance_pips *dec() *Point);}

//+------------------------------------------------------------------+
double nl(double value)
{return(NormalizeDouble(value,Digits));}// end
//+------------------------------------------------------------------+

int get_latest_ticket(int type)
{
int ticket   =  0;
for (int x=0;x<OrdersTotal();x++)
     {
     if(OrderSelect           (x,SELECT_BY_POS,MODE_TRADES))
     if(OrderSymbol()         !=  Symbol())            continue;
     if(OrderMagicNumber()    !=  magic)               continue; 
     if(OrderType()           !=  type)                continue;
     if(OrderTicket()         >   ticket || ticket == 0 )
                     ticket   =   OrderTicket();
     }// for loop  

return(ticket);
}// end
//--------------------------------------------------------------------+
double tp_buy()
{
double value   =  latest_openprice(OP_BUY) + takeprofit * dec()* Point;
if (takeprofit*dec()*Point < stoplvl())
   value = 0;
return(nl(value));
}//
//+------------------------------------------------------------------+

double tp_sell()
{
double value   =  latest_openprice(OP_SELL) - takeprofit * dec()* Point;
if (takeprofit*dec()*Point < stoplvl())
   value = 0;
return(nl(value));
}//
//+------------------------------------------------------------------+

void put_tp(double tp_cal)
{

double tp = nl(tp_cal);
for(int x=0; x<OrdersTotal(); x++)
   {
   RefreshRates();

   if(OrderSelect          (x,SELECT_BY_POS,MODE_TRADES))
   if(OrderSymbol()        == Symbol())
   if(OrderMagicNumber()   == magic   )
      {
      //------------------------------------------------
      if(OrderType()  ==    OP_BUY)
      if(tp           >     0)
      if(tp           !=    OrderTakeProfit())
      if(tp           >     ask()   +  stoplvl())
      
               {
               bool modify =     OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,clrNONE);
               if (!modify)      Print("tp: ",nl(tp),", Failed To Insert Tp For Buy Trade. error# ", GetLastError());
               }

      //------------------------------------------------
      if(OrderType()  ==    OP_SELL)
      if(tp           >     0)
      if(tp           !=    OrderTakeProfit())
      if(tp           <     bid()  -  stoplvl())
               {
               bool modify =     OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),tp,0,clrNONE);
               if (!modify)      Print(OrderTicket(),"tp: ",nl(tp),",  Failed To Insert TP for Sell Trade. error# ", GetLastError());
               }
      }// if select
   }// for loop
}// end

//--------------------------------------------------------------------+
string floating(int type)
{
double floating  =  0;
for (int x=0;x<OrdersTotal();x++)
   { 
     if(OrderSelect        (x,SELECT_BY_POS,MODE_TRADES) )
     if (OrderSymbol()     != Symbol())      continue;
     if( OrderMagicNumber()!= magic)         continue;
     if (OrderType()       != type)          continue;
         floating += OrderProfit();
   }// for loop
return(DoubleToStr(floating,2));
}// end
//+------------------------------------------------------------------+
double totlot(int type)
{
double value  =  0;
for (int x=0;x<OrdersTotal();x++)
   { 
     if (OrderSelect        (x,SELECT_BY_POS,MODE_TRADES) )
     if (OrderSymbol()     != Symbol())      continue;
     if (OrderMagicNumber()!= magic)         continue;
     if (OrderType()       != type)          continue;
          value += OrderLots();
   }// for loop
return(value);
}// end
//--------------------------------------------------------------------+

void setup()
{
array_resize();
initialize_lotbuy();
initialize_lotsell();

//-- initial simultaneous orders 
if (counter(OP_BUY,magic)==0)
   {
   EA=EA1+buy+IntegerToString(counter(OP_BUY,magic));
   openorder(OP_BUY, lot_initial,ask(),0,0,clrBlue);
   }
   
if (counter(OP_SELL,magic)==0)
   {   
   EA=EA1+sell+IntegerToString(counter(OP_SELL,magic));
   openorder(OP_SELL,lot_initial,bid(),0,0,clrRed);
   }

//--layering sell martingale orders
if (counter(OP_SELL,magic)  >  0) 
if (counter(OP_SELL,magic)  <  maxlayer)
if (bid()                   >= nextlayer_pricesell())
   {
   EA=EA1+sell+IntegerToString(counter(OP_SELL,magic));
   openorder(OP_SELL,lotssell[counter(OP_SELL,magic)],bid(),0,0,clrRed);
   } 
  
//--layering buy martingale orders
if (counter(OP_BUY,magic)  >  0) 
if (counter(OP_BUY,magic)  <  maxlayer)
if (ask()                  <= nextlayer_pricebuy())
   {
   EA=EA1+buy+IntegerToString(counter(OP_BUY,magic));
   openorder(OP_BUY,lotsbuy[counter(OP_BUY,magic)],ask(),0,0,clrBlue);
   }
  
   
//-- put tp 
if (counter(OP_BUY,magic)>0)
   put_tp(tp_buy());
if (counter(OP_SELL,magic)>0)
   put_tp(tp_sell());
   
if(display_info)   
 display();
 
else {ObjectsDeleteAll(0,OBJ_RECTANGLE_LABEL); ObjectsDeleteAll(0,OBJ_LABEL);}
}// end

//--------------------------------------------------------------------+

void display()
{

int x=160; int x2=80; int x3=40;
int y=50;int yt=14;

rec_label("pak",170,25,clrSeaGreen);

text("paktex" ,x ,y+yt*-1,EA1);
text("balance",x ,y+yt*1,"BALANCE: ")     ;text("bal"        ,x2,y+yt*1 ,DoubleToStr(AccountBalance(),2));
text("lvg"    ,x ,y+yt*2,"LEVERAGE: ")    ;text("levg"       ,x2,y+yt*2 ,DoubleToStr(AccountLeverage(),0));
text("fmargin",x ,y+yt*3,"F.MARGIN: ")    ;text("freemargin"    ,x2,y+yt*3 ,DoubleToStr(AccountFreeMargin(),2));
text("margin" ,x ,y+yt*4,"MARGIN: ")      ;text("Margin"     ,x2,y+yt*4 ,DoubleToStr(AccountMargin(),2));
text("equity" ,x ,y+yt*5,"EQUITY: ")      ;text("Equity"     ,x2,y+yt*5 ,DoubleToStr(AccountEquity(),2));

text("buy"    ,x ,y+yt*7,"BUY: ")         ;text("countbuy",x2,y+yt*7,IntegerToString(counter(OP_BUY,magic)));
text("lotbuy" ,x3,y+yt*7,"("+DoubleToStr(totlot(OP_BUY),2)+")");

text("sell"   ,x ,y+yt*8,"SELL: ")        ;text("countsell",x2,y+yt*8,IntegerToString(counter(OP_SELL,magic)));
text("lotsell",x3,y+yt*8,"("+DoubleToStr(totlot(OP_SELL),2)+")");

text("fbuy"   ,x,y+yt*10,"FL.BUY:  ")      ;text("flbuy",x2,y+yt*10,floating(OP_BUY));
text("fsell"  ,x,y+yt*11,"FL.SELL:  ")     ;text("flsell",x2,y+yt*11,floating(OP_SELL));

}// end

//--------------------------------------------------------------------+

void rec_label(string name, int xD,int yD,color warna)
{
  //ObjectDelete(name);
  ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0);
  ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xD);
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yD);
  ObjectSetInteger(0,name,OBJPROP_XSIZE,170);
  ObjectSetInteger(0,name,OBJPROP_YSIZE,200);
  ObjectSetInteger(0,name,OBJPROP_BGCOLOR,warna);
  ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,STYLE_SOLID);
  ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetInteger(0,name,OBJPROP_COLOR,clrSilver);
  ObjectSetInteger(0,name,OBJPROP_STYLE,BORDER_SUNKEN);
  ObjectSetInteger(0,name,OBJPROP_WIDTH,5);
  ObjectSetInteger(0,name,OBJPROP_BACK,true);
  ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
  ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
  ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
}
//+------------------------------------------------------------------+
void text(string name2, int xDtext, int yDtext,string text)
{
  ObjectDelete(name2);
  ObjectCreate(0,name2,OBJ_LABEL,0,0,0);
  ObjectSetInteger(0,name2,OBJPROP_XDISTANCE,xDtext);
  ObjectSetInteger(0,name2,OBJPROP_YDISTANCE,yDtext);
  ObjectSetInteger(0,name2,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
  ObjectSetString(0,name2,OBJPROP_TEXT,text);
  ObjectSetString(0,name2,OBJPROP_FONT,"Arial");
  ObjectSetInteger(0,name2,OBJPROP_FONTSIZE,fontsize);
  ObjectSetInteger(0,name2,OBJPROP_COLOR,kolor_display);
  ObjectSetInteger(0,name2,OBJPROP_BACK,false);
  ObjectSetInteger(0,name2,OBJPROP_SELECTABLE,false);
  ObjectSetInteger(0,name2,OBJPROP_SELECTED,false);
  ObjectSetInteger(0,name2,OBJPROP_HIDDEN,true); 
  

}// end text
//+------------------------------------------------------------------+










