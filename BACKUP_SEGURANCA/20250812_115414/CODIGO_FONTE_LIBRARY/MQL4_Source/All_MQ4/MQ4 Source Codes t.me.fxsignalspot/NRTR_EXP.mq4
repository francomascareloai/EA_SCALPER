//+------------------------------------------------------------------+
//|                     Trader by ASC                                |
//+------------------------------------------------------------------+
extern double Lots = 1.0;
extern int    ATR  = 50;
extern int    Coeficient = 3;
extern bool   MM   = true;
extern int    Risk = 12;
extern bool   TS_ATR = true;
extern double Patr=9;
extern double Prange=5;
extern double Kstop=1.5;
extern double kts=2;
extern double Vts=2;

double BuyPrice,SellPrice;
bool   OpenBuy,OpenSell,CloseBuy,CloseSell;
bool   UpArrow,DnArrow,first;
string MODE;
double Up[],Dn[];
int ns=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init ()  { first=true; UpArrow=false; DnArrow=false; MODE=""; return(0); }
int deinit() { Comment(""); return(0); }

int start()
{
  int OpenTrades,cnt;
  double lotsi;

  ArrayResize(Up,Bars+1); ArrayResize(Dn,Bars+1);
  ArrayInitialize(Up,0.0); ArrayInitialize(Dn,0.0);

  if(!MM) lotsi=MathCeil(AccountBalance()*Risk/10000)/10;
  else lotsi=Lots;

  Up[0]=iCustom(NULL,0,"NRTR_ATR_STOP",ATR,Coeficient,0,0);
  Dn[0]=iCustom(NULL,0,"NRTR_ATR_STOP",ATR,Coeficient,1,0);
  Up[1]=iCustom(NULL,0,"NRTR_ATR_STOP",ATR,Coeficient,0,1);
  Dn[1]=iCustom(NULL,0,"NRTR_ATR_STOP",ATR,Coeficient,1,1);

  CloseSell=false; OpenSell=false; CloseBuy=false; OpenBuy=false;
  if(Up[0]!=0 && Dn[0]==0 && Dn[1]!=0) { CloseSell=true; OpenBuy=true;  }
  if(Dn[0]!=0 && Up[0]==0 && Up[1]!=0) { CloseBuy=true;  OpenSell=true; }

  for(cnt=0; cnt<OrdersTotal(); cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if(OrderSymbol()==Symbol())
    {
      if(OrderType()==OP_BUY)
      { if(CloseBuy)  { OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE); Sleep(15000); } }

      if(OrderType()==OP_SELL)
      { if(CloseSell) { OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE); Sleep(15000); } }

      if(OrderType()==OP_BUYSTOP)
      { if(CloseBuy)  { OrderDelete(OrderTicket()); Sleep(15000); } }

      if(OrderType()==OP_SELLSTOP)
      { if(CloseSell) { OrderDelete(OrderTicket()); Sleep(15000); } }
    }
  }

  TSATRStop(TS_ATR);

  OpenTrades=0;
  for(cnt=0; cnt<OrdersTotal(); cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
    if(OrderSymbol()==Symbol()) OpenTrades++;
  }

  if(OpenTrades==0 && OpenBuy)
 	{
 	  if(!UpArrow) 
 	  {
   	  ns++;
      CreateArrow(ns,Time[0],Up[0],225,Aqua);
      UpArrow=true; DnArrow=false;
    }

    OrderSend(Symbol(),OP_BUY,lotsi,Ask,3,0,0,"BuyOrder",255,0,CLR_NONE);
    return(0);
 	}
    
  if(OpenTrades==0 && OpenSell)
 	{
 	  if(!DnArrow)
 	  {
   	  ns++;
  	  CreateArrow(ns,Time[0],Dn[0],226,Red);
      DnArrow=true; UpArrow=false;
  	}

    OrderSend(Symbol(),OP_SELL,lotsi,Bid,3,0,0,"SelOrder",255,0,CLR_NONE);
    return(0);
 	}

  return(0);
}
//*******************************************************************************
void TSATRStop(bool Trailing)
{
  int i,mode,ticket,total;
  double cnt,ValATR,hi,lo,SL,TS,prevBars;

  if(!Trailing) return(0);

  if (prevBars!=Bars) 
  {
    ValATR=0;
    for(i=1; i<=Patr; i++) { if(i<=Patr) { ValATR+=High[i]-Low[i]; } }
    ValATR=ValATR/Patr;
     
    hi=High[Highest(NULL,0,MODE_HIGH,Prange,Prange)]; 
    lo=Low[Lowest(NULL,0,MODE_LOW,Prange,Prange)]; 
 
    if (Vts==1)  {TS=kts*ValATR; SL=Kstop*ValATR;}
    if (Vts==2)  {TS=(hi-lo);    SL=Kstop*(hi-lo);}
    prevBars = Bars;
  }

  if (Vts<1 || Vts>2)  return(0);

  for (cnt=0; cnt<=OrdersTotal(); cnt++)
  {
    OrderSelect(cnt,SELECT_BY_POS);
    mode=OrderType();
    if(OrderSymbol()==Symbol())
    {
//First Stop---------------------------------
      if (mode==OP_BUY && OrderStopLoss()== 0)
      {
        OrderModify(OrderTicket(),OrderOpenPrice(),Low[0]-SL,OrderTakeProfit(),0,CLR_NONE);
        PlaySound("expert.wav");
        return(0);
      }

      if (mode==OP_SELL && OrderStopLoss()==0)
      {
        OrderModify(OrderTicket(),OrderOpenPrice(),High[0]+SL,OrderTakeProfit(),0,CLR_NONE);
        PlaySound("expert.wav");
        return(0);
      }
//Main Trailing-------------------------------
      if ((mode==OP_BUY && High[0]-OrderOpenPrice()>TS && OrderStopLoss()<High[0]-TS) || OrderStopLoss()==0)
      {
        OrderModify(OrderTicket(),OrderOpenPrice(),High[0]-TS,OrderTakeProfit(),0,CLR_NONE);
        PlaySound("expert.wav");
        return(0);
      }

      if ((mode==OP_SELL && OrderOpenPrice()-Low[0]>TS && OrderStopLoss()>Low[0]+TS) || OrderStopLoss()==0)
      {
        OrderModify(OrderTicket(),OrderOpenPrice(),Low[0]+TS,OrderTakeProfit(),0,CLR_NONE);
        PlaySound("expert.wav");
        return(0);
      }
    }
  }
}
//*******************************************************************************
void CreateArrow(string name, datetime time1, double price1, int code_arrow, int clr)
{
  ObjectCreate(name,OBJ_ARROW,0,time1,price1);
  ObjectSet(name,OBJPROP_ARROWCODE,code_arrow);
  ObjectSet(name,OBJPROP_COLOR,clr);
}
//*******************************************************************************
/*
double NRTR()
{
  int i,limit;
  double REZ,md;

  limit=Bars-ATR-1;

  if(first)
  {
    md=0;
    for(i=0; i<limit; i++) md+=iATR(NULL,0,ATR,i);
    REZ=Coeficient*iATR(NULL,0,ATR,limit);
    if(iATR(NULL,0,ATR,limit)<md/limit) { Up[limit+1]= Low[limit+1]-REZ; MODE="UP"; }
    if(iATR(NULL,0,ATR,limit)>md/limit) { Dn[limit+1]=High[limit+1]+REZ; MODE="DN"; }
    first=false;
  }

  for(i=limit-1; i>=0; i--)
  {
    Dn[i]=0; Up[i]=0;
    REZ=Coeficient*iATR(NULL,0,ATR,i);
    if(MODE=="DN" &&  Low[i+1]>Dn[i+1]) { Up[i+1]= Low[i+1]-REZ; MODE="UP"; }
    if(MODE=="UP" && High[i+1]<Up[i+1]) { Dn[i+1]=High[i+1]+REZ; MODE="DN"; }

    if(MODE=="UP")
    {
      if(Low[i+1]>Up[i+1]+REZ) { Up[i]=Low[i+1]-REZ; Dn[i]=0; }
		  else { Up[i]=Up[i+1]; Dn[i]=0; }
		}

    if(MODE=="DN")
    {
     	if(High[i+1]<Dn[i+1]-REZ) { Dn[i]=High[i+1]+REZ; Up[i]=0; }
	    else { Dn[i]=Dn[i+1]; Up[i]=0; }
	  }
  }
  return(0);
}
*/