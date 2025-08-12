#include <stdlib.mqh>
//+------------------------------------------------------------------+
//|                                                3Auto_Targets.mq4 |
//|                                    Copyright © 2006, Yousky Soft |
//|                                            http://yousky.free.fr |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright " OlegVS"
#property link      " olegvs2003@yahoo.com"

#property indicator_chart_window
#property indicator_color1  Blue
#property indicator_buffers 2
#property indicator_color2  Red

//+------------------------------------------------------------------+
//| Common External variables                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| External variables                                               |
//+------------------------------------------------------------------+
extern double BarsCount = 200;
extern double depth = 15;
extern double deviation = 5;
extern double backstep = 3;

//+------------------------------------------------------------------+
//| Special Convertion Functions                                     |
//+------------------------------------------------------------------+

int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];

bool MOrderDelete( int ticket )
  {
  LastTradeTime = CurTime();
  return ( OrderDelete( ticket ) );
  }

bool MOrderClose( int ticket, double lots, double price, int slippage, color Color=CLR_NONE)
  {
  LastTradeTime = CurTime();
  price = MathRound(price*10000)/10000;
  return ( OrderClose( ticket, lots, price, slippage, Color) );
  }

bool MOrderModify( int ticket, double price, double stoploss, double takeprofit, datetime expiration, color arrow_color=CLR_NONE)
  {
  LastTradeTime = CurTime();
  price = MathRound(price*10000)/10000;
  stoploss = MathRound(stoploss*10000)/10000;
  takeprofit = MathRound(takeprofit*10000)/10000;
  return ( OrderModify( ticket, price, stoploss, takeprofit, expiration, arrow_color) );
  }

int MOrderSend( string symbol, int cmd, double volume, double price, int slippage, double stoploss, double takeprofit, string comment="", int magic=0, datetime expiration=0, color arrow_color=CLR_NONE)
  {
  LastTradeTime = CurTime();
  price = MathRound(price*10000)/10000;
  stoploss = MathRound(stoploss*10000)/10000;
  takeprofit = MathRound(takeprofit*10000)/10000;
  return ( OrderSend( symbol, cmd, volume, price, slippage, stoploss, takeprofit, comment, magic, expiration, arrow_color ) );
  }

int OrderValueTicket(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderTicket());
}

int OrderValueType(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderType());
}

double OrderValueLots(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderLots());
}

double OrderValueOpenPrice(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderOpenPrice());
}

double OrderValueStopLoss(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderStopLoss());
}

double OrderValueTakeProfit(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderTakeProfit());
}

double OrderValueClosePrice(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderClosePrice());
}

double OrderValueComission(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderCommission());
}

double OrderValueSwap(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderSwap());
}

double OrderValueProfit(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderProfit());
}

string OrderValueSymbol(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderSymbol());
}

string OrderValueComment(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderComment());
}

datetime OrderValueOpenTime(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderOpenTime());
}

datetime OrderValueCloseTime(int index)
{
  OrderSelect(index, SELECT_BY_POS);
  return(OrderCloseTime());
}

void PrintTrade(int index)
{
  if (OrderSelect(index, SELECT_BY_POS)==true)
    OrderPrint();
}

bool SetTextObject(string name, string text, string font, int font_size, color text_color=CLR_NONE)
{
  ObjectSetText(name, text, font_size, font, text_color);
}

void SetLoopCount(int loops)
{
}

void SetIndexValue(int shift, double value)
{
  ExtHistoBuffer[shift] = value;
}

void SetIndexValue2(int shift, double value)
{
  ExtHistoBuffer2[shift] = value;
}

double GetIndexValue(int shift)
{
  return(ExtHistoBuffer[shift]);
}

double GetIndexValue2(int shift)
{
  return(ExtHistoBuffer2[shift]);
}

bool SetObjectText(string name, string text, string font, int size, color Acolor)
{
  return(ObjectSetText(name, text, size, font, Acolor));
}

bool MoveObject(string name, int type, datetime Atime, double Aprice, datetime Atime2 = 0, double Aprice2 = 0, color Acolor = CLR_NONE, int Aweight = 0, int Astyle = 0)
{
    if (ObjectFind(name) != -1)
    {
      return(ObjectMove(name, type, Atime, Aprice));
    }
    else
    {
      return(ObjectCreate(name, type, 0, Atime, Aprice, Atime2, Aprice2, 0, 0));
    }
}

void SetArrow(datetime ArrowTime, double Price, double ArrowCode, color ArrowColor)
{
 int err;
 string ArrowName = DoubleToStr(ArrowTime,0);
   if (ObjectFind(ArrowName) != -1) ObjectDelete(ArrowName);
   if(!ObjectCreate(ArrowName, OBJ_ARROW, 0, ArrowTime, Price))
    {
      err=GetLastError();
      Print("error: can't create Arrow! code #",err," ",ErrorDescription(err));
      return;
    }
   else
   {
     ObjectSet(ArrowName, OBJPROP_ARROWCODE, ArrowCode);
     ObjectSet(ArrowName, OBJPROP_COLOR , ArrowColor);
     ObjectsRedraw();
   }
}

void DelArrow(datetime ArrowTime, double Price)
{
 int err;
 string ArrowName = DoubleToStr(ArrowTime,0);
   if (ObjectFind(ArrowName) != -1) ObjectDelete(ArrowName);
}

//+------------------------------------------------------------------+
//| End                                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+

int init()
{
   SetIndexBuffer(0, ExtHistoBuffer);
   SetIndexBuffer(1, ExtHistoBuffer2);
   return(0);
}
int start()
{
//+------------------------------------------------------------------+
//| Local variables                                                  |
//+------------------------------------------------------------------+
int shift = 0;
double Bars_ = 200;
double FractalUp = 0;
double FractalDown = 0;
double Target1 = 0;
double Target2 = 0;
double Target3 = 0;
double Fantasy = 0;
double CrazyDream = 0;
double Start = 0;
double Stop = 0;
double PointA = 0;
double PointB = 0;
double PointC = 0;
double zz = 0;
double zzs = 0;
int i = 0;
bool ft = true;
double m = 0;
double n = 0;
double k = 0;
string poz = "";

/*[[
	Name := 3_Targets
	Author := OlegVS
	Link := olegvs2003@yahoo.com
	Separate Window :=No 
	First Color := Blue
	First Draw Type := Symbol
	First Symbol := 158
	Use Second Data := Yes
	Second Color := Red
	Second Draw Type := Symbol
	Second Symbol := 158
]]*/
 
  
 
 

SetLoopCount(0);
if( BarsCount < 1 ) Bars_ = Bars
; else Bars_ = BarsCount;

for(shift =Bars_-1;shift >=0 ;shift --){ 
zzs=iCustom(NULL, 0, "ZigZag",depth,deviation,backstep,0,1);
if( zzs != 0 || ft ) { PointC=0;PointB=0;PointA=0;k=0;n=0;m=0; 
for(i=0;i<=BarsCount ;i++){ 
zz=iCustom(NULL, 0, "ZigZag",depth,deviation,backstep,0,i);
if( zz != 0 && k == 0 ) { k=1;PointC=zz;} 
if( zz != 0 && zz != PointC && k == 1 && n == 0 ) { n=1;PointB=zz;} 
if( zz != 0 && zz != PointC && zz != PointB && k == 1 && n == 1 && m == 0 ) { m=1;PointA=zz;} 
if( zz == 0 && PointC != 0 && PointB != 0 && PointA != 0 && PointC != PointB && PointB != PointA && PointA != PointC ) break;
} ft=false;} 

Target1=NormalizeDouble((PointB-PointA)*0.618+PointC,4);
Target2=PointB-PointA+PointC;
Target3=NormalizeDouble((PointB-PointA)*1.618+PointC,4);
Fantasy=NormalizeDouble((PointB-PointA)*2.618+PointC,4);
CrazyDream=NormalizeDouble((PointB-PointA)*4.618+PointC,4);
if( PointB<PointC ) 
{
Start= NormalizeDouble((PointB-PointA)*0.318+PointC,4)-(Ask-Bid);
Stop=PointC+2*(Ask-Bid);
}
if( PointB>PointC ) 
{
Start= NormalizeDouble((PointB-PointA)*0.318+PointC,4)+(Ask-Bid);
Stop=PointC-2*(Ask-Bid);
}
MoveObject("Target1",OBJ_HLINE,Time[1],Target1,Time[1],Target1,Yellow,1,STYLE_DASH);
SetObjectText("Target1_txt","Target1 "+Target1,"Arial",8,White);
MoveObject("Target1_txt",OBJ_TEXT,Time[25],Target1,Time[25],Target1,White);

MoveObject("Target2",OBJ_HLINE,Time[1],Target2,Time[1],Target2,LimeGreen,1,STYLE_DASH);
SetObjectText("Target2_txt","Target2 "+Target2,"Arial",8,White);
MoveObject("Target2_txt",OBJ_TEXT,Time[25],Target2,Time[25],Target2,White);

MoveObject("Target3",OBJ_HLINE,Time[1],Target3,Time[1],Target3,Blue,1,STYLE_DASH);
SetObjectText("Target3_txt","Target3 "+Target3,"Arial",8,White);
MoveObject("Target3_txt",OBJ_TEXT,Time[25],Target3,Time[25],Target3,White);

MoveObject("Fantasy",OBJ_HLINE,Time[1],Fantasy,Time[1],Fantasy,Violet,1,STYLE_DASH);
SetObjectText("Fantasy_txt","Fantasy "+Fantasy,"Arial",8,White);
MoveObject("Fantasy_txt",OBJ_TEXT,Time[25],Fantasy,Time[25],Fantasy,White);

MoveObject("CrazyDream",OBJ_HLINE,Time[1],CrazyDream,Time[1],CrazyDream,DarkViolet,1,STYLE_DASH);
SetObjectText("CrazyDream_txt","CrazyDream "+CrazyDream,"Arial",8,White);
MoveObject("CrazyDream_txt",OBJ_TEXT,Time[25],CrazyDream,Time[25],CrazyDream,White);

MoveObject("Start",OBJ_HLINE,Time[1],Start,Time[1],Start,Cyan,1,STYLE_DOT);
SetObjectText("Start_txt","Start "+Start,"Arial",8,White);
MoveObject("Start_txt",OBJ_TEXT,Time[25],Start,Time[25],Start,White);

MoveObject("Stop",OBJ_HLINE,Time[1],Stop,Time[1],Stop,Red,1,STYLE_DOT);
SetObjectText("Stop_txt","Stop "+Stop,"Arial",8,White);
MoveObject("Stop_txt",OBJ_TEXT,Time[25],Stop,Time[25],Stop,White);

	SetIndexValue(shift,zzs);
	SetIndexValue2(shift,Start);
} 

if( PointC != 0 && PointC>Start && Bid>Start ) poz="SellStop for Target1";
if( PointC != 0 && PointC<Start && Ask<Start ) poz="BuyStop for Target1";
if( (PointC != 0 && PointC>Start && Close[0]<Start) || (PointC != 0 && PointC<Start && Close[0]>Start) ) poz="Not Target1";

Comment("ComaA=",PointA,"  ComaB=",PointB,"  ComaC=",PointC,"  StartZZ=",zzs,"  StartPrice=",Start,"  Position=",poz);
  return(0);
}