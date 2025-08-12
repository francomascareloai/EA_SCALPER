//+-----===         PCS         ===-----+
//+-----=== Designed for EURAUD ===-----+

#property copyright "Copyright © 2006, maloma"
#include <stdlib.mqh>
#include <stderror.mqh>

extern double Lots          = 0.1;
extern int    StopLoss      = 1000;
extern int    TakeProfit    = 1000;
extern int    MagicNumber   = 6540123;
extern string PCP           = "   ---   Параметры PriceChannel_Stop_v6   ---   ";
extern double Risk          = 0.30;
extern int    ChannelPeriod = 9;   //Price Channel Period
       int    Slippage      = 3;
       double SL,TP;
       int    i,j,CBar,CTicket=0;
       string S; 
       double UpTrendSignal[];
       double DownTrendSignal[];
   
void init()
{
 CBar=0;
 S=Symbol();
 SL=StopLoss*MarketInfo(S,MODE_POINT);
 TP=TakeProfit*MarketInfo(S,MODE_POINT);
 return(0);
}

void PriceChannel_Stop_v6()
{
   double UpTrendBuffer[];
   double DownTrendBuffer[];
   double UpTrendLine[];
   double DownTrendLine[];
   double UpTrendBar[];
   double DownTrendBar[];
   int Signal=1;          //Display signals mode: 1-Signals & Stops; 0-only Stops; 2-only Signals;
   int Line=1;            //Display line mode: 0-no,1-yes  
   int ColorBar=1;        //Display color bars mode: 0-no,1-yes 
   int TimeFrame=0;   
   int Nbars=100;
   datetime TimeArray[];
   int    i,shift,trend,y=0;
   double high, low, price, sum, VolAverage,UpBar,DnBar;
   double smax[25000],smin[25000],bsmax[25000],bsmin[25000],Mid[25000],Vol[25000];
   double LowArray[],HighArray[];
   
   for (shift=Nbars-1;shift>=0;shift--)
   {
   UpTrendBuffer[shift]=0.0;
   DownTrendBuffer[shift]=0.0;
   UpTrendSignal[shift]=0.0;
   DownTrendSignal[shift]=0.0;
   UpTrendLine[shift]=EMPTY_VALUE;
   DownTrendLine[shift]=EMPTY_VALUE;
   UpTrendBar[shift]=0.0;
	DownTrendBar[shift]=0.0;
   }
// Draw price channel boards + calculation : Channel middle, half channel width, 
 
   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   ArrayCopySeries(LowArray,MODE_LOW,Symbol(),TimeFrame);     
   ArrayCopySeries(HighArray,MODE_HIGH,Symbol(),TimeFrame);  
   
   for(i=0,y=0;i<Nbars;i++)
   {
   if (Time[i]<TimeArray[y]) y++;  
   smin[i]=LowArray[Lowest(NULL,TimeFrame,MODE_LOW,ChannelPeriod,y)]; 
   smax[i]=HighArray[Highest(NULL,TimeFrame,MODE_HIGH,ChannelPeriod,y)];       
   Mid[i]=0.5*(smin[i]+smax[i]);
   }  
     
//
   
   for (shift=Nbars-ChannelPeriod-1;shift>=0;shift--)
   {	  
// Calculation channel stop values 
              
     bsmax[shift]=smax[shift]-(smax[shift]-smin[shift])*Risk;
	  bsmin[shift]=smin[shift]+(smax[shift]-smin[shift])*Risk;

// Signal area : any conditions to trend determination:     
// 1. Price Channel breakout 
    
     if(Risk>0)
     {
      if(Close[shift]>bsmax[shift])  trend=1; 
      if(Close[shift]<bsmin[shift])  trend=-1;
     }
     else
     {
      if(Close[shift]>bsmax[shift+1])  trend=1; 
      if(Close[shift]<bsmin[shift+1])  trend=-1;
     } 
    
// Correction boards values with existing trend	  		

	  if(trend>0)
     {
     if(Risk>0 && Close[shift]<bsmin[shift]) bsmin[shift]=bsmin[shift+1];
     if(bsmin[shift]<bsmin[shift+1]) bsmin[shift]=bsmin[shift+1];
     }
     if(trend<0)
     {
     if(Risk>0 && Close[shift]>bsmax[shift]) bsmax[shift]=bsmax[shift+1];
     if(bsmax[shift]>bsmax[shift+1]) bsmax[shift]=bsmax[shift+1];
     } 

// Drawing area	  
	  UpBar=bsmax[shift];
	  DnBar=bsmin[shift];
	  
	  if ( Risk == 0 ){UpBar=Mid[shift];DnBar=Mid[shift];}
	  
	  if (trend>0) 
	  {
	     if (Signal>0 && UpTrendBuffer[shift+1]==-1.0)
	     {
	        //bsmin[shift]=smin[shift];
	        UpTrendSignal[shift]=bsmin[shift];
	        if(Line>0) UpTrendLine[shift]=bsmin[shift];
	        
	     }
	     else
	     {
	     UpTrendBuffer[shift]=bsmin[shift];
	     if(Line>0) UpTrendLine[shift]=bsmin[shift];
	     UpTrendSignal[shift]=-1;
	     }
	  if(ColorBar>0)
	        {
	           if(Close[shift]>UpBar)
	           {
	              UpTrendBar[shift]=High[shift];
	              DownTrendBar[shift]=Low[shift];
	           }
	           else
	           {
	              UpTrendBar[shift]=EMPTY_VALUE;
	              DownTrendBar[shift]=EMPTY_VALUE;
	           }
	              
	        }   
	  if (Signal==2) UpTrendBuffer[shift]=0;   
	  DownTrendBuffer[shift]=-1.0;
	  DownTrendLine[shift]=EMPTY_VALUE;
	  }
	  
	  if (trend<0) 
	  {
	  if (Signal>0 && DownTrendBuffer[shift+1]==-1.0)
	     {
	     //bsmax[shift]=smax[shift];
	     DownTrendSignal[shift]=bsmax[shift];
	     if(Line>0) DownTrendLine[shift]=bsmax[shift];
	     }
	     else
	     {
	     DownTrendBuffer[shift]=bsmax[shift];
	     if(Line>0)DownTrendLine[shift]=bsmax[shift];
	     DownTrendSignal[shift]=-1;
	     }
	  if(ColorBar>0)
	        {
	           if(Close[shift]<DnBar)
	           {
	              UpTrendBar[shift]=Low[shift];
	              DownTrendBar[shift]=High[shift];
	           }
	           else
	           {
	              UpTrendBar[shift]=EMPTY_VALUE;
	              DownTrendBar[shift]=EMPTY_VALUE;
	           }      
	        }   
	  if (Signal==2) DownTrendBuffer[shift]=0;    
	  UpTrendBuffer[shift]=-1.0;
	  UpTrendLine[shift]=EMPTY_VALUE;
	  }
	  
	 
   }
   return(0);
}

int OpenOrder(string S, int OP)
{
 
 int cnt=10;
 int res=0;
 if (OP==OP_BUY)
  {
   double Price=MarketInfo(S,MODE_ASK);
   double CSL=Price-SL;
   double CTP=Price+TP;
  }
 if (OP==OP_SELL)
  {
   Price=MarketInfo(S,MODE_BID);
   CSL=Price+SL;
   CTP=Price-TP;
  }
 while (res==0 && cnt>0)
  {
   res=OrderSend(S,OP,Lots,Price,Slippage,CSL,CTP," Crazy`s`Graal on "+S+" ",MagicNumber,0,CLR_NONE);
   if (res>0) 
     {
      Comment("                                                                               ");
      Sleep(2000);
     } 
    else 
     {
      int le=GetLastError();
      Comment("                                                                               ");
      Comment("Ошибка открытия ордера #",le," - ",ErrorDescription(le));
      Sleep(6000);
      cnt--;
     }
  }
 if (res==-1) res=0;
 return(res);
}

bool CloseOrder(int T, string S, int OP)
{
 int cnt=10;
 bool res=false;
 if (OP==OP_BUY) {double Price=MarketInfo(S,MODE_BID);}
 if (OP==OP_SELL)       {Price=MarketInfo(S,MODE_ASK);}
 while (!res && cnt>0)
  {
   OrderSelect(T,SELECT_BY_TICKET,MODE_TRADES);
   res=OrderClose(T,OrderLots(),Price,Slippage,CLR_NONE);
   if (res) 
     {
      Comment("                                                                               ");
      Sleep(2000);
     } 
    else 
     {
      int le=GetLastError();
      Comment("                                                                               ");
      Comment("Ошибка закрытия ордера #",le," - ",ErrorDescription(le));
      Sleep(6000);
      cnt--;
     }
  }
 return(res);
}

int Signal()
{
 PriceChannel_Stop_v6();
 int res=0;
 if (UpTrendSignal[0]>0) res=1;
 if (DownTrendSignal[0]>0) res=-1;
 return(res);
}

bool BuyNotExist()
{
 bool res=true;
 for (i=OrdersTotal()-1;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_BUY) res=false;
   if (!res) break;
  }
 return(res);
}

bool SellNotExist()
{
 bool res=true;
 for (i=OrdersTotal()-1;i>=0;i--)
  {
   OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol()==Symbol() && OrderMagicNumber()==MagicNumber && OrderType()==OP_SELL) res=false;
   if (!res) break;
  }
 return(res);
}

void start()
{
 i=Bars;
 j=Signal();
 if (j==1 && CBar!=i) if (BuyNotExist())
  {
   CloseOrder(CTicket,S,OP_SELL);
   CTicket=OpenOrder(S, OP_BUY);
   CBar=i;
  }
  if (j==-1 && CBar!=i) if (SellNotExist())
  {
   CloseOrder(CTicket,S,OP_BUY);
   CTicket=OpenOrder(S, OP_SELL);
   CBar=i;
  }
 return(0);
}

