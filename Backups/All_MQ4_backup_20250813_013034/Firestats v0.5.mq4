//+-----------------------------------------------------------------------------+
//|                              Firestats v0.5 - Output data for stat analysis |
//+-----------------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven"
#property link      "TraderSeven@gmx.net"

//----------------------- USER INPUT
extern int MA_length = 10;
extern int MAtype=0;//0=close, 1=HL		 
extern double Percent = 0.3;
extern int TakeProfit = 30;
//-----
int UpActive=0;
int handle;
handle=FileOpen("C:\Documents and Settings\JustMe\Desktop\FireStats.csv", FILE_CSV|FILE_WRITE, ';');


//----------------------- MAIN PROGRAM LOOP
int start()
{

/////////// BUG BUG BUGGY
if((iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*(1+Percent/100))<High[0] && UpActive==0)// detect x-over
  {
      Comment("Bling blong");
  double UpEntry=iMA(NULL,0,MA_length,0,MODE_SMA,PRICE_OPEN,0)*(1+Percent/100);
  double UpMax=High[0];
  double UpTarget=(UpMax+UpEntry)/2-(TakeProfit*Point);
  datetime OrderOpenDate=OrderOpenTime();
  UpActive=1;
  }

if(UpActive==1)// check active trades
  {
/////////// BUG BUG BUGGY
  if(Low[0]<UpTarget)// check if ProfitTarget is reached
    {
    Comment("Writing to file....");
    //Target is reached. Now write data to file.
    int PipDD=UpMax-UpEntry;
    datetime OrderCloseDate=OrderCloseTime();
    FileWrite(handle,PipDD,TimeToStr(OrderOpenDate),TimeToStr(OrderCloseDate));
    UpActive=0;//flag trade as closed
    }
  
  if(High[0]>UpMax)// update target
    {
    UpMax=High[0];
    UpTarget=(UpMax+UpEntry)/2-(TakeProfit*Point);
    }
  }  
  





}

