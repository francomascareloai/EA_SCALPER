//+------------------------------------------------------------------+
//|                                           	  	      Trix_EA.mq4 |
//|                                  Copyright © 2007, Forex-Experts |
//|                                     http://www.forex-experts.com |
//+------------------------------------------------------------------+

#define OrderStr "Trix_EA"
#property copyright "Copyright © 2007, Forex-Experts"
#property link      "http://www.forex-experts.com"


extern double  Lots = 0.1;
extern int		StopLoss = 50;
extern int	 	TakeProfit = 0;
extern bool 	TradeAtCloseBar = true;
extern int 		TrailingStop = 0;
extern int 		TrailingStep = 1;      //Trailing step
extern int    	BreakEven = 0;
extern int	  	MagicNumber=0;
//For alerts:
extern int     Repeat=3;
extern int     Periods=5;
extern bool    UseAlert=false;
extern bool    SendEmail=true;
extern string
			TradeLog="Trix_EA";


extern int  Slippage = 3;

int 	         mm = 0;
double         Risk = 10;
int       	   Crepeat=0;
int            AlertTime=0;
double         AheadTradeSec = 0;
double         AheadExitSec = 0;
int     			TradeBar = 0;
double         MaxTradeTime = 300;

extern string  
         Indicator_Setting = "---------- Indicator Setting";
extern int  TimeFrame      = 0;
extern int  TRIX_Period    = 13;
extern int  Signal_Period 	= 8;
extern bool Signals      	= true;
extern int  CountBars    	= 1500;

int
					NumberOfTries		= 5, //Number of tries to set, close orders;
					RetryTime			= 1; 



double	
			Ilo					=	0;

int DotLoc=7;
static int TradeLast=0;

string sound="alert.wav";

double sig_buy=0, sig_sell=0;

int Spread=0;
string filename="";

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 


Crepeat=Repeat;    
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
if (TradeAtCloseBar) TradeBar=1;
else TradeBar=0;

filename=Symbol() + TradeLog + "-" + Month() + "-" + Day() + ".log";


Spread=MarketInfo(Symbol(),MODE_SPREAD);


//---- 
int   i=0;

double   BuyValue=0, SellValue=0;
BuyValue=0; SellValue=0;


if (CntOrd(OP_BUY,MagicNumber)>0) TradeLast=1;
if (CntOrd(OP_SELL,MagicNumber)>0) TradeLast=-1;

sig_buy=iCustom(NULL,0,"#MTF_Trix",TimeFrame,TRIX_Period,Signal_Period,Signals,CountBars,2,TradeBar);
sig_sell=iCustom(NULL,0,"#MTF_Trix",TimeFrame,TRIX_Period,Signal_Period,Signals,CountBars,3,TradeBar);



//Comment("sig_buy=",sig_buy," sig_sell=",sig_sell); 


if (sig_buy!=EMPTY_VALUE) {     
	BuyValue=1; 
}


if (sig_sell!=EMPTY_VALUE) {     
	SellValue=1;
}



int  cnt=0,OpenPos=0,OpenSell=0,OpenBuy=0,CloseSell=0,CloseBuy=0;
double	mode=0,Stop=0,NewBarTime=0;

//Here we found if new bar has just opened
static int prevtime=0;  
int NewBar=0,FirstRun=1;

if (FirstRun==1) {
FirstRun=0;
prevtime=Time[0];
}
if ((prevtime == Time[0]) &&  (CurTime()-prevtime)>MaxTradeTime) {
NewBar=0;
}
else {
prevtime = Time[0];
NewBar=1;
}


int   AllowTrade=0,AllowExit=0;
//Trade before bar current bar closed
if (CurTime()>= Time[0]+Period()*60-AheadTradeSec) AllowTrade=1; else AllowTrade=0;
if (CurTime()>= Time[0]+Period()*60-AheadExitSec) AllowExit=1; else AllowExit=0;
if (AheadTradeSec==0) AllowTrade=1;
if (AheadExitSec==0) AllowExit=1;

/*====================== MONEY MANAGEMENT / COMPOUNDING ===========================================
Changing the value of mm will give you several money management options
mm = -1 : Fractional lots/ balance X the risk factor.(use for Mini accts)
mm = 0 : Single Lots.
mm = 1 : Full lots/ balance X the risk factor up to 100 lot orders.(use for Regular accounts)
***************************************************************************************************
RISK FACTOR:
risk can be anything from 1 up. 
Factor of 5 adds a lot for every $20,000.00 ($2000-MINI) added to the balance. 
Factor of 10 adds a lot with every $10.000.00 ($1000-MINI) added to the balance.
The higher the risk,  the easier it is to blow your margin..
***************************************************************************************************/

Ilo=Lots;
if (mm<0) 
  {
	Ilo=MathCeil(AccountEquity()*Risk/10000)/10-0.1;
	if (Ilo<0.1) Ilo=0.1;		
  }
if (mm>0) 
  {
	Ilo=MathCeil(AccountEquity()*Risk/10000)/10-1;
	if (Ilo>1) Ilo=MathCeil(Ilo);
    if (Ilo<1) Ilo=1;		
  }
if (Ilo>100) Ilo=100;

OpenPos=0;
for(cnt=0; cnt<OrdersTotal(); cnt++) {
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
if ((OrderType()==OP_SELL || OrderType()==OP_BUY) && OrderSymbol()==Symbol() && ((OrderMagicNumber () == MagicNumber) || MagicNumber==0)) OpenPos=OpenPos+1;
}

if (OpenPos>=1) {
		OpenSell=0;	OpenBuy=0;
}



OpenBuy=0; OpenSell=0;
CloseBuy=0; CloseSell=0;

//Conditions to open the position
//
if (SellValue>0) {
	OpenSell=1;
	OpenBuy=0;
}

if  (BuyValue>0) {
	OpenBuy=1;
	OpenSell=0;

}

//Print("OpenSell=",OpenSell," OpenBuy=",OpenBuy);


//Conditions to close the positions
if (SellValue>0) {
	CloseBuy=1;
}


if (BuyValue>0) {
	CloseSell=1;
}

subPrintDetails();


for(cnt=0; cnt<OrdersTotal(); cnt++) {
OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);

	if (OrderType()==OP_BUY && OrderSymbol()==Symbol() && ((OrderMagicNumber () == MagicNumber) || MagicNumber==0)) {
		if (CloseBuy==1 && AllowExit==1) {
				if (NewBar==1 && TradeBar>0)
				{
				   SetText(Time[0],High[0]+1*DotLoc*Point,("CloseBuy"+DoubleToStr(Time[0],0)),CharToStr(251),Magenta);
				   PlaySound("alert.wav");
				   OrdClose(OrderTicket(),OrderLots(),Bid,Slippage,Red);  
					Alerts(0, 0, CloseBuy, CloseSell,Bid,0,0,OrderTicket());
					return(0);	
				}
				if (TradeBar==0) 
				{  
				   SetText(Time[0],High[0]+1*DotLoc*Point,("CloseBuy"+DoubleToStr(Time[0],0)),CharToStr(251),Magenta);
				   PlaySound("alert.wav");
				   OrdClose(OrderTicket(),OrderLots(),Bid,Slippage,Red);
					Alerts(0, 0, CloseBuy, CloseSell,Bid,0,0,OrderTicket());
					return(0);	
				}
			
		}	
	}

	if (OrderType()==OP_SELL && OrderSymbol()==Symbol() && ((OrderMagicNumber () == MagicNumber) || MagicNumber==0)) {
		if (CloseSell==1 && AllowExit==1) {
			if (NewBar==1 && TradeBar>0)
			{
				   SetText(Time[0],High[0]-0.3*DotLoc*Point,("CloseSell"+DoubleToStr(Time[0],0)),CharToStr(251),Magenta);
				   PlaySound("alert.wav");
				   OrdClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);
					Alerts(0, 0, CloseBuy, CloseSell,Ask,0,0,OrderTicket());
					return(0);	
			}
			if (TradeBar==0)
			{
               SetText(Time[0],High[0]-0.3*DotLoc*Point,("CloseSell"+DoubleToStr(Time[0],0)),CharToStr(251),Magenta);				   
				   PlaySound("alert.wav");
				   OrdClose(OrderTicket(),OrderLots(),Ask,Slippage,Red);
					Alerts(0, 0, CloseBuy, CloseSell,Ask,0,0,OrderTicket());
					return(0);	
			}


		}
	}

}

double MyStopLoss=0, MyTakeProfit=0;
int ticket=0;



//Should we open a position?
if (OpenPos==0) {
	if (OpenSell==1 && AllowTrade==1) {
		if (NewBar==1 && TradeBar>0) 
		{
      SetText(Time[0],High[0]+1*DotLoc*Point,("Sell"+DoubleToStr(Time[0],0)),CharToStr(234),Red);
      if (TakeProfit==0) MyTakeProfit=0; else MyTakeProfit=Bid-TakeProfit*Point;
 		if (StopLoss==0) MyStopLoss=0; else MyStopLoss=Bid+StopLoss*Point;		
      PlaySound("alert.wav");
      ticket=OrdSend(Symbol(),OP_SELL,Ilo,Bid,Slippage,MyStopLoss,MyTakeProfit,OrderStr,MagicNumber,0,Red);
		Alerts(OpenBuy, OpenSell, 0, 0,Bid,MyStopLoss,MyTakeProfit,ticket);
		OpenSell=0;
		return(0);
		}
		if (TradeBar==0)
		{
		SetText(Time[0],High[0]+1*DotLoc*Point,("Sell"+DoubleToStr(Time[0],0)),CharToStr(234),Red);		
      if (TakeProfit==0) MyTakeProfit=0; else MyTakeProfit=Bid-TakeProfit*Point;
 		if (StopLoss==0) MyStopLoss=0; else MyStopLoss=Bid+StopLoss*Point;		
      PlaySound("alert.wav");
      ticket=OrdSend(Symbol(),OP_SELL,Ilo,Bid,Slippage,MyStopLoss,MyTakeProfit,OrderStr,MagicNumber,0,Red);		
		Alerts(OpenBuy, OpenSell, 0, 0,Bid,MyStopLoss,MyTakeProfit,ticket);
		OpenSell=0;
		return(0);		
		}
	}	
	if (OpenBuy==1 && AllowTrade==1) {
		if (NewBar==1 && TradeBar>0)
		{
      SetText(Time[0],Low[0]-0.3*DotLoc*Point,("Buy"+DoubleToStr(Time[0],0)),CharToStr(233),Lime);
      if (TakeProfit==0) MyTakeProfit=0; else MyTakeProfit=Ask+TakeProfit*Point;
      if (StopLoss==0) MyStopLoss=0; else MyStopLoss=Ask-StopLoss*Point;		      
      PlaySound("alert.wav");
      ticket=OrdSend(Symbol(),OP_BUY,Ilo,Ask,Slippage,MyStopLoss,MyTakeProfit,OrderStr,MagicNumber,0,Lime);
		Alerts(OpenBuy, OpenSell, 0, 0,Ask,MyStopLoss,MyTakeProfit,ticket);
		OpenBuy=0;
		return(0);
		}
		if (TradeBar==0)
		{
      SetText(Time[0],Low[0]-0.3*DotLoc*Point,("Buy"+DoubleToStr(Time[0],0)),CharToStr(233),Lime);
      if (TakeProfit==0) MyTakeProfit=0; else MyTakeProfit=Ask+TakeProfit*Point;
      if (StopLoss==0) MyStopLoss=0; else MyStopLoss=Ask-StopLoss*Point;		      
      PlaySound("alert.wav");
      ticket=OrdSend(Symbol(),OP_BUY,Ilo,Ask,Slippage,MyStopLoss,MyTakeProfit,OrderStr,MagicNumber,0,Lime);
		Alerts(OpenBuy, OpenSell, 0, 0,Ask,MyStopLoss,MyTakeProfit,ticket);
		OpenBuy=0;
		return(0);
		}
		
	}

}



for (i=0; i<OrdersTotal(); i++) {
   if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if (OrderSymbol()==Symbol() && ((OrderMagicNumber () == MagicNumber) || MagicNumber==0)) {
         TrailingPositions();
      }
   }
}


Alerts(0, 0, 0, 0, 0, 0, 0, 0);


// the end

  
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

void SetText(int X1, double Y1, string TEXT_NAME, string TEXT_VALUE, int TEXT_COLOR) {
return;
if(ObjectFind(TEXT_NAME) != 0)
{
   ObjectCreate(TEXT_NAME, OBJ_TEXT, 0, X1, Y1);
   ObjectSet(TEXT_NAME,OBJPROP_COLOR,TEXT_COLOR);
   ObjectSetText(TEXT_NAME, TEXT_VALUE, 10, "Wingdings", EMPTY);         
}
else
{
   ObjectMove(TEXT_NAME, 0, X1, Y1);
}                  
}


void Alerts(int _buy, int _sell, int _exitbuy, int _exitsell, double _op, double _sl, double _tp, int _ticket) {

string AlertStr="";
AlertStr="";
string CurDate="";
CurDate=TimeToStr(CurTime(),TIME_DATE|TIME_MINUTES);

//Alert system
if (UseAlert)
{

if (_buy==1) 
{ 
   if (Crepeat==Repeat)
   { 
      AlertTime=0;
   }
   if (Crepeat>0 && (CurTime()-AlertTime)>Periods)
   {
   if (_buy==1) {
   AlertStr=AlertStr+"Buy @ "+DoubleToStr(_op,Digits)+"; SL: "+DoubleToStr(_sl,Digits)+"; TP: "+DoubleToStr(_tp,Digits)+" at "+CurDate+" Order:"+DoubleToStr(_ticket,0)+"."; 
   Alert(Symbol()," ",Period(), ": ",AlertStr); 
   if (SendEmail) 
   {
      SendMail(Symbol()+" "+Period()+ ": ",Symbol()+" "+Period()+": "+AlertStr);
   }


      Crepeat=Crepeat-1;
      AlertTime=CurTime();
   }

   } 
}

if (_sell==1) 
{ 
   if (Crepeat==Repeat)
   { 
      AlertTime=0;
   }
   if (Crepeat>0 && (CurTime()-AlertTime)>Periods)
   {
   if (_sell==1) {
      AlertStr=AlertStr+"Sell @ "+DoubleToStr(_op,Digits)+"; SL: "+DoubleToStr(_sl,Digits)+"; TP: "+DoubleToStr(_tp,Digits)+" at "+CurDate+" Order:"+DoubleToStr(_ticket,0)+"."; 
   Alert(Symbol()," ",Period(), ": ",AlertStr); 
   if (SendEmail) 
   {
      SendMail(Symbol()+" "+Period()+ ": ",Symbol()+" "+Period()+": "+AlertStr);
   }


      Crepeat=Crepeat-1;
      AlertTime=CurTime();
   }

   } 
}

if (_exitsell==1) 
{ 
   if (Crepeat==Repeat)
   { 
   AlertTime=0;
   }

if (Crepeat>0 && (CurTime()-AlertTime)>Periods)
{
   if (_exitsell==1) {
   AlertStr=AlertStr+" Close Sell @ "+DoubleToStr(_op,Digits)+" at "+CurDate+" Order:"+DoubleToStr(_ticket,0)+"."; 
   Alert(Symbol()," ",Period(), ": ", AlertStr); 
   if (SendEmail) 
   {
      SendMail(Symbol()+" "+Period()+ ": ",Symbol()+" "+Period()+": "+AlertStr);
   }


   Crepeat=Crepeat-1;
   AlertTime=CurTime();
   }

}

} 


if (_exitbuy==1) 
{ 
   if (Crepeat==Repeat)
   { 
      AlertTime=0;
   }
   if (Crepeat>0 && (CurTime()-AlertTime)>Periods)
   {
   if (_exitbuy==1) {
   AlertStr=AlertStr+" Close Buy @ "+DoubleToStr(_op,Digits)+" at "+CurDate+" Order:"+DoubleToStr(_ticket,0)+"."; 
   Alert(Symbol()," ",Period(), ": ",AlertStr); 
   if (SendEmail) 
   {
      SendMail(Symbol()+" "+Period()+ ": ",Symbol()+" "+Period()+": "+AlertStr);
   }


      Crepeat=Crepeat-1;
      AlertTime=CurTime();
   }

   } 
}

if (_exitbuy==0 && _exitsell==0 && _buy==0 && _sell==0)  
{
   Crepeat=Repeat;
   AlertTime=0;
}

}
//




//----
return;
}


//----------------------- PRINT COMMENT FUNCTION
void subPrintDetails()
{
   string sComment   = "";
   string sp         = "----------------------------------------\n";
   string NL         = "\n";
	string sDirection = "";
   sComment = "Trix_EA v.1.0" + NL;
   sComment = sComment + "StopLoss=" + DoubleToStr(StopLoss,0) + " | "; 
   sComment = sComment + "TakeProfit=" + DoubleToStr(TakeProfit,0) + " | ";
   sComment = sComment + "TrailingStop=" + DoubleToStr(TrailingStop,0) + NL;   
   sComment = sComment + sp;   
   sComment = sComment + "Lots=" + DoubleToStr(Ilo,2) + " | ";
   sComment = sComment + "LastTrade=" + DoubleToStr(TradeLast,0) + NL; 
   sComment = sComment + "sig_buy=" + DoubleToStr(sig_buy,Digits) + NL; 
   sComment = sComment + "sig_sell=" + DoubleToStr(sig_sell,Digits) + NL; 
   sComment = sComment + sp;  
   Comment(sComment);
}




int CntOrd(int Type, int Magic) {
//return number of orders with specific parameters
int _CntOrd;
_CntOrd=0;
for(int i=0;i<OrdersTotal();i++)
{
   OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
  
   if (OrderSymbol()==Symbol()) {
      if ( (OrderType()==Type && (OrderMagicNumber()==Magic) || Magic==0)) _CntOrd++;
   }
}
return(_CntOrd);
}



//+------------------------------------------------------------------+
//| return error description                                         |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string;
//----
   switch(error_code)
     {
      //---- codes returned from trade server
      case 0:
      case 1:   error_string="no error";                                                  break;
      case 2:   error_string="common error";                                              break;
      case 3:   error_string="invalid trade parameters";                                  break;
      case 4:   error_string="trade server is busy";                                      break;
      case 5:   error_string="old version of the client terminal";                        break;
      case 6:   error_string="no connection with trade server";                           break;
      case 7:   error_string="not enough rights";                                         break;
      case 8:   error_string="too frequent requests";                                     break;
      case 9:   error_string="malfunctional trade operation";                             break;
      case 64:  error_string="account disabled";                                          break;
      case 65:  error_string="invalid account";                                           break;
      case 128: error_string="trade timeout";                                             break;
      case 129: error_string="invalid price";                                             break;
      case 130: error_string="invalid stops";                                             break;
      case 131: error_string="invalid trade volume";                                      break;
      case 132: error_string="market is closed";                                          break;
      case 133: error_string="trade is disabled";                                         break;
      case 134: error_string="not enough money";                                          break;
      case 135: error_string="price changed";                                             break;
      case 136: error_string="off quotes";                                                break;
      case 137: error_string="broker is busy";                                            break;
      case 138: error_string="requote";                                                   break;
      case 139: error_string="order is locked";                                           break;
      case 140: error_string="long positions only allowed";                               break;
      case 141: error_string="too many requests";                                         break;
      case 145: error_string="modification denied because order too close to market";     break;
      case 146: error_string="trade context is busy";                                     break;
      //---- mql4 errors
      case 4000: error_string="no error";                                                 break;
      case 4001: error_string="wrong function pointer";                                   break;
      case 4002: error_string="array index is out of range";                              break;
      case 4003: error_string="no memory for function call stack";                        break;
      case 4004: error_string="recursive stack overflow";                                 break;
      case 4005: error_string="not enough stack for parameter";                           break;
      case 4006: error_string="no memory for parameter string";                           break;
      case 4007: error_string="no memory for temp string";                                break;
      case 4008: error_string="not initialized string";                                   break;
      case 4009: error_string="not initialized string in array";                          break;
      case 4010: error_string="no memory for array\' string";                             break;
      case 4011: error_string="too long string";                                          break;
      case 4012: error_string="remainder from zero divide";                               break;
      case 4013: error_string="zero divide";                                              break;
      case 4014: error_string="unknown command";                                          break;
      case 4015: error_string="wrong jump (never generated error)";                       break;
      case 4016: error_string="not initialized array";                                    break;
      case 4017: error_string="dll calls are not allowed";                                break;
      case 4018: error_string="cannot load library";                                      break;
      case 4019: error_string="cannot call function";                                     break;
      case 4020: error_string="expert function calls are not allowed";                    break;
      case 4021: error_string="not enough memory for temp string returned from function"; break;
      case 4022: error_string="system is busy (never generated error)";                   break;
      case 4050: error_string="invalid function parameters count";                        break;
      case 4051: error_string="invalid function parameter value";                         break;
      case 4052: error_string="string function internal error";                           break;
      case 4053: error_string="some array error";                                         break;
      case 4054: error_string="incorrect series array using";                             break;
      case 4055: error_string="custom indicator error";                                   break;
      case 4056: error_string="arrays are incompatible";                                  break;
      case 4057: error_string="global variables processing error";                        break;
      case 4058: error_string="global variable not found";                                break;
      case 4059: error_string="function is not allowed in testing mode";                  break;
      case 4060: error_string="function is not confirmed";                                break;
      case 4061: error_string="send mail error";                                          break;
      case 4062: error_string="string parameter expected";                                break;
      case 4063: error_string="integer parameter expected";                               break;
      case 4064: error_string="double parameter expected";                                break;
      case 4065: error_string="array as parameter expected";                              break;
      case 4066: error_string="requested history data in update state";                   break;
      case 4099: error_string="end of file";                                              break;
      case 4100: error_string="some file error";                                          break;
      case 4101: error_string="wrong file name";                                          break;
      case 4102: error_string="too many opened files";                                    break;
      case 4103: error_string="cannot open file";                                         break;
      case 4104: error_string="incompatible access to a file";                            break;
      case 4105: error_string="no order selected";                                        break;
      case 4106: error_string="unknown symbol";                                           break;
      case 4107: error_string="invalid price parameter for trade function";               break;
      case 4108: error_string="invalid ticket";                                           break;
      case 4109: error_string="trade is not allowed";                                     break;
      case 4110: error_string="longs are not allowed";                                    break;
      case 4111: error_string="shorts are not allowed";                                   break;
      case 4200: error_string="object is already exist";                                  break;
      case 4201: error_string="unknown object property";                                  break;
      case 4202: error_string="object is not exist";                                      break;
      case 4203: error_string="unknown object type";                                      break;
      case 4204: error_string="no object name";                                           break;
      case 4205: error_string="object coordinates error";                                 break;
      case 4206: error_string="no specified subwindow";                                   break;
      default:   error_string="unknown error";
     }
//----
   return(error_string);
  }  
//+------------------------------------------------------------------+





int Write(string str)
{
//Write log file
   int handle; 
   handle = FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV,"/t");
   FileSeek(handle, 0, SEEK_END);      
   FileWrite(handle," Time " + TimeToStr(CurTime(),TIME_DATE|TIME_SECONDS) + ": " + str);
   FileClose(handle);
	Print(str);
}




int OrdSend(string _symbol, int _cmd, double _volume, double _price, int _slippage, double _stoploss, double _takeprofit, string _comment="", int _magic=0, datetime _expiration=0, color _arrow_color=CLR_NONE) {
//Send order with retry capabilities and log
int _stoplevel=MarketInfo(_symbol,MODE_STOPLEVEL);
double _priceop=0;
int ticket,err,tries;
tries = 0;
switch (_cmd) {
	case OP_BUY:
		if (!IsTradeContextBusy() && IsTradeAllowed()) {
		while (tries < NumberOfTries) {
			RefreshRates();
			ticket = OrderSend(_symbol,OP_BUY,_volume,Ask,_slippage,NormalizeDouble(_stoploss,Digits),NormalizeDouble(_takeprofit,Digits),_comment,_magic,_expiration,_arrow_color);
			if(ticket<=0) {
				Write("Error Occured : "+ErrorDescription(GetLastError()));
				Write(Symbol()+" Buy @ "+Ask+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
				tries++;
			} else {
				tries = NumberOfTries;
				Write("Order opened : "+Symbol()+" Buy @ "+Ask+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
			}
			Sleep(RetryTime*1000);
		}
		}
		err=ticket;
		break;

	case OP_SELL:
		if (!IsTradeContextBusy() && IsTradeAllowed()) {
		while (tries < NumberOfTries) {
			RefreshRates();
			ticket = OrderSend(_symbol,OP_SELL,_volume,Bid,_slippage,NormalizeDouble(_stoploss,Digits),NormalizeDouble(_takeprofit,Digits),_comment,_magic,_expiration,_arrow_color);
			if(ticket<=0) {
				Write("Error Occured : "+ErrorDescription(GetLastError()));
				Write(Symbol()+" Sell @ "+Bid+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
				tries++;
			} else {
				tries = NumberOfTries;
				Write("Order opened : "+Symbol()+" Sell @ "+Bid+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
			}
			Sleep(RetryTime*1000);	
		}
		}
		err=ticket;
		break;

	case OP_BUYSTOP:
		while (tries < NumberOfTries) {
			RefreshRates();
			if ((_price-Ask)<_stoplevel*Point) _priceop=Ask+_stoplevel*Point; else _priceop=_price;			
			ticket = OrderSend(_symbol,OP_BUYSTOP,_volume,NormalizeDouble(_priceop,Digits),_slippage,NormalizeDouble(_stoploss,Digits),NormalizeDouble(_takeprofit,Digits),_comment,_magic,_expiration,_arrow_color);
			if(ticket<=0) {
				Write("Error Occured : "+ErrorDescription(GetLastError()));
				Write(Symbol()+" Buy Stop @ "+_priceop+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
				tries++;
			} else {
				tries = NumberOfTries;
				Write("Order opened : "+Symbol()+" Buy Stop@ "+_priceop+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
			}
			Sleep(RetryTime*1000);
		}
		err=ticket;
		break;


	case OP_SELLSTOP:
		if (!IsTradeContextBusy() && IsTradeAllowed()) {
		while (tries < NumberOfTries) {
			RefreshRates();
			if ((Bid-_price)<_stoplevel*Point) _priceop=Bid-_stoplevel*Point; else _priceop=_price;			
			ticket = OrderSend(_symbol,OP_SELLSTOP,_volume,NormalizeDouble(_priceop,Digits),_slippage,NormalizeDouble(_stoploss,Digits),NormalizeDouble(_takeprofit,Digits),_comment,_magic,_expiration,_arrow_color);
			if(ticket<=0) {
				Write("Error Occured : "+ErrorDescription(GetLastError()));
				Write(Symbol()+" Sell Stop @ "+_priceop+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
				tries++;
			} else {
				tries = NumberOfTries;
				Write("Order opened : "+Symbol()+" Sell Stop @ "+_priceop+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
			}
			Sleep(RetryTime*1000);
		}
		}
		err=ticket;
		break;


	case OP_BUYLIMIT:
		if (!IsTradeContextBusy() && IsTradeAllowed()) {
		while (tries < NumberOfTries) {
			RefreshRates();
			if ((Ask-_price)<_stoplevel*Point) _priceop=Ask-_stoplevel*Point; else _priceop=_price;			
			ticket = OrderSend(_symbol,OP_BUYLIMIT,_volume,NormalizeDouble(_priceop,Digits),_slippage,NormalizeDouble(_stoploss,Digits),NormalizeDouble(_takeprofit,Digits),_comment,_magic,_expiration,_arrow_color);
			if(ticket<=0) {
				Write("Error Occured : "+ErrorDescription(GetLastError()));
				Write(Symbol()+" Buy Limit @ "+_priceop+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
				tries++;
			} else {
				tries = NumberOfTries;
				Write("Order opened : "+Symbol()+" Buy Limit @ "+_priceop+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
			}
			Sleep(RetryTime*1000);
		}
		}
		err=ticket;
		break;

	case OP_SELLLIMIT:
		if (!IsTradeContextBusy() && IsTradeAllowed()) {
		while (tries < NumberOfTries) {
			RefreshRates();
			if ((_price-Bid)<_stoplevel*Point) _priceop=Bid+_stoplevel*Point; else _priceop=_price;			
			ticket = OrderSend(_symbol,OP_BUYLIMIT,_volume,NormalizeDouble(_priceop,Digits),_slippage,NormalizeDouble(_stoploss,Digits),NormalizeDouble(_takeprofit,Digits),_comment,_magic,_expiration,_arrow_color);
			if(ticket<=0) {
				Write("Error Occured : "+ErrorDescription(GetLastError()));
				Write(Symbol()+" Sell Limit @ "+_priceop+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
				tries++;
			} else {
				tries = NumberOfTries;
				Write("Order opened : "+Symbol()+" Sell Limit @ "+_priceop+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+ticket);
			}
			Sleep(RetryTime*1000);
		}
		err=ticket;
		}
		break;

	default:
		Write("No valid type of order found");
		err=-1;
		break;
}
return(err);
}


int OrdClose(int _ticket, double _lots, double _price, int _slippage, color _color=CLR_NONE) {
//The function close order with log
double _priceop=0;
int ticket,err,tries;

tries = 0;
		if (!IsTradeContextBusy() && IsTradeAllowed()) {
		while (tries < NumberOfTries) {
			RefreshRates();
			ticket = OrderClose(_ticket,_lots,NormalizeDouble(_price,Digits),_slippage,_color);
			if(ticket==0) {
				Write("Error Occured : "+ErrorDescription(GetLastError()));
				Write(Symbol()+" Close @ "+_price+" ticket ="+_ticket);
				tries++;
			} else {
				tries = NumberOfTries;
				Write("Order closed : "+Symbol()+" Close @ "+_price+" ticket ="+_ticket);
			}
			Sleep(RetryTime*1000);
		}
		}
		err=ticket;

return(err);

}


int OrdModify(int _ticket, double _price, double _stoploss, double _takeprofit, datetime _expiration, color _color=CLR_NONE) {
//The function modify order with log
double _priceop=0;
int ticket,err,tries;

tries = 0;				
		if (!IsTradeContextBusy() && IsTradeAllowed()) {
		while (tries < NumberOfTries) {
			RefreshRates();
			ticket = OrderModify(_ticket,NormalizeDouble(_price,Digits),NormalizeDouble(_stoploss,Digits),NormalizeDouble(_takeprofit,Digits),_expiration,_color);
			if(ticket==0) {
				Write("Error Occured : "+ErrorDescription(GetLastError()));
				Write(Symbol()+" Modify @ "+_price+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+_ticket);
				tries++;
			} else {
				tries = NumberOfTries;
				Write("Order modified : "+Symbol()+" Modify @ "+_price+" SL @ "+_stoploss+" TP @"+_takeprofit+" ticket ="+_ticket);
			}
			Sleep(RetryTime*1000);
		}
		}
		err=ticket;
		return(err);

}



/*


int OrdDelete(int _ticket) {
//Delete pending order
double _priceop=0;
int ticket,err,tries;
tries = 0;
		if (!IsTradeContextBusy() && IsTradeAllowed()) {
		while (tries < NumberOfTries) {
			RefreshRates();
			ticket = OrderDelete(_ticket);
			if(ticket==0) {
				Write("Error Occured : "+ErrorDescription(GetLastError()));
				Write(Symbol()+" Delete @ "+Bid+" ticket ="+_ticket);
				tries++;
			} else {
				tries = NumberOfTries;
				Write("Order Deleted : "+Symbol()+" Delete @ "+Bid+" ticket ="+_ticket);
			}
			Sleep(RetryTime*1000);
		}
		}
		err=ticket;		
		return(err);
} 
*/

void TrailingPositions() {
  double pBid, pAsk, pp;

  pp = MarketInfo(OrderSymbol(), MODE_POINT);
  if (OrderType()==OP_BUY) {
   pBid = MarketInfo(OrderSymbol(), MODE_BID);

//BreakEven routine
    if (BreakEven>0) {
      if ((pBid-OrderOpenPrice())>BreakEven*pp) {
         if ((OrderStopLoss()-OrderOpenPrice())<0) {
            ModifyStopLoss(OrderOpenPrice()+0*pp);
         }   
      }    
    }
    
    if (TrailingStop>0) {
    if ((pBid-OrderOpenPrice())>TrailingStop*pp) {
      if (OrderStopLoss()<pBid-(TrailingStop+TrailingStep-1)*pp) {
        ModifyStopLoss(pBid-TrailingStop*pp);
        return;
      }
    }
    }

  }
  if (OrderType()==OP_SELL) {
    pAsk = MarketInfo(OrderSymbol(), MODE_ASK);

    if (BreakEven>0) {
      if ((OrderOpenPrice()-pAsk)>BreakEven*pp) {
         if ((OrderOpenPrice()-OrderStopLoss())<0) {
            ModifyStopLoss(OrderOpenPrice()-0*pp);
          }
       }
    }

    if (TrailingStop>0) {
    if (OrderOpenPrice()-pAsk>TrailingStop*pp) {
      if (OrderStopLoss()>pAsk+(TrailingStop+TrailingStep-1)*pp || OrderStopLoss()==0) {
        ModifyStopLoss(pAsk+TrailingStop*pp);
        return;
      }
    }
    }


  }
}

//+------------------------------------------------------------------+
//| Modify StopLoss                                                  |
//| Parameters:                                                      |
//|   ldStopLoss - StopLoss Leve                                     |
//+------------------------------------------------------------------+
void ModifyStopLoss(double ldStopLoss) {
  bool fm;
  PlaySound("alert.wav");
  fm=OrdModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE);
}
//+------------------------------------------------------------------+



